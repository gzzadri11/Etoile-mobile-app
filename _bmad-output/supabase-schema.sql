-- =============================================================================
-- SCHEMA ETOILE - PostgreSQL via Supabase
-- Executez ce script dans: Supabase > SQL Editor > New Query
-- =============================================================================

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- TABLE: categories (doit etre creee en premier pour les references)
-- Description: Categories de metiers/secteurs
-- =============================================================================
CREATE TABLE IF NOT EXISTS categories (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                VARCHAR(100) NOT NULL UNIQUE,
    slug                VARCHAR(100) NOT NULL UNIQUE,
    description         TEXT,
    icon                VARCHAR(50),
    parent_id           UUID REFERENCES categories(id),
    sort_order          INTEGER DEFAULT 0,
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABLE: seeker_profiles
-- Description: Profils des chercheurs d'emploi
-- =============================================================================
CREATE TABLE IF NOT EXISTS seeker_profiles (
    user_id             UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    first_name          VARCHAR(100) NOT NULL,
    last_name           VARCHAR(100),
    phone               VARCHAR(20),
    birth_date          DATE,
    region              VARCHAR(100),
    city                VARCHAR(100),
    postal_code         VARCHAR(10),
    categories          TEXT[] DEFAULT '{}',
    contract_types      TEXT[] DEFAULT '{}',
    experience_level    VARCHAR(50),
    availability        VARCHAR(50),
    salary_expectation  INTEGER,
    bio                 TEXT,
    profile_complete    BOOLEAN DEFAULT FALSE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_seeker_categories ON seeker_profiles USING GIN(categories);
CREATE INDEX IF NOT EXISTS idx_seeker_region ON seeker_profiles(region);

-- =============================================================================
-- TABLE: recruiter_profiles
-- Description: Profils des recruteurs (entreprises)
-- =============================================================================
CREATE TABLE IF NOT EXISTS recruiter_profiles (
    user_id             UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    company_name        VARCHAR(255) NOT NULL,
    siret               VARCHAR(14),
    siren               VARCHAR(9),
    legal_form          VARCHAR(100),
    document_type       VARCHAR(50),
    document_url        VARCHAR(500),
    document_uploaded_at TIMESTAMP WITH TIME ZONE,
    logo_url            VARCHAR(500),
    cover_url           VARCHAR(500),
    description         TEXT,
    website             VARCHAR(255),
    sector              VARCHAR(100),
    company_size        VARCHAR(50),
    locations           TEXT[] DEFAULT '{}',
    verification_status VARCHAR(20) DEFAULT 'pending'
                        CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verified_at         TIMESTAMP WITH TIME ZONE,
    verified_by         UUID REFERENCES auth.users(id),
    rejection_reason    TEXT,
    video_credits       INTEGER DEFAULT 1,
    poster_credits      INTEGER DEFAULT 1,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recruiter_siret ON recruiter_profiles(siret);
CREATE INDEX IF NOT EXISTS idx_recruiter_verification ON recruiter_profiles(verification_status);

-- =============================================================================
-- TABLE: videos
-- Description: Videos des utilisateurs (chercheurs et recruteurs)
-- =============================================================================
CREATE TABLE IF NOT EXISTS videos (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type                VARCHAR(20) NOT NULL CHECK (type IN ('presentation', 'offer')),
    category_id         UUID REFERENCES categories(id),
    title               VARCHAR(255),
    description         TEXT,
    video_key           VARCHAR(500) NOT NULL,
    video_url           VARCHAR(500),
    thumbnail_key       VARCHAR(500),
    thumbnail_url       VARCHAR(500),
    duration_seconds    INTEGER DEFAULT 40,
    file_size_bytes     BIGINT,
    resolution          VARCHAR(20),
    codec               VARCHAR(50),
    status              VARCHAR(20) DEFAULT 'processing'
                        CHECK (status IN ('processing', 'active', 'suspended', 'deleted')),
    processing_error    TEXT,
    views_count         INTEGER DEFAULT 0,
    unique_viewers      INTEGER DEFAULT 0,
    published_at        TIMESTAMP WITH TIME ZONE,
    expires_at          TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_videos_user ON videos(user_id);
CREATE INDEX IF NOT EXISTS idx_videos_category ON videos(category_id);
CREATE INDEX IF NOT EXISTS idx_videos_status ON videos(status);
CREATE INDEX IF NOT EXISTS idx_videos_type ON videos(type);

-- =============================================================================
-- TABLE: video_views
-- Description: Tracking des vues de videos
-- =============================================================================
CREATE TABLE IF NOT EXISTS video_views (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    video_id            UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    viewer_id           UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    viewer_ip_hash      VARCHAR(64),
    watch_duration      INTEGER,
    completed           BOOLEAN DEFAULT FALSE,
    device_type         VARCHAR(20),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_video_views_video ON video_views(video_id);
CREATE INDEX IF NOT EXISTS idx_video_views_viewer ON video_views(viewer_id);

-- =============================================================================
-- TABLE: conversations
-- Description: Conversations entre utilisateurs
-- =============================================================================
CREATE TABLE IF NOT EXISTS conversations (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_1       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    participant_2       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    video_id            UUID REFERENCES videos(id),
    last_message_at     TIMESTAMP WITH TIME ZONE,
    last_message_preview TEXT,
    participant_1_read_at TIMESTAMP WITH TIME ZONE,
    participant_2_read_at TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(participant_1, participant_2)
);

CREATE INDEX IF NOT EXISTS idx_conversations_p1 ON conversations(participant_1);
CREATE INDEX IF NOT EXISTS idx_conversations_p2 ON conversations(participant_2);

-- =============================================================================
-- TABLE: messages
-- Description: Messages individuels
-- =============================================================================
CREATE TABLE IF NOT EXISTS messages (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id     UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content             TEXT NOT NULL,
    content_type        VARCHAR(20) DEFAULT 'text' CHECK (content_type IN ('text', 'system')),
    is_read             BOOLEAN DEFAULT FALSE,
    read_at             TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);

-- =============================================================================
-- TABLE: subscriptions
-- Description: Abonnements premium
-- =============================================================================
CREATE TABLE IF NOT EXISTS subscriptions (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    plan_type           VARCHAR(50) NOT NULL
                        CHECK (plan_type IN ('seeker_premium', 'recruiter_premium')),
    plan_price_cents    INTEGER NOT NULL,
    stripe_subscription_id VARCHAR(255) UNIQUE,
    stripe_customer_id     VARCHAR(255),
    stripe_price_id        VARCHAR(255),
    status              VARCHAR(20) DEFAULT 'active'
                        CHECK (status IN ('active', 'canceled', 'past_due', 'expired', 'trialing')),
    trial_ends_at       TIMESTAMP WITH TIME ZONE,
    current_period_start TIMESTAMP WITH TIME ZONE,
    current_period_end   TIMESTAMP WITH TIME ZONE,
    canceled_at         TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);

-- =============================================================================
-- TABLE: purchases
-- Description: Achats unitaires (credits video/affiche)
-- =============================================================================
CREATE TABLE IF NOT EXISTS purchases (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES auth.users(id),
    product_type        VARCHAR(50) NOT NULL
                        CHECK (product_type IN ('video_credit', 'poster_credit')),
    quantity            INTEGER DEFAULT 1,
    unit_price_cents    INTEGER NOT NULL,
    total_price_cents   INTEGER NOT NULL,
    stripe_payment_intent_id VARCHAR(255),
    stripe_invoice_id       VARCHAR(255),
    status              VARCHAR(20) DEFAULT 'pending'
                        CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_purchases_user ON purchases(user_id);

-- =============================================================================
-- TABLE: blocks
-- Description: Blocages entre utilisateurs
-- =============================================================================
CREATE TABLE IF NOT EXISTS blocks (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    blocker_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blocked_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason              TEXT,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(blocker_id, blocked_id)
);

CREATE INDEX IF NOT EXISTS idx_blocks_blocker ON blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_blocks_blocked ON blocks(blocked_id);

-- =============================================================================
-- TABLE: reports
-- Description: Signalements de contenus
-- =============================================================================
CREATE TABLE IF NOT EXISTS reports (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id         UUID NOT NULL REFERENCES auth.users(id),
    reported_user_id    UUID REFERENCES auth.users(id),
    reported_video_id   UUID REFERENCES videos(id),
    reported_message_id UUID REFERENCES messages(id),
    reason              VARCHAR(100) NOT NULL,
    description         TEXT,
    status              VARCHAR(20) DEFAULT 'pending'
                        CHECK (status IN ('pending', 'reviewing', 'actioned', 'dismissed')),
    action_taken        VARCHAR(100),
    reviewed_by         UUID REFERENCES auth.users(id),
    reviewed_at         TIMESTAMP WITH TIME ZONE,
    admin_notes         TEXT,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);

-- =============================================================================
-- TABLE: user_roles
-- Description: Roles des utilisateurs (seeker, recruiter, admin)
-- =============================================================================
CREATE TABLE IF NOT EXISTS user_roles (
    user_id             UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role                VARCHAR(20) NOT NULL CHECK (role IN ('seeker', 'recruiter', 'admin')),
    is_premium          BOOLEAN DEFAULT FALSE,
    premium_until       TIMESTAMP WITH TIME ZONE,
    email_verified      BOOLEAN DEFAULT FALSE,
    status              VARCHAR(20) DEFAULT 'active'
                        CHECK (status IN ('active', 'pending', 'suspended', 'deleted')),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_roles_role ON user_roles(role);

-- =============================================================================
-- TRIGGERS: Updated_at automatique
-- =============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_seeker_profiles_updated_at
    BEFORE UPDATE ON seeker_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recruiter_profiles_updated_at
    BEFORE UPDATE ON recruiter_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_videos_updated_at
    BEFORE UPDATE ON videos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_roles_updated_at
    BEFORE UPDATE ON user_roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Activer RLS sur toutes les tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE seeker_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE recruiter_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- POLICIES
-- =============================================================================

-- Categories: tout le monde peut lire
CREATE POLICY "Anyone can read categories" ON categories
    FOR SELECT USING (true);

-- User roles: chacun peut lire/modifier le sien
CREATE POLICY "Users can read own role" ON user_roles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own role" ON user_roles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own role" ON user_roles
    FOR UPDATE USING (auth.uid() = user_id);

-- Seeker profiles
CREATE POLICY "Users can read own seeker profile" ON seeker_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Recruiters can read seeker profiles" ON seeker_profiles
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'recruiter')
    );

CREATE POLICY "Users can manage own seeker profile" ON seeker_profiles
    FOR ALL USING (auth.uid() = user_id);

-- Recruiter profiles
CREATE POLICY "Anyone can read verified recruiter profiles" ON recruiter_profiles
    FOR SELECT USING (verification_status = 'verified');

CREATE POLICY "Users can read own recruiter profile" ON recruiter_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own recruiter profile" ON recruiter_profiles
    FOR ALL USING (auth.uid() = user_id);

-- Videos: tout le monde peut voir les actives
CREATE POLICY "Anyone can read active videos" ON videos
    FOR SELECT USING (status = 'active');

CREATE POLICY "Users can read own videos" ON videos
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own videos" ON videos
    FOR ALL USING (auth.uid() = user_id);

-- Video views
CREATE POLICY "Users can insert video views" ON video_views
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Video owners can read views" ON video_views
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM videos WHERE videos.id = video_id AND videos.user_id = auth.uid())
    );

-- Conversations: participants seulement
CREATE POLICY "Participants can read conversations" ON conversations
    FOR SELECT USING (auth.uid() = participant_1 OR auth.uid() = participant_2);

CREATE POLICY "Users can create conversations" ON conversations
    FOR INSERT WITH CHECK (auth.uid() = participant_1 OR auth.uid() = participant_2);

CREATE POLICY "Participants can update conversations" ON conversations
    FOR UPDATE USING (auth.uid() = participant_1 OR auth.uid() = participant_2);

-- Messages: participants seulement
CREATE POLICY "Conversation participants can read messages" ON messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM conversations c
            WHERE c.id = conversation_id
            AND (c.participant_1 = auth.uid() OR c.participant_2 = auth.uid())
        )
    );

CREATE POLICY "Users can send messages" ON messages
    FOR INSERT WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update own messages" ON messages
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM conversations c
            WHERE c.id = conversation_id
            AND (c.participant_1 = auth.uid() OR c.participant_2 = auth.uid())
        )
    );

-- Subscriptions
CREATE POLICY "Users can read own subscriptions" ON subscriptions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own subscriptions" ON subscriptions
    FOR ALL USING (auth.uid() = user_id);

-- Purchases
CREATE POLICY "Users can read own purchases" ON purchases
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create purchases" ON purchases
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Blocks
CREATE POLICY "Users can manage own blocks" ON blocks
    FOR ALL USING (auth.uid() = blocker_id);

-- Reports
CREATE POLICY "Users can create reports" ON reports
    FOR INSERT WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users can read own reports" ON reports
    FOR SELECT USING (auth.uid() = reporter_id);

-- =============================================================================
-- DONNEES INITIALES: Categories
-- =============================================================================
INSERT INTO categories (name, slug, icon, sort_order) VALUES
    ('Restauration', 'restauration', 'restaurant', 1),
    ('Commerce & Vente', 'commerce-vente', 'storefront', 2),
    ('Hotellerie & Tourisme', 'hotellerie-tourisme', 'hotel', 3),
    ('BTP & Construction', 'btp-construction', 'construction', 4),
    ('Transport & Logistique', 'transport-logistique', 'local_shipping', 5),
    ('Sante & Medical', 'sante-medical', 'medical_services', 6),
    ('Informatique & Tech', 'informatique-tech', 'computer', 7),
    ('Marketing & Communication', 'marketing-communication', 'campaign', 8),
    ('Finance & Comptabilite', 'finance-comptabilite', 'account_balance', 9),
    ('Ressources Humaines', 'ressources-humaines', 'people', 10),
    ('Industrie & Production', 'industrie-production', 'factory', 11),
    ('Services a la personne', 'services-personne', 'support_agent', 12),
    ('Agriculture & Environnement', 'agriculture-environnement', 'eco', 13),
    ('Art & Culture', 'art-culture', 'palette', 14),
    ('Autre', 'autre', 'more_horiz', 99)
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- FIN DU SCRIPT
-- =============================================================================
