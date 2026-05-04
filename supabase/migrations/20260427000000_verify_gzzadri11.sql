-- Migration pour vérifier le compte recruteur gzzadri11@gmail.com
-- Date: 2026-04-27

-- Mettre le statut à "verified" pour le compte gzzadri11@gmail.com
UPDATE recruiter_profiles
SET
  verification_status = 'verified',
  verified_at = NOW(),
  rejection_reason = NULL,
  updated_at = NOW()
WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'gzzadri11@gmail.com'
)
AND verification_status != 'verified';

-- Commentaire pour la migration
COMMENT ON TABLE recruiter_profiles IS 'Table des profils recruteurs - gzzadri11@gmail.com vérifié le 2026-04-27';
