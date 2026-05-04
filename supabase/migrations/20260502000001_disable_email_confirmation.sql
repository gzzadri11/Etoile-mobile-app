-- Migration : Désactive la confirmation email pour les chercheurs (beta)
-- Date : 2026-05-02
--
-- Cette migration configure Supabase Auth pour auto-confirmer les utilisateurs
-- sans envoyer d'email de confirmation (mode dev/beta).

-- Note : Cette configuration se fait via le dashboard Supabase
-- Authentication → Settings → Email Auth → Disable "Enable email confirmations"
--
-- Cette migration sert de documentation. La config réelle doit être faite manuellement
-- car Supabase ne permet pas de modifier auth.config via SQL.

-- En attendant, on s'assure que tous les users existants sont confirmés
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- Commentaire pour traçabilité
COMMENT ON TABLE auth.users IS 'Email confirmation désactivée manuellement dans dashboard Supabase (2026-05-02)';
