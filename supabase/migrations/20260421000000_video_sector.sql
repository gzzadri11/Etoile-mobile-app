-- Add sector column to videos table for per-offer filtering
ALTER TABLE videos ADD COLUMN IF NOT EXISTS sector TEXT;

-- Index on active videos by sector for feed filtering
CREATE INDEX IF NOT EXISTS idx_videos_sector_active
  ON videos (sector)
  WHERE status = 'active' AND sector IS NOT NULL;
