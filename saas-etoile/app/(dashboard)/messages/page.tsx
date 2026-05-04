'use client';

import { useSearchParams, useRouter } from 'next/navigation';
import { Suspense, useEffect, useState } from 'react';
import { ConversationList } from '@/components/messages/conversation-list';
import { MessageThread } from '@/components/messages/message-thread';
import { getConversations } from './actions';
import type { ConversationWithUnread } from '@/lib/types/database';

function MessagesPageContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const selectedConversationId = searchParams.get('conversation');

  const [conversations, setConversations] = useState<ConversationWithUnread[]>([]);
  const [loading, setLoading] = useState(true);

  // Load conversations
  useEffect(() => {
    getConversations().then((data) => {
      setConversations(data);
      setLoading(false);
    });
  }, []);

  const handleSelectConversation = (id: string) => {
    router.push(`/messages?conversation=${id}`);
  };

  return (
    <div className="flex h-[calc(100vh-5rem)] -m-8">
      {/* Sidebar conversations */}
      <ConversationList
        conversations={conversations}
        selectedId={selectedConversationId || undefined}
        onSelect={handleSelectConversation}
        loading={loading}
      />

      {/* Main chat thread */}
      {selectedConversationId ? (
        <MessageThread conversationId={selectedConversationId} />
      ) : (
        <div className="flex-1 flex items-center justify-center text-muted-foreground">
          <div className="text-center">
            <p className="text-lg font-medium">Sélectionnez une conversation</p>
            <p className="text-sm mt-2">Choisissez un candidat pour commencer la discussion</p>
          </div>
        </div>
      )}
    </div>
  );
}

export default function MessagesPage() {
  return (
    <Suspense
      fallback={
        <div className="flex h-[calc(100vh-5rem)] -m-8 items-center justify-center">
          <p className="text-muted-foreground">Chargement...</p>
        </div>
      }
    >
      <MessagesPageContent />
    </Suspense>
  );
}
