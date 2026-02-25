-- =============================================================================
-- PREREQUISITES SPRINT 15
-- Migration: 20260225000000_prerequisites_sprint15.sql
-- Description: Admin role + users view + verification-docs bucket + RLS
-- =============================================================================

-- 1. Create a "users" VIEW joining auth.users + user_roles
-- This gives PostgREST access to email + role + is_premium in one query.
-- Uses SECURITY DEFINER to access auth.users from the public schema.
CREATE OR REPLACE VIEW public.users AS
SELECT
  au.id,
  au.email,
  ur.role,
  ur.is_premium,
  ur.premium_until,
  ur.email_verified,
  ur.status,
  ur.created_at,
  ur.updated_at
FROM auth.users au
LEFT JOIN public.user_roles ur ON ur.user_id = au.id;

-- Grant access to the view
GRANT SELECT ON public.users TO authenticated;
GRANT SELECT ON public.users TO anon;

-- RLS is not directly supported on views, but we protect via user_roles RLS
-- and the SECURITY INVOKER default (uses caller's permissions)

-- 2. Set admin role for the project owner
UPDATE user_roles SET role = 'admin'
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'gzzadri@gmail.com');

-- 3. Ensure RLS INSERT policy exists on reports (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'reports' AND policyname = 'Users can create reports'
  ) THEN
    EXECUTE 'CREATE POLICY "Users can create reports" ON reports FOR INSERT WITH CHECK (auth.uid() = reporter_id)';
  END IF;
END $$;

-- 4. Create storage bucket verification-docs (if not exists)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'verification-docs',
  'verification-docs',
  false,
  10485760, -- 10MB max
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
)
ON CONFLICT (id) DO NOTHING;

-- 5. RLS policies for verification-docs bucket
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'objects' AND policyname = 'Users can upload verification docs'
  ) THEN
    EXECUTE $policy$
      CREATE POLICY "Users can upload verification docs" ON storage.objects
        FOR INSERT WITH CHECK (
          bucket_id = 'verification-docs' AND
          (storage.foldername(name))[1] = auth.uid()::text
        )
    $policy$;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'objects' AND policyname = 'Users can view own verification docs'
  ) THEN
    EXECUTE $policy$
      CREATE POLICY "Users can view own verification docs" ON storage.objects
        FOR SELECT USING (
          bucket_id = 'verification-docs' AND
          (storage.foldername(name))[1] = auth.uid()::text
        )
    $policy$;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'objects' AND policyname = 'Admins can view all verification docs'
  ) THEN
    EXECUTE $policy$
      CREATE POLICY "Admins can view all verification docs" ON storage.objects
        FOR SELECT USING (
          bucket_id = 'verification-docs' AND
          EXISTS (SELECT 1 FROM user_roles u WHERE u.user_id = auth.uid() AND u.role = 'admin')
        )
    $policy$;
  END IF;
END $$;
