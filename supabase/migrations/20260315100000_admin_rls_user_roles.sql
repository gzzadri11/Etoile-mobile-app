-- =============================================================================
-- Migration: Admin RLS policy for user_roles
-- Date: 2026-03-15
-- Purpose: Allow admin to read user_roles for any user (needed for
--          recruiter verification detail page to get registration date)
-- =============================================================================

-- Helper function to check admin role without triggering RLS recursion.
-- SECURITY DEFINER bypasses RLS on user_roles when checking the caller's role.
CREATE OR REPLACE FUNCTION public.is_admin()
  RETURNS boolean
  LANGUAGE sql
  SECURITY DEFINER
  STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  );
$$;

-- Admin can SELECT all user_roles (to get created_at for recruiter detail)
CREATE POLICY "Admins can read all user roles"
  ON public.user_roles
  FOR SELECT
  TO authenticated
  USING (public.is_admin());
