-- Add map markers (multiple named locations) to recruiter_profiles
-- map_markers format: [{"name": "Siege", "lat": 48.85, "lng": 2.35}, ...]
ALTER TABLE recruiter_profiles
  ADD COLUMN latitude DOUBLE PRECISION,
  ADD COLUMN longitude DOUBLE PRECISION,
  ADD COLUMN map_markers JSONB DEFAULT '[]'::jsonb;
