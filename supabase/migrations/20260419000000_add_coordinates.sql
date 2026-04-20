-- Add latitude/longitude coordinates to recruiter and seeker profiles
-- for proximity-based filtering

ALTER TABLE recruiter_profiles
  ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

ALTER TABLE seeker_profiles
  ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

CREATE INDEX IF NOT EXISTS idx_recruiter_coords
  ON recruiter_profiles(latitude, longitude)
  WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
