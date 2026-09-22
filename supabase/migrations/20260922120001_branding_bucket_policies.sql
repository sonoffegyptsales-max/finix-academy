-- Branding assets: site logo and favicon, replaceable from the admin panel.
--
-- The bucket itself is created by scripts/init_branding_bucket.py over the
-- Storage REST API (no Management token needed). This migration only adds the
-- object policies, because those require DDL.
--
-- Unlike lesson-media this bucket is PUBLIC: a logo has to render for
-- signed-out visitors on the landing page, and a favicon is fetched by the
-- browser with no auth headers at all. Nothing secret lives here.

-- Admins (not trainers) may upload, replace and delete branding.
-- Branding is site identity, so it stays with the admin role.
DROP POLICY IF EXISTS branding_objects_admin ON storage.objects;
CREATE POLICY branding_objects_admin ON storage.objects
  FOR ALL TO authenticated
  USING (
    bucket_id = 'branding'
    AND EXISTS (
      SELECT 1 FROM public.user_roles ur
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  )
  WITH CHECK (
    bucket_id = 'branding'
    AND EXISTS (
      SELECT 1 FROM public.user_roles ur
      WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
    )
  );

-- Anyone may read. The bucket is public; this makes the intent explicit and
-- keeps the favicon reachable by an unauthenticated browser request.
DROP POLICY IF EXISTS branding_objects_public_read ON storage.objects;
CREATE POLICY branding_objects_public_read ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'branding');
