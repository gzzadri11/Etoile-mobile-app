-- Simplifier admin_secrets : 1 seul code secret (le 2e)
-- Le 1er code devient le mot de passe Supabase Auth

-- Drop ancienne RPC (signature 2 params)
DROP FUNCTION IF EXISTS verify_admin_secrets(TEXT, TEXT);

-- Simplifier la table
ALTER TABLE admin_secrets DROP COLUMN secret_1_hash;
ALTER TABLE admin_secrets RENAME COLUMN secret_2_hash TO secret_hash;

-- Nouvelle RPC avec 1 seul code
CREATE OR REPLACE FUNCTION verify_admin_secrets(code TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  stored_hash TEXT;
  is_admin BOOLEAN;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  ) INTO is_admin;

  IF NOT is_admin THEN
    RETURN FALSE;
  END IF;

  SELECT secret_hash INTO stored_hash
  FROM admin_secrets
  WHERE user_id = auth.uid();

  IF stored_hash IS NULL THEN
    RETURN FALSE;
  END IF;

  RETURN stored_hash = crypt(code, stored_hash);
END;
$$;
