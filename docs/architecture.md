# Architecture — Étoile (Post-pivot E-4)

Dernière mise à jour : 2026-05-02

## Vue d'ensemble

Étoile est composée de **deux applications distinctes** partageant le **même backend Supabase** :

```
┌─────────────────────────┐         ┌─────────────────────────┐
│   App Mobile Flutter    │         │    SaaS Web Next.js     │
│   (Chercheurs)          │         │    (Recruteurs)         │
│                         │         │                         │
│  - Inscription OTP      │         │  - Inscription SIRET    │
│  - Profil + @username   │         │  - Publication offres   │
│  - Enregistrement vidéo │         │  - Grille candidats     │
│  - Feed vertical offres │         │  - Messagerie temps réel│
│  - Candidature 1 clic   │         │  - Dashboard KPIs       │
│  - Messagerie temps réel│         │  - Paiements Stripe     │
└────────┬────────────────┘         └────────┬────────────────┘
         │                                   │
         │         Supabase Shared Backend   │
         └───────────────┬───────────────────┘
                         │
        ┌────────────────┴────────────────┐
        │ PostgreSQL + Auth + Realtime    │
        │ Edge Functions + Storage        │
        │ RLS (Row Level Security)        │
        └─────────────────────────────────┘
                         │
        ┌────────────────┴────────────────┐
        │    Cloudflare R2 + Worker       │
        │    (Stockage vidéos)            │
        └─────────────────────────────────┘
```

## Stack technique

### App Mobile (Flutter)

| Couche | Technologie | Rôle |
|--------|-------------|------|
| Framework | Flutter 3.x / Dart | Cross-platform iOS + Android |
| State Management | BLoC (flutter_bloc) | Architecture feature-based |
| Navigation | GoRouter | Routes déclaratives, deep linking |
| Auth | Supabase Auth | Email + OTP 6 chiffres |
| Database | supabase_flutter | Client PostgreSQL + Realtime |
| Vidéo | camera + video_player | Enregistrement in-app + playback |
| Upload | http + Cloudflare Worker | Presigned URLs R2 |
| Push | Firebase Cloud Messaging | Notifications temps réel |
| Design | Sora (Google Fonts) + Material 3 | Violet #635BFF |

### SaaS Web (Next.js)

| Couche | Technologie | Rôle |
|--------|-------------|------|
| Framework | Next.js 16 (App Router) | SSR + Server Components |
| UI | Tailwind CSS + Shadcn/ui | Design system Stripe-like |
| Auth | Supabase SSR (@supabase/ssr) | Session cookies + middleware |
| Database | Supabase | Client server + browser |
| Paiements | Stripe Checkout | Abonnements 499€/mois |
| Messagerie | Supabase Realtime | WebSocket sync avec mobile |
| Déploiement | Vercel | Hobby tier (gratuit) |
| Design | Sora (Google Fonts) | Violet #635BFF |

### Backend Partagé (Supabase)

| Service | Usage |
|---------|-------|
| Auth | Email + OTP pour chercheurs et recruteurs |
| PostgreSQL | Tables partagées (users, profiles, videos, offers, messages) |
| Realtime | Messagerie synchronisée Flutter ↔ Next.js |
| Edge Functions | Score matching, suppression compte, modération |
| Storage | Photos profil, documents vérification SIRET |
| RLS (Row Level Security) | Isolation des données par utilisateur |

### Stockage Vidéos (Cloudflare)

| Composant | Usage |
|-----------|-------|
| R2 | Bucket `etoile-videos` (50 Mo max par vidéo) |
| Worker | Génération presigned URLs upload + streaming |
| Egress gratuit | Pas de coût de bande passante (vs S3) |

## Architecture Base de Données

### Tables principales

```sql
-- Authentification et rôles
user_roles (
  user_id UUID PRIMARY KEY,
  role TEXT CHECK(role IN ('seeker', 'recruiter', 'admin')),
  email TEXT,
  created_at TIMESTAMPTZ,
  last_login_at TIMESTAMPTZ  -- Epic 13
)

-- Profils chercheurs
seeker_profiles (
  id UUID PRIMARY KEY REFERENCES user_roles(user_id),
  first_name TEXT,
  last_name TEXT,
  username VARCHAR(10) UNIQUE,  -- @pseudo unique (Sprint 30)
  age INTEGER,
  city TEXT,
  school TEXT,
  study_level TEXT,
  domain TEXT,  -- secteur cherché
  specialty TEXT,
  photo_url TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ
)

-- Profils recruteurs
recruiter_profiles (
  id UUID PRIMARY KEY REFERENCES user_roles(user_id),
  company_name TEXT,
  sector TEXT,  -- secteur entreprise
  description TEXT,
  locations TEXT[],  -- villes de recrutement
  siret TEXT,
  verification_status TEXT CHECK(verification_status IN ('pending', 'verified', 'rejected')),
  verification_document_url TEXT,
  photo_url TEXT,  -- Epic 10 Phase 2
  video_credits INTEGER DEFAULT 0,
  poster_credits INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ
)

-- Vidéos chercheurs
videos (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES user_roles(user_id),
  cloudflare_key TEXT,
  thumbnail_key TEXT,
  duration INTEGER,
  sector TEXT,  -- Sprint SaaS-2
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ
)

-- Offres recruteurs
offers (
  id UUID PRIMARY KEY,
  recruiter_id UUID REFERENCES user_roles(user_id),
  title TEXT,
  description TEXT,
  sector TEXT,
  contract_type TEXT,
  media_type TEXT CHECK(media_type IN ('video', 'poster')),
  media_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ
)

-- Candidatures
applications (
  id UUID PRIMARY KEY,
  seeker_id UUID REFERENCES user_roles(user_id),
  offer_id UUID REFERENCES offers(id),
  video_id UUID REFERENCES videos(id),
  status TEXT CHECK(status IN ('pending', 'shortlisted', 'rejected')),
  created_at TIMESTAMPTZ
)

-- Messagerie
conversations (
  id UUID PRIMARY KEY,
  seeker_id UUID REFERENCES user_roles(user_id),
  recruiter_id UUID REFERENCES user_roles(user_id),
  offer_id UUID REFERENCES offers(id),
  video_id UUID REFERENCES videos(id),
  last_message_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ
)

messages (
  id UUID PRIMARY KEY,
  conversation_id UUID REFERENCES conversations(id),
  sender_id UUID REFERENCES user_roles(user_id),
  content TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ
)

-- Scoring (Epic 14)
match_scores (
  id UUID PRIMARY KEY,
  seeker_id UUID REFERENCES user_roles(user_id),
  offer_id UUID REFERENCES offers(id),
  score INTEGER,  -- 0-100
  sector_match BOOLEAN,
  city_match BOOLEAN,
  study_level_match BOOLEAN,
  specialty_match BOOLEAN,
  computed_at TIMESTAMPTZ
)

-- Évaluations candidats (SaaS)
candidate_evaluations (
  id UUID PRIMARY KEY,
  recruiter_id UUID REFERENCES user_roles(user_id),
  seeker_id UUID REFERENCES user_roles(user_id),
  offer_id UUID REFERENCES offers(id),
  notes TEXT,
  tags TEXT[],
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
```

### RLS Policies

Toutes les tables ont des policies Row Level Security activées :

- **Chercheurs** : accès uniquement à leurs propres données
- **Recruteurs** : accès à leurs offres + candidatures reçues + conversations
- **Admin** : accès complet

## Flux de données critiques

### 1. Publication vidéo chercheur (Mobile → R2 → DB)

```
1. Chercheur enregistre vidéo in-app (camera Flutter)
2. App demande presigned URL au Worker Cloudflare
3. Upload direct vers R2 (pas de transit backend)
4. App INSERT dans table videos avec cloudflare_key
5. Vidéo disponible dans feed recruteurs
```

### 2. Candidature chercheur → conversation (Mobile → SaaS)

```
1. Chercheur clique "Postuler" sur une offre (Mobile)
2. INSERT dans applications (seeker_id, offer_id, video_id)
3. INSERT dans conversations si première candidature
4. Recruteur voit nouvelle candidature (SaaS, grille temps réel)
5. Recruteur peut initier conversation (message INSERT)
6. Notification push chercheur (FCM via Edge Function)
```

### 3. Messagerie temps réel (Supabase Realtime)

```
Flutter (chercheur)                    Next.js (recruteur)
      │                                        │
      ├─ supabase.channel('messages')          │
      │  .on('postgres_changes')               │
      │  .subscribe()                          │
      │                                        │
      ├─ INSERT message ───────────────────────→ Supabase
      │                                        │
      │                    Realtime broadcast  │
      │                                        │
      ←───────────────────────────────────────┤ useEffect()
      │                                        │ message reçu
   Message reçu                                │
```

### 4. Score de matching (Epic 14)

```
1. Recruteur publie offre (secteur, ville, niveau, spécialité)
2. Trigger PostgreSQL calcule scores pour tous chercheurs actifs
3. INSERT batch dans match_scores (fonction calculate_match_score)
4. SaaS grille candidats : ORDER BY score DESC
5. Mise à jour lazy : DELETE scores à la modification de profil/offre
```

## Décisions architecturales clés (ADR)

### ADR-001 : Paiements Stripe direct (SaaS uniquement)

**Contexte** : Pivot vers SaaS web pour recruteurs, app mobile gratuite pour chercheurs.

**Décision** : Stripe direct sur le web SaaS, AUCUN IAP mobile.

**Justification** :
- Recruteurs paient 499€/mois (B2B, facture entreprise)
- Stripe Checkout + Customer Portal natif
- Pas de commission Apple/Google (économie ~30%)
- Chercheurs gratuits (modèle freemium)

**Impact** :
- App mobile ne gère AUCUN paiement
- Code IAP supprimé lors du Sprint 30

---

### ADR-002 : Username unique chercheur

**Contexte** : Besoin de recherche par @pseudo pour recruteurs.

**Décision** : Colonne `username VARCHAR(10) UNIQUE` dans `seeker_profiles`.

**Format** :
- 3-10 caractères lowercase alphanumérique + tirets
- Vérification unicité en temps réel (debounce 500ms)
- Triple sécurité : UNIQUE SQL + repo check + UI feedback

**Impact** :
- Profil completion chercheur : 20% = prenom + nom + age + **username**
- SaaS recherche : `/search?q=@username` (SSR Next.js)

---

### ADR-003 : Scoring PostgreSQL vs Edge Function

**Contexte** : Epic 14, calcul score de matching (0-100%) pour 10k+ paires.

**Décision** : PostgreSQL Function STABLE (pas Edge Function).

**Justification** :
- Performance : <100ms pour batch 1000 scores (vs 2s+ Edge Function)
- Zero cold start
- Optimisation query plan PostgreSQL
- Trigger DELETE lazy pour invalidation cache

**Trade-offs** :
- (+) Très rapide, pas de réseau
- (+) Transactionnel (ACID)
- (-) Moins flexible que TypeScript Edge Function

---

### ADR-004 : Messagerie Supabase Realtime vs WebSocket custom

**Contexte** : Epic 15, messagerie temps réel Flutter ↔ Next.js.

**Décision** : Supabase Realtime (postgres_changes subscription).

**Justification** :
- Déjà inclus dans Supabase (coût 0€)
- SDK natif Flutter + Next.js
- Synchronisation automatique avec DB
- Pas de serveur WebSocket à maintenir

**Limitations** :
- 100 connexions simultanées max (tier gratuit)
- Suffisant pour MVP (<1000 utilisateurs actifs)

---

## Sécurité et RGPD

### Row Level Security (RLS)

Toutes les tables ont RLS activé + policies strictes :

```sql
-- Exemple : seeker_profiles
ALTER TABLE seeker_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Seekers can view own profile"
  ON seeker_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Recruiters can view verified seekers"
  ON seeker_profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
        AND role = 'recruiter'
    )
  );
```

### RGPD

- Soft delete 30 jours (colonne `deleted_at`)
- Export JSON via Edge Function `export-user-data`
- Portabilité complète (profil + vidéos + messages)
- Suppression définitive après 30j (CRON job)

## Performance et Scalabilité

### Métriques cibles

| Métrique | Objectif | Actuel |
|----------|----------|--------|
| Page load (SaaS) | <2s | ~1.2s |
| Video start (mobile) | <1s | ~800ms |
| Realtime latency | <500ms | ~200ms |
| Match scoring | <100ms | ~80ms |

### Optimisations implémentées

- Next.js Server Components (cache 5 min)
- PostgreSQL indexes sur colonnes critiques
- Cloudflare R2 edge caching
- Supabase connection pooling (PgBouncer)

### Limites actuelles (tier gratuit Supabase)

- 500 MB storage (vidéos externalisées sur R2)
- 2 GB egress/mois (acceptable pour MVP)
- Pas de backup automatique point-in-time

## Monitoring et Logs

- **Supabase Dashboard** : requêtes lentes, erreurs auth
- **Vercel Analytics** : Next.js performance
- **Firebase Crashlytics** : crashes Flutter
- **Cloudflare Analytics** : trafic vidéos

## Prochaines étapes techniques

1. Migration Supabase tier Pro (25$/mois) avant 1000 utilisateurs
2. CDN custom domain pour vidéos (etoile-cdn.fr)
3. Backup automatique PostgreSQL (point-in-time recovery)
4. Tests de charge (k6.io) pour 10k utilisateurs simultanés
