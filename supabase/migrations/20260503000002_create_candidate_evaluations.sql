-- Migration: Table d'évaluation des candidats par les recruteurs
-- Date: 2026-05-03
-- Description: Système 3 états (interested, neutral, not_interested) + notes privées

CREATE TABLE IF NOT EXISTS candidate_evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recruiter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
  rating TEXT CHECK (rating IN ('interested', 'neutral', 'not_interested')),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(recruiter_id, application_id)
);

COMMENT ON TABLE candidate_evaluations IS 'Évaluations privées des candidats par les recruteurs (système 3 états)';
COMMENT ON COLUMN candidate_evaluations.rating IS 'interested = vert, neutral = orange, not_interested = rouge';
COMMENT ON COLUMN candidate_evaluations.notes IS 'Notes privées du recruteur sur le candidat';

-- Index pour performances
CREATE INDEX IF NOT EXISTS idx_candidate_evaluations_recruiter ON candidate_evaluations(recruiter_id);
CREATE INDEX IF NOT EXISTS idx_candidate_evaluations_application ON candidate_evaluations(application_id);

-- RLS
ALTER TABLE candidate_evaluations ENABLE ROW LEVEL SECURITY;

-- Policy: Le recruteur peut voir ses propres évaluations
CREATE POLICY select_own_evaluations ON candidate_evaluations
  FOR SELECT
  USING (recruiter_id = auth.uid());

-- Policy: Le recruteur peut créer ses évaluations
CREATE POLICY insert_own_evaluations ON candidate_evaluations
  FOR INSERT
  WITH CHECK (recruiter_id = auth.uid());

-- Policy: Le recruteur peut modifier ses propres évaluations
CREATE POLICY update_own_evaluations ON candidate_evaluations
  FOR UPDATE
  USING (recruiter_id = auth.uid())
  WITH CHECK (recruiter_id = auth.uid());

-- Policy: Le recruteur peut supprimer ses propres évaluations
CREATE POLICY delete_own_evaluations ON candidate_evaluations
  FOR DELETE
  USING (recruiter_id = auth.uid());
