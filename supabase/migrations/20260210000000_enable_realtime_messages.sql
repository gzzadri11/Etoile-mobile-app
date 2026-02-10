-- =============================================================================
-- MIGRATION: Enable Realtime for messaging tables
-- Date: 2026-02-10
-- Description: Active Supabase Realtime sur messages et conversations
--              pour permettre la messagerie temps reel
-- =============================================================================

-- Enable realtime for messages table (new messages appear instantly)
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Enable realtime for conversations table (last_message_at, preview updates)
ALTER PUBLICATION supabase_realtime ADD TABLE conversations;
