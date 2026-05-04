-- Epic 14: Scoring PostgreSQL + Persistance
-- Migration: Create match_scores table + calculate_match_score function + trigger
-- Date: 2026-04-25

-- ============================================================================
-- TABLE: match_scores
-- ============================================================================

CREATE TABLE match_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seeker_id UUID NOT NULL REFERENCES seeker_profiles(user_id) ON DELETE CASCADE,
  video_id UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
  score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
  computed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(seeker_id, video_id)
);

COMMENT ON TABLE match_scores IS 'Scores de matching persistés entre chercheurs et offres vidéo (Epic 14)';
COMMENT ON COLUMN match_scores.score IS 'Score 0-100: secteur(30%) + études(25%) + ville(25%) + spécialité(20%)';
COMMENT ON COLUMN match_scores.computed_at IS 'Timestamp calcul - foundation pour staleness detection Phase 2';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Index composite pour tri rapide grille candidats (ORDER BY video_id, score DESC)
CREATE INDEX idx_match_scores_by_video_score
ON match_scores(video_id, score DESC);

-- Index pour détection staleness Phase 2
CREATE INDEX idx_match_scores_computed_at
ON match_scores(computed_at);

-- ============================================================================
-- FUNCTION: calculate_match_score
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_match_score(
  p_seeker_id UUID,
  p_video_id UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_score INTEGER := 0;
  v_seeker_domain VARCHAR;
  v_seeker_city VARCHAR;
  v_seeker_study_level VARCHAR;
  v_seeker_specialty VARCHAR;
  v_offer_sector VARCHAR;
  v_recruiter_locations TEXT[];
  v_study_score INTEGER := 0;
  v_location_match BOOLEAN := FALSE;
  v_loc TEXT;
BEGIN
  -- Fetch seeker profile data
  SELECT domain, city, study_level, specialty
  INTO v_seeker_domain, v_seeker_city, v_seeker_study_level, v_seeker_specialty
  FROM seeker_profiles
  WHERE user_id = p_seeker_id;

  -- Fetch video + recruiter data
  SELECT v.sector, rp.locations
  INTO v_offer_sector, v_recruiter_locations
  FROM videos v
  INNER JOIN recruiter_profiles rp ON rp.user_id = v.user_id
  WHERE v.id = p_video_id;

  -- Return 0 if data missing
  IF v_seeker_domain IS NULL OR v_offer_sector IS NULL THEN
    RETURN 0;
  END IF;

  -- ============================================================================
  -- SCORING ALGORITHM (cohérent avec lib/scoring.ts)
  -- ============================================================================

  -- 1. Sector match (30%)
  IF v_seeker_domain = v_offer_sector THEN
    v_score := v_score + 30;
  END IF;

  -- 2. Study level (25%) - Buckets simples
  IF v_seeker_study_level IS NOT NULL THEN
    CASE v_seeker_study_level
      WHEN 'bac+2', 'bac+3', 'bac+4', 'bac+5', 'bac+8' THEN
        v_study_score := 25;
      WHEN 'bac', 'bac+1' THEN
        v_study_score := 15;
      WHEN 'cap_bep', 'sans_diplome' THEN
        v_study_score := 5;
      ELSE
        v_study_score := 0;
    END CASE;
    v_score := v_score + v_study_score;
  END IF;

  -- 3. Location match (25%) - Fuzzy matching simple
  IF v_seeker_city IS NOT NULL AND v_recruiter_locations IS NOT NULL THEN
    FOREACH v_loc IN ARRAY v_recruiter_locations
    LOOP
      -- Fuzzy match: cityLower LIKE %loc% OR loc LIKE %city% OR exact
      IF LOWER(v_seeker_city) LIKE '%' || LOWER(v_loc) || '%'
         OR LOWER(v_loc) LIKE '%' || LOWER(v_seeker_city) || '%'
         OR LOWER(v_seeker_city) = LOWER(v_loc)
      THEN
        v_location_match := TRUE;
        EXIT; -- Stop at first match
      END IF;
    END LOOP;

    IF v_location_match THEN
      v_score := v_score + 25;
    END IF;
  END IF;

  -- 4. Specialty (20%) - MVP: points si rempli
  IF v_seeker_specialty IS NOT NULL THEN
    v_score := v_score + 20;
  END IF;

  -- Clamp score 0-100
  v_score := LEAST(100, GREATEST(0, v_score));

  RETURN v_score;
END;
$$;

COMMENT ON FUNCTION calculate_match_score IS 'Calcule score matching 0-100 entre chercheur et offre vidéo (Epic 14)';

-- ============================================================================
-- TRIGGER FUNCTION: trigger_update_match_scores
-- ============================================================================

CREATE OR REPLACE FUNCTION trigger_update_match_scores()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Détecte changements sur les champs du scoring
  IF (OLD.domain IS DISTINCT FROM NEW.domain)
     OR (OLD.city IS DISTINCT FROM NEW.city)
     OR (OLD.study_level IS DISTINCT FROM NEW.study_level)
     OR (OLD.specialty IS DISTINCT FROM NEW.specialty)
  THEN
    -- Stratégie DELETE lazy: supprimer tous les scores du chercheur
    -- Recalcul à la demande quand grille candidats charge
    DELETE FROM match_scores WHERE seeker_id = NEW.user_id;
  END IF;

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION trigger_update_match_scores IS 'Invalide cache scores quand profil chercheur change (Epic 14)';

-- ============================================================================
-- TRIGGER: seeker_profile_change
-- ============================================================================

CREATE TRIGGER trigger_seeker_profile_change
AFTER UPDATE ON seeker_profiles
FOR EACH ROW
EXECUTE FUNCTION trigger_update_match_scores();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE match_scores ENABLE ROW LEVEL SECURITY;

-- Policy SELECT: Recruteur voit scores de SES offres uniquement
CREATE POLICY "Recruiters can view match scores for their offers"
ON match_scores
FOR SELECT
USING (
  video_id IN (
    SELECT id FROM videos WHERE user_id = auth.uid()
  )
);

-- Policy DELETE: Recruteur peut supprimer scores de SES offres (recalcul manuel)
CREATE POLICY "Recruiters can delete match scores for their offers"
ON match_scores
FOR DELETE
USING (
  video_id IN (
    SELECT id FROM videos WHERE user_id = auth.uid()
  )
);

-- Pas de policy INSERT/UPDATE: seules fonctions/triggers écrivent dans cette table
