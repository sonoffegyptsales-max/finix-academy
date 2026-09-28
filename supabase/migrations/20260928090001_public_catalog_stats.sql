-- Public catalogue counts for the landing page.
--
-- The landing page showed "10 modules / 4 tracks" from a static TS file that
-- predates the real curriculum (22 modules, 3 tracks, 83 lessons, 330 quiz
-- questions). Anonymous visitors cannot read lessons or quiz tables (RLS), so
-- the page cannot count them itself. This function returns COUNTS ONLY --
-- no titles, no bodies, no answers -- so it exposes nothing RLS protects.
CREATE OR REPLACE FUNCTION public.public_catalog_stats()
RETURNS json
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT json_build_object(
    'tracks',    (SELECT count(*) FROM public.tracks),
    'modules',   (SELECT count(*) FROM public.modules),
    'lessons',   (SELECT count(*) FROM public.lessons),
    'questions', (SELECT count(*) FROM public.quiz_questions)
  );
$$;

REVOKE ALL ON FUNCTION public.public_catalog_stats() FROM public;
GRANT EXECUTE ON FUNCTION public.public_catalog_stats() TO anon, authenticated;
