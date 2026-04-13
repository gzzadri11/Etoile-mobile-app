-- Add unique username to seeker profiles for SaaS web identification
ALTER TABLE seeker_profiles ADD COLUMN IF NOT EXISTS username VARCHAR(10) UNIQUE;
CREATE INDEX IF NOT EXISTS idx_seeker_profiles_username ON seeker_profiles(username);
