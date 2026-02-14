-- =============================================================================
-- ETOILE MOBILE APP - NOTIFICATIONS PUSH
-- Migration: 20260214000000_device_tokens.sql
-- Description: Tables pour les notifications push (FCM tokens + deduplication)
-- =============================================================================

-- =============================================================================
-- TABLE: device_tokens
-- Description: Tokens FCM des appareils pour les notifications push
-- =============================================================================
CREATE TABLE IF NOT EXISTS device_tokens (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token       TEXT NOT NULL,
    platform    VARCHAR(10) NOT NULL CHECK (platform IN ('android', 'ios')),
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user ON device_tokens(user_id);

-- RLS
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- Un utilisateur peut gerer ses propres tokens
CREATE POLICY "Users manage own tokens" ON device_tokens
    FOR ALL USING (auth.uid() = user_id);

-- =============================================================================
-- TABLE: notification_log
-- Description: Log de deduplication des notifications envoyees
-- =============================================================================
CREATE TABLE IF NOT EXISTS notification_log (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type            VARCHAR(30) NOT NULL,
    reference_id    UUID,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notif_log_user_type ON notification_log(user_id, type, created_at DESC);

-- RLS
ALTER TABLE notification_log ENABLE ROW LEVEL SECURITY;

-- Seul le service_role peut ecrire/lire (via Edge Functions)
CREATE POLICY "Service role manages notification_log" ON notification_log
    FOR ALL USING (true);

-- =============================================================================
-- REALTIME: Activer pour device_tokens (pour sync)
-- =============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE device_tokens;
