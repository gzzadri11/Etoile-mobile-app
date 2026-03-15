-- =============================================================================
-- Migration: Admin RLS policies for recruiter_profiles + storage DELETE
-- Date: 2026-03-15
-- Purpose: Fix admin dashboard unable to see/manage pending recruiters
-- =============================================================================

-- 1. Admin can SELECT all recruiter profiles (any verification_status)
CREATE POLICY "Admins can read all recruiter profiles"
  ON public.recruiter_profiles
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_roles.user_id = auth.uid()
        AND user_roles.role = 'admin'
    )
  );

-- 2. Admin can UPDATE recruiter profiles (approve/reject verification)
CREATE POLICY "Admins can update recruiter profiles"
  ON public.recruiter_profiles
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_roles.user_id = auth.uid()
        AND user_roles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_roles.user_id = auth.uid()
        AND user_roles.role = 'admin'
    )
  );

-- 3. Recruiters can DELETE their own verification docs (to re-upload)
CREATE POLICY "Recruiters can delete their own docs"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'verification-docs'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- 4. Admins can DELETE verification docs if needed
CREATE POLICY "Admins can delete verification docs"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'verification-docs'
    AND EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_roles.user_id = auth.uid()
        AND user_roles.role = 'admin'
    )
  );
