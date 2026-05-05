-- Add address column to videos table (for offer location)
ALTER TABLE videos ADD COLUMN address TEXT;

COMMENT ON COLUMN videos.address IS 'Adresse complète du lieu de l''alternance (rue, code postal, ville)';
