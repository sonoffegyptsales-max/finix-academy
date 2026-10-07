-- =============================================================================
-- Trainer accounts scoped to admin-selected lessons.
--
-- BEFORE: any 'trainer' could read AND rewrite every track, module, lesson,
-- quiz, answer key and media file (all write policies were admin-OR-trainer).
-- AFTER:
--   admin   -> everything (unchanged)
--   trainer -> READ only the lessons assigned to them (+ their modules' cards
--              and quizzes, to teach them); WRITE only those lessons' text and
--              media. No creating/deleting lessons, modules, tracks; no quiz
--              or answer-key edits; no publishing.
--   trainee -> unchanged (module_access).
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.trainer_assignments (
  trainer_id  uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id   uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  assigned_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  assigned_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (trainer_id, lesson_id)
);
CREATE INDEX IF NOT EXISTS trainer_assignments_lesson_idx ON public.trainer_assignments (lesson_id);
ALTER TABLE public.trainer_assignments ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.trainer_assignments FROM anon;
GRANT SELECT ON public.trainer_assignments TO authenticated;
-- Writes only through the admin server function (service role).
DROP POLICY IF EXISTS trainer_assignments_read ON public.trainer_assignments;
CREATE POLICY trainer_assignments_read ON public.trainer_assignments
  FOR SELECT TO authenticated
  USING (trainer_id = auth.uid() OR public.has_role(auth.uid(), 'admin'::app_role));

-- ---------------------------------------------------------------- helpers
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.has_role(auth.uid(), 'admin'::app_role);
$$;

CREATE OR REPLACE FUNCTION public.trainer_has_lesson(_user uuid, _lesson uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.trainer_assignments a
                 WHERE a.trainer_id = _user AND a.lesson_id = _lesson)
     AND public.has_role(_user, 'trainer'::app_role);
$$;

CREATE OR REPLACE FUNCTION public.trainer_has_module(_user uuid, _module uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.trainer_assignments a
                 JOIN public.lessons l ON l.id = a.lesson_id
                 WHERE a.trainer_id = _user AND l.module_id = _module)
     AND public.has_role(_user, 'trainer'::app_role);
$$;

-- Module-level access: admin, a trainer with a lesson in it, or a trainee
-- with a module_access grant.
CREATE OR REPLACE FUNCTION public.has_module_access(_user uuid, _module uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.has_role(_user, 'admin'::app_role)
      OR public.trainer_has_module(_user, _module)
      OR EXISTS (SELECT 1 FROM public.module_access ma
                 WHERE ma.user_id = _user AND ma.module_id = _module AND ma.revoked_at IS NULL);
$$;

-- Lesson-level access is narrower for trainers: the lesson itself must be
-- assigned (a trainer with one lesson of a module must not see the others).
CREATE OR REPLACE FUNCTION public.can_access_lesson(_lesson uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.is_admin()
      OR public.trainer_has_lesson(auth.uid(), _lesson)
      OR EXISTS (SELECT 1 FROM public.lessons l
                 JOIN public.module_access ma ON ma.module_id = l.module_id
                 WHERE l.id = _lesson AND ma.user_id = auth.uid() AND ma.revoked_at IS NULL);
$$;

CREATE OR REPLACE FUNCTION public.can_access_lesson_object(_name text)
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
DECLARE _first text := split_part(_name, '/', 1);
BEGIN
  IF public.is_admin() THEN RETURN true; END IF;
  IF _first !~ '^[0-9a-fA-F-]{36}$' THEN RETURN false; END IF;
  RETURN public.can_access_lesson(_first::uuid);
END;
$$;

CREATE OR REPLACE FUNCTION public.can_edit_lesson_object(_name text)
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
DECLARE _first text := split_part(_name, '/', 1);
BEGIN
  IF public.is_admin() THEN RETURN true; END IF;
  IF _first !~ '^[0-9a-fA-F-]{36}$' THEN RETURN false; END IF;
  RETURN public.trainer_has_lesson(auth.uid(), _first::uuid);
END;
$$;

REVOKE ALL ON FUNCTION public.is_admin() FROM public;
REVOKE ALL ON FUNCTION public.trainer_has_lesson(uuid, uuid) FROM public;
REVOKE ALL ON FUNCTION public.trainer_has_module(uuid, uuid) FROM public;
REVOKE ALL ON FUNCTION public.can_edit_lesson_object(text) FROM public;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.trainer_has_lesson(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.trainer_has_module(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_edit_lesson_object(text) TO authenticated;

-- ---------------------------------------------------------------- tracks / modules
DROP POLICY IF EXISTS tracks_staff_write ON public.tracks;
DROP POLICY IF EXISTS tracks_admin_write ON public.tracks;
CREATE POLICY tracks_admin_write ON public.tracks
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS modules_select_published ON public.modules;
CREATE POLICY modules_select_published ON public.modules
  FOR SELECT USING (
    published = true OR public.is_admin() OR public.trainer_has_module(auth.uid(), id)
  );
DROP POLICY IF EXISTS modules_staff_write ON public.modules;
DROP POLICY IF EXISTS modules_admin_write ON public.modules;
CREATE POLICY modules_admin_write ON public.modules
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------- lessons
DROP POLICY IF EXISTS lessons_select_device_locked ON public.lessons;
CREATE POLICY lessons_select_device_locked ON public.lessons
  FOR SELECT TO authenticated
  USING (
    public.is_admin()
    OR public.trainer_has_lesson(auth.uid(), id)
    OR (public.device_ok(auth.uid())
        AND EXISTS (SELECT 1 FROM public.module_access ma
                    WHERE ma.user_id = auth.uid() AND ma.module_id = lessons.module_id AND ma.revoked_at IS NULL))
  );

DROP POLICY IF EXISTS lessons_staff_write ON public.lessons;
DROP POLICY IF EXISTS lessons_admin_write ON public.lessons;
CREATE POLICY lessons_admin_write ON public.lessons
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS lessons_trainer_update ON public.lessons;
CREATE POLICY lessons_trainer_update ON public.lessons
  FOR UPDATE TO authenticated
  USING (public.trainer_has_lesson(auth.uid(), id))
  WITH CHECK (public.trainer_has_lesson(auth.uid(), id));

-- A trainer edits words, not structure: module and order stay as the admin set them.
CREATE OR REPLACE FUNCTION public.guard_trainer_lesson_update()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF auth.uid() IS NOT NULL AND NOT public.is_admin() THEN
    IF NEW.module_id IS DISTINCT FROM OLD.module_id OR NEW.position IS DISTINCT FROM OLD.position THEN
      RAISE EXCEPTION 'Trainers cannot move lessons' USING ERRCODE = 'insufficient_privilege';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS lessons_trainer_guard ON public.lessons;
CREATE TRIGGER lessons_trainer_guard BEFORE UPDATE ON public.lessons
  FOR EACH ROW EXECUTE FUNCTION public.guard_trainer_lesson_update();

-- ---------------------------------------------------------------- lesson media
DROP POLICY IF EXISTS lesson_media_read ON public.lesson_media;
CREATE POLICY lesson_media_read ON public.lesson_media
  FOR SELECT TO authenticated USING (public.can_access_lesson(lesson_id));

DROP POLICY IF EXISTS lesson_media_staff_write ON public.lesson_media;
DROP POLICY IF EXISTS lesson_media_write ON public.lesson_media;
CREATE POLICY lesson_media_write ON public.lesson_media
  FOR ALL TO authenticated
  USING (public.is_admin() OR public.trainer_has_lesson(auth.uid(), lesson_id))
  WITH CHECK (public.is_admin() OR public.trainer_has_lesson(auth.uid(), lesson_id));

DROP POLICY IF EXISTS lesson_media_objects_staff ON storage.objects;
DROP POLICY IF EXISTS lesson_media_objects_write ON storage.objects;
CREATE POLICY lesson_media_objects_write ON storage.objects
  FOR ALL TO authenticated
  USING (bucket_id = 'lesson-media' AND public.can_edit_lesson_object(name))
  WITH CHECK (bucket_id = 'lesson-media' AND public.can_edit_lesson_object(name));

-- ---------------------------------------------------------------- quizzes
DROP POLICY IF EXISTS quizzes_staff_write ON public.quizzes;
DROP POLICY IF EXISTS quizzes_admin_write ON public.quizzes;
CREATE POLICY quizzes_admin_write ON public.quizzes
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS quiz_questions_select_authenticated ON public.quiz_questions;
CREATE POLICY quiz_questions_select_authenticated ON public.quiz_questions
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.quizzes q
                 WHERE q.id = quiz_id AND public.has_module_access(auth.uid(), q.module_id)));
DROP POLICY IF EXISTS quiz_questions_staff_write ON public.quiz_questions;
DROP POLICY IF EXISTS quiz_questions_admin_write ON public.quiz_questions;
CREATE POLICY quiz_questions_admin_write ON public.quiz_questions
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Answer keys: admin everything; a trainer may READ the keys of modules they
-- teach (to explain answers). Trainees never touch this table.
DROP POLICY IF EXISTS quiz_options_staff_all ON public.quiz_options;
DROP POLICY IF EXISTS quiz_options_admin_all ON public.quiz_options;
CREATE POLICY quiz_options_admin_all ON public.quiz_options
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
DROP POLICY IF EXISTS quiz_options_trainer_read ON public.quiz_options;
CREATE POLICY quiz_options_trainer_read ON public.quiz_options
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.quiz_questions qq
                 JOIN public.quizzes q ON q.id = qq.quiz_id
                 WHERE qq.id = question_id AND public.trainer_has_module(auth.uid(), q.module_id)));
