'use client';

import { Badge } from '@/components/ui/badge';
import type { ConversationWithUnread } from '@/lib/types/database';
import { formatDistanceToNow } from 'date-fns';
import { fr } from 'date-fns/locale';

interface ConversationListProps {
  conversations: ConversationWithUnread[];
  selectedId?: string;
  onSelect: (id: string) => void;
  loading?: boolean;
}

export function ConversationList({
  conversations,
  selectedId,
  onSelect,
  loading,
}: ConversationListProps) {
  if (loading) {
    return (
      <div className="w-80 shrink-0 border-r bg-background p-4">
        <div className="space-y-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="animate-pulse">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-muted rounded-full" />
                <div className="flex-1 space-y-2">
                  <div className="h-4 bg-muted rounded w-3/4" />
                  <div className="h-3 bg-muted rounded w-1/2" />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (conversations.length === 0) {
    return (
      <div className="w-80 shrink-0 border-r bg-background p-4">
        <p className="text-center text-text-secondary text-sm mt-8">
          Aucune conversation
        </p>
      </div>
    );
  }

  return (
    <div className="w-80 shrink-0 border-r bg-background overflow-y-auto">
      <div className="sticky top-0 z-10 bg-background border-b p-4">
        <h2 className="font-semibold text-lg">Messages</h2>
        <p className="text-sm text-text-secondary mt-1">
          {conversations.length} conversation{conversations.length > 1 ? 's' : ''}
        </p>
      </div>

      <div className="divide-y">
        {conversations.map((conv) => {
          const isSelected = selectedId === conv.id;
          const hasUnread = (conv.unread_count || 0) > 0;

          return (
            <button
              key={conv.id}
              onClick={() => onSelect(conv.id)}
              className={`w-full text-left p-4 hover:bg-bg-subtle transition-fast ${
                isSelected ? 'bg-muted' : ''
              }`}
            >
              <div className="flex items-start gap-3">
                {/* Avatar */}
                <div className="shrink-0">
                  {conv.participant?.photo_url ? (
                    <img
                      src={conv.participant.photo_url}
                      alt={conv.participant.first_name || 'Candidat'}
                      className="w-12 h-12 rounded-full object-cover"
                    />
                  ) : (
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-orange-400 to-rose-400 flex items-center justify-center text-white font-medium">
                      {conv.participant?.first_name?.charAt(0)?.toUpperCase() || '?'}
                    </div>
                  )}
                </div>

                {/* Content */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between gap-2 mb-1">
                    <p className={`font-medium truncate ${hasUnread ? 'text-text-primary' : 'text-foreground'}`}>
                      {conv.participant?.first_name || 'Inconnu'}
                      {conv.participant?.username && (
                        <span className="text-text-secondary text-sm font-normal ml-2">
                          @{conv.participant.username}
                        </span>
                      )}
                    </p>
                    {hasUnread && (
                      <Badge variant="default" className="shrink-0">
                        {conv.unread_count}
                      </Badge>
                    )}
                  </div>

                  {conv.participant?.specialty && (
                    <p className="text-xs text-text-secondary mb-1">{conv.participant.specialty}</p>
                  )}

                  {conv.last_message_preview && (
                    <p className={`text-sm truncate ${hasUnread ? 'font-medium text-text-primary' : 'text-muted-foreground'}`}>
                      {conv.last_message_preview}
                    </p>
                  )}

                  {conv.last_message_at && (
                    <p className="text-xs text-text-tertiary mt-1">
                      {formatDistanceToNow(new Date(conv.last_message_at), {
                        addSuffix: true,
                        locale: fr,
                      })}
                    </p>
                  )}
                </div>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}
