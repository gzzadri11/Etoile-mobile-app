-- Add address column to recruiter_profiles
-- Address complète de l'entreprise (remplace locations qui n'était pas pertinent)

ALTER TABLE recruiter_profiles
ADD COLUMN address TEXT;

COMMENT ON COLUMN recruiter_profiles.address IS 'Adresse complète de l''entreprise (rue, ville, code postal)';
