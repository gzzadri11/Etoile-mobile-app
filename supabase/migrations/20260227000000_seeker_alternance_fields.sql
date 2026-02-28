-- Sprint 18: Beta pivot - add alternance fields to seeker_profiles
-- New fields: age, school, study_level, domain
-- Old fields (categories, contract_types, etc.) kept for backward compatibility

ALTER TABLE seeker_profiles
  ADD COLUMN IF NOT EXISTS age text,
  ADD COLUMN IF NOT EXISTS school text,
  ADD COLUMN IF NOT EXISTS study_level text,
  ADD COLUMN IF NOT EXISTS domain text;

-- Add comment for documentation
COMMENT ON COLUMN seeker_profiles.age IS 'Age of the seeker (beta: dropdown 16-60)';
COMMENT ON COLUMN seeker_profiles.school IS 'School name (free text)';
COMMENT ON COLUMN seeker_profiles.study_level IS 'Study level (sans_diplome, cap_bep, bac, bac+1..bac+5, bac+8)';
COMMENT ON COLUMN seeker_profiles.domain IS 'Professional domain (commerce_vente, restauration_hotellerie)';
