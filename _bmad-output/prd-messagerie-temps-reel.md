---
status: validated
date: 2026-02-10
author: John (PM)
projectName: Etoile Mobile App
feature: Messagerie Temps Reel - Activation & Finalisation
priority: haute
sprint: 8 (post Feed par Profil)
---

# PRD : Messagerie Temps Reel - Activation & Finalisation

## Contexte

La messagerie de l'app Etoile est implementee a 90% (models, repositories, BLoC, pages). Le code inclut deja les subscriptions Supabase Realtime et l'UI optimistic. Cependant, le **Realtime n'est pas active cote Supabase** et la **liste des conversations ne se met pas a jour en temps reel**.

## Probleme

1. Les messages envoyes n'arrivent pas en temps reel chez le destinataire (Realtime non publie)
2. La liste des conversations ne reflète pas les nouveaux messages sans rafraichissement manuel
3. Le flow complet n'a jamais ete teste entre 2 utilisateurs

---

## Gap 1 : Activer Supabase Realtime

### Description
Activer la publication Realtime sur les tables `messages` et `conversations` pour que les subscriptions existantes dans `MessageRepository.subscribeToMessages()` fonctionnent.

### Action requise
Migration SQL :
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE conversations;
```

### Criteres d'acceptation
- [ ] Les inserts dans `messages` declenchent les callbacks Realtime
- [ ] Les updates dans `conversations` (last_message_at) sont diffuses

---

## Gap 2 : Liste des conversations en temps reel

### Description
La `ConversationsPage` actuelle charge les conversations une seule fois dans `initState()` et via pull-to-refresh. Elle doit ecouter les changements en temps reel pour :
- Afficher un nouveau message recu (mise a jour du preview + badge unread)
- Reordonner la liste quand un message arrive dans une conversation existante
- Afficher une nouvelle conversation initiee par un autre utilisateur

### Solution technique
Ajouter une subscription Realtime sur la table `conversations` dans `ConversationsPage` :
- Ecouter les events `UPDATE` (nouveau message dans conversation existante)
- Ecouter les events `INSERT` (nouvelle conversation)
- Rafraichir la liste complete a chaque event (simple et fiable)

### Criteres d'acceptation
- [ ] Un nouveau message recu met a jour le preview et le badge instantanement
- [ ] L'ordre de la liste change quand un message arrive
- [ ] Une nouvelle conversation apparait sans refresh manuel
- [ ] La subscription est correctement fermee lors du dispose

---

## Gap 3 : Test end-to-end

### Description
Valider le flow complet avec 2 comptes utilisateur :
1. User A clique "Postuler"/"Contacter" dans le feed
2. La conversation est creee et visible dans la liste des 2 users
3. User A envoie un message
4. User B recoit le message en temps reel
5. User B repond
6. User A recoit la reponse en temps reel
7. Les badges unread fonctionnent correctement

### Comptes de test
- Compte recruteur : emma@gmail.com (entreprise UDI, secteur BTP)
- Compte chercheur : a creer ou utiliser un existant

---

## Hors scope (v1)

- Notifications push (Sprint 9)
- Bloquer utilisateur (Sprint 9)
- Signaler conversation (Sprint 9)
- Envoi d'images/fichiers
- Indicateur "en train d'ecrire" (typing indicator)
- Messages vocaux

---

## Fichiers concernes

| Fichier | Action |
|---------|--------|
| `supabase/migrations/nouveau_fichier.sql` | Migration Realtime |
| `conversations_page.dart` | Ajouter subscription Realtime |
| `message_repository.dart` | Ajouter methode subscribe conversations (si besoin) |

---

## Estimation

| Gap | Effort | Risque |
|-----|--------|--------|
| Realtime SQL | 5 min | Faible - configuration standard |
| Conversations temps reel | 30 min | Faible - pattern deja utilise dans MessageBloc |
| Test E2E | 15 min | Moyen - necessite 2 sessions navigateur |

**Total estime : ~50 min**

---

*PRD cree par John (PM) le 2026-02-10*
