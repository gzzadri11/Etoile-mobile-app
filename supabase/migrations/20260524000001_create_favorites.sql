-- Favoris chercheur (offres/vidéos sauvegardées)
CREATE TABLE IF NOT EXISTS seeker_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seeker_id UUID NOT NULL,  -- auth.uid() du chercheur
  video_id UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(seeker_id, video_id)
);

CREATE INDEX IF NOT EXISTS idx_seeker_favorites_seeker_id ON seeker_favorites(seeker_id);
CREATE INDEX IF NOT EXISTS idx_seeker_favorites_video_id ON seeker_favorites(video_id);

ALTER TABLE seeker_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "seeker_select_own_favorites"
  ON seeker_favorites FOR SELECT
  TO authenticated
  USING (auth.uid() = seeker_id);

CREATE POLICY "seeker_insert_own_favorites"
  ON seeker_favorites FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = seeker_id);

CREATE POLICY "seeker_delete_own_favorites"
  ON seeker_favorites FOR DELETE
  TO authenticated
  USING (auth.uid() = seeker_id);

-- Favoris recruteur (chercheurs sauvegardés)
CREATE TABLE IF NOT EXISTS recruiter_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recruiter_id UUID NOT NULL,  -- auth.uid() du recruteur
  seeker_id UUID NOT NULL,     -- auth.uid() du chercheur cible
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(recruiter_id, seeker_id)
);

CREATE INDEX IF NOT EXISTS idx_recruiter_favorites_recruiter_id ON recruiter_favorites(recruiter_id);
CREATE INDEX IF NOT EXISTS idx_recruiter_favorites_seeker_id ON recruiter_favorites(seeker_id);

ALTER TABLE recruiter_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "recruiter_select_own_favorites"
  ON recruiter_favorites FOR SELECT
  TO authenticated
  USING (auth.uid() = recruiter_id);

CREATE POLICY "recruiter_insert_own_favorites"
  ON recruiter_favorites FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = recruiter_id);

CREATE POLICY "recruiter_delete_own_favorites"
  ON recruiter_favorites FOR DELETE
  TO authenticated
  USING (auth.uid() = recruiter_id);
