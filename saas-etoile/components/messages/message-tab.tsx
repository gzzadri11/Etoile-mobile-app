"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import {
  getConversationBySeeker,
  createConversation,
} from "@/app/(dashboard)/messages/actions";
import { ChatThread } from "./chat-thread";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { MessageCircle } from "lucide-react";

interface MessageTabProps {
  seekerId: string;
  videoId: string;
  applicationStatus: "pending" | "contacted" | "withdrawn";
  onConversationCreated?: () => void;
}

/**
 * Epic 15 US-15.2 : Onglet messagerie modal candidat
 *
 * Affiche conversation existante ou formulaire premier contact
 */
export function MessageTab({
  seekerId,
  videoId,
  applicationStatus,
  onConversationCreated,
}: MessageTabProps) {
  const router = useRouter();
  const [conversationId, setConversationId] = useState<string | null>(null);
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [firstMessage, setFirstMessage] = useState("");
  const [sending, setSending] = useState(false);
  const [participantData, setParticipantData] = useState<{
    user_id: string;
    first_name: string | null;
    username: string | null;
    photo_url: string | null;
    specialty: string | null;
  } | null>(null);

  useEffect(() => {
    async function loadConversation() {
      setLoading(true);

      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) {
        setLoading(false);
        return;
      }

      setCurrentUserId(user.id);

      // Epic 15 : Chercher conversation existante
      const conversation = await getConversationBySeeker(seekerId, videoId);

      if (conversation.conversationId) {
        setConversationId(conversation.conversationId);

        // Fetch participant info for ChatThread
        const { data: seeker } = await supabase
          .from("seeker_profiles")
          .select("user_id, first_name, username, photo_url, specialty")
          .eq("user_id", seekerId)
          .single();

        setParticipantData(
          seeker || {
            user_id: seekerId,
            first_name: null,
            username: null,
            photo_url: null,
            specialty: null,
          }
        );
      }

      setLoading(false);
    }

    loadConversation();
  }, [seekerId, videoId]);

  async function handleSendFirstMessage() {
    if (!firstMessage.trim() || sending) return;

    setSending(true);

    // Epic 15 : Créer conversation + envoyer premier message
    const result = await createConversation(
      seekerId,
      videoId,
      firstMessage.trim()
    );

    if (result.success && result.conversationId) {
      setConversationId(result.conversationId);
      setFirstMessage("");
      onConversationCreated?.();
    }

    setSending(false);
  }

  if (loading) {
    return (
      <div className="py-16 text-center">
        <p className="text-base text-muted-foreground">Chargement...</p>
      </div>
    );
  }

  // Conversation exists - show thread
  if (conversationId && currentUserId && participantData) {
    return (
      <div className="flex flex-col h-[60vh]">
        <ChatThread
          conversationId={conversationId}
          participant={participantData}
          currentUserId={currentUserId}
        />
      </div>
    );
  }

  // No conversation - show first contact form
  if (applicationStatus === "pending") {
    return (
      <div className="space-y-5">
        <div>
          <h3 className="text-base font-semibold mb-3">Premier contact</h3>
          <p className="text-sm text-muted-foreground mb-4">
            Envoyez un message pour démarrer la conversation avec ce candidat.
          </p>
          <Textarea
            value={firstMessage}
            onChange={(e) => setFirstMessage(e.target.value)}
            placeholder="Bonjour ! J'ai bien reçu votre candidature et je souhaiterais échanger avec vous..."
            className="min-h-[140px] resize-none text-base"
          />
        </div>

        <Button
          variant="default"
          className="w-full text-base h-11"
          onClick={handleSendFirstMessage}
          disabled={!firstMessage.trim() || sending}
        >
          <MessageCircle className="mr-2 h-5 w-5" />
          {sending ? "Envoi..." : "Envoyer et contacter"}
        </Button>

        <p className="text-xs text-muted-foreground text-center">
          Le statut de la candidature passera automatiquement à &quot;Contacté&quot;
        </p>
      </div>
    );
  }

  // Contacted but no conversation found (should not happen)
  return (
    <div className="rounded-lg border border-dashed py-16 text-center">
      <p className="text-base text-muted-foreground">
        Aucune conversation trouvée
      </p>
      <Button
        variant="outline"
        className="mt-4"
        onClick={() => router.push("/messages")}
      >
        Voir toutes les conversations
      </Button>
    </div>
  );
}
