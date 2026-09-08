-- Fix: "passed" was ambiguous inside submit_quiz_attempt because the function's
-- own RETURNS TABLE output column is also named "passed", shadowing the
-- quiz_attempts.passed column reference in the enrollment-completion check.
CREATE OR REPLACE FUNCTION public.submit_quiz_attempt(
  _quiz_id uuid,
  _answers jsonb -- [{"question_id": "...", "selected_option_id": "..."}]
)
RETURNS TABLE (attempt_id uuid, score integer, total integer, percent integer, passed boolean)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
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

  INSERT INTO public.quiz_attempts (user_id, quiz_id, started_at)
  VALUES (_user_id, _quiz_id, now())
  RETURNING id INTO _attempt_id;

  FOR _answer IN SELECT * FROM jsonb_array_elements(_answers)
  LOOP
    _total := _total + 1;
    SELECT o.is_correct INTO _is_correct
    FROM public.quiz_options o
    WHERE o.id = (_answer->>'selected_option_id')::uuid;

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

  -- Mark enrollment complete on a pass (qualified alias avoids ambiguity with
  -- the function's own OUT parameter "passed")
  IF (SELECT qa2.passed FROM public.quiz_attempts qa2 WHERE qa2.id = _attempt_id) THEN
    INSERT INTO public.enrollments (user_id, module_id, status, completed_at)
    VALUES (_user_id, _module_id, 'completed', now())
    ON CONFLICT (user_id, module_id)
    DO UPDATE SET status = 'completed', completed_at = now(), updated_at = now();

    -- Auto-issue certificate if the user has passed this tier's quiz in every published module
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
$$;
