-- ============================================================================
-- Migration: Nettoyage tables et colonnes inutilisees post-pivot
-- Date: 2026-04-13
-- Contexte: Apres le pivot deux plateformes (mobile seeker-only + SaaS web
--           recruteur), ces objets ne sont plus references dans le code.
-- ============================================================================

-- ============================================================================
-- 1. DROP TABLES (0 references dans le code Flutter)
-- ============================================================================

-- Paiements in-app supprimes (migres vers Stripe web SaaS)
DROP TABLE IF EXISTS purchases CASCADE;

-- Jamais requetee cote Flutter
DROP TABLE IF EXISTS notification_log CASCADE;

-- Plus de page admin_auth dans l'app
DROP TABLE IF EXISTS admin_secrets CASCADE;

-- Le code utilise device_tokens a la place
DROP TABLE IF EXISTS push_tokens CASCADE;

-- ============================================================================
-- 2. DROP COLUMNS seeker_profiles (champs legacy post-pivot)
-- ============================================================================

ALTER TABLE seeker_profiles
  DROP COLUMN IF EXISTS phone,
  DROP COLUMN IF EXISTS birth_date,
  DROP COLUMN IF EXISTS postal_code,
  DROP COLUMN IF EXISTS categories,
  DROP COLUMN IF EXISTS contract_types,
  DROP COLUMN IF EXISTS experience_level,
  DROP COLUMN IF EXISTS availability,
  DROP COLUMN IF EXISTS salary_expectation,
  DROP COLUMN IF EXISTS bio,
  DROP COLUMN IF EXISTS profile_complete;

-- ============================================================================
-- 3. DROP COLUMNS recruiter_profiles
-- ============================================================================

ALTER TABLE recruiter_profiles
  DROP COLUMN IF EXISTS cover_url,
  DROP COLUMN IF EXISTS website,
  DROP COLUMN IF EXISTS company_size,
  DROP COLUMN IF EXISTS latitude,
  DROP COLUMN IF EXISTS longitude,
  DROP COLUMN IF EXISTS map_markers;

-- ============================================================================
-- 4. DROP COLUMN videos
-- ============================================================================

ALTER TABLE videos
  DROP COLUMN IF EXISTS codec;
