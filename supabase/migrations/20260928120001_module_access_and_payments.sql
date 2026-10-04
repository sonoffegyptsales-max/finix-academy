-- =============================================================================
-- Per-trainee module access (locked by default) + paid access requests (InstaPay)
--
-- Model: the curriculum is authored ONCE. A trainee sees a module only when a
-- module_access row grants it -- created either by a trainer/admin by hand, or
-- automatically when an admin approves an InstaPay payment request.
--
-- Enforcement is in the DATABASE, not the UI: lessons, lesson media (rows AND
-- storage objects), quiz questions/options and the grading RPC all check
-- access. Hiding a card in React would leave every lesson one API call away.
-- =============================================================================

-- ---------------------------------------------------------------- access table
CREATE TABLE IF NOT EXISTS public.module_access (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  module_id   uuid NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
  source      text NOT NULL DEFAULT 'manual'
              CHECK (source IN ('manual', 'payment', 'migration')),
  request_id  uuid,
  granted_by  uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  granted_at  timestamptz NOT NULL DEFAULT now(),
  revoked_at  timestamptz,
  UNIQUE (user_id, module_id)
);
CREATE INDEX IF NOT EXISTS module_access_user_idx ON public.module_access (user_id) WHERE revoked_at IS NULL;

ALTER TABLE public.module_access ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.module_access FROM anon;
GRANT SELECT ON public.module_access TO authenticated;
-- Writes go through server functions (service role) so grants are audited
-- with granted_by and cannot be self-issued.

DROP POLICY IF EXISTS module_access_select ON public.module_access;
CREATE POLICY module_access_select ON public.module_access
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_staff());

-- ---------------------------------------------------------------- helpers
CREATE OR REPLACE FUNCTION public.has_module_access(_user uuid, _module uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
           SELECT 1 FROM public.user_roles ur
           WHERE ur.user_id = _user AND ur.role IN ('admin', 'trainer'))
      OR EXISTS (
           SELECT 1 FROM public.module_access ma
           WHERE ma.user_id = _user AND ma.module_id = _module AND ma.revoked_at IS NULL);
$$;

CREATE OR REPLACE FUNCTION public.can_access_lesson(_lesson uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.lessons l
    WHERE l.id = _lesson AND public.has_module_access(auth.uid(), l.module_id));
$$;

-- Storage keys look like "<lesson uuid>/<file>". Anything else -> no access.
CREATE OR REPLACE FUNCTION public.can_access_lesson_object(_name text)
RETURNS boolean
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
DECLARE _first text := split_part(_name, '/', 1);
BEGIN
  IF public.is_staff() THEN RETURN true; END IF;
  IF _first !~ '^[0-9a-fA-F-]{36}$' THEN RETURN false; END IF;
  RETURN public.can_access_lesson(_first::uuid);
END;
$$;

-- Lesson counts per module so a LOCKED module card can still say "4 lessons"
-- without exposing lesson rows.
CREATE OR REPLACE FUNCTION public.module_lesson_counts()
RETURNS TABLE (module_id uuid, lessons integer)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT l.module_id, count(*)::int FROM public.lessons l GROUP BY l.module_id;
$$;

REVOKE ALL ON FUNCTION public.has_module_access(uuid, uuid) FROM public;
REVOKE ALL ON FUNCTION public.can_access_lesson(uuid) FROM public;
REVOKE ALL ON FUNCTION public.can_access_lesson_object(text) FROM public;
REVOKE ALL ON FUNCTION public.module_lesson_counts() FROM public;
GRANT EXECUTE ON FUNCTION public.has_module_access(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_access_lesson(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_access_lesson_object(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.module_lesson_counts() TO authenticated;

-- ---------------------------------------------------------------- lessons
DROP POLICY IF EXISTS lessons_select_device_locked ON public.lessons;
CREATE POLICY lessons_select_device_locked ON public.lessons
  FOR SELECT TO authenticated
  USING (
    public.has_role(auth.uid(), 'admin'::app_role)
    OR public.has_role(auth.uid(), 'trainer'::app_role)
    OR (public.device_ok(auth.uid()) AND public.has_module_access(auth.uid(), module_id))
  );

-- ---------------------------------------------------------------- lesson media
DROP POLICY IF EXISTS lesson_media_read ON public.lesson_media;
CREATE POLICY lesson_media_read ON public.lesson_media
  FOR SELECT TO authenticated
  USING (public.is_staff() OR public.can_access_lesson(lesson_id));

DROP POLICY IF EXISTS lesson_media_objects_read ON storage.objects;
CREATE POLICY lesson_media_objects_read ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'lesson-media' AND public.can_access_lesson_object(name));

-- ---------------------------------------------------------------- quizzes
-- Quiz titles stay readable (a locked card may show them); the QUESTIONS and
-- OPTIONS require access.
DROP POLICY IF EXISTS quiz_questions_select_authenticated ON public.quiz_questions;
CREATE POLICY quiz_questions_select_authenticated ON public.quiz_questions
  FOR SELECT TO authenticated
  USING (
    public.is_staff()
    OR EXISTS (SELECT 1 FROM public.quizzes q
               WHERE q.id = quiz_id AND public.has_module_access(auth.uid(), q.module_id))
  );

-- The public options view runs with owner rights (it must: the base table
-- with is_correct is not granted to trainees), so it filters itself.
CREATE OR REPLACE VIEW public.quiz_options_public AS
  SELECT o.id, o.question_id, o.option_text, o.option_text_ar, o."position"
  FROM public.quiz_options o
  JOIN public.quiz_questions qq ON qq.id = o.question_id
  JOIN public.quizzes q ON q.id = qq.quiz_id
  WHERE public.has_module_access(auth.uid(), q.module_id);

REVOKE ALL ON public.quiz_options_public FROM anon;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON public.quiz_options_public FROM authenticated;
GRANT SELECT ON public.quiz_options_public TO authenticated;

-- Grader: refuse locked modules (otherwise a crafted RPC call could still
-- earn a pass and a certificate).
CREATE OR REPLACE FUNCTION public.submit_quiz_attempt(_quiz_id uuid, _answers jsonb)
 RETURNS TABLE(attempt_id uuid, score integer, total integer, percent integer, passed boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  _user_id uuid := auth.uid();
  _pass_percent integer;
  _tier public.quiz_tier;
  _module_id uuid;
  _attempt_id uuid;
  _total integer := 0;
  _correct integer := 0;
  _answer jsonb;
  _is_correct boolean;
BEGIN
  IF _user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT pass_percent, tier, module_id INTO _pass_percent, _tier, _module_id
  FROM public.quizzes WHERE id = _quiz_id;

  IF _pass_percent IS NULL THEN
    RAISE EXCEPTION 'Quiz not found';
  END IF;

  IF NOT public.has_module_access(_user_id, _module_id) THEN
    RAISE EXCEPTION 'Module locked';
  END IF;

  INSERT INTO public.quiz_attempts (user_id, quiz_id, started_at)
  VALUES (_user_id, _quiz_id, now())
  RETURNING id INTO _attempt_id;

  FOR _answer IN SELECT * FROM jsonb_array_elements(_answers)
  LOOP
    _total := _total + 1;
    SELECT o.is_correct INTO _is_correct
    FROM public.quiz_options o
    JOIN public.quiz_questions qq ON qq.id = o.question_id
    WHERE o.id = (_answer->>'selected_option_id')::uuid
      AND qq.quiz_id = _quiz_id;   -- an option from another quiz never scores

    _is_correct := COALESCE(_is_correct, false);
    IF _is_correct THEN
      _correct := _correct + 1;
    END IF;

    INSERT INTO public.quiz_answers (attempt_id, question_id, selected_option_id, is_correct)
    VALUES (
      _attempt_id,
      (_answer->>'question_id')::uuid,
      (_answer->>'selected_option_id')::uuid,
      _is_correct
    );
  END LOOP;

  UPDATE public.quiz_attempts
  SET score = _correct,
      total = _total,
      percent = CASE WHEN _total > 0 THEN round((_correct::numeric / _total) * 100) ELSE 0 END,
      passed = CASE WHEN _total > 0 THEN (round((_correct::numeric / _total) * 100) >= _pass_percent) ELSE false END,
      submitted_at = now()
  WHERE id = _attempt_id;

  IF (SELECT qa2.passed FROM public.quiz_attempts qa2 WHERE qa2.id = _attempt_id) THEN
    INSERT INTO public.enrollments (user_id, module_id, status, completed_at)
    VALUES (_user_id, _module_id, 'completed', now())
    ON CONFLICT (user_id, module_id)
    DO UPDATE SET status = 'completed', completed_at = now(), updated_at = now();

    IF NOT EXISTS (
      SELECT 1 FROM public.modules m
      WHERE m.published = true
        AND NOT EXISTS (
          SELECT 1
          FROM public.quiz_attempts qa
          JOIN public.quizzes q ON q.id = qa.quiz_id
          WHERE qa.user_id = _user_id
            AND q.module_id = m.id
            AND q.tier = _tier
            AND qa.passed = true
        )
    ) THEN
      INSERT INTO public.certificates (user_id, tier, certificate_number)
      VALUES (
        _user_id,
        _tier,
        'FIN-' || upper(_tier::text) || '-' || substr(_user_id::text, 1, 8) || '-' || to_char(now(), 'YYYYMMDD')
      )
      ON CONFLICT (user_id, tier) DO NOTHING;
    END IF;
  END IF;

  RETURN QUERY
  SELECT _attempt_id, _correct, _total,
         CASE WHEN _total > 0 THEN round((_correct::numeric / _total) * 100)::integer ELSE 0 END,
         CASE WHEN _total > 0 THEN (round((_correct::numeric / _total) * 100) >= _pass_percent) ELSE false END;
END;
$function$;

-- ---------------------------------------------------------------- pricing
CREATE TABLE IF NOT EXISTS public.course_packages (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code            text NOT NULL UNIQUE,
  name            text NOT NULL,
  name_ar         text NOT NULL,
  description     text NOT NULL DEFAULT '',
  description_ar  text NOT NULL DEFAULT '',
  price_egp       integer NOT NULL CHECK (price_egp >= 0),
  scope           text NOT NULL CHECK (scope IN ('track', 'all')),
  instructor_led  boolean NOT NULL DEFAULT false,
  includes_labs   boolean NOT NULL DEFAULT false,
  active          boolean NOT NULL DEFAULT true,
  position        integer NOT NULL DEFAULT 0,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.course_packages ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.course_packages TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.course_packages TO authenticated;

DROP POLICY IF EXISTS course_packages_read ON public.course_packages;
CREATE POLICY course_packages_read ON public.course_packages
  FOR SELECT TO anon, authenticated
  USING (active OR public.has_role(auth.uid(), 'admin'::app_role));
DROP POLICY IF EXISTS course_packages_admin ON public.course_packages;
CREATE POLICY course_packages_admin ON public.course_packages
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (public.has_role(auth.uid(), 'admin'::app_role));

-- Single-row settings: where trainees send the InstaPay transfer.
CREATE TABLE IF NOT EXISTS public.payment_settings (
  id                  integer PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  instapay_address    text NOT NULL DEFAULT '',
  instapay_phone      text NOT NULL DEFAULT '',
  account_name        text NOT NULL DEFAULT '',
  instructions        text NOT NULL DEFAULT '',
  instructions_ar     text NOT NULL DEFAULT '',
  whatsapp            text NOT NULL DEFAULT '',
  updated_at          timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.payment_settings ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.payment_settings TO anon, authenticated;
GRANT INSERT, UPDATE ON public.payment_settings TO authenticated;
DROP POLICY IF EXISTS payment_settings_read ON public.payment_settings;
CREATE POLICY payment_settings_read ON public.payment_settings
  FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS payment_settings_admin ON public.payment_settings;
CREATE POLICY payment_settings_admin ON public.payment_settings
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (public.has_role(auth.uid(), 'admin'::app_role));
INSERT INTO public.payment_settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------- requests
CREATE TABLE IF NOT EXISTS public.access_requests (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          timestamptz NOT NULL DEFAULT now(),
  user_id             uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  full_name           text NOT NULL,
  phone               text NOT NULL,
  email               text NOT NULL,
  package_id          uuid NOT NULL REFERENCES public.course_packages(id),
  track_id            text REFERENCES public.tracks(id),
  amount_egp          integer NOT NULL,
  instapay_reference  text NOT NULL,
  sender_name         text NOT NULL DEFAULT '',
  proof_path          text,
  customer_note       text NOT NULL DEFAULT '',
  status              text NOT NULL DEFAULT 'pending'
                      CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_note          text NOT NULL DEFAULT '',
  reviewed_by         uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  reviewed_at         timestamptz,
  granted_user_id     uuid REFERENCES auth.users(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS access_requests_status_idx ON public.access_requests (status, created_at DESC);
-- The same InstaPay transaction cannot be submitted twice.
CREATE UNIQUE INDEX IF NOT EXISTS access_requests_reference_uniq
  ON public.access_requests (lower(instapay_reference)) WHERE status <> 'rejected';

ALTER TABLE public.access_requests ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.access_requests FROM anon;
GRANT SELECT ON public.access_requests TO authenticated;
-- Inserts and reviews happen only in server functions (service role).

DROP POLICY IF EXISTS access_requests_select ON public.access_requests;
CREATE POLICY access_requests_select ON public.access_requests
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'::app_role));

ALTER TABLE public.module_access
  DROP CONSTRAINT IF EXISTS module_access_request_fk;
ALTER TABLE public.module_access
  ADD CONSTRAINT module_access_request_fk
  FOREIGN KEY (request_id) REFERENCES public.access_requests(id) ON DELETE SET NULL;

-- Private bucket for transfer screenshots. Only admins can read; uploads are
-- done by the server function with the service key.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('payment-proofs', 'payment-proofs', false, 5242880,
        ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS payment_proofs_admin_read ON storage.objects;
CREATE POLICY payment_proofs_admin_read ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'payment-proofs' AND public.has_role(auth.uid(), 'admin'::app_role));

-- ---------------------------------------------------------------- seed
INSERT INTO public.course_packages
  (code, name, name_ar, description, description_ar, price_egp, scope, instructor_led, includes_labs, position)
VALUES
  ('track-self',  'Single track — self-paced', 'مسار واحد — ذاتي',
   'One track on the platform, all quizzes and the track certificate.',
   'مسار واحد على المنصة مع كل الاختبارات وشهادة المسار.', 1900, 'track', false, false, 1),
  ('track-led',   'Single track — with instructor', 'مسار واحد — مع مدرب',
   'One track plus 4 instructor-led sessions and a supervised exam.',
   'مسار واحد مع 4 محاضرات مع المدرب واختبار بإشراف.', 3500, 'track', true, false, 2),
  ('full-self',   'Full programme — self-paced', 'البرنامج الكامل — ذاتي',
   'All three tracks on the platform.',
   'المسارات الثلاثة كاملة على المنصة.', 4500, 'all', false, false, 3),
  ('full-led',    'Full programme — with instructor', 'البرنامج الكامل — مع مدرب',
   'All three tracks, 12 instructor-led sessions, three certificates.',
   'المسارات الثلاثة مع 12 محاضرة مع المدرب و3 شهادات.', 8500, 'all', true, false, 4),
  ('full-labs',   'Full programme + labs', 'البرنامج الكامل + المعامل',
   'Everything in the instructor-led programme plus three hands-on lab days.',
   'كل حاجة في البرنامج مع المدرب، مع 3 أيام معمل عملي.', 11900, 'all', true, true, 5)
ON CONFLICT (code) DO NOTHING;

-- Existing trainees keep what they had: grant them everything so nobody
-- loses access on deploy. New trainees start fully locked.
INSERT INTO public.module_access (user_id, module_id, source)
SELECT ur.user_id, m.id, 'migration'
FROM public.user_roles ur
CROSS JOIN public.modules m
WHERE ur.role = 'trainee'
ON CONFLICT (user_id, module_id) DO NOTHING;
