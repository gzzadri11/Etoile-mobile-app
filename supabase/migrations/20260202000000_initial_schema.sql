-- =============================================================================
-- ETOILE MOBILE APP - SCHEMA INITIAL
-- Migration: 20260202000000_initial_schema.sql
-- Description: Creation du schema complet de la base de donnees
-- =============================================================================

-- =============================================================================
-- EXTENSIONS
-- =============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- TABLE: users
-- Description: Utilisateurs de la plateforme (chercheurs, recruteurs, admins)
-- =============================================================================
CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email               VARCHAR(255) UNIQUE NOT NULL,
    password_hash       VARCHAR(255),
    role                VARCHAR(20) NOT NULL CHECK (role IN ('seeker', 'recruiter', 'admin')),
    email_verified      BOOLEAN DEFAULT FALSE,
    email_verified_at   TIMESTAMP WITH TIME ZONE,
    is_premium          BOOLEAN DEFAULT FALSE,
    premium_until       TIMESTAMP WITH TIME ZONE,
    status              VARCHAR(20) DEFAULT 'active'
                        CHECK (status IN ('active', 'pending', 'suspended', 'deleted')),
    last_login_at       TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);

-- =============================================================================
-- TABLE: categories
-- Description: Categories de metiers/secteurs
-- =============================================================================
CREATE TABLE categories (
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
CREATE TABLE seeker_profiles (
    user_id             UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
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

CREATE INDEX idx_seeker_categories ON seeker_profiles USING GIN(categories);
CREATE INDEX idx_seeker_region ON seeker_profiles(region);
CREATE INDEX idx_seeker_city ON seeker_profiles(city);

-- =============================================================================
-- TABLE: recruiter_profiles
-- Description: Profils des recruteurs (entreprises)
-- =============================================================================
CREATE TABLE recruiter_profiles (
    user_id             UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
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
    verified_by         UUID REFERENCES users(id),
    rejection_reason    TEXT,
    video_credits       INTEGER DEFAULT 1,
    poster_credits      INTEGER DEFAULT 1,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_recruiter_siret ON recruiter_profiles(siret);
CREATE INDEX idx_recruiter_sector ON recruiter_profiles(sector);
CREATE INDEX idx_recruiter_verification ON recruiter_profiles(verification_status);

-- =============================================================================
-- TABLE: videos
-- Description: Videos des utilisateurs (chercheurs et recruteurs)
-- =============================================================================
CREATE TABLE videos (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type                VARCHAR(20) NOT NULL CHECK (type IN ('presentation', 'offer', 'poster')),
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

CREATE INDEX idx_videos_user ON videos(user_id);
CREATE INDEX idx_videos_category ON videos(category_id);
CREATE INDEX idx_videos_status ON videos(status);
CREATE INDEX idx_videos_type ON videos(type);
CREATE INDEX idx_videos_published ON videos(published_at DESC) WHERE status = 'active';

CREATE UNIQUE INDEX idx_unique_seeker_video_per_category
    ON videos(user_id, category_id)
    WHERE type = 'presentation' AND status = 'active';

-- =============================================================================
-- TABLE: video_views
-- Description: Tracking des vues de videos
-- =============================================================================
CREATE TABLE video_views (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    video_id            UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    viewer_id           UUID REFERENCES users(id) ON DELETE SET NULL,
    viewer_ip_hash      VARCHAR(64),
    watch_duration      INTEGER,
    completed           BOOLEAN DEFAULT FALSE,
    device_type         VARCHAR(20),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_video_views_video ON video_views(video_id);
CREATE INDEX idx_video_views_viewer ON video_views(viewer_id);
CREATE INDEX idx_video_views_date ON video_views(created_at);

-- =============================================================================
-- TABLE: conversations
-- Description: Conversations entre utilisateurs
-- =============================================================================
CREATE TABLE conversations (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_1       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    participant_2       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    video_id            UUID REFERENCES videos(id),
    last_message_at     TIMESTAMP WITH TIME ZONE,
    last_message_preview TEXT,
    participant_1_read_at TIMESTAMP WITH TIME ZONE,
    participant_2_read_at TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(participant_1, participant_2)
);

CREATE INDEX idx_conversations_p1 ON conversations(participant_1);
CREATE INDEX idx_conversations_p2 ON conversations(participant_2);
CREATE INDEX idx_conversations_last_msg ON conversations(last_message_at DESC);

-- =============================================================================
-- TABLE: messages
-- Description: Messages individuels
-- =============================================================================
CREATE TABLE messages (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id     UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content             TEXT NOT NULL,
    content_type        VARCHAR(20) DEFAULT 'text' CHECK (content_type IN ('text', 'system')),
    is_read             BOOLEAN DEFAULT FALSE,
    read_at             TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);

-- =============================================================================
-- TABLE: subscriptions
-- Description: Abonnements premium
-- =============================================================================
CREATE TABLE subscriptions (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
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

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_stripe ON subscriptions(stripe_subscription_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- =============================================================================
-- TABLE: purchases
-- Description: Achats unitaires (credits video/affiche)
-- =============================================================================
CREATE TABLE purchases (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id),
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

CREATE INDEX idx_purchases_user ON purchases(user_id);
CREATE INDEX idx_purchases_status ON purchases(status);

-- =============================================================================
-- TABLE: blocks
-- Description: Blocages entre utilisateurs
-- =============================================================================
CREATE TABLE blocks (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    blocker_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason              TEXT,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(blocker_id, blocked_id)
);

CREATE INDEX idx_blocks_blocker ON blocks(blocker_id);
CREATE INDEX idx_blocks_blocked ON blocks(blocked_id);

-- =============================================================================
-- TABLE: reports
-- Description: Signalements de contenus
-- =============================================================================
CREATE TABLE reports (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id         UUID NOT NULL REFERENCES users(id),
    reported_user_id    UUID REFERENCES users(id),
    reported_video_id   UUID REFERENCES videos(id),
    reported_message_id UUID REFERENCES messages(id),
    reason              VARCHAR(100) NOT NULL,
    description         TEXT,
    status              VARCHAR(20) DEFAULT 'pending'
                        CHECK (status IN ('pending', 'reviewing', 'actioned', 'dismissed')),
    action_taken        VARCHAR(100),
    reviewed_by         UUID REFERENCES users(id),
    reviewed_at         TIMESTAMP WITH TIME ZONE,
    admin_notes         TEXT,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_created ON reports(created_at DESC);

-- =============================================================================
-- TABLE: push_tokens
-- Description: Tokens pour notifications push
-- =============================================================================
CREATE TABLE push_tokens (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token               TEXT NOT NULL,
    platform            VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android')),
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_push_tokens_user ON push_tokens(user_id);
CREATE UNIQUE INDEX idx_push_tokens_token ON push_tokens(token);

-- =============================================================================
-- TABLE: audit_logs
-- Description: Journal d'audit pour actions sensibles
-- =============================================================================
CREATE TABLE audit_logs (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID REFERENCES users(id),
    action              VARCHAR(100) NOT NULL,
    entity_type         VARCHAR(50),
    entity_id           UUID,
    old_values          JSONB,
    new_values          JSONB,
    ip_address          INET,
    user_agent          TEXT,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);

-- =============================================================================
-- FUNCTION: update_updated_at_column
-- Description: Met a jour automatiquement updated_at
-- =============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- TRIGGERS: Updated_at automatique
-- =============================================================================
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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

CREATE TRIGGER update_push_tokens_updated_at
    BEFORE UPDATE ON push_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Activer RLS sur toutes les tables sensibles
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
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
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- RLS POLICIES: users
-- =============================================================================
CREATE POLICY "Users can read own data" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can read all users" ON users
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM users u WHERE u.id = auth.uid() AND u.role = 'admin')
    );

-- =============================================================================
-- RLS POLICIES: seeker_profiles
-- =============================================================================
CREATE POLICY "Seekers can manage own profile" ON seeker_profiles
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Anyone can read seeker profiles" ON seeker_profiles
    FOR SELECT USING (true);

-- =============================================================================
-- RLS POLICIES: recruiter_profiles
-- =============================================================================
CREATE POLICY "Recruiters can manage own profile" ON recruiter_profiles
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Anyone can read verified recruiter profiles" ON recruiter_profiles
    FOR SELECT USING (verification_status = 'verified');

CREATE POLICY "Admins can read all recruiter profiles" ON recruiter_profiles
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM users u WHERE u.id = auth.uid() AND u.role = 'admin')
    );

-- =============================================================================
-- RLS POLICIES: videos
-- =============================================================================
CREATE POLICY "Anyone can read active videos" ON videos
    FOR SELECT USING (status = 'active');

CREATE POLICY "Users can manage own videos" ON videos
    FOR ALL USING (auth.uid() = user_id);

-- =============================================================================
-- RLS POLICIES: video_views
-- =============================================================================
CREATE POLICY "Users can create video views" ON video_views
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Video owners can read views" ON video_views
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM videos v WHERE v.id = video_id AND v.user_id = auth.uid())
    );

-- =============================================================================
-- RLS POLICIES: conversations
-- =============================================================================
CREATE POLICY "Participants can read conversations" ON conversations
    FOR SELECT USING (auth.uid() IN (participant_1, participant_2));

CREATE POLICY "Participants can create conversations" ON conversations
    FOR INSERT WITH CHECK (auth.uid() IN (participant_1, participant_2));

CREATE POLICY "Participants can update conversations" ON conversations
    FOR UPDATE USING (auth.uid() IN (participant_1, participant_2));

-- =============================================================================
-- RLS POLICIES: messages
-- =============================================================================
CREATE POLICY "Conversation participants can read messages" ON messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM conversations c
            WHERE c.id = conversation_id
            AND (c.participant_1 = auth.uid() OR c.participant_2 = auth.uid())
        )
    );

CREATE POLICY "Users can send messages to their conversations" ON messages
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM conversations c
            WHERE c.id = conversation_id
            AND (c.participant_1 = auth.uid() OR c.participant_2 = auth.uid())
        )
    );

-- =============================================================================
-- RLS POLICIES: subscriptions
-- =============================================================================
CREATE POLICY "Users can read own subscriptions" ON subscriptions
    FOR SELECT USING (auth.uid() = user_id);

-- =============================================================================
-- RLS POLICIES: purchases
-- =============================================================================
CREATE POLICY "Users can read own purchases" ON purchases
    FOR SELECT USING (auth.uid() = user_id);

-- =============================================================================
-- RLS POLICIES: blocks
-- =============================================================================
CREATE POLICY "Users can manage own blocks" ON blocks
    FOR ALL USING (auth.uid() = blocker_id);

-- =============================================================================
-- RLS POLICIES: reports
-- =============================================================================
CREATE POLICY "Users can create reports" ON reports
    FOR INSERT WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users can read own reports" ON reports
    FOR SELECT USING (auth.uid() = reporter_id);

CREATE POLICY "Admins can manage reports" ON reports
    FOR ALL USING (
        EXISTS (SELECT 1 FROM users u WHERE u.id = auth.uid() AND u.role = 'admin')
    );

-- =============================================================================
-- RLS POLICIES: push_tokens
-- =============================================================================
CREATE POLICY "Users can manage own push tokens" ON push_tokens
    FOR ALL USING (auth.uid() = user_id);

-- =============================================================================
-- SEED DATA: Categories initiales
-- =============================================================================
INSERT INTO categories (name, slug, description, sort_order) VALUES
    ('Informatique & Tech', 'informatique-tech', 'Developpement, IT, Data, Cybersecurite', 1),
    ('Commerce & Vente', 'commerce-vente', 'Vente, Retail, Business Development', 2),
    ('Marketing & Communication', 'marketing-communication', 'Marketing digital, Communication, RP', 3),
    ('Finance & Comptabilite', 'finance-comptabilite', 'Comptabilite, Audit, Finance d''entreprise', 4),
    ('Ressources Humaines', 'ressources-humaines', 'RH, Recrutement, Formation', 5),
    ('Sante & Medical', 'sante-medical', 'Professions medicales et paramedicales', 6),
    ('BTP & Construction', 'btp-construction', 'Batiment, Travaux Publics, Architecture', 7),
    ('Industrie & Production', 'industrie-production', 'Usine, Logistique, Supply Chain', 8),
    ('Hotellerie & Restauration', 'hotellerie-restauration', 'Hotels, Restaurants, Tourisme', 9),
    ('Education & Formation', 'education-formation', 'Enseignement, Formation professionnelle', 10),
    ('Juridique & Droit', 'juridique-droit', 'Avocats, Juristes, Notaires', 11),
    ('Art & Design', 'art-design', 'Design graphique, UX/UI, Creation', 12),
    ('Services a la personne', 'services-personne', 'Aide a domicile, Garde d''enfants', 13),
    ('Transport & Logistique', 'transport-logistique', 'Chauffeurs, Livreurs, Logistique', 14),
    ('Autre', 'autre', 'Autres secteurs d''activite', 99);

-- =============================================================================
-- FIN DE LA MIGRATION
-- =============================================================================
