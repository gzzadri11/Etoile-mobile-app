-- ============================================================================
-- Script de test - Ajout compétences à un profil chercheur
-- ============================================================================
-- À exécuter dans Supabase Dashboard > SQL Editor
-- ============================================================================

-- ÉTAPE 1: Vérifier qu'un chercheur a bien postuléSELECT
  sp.user_id,
  sp.first_name,
  sp.last_name,
  sp.username,
  sp.skills,  -- ⚠️ Si cette colonne n'existe pas = migrations non déployées
  a.id as application_id,
  a.status
FROM applications a
INNER JOIN seeker_profiles sp ON sp.user_id = a.seeker_id
WHERE a.status IN ('pending', 'contacted')
LIMIT 5;

-- Si erreur "column skills does not exist" → DÉPLOYER D'ABORD LES MIGRATIONS
-- Sinon, noter un user_id ci-dessous

-- ============================================================================

-- ÉTAPE 2: Ajouter des compétences à CE chercheur
-- Remplace 'USER_ID_ICI' par un user_id de l'étape 1

UPDATE seeker_profiles
SET skills = ARRAY['React.js', 'TypeScript', 'Figma', 'Adobe Photoshop']
WHERE user_id = 'USER_ID_ICI';  -- ⚠️ REMPLACER PAR UN VRAI UUID

-- ============================================================================

-- ÉTAPE 3: Vérifier que les compétences sont bien enregistrées

SELECT
  user_id,
  first_name,
  last_name,
  skills,
  array_length(skills, 1) as nb_skills
FROM seeker_profiles
WHERE user_id = 'USER_ID_ICI';  -- ⚠️ MÊME UUID

-- Résultat attendu: nb_skills = 4

-- ============================================================================

-- ÉTAPE 4: Tester dans le SaaS
-- 1. Lancer le SaaS: npm run dev
-- 2. Aller dans Candidats
-- 3. Cliquer sur le candidat avec cet user_id
-- 4. Onglet Profil → Section Compétences devrait afficher 4 badges
