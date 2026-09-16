-- Migration: trainee device locking + access-code sign-in
--
-- Goal: a trainee account is bound to the FIRST device it signs in from.
-- Lesson content is only readable when the request carries that bound device id.
-- Admins can reset a binding (lost/replaced phone) from the admin panel.
--
-- Enforcement is at the DATABASE (RLS), not just the UI, so it holds for every
-- client path — direct PostgREST calls included.

-- ---------------------------------------------------------------------------
-- 1. Device bindings
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.trainee_devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  device_id text NOT NULL,
  device_label text,
  user_agent text,
  bound_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  revoked_at timestamptz
);

-- One ACTIVE binding per user. Revoked rows are kept as an audit trail.
CREATE UNIQUE INDEX IF NOT EXISTS trainee_devices_one_active_per_user
  ON public.trainee_devices (user_id)
  WHERE revoked_at IS NULL;

CREATE INDEX IF NOT EXISTS trainee_devices_lookup_idx
  ON public.trainee_devices (user_id, device_id);

-- Deliberately NO grants to `authenticated`: a trainee must never be able to
-- read their own device_id back out and replay it on another machine.
REVOKE ALL ON public.trainee_devices FROM authenticated, anon;
GRANT ALL ON public.trainee_devices TO service_role;
ALTER TABLE public.trainee_devices ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- 2. Access codes (sign in with a short code instead of email + password)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.access_codes (
  code text PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz,
  revoked_at timestamptz,
  last_used_at timestamptz
);

CREATE INDEX IF NOT EXISTS access_codes_user_idx ON public.access_codes (user_id);

-- Codes are credentials: service_role only, never exposed to the browser.
REVOKE ALL ON public.access_codes FROM authenticated, anon;
GRANT ALL ON public.access_codes TO service_role;
ALTER TABLE public.access_codes ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- 3. Helpers
-- ---------------------------------------------------------------------------

-- The device id the current request claims, taken from the x-device-id header
-- that the Supabase browser client attaches to every call.
CREATE OR REPLACE FUNCTION public.current_device_id()
RETURNS text
LANGUAGE sql
STABLE
AS $$
  SELECT nullif(
    current_setting('request.headers', true)::json ->> 'x-device-id',
    ''
  );
$$;

-- True when the caller's request carries the device this user is bound to.
-- SECURITY DEFINER so the policy can read trainee_devices without granting
-- trainees any direct access to that table.
CREATE OR REPLACE FUNCTION public.device_ok(_user uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.trainee_devices d
    WHERE d.user_id = _user
      AND d.revoked_at IS NULL
      AND d.device_id = public.current_device_id()
  );
$$;

GRANT EXECUTE ON FUNCTION public.current_device_id() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.device_ok(uuid) TO authenticated, anon;

-- ---------------------------------------------------------------------------
-- 4. Lock lesson content to the bound device
-- ---------------------------------------------------------------------------
-- Staff (admin/trainer) are exempt — they author and review from any machine.
-- Trainees only see lesson rows when the request comes from their bound device.
-- Anonymous visitors get nothing (lessons were never part of the public site).
DROP POLICY IF EXISTS "lessons_select_all" ON public.lessons;
DROP POLICY IF EXISTS "lessons_select_device_locked" ON public.lessons;

CREATE POLICY "lessons_select_device_locked" ON public.lessons
  FOR SELECT TO authenticated
  USING (
    public.has_role(auth.uid(), 'admin')
    OR public.has_role(auth.uid(), 'trainer')
    OR public.device_ok(auth.uid())
  );
