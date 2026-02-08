-- =============================================================================
-- SCRIPT: Ajouter un utilisateur de test avec des vidéos
-- Executez ce script dans: Supabase > SQL Editor > New Query
-- =============================================================================

-- =============================================================================
-- ETAPE 1: Créer un utilisateur de test dans auth.users
-- Note: Normalement on crée les users via l'app, mais pour les tests on peut
-- utiliser la fonction admin de Supabase
-- =============================================================================

-- Vérifier d'abord combien d'utilisateurs existent
SELECT
    'Utilisateurs actuels' as info,
    COUNT(*) as count
FROM auth.users;

-- =============================================================================
-- ETAPE 2: Créer un profil seeker de test
-- On va créer un "faux" profil pour un utilisateur qui n'existe pas dans auth
-- Cela fonctionne car les RLS permettent de voir les profils des autres
-- =============================================================================

-- Générer un UUID fixe pour notre utilisateur de test
-- Utilisons un UUID reconnaissable: 00000000-0000-0000-0000-000000000001
DO $$
DECLARE
    v_test_user_id UUID := '00000000-0000-0000-0000-000000000001';
    v_category_dev UUID;
    v_category_design UUID;
    v_category_commercial UUID;
BEGIN
    -- Vérifier si l'utilisateur de test existe déjà
    IF EXISTS (SELECT 1 FROM seeker_profiles WHERE user_id = v_test_user_id) THEN
        RAISE NOTICE 'Utilisateur de test existe déjà, mise à jour des vidéos...';
    ELSE
        -- Créer le profil seeker de test
        INSERT INTO seeker_profiles (
            user_id,
            first_name,
            last_name,
            phone,
            region,
            city,
            postal_code,
            categories,
            contract_types,
            experience_level,
            availability,
            bio,
            profile_complete
        ) VALUES (
            v_test_user_id,
            'Marie',
            'Dupont',
            '+33612345678',
            'Île-de-France',
            'Paris',
            '75001',
            ARRAY['Développement', 'Design'],
            ARRAY['CDI', 'CDD'],
            'senior',
            'immediate',
            'Développeuse Full Stack passionnée avec 7 ans d''expérience. Spécialisée React/Node.js.',
            true
        );
        RAISE NOTICE 'Profil seeker de test créé: Marie Dupont';
    END IF;

    -- Récupérer les IDs des catégories
    SELECT id INTO v_category_dev FROM categories WHERE slug = 'developpement' OR name ILIKE '%développement%' OR name ILIKE '%informatique%' LIMIT 1;
    SELECT id INTO v_category_design FROM categories WHERE slug = 'design' OR name ILIKE '%design%' LIMIT 1;
    SELECT id INTO v_category_commercial FROM categories WHERE slug = 'commercial' OR name ILIKE '%commerce%' OR name ILIKE '%vente%' LIMIT 1;

    -- Supprimer les anciennes vidéos de test pour cet utilisateur
    DELETE FROM videos WHERE user_id = v_test_user_id;

    -- Créer des vidéos de test pour Marie
    INSERT INTO videos (
        user_id, type, category_id, title, description,
        video_key, video_url, thumbnail_url,
        duration_seconds, status, published_at, created_at
    ) VALUES
    (
        v_test_user_id,
        'presentation',
        v_category_dev,
        NULL,
        'Développeuse Full Stack - React, Node.js, PostgreSQL',
        'test/marie_dev.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        'https://picsum.photos/seed/marie1/400/700',
        40,
        'active',
        NOW() - INTERVAL '2 hours',
        NOW() - INTERVAL '2 hours'
    ),
    (
        v_test_user_id,
        'presentation',
        v_category_design,
        NULL,
        'Egalement passionnée par l''UX/UI Design',
        'test/marie_design.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'https://picsum.photos/seed/marie2/400/700',
        40,
        'active',
        NOW() - INTERVAL '1 hour',
        NOW() - INTERVAL '1 hour'
    );

    RAISE NOTICE 'Vidéos de test créées pour Marie Dupont';
END $$;

-- =============================================================================
-- ETAPE 3: Créer un second utilisateur de test (recruteur)
-- =============================================================================

DO $$
DECLARE
    v_test_recruiter_id UUID := '00000000-0000-0000-0000-000000000002';
    v_category_commercial UUID;
BEGIN
    -- Vérifier si le recruteur de test existe déjà
    IF EXISTS (SELECT 1 FROM recruiter_profiles WHERE user_id = v_test_recruiter_id) THEN
        RAISE NOTICE 'Recruteur de test existe déjà, mise à jour des vidéos...';
    ELSE
        -- Créer le profil recruiter de test
        INSERT INTO recruiter_profiles (
            user_id,
            company_name,
            siret,
            description,
            website,
            sector,
            company_size,
            locations,
            verification_status
        ) VALUES (
            v_test_recruiter_id,
            'TechStartup SAS',
            '12345678901234',
            'Startup innovante dans la FoodTech. Nous révolutionnons la livraison de repas.',
            'https://techstartup.example.com',
            'Tech / FoodTech',
            '11-50',
            ARRAY['Paris', 'Lyon'],
            'verified'
        );
        RAISE NOTICE 'Profil recruteur de test créé: TechStartup SAS';
    END IF;

    -- Récupérer l'ID de la catégorie
    SELECT id INTO v_category_commercial FROM categories WHERE slug = 'commercial' OR name ILIKE '%commerce%' OR name ILIKE '%vente%' LIMIT 1;

    -- Supprimer les anciennes vidéos de test pour ce recruteur
    DELETE FROM videos WHERE user_id = v_test_recruiter_id;

    -- Créer une vidéo d'offre d'emploi
    INSERT INTO videos (
        user_id, type, category_id, title, description,
        video_key, video_url, thumbnail_url,
        duration_seconds, status, published_at, created_at
    ) VALUES
    (
        v_test_recruiter_id,
        'offer',
        v_category_commercial,
        'Commercial B2B - CDI Paris',
        'Rejoignez notre équipe commerciale en pleine croissance !',
        'test/techstartup_offer.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'https://picsum.photos/seed/startup1/400/700',
        40,
        'active',
        NOW() - INTERVAL '30 minutes',
        NOW() - INTERVAL '30 minutes'
    );

    RAISE NOTICE 'Vidéo d''offre créée pour TechStartup SAS';
END $$;

-- =============================================================================
-- ETAPE 4: Vérifier les données créées
-- =============================================================================

SELECT '=== PROFILS SEEKER ===' as section;
SELECT user_id, first_name, last_name, city, availability
FROM seeker_profiles
ORDER BY created_at DESC
LIMIT 5;

SELECT '=== PROFILS RECRUITER ===' as section;
SELECT user_id, company_name, sector, verification_status
FROM recruiter_profiles
ORDER BY created_at DESC
LIMIT 5;

SELECT '=== VIDEOS ACTIVES ===' as section;
SELECT
    v.id,
    v.user_id,
    v.type,
    v.status,
    COALESCE(sp.first_name || ' ' || sp.last_name, rp.company_name, 'Unknown') as owner_name,
    v.published_at
FROM videos v
LEFT JOIN seeker_profiles sp ON v.user_id = sp.user_id
LEFT JOIN recruiter_profiles rp ON v.user_id = rp.user_id
WHERE v.status = 'active'
ORDER BY v.published_at DESC;

-- =============================================================================
-- RESULTAT ATTENDU:
-- - 2 vidéos de Marie Dupont (seeker)
-- - 1 vidéo de TechStartup SAS (recruiter)
-- - Vos vidéos existantes
--
-- Vous pourrez maintenant contacter Marie ou TechStartup depuis le feed!
-- =============================================================================
