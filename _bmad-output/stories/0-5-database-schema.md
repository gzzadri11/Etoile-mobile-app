# Story 0.5: Schema Base de Donnees Initial

---
status: complete
epic: 0 - Fondation Technique
sprint: 1
points: 8
created: 2026-02-02
completed: 2026-02-02
author: John (PM)
developer: Amelia (Dev)
---

## Story

**As a** developpeur,
**I want** les tables de base creees dans PostgreSQL via Supabase,
**So that** les fonctionnalites d'authentification et de profil puissent etre developpees.

---

## Acceptance Criteria

### AC-1: Extensions PostgreSQL
**Given** un projet Supabase configure
**When** le schema est deploye
**Then** les extensions `uuid-ossp` et `pgcrypto` sont activees

### AC-2: Tables Core
**Given** les extensions sont activees
**When** je cree les tables principales
**Then** les tables `users` et `categories` existent avec tous leurs champs

### AC-3: Tables Profils
**Given** la table `users` existe
**When** je cree les tables de profil
**Then** les tables `seeker_profiles` et `recruiter_profiles` existent avec FK vers users

### AC-4: Tables Contenu
**Given** les tables core existent
**When** je cree les tables de contenu
**Then** les tables `videos` et `video_views` existent avec tous les index

### AC-5: Tables Communication
**Given** la table `users` existe
**When** je cree les tables de messagerie
**Then** les tables `conversations` et `messages` existent

### AC-6: Tables Monetisation
**Given** la table `users` existe
**When** je cree les tables de paiement
**Then** les tables `subscriptions` et `purchases` existent

### AC-7: Tables Moderation
**Given** la table `users` existe
**When** je cree les tables de moderation
**Then** les tables `blocks` et `reports` existent

### AC-8: Tables Utilitaires
**Given** la table `users` existe
**When** je cree les tables utilitaires
**Then** les tables `push_tokens` et `audit_logs` existent

### AC-9: Triggers Updated_at
**Given** toutes les tables sont creees
**When** je configure les triggers
**Then** `updated_at` est automatiquement mis a jour sur modification

### AC-10: Row Level Security
**Given** toutes les tables sont creees
**When** j'active RLS
**Then** RLS est active sur toutes les tables sensibles avec policies de base

---

## Tasks/Subtasks

### Task 1: Creer fichier migration SQL
- [x] 1.1 Creer le dossier `supabase/migrations/` a la racine du projet
- [x] 1.2 Creer le fichier de migration initial `20260202000000_initial_schema.sql`

### Task 2: Extensions PostgreSQL (AC-1)
- [x] 2.1 Ajouter `CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`
- [x] 2.2 Ajouter `CREATE EXTENSION IF NOT EXISTS "pgcrypto"`

### Task 3: Table users (AC-2)
- [x] 3.1 Creer la table `users` avec tous les champs (id, email, role, status, etc.)
- [x] 3.2 Ajouter les index sur email, role, status

### Task 4: Table categories (AC-2)
- [x] 4.1 Creer la table `categories` avec les champs (id, name, slug, parent_id, etc.)

### Task 5: Table seeker_profiles (AC-3)
- [x] 5.1 Creer la table `seeker_profiles` avec FK vers users
- [x] 5.2 Ajouter les index GIN sur categories et index sur region/city

### Task 6: Table recruiter_profiles (AC-3)
- [x] 6.1 Creer la table `recruiter_profiles` avec FK vers users
- [x] 6.2 Ajouter les index sur siret, sector, verification_status

### Task 7: Table videos (AC-4)
- [x] 7.1 Creer la table `videos` avec tous les champs
- [x] 7.2 Ajouter les index sur user, category, status, type
- [x] 7.3 Ajouter la contrainte unique pour 1 video active par chercheur par categorie

### Task 8: Table video_views (AC-4)
- [x] 8.1 Creer la table `video_views` avec FK vers videos et users
- [x] 8.2 Ajouter les index sur video_id, viewer_id, created_at

### Task 9: Table conversations (AC-5)
- [x] 9.1 Creer la table `conversations` avec les deux participants
- [x] 9.2 Ajouter les index et contrainte unique sur participant_1, participant_2

### Task 10: Table messages (AC-5)
- [x] 10.1 Creer la table `messages` avec FK vers conversations
- [x] 10.2 Ajouter les index sur conversation_id, sender_id, created_at

### Task 11: Table subscriptions (AC-6)
- [x] 11.1 Creer la table `subscriptions` avec tous les champs Stripe
- [x] 11.2 Ajouter les index sur user_id, stripe_subscription_id, status

### Task 12: Table purchases (AC-6)
- [x] 12.1 Creer la table `purchases` avec tous les champs
- [x] 12.2 Ajouter les index sur user_id, status

### Task 13: Table blocks (AC-7)
- [x] 13.1 Creer la table `blocks` avec contrainte unique
- [x] 13.2 Ajouter les index sur blocker_id, blocked_id

### Task 14: Table reports (AC-7)
- [x] 14.1 Creer la table `reports` avec toutes les FK
- [x] 14.2 Ajouter les index sur status, created_at

### Task 15: Table push_tokens (AC-8)
- [x] 15.1 Creer la table `push_tokens`
- [x] 15.2 Ajouter les index sur user_id et unique sur token

### Task 16: Table audit_logs (AC-8)
- [x] 16.1 Creer la table `audit_logs` avec colonnes JSONB
- [x] 16.2 Ajouter les index sur user_id, action, created_at

### Task 17: Triggers updated_at (AC-9)
- [x] 17.1 Creer la fonction `update_updated_at_column()`
- [x] 17.2 Creer les triggers sur users, seeker_profiles, recruiter_profiles, videos, subscriptions, push_tokens

### Task 18: Row Level Security (AC-10)
- [x] 18.1 Activer RLS sur toutes les tables sensibles (12 tables)
- [x] 18.2 Creer les policies de base (read own data, manage own videos, etc.)

### Task 19: Verification et Documentation
- [x] 19.1 Creer un fichier README dans supabase/ expliquant comment deployer
- [x] 19.2 Verifier la syntaxe SQL complete

---

## Dev Notes

### Architecture Reference
- Architecture document: `_bmad-output/architecture-etoile.md` (Section 3.3)
- Schema complet avec 14 tables defini dans l'architecture

### Tables a Creer (14 total)
1. `users` - Utilisateurs (chercheurs, recruteurs, admins)
2. `seeker_profiles` - Profils chercheurs d'emploi
3. `recruiter_profiles` - Profils recruteurs/entreprises
4. `categories` - Categories de metiers
5. `videos` - Videos (presentations et offres)
6. `video_views` - Tracking des vues
7. `conversations` - Conversations entre utilisateurs
8. `messages` - Messages individuels
9. `subscriptions` - Abonnements premium
10. `purchases` - Achats unitaires
11. `blocks` - Blocages entre utilisateurs
12. `reports` - Signalements
13. `push_tokens` - Tokens notifications push
14. `audit_logs` - Journal d'audit

### Conventions
- UUIDs pour toutes les PKs (uuid_generate_v4)
- Timestamps WITH TIME ZONE pour toutes les dates
- Soft delete via status='deleted' plutot que suppression physique
- Indexes sur toutes les FK et colonnes filtrees frequemment

### RLS Policies a Implementer
- Users: lecture/modification de ses propres donnees
- Videos: lecture publique si active, gestion par proprietaire
- Messages: lecture uniquement par participants de la conversation
- Profils: lecture publique, modification par proprietaire

### Environnement
- Supabase CLI pour migrations
- PostgreSQL 15+
- Extensions: uuid-ossp, pgcrypto

---

## Dev Agent Record

### Implementation Plan
Creation d'un fichier de migration SQL unique contenant:
1. Extensions PostgreSQL (uuid-ossp, pgcrypto)
2. 14 tables avec tous leurs champs, contraintes et indexes
3. Fonction et triggers pour updated_at automatique
4. RLS active sur 12 tables avec policies de base
5. Seed data pour 15 categories initiales

### Debug Log
- Aucun probleme rencontre
- Migration SQL syntaxiquement correcte
- Toutes les FK et contraintes respectees

### Completion Notes
Implementation complete du schema de base de donnees:

**Tables creees (14):**
- users, seeker_profiles, recruiter_profiles, categories
- videos, video_views
- conversations, messages
- subscriptions, purchases
- blocks, reports
- push_tokens, audit_logs

**Indexes crees (27):**
- Index sur toutes les FK
- Index GIN sur arrays (seeker_profiles.categories)
- Index partiels pour videos actives
- Contraintes UNIQUE pour integrite

**RLS Policies (18):**
- Policies pour tous les cas d'usage definis
- Admin access pour moderation
- Participant-only access pour messages

**Triggers (6):**
- updated_at automatique sur tables modifiables

**Seed Data:**
- 15 categories metiers pre-inserees

---

## File List

### Fichiers Crees
- `supabase/migrations/20260202000000_initial_schema.sql` (NEW)
- `supabase/README.md` (NEW)

### Fichiers Modifies
- Aucun

---

## Change Log
| Date | Changement | Auteur |
|------|------------|--------|
| 2026-02-02 | Creation de la story | John (PM) |
| 2026-02-02 | Implementation complete du schema DB | Amelia (Dev) |

---

## Status
complete
