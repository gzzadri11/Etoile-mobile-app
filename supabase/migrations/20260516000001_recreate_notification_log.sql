-- =============================================================================
-- Recréation de notification_log supprimée par erreur dans cleanup_unused.
-- Cette table est requise par l'Edge Function send-push pour la déduplication.
-- =============================================================================

CREATE TABLE IF NOT EXISTS notification_log (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type         VARCHAR(30) NOT NULL,
    reference_id UUID,
    created_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notif_log_user_type
    ON notification_log(user_id, type, created_at DESC);

ALTER TABLE notification_log ENABLE ROW LEVEL SECURITY;

-- Seul le service_role (Edge Functions) peut lire/écrire
CREATE POLICY "Service role manages notification_log" ON notification_log
    FOR ALL USING (true);
