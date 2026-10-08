-- =============================================================================
-- 1. Certificates are earned PER TRACK and level.
--    Before: a tier certificate required passing that tier in ALL published
--    modules of ALL tracks, so a student who bought one track could never be
--    certified. Now: pass the tier in every published module of ONE track.
--    (No certificates existed when this ran, so no backfill is needed.)
-- 2. Module order within tracks (positions only; codes/slugs unchanged).
-- =============================================================================

ALTER TABLE public.certificates ADD COLUMN IF NOT EXISTS track_id text REFERENCES public.tracks(id);
ALTER TABLE public.certificates DROP CONSTRAINT IF EXISTS certificates_user_id_tier_key;
ALTER TABLE public.certificates DROP CONSTRAINT IF EXISTS certificates_user_track_tier_key;
ALTER TABLE public.certificates
  ADD CONSTRAINT certificates_user_track_tier_key UNIQUE (user_id, track_id, tier);

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
  _track_id text;
  _track_pos integer;
  _attempt_id uuid;
  _total integer := 0;
  _correct integer := 0;
  _answer jsonb;
  _is_correct boolean;
BEGIN
  IF _user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT q.pass_percent, q.tier, q.module_id INTO _pass_percent, _tier, _module_id
  FROM public.quizzes q WHERE q.id = _quiz_id;

  IF _pass_percent IS NULL THEN
    RAISE EXCEPTION 'Quiz not found';
  END IF;

  IF NOT public.has_module_access(_user_id, _module_id) THEN
    RAISE EXCEPTION 'Module locked';
  END IF;

  SELECT m.track_id, t.position INTO _track_id, _track_pos
  FROM public.modules m JOIN public.tracks t ON t.id = m.track_id
  WHERE m.id = _module_id;

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
      AND qq.quiz_id = _quiz_id;

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

    -- Certificate for THIS track and level: every published module of the
    -- track must have a passed attempt at this tier.
    IF NOT EXISTS (
      SELECT 1 FROM public.modules m
      WHERE m.published = true
        AND m.track_id = _track_id
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
      INSERT INTO public.certificates (user_id, tier, track_id, certificate_number)
      VALUES (
        _user_id,
        _tier,
        _track_id,
        'FIN-T' || _track_pos || '-' || upper(_tier::text) || '-' || substr(_user_id::text, 1, 8) || '-' || to_char(now(), 'YYYYMMDD')
      )
      ON CONFLICT (user_id, track_id, tier) DO NOTHING;
    END IF;
  END IF;

  RETURN QUERY
  SELECT _attempt_id, _correct, _total,
         CASE WHEN _total > 0 THEN round((_correct::numeric / _total) * 100)::integer ELSE 0 END,
         CASE WHEN _total > 0 THEN (round((_correct::numeric / _total) * 100) >= _pass_percent) ELSE false END;
END;
$function$;

-- ---------------------------------------------------------------- order
-- Track 1: terminology first (the rest of the track uses it).
-- Track 2: device wiring before installation practice; hardening before
--          large-deployment troubleshooting.
UPDATE public.modules SET position = v.pos
FROM (VALUES
  ('F08', 1), ('F01', 2), ('F02', 3), ('F03', 4), ('F04', 5), ('F05', 6), ('F06', 7), ('F07', 8),
  ('M11', 1), ('M14', 2), ('M12', 3), ('M13', 4), ('M16', 5), ('M15', 6), ('M17', 7)
) AS v(code, pos)
WHERE modules.code = v.code;
