-- =============================================================================
-- Two devices per trainee (was one).
--
-- The old partial unique index allowed exactly ONE active binding per user.
-- A count limit can't be a unique index, so it becomes a trigger that locks
-- the user's rows and refuses a third active device. claimDevice() also checks
-- first and returns a friendly "blocked", so the trigger is the backstop for
-- races (two new devices signing in at the same moment).
-- device_ok() already matches ANY active binding, so lesson RLS needs no change.
-- =============================================================================

DROP INDEX IF EXISTS public.trainee_devices_one_active_per_user;

-- The same device must not be bound twice for one user.
CREATE UNIQUE INDEX IF NOT EXISTS trainee_devices_active_user_device
  ON public.trainee_devices (user_id, device_id) WHERE revoked_at IS NULL;

CREATE OR REPLACE FUNCTION public.max_trainee_devices()
RETURNS integer LANGUAGE sql IMMUTABLE AS $$ SELECT 2 $$;

CREATE OR REPLACE FUNCTION public.enforce_device_limit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE _active integer;
BEGIN
  IF NEW.revoked_at IS NOT NULL THEN
    RETURN NEW;
  END IF;
  -- Serialise concurrent binds for the same user.
  PERFORM pg_advisory_xact_lock(hashtext('trainee_devices:' || NEW.user_id::text));
  SELECT count(*) INTO _active
  FROM public.trainee_devices
  WHERE user_id = NEW.user_id
    AND revoked_at IS NULL
    AND id <> NEW.id;
  IF _active >= public.max_trainee_devices() THEN
    RAISE EXCEPTION 'device_limit_reached' USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trainee_devices_limit ON public.trainee_devices;
CREATE TRIGGER trainee_devices_limit
  BEFORE INSERT OR UPDATE OF revoked_at ON public.trainee_devices
  FOR EACH ROW EXECUTE FUNCTION public.enforce_device_limit();

-- Trainees may read their own bindings (for "your devices" display).
DROP POLICY IF EXISTS trainee_devices_own_read ON public.trainee_devices;
CREATE POLICY trainee_devices_own_read ON public.trainee_devices
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_staff());
GRANT SELECT ON public.trainee_devices TO authenticated;
