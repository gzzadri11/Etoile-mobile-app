-- ============================================================================
-- Script de vérification - Migrations 2026-05-03
-- ============================================================================
-- À exécuter dans Supabase Dashboard > SQL Editor APRÈS déploiement
-- ============================================================================

-- 1. Vérifier colonnes seeker_profiles (rhythm + skills)
SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'seeker_profiles'
  AND column_name IN ('rhythm', 'skills')
ORDER BY column_name;

-- Résultat attendu : 2 lignes
-- rhythm  | character varying | YES
-- skills  | ARRAY             | YES

-- ============================================================================

-- 2. Vérifier table candidate_evaluations existe
SELECT
  table_name,
  table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'candidate_evaluations';

-- Résultat attendu : 1 ligne
-- candidate_evaluations | BASE TABLE

-- ============================================================================

-- 3. Vérifier colonne keywords sur videos
SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'videos'
  AND column_name = 'keywords';

-- Résultat attendu : 1 ligne
-- keywords | ARRAY | YES

-- ============================================================================

-- 4. Vérifier fonction calculate_match_score a été mise à jour
SELECT
  routine_name,
  routine_definition LIKE '%v_seeker_skills%' AS has_skills_logic
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'calculate_match_score';

-- Résultat attendu : 1 ligne avec has_skills_logic = true

-- ============================================================================

-- RÉSUMÉ ATTENDU :
-- ✅ 2 colonnes dans seeker_profiles (rhythm, skills)
-- ✅ 1 table candidate_evaluations
-- ✅ 1 colonne keywords dans videos
-- ✅ 1 fonction calculate_match_score avec logique skills

-- Si TOUTES les vérifications passent → Migrations OK, passer aux tests Flutter/SaaS
-- Si UNE vérification échoue → Relancer DEPLOY-MIGRATIONS-2026-05-03.sql
