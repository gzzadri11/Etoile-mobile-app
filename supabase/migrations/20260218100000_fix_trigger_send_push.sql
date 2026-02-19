-- =============================================================================
-- Fix: trigger_send_push resilient to missing service_role_key
-- The current_setting('supabase.service_role_key') can fail in some contexts,
-- which blocks message INSERT entirely. This fix catches the error gracefully.
-- Date: 2026-02-18
-- =============================================================================

CREATE OR REPLACE FUNCTION public.trigger_send_push()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  request_id bigint;
  payload jsonb;
  headers jsonb;
  service_key text;
BEGIN
  -- Try to get service role key; if unavailable, skip push but let INSERT succeed
  BEGIN
    service_key := current_setting('supabase.service_role_key');
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING '[trigger_send_push] service_role_key not available, skipping push notification';
    RETURN NEW;
  END;

  payload := jsonb_build_object(
    'type', TG_OP,
    'table', TG_TABLE_NAME,
    'schema', TG_TABLE_SCHEMA,
    'record', row_to_json(NEW)::jsonb,
    'old_record', CASE WHEN TG_OP = 'UPDATE' THEN row_to_json(OLD)::jsonb ELSE NULL END
  );

  headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'Authorization', 'Bearer ' || service_key
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
