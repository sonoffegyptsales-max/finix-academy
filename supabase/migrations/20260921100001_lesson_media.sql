-- Lesson media: images, video and audio attached to lessons by trainers.
--
-- The bucket is PRIVATE: no public URLs exist. The app mints a short-lived
-- signed URL each time media is viewed, so a copied link dies in minutes and
-- the existing device-lock + watermark protections still apply.

-- 1. Private bucket -----------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'lesson-media',
  'lesson-media',
  false,
  524288000,  -- 500 MB per file
  ARRAY[
    'image/png','image/jpeg','image/webp','image/gif','image/svg+xml',
    'video/mp4','video/webm','video/quicktime',
    'audio/mpeg','audio/mp3','audio/wav','audio/ogg','audio/mp4'
  ]
)
ON CONFLICT (id) DO UPDATE
SET file_size_limit    = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types,
    public             = false;

-- 2. Media rows ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.lesson_media (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id    uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  kind         text NOT NULL CHECK (kind IN ('image','video','audio')),
  storage_path text NOT NULL,
  caption      text,
  caption_ar   text,
  position     integer NOT NULL DEFAULT 1,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS lesson_media_lesson_idx
  ON public.lesson_media (lesson_id, position);

ALTER TABLE public.lesson_media ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.is_staff()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles ur
    WHERE ur.user_id = auth.uid() AND ur.role IN ('admin','trainer')
  );
$$;

DROP POLICY IF EXISTS lesson_media_staff_write ON public.lesson_media;
CREATE POLICY lesson_media_staff_write ON public.lesson_media
  FOR ALL TO authenticated
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

DROP POLICY IF EXISTS lesson_media_read ON public.lesson_media;
CREATE POLICY lesson_media_read ON public.lesson_media
  FOR SELECT TO authenticated
  USING (true);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.lesson_media TO authenticated;

-- 3. Storage object policies -------------------------------------------
-- Staff may upload / replace / delete.
DROP POLICY IF EXISTS lesson_media_objects_staff ON storage.objects;
CREATE POLICY lesson_media_objects_staff ON storage.objects
  FOR ALL TO authenticated
  USING (bucket_id = 'lesson-media' AND public.is_staff())
  WITH CHECK (bucket_id = 'lesson-media' AND public.is_staff());

-- Signed-in users may read, which is what lets the client mint a signed URL.
-- The bucket stays private, so this never yields a shareable public link.
DROP POLICY IF EXISTS lesson_media_objects_read ON storage.objects;
CREATE POLICY lesson_media_objects_read ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'lesson-media');
