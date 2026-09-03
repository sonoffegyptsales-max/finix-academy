CREATE TABLE public.session_videos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id integer NOT NULL,
  title text NOT NULL,
  description text,
  url text NOT NULL,
  source text NOT NULL DEFAULT 'custom',
  position integer NOT NULL DEFAULT 0,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.session_videos TO authenticated;
GRANT ALL ON public.session_videos TO service_role;

ALTER TABLE public.session_videos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "session_videos_select" ON public.session_videos
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "session_videos_admin_write" ON public.session_videos
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (public.has_role(auth.uid(), 'admin'::app_role));

CREATE INDEX session_videos_session_idx ON public.session_videos (session_id, position);