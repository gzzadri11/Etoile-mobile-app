-- Migration: Epic 13 - Tracking dernière connexion recruteur
-- Decision 3: Colonne user_roles.last_login_at TIMESTAMPTZ
-- US-13.1: Briefing "nouvelles candidatures depuis dernière connexion"

-- Ajouter colonne last_login_at
ALTER TABLE user_roles
ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ DEFAULT NOW();

-- Index pour performance (WHERE role = 'recruiter')
CREATE INDEX IF NOT EXISTS idx_user_roles_last_login
ON user_roles(last_login_at)
WHERE role = 'recruiter';

-- Initialiser avec NOW() pour utilisateurs existants
UPDATE user_roles
SET last_login_at = NOW()
WHERE role = 'recruiter' AND last_login_at IS NULL;

-- Commentaire colonne
COMMENT ON COLUMN user_roles.last_login_at IS
'Timestamp dernière connexion utilisateur (mis à jour par middleware.ts). Utilisé pour briefing "nouvelles candidatures depuis dernière visite".';
