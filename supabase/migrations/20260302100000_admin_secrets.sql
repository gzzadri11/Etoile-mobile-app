-- Table pour stocker les 2 codes secrets hashes (bcrypt)
CREATE TABLE admin_secrets (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  secret_1_hash TEXT NOT NULL,
  secret_2_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS active, AUCUNE policy = impossible de lire via l'API REST
ALTER TABLE admin_secrets ENABLE ROW LEVEL SECURITY;

-- RPC SECURITY DEFINER : s'execute avec les droits du createur (bypass RLS)
-- Verifie que l'utilisateur courant est admin + que les 2 codes sont corrects
CREATE OR REPLACE FUNCTION verify_admin_secrets(code1 TEXT, code2 TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  stored RECORD;
  is_admin BOOLEAN;
BEGIN
  -- Verifier que l'appelant est admin
  SELECT EXISTS(
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  ) INTO is_admin;

  IF NOT is_admin THEN
    RETURN FALSE;
  END IF;

  -- Recuperer les hashes
  SELECT secret_1_hash, secret_2_hash INTO stored
  FROM admin_secrets
  WHERE user_id = auth.uid();

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  -- Comparer avec bcrypt
  RETURN stored.secret_1_hash = crypt(code1, stored.secret_1_hash)
     AND stored.secret_2_hash = crypt(code2, stored.secret_2_hash);
END;
$$;
