-- Add 'trainer' role. Must be committed before use in policies (separate migration file).
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'trainer';
