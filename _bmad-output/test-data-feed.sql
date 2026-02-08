-- =============================================================================
-- DONNEES DE TEST - FEED ETOILE
-- Executez ce script dans: Supabase > SQL Editor > New Query
-- IMPORTANT: Vous devez d'abord avoir un compte utilisateur créé via l'app
-- =============================================================================

-- =============================================================================
-- 1. CATEGORIES (si pas déjà créées)
-- =============================================================================
INSERT INTO categories (name, slug, description, icon, sort_order, is_active)
VALUES
    ('Développement', 'developpement', 'Développement logiciel et web', '💻', 1, true),
    ('Design', 'design', 'Design graphique et UX/UI', '🎨', 2, true),
    ('Marketing', 'marketing', 'Marketing digital et communication', '📢', 3, true),
    ('Commercial', 'commercial', 'Vente et relation client', '🤝', 4, true),
    ('Ressources Humaines', 'rh', 'RH et recrutement', '👥', 5, true),
    ('Finance', 'finance', 'Comptabilité et finance', '💰', 6, true),
    ('Logistique', 'logistique', 'Supply chain et transport', '📦', 7, true),
    ('Santé', 'sante', 'Médical et paramédical', '🏥', 8, true)
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- 2. FONCTION POUR CREER DES VIDEOS DE TEST
-- Cette fonction utilise votre user_id actuel
-- =============================================================================

-- Afficher votre user_id (copiez-le pour la suite)
-- SELECT auth.uid();

-- =============================================================================
-- 3. CREER DES VIDEOS DE TEST
-- REMPLACEZ 'VOTRE_USER_ID' par votre vrai user_id
-- Vous pouvez le trouver dans: Authentication > Users dans Supabase
-- =============================================================================

-- Option A: Si vous êtes connecté, utilisez auth.uid()
-- Option B: Remplacez par votre UUID manuellement

DO $$
DECLARE
    v_user_id UUID;
    v_category_dev UUID;
    v_category_design UUID;
    v_category_marketing UUID;
BEGIN
    -- Récupérer l'ID du premier utilisateur seeker existant
    SELECT user_id INTO v_user_id FROM seeker_profiles LIMIT 1;

    IF v_user_id IS NULL THEN
        RAISE NOTICE 'Aucun seeker_profile trouvé. Créez d''abord un compte chercheur via l''app.';
        RETURN;
    END IF;

    -- Récupérer les IDs des catégories
    SELECT id INTO v_category_dev FROM categories WHERE slug = 'developpement';
    SELECT id INTO v_category_design FROM categories WHERE slug = 'design';
    SELECT id INTO v_category_marketing FROM categories WHERE slug = 'marketing';

    RAISE NOTICE 'Création des vidéos pour user_id: %', v_user_id;

    -- Créer 3 vidéos de test
    INSERT INTO videos (
        user_id, type, category_id, title, description,
        video_key, video_url, thumbnail_url,
        duration_seconds, status, published_at, created_at
    ) VALUES
    (
        v_user_id,
        'presentation',
        v_category_dev,
        NULL,
        'Développeur passionné avec 5 ans d''expérience',
        'test/video1.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'https://picsum.photos/seed/dev1/400/700',
        40,
        'active',
        NOW() - INTERVAL '1 hour',
        NOW() - INTERVAL '1 hour'
    ),
    (
        v_user_id,
        'presentation',
        v_category_design,
        NULL,
        'Designer créatif spécialisé en UX mobile',
        'test/video2.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'https://picsum.photos/seed/design1/400/700',
        40,
        'active',
        NOW() - INTERVAL '30 minutes',
        NOW() - INTERVAL '30 minutes'
    ),
    (
        v_user_id,
        'presentation',
        v_category_marketing,
        NULL,
        'Expert marketing digital et growth hacking',
        'test/video3.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'https://picsum.photos/seed/marketing1/400/700',
        40,
        'active',
        NOW(),
        NOW()
    );

    RAISE NOTICE 'Vidéos de test créées avec succès!';
END $$;

-- =============================================================================
-- 4. VERIFIER LES DONNEES
-- =============================================================================
SELECT
    v.id,
    v.type,
    v.status,
    v.title,
    v.thumbnail_url,
    sp.first_name,
    sp.last_name,
    sp.city
FROM videos v
LEFT JOIN seeker_profiles sp ON v.user_id = sp.user_id
WHERE v.status = 'active'
ORDER BY v.published_at DESC;

-- =============================================================================
-- 5. COMPTER LES VIDEOS
-- =============================================================================
SELECT
    COUNT(*) as total_videos,
    COUNT(*) FILTER (WHERE status = 'active') as active_videos,
    COUNT(*) FILTER (WHERE type = 'presentation') as seeker_videos,
    COUNT(*) FILTER (WHERE type = 'offer') as recruiter_videos
FROM videos;
