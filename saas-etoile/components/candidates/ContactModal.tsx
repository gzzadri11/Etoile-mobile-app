"use client";

import { useEffect, useRef, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { X } from "lucide-react";

interface ContactModalProps {
  seekerId: string;
  seekerName: string;
  seekerUsername?: string | null;
  videoId: string;
  applicationId: string;
  onStatusChanged: () => void;
  onClose: () => void;
}

interface Message {
  id: string;
  sender_id: string;
  content: string;
  created_at: string;
}

export function ContactModal({
  seekerId,
  seekerName,
  seekerUsername,
  videoId,
  applicationId,
  onStatusChanged,
  onClose,
}: ContactModalProps) {
  const supabase = useRef(createClient()).current;
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [conversationId, setConversationId] = useState<string | null>(null);
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  useEffect(() => {
    async function init() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;
      setCurrentUserId(user.id);

      // Find or create conversation
      const { data: existing } = await supabase
        .from("conversations")
        .select("id")
        .or(
          `and(participant_1.eq.${user.id},participant_2.eq.${seekerId}),` +
          `and(participant_1.eq.${seekerId},participant_2.eq.${user.id})`
        )
        .limit(1)
        .maybeSingle();

      let convId = existing?.id;

      if (!convId) {
        const { data: created } = await supabase
          .from("conversations")
          .insert({ participant_1: user.id, participant_2: seekerId, video_id: videoId })
          .select("id")
          .single();
        convId = created?.id;

        // First contact: update application status
        if (convId) {
          await supabase.from("applications").update({ status: "contacted" }).eq("id", applicationId);
          onStatusChanged();
        }
      }

      if (!convId) { setLoading(false); return; }

      setConversationId(convId);

      // Load messages
      const { data: msgs } = await supabase
        .from("messages")
        .select("id, sender_id, content, created_at")
        .eq("conversation_id", convId)
        .order("created_at", { ascending: true });
      setMessages(msgs ?? []);
      setLoading(false);

      // Realtime subscription
      supabase
        .channel(`contact-modal-${convId}`)
        .on(
          "postgres_changes",
          { event: "INSERT", schema: "public", table: "messages", filter: `conversation_id=eq.${convId}` },
          (payload) => setMessages((prev) => [...prev, payload.new as Message])
        )
        .subscribe();
    }
    init();

    return () => {
      supabase.removeAllChannels();
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function sendMessage() {
    if (!input.trim() || !conversationId || !currentUserId) return;
    const text = input.trim();
    setInput("");
    await supabase.from("messages").insert({
      conversation_id: conversationId,
      sender_id: currentUserId,
      content: text,
    });
    await supabase
      .from("conversations")
      .update({ updated_at: new Date().toISOString() })
      .eq("id", conversationId);
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLTextAreaElement>) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  }

  return (
    <div className="fixed inset-0 z-[300] flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="flex h-[70vh] w-[90vw] max-w-[560px] flex-col overflow-hidden rounded-2xl bg-white shadow-xl">
        {/* Header */}
        <div className="flex items-center gap-3 border-b border-border px-5 py-4">
          <div className="flex-1">
            <div className="text-sm font-semibold text-text-primary">{seekerName}</div>
            {seekerUsername && (
              <div className="text-xs text-text-tertiary">@{seekerUsername}</div>
            )}
          </div>
          <button
            onClick={onClose}
            className="rounded-lg p-1 text-text-tertiary transition-colors hover:bg-bg-muted hover:text-text-primary"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Messages */}
        <div className="flex flex-1 flex-col gap-3 overflow-y-auto p-5">
          {loading && (
            <div className="flex flex-1 items-center justify-center">
              <div className="h-5 w-5 animate-spin rounded-full border-2 border-border border-t-accent" />
            </div>
          )}
          {!loading && messages.length === 0 && (
            <div className="mt-10 text-center text-sm text-text-tertiary">
              Démarrez la conversation avec {seekerName.split(" ")[0]}.
            </div>
          )}
          {messages.map((msg) => {
            const isMe = msg.sender_id === currentUserId;
            return (
              <div key={msg.id} className={`flex ${isMe ? "justify-end" : "justify-start"}`}>
                <div
                  className={`max-w-[72%] rounded-xl px-3.5 py-2.5 text-sm leading-relaxed ${
                    isMe
                      ? "rounded-br-sm bg-accent text-white"
                      : "rounded-bl-sm bg-bg-muted text-text-primary"
                  }`}
                >
                  {msg.content}
                </div>
              </div>
            );
          })}
          <div ref={bottomRef} />
        </div>

        {/* Input */}
        <div className="flex gap-2.5 border-t border-border px-4 py-3">
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Écrivez votre message…"
            rows={1}
            className="flex-1 resize-none rounded-lg border border-border px-3.5 py-2.5 font-sans text-sm outline-none transition-colors focus:border-accent"
          />
          <button
            onClick={sendMessage}
            disabled={!input.trim()}
            className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-accent text-white transition-opacity disabled:opacity-40"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  );
}
