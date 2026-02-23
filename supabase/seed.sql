-- =============================================================================
-- ETOILE MOBILE APP - SEED DATA
-- Description: Donnees de test reproductibles pour le developpement
-- Usage: npx --prefix supabase supabase db reset
-- =============================================================================
-- NOTE: Les categories sont deja inserees dans la migration initiale.
-- NOTE: Pour que l'auth fonctionne, creer ces users via Supabase Auth
--       (Dashboard ou API) PUIS executer ce seed. Les UUIDs ci-dessous
--       doivent correspondre aux auth.users.id crees.
-- =============================================================================

-- =============================================================================
-- USERS (3 chercheurs, 2 recruteurs, 1 admin)
-- =============================================================================
-- UUIDs deterministes pour reproductibilite
-- Format: 00000000-0000-0000-0000-00000000000X

INSERT INTO users (id, email, role, email_verified, email_verified_at, is_premium, status, last_login_at) VALUES
  -- Chercheurs
  ('00000000-0000-0000-0000-000000000001', 'alice.martin@test.fr',    'seeker',    true,  NOW() - INTERVAL '30 days', false, 'active', NOW() - INTERVAL '1 day'),
  ('00000000-0000-0000-0000-000000000002', 'lucas.durand@test.fr',    'seeker',    true,  NOW() - INTERVAL '20 days', true,  'active', NOW() - INTERVAL '2 hours'),
  ('00000000-0000-0000-0000-000000000003', 'sofia.benali@test.fr',    'seeker',    true,  NOW() - INTERVAL '10 days', false, 'active', NOW() - INTERVAL '5 days'),
  -- Recruteurs
  ('00000000-0000-0000-0000-000000000004', 'emma@gmail.com',          'recruiter', true,  NOW() - INTERVAL '25 days', false, 'active', NOW() - INTERVAL '3 hours'),
  ('00000000-0000-0000-0000-000000000005', 'contact@techvision.fr',   'recruiter', true,  NOW() - INTERVAL '15 days', true,  'active', NOW() - INTERVAL '1 day'),
  -- Admin
  ('00000000-0000-0000-0000-000000000006', 'admin@etoile-app.fr',     'admin',     true,  NOW() - INTERVAL '60 days', false, 'active', NOW())
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- SEEKER PROFILES (3 profils complets)
-- =============================================================================

INSERT INTO seeker_profiles (user_id, first_name, last_name, phone, birth_date, region, city, postal_code, categories, contract_types, experience_level, availability, bio, profile_complete) VALUES
  (
    '00000000-0000-0000-0000-000000000001',
    'Alice', 'Martin', '0612345678', '1995-03-15',
    'Ile-de-France', 'Paris', '75011',
    ARRAY['Informatique & Tech', 'Art & Design'],
    ARRAY['CDI', 'CDD'],
    'junior',
    'immediate',
    'Developpeuse frontend passionnee par le design et l''experience utilisateur. Diplome Epitech 2020.',
    true
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    'Lucas', 'Durand', '0698765432', '1990-07-22',
    'Auvergne-Rhone-Alpes', 'Lyon', '69003',
    ARRAY['Commerce & Vente', 'Marketing & Communication'],
    ARRAY['CDI'],
    'senior',
    'immediate',
    'Directeur commercial avec 8 ans d''experience dans le SaaS B2B. Trilingue FR/EN/ES.',
    true
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    'Sofia', 'Benali', '0654321987', '1998-11-03',
    'Provence-Alpes-Cote d''Azur', 'Marseille', '13001',
    ARRAY['Hotellerie & Restauration'],
    ARRAY['CDD', 'Interim'],
    'intermediate',
    'under_1_month',
    'Receptionniste experimentee, bilingue francais-arabe. Formation en management hotelier.',
    true
  )
ON CONFLICT (user_id) DO NOTHING;

-- =============================================================================
-- RECRUITER PROFILES (1 verifie avec credits, 1 pending)
-- =============================================================================

INSERT INTO recruiter_profiles (user_id, company_name, siret, siren, legal_form, description, website, sector, company_size, locations, verification_status, verified_at, verified_by, video_credits, poster_credits, latitude, longitude, map_markers) VALUES
  (
    '00000000-0000-0000-0000-000000000004',
    'UDI', '12345678901234', '123456789', 'SAS',
    'Entreprise de construction et renovation specialisee dans les batiments publics. 50 ans d''expertise en Ile-de-France.',
    'https://udi-btp.fr', 'BTP', '50-249',
    ARRAY['Paris 11e', 'Nanterre'],
    'verified', NOW() - INTERVAL '20 days', '00000000-0000-0000-0000-000000000006',
    3, 2,
    48.8566, 2.3522,
    '[{"name": "Siege Paris", "lat": 48.8566, "lng": 2.3522}, {"name": "Agence Nanterre", "lat": 48.8924, "lng": 2.2071}]'::jsonb
  ),
  (
    '00000000-0000-0000-0000-000000000005',
    'TechVision', '98765432109876', '987654321', 'SAS',
    'Startup IA specialisee en computer vision pour l''industrie. Equipe de 30 ingenieurs.',
    'https://techvision.fr', 'Informatique & Tech', '10-49',
    ARRAY['Lyon Part-Dieu'],
    'verified', NOW() - INTERVAL '10 days', '00000000-0000-0000-0000-000000000006',
    5, 3,
    45.7640, 4.8357,
    '[{"name": "Bureau Lyon", "lat": 45.7640, "lng": 4.8357}]'::jsonb
  )
ON CONFLICT (user_id) DO NOTHING;

-- =============================================================================
-- VIDEOS (2 presentations chercheur, 2 offres recruteur, 1 affiche)
-- =============================================================================
-- NOTE: video_key et thumbnail_key sont des placeholders.
--       Pour tester le streaming, remplacer par de vraies cles R2.

INSERT INTO videos (id, user_id, type, category_id, title, description, video_key, video_url, thumbnail_key, thumbnail_url, duration_seconds, file_size_bytes, resolution, status, views_count, unique_viewers, published_at, contract_type) VALUES
  -- Alice: presentation en Informatique & Tech
  (
    '10000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'presentation',
    (SELECT id FROM categories WHERE slug = 'informatique-tech'),
    NULL, NULL,
    'videos/alice-presentation-tech.mp4',
    'https://etoile-video-worker.gzzadri11.workers.dev/stream/videos/alice-presentation-tech.mp4',
    'thumbnails/alice-presentation-tech.jpg',
    'https://etoile-video-worker.gzzadri11.workers.dev/stream/thumbnails/alice-presentation-tech.jpg',
    40, 8500000, '720p',
    'active', 47, 32,
    NOW() - INTERVAL '28 days',
    NULL
  ),
  -- Lucas: presentation en Commerce & Vente
  (
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000002',
    'presentation',
    (SELECT id FROM categories WHERE slug = 'commerce-vente'),
    NULL, NULL,
    'videos/lucas-presentation-commerce.mp4',
    'https://etoile-video-worker.gzzadri11.workers.dev/stream/videos/lucas-presentation-commerce.mp4',
    'thumbnails/lucas-presentation-commerce.jpg',
    'https://etoile-video-worker.gzzadri11.workers.dev/stream/thumbnails/lucas-presentation-commerce.jpg',
    40, 9200000, '720p',
    'active', 125, 89,
    NOW() - INTERVAL '18 days',
    NULL
  ),
  -- UDI (emma): offre video BTP — Chef de chantier CDI
  (
    '10000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000004',
    'offer',
    (SELECT id FROM categories WHERE slug = 'btp-construction'),
    'Chef de chantier — CDI Paris',
    'Nous recherchons un chef de chantier experimente pour nos projets de renovation en Ile-de-France.',
    'videos/udi-chef-chantier.mp4',
    'https://etoile-video-worker.gzzadri11.workers.dev/stream/videos/udi-chef-chantier.mp4',
    'thumbnails/udi-chef-chantier.jpg',
    'https://etoile-video-worker.gzzadri11.workers.dev/stream/thumbnails/udi-chef-chantier.jpg',
    38, 7800000, '720p',
    'active', 63, 41,
    NOW() - INTERVAL '15 days',
    'CDI'
  ),
  -- TechVision: offre video IT — Dev Python Senior
  (
    '10000000-0000-0000-0000-000000000004',
    '00000000-0000-0000-0000-000000000005',
    'offer',
    (SELECT id FROM categories WHERE slug = 'informatique-tech'),
    'Developpeur Python Senior — CDI Lyon',
    'Rejoignez notre equipe IA pour developper des solutions de computer vision.',
    'videos/techvision-dev-python.mp4',
    'https://etoile-video-worker.gzzadri11.workers.dev/stream/videos/techvision-dev-python.mp4',
    'thumbnails/techvision-dev-python.jpg',
    'https://etoile-video-worker.gzzadri11.workers.dev/stream/thumbnails/techvision-dev-python.jpg',
    40, 10200000, '720p',
    'active', 210, 156,
    NOW() - INTERVAL '12 days',
    'CDI'
  ),
  -- UDI (emma): affiche BTP — Electricien
  (
    '10000000-0000-0000-0000-000000000005',
    '00000000-0000-0000-0000-000000000004',
    'poster',
    (SELECT id FROM categories WHERE slug = 'btp-construction'),
    'Electricien qualifie — CDD 6 mois',
    'CDD de 6 mois pour un chantier de renovation a Nanterre. Habilitation electrique requise.',
    'posters/udi-electricien.jpg',
    'https://etoile-video-worker.gzzadri11.workers.dev/stream/posters/udi-electricien.jpg',
    'posters/udi-electricien.jpg',
    'https://etoile-video-worker.gzzadri11.workers.dev/stream/posters/udi-electricien.jpg',
    0, 1500000, NULL,
    'active', 28, 22,
    NOW() - INTERVAL '10 days',
    'CDD'
  )
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- VIDEO VIEWS (quelques vues pour les stats)
-- =============================================================================

INSERT INTO video_views (video_id, viewer_id, watch_duration, completed, device_type) VALUES
  -- Emma regarde la video d'Alice
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', 40, true,  'android'),
  -- Emma regarde la video de Lucas
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 35, false, 'android'),
  -- Alice regarde l'offre UDI
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 38, true,  'ios'),
  -- Alice regarde l'offre TechVision
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 40, true,  'ios'),
  -- Lucas regarde l'offre TechVision
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002', 40, true,  'android');

-- =============================================================================
-- CONVERSATIONS (2 conversations)
-- =============================================================================

INSERT INTO conversations (id, participant_1, participant_2, video_id, last_message_at, last_message_preview) VALUES
  -- Emma (recruteur) contacte Alice (chercheur) via sa video
  (
    '20000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000004',
    '00000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    NOW() - INTERVAL '2 hours',
    'Super, je vous envoie les details par mail !'
  ),
  -- TechVision contacte Lucas via sa video
  (
    '20000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000005',
    '00000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000002',
    NOW() - INTERVAL '1 day',
    'Merci pour votre interet, je suis disponible la semaine prochaine.'
  )
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- MESSAGES (conversation 1 : 5 messages, conversation 2 : 3 messages)
-- =============================================================================

INSERT INTO messages (conversation_id, sender_id, content, content_type, is_read, created_at) VALUES
  -- Conversation 1 : Emma <-> Alice
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004',
   'Bonjour Alice ! J''ai vu votre video de presentation, votre profil correspond a ce que nous recherchons chez UDI.',
   'text', true, NOW() - INTERVAL '3 days'),

  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
   'Bonjour ! Merci beaucoup, ca me fait plaisir. Quel type de poste proposez-vous ?',
   'text', true, NOW() - INTERVAL '3 days' + INTERVAL '30 minutes'),

  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004',
   'Nous cherchons un developpeur frontend pour notre outil interne de suivi de chantier. Stack React/TypeScript.',
   'text', true, NOW() - INTERVAL '2 days'),

  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
   'Ca m''interesse beaucoup ! Je suis disponible pour un entretien quand vous voulez.',
   'text', true, NOW() - INTERVAL '1 day'),

  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004',
   'Super, je vous envoie les details par mail !',
   'text', false, NOW() - INTERVAL '2 hours'),

  -- Conversation 2 : TechVision <-> Lucas
  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000005',
   'Bonjour Lucas, votre experience en direction commerciale SaaS nous interesse chez TechVision.',
   'text', true, NOW() - INTERVAL '2 days'),

  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002',
   'Bonjour ! Merci pour votre message. Pouvez-vous m''en dire plus sur le poste ?',
   'text', true, NOW() - INTERVAL '2 days' + INTERVAL '2 hours'),

  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002',
   'Merci pour votre interet, je suis disponible la semaine prochaine.',
   'text', false, NOW() - INTERVAL '1 day')
;

-- =============================================================================
-- FIN DU SEED
-- =============================================================================
-- Comptes de test :
--   Chercheur : alice.martin@test.fr, lucas.durand@test.fr, sofia.benali@test.fr
--   Recruteur : emma@gmail.com (UDI, BTP, verifie), contact@techvision.fr (IT, verifie)
--   Admin     : admin@etoile-app.fr
-- =============================================================================
