'use client';

import { useEffect, useState, useRef } from 'react';
import { createClient } from '@/lib/supabase/client';
import { getMessages, markConversationAsRead, sendMessage as sendMessageAction } from '@/app/(dashboard)/messages/actions';
import type { Message } from '@/lib/types/database';
import { MessageBubble } from './message-bubble';
import { MessageInput } from './message-input';
import { toast } from 'sonner';

interface MessageThreadProps {
  conversationId: string;
}

export function MessageThread({ conversationId }: MessageThreadProps) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);
  const bottomRef = useRef<HTMLDivElement>(null);
  const supabase = createClient();

  // Load initial messages + mark as read
  useEffect(() => {
    if (!conversationId) return;

    setLoading(true);
    Promise.all([
      getMessages(conversationId),
      markConversationAsRead(conversationId),
    ]).then(([msgs]) => {
      setMessages(msgs);
      setLoading(false);
    });
  }, [conversationId]);

  // Realtime subscription (global channel)
  useEffect(() => {
    if (!conversationId) return;

    const channel = supabase
      .channel('recruiter-messages')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `conversation_id=eq.${conversationId}`,
        },
        (payload) => {
          const newMessage = payload.new as Message;
          setMessages((prev) => [...prev, newMessage]);
        }
      )
      .subscribe();

    return () => {
      channel.unsubscribe();
    };
  }, [conversationId, supabase]);

  // Auto-scroll to bottom on new message
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages.length]);

  const handleSendMessage = async (content: string) => {
    const result = await sendMessageAction(conversationId, content);
    if (!result.success) {
      toast.error(result.error || 'Échec envoi message');
    }
  };

  if (loading) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <p className="text-muted-foreground">Chargement...</p>
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Messages container */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 ? (
          <div className="flex items-center justify-center h-full text-muted-foreground">
            <p>Aucun message pour le moment</p>
          </div>
        ) : (
          messages.map((msg) => <MessageBubble key={msg.id} message={msg} />)
        )}
        <div ref={bottomRef} />
      </div>

      {/* Input container */}
      <MessageInput onSend={handleSendMessage} />
    </div>
  );
}
