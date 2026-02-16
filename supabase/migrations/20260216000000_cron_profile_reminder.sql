-- =============================================================================
-- Migration: Webhooks + CRON - Notifications Push
-- Sprint 9 - Notifications Push
-- Date: 2026-02-16
-- =============================================================================

-- =============================================================================
-- PARTIE A : Database Webhooks (triggers pour notifications push)
-- =============================================================================

-- Fonction trigger qui appelle send-push avec auth dynamique
CREATE OR REPLACE FUNCTION public.trigger_send_push()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  request_id bigint;
  payload jsonb;
  headers jsonb;
BEGIN
  payload := jsonb_build_object(
    'type', TG_OP,
    'table', TG_TABLE_NAME,
    'schema', TG_TABLE_SCHEMA,
    'record', row_to_json(NEW)::jsonb,
    'old_record', CASE WHEN TG_OP = 'UPDATE' THEN row_to_json(OLD)::jsonb ELSE NULL END
  );

  headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'Authorization', 'Bearer ' || current_setting('supabase.service_role_key')
  );

  SELECT http_post INTO request_id FROM net.http_post(
    'https://ojslqytmuifaofojutgb.supabase.co/functions/v1/send-push',
    payload,
    '{}'::jsonb,
    headers,
    5000
  );

  RETURN NEW;
END;
$$;

-- Trigger 1 : nouveau message -> notification push
DROP TRIGGER IF EXISTS on_new_message ON public.messages;
CREATE TRIGGER on_new_message
  AFTER INSERT ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_send_push();

-- Trigger 2 : nouvelle conversation -> notification push
DROP TRIGGER IF EXISTS on_new_conversation ON public.conversations;
CREATE TRIGGER on_new_conversation
  AFTER INSERT ON public.conversations
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_send_push();

-- =============================================================================
-- PARTIE B : CRON Jobs
-- =============================================================================

-- 1. Activer les extensions pg_cron et pg_net (si pas deja fait)
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- 2. Accorder les permissions necessaires
GRANT USAGE ON SCHEMA cron TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cron TO postgres;

-- 3. Planifier le CRON : chaque jour a 10h UTC
-- Appelle l'Edge Function send-push avec type "profile_reminder"
SELECT cron.schedule(
    'profile-reminder-daily',
    '0 10 * * *',
    $$
    SELECT net.http_post(
        url := 'https://ojslqytmuifaofojutgb.supabase.co/functions/v1/send-push',
        headers := jsonb_build_object(
            'Authorization', 'Bearer ' || current_setting('supabase.service_role_key'),
            'Content-Type', 'application/json'
        ),
        body := '{"type": "profile_reminder"}'::jsonb
    );
    $$
);

-- 4. (Optionnel) Nettoyage des vieux logs de notifications (> 30 jours)
-- Execute chaque dimanche a 3h UTC
SELECT cron.schedule(
    'cleanup-notification-logs',
    '0 3 * * 0',
    $$
    DELETE FROM notification_log
    WHERE created_at < NOW() - INTERVAL '30 days';
    $$
);
