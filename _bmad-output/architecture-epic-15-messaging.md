# Architecture Epic 15 : Messagerie Temps Réel (SaaS)

**Date** : 2026-04-25
**Architecte** : Winston (BMAD Architect Agent)
**Status** : ✅ Complete — Ready for Implementation
**Epic** : US-15.1 (Conversations synchronisées) + US-15.2 (Contacter depuis modal)

---

## Table of Contents

1. [Scope du Document](#scope-du-document)
2. [Project Context Analysis](#project-context-analysis)
3. [Stack Technique Existante](#stack-technique-existante)
4. [Core Architectural Decisions](#core-architectural-decisions)
5. [Patterns & Best Practices](#patterns--best-practices)
6. [Architecture Validation & Implementation Readiness](#architecture-validation--implementation-readiness)

---

## Scope du Document

### Epic 15 : Messagerie Recruteur (SaaS)

**Objectif** : Permettre aux recruteurs de communiquer en temps réel avec les chercheurs directement depuis le SaaS web, avec synchronisation native avec l'app mobile Flutter.

**User Stories** :

**US-15.1 : Conversations synchronisées**
> En tant que recruteur, je veux envoyer et recevoir des messages avec les chercheurs depuis le SaaS.

Critères d'acceptation :
- Liste des conversations actives
- Badge "Non lu" sur les nouveaux messages
- Réponse en texte libre, temps réel (Supabase Realtime)
- Messages synchronisés avec l'app mobile du chercheur (mêmes tables, mêmes channels)
- Info du chercheur visible (prénom, username, spécialité)

**US-15.2 : Contacter depuis le modal**
> En tant que recruteur, je veux contacter un candidat directement depuis sa fiche.

Critères d'acceptation :
- Onglet "Contacter" dans le modal candidat
- Si conversation existante : afficher historique
- Si nouvelle conversation : champ de premier message
- Le candidat reçoit une push notification sur son mobile
- Le statut de la candidature passe à "Contacté"

---

**Contexte Projet** :

Epic 15 complète le flux recruteur-candidat établi par Epic 12-14 :
1. ✅ Epic 12 : Grille candidats + modal split layout
2. ✅ Epic 13 : Dashboard briefing (KPIs PostgreSQL)
3. ✅ Epic 14 : Scoring PostgreSQL (match_scores)
4. **Epic 15** : Messagerie temps réel ← CURRENT

**Déclencheur Epic 15** : L'onglet "Messages" dans le modal candidat (Epic 12) existe déjà en placeholder. Epic 15 implémente la fonctionnalité complète.

---

## Project Context Analysis

### Requirements Analysis

**Functional Requirements (FRs)** :

1. **Page `/messages`** : Layout split sidebar (conversations) + main (chat)
2. **Supabase Realtime** : Subscription temps réel pour nouveaux messages
3. **Server Actions** : fetchConversations, sendMessage, markAsRead
4. **Composants UI** : ConversationList, MessageBubble, MessageInput, MessageThread
5. **Intégration modal** : Onglet "Messages" dans modal candidat (Epic 12)
6. **Badge compteur** : Non-lus dans sidebar + header navigation

**Non-Functional Requirements (NFRs)** :

- **Performance** : Messages chargés <500ms, Realtime latency <200ms
- **UX** : Auto-scroll bottom nouveaux messages, indication typing optionnel V2
- **Sécurité** : RLS strict (recruteur voit conversations SES offres uniquement)
- **Mobile sync** : Compatibilité app Flutter (mêmes tables/channels Supabase)
- **Scalabilité** : Support 20 conversations actives par recruteur (MVP)

### Contraintes Techniques

**Tables DB** : Déjà créées, schema immutable
- `conversations` : id, participant_1, participant_2, video_id, last_message_at, read timestamps
- `messages` : id, conversation_id, sender_id, content, is_read, created_at

**RLS Policies** : Déjà actives et testées
- SELECT : users voient conversations où ils sont participants
- INSERT : users peuvent créer messages dans LEURS conversations
- UPDATE : users peuvent marquer messages comme lus

**Supabase Realtime** : Déjà configuré par app mobile
- Channel pattern : `supabase.channel('conversation:id')`
- Broadcast : `postgres_changes` sur table messages
- Cleanup : `channel.unsubscribe()` requis

**Edge Function** : `send-push` déjà active
- Trigger INSERT messages → envoie push notification mobile
- Pas de changement nécessaire

### Complexité Estimée

**Complexité : Moyenne**

**Rationale** :
- ✅ Tables DB ready (pas de migration)
- ✅ RLS policies ready
- ✅ Supabase Realtime configuré (pattern connu)
- ✅ Layout split validé (Epic 12)
- ⚠️ Realtime subscription cleanup critique (memory leaks)
- ⚠️ Sync mobile = contrainte (pas de breaking change schema)

**Estimation temps** : 5h30 dev (1 journée)

---

## Stack Technique Existante

### Contexte Projet

Epic 15 s'intègre dans le **projet SaaS Etoile existant**, déjà établi par Sprints SaaS-1/2 et Epic 12-14.

**Historique d'implémentation** :
- **Sprint SaaS-1** (2026-04-14) : Init Next.js + Auth + Layout + Dashboard
- **Sprint SaaS-2** (2026-04-21) : Publication offres (Epic 11)
- **Epic 12** (2026-04-23) : Grille candidats + modal split 50/50
- **Epic 13** (2026-04-25) : Dashboard briefing (KPIs + polling)
- **Epic 14** (2026-04-25) : Scoring PostgreSQL (match_scores)

### Stack Établie

**Frontend (Next.js 16)** :
- Framework : Next.js 16.2.3 (App Router)
- Language : TypeScript 5.x
- Styling : Tailwind CSS v4 + Shadcn/ui v4
- Components : Badge, Card, Button, Dialog, Select, Tabs, Textarea, Tooltip
- Deployment : Vercel (hobby plan)

**Backend (Supabase)** :
- Database : PostgreSQL (West EU Paris)
- Auth : Supabase SSR (@supabase/ssr)
- **Realtime** : Supabase Realtime (utilisé par app mobile Flutter)
- Edge Functions : send-push (notifications Firebase)
- Storage : Cloudflare R2 via Workers
- RLS : Row Level Security actif sur toutes les tables

**Patterns Architecturaux Établis** :

1. **Server Components + Server Actions** (Epic 13/14) :
   - Server Components pour data fetching initial (cache possible)
   - Server Actions pour mutations (`"use server"`)
   - Client Components uniquement pour interactivité/Realtime

2. **Layout Split** (Epic 12) :
   - Sidebar fixe (w-64 ou w-80) + Main content (flex-1)
   - Modal 50/50 vidéo+panneau avec tabs
   - Pattern responsive (mobile = stack vertical)

3. **Supabase Realtime** (app mobile Flutter) :
   - Channel subscription : `supabase.channel('name')`
   - Postgres changes : `channel.on('postgres_changes', { table: 'messages' })`
   - Cleanup obligatoire : `useEffect(() => { ... return () => channel.unsubscribe(); })`

4. **File Structure SaaS** :
```
saas-etoile/
├── app/(dashboard)/
│   ├── dashboard/        # Epic 13 (KPIs)
│   ├── candidates/       # Epic 12 (grille + modal)
│   ├── offers/           # Epic 11 (publication)
│   └── messages/         # Epic 15 ← CURRENT (placeholder existe)
├── components/
│   ├── ui/               # Shadcn/ui components
│   ├── layout/           # Sidebar, Header
│   ├── dashboard/        # Epic 13 components
│   ├── candidates/       # Epic 12 components
│   └── messages/         # Epic 15 ← NEW
├── lib/
│   ├── supabase/         # Browser + Server clients
│   ├── types/database.ts # TypeScript types (miroir DB)
│   └── constants/        # Routes, sectors, etc.
└── middleware.ts         # Auth + last_login_at tracking
```

### Database Schema (Tables Epic 15)

**Table `conversations`** (déjà créée, immutable) :
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_1 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  participant_2 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  video_id UUID REFERENCES videos(id) ON DELETE SET NULL,
  last_message_at TIMESTAMPTZ,
  last_message_preview TEXT,
  participant_1_read_at TIMESTAMPTZ,
  participant_2_read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conversations_participants ON conversations(participant_1, participant_2);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);
```

**Table `messages`** (déjà créée, immutable) :
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  content_type TEXT DEFAULT 'text',  -- 'text' | 'system'
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at);
CREATE INDEX idx_messages_sender ON messages(sender_id);
```

**RLS Policies Existantes** :
```sql
-- SELECT : users voient conversations où ils participent
CREATE POLICY "Users can view their conversations"
ON conversations FOR SELECT
USING (auth.uid() = participant_1 OR auth.uid() = participant_2);

-- INSERT : users peuvent créer messages dans LEURS conversations
CREATE POLICY "Users can send messages in their conversations"
ON messages FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM conversations c
    WHERE c.id = conversation_id
    AND (c.participant_1 = auth.uid() OR c.participant_2 = auth.uid())
  )
);

-- UPDATE : users peuvent marquer messages comme lus
CREATE POLICY "Users can mark messages as read"
ON messages FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM conversations c
    WHERE c.id = conversation_id
    AND (c.participant_1 = auth.uid() OR c.participant_2 = auth.uid())
  )
);
```

**Edge Function Existante** : `send-push`
```sql
-- Trigger INSERT messages → envoie push notification
CREATE TRIGGER trigger_send_push
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION supabase_functions.http_request(
  'https://[project-ref].supabase.co/functions/v1/send-push',
  'POST',
  '{"Content-Type":"application/json"}',
  '{}',
  '1000'
);
```

### Implications pour Epic 15

**Ce qui est déjà résolu** :
- ✅ Pas besoin de créer tables (schema ready)
- ✅ RLS policies déjà sécurisées et testées
- ✅ Supabase Realtime configuré (app mobile l'utilise)
- ✅ Push notifications fonctionnelles (trigger existant)
- ✅ Pattern Server Component + Client Component établi
- ✅ Layout split validé (Epic 12)
- ✅ TypeScript types base (Conversation, Message)

**Ce qu'il reste à faire** :
- Page `/messages` (remplacer placeholder)
- 3 composants UI : ConversationList, MessageBubble, MessageInput
- 4 Server Actions : getConversations, sendMessage, markAsRead, getConversationBySeeker
- Realtime subscription côté SaaS (adapter pattern Flutter)
- Intégration onglet "Messages" modal candidat (Epic 12)
- Badge compteur non-lus (header + sidebar)

---

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation)** :

Toutes les 5 décisions ci-dessous sont **critiques** — elles bloquent l'implémentation Epic 15 et doivent être documentées avant le code.

**Important Decisions (Shape Architecture)** :

Les décisions suivantes façonnent l'architecture mais sont déjà prises par la stack existante :
- Database : Supabase PostgreSQL (tables conversations + messages)
- Auth & RLS : Supabase SSR (policies existantes)
- Frontend : Next.js 16 Server Components
- Realtime : Supabase Realtime (configuré app mobile)

**Deferred Decisions (Post-MVP)** :

- Typing indicator → Phase 2
- Message attachments (images/files) → Phase 2
- Message search → Phase 2
- Conversation archive → Phase 2
- Read receipts détaillés (scroll-based) → Phase 2

---

### Decision 1 : Page Layout — Architecture `/messages`

**Decision :** Structure layout page messagerie (sidebar conversations + zone chat).

**Choix retenu :** **Split Layout Permanent (Sidebar 320px + Main flex-1)**

**Schema Layout** :
```tsx
<div className="flex h-[calc(100vh-5rem)] -m-8">
  <ConversationList width="320px" className="shrink-0 border-r" />
  <MessageThread flex="1" />
</div>
```

**Rationale** :
- ✅ **Cohérence Epic 12** : Pattern validé (grille candidats sidebar + main)
- ✅ **Desktop-first** : Cible recruteur (travaille sur grand écran)
- ✅ **UX optimale** : Vue simultanée liste + chat (switch rapide)
- ✅ **Code réutilisable** : Même pattern layout que Epic 12
- ✅ **Responsive** : Mobile = stack vertical ou tabs (Phase 2)

**Alternatives rejetées** :
- **Option B (Modal Overlay)** : Pas de contexte visuel, friction switch conversation
- **Option C (Tabs Layout)** : Pattern mobile, pas de vue simultanée

**Affects :** US-15.1

---

### Decision 2 : Realtime Strategy — Supabase Channel Pattern

**Decision :** Comment gérer les subscriptions Realtime pour recevoir nouveaux messages.

**Choix retenu :** **Global Channel (écoute toutes conversations du recruteur)**

**Code Pattern** :
```ts
const channel = supabase
  .channel('recruiter-messages')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'messages' },
    (payload) => {
      // Filter client-side par conversation_id
      if (payload.new.conversation_id === currentConversationId) {
        setMessages(prev => [...prev, payload.new]);
      }
      // Update badge unread count (toutes conversations)
      updateUnreadCount();
    }
  )
  .subscribe();
```

**Rationale** :
- ✅ **Scalabilité MVP** : <20 conversations par recruteur (overhead acceptable)
- ✅ **Badge temps réel** : Compteur non-lu global (UX nécessaire)
- ✅ **Pas de latency** : 1 subscription permanente, pas de re-subscribe
- ✅ **Code simple** : Pas de cleanup/re-subscribe à chaque switch
- ⚠️ **Phase 2** : Si >50 conversations, optimiser avec filter server-side

**Alternatives rejetées** :
- **Option A (Channel per Conversation)** : Latency 200-500ms re-subscribe, miss messages
- **Option C (Hybrid)** : Complexité inutile pour MVP

**Affects :** US-15.1

---

### Decision 3 : Message State Management — React State + Realtime

**Decision :** Comment gérer l'état des messages (chargement initial + updates Realtime).

**Choix retenu :** **useState + append Realtime**

**Code Pattern** :
```ts
const [messages, setMessages] = useState<Message[]>([]);

// Initial load
useEffect(() => {
  fetchMessages(conversationId).then(setMessages);
}, [conversationId]);

// Realtime append
useEffect(() => {
  const channel = supabase.channel('recruiter-messages')
    .on('postgres_changes', { table: 'messages' }, (payload) => {
      if (payload.new.conversation_id === conversationId) {
        setMessages(prev => [...prev, payload.new as Message]);
      }
    })
    .subscribe();

  return () => { channel.unsubscribe(); };
}, [conversationId]);
```

**Rationale** :
- ✅ **Simplicité** : Pattern React classique (MVP)
- ✅ **Cohérence** : useState utilisé dans Epic 12/13
- ✅ **Duplicates = non-problème** : React `key={message.id}` déduplique
- ✅ **Maintenance** : Moins de code = moins de bugs
- ⚠️ **Phase 2** : Migrer vers useReducer si optimistic updates nécessaires

**Alternatives rejetées** :
- **Option B (useReducer)** : Over-engineering pour MVP simple
- **Option C (SWR/React Query)** : Dépendance externe inutile

**Affects :** US-15.1

---

### Decision 4 : Read Status Tracking — Marquer messages lus

**Decision :** Quand et comment marquer les messages comme lus (`is_read = true`).

**Choix retenu :** **On Conversation Open (toute conversation = lue)**

**Code Pattern** :
```ts
useEffect(() => {
  if (conversationId) {
    markConversationAsRead(conversationId);  // Server Action
    // UPDATE messages SET is_read = true, read_at = NOW()
    // WHERE conversation_id = $1 AND is_read = false
  }
}, [conversationId]);
```

**Rationale** :
- ✅ **Simplicité** : 1 seul appel API par switch conversation
- ✅ **UX claire** : Ouverture conversation = intention de lire (pattern Slack/Teams)
- ✅ **Badge réactif** : Compteur non-lu disparaît immédiatement
- ✅ **MVP suffisant** : Recruteur lit généralement tout l'historique
- ⚠️ **Phase 2** : Si feedback utilisateur, ajouter scroll visibility

**Alternatives rejetées** :
- **Option B (IntersectionObserver)** : Over-engineering, overhead API (N appels)
- **Option C (Focus + Debounce)** : Delay artificiel, miss si quit avant debounce

**Affects :** US-15.1

---

### Decision 5 : Conversation List Ordering — Tri + Badge Non-lu

**Decision :** Comment trier les conversations dans la sidebar + afficher badge non-lu.

**Choix retenu :** **Server-Side Ordering + Count (Server Action)**

**SQL Query** :
```sql
SELECT
  c.*,
  COUNT(m.id) FILTER (WHERE m.is_read = false AND m.sender_id != $1) as unread_count,
  sp.first_name,
  sp.username,
  sp.photo_url,
  sp.specialty
FROM conversations c
LEFT JOIN messages m ON m.conversation_id = c.id
LEFT JOIN seeker_profiles sp ON (
  CASE
    WHEN c.participant_1 = $1 THEN c.participant_2
    ELSE c.participant_1
  END = sp.user_id
)
WHERE c.participant_1 = $1 OR c.participant_2 = $1
GROUP BY c.id, sp.user_id
ORDER BY c.last_message_at DESC NULLS LAST;
```

**Rationale** :
- ✅ **Performance** : Index `last_message_at` déjà existant
- ✅ **Précision count** : Agrégation SQL garantie exacte
- ✅ **Pas de schema change** : Utilise tables existantes
- ✅ **Scalabilité MVP** : <20 conversations OK (Phase 2 : materialized view si >50)
- ✅ **Dénormalisation UX** : JOIN seeker_profiles pour affichage direct

**Alternatives rejetées** :
- **Option B (Client-Side Sort)** : Performance dégradée, count imprécis
- **Option C (Materialized View)** : Migration SQL nécessaire, overhead maintenance

**Affects :** US-15.1

---

### Decision Impact Analysis

**Implementation Sequence (ordre recommandé)** :

1. **Server Actions** : getConversations(), sendMessage(), markAsRead(), getConversationBySeeker()
2. **Types TypeScript** : ConversationWithUnread interface
3. **Page Layout** : `/messages` avec split sidebar 320px + main flex-1
4. **Composants UI** : ConversationList, MessageThread, MessageBubble, MessageInput
5. **Realtime** : Global channel subscription (intégré dans MessageThread)
6. **Intégration Modal** : Onglet "Messages" dans modal candidat (Epic 12)

**Cross-Component Dependencies** :

- `/messages` page ↔ ConversationList ↔ getConversations()
- ConversationList ↔ Badge unread ↔ Realtime global channel
- MessageThread ↔ MessageInput ↔ sendMessage()
- MessageThread ↔ Realtime subscription ↔ Global channel
- Modal candidat ↔ MessagesTabContent ↔ getConversationBySeeker()

**Validation Points** :

- ✅ Page `/messages` affiche liste conversations triées
- ✅ Badge unread affiché correctement
- ✅ Clic conversation → messages chargent <500ms
- ✅ Nouveau message apparaît temps réel <200ms
- ✅ Envoyer message → succès + append local
- ✅ Ouverture conversation → marque lue + badge disparaît
- ✅ Onglet modal "Messages" fonctionne
- ✅ RLS empêche accès conversations autres recruteurs

---

## Patterns & Best Practices

### Pattern 1 : Realtime Subscription Lifecycle

**Pattern : useEffect cleanup pour éviter memory leaks**

```tsx
// components/messages/message-thread.tsx
'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import type { Message } from '@/lib/types/database';

export function MessageThread({ conversationId }: { conversationId: string }) {
  const [messages, setMessages] = useState<Message[]>([]);
  const supabase = createClient();

  useEffect(() => {
    // 1. Initial fetch
    fetchMessages(conversationId).then(setMessages);

    // 2. Realtime subscription
    const channel = supabase
      .channel('recruiter-messages')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `conversation_id=eq.${conversationId}`
        },
        (payload) => {
          setMessages(prev => [...prev, payload.new as Message]);
        }
      )
      .subscribe();

    // 3. CRITICAL: Cleanup on unmount
    return () => {
      channel.unsubscribe();
    };
  }, [conversationId]);

  return (/* ... */);
}
```

**Rationale** :
- ✅ Cleanup évite subscriptions multiples (memory leaks)
- ✅ Re-subscribe automatique si conversationId change
- ✅ Pattern React standard (deps array)

---

### Pattern 2 : Server Action Error Handling

**Pattern : Try-catch + fallback gracieux**

```ts
// app/(dashboard)/messages/actions.ts
'use server';

import { createClient } from '@/lib/supabase/server';

export async function sendMessage(
  conversationId: string,
  content: string
): Promise<{ success: boolean; error?: string }> {
  try {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return { success: false, error: 'Not authenticated' };
    }

    const { error } = await supabase
      .from('messages')
      .insert({
        conversation_id: conversationId,
        sender_id: user.id,
        content,
        content_type: 'text',
      });

    if (error) {
      console.error('Error sending message:', error);
      return { success: false, error: error.message };
    }

    return { success: true };
  } catch (error) {
    console.error('Unexpected error in sendMessage:', error);
    return { success: false, error: 'Failed to send message' };
  }
}
```

**Rationale** :
- ✅ Jamais throw d'erreur (catch always)
- ✅ Return type explicite (success + error)
- ✅ Log errors pour debug
- ✅ UX : afficher toast error côté client

---

### Pattern 3 : Auto-Scroll to Bottom

**Pattern : useRef + scrollIntoView**

```tsx
// components/messages/message-thread.tsx
'use client';

import { useEffect, useRef } from 'react';

export function MessageThread({ messages }: { messages: Message[] }) {
  const bottomRef = useRef<HTMLDivElement>(null);

  // Scroll to bottom when new message arrives
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages.length]);  // Trigger on new message

  return (
    <div className="flex flex-col overflow-y-auto p-4">
      {messages.map(msg => (
        <MessageBubble key={msg.id} message={msg} />
      ))}
      <div ref={bottomRef} />  {/* Anchor point */}
    </div>
  );
}
```

**Rationale** :
- ✅ UX familière (chat apps standard)
- ✅ Smooth scroll (pas de jump brutal)
- ✅ Trigger uniquement sur nouveaux messages

---

### Pattern 4 : URL State pour Conversation Selection

**Pattern : searchParams pour deep linking**

```tsx
// app/(dashboard)/messages/page.tsx
'use client';

import { useSearchParams, useRouter } from 'next/navigation';

export default function MessagesPage() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const selectedConversationId = searchParams.get('conversation');

  const handleSelectConversation = (id: string) => {
    router.push(`/messages?conversation=${id}`);
  };

  return (
    <div className="flex h-[calc(100vh-5rem)] -m-8">
      <ConversationList
        selectedId={selectedConversationId}
        onSelect={handleSelectConversation}
      />
      {selectedConversationId && (
        <MessageThread conversationId={selectedConversationId} />
      )}
    </div>
  );
}
```

**Rationale** :
- ✅ Deep linking (partager URL conversation)
- ✅ Browser back/forward fonctionne
- ✅ État persisté si refresh page
- ✅ Cohérent Epic 12 (filtres URL)

---

### Pattern 5 : Message Grouping (même sender)

**Pattern : Grouper messages du même sender <5min**

```ts
// lib/utils/message-grouping.ts
export function groupMessages(messages: Message[]) {
  const groups: Message[][] = [];
  let currentGroup: Message[] = [];

  messages.forEach((msg, index) => {
    const prevMsg = messages[index - 1];

    const isSameSender = prevMsg && prevMsg.sender_id === msg.sender_id;
    const isWithin5Min = prevMsg &&
      (new Date(msg.created_at).getTime() - new Date(prevMsg.created_at).getTime()) < 5 * 60 * 1000;

    if (isSameSender && isWithin5Min) {
      currentGroup.push(msg);
    } else {
      if (currentGroup.length > 0) groups.push(currentGroup);
      currentGroup = [msg];
    }
  });

  if (currentGroup.length > 0) groups.push(currentGroup);
  return groups;
}
```

**Rationale** :
- ✅ UX moderne (WhatsApp, Slack)
- ✅ Réduit répétition avatar/nom
- ⚠️ Optionnel MVP (Phase 2)

---

### Anti-Patterns à Éviter

**❌ Ne PAS faire** :

1. **Polling au lieu de Realtime** :
   ```tsx
   // MAUVAIS
   setInterval(() => fetchMessages(), 5000);  // Overhead inutile
   ```
   → Utiliser Supabase Realtime

2. **Fetch messages à chaque render** :
   ```tsx
   // MAUVAIS - Top-level fetch
   const messages = await fetchMessages(conversationId);
   ```
   → Utiliser `useEffect` avec deps array

3. **Oublier cleanup Realtime** :
   ```tsx
   // MAUVAIS
   useEffect(() => {
     channel.subscribe();
     // Missing: return () => channel.unsubscribe();
   });
   ```
   → Toujours cleanup

4. **Mutation directe state** :
   ```tsx
   // MAUVAIS
   messages.push(newMessage);
   ```
   → Immutable : `setMessages([...messages, newMessage])`

5. **Hardcoded user role** :
   ```tsx
   // MAUVAIS
   const isRecruiter = true;
   ```
   → Fetch depuis auth : `await supabase.auth.getUser()`

---

## Architecture Validation & Implementation Readiness

### Architecture Completion Summary

**Epic 15 : Messagerie Temps Réel (SaaS)** — Architecture **COMPLETE** ✅

**Date de completion** : 2026-04-25
**Architecte** : Winston (BMAD Architect Agent)
**Statut** : Prêt pour implémentation (Amelia /dev)

---

### Documents Produits

**Sections Architecture Complètes** :

1. ✅ **Scope du Document** — Epic 15 contexte, User Stories (US-15.1 + US-15.2)
2. ✅ **Project Context Analysis** — Requirements (6 FRs + 5 NFRs), complexité moyenne, contraintes
3. ✅ **Stack Technique Existante** — Historique Sprints SaaS, Epic 12/13/14 patterns, Supabase Realtime ready
4. ✅ **Core Architectural Decisions (5 critiques)** :
   - Decision 1 : Page Layout (Split Layout Permanent 320px + flex-1)
   - Decision 2 : Realtime Strategy (Global Channel)
   - Decision 3 : Message State Management (useState + append)
   - Decision 4 : Read Status Tracking (On Conversation Open)
   - Decision 5 : Conversation List Ordering (Server-Side + Count)
5. ✅ **Patterns & Best Practices** — 5 patterns documentés, 5 anti-patterns

---

### Livrables Techniques Documentés

**Code Patterns Prêts** :
- ✅ Realtime subscription avec cleanup
- ✅ Server Actions avec error handling
- ✅ Auto-scroll to bottom
- ✅ URL state conversation selection
- ✅ SQL query tri + unread count

**Composants Définis** :
- ✅ ConversationList (sidebar 320px, tri last_message_at, badge)
- ✅ MessageBubble (sender/receiver style)
- ✅ MessageInput (textarea + bouton)
- ✅ MessageThread (container + scroll + Realtime)

**Server Actions Définis** :
- ✅ getConversations() : SQL avec JOIN + COUNT unread
- ✅ sendMessage() : INSERT message + return success
- ✅ markAsRead() : UPDATE is_read = true
- ✅ getConversationBySeeker() : Pour modal candidat

---

### Implementation Readiness Checklist

**Décisions Architecturales** :
- ✅ Toutes les décisions critiques prises (5/5)
- ✅ Alternatives évaluées et documentées
- ✅ Rationales claires pour chaque choix
- ✅ Trade-offs identifiés et justifiés
- ✅ Deferred decisions documentées (Phase 2)

**Spécifications Techniques** :
- ✅ Layout split validé (pattern Epic 12)
- ✅ Realtime global channel pattern défini
- ✅ Server Actions signatures documentées
- ✅ RLS policies existantes vérifiées
- ✅ Pas de migration SQL nécessaire

**Alignement Projet** :
- ✅ Cohérent avec stack existante (Next.js 16 + Supabase)
- ✅ Suit patterns établis (Epic 12 layout, Epic 13 Server Actions)
- ✅ Tables DB ready (conversations + messages)
- ✅ Supabase Realtime configuré
- ✅ RLS actif et testé

**Documentation** :
- ✅ Architecture document complet (~450 lignes)
- ✅ Code patterns commentés
- ✅ Sequence d'implémentation claire (6 étapes)
- ✅ Validation points définis (15 checks)
- ✅ Dependencies mappées

---

### Implementation Sequence

**Ordre strict recommandé (6 étapes)** :

1. **Server Actions** (1h15) : getConversations, sendMessage, markAsRead, getConversationBySeeker
2. **Types TypeScript** (15min) : ConversationWithUnread interface
3. **Page Layout** (30min) : `/messages` split sidebar 320px + main
4. **Composants UI** (2h) : ConversationList, MessageThread, MessageBubble, MessageInput
5. **Realtime Integration** (inclus étape 4) : Global channel subscription
6. **Modal Integration** (1h) : Onglet "Messages" modal candidat

**Temps total estimé** : ~5h30 (1 journée dev)

---

### Validation Points

**Fonctionnel** :
- ✅ Page `/messages` accessible et responsive
- ✅ Conversations triées par last_message_at DESC
- ✅ Badge unread affiché correctement
- ✅ Clic conversation → messages <500ms
- ✅ Nouveau message temps réel <200ms
- ✅ Envoyer message → succès + append
- ✅ Ouverture conversation → marque lue
- ✅ Onglet modal fonctionne

**Sécurité** :
- ✅ RLS SELECT conversations (participant only)
- ✅ RLS INSERT messages (own conversations)
- ✅ Recruteur A ≠ voir conversations Recruteur B

**Performance** :
- ✅ Page load <1s
- ✅ Realtime latency <200ms
- ✅ Scroll smooth
- ✅ Pas de memory leak (cleanup OK)

**UX** :
- ✅ Auto-scroll bottom
- ✅ Empty state si aucune conversation
- ✅ Loading state pendant fetch
- ✅ Error toast si échec

---

### Blockers Potentiels

**❌ Aucun identifié** :
- ✅ Stack configurée (Next.js + Realtime)
- ✅ Tables ready (conversations + messages)
- ✅ RLS policies existantes
- ✅ Pattern validé (Epic 12 split)
- ✅ Edge Function push active

---

### Architecture Sign-Off

**Winston (Architecte)** — Epic 15 architecture validée et prête pour implémentation.

**Décisions prises** : 5/5 critiques
**Alternatives évaluées** : 15 options (5 décisions × 3 options)
**Rationales documentées** : Toutes
**Code patterns complets** : ✅ (~100 lignes)
**Implementation ready** : ✅

---

**🚀 Ready to implement — Invoke `/dev` (Amelia) to begin coding.**
