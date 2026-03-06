-- Add specialty column to seeker_profiles for sub-sector specialization
ALTER TABLE seeker_profiles ADD COLUMN IF NOT EXISTS specialty text;
