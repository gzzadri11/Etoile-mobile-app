-- Migration: Epic 13 - PostgreSQL Functions pour KPIs recruteur
-- Decision 4: PostgreSQL Functions (stored procedures)
-- US-13.3: KPIs recruteur (temps moyen réponse, taux shortlist, comparaison offres)

-- ============================================================================
-- Fonction 1: Temps moyen de réponse aux candidats (en heures)
-- ============================================================================
CREATE OR REPLACE FUNCTION calculate_avg_response_time(recruiter_id UUID)
RETURNS NUMERIC AS $$
  SELECT COALESCE(
    AVG(
      EXTRACT(EPOCH FROM (m.created_at - a.applied_at)) / 3600
    ),
    0
  )::NUMERIC(10,2) AS avg_hours
  FROM applications a
  INNER JOIN conversations c ON (
    c.video_id = a.video_id
    AND (
      (c.participant_1 = a.seeker_id AND c.participant_2 = $1)
      OR (c.participant_2 = a.seeker_id AND c.participant_1 = $1)
    )
  )
  INNER JOIN LATERAL (
    -- Premier message du recruteur dans la conversation
    SELECT created_at
    FROM messages
    WHERE conversation_id = c.id
      AND sender_id = $1
    ORDER BY created_at ASC
    LIMIT 1
  ) m ON true
  WHERE a.recruiter_id = $1;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION calculate_avg_response_time(UUID) IS
'Calcule le temps moyen (en heures) entre la candidature et le premier message du recruteur. Retourne 0 si aucune réponse.';

-- ============================================================================
-- Fonction 2: Taux de shortlist (pourcentage candidatures contactées)
-- ============================================================================
CREATE OR REPLACE FUNCTION calculate_shortlist_rate(recruiter_id UUID)
RETURNS NUMERIC AS $$
  SELECT CASE
    WHEN COUNT(*) = 0 THEN 0
    ELSE (COUNT(*) FILTER (WHERE status = 'contacted')::NUMERIC / COUNT(*) * 100)::NUMERIC(5,2)
  END AS shortlist_rate_percent
  FROM applications
  WHERE recruiter_id = $1;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION calculate_shortlist_rate(UUID) IS
'Calcule le pourcentage de candidatures ayant été contactées (status = contacted). Retourne 0-100.';

-- ============================================================================
-- Fonction 3: Top offres performantes (nombre de candidatures par offre)
-- ============================================================================
CREATE OR REPLACE FUNCTION get_top_performing_offers(recruiter_id UUID, limit_count INT DEFAULT 5)
RETURNS TABLE(
  video_id UUID,
  title TEXT,
  applications_count BIGINT
) AS $$
  SELECT
    v.id AS video_id,
    v.title,
    COUNT(a.id)::BIGINT AS applications_count
  FROM videos v
  LEFT JOIN applications a ON a.video_id = v.id
  WHERE v.user_id = $1
    AND v.type IN ('offer', 'poster')
    AND v.status = 'active'
  GROUP BY v.id, v.title
  ORDER BY applications_count DESC
  LIMIT $2;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION get_top_performing_offers(UUID, INT) IS
'Retourne les N offres avec le plus de candidatures. Par défaut limit=5.';

-- ============================================================================
-- Permissions RLS (les fonctions héritent des RLS des tables sous-jacentes)
-- ============================================================================
-- Note: Les fonctions SQL STABLE s'exécutent avec les permissions de l'appelant.
-- RLS sur applications/conversations/messages déjà actif → filtrage automatique.
