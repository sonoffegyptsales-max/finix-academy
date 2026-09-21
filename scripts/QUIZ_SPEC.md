# Quiz Authoring Spec — Finix Academy

You are writing SQL migration files that add bilingual (English/Arabic) quiz
questions to an existing Supabase database. Follow this spec exactly.

## The helper function

Every file you write MUST begin with this exact helper definition, then use it
for each question:

```sql
CREATE OR REPLACE FUNCTION pg_temp.add_q(
  p_slug text, p_tier text, p_pos int,
  p_q text, p_q_ar text,
  p_a text, p_a_ar text, p_a_ok boolean,
  p_b text, p_b_ar text, p_b_ok boolean,
  p_c text, p_c_ar text, p_c_ok boolean,
  p_d text, p_d_ar text, p_d_ok boolean
) RETURNS void LANGUAGE plpgsql AS $fn$
DECLARE v_quiz uuid; v_q uuid;
BEGIN
  SELECT qz.id INTO v_quiz
  FROM public.quizzes qz JOIN public.modules m ON m.id = qz.module_id
  WHERE m.slug = p_slug AND qz.tier = p_tier::public.quiz_tier;

  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  VALUES (v_quiz, p_q, p_q_ar, p_pos) RETURNING id INTO v_q;

  INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
  VALUES (v_q, p_a, p_a_ar, p_a_ok, 1),
         (v_q, p_b, p_b_ar, p_b_ok, 2),
         (v_q, p_c, p_c_ar, p_c_ok, 3),
         (v_q, p_d, p_d_ar, p_d_ok, 4);
END $fn$;
```

## Call format

```sql
SELECT pg_temp.add_q('<module-slug>','<tier>',<position>,
  'Question text in English?',
  'نص السؤال بالعربية؟',
  'Option A', 'الخيار أ', false,
  'Option B', 'الخيار ب', true,
  'Option C', 'الخيار ج', false,
  'Option D', 'الخيار د', false);
```

## Hard rules — violating any of these breaks the build

1. **Exactly 4 options per question. Exactly ONE has `true`.** The other three
   are `false`. Never two correct, never zero.
2. **Every string is single-quoted SQL.** Any apostrophe inside text MUST be
   doubled: `'the motor''s rating'`. This is the single most common failure —
   check every English string for apostrophes before finishing.
3. **Both languages required.** Every question and every option needs real
   Arabic. Never leave Arabic empty, never repeat the English in the Arabic
   field, never use machine-garbled text. Arabic must be natural technical
   Arabic as an Egyptian electrical technician would read it.
4. **Positions continue from the existing highest position** for that quiz.
   Each task below tells you the starting position per tier.
5. **No trailing commas**, and every statement ends with `;`.

## Tier semantics — these are different kinds of question

- **bronze = recall.** Does the trainee remember the fact? "What does a
  contactor's auxiliary contact do?"
- **silver = application.** Can they apply it to a described situation? "A motor
  trips on start but runs fine when started unloaded. Which is most likely?"
- **gold = judgement/diagnosis.** A realistic scenario with a plausible-sounding
  wrong answer. "A client reports lights dropping out every evening around
  sunset. Walk through the most probable cause." Gold questions should reward
  the systematic approach taught in the lesson, and the distractors should be
  things a careless technician would actually pick.

## Quality bar

- Distractors must be **plausible**, not filler. A question where three options
  are obviously absurd tests nothing.
- Draw questions from the ACTUAL lesson content supplied to you — do not invent
  facts that are not taught in the module.
- Do not duplicate an existing question's concept. You are given the existing
  questions; cover DIFFERENT points from the lessons.
- Vary which letter is correct. Do not make option B correct every time.

## Output

Write ONE file per task to the exact path given. Do not apply it, do not run
any database command, do not commit. Writing the file is the whole job.
Report the file path and the number of questions written.
