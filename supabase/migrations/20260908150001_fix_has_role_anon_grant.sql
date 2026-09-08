-- Fix: anon reads on `modules` failed because has_role() requires EXECUTE,
-- previously granted only to authenticated. Postgres checks function permissions
-- for ALL roles evaluating an RLS predicate, even ones that would short-circuit
-- via OR, so anon SELECTs on `modules` errored with "permission denied for
-- function has_role" instead of just seeing published rows.
GRANT EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) TO anon;
