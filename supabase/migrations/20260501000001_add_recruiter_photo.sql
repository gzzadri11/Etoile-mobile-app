-- Epic 10 Phase 2: Photo de profil recruteur
-- Story 10.6: Photo de profil recruteur
-- Date: 2026-05-01

-- Add photo_url column to recruiter_profiles
ALTER TABLE recruiter_profiles
ADD COLUMN photo_url TEXT;

-- RLS Policy: Only recruiters can update their own profile
CREATE POLICY "recruiters_update_own_profile"
ON recruiter_profiles
FOR UPDATE
USING (user_id = auth.uid());
