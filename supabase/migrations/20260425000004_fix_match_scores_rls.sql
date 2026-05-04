-- Epic 14: Fix RLS policies for match_scores table
-- Migration: Add INSERT policy to allow recruiters to store scores via Server Action
-- Date: 2026-04-25

-- ============================================================================
-- FIX: RLS Policy INSERT
-- ============================================================================

-- Allow recruiters to insert match scores for their own offers
-- Needed for calculateAndStoreMatchScore() Server Action
CREATE POLICY "Recruiters can insert match scores for their offers"
ON match_scores
FOR INSERT
WITH CHECK (
  video_id IN (
    SELECT id FROM videos WHERE user_id = auth.uid()
  )
);

-- ============================================================================
-- FIX: RLS Policy UPDATE
-- ============================================================================

-- Allow recruiters to update match scores for their own offers
-- Needed for upsert pattern in calculateAndStoreMatchScore()
CREATE POLICY "Recruiters can update match scores for their offers"
ON match_scores
FOR UPDATE
USING (
  video_id IN (
    SELECT id FROM videos WHERE user_id = auth.uid()
  )
)
WITH CHECK (
  video_id IN (
    SELECT id FROM videos WHERE user_id = auth.uid()
  )
);

COMMENT ON POLICY "Recruiters can insert match scores for their offers" ON match_scores
IS 'Permet calcul à la demande via Server Action calculateAndStoreMatchScore()';

COMMENT ON POLICY "Recruiters can update match scores for their offers" ON match_scores
IS 'Permet upsert pattern (ON CONFLICT DO UPDATE) dans Server Action';
