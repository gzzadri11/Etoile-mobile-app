-- ============================================================================
-- Migration: Ajout compétences chercheur + keywords offres + scoring compétences
-- Date: 2026-05-03
-- Contexte: Task #5 - Section compétences profil chercheur
-- ============================================================================

-- ============================================================================
-- 1. Ajouter colonne skills à seeker_profiles
-- ============================================================================

ALTER TABLE seeker_profiles
ADD COLUMN skills TEXT[] DEFAULT '{}';

COMMENT ON COLUMN seeker_profiles.skills IS 'Compétences techniques libres saisies par le chercheur (ex: Adobe Photoshop, Excel, Gestion de projet)';

CREATE INDEX idx_seeker_skills ON seeker_profiles USING GIN(skills);

-- ============================================================================
-- 2. Ajouter colonne keywords à videos (offres)
-- ============================================================================

ALTER TABLE videos
ADD COLUMN keywords TEXT[] DEFAULT '{}';

COMMENT ON COLUMN videos.keywords IS 'Mots-clés compétences recherchées pour cette offre (optionnel) - utilisé pour scoring compétences';

CREATE INDEX idx_videos_keywords ON videos USING GIN(keywords);

-- ============================================================================
-- 3. Modifier fonction calculate_match_score pour intégrer compétences (20%)
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
  v_seeker_skills TEXT[];
  v_offer_sector VARCHAR;
  v_offer_keywords TEXT[];
  v_recruiter_locations TEXT[];
  v_study_score INTEGER := 0;
  v_skills_score NUMERIC := 0;
  v_location_match BOOLEAN := FALSE;
  v_loc TEXT;
  v_skill TEXT;
  v_keyword TEXT;
  v_match_count INTEGER := 0;
BEGIN
  -- Fetch seeker profile data
  SELECT domain, city, study_level, specialty, skills
  INTO v_seeker_domain, v_seeker_city, v_seeker_study_level, v_seeker_specialty, v_seeker_skills
  FROM seeker_profiles
  WHERE user_id = p_seeker_id;

  -- Fetch video + recruiter data
  SELECT v.sector, v.keywords, rp.locations
  INTO v_offer_sector, v_offer_keywords, v_recruiter_locations
  FROM videos v
  INNER JOIN recruiter_profiles rp ON rp.user_id = v.user_id
  WHERE v.id = p_video_id;

  -- Return 0 if data missing
  IF v_seeker_domain IS NULL OR v_offer_sector IS NULL THEN
    RETURN 0;
  END IF;

  -- ============================================================================
  -- SCORING ALGORITHM (mis à jour avec compétences 20%)
  -- Total: Secteur(25%) + Ville(20%) + Études(20%) + Spécialité(15%) + Compétences(20%)
  -- ============================================================================

  -- 1. Sector match (25%)
  IF v_seeker_domain = v_offer_sector THEN
    v_score := v_score + 25;
  END IF;

  -- 2. Study level (20%) - Buckets simples
  IF v_seeker_study_level IS NOT NULL THEN
    CASE v_seeker_study_level
      WHEN 'bac+2', 'bac+3', 'bac+4', 'bac+5', 'bac+8' THEN
        v_study_score := 20;
      WHEN 'bac', 'bac+1' THEN
        v_study_score := 12;
      WHEN 'cap_bep', 'sans_diplome' THEN
        v_study_score := 4;
      ELSE
        v_study_score := 0;
    END CASE;
    v_score := v_score + v_study_score;
  END IF;

  -- 3. Location match (20%) - Fuzzy matching simple
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
      v_score := v_score + 20;
    END IF;
  END IF;

  -- 4. Specialty (15%) - MVP: points si rempli
  IF v_seeker_specialty IS NOT NULL THEN
    v_score := v_score + 15;
  END IF;

  -- 5. Skills matching (20%) - NOUVEAU
  IF v_offer_keywords IS NOT NULL AND array_length(v_offer_keywords, 1) > 0 THEN
    IF v_seeker_skills IS NOT NULL AND array_length(v_seeker_skills, 1) > 0 THEN
      -- Compter le nombre de skills du chercheur qui matchent un keyword de l'offre
      FOREACH v_skill IN ARRAY v_seeker_skills
      LOOP
        FOREACH v_keyword IN ARRAY v_offer_keywords
        LOOP
          -- Match si le skill contient le keyword ou inversement (case insensitive)
          IF LOWER(v_skill) LIKE '%' || LOWER(v_keyword) || '%'
             OR LOWER(v_keyword) LIKE '%' || LOWER(v_skill) || '%'
          THEN
            v_match_count := v_match_count + 1;
            EXIT; -- Éviter de compter le même skill plusieurs fois
          END IF;
        END LOOP;
      END LOOP;

      -- Score = (matches / keywords_count) * 20, plafonné à 20
      v_skills_score := LEAST(20, (v_match_count::NUMERIC / array_length(v_offer_keywords, 1)::NUMERIC) * 20);
      v_score := v_score + v_skills_score::INTEGER;
    ELSE
      -- Chercheur n'a pas de skills renseignées → score neutre 0 (pas de points)
      v_score := v_score + 0;
    END IF;
  ELSE
    -- Offre n'a pas de keywords → score neutre 10 (50% de 20)
    v_score := v_score + 10;
  END IF;

  -- Clamp score 0-100
  v_score := LEAST(100, GREATEST(0, v_score));

  RETURN v_score;
END;
$$;

COMMENT ON FUNCTION calculate_match_score IS 'Calcule score matching 0-100 : secteur(25%) + ville(20%) + études(20%) + spécialité(15%) + compétences(20%)';

-- ============================================================================
-- 4. Mettre à jour le trigger pour inclure skills
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
     OR (OLD.skills IS DISTINCT FROM NEW.skills)  -- NOUVEAU
  THEN
    -- Stratégie DELETE lazy: supprimer tous les scores du chercheur
    -- Recalcul à la demande quand grille candidats charge
    DELETE FROM match_scores WHERE seeker_id = NEW.user_id;
  END IF;

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION trigger_update_match_scores IS 'Invalide cache scores quand profil chercheur change (inclut skills)';
