-- Step 1: Remove the empty Gen-1 scaffold modules (M01–M10).
--
-- All 26 of their lessons are title-only shells with zero content, and every
-- topic they name is taught properly in F01–F08. They occupy positions 1–10,
-- so they are the first thing a new trainee sees — an empty course.
--
-- Their four tracks go with them; the surviving tracks are renumbered so the
-- catalogue reads in teaching order.

BEGIN;

-- Remove progress rows pointing at the doomed modules first, so nothing is
-- left orphaned if the FK is not ON DELETE CASCADE.
DELETE FROM public.enrollments
WHERE module_id IN (SELECT id FROM public.modules WHERE code IN
  ('M01','M02','M03','M04','M05','M06','M07','M08','M09','M10'));

DELETE FROM public.quiz_options
WHERE question_id IN (
  SELECT qq.id FROM public.quiz_questions qq
  JOIN public.quizzes q ON q.id = qq.quiz_id
  JOIN public.modules m ON m.id = q.module_id
  WHERE m.code IN ('M01','M02','M03','M04','M05','M06','M07','M08','M09','M10')
);

DELETE FROM public.quiz_questions
WHERE quiz_id IN (
  SELECT q.id FROM public.quizzes q
  JOIN public.modules m ON m.id = q.module_id
  WHERE m.code IN ('M01','M02','M03','M04','M05','M06','M07','M08','M09','M10')
);

DELETE FROM public.quizzes
WHERE module_id IN (SELECT id FROM public.modules WHERE code IN
  ('M01','M02','M03','M04','M05','M06','M07','M08','M09','M10'));

DELETE FROM public.lessons
WHERE module_id IN (SELECT id FROM public.modules WHERE code IN
  ('M01','M02','M03','M04','M05','M06','M07','M08','M09','M10'));

DELETE FROM public.modules
WHERE code IN ('M01','M02','M03','M04','M05','M06','M07','M08','M09','M10');

DELETE FROM public.tracks
WHERE id IN ('hardware-foundations','networking-protocols',
             'team-project-management','survey-terminology-tools');

-- Renumber the surviving tracks into teaching order.
UPDATE public.tracks SET position = 1 WHERE id = 'finix-technician-academy';
UPDATE public.tracks SET position = 2 WHERE id = 'sonoff-installer-certification';
UPDATE public.tracks SET position = 3 WHERE id = 'finix-industrial-control';

-- Renumber modules 1..N within each track so nothing starts at position 11.
WITH ordered AS (
  SELECT m.id,
         row_number() OVER (PARTITION BY m.track_id ORDER BY m.position) AS rn
  FROM public.modules m
)
UPDATE public.modules m
SET position = ordered.rn
FROM ordered
WHERE ordered.id = m.id;

COMMIT;
