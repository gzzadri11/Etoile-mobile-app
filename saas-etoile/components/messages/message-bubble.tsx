'use client';

import type { Message } from '@/lib/types/database';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';

interface MessageBubbleProps {
  message: Message;
}

export function MessageBubble({ message }: MessageBubbleProps) {
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);
  const supabase = createClient();

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      setCurrentUserId(data.user?.id || null);
    });
  }, [supabase]);

  const isSent = message.sender_id === currentUserId;

  return (
    <div className={`flex ${isSent ? 'justify-end' : 'justify-start'}`}>
      <div
        className={`max-w-[70%] px-4 py-2 ${
          isSent
            ? 'bg-accent text-white rounded-xl rounded-br-md'
            : 'bg-bg-muted text-text-primary rounded-xl rounded-bl-md'
        }`}
      >
        <p className="text-sm whitespace-pre-wrap break-words">{message.content}</p>
        <p
          className={`text-xs mt-1 ${
            isSent ? 'text-white/80' : 'text-text-secondary'
          }`}
        >
          {format(new Date(message.created_at), 'HH:mm', { locale: fr })}
        </p>
      </div>
    </div>
  );
}
