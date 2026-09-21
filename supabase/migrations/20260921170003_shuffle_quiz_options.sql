-- Randomise option order across the entire quiz bank.
--
-- Two position biases existed: the 29 repaired seed questions all had their
-- correct answer at position 1, and the newly authored questions were written
-- with a hand-varied but not random distribution. A trainee who notices a
-- positional pattern can score without knowing the material.
--
-- This reassigns positions 1-4 randomly within every question. It is safe to
-- re-run; correctness lives on the is_correct flag, not on position.

WITH shuffled AS (
  SELECT id,
         row_number() OVER (PARTITION BY question_id ORDER BY random()) AS new_pos
  FROM public.quiz_options
)
UPDATE public.quiz_options qo
SET position = s.new_pos
FROM shuffled s
WHERE qo.id = s.id;

-- Report the resulting distribution of the correct answer across positions.
SELECT position AS correct_answer_position, count(*) AS questions
FROM public.quiz_options
WHERE is_correct
GROUP BY position
ORDER BY position;
