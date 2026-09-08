-- Fix: several tables have RLS policies granting staff (admin/trainer) full
-- write access via "FOR ALL ... USING (has_role(...))", but the base table
-- GRANT only covered SELECT. Postgres checks table-level privileges before
-- RLS policies are ever evaluated, so every INSERT/UPDATE/DELETE from staff
-- was failing with "permission denied for table X" regardless of role.
-- RLS policies remain the actual authorization gate; these grants just let
-- authenticated users reach that gate at all.
GRANT INSERT, UPDATE, DELETE ON public.tracks TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.modules TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.lessons TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.quizzes TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.quiz_questions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.quiz_options TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.certificates TO authenticated;
