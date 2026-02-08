# Architecture Technique - Etoile Mobile App

---
version: 1.0
date: 2026-02-01
author: Winston (Architecte Technique Senior)
status: Draft
projectName: Etoile Mobile App
---

## Table des Matieres

1. [Executive Summary Architecture](#1-executive-summary-architecture)
2. [Architecture Globale](#2-architecture-globale)
3. [Stack Technique Recommandee](#3-stack-technique-recommandee)
4. [Architecture Flutter](#4-architecture-flutter)
5. [Architecture Backend](#5-architecture-backend)
6. [Securite](#6-securite)
7. [Scalabilite](#7-scalabilite)
8. [Infrastructure](#8-infrastructure)
9. [Estimations Techniques](#9-estimations-techniques)
10. [Decisions d'Architecture (ADR)](#10-decisions-darchitecture-adr)

---

## 1. Executive Summary Architecture

### Vision Technique

Etoile est une application mobile Flutter cross-platform (iOS/Android) de recrutement par video de 40 secondes. L'architecture doit supporter une experience utilisateur fluide de type "TikTok-like" tout en garantissant authenticite, securite et scalabilite.

### Principes Directeurs

| Principe | Description | Impact |
|----------|-------------|--------|
| **Mobile-First** | Flutter comme unique codebase iOS/Android | Reduction des couts de developpement de 40% |
| **Video-Centric** | Architecture optimisee pour le streaming video | CDN edge, preloading, compression adaptative |
| **Serverless-First** | Backend scalable automatiquement | Pas de gestion serveur, scaling transparent |
| **Security by Design** | Verification des recruteurs, donnees chiffrees | Confiance utilisateur, conformite RGPD |
| **Cost-Optimized** | Cloudflare R2 (egress gratuit) vs S3 | Economies significatives sur le trafic video |
| **Offline-Resilient** | Cache local, sync intelligente | UX fluide meme en connexion degradee |

### Contraintes Techniques Cles

| Contrainte | Valeur | Justification |
|------------|--------|---------------|
| Utilisateurs simultanes (nominal) | 500 | Charge de base |
| Utilisateurs simultanes (pic) | 2 000 | Campagnes marketing, pics d'activite |
| Disponibilite | 24/7, SLA 99.5% | Application critique pour chercheurs d'emploi |
| Temps de chargement video | < 2 secondes | Experience TikTok-like |
| Temps de reponse API | < 500ms (P95) | Fluidite de l'interface |
| Duree video | 40 secondes fixes | Contrainte produit |
| Taille video estimee | ~15-25 MB (1080p compresse) | Optimisation bande passante |

---

## 2. Architecture Globale

### Diagramme Systeme Complet

```
+===========================================================================+
|                              CLIENTS MOBILES                               |
|  +---------------------------+     +---------------------------+           |
|  |       iOS App             |     |      Android App          |           |
|  |    Flutter 3.x / Dart     |     |    Flutter 3.x / Dart     |           |
|  |                           |     |                           |           |
|  |  +---------------------+  |     |  +---------------------+  |           |
|  |  | BLoC State Mgmt     |  |     |  | BLoC State Mgmt     |  |           |
|  |  | Clean Architecture  |  |     |  | Clean Architecture  |  |           |
|  |  | Local Cache (Hive)  |  |     |  | Local Cache (Hive)  |  |           |
|  |  +---------------------+  |     |  +---------------------+  |           |
|  +-------------+-------------+     +-------------+-------------+           |
|                |                                 |                          |
+================|=================================|==========================+
                 |           HTTPS/WSS             |
                 +----------------+----------------+
                                  |
                                  v
+===========================================================================+
|                           CLOUDFLARE EDGE                                  |
|                                                                            |
|  +-------------------+  +-------------------+  +------------------------+  |
|  |       CDN         |  |     Workers       |  |          R2            |  |
|  | Cache Global      |  | Edge Compute      |  |   Stockage Video       |  |
|  | DDoS Protection   |  | Signed URLs       |  |   Egress Gratuit       |  |
|  | SSL/TLS          |  | Rate Limiting     |  |   Compatible S3        |  |
|  +-------------------+  +-------------------+  +------------------------+  |
|           |                     |                         |                |
+-----------+---------------------+-------------------------+----------------+
            |                     |                         |
            v                     v                         v
+===========================================================================+
|                              BACKEND LAYER                                 |
|                                                                            |
|  +-----------------------------------------------------------------------+ |
|  |                          SUPABASE (Recommande)                        | |
|  |                                                                       | |
|  |  +-----------------+  +------------------+  +----------------------+  | |
|  |  |   Auth          |  |   Realtime       |  |      Edge Functions  |  | |
|  |  | JWT + Refresh   |  | WebSocket        |  |   API Custom Logic   |  | |
|  |  | OAuth (option)  |  | Subscriptions    |  |   Webhooks           |  | |
|  |  +-----------------+  +------------------+  +----------------------+  | |
|  |                                                                       | |
|  |  +-----------------+  +------------------+  +----------------------+  | |
|  |  |   PostgreSQL    |  |    Storage       |  |      PostgREST       |  | |
|  |  | Base de donnees |  | Fichiers/Docs    |  |   API Auto-generee   |  | |
|  |  | Row Level Sec.  |  | (Thumbnails)     |  |   Filtres, Pagination| |
|  |  +-----------------+  +------------------+  +----------------------+  | |
|  +-----------------------------------------------------------------------+ |
|                                    |                                       |
+====================================|=======================================+
                                     |
            +------------------------+------------------------+
            |                        |                        |
            v                        v                        v
+-------------------+   +-------------------+   +-------------------+
|      STRIPE       |   |      RESEND       |   |      SENTRY       |
|   Paiements       |   | Emails Transac.   |   |   Monitoring      |
|   Abonnements     |   | Notifications     |   |   Error Tracking  |
|   Webhooks        |   | Templates         |   |   Performance     |
+-------------------+   +-------------------+   +-------------------+
```

### Composants Principaux et Interactions

| Composant | Role | Interactions |
|-----------|------|--------------|
| **App Flutter** | Interface utilisateur, logique metier locale | API REST, WebSocket, R2 (upload/download) |
| **Cloudflare CDN** | Distribution globale, cache | Toutes requetes entrantes |
| **Cloudflare Workers** | Logique edge (URLs signees, rate limiting) | Requetes sensibles, uploads video |
| **Cloudflare R2** | Stockage videos et thumbnails | Upload presigne, streaming direct |
| **Supabase** | Backend-as-a-Service complet | Auth, DB, Realtime, Storage secondaire |
| **PostgreSQL** | Base de donnees relationnelle | Toutes donnees structurees |
| **Stripe** | Gestion des paiements | Webhooks vers backend |
| **Resend** | Emails transactionnels | Declenchement par Edge Functions |

### Flux de Donnees Critiques

#### Flux 1: Upload Video Chercheur

```
[App Flutter] --1. Request Upload URL--> [Supabase Edge Function]
      |                                           |
      |    <--2. Presigned URL R2--               |
      |                                           |
      +--3. Upload Direct Video--> [Cloudflare R2]
      |                                           |
      +--4. Confirm Upload--> [Supabase Edge Function]
      |                                           |
      |                      [5. Update DB + Generate Thumbnail]
      |                                           |
      <--6. Success Response--                    |
```

#### Flux 2: Streaming Video Feed

```
[App Flutter] --1. Request Feed--> [Cloudflare CDN]
      |                                   |
      |                     [Cache HIT?]--+
      |                       |           |
      |    <--Cached Response-+    [Cache MISS]
      |                                   |
      |                                   v
      |                          [Supabase PostgREST]
      |                                   |
      |                          [Query PostgreSQL]
      |                                   |
      |    <--Video Metadata + CDN URLs---+
      |
      +--2. Stream Video--> [Cloudflare R2 via CDN]
```

---

## 3. Stack Technique Recommandee

### 3.1 Frontend: Flutter/Dart

| Aspect | Choix | Version | Justification |
|--------|-------|---------|---------------|
| **Framework** | Flutter | 3.x (stable) | Cross-platform, performances natives |
| **Langage** | Dart | 3.x | Type-safe, async/await natif |
| **State Management** | BLoC | 8.x | Separation claire, testabilite, scalable |
| **Navigation** | go_router | 12.x | Declarative, deep linking |
| **HTTP Client** | Dio | 5.x | Interceptors, retry, logging |
| **WebSocket** | supabase_flutter | - | Realtime natif |
| **Cache Local** | Hive | 2.x | NoSQL performant, chiffrement |
| **Video Player** | video_player + chewie | - | Lecture video native |
| **Camera** | camera | - | Enregistrement video natif |

### 3.2 Backend: Comparatif et Recommandation

| Critere | Supabase | Firebase | Backend Custom |
|---------|----------|----------|----------------|
| **Setup Initial** | Rapide (heures) | Rapide (heures) | Long (semaines) |
| **Auth Integre** | Oui (JWT) | Oui (Firebase Auth) | A developper |
| **Base de Donnees** | PostgreSQL (SQL) | Firestore (NoSQL) | Au choix |
| **Realtime** | WebSocket natif | Realtime Database | A implementer |
| **Row Level Security** | Oui (RLS PostgreSQL) | Security Rules | A implementer |
| **Edge Functions** | Oui (Deno) | Cloud Functions | AWS Lambda, etc. |
| **Cout (MVP)** | ~25$/mois | ~30$/mois | ~100-200$/mois |
| **Vendor Lock-in** | Faible (PostgreSQL) | Eleve (Firestore) | Aucun |
| **Open Source** | Oui | Non | Variable |
| **Scalabilite** | Auto-scaling | Auto-scaling | A configurer |

#### Recommandation: SUPABASE

**Raisons du choix:**

1. **PostgreSQL** - Base SQL robuste, connue, facile a migrer si besoin
2. **Row Level Security** - Securite au niveau DB, pas seulement API
3. **Open Source** - Possibilite de self-host en cas de besoin
4. **Realtime natif** - Parfait pour la messagerie instantanee
5. **Edge Functions** - Logique serveur sans infrastructure a gerer
6. **Cout optimise** - Tier gratuit genereux, scaling progressif
7. **Compatibilite Flutter** - SDK officiel bien maintenu

### 3.3 Base de Donnees: PostgreSQL

#### Schema Detaille

```sql
-- =============================================================================
-- SCHEMA ETOILE - PostgreSQL via Supabase
-- =============================================================================

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- TABLE: users
-- Description: Utilisateurs de la plateforme (chercheurs, recruteurs, admins)
-- =============================================================================
CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email               VARCHAR(255) UNIQUE NOT NULL,
    password_hash       VARCHAR(255), -- NULL si OAuth
    role                VARCHAR(20) NOT NULL CHECK (role IN ('seeker', 'recruiter', 'admin')),
    email_verified      BOOLEAN DEFAULT FALSE,
    email_verified_at   TIMESTAMP WITH TIME ZONE,
    is_premium          BOOLEAN DEFAULT FALSE,
    premium_until       TIMESTAMP WITH TIME ZONE,
    status              VARCHAR(20) DEFAULT 'active'
                        CHECK (status IN ('active', 'pending', 'suspended', 'deleted')),
    last_login_at       TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);

-- =============================================================================
-- TABLE: seeker_profiles
-- Description: Profils des chercheurs d'emploi
-- =============================================================================
CREATE TABLE seeker_profiles (
    user_id             UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    first_name          VARCHAR(100) NOT NULL,
    last_name           VARCHAR(100),
    phone               VARCHAR(20),
    birth_date          DATE,
    -- Localisation
    region              VARCHAR(100),
    city                VARCHAR(100),
    postal_code         VARCHAR(10),
    -- Recherche
    categories          TEXT[] DEFAULT '{}',           -- Secteurs recherches (multi)
    contract_types      TEXT[] DEFAULT '{}',           -- CDI, CDD, alternance, stage, interim
    experience_level    VARCHAR(50),                   -- junior, confirmed, senior
    availability        VARCHAR(50),                   -- immediate, 1_month, 3_months
    salary_expectation  INTEGER,                       -- En euros annuel brut
    -- Bio
    bio                 TEXT,
    -- Metadata
    profile_complete    BOOLEAN DEFAULT FALSE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_seeker_categories ON seeker_profiles USING GIN(categories);
CREATE INDEX idx_seeker_region ON seeker_profiles(region);
CREATE INDEX idx_seeker_city ON seeker_profiles(city);

-- =============================================================================
-- TABLE: recruiter_profiles
-- Description: Profils des recruteurs (entreprises)
-- =============================================================================
CREATE TABLE recruiter_profiles (
    user_id             UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    -- Entreprise
    company_name        VARCHAR(255) NOT NULL,
    siret               VARCHAR(14),
    siren               VARCHAR(9),
    legal_form          VARCHAR(100),                  -- SARL, SAS, etc.
    -- Documents
    document_type       VARCHAR(50),                   -- kbis, carte_pro, etc.
    document_url        VARCHAR(500),
    document_uploaded_at TIMESTAMP WITH TIME ZONE,
    -- Presentation
    logo_url            VARCHAR(500),
    cover_url           VARCHAR(500),
    description         TEXT,
    website             VARCHAR(255),
    -- Activite
    sector              VARCHAR(100),
    company_size        VARCHAR(50),                   -- 1-10, 11-50, 51-200, 200+
    locations           TEXT[] DEFAULT '{}',
    -- Verification
    verification_status VARCHAR(20) DEFAULT 'pending'
                        CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verified_at         TIMESTAMP WITH TIME ZONE,
    verified_by         UUID REFERENCES users(id),
    rejection_reason    TEXT,
    -- Credits
    video_credits       INTEGER DEFAULT 1,
    poster_credits      INTEGER DEFAULT 1,
    -- Metadata
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_recruiter_siret ON recruiter_profiles(siret);
CREATE INDEX idx_recruiter_sector ON recruiter_profiles(sector);
CREATE INDEX idx_recruiter_verification ON recruiter_profiles(verification_status);

-- =============================================================================
-- TABLE: categories
-- Description: Categories de metiers/secteurs
-- =============================================================================
CREATE TABLE categories (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                VARCHAR(100) NOT NULL UNIQUE,
    slug                VARCHAR(100) NOT NULL UNIQUE,
    description         TEXT,
    icon                VARCHAR(50),
    parent_id           UUID REFERENCES categories(id),
    sort_order          INTEGER DEFAULT 0,
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABLE: videos
-- Description: Videos des utilisateurs (chercheurs et recruteurs)
-- =============================================================================
CREATE TABLE videos (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    -- Type et categorie
    type                VARCHAR(20) NOT NULL CHECK (type IN ('presentation', 'offer')),
    category_id         UUID REFERENCES categories(id),
    -- Contenu
    title               VARCHAR(255),
    description         TEXT,
    -- Fichiers (Cloudflare R2)
    video_key           VARCHAR(500) NOT NULL,         -- Cle R2
    video_url           VARCHAR(500),                  -- URL CDN publique
    thumbnail_key       VARCHAR(500),
    thumbnail_url       VARCHAR(500),
    -- Metadonnees video
    duration_seconds    INTEGER DEFAULT 40,
    file_size_bytes     BIGINT,
    resolution          VARCHAR(20),                   -- 1080p, 720p, etc.
    codec               VARCHAR(50),
    -- Statut
    status              VARCHAR(20) DEFAULT 'processing'
                        CHECK (status IN ('processing', 'active', 'suspended', 'deleted')),
    processing_error    TEXT,
    -- Statistiques
    views_count         INTEGER DEFAULT 0,
    unique_viewers      INTEGER DEFAULT 0,
    -- Lifecycle
    published_at        TIMESTAMP WITH TIME ZONE,
    expires_at          TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_videos_user ON videos(user_id);
CREATE INDEX idx_videos_category ON videos(category_id);
CREATE INDEX idx_videos_status ON videos(status);
CREATE INDEX idx_videos_type ON videos(type);
CREATE INDEX idx_videos_published ON videos(published_at DESC) WHERE status = 'active';

-- Contrainte: 1 seule video active par chercheur par categorie
CREATE UNIQUE INDEX idx_unique_seeker_video_per_category
    ON videos(user_id, category_id)
    WHERE type = 'presentation' AND status = 'active';

-- =============================================================================
-- TABLE: video_views
-- Description: Tracking des vues de videos
-- =============================================================================
CREATE TABLE video_views (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    video_id            UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    viewer_id           UUID REFERENCES users(id) ON DELETE SET NULL,
    viewer_ip_hash      VARCHAR(64),                   -- Hash pour anonymat
    watch_duration      INTEGER,                       -- Secondes regardees
    completed           BOOLEAN DEFAULT FALSE,
    device_type         VARCHAR(20),                   -- ios, android
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_video_views_video ON video_views(video_id);
CREATE INDEX idx_video_views_viewer ON video_views(viewer_id);
CREATE INDEX idx_video_views_date ON video_views(created_at);

-- =============================================================================
-- TABLE: conversations
-- Description: Conversations entre utilisateurs
-- =============================================================================
CREATE TABLE conversations (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_1       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    participant_2       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    -- Contexte
    video_id            UUID REFERENCES videos(id),    -- Video a l'origine du contact
    -- Etat
    last_message_at     TIMESTAMP WITH TIME ZONE,
    last_message_preview TEXT,
    -- Lecture
    participant_1_read_at TIMESTAMP WITH TIME ZONE,
    participant_2_read_at TIMESTAMP WITH TIME ZONE,
    -- Metadata
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- Contrainte d'unicite
    UNIQUE(participant_1, participant_2)
);

CREATE INDEX idx_conversations_p1 ON conversations(participant_1);
CREATE INDEX idx_conversations_p2 ON conversations(participant_2);
CREATE INDEX idx_conversations_last_msg ON conversations(last_message_at DESC);

-- =============================================================================
-- TABLE: messages
-- Description: Messages individuels
-- =============================================================================
CREATE TABLE messages (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id     UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    -- Contenu
    content             TEXT NOT NULL,
    content_type        VARCHAR(20) DEFAULT 'text' CHECK (content_type IN ('text', 'system')),
    -- Etat
    is_read             BOOLEAN DEFAULT FALSE,
    read_at             TIMESTAMP WITH TIME ZONE,
    -- Metadata
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);

-- =============================================================================
-- TABLE: subscriptions
-- Description: Abonnements premium
-- =============================================================================
CREATE TABLE subscriptions (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    -- Plan
    plan_type           VARCHAR(50) NOT NULL
                        CHECK (plan_type IN ('seeker_premium', 'recruiter_premium')),
    plan_price_cents    INTEGER NOT NULL,
    -- Stripe
    stripe_subscription_id VARCHAR(255) UNIQUE,
    stripe_customer_id     VARCHAR(255),
    stripe_price_id        VARCHAR(255),
    -- Etat
    status              VARCHAR(20) DEFAULT 'active'
                        CHECK (status IN ('active', 'canceled', 'past_due', 'expired', 'trialing')),
    -- Periodes
    trial_ends_at       TIMESTAMP WITH TIME ZONE,
    current_period_start TIMESTAMP WITH TIME ZONE,
    current_period_end   TIMESTAMP WITH TIME ZONE,
    canceled_at         TIMESTAMP WITH TIME ZONE,
    -- Metadata
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_stripe ON subscriptions(stripe_subscription_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- =============================================================================
-- TABLE: purchases
-- Description: Achats unitaires (credits video/affiche)
-- =============================================================================
CREATE TABLE purchases (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id),
    -- Produit
    product_type        VARCHAR(50) NOT NULL
                        CHECK (product_type IN ('video_credit', 'poster_credit')),
    quantity            INTEGER DEFAULT 1,
    unit_price_cents    INTEGER NOT NULL,
    total_price_cents   INTEGER NOT NULL,
    -- Stripe
    stripe_payment_intent_id VARCHAR(255),
    stripe_invoice_id       VARCHAR(255),
    -- Etat
    status              VARCHAR(20) DEFAULT 'pending'
                        CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    -- Metadata
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_purchases_user ON purchases(user_id);
CREATE INDEX idx_purchases_status ON purchases(status);

-- =============================================================================
-- TABLE: blocks
-- Description: Blocages entre utilisateurs
-- =============================================================================
CREATE TABLE blocks (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    blocker_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason              TEXT,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(blocker_id, blocked_id)
);

CREATE INDEX idx_blocks_blocker ON blocks(blocker_id);
CREATE INDEX idx_blocks_blocked ON blocks(blocked_id);

-- =============================================================================
-- TABLE: reports
-- Description: Signalements de contenus
-- =============================================================================
CREATE TABLE reports (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id         UUID NOT NULL REFERENCES users(id),
    -- Cible
    reported_user_id    UUID REFERENCES users(id),
    reported_video_id   UUID REFERENCES videos(id),
    reported_message_id UUID REFERENCES messages(id),
    -- Signalement
    reason              VARCHAR(100) NOT NULL,
    description         TEXT,
    -- Traitement
    status              VARCHAR(20) DEFAULT 'pending'
                        CHECK (status IN ('pending', 'reviewing', 'actioned', 'dismissed')),
    action_taken        VARCHAR(100),
    reviewed_by         UUID REFERENCES users(id),
    reviewed_at         TIMESTAMP WITH TIME ZONE,
    admin_notes         TEXT,
    -- Metadata
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_created ON reports(created_at DESC);

-- =============================================================================
-- TABLE: push_tokens
-- Description: Tokens pour notifications push
-- =============================================================================
CREATE TABLE push_tokens (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token               TEXT NOT NULL,
    platform            VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android')),
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_push_tokens_user ON push_tokens(user_id);
CREATE UNIQUE INDEX idx_push_tokens_token ON push_tokens(token);

-- =============================================================================
-- TABLE: audit_logs
-- Description: Journal d'audit pour actions sensibles
-- =============================================================================
CREATE TABLE audit_logs (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID REFERENCES users(id),
    action              VARCHAR(100) NOT NULL,
    entity_type         VARCHAR(50),
    entity_id           UUID,
    old_values          JSONB,
    new_values          JSONB,
    ip_address          INET,
    user_agent          TEXT,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);

-- =============================================================================
-- TRIGGERS: Updated_at automatique
-- =============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_seeker_profiles_updated_at BEFORE UPDATE ON seeker_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recruiter_profiles_updated_at BEFORE UPDATE ON recruiter_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_videos_updated_at BEFORE UPDATE ON videos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Activer RLS sur toutes les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE seeker_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE recruiter_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Policies exemples (a completer selon besoins)
CREATE POLICY "Users can read own data" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Anyone can read active videos" ON videos
    FOR SELECT USING (status = 'active');

CREATE POLICY "Users can manage own videos" ON videos
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Conversation participants can read messages" ON messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM conversations c
            WHERE c.id = conversation_id
            AND (c.participant_1 = auth.uid() OR c.participant_2 = auth.uid())
        )
    );
```

### 3.4 Stockage Video: Cloudflare R2

| Configuration | Valeur | Justification |
|---------------|--------|---------------|
| **Bucket Principal** | `etoile-videos-prod` | Videos des utilisateurs |
| **Bucket Thumbnails** | `etoile-thumbnails-prod` | Vignettes generees |
| **Region** | Auto (edge) | Distribution globale |
| **Versioning** | Desactive (MVP) | Simplification, economies |
| **Lifecycle** | 30 jours soft delete | Conformite RGPD |

#### Configuration R2

```toml
# wrangler.toml (Cloudflare Workers)
name = "etoile-video-worker"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[[r2_buckets]]
binding = "VIDEOS"
bucket_name = "etoile-videos-prod"

[[r2_buckets]]
binding = "THUMBNAILS"
bucket_name = "etoile-thumbnails-prod"

[vars]
ALLOWED_ORIGINS = "https://api.etoile-app.fr"
MAX_VIDEO_SIZE_MB = "50"
VIDEO_DURATION_SECONDS = "40"
```

### 3.5 CDN: Cloudflare

| Configuration | Valeur |
|---------------|--------|
| **SSL** | Full (strict) |
| **Min TLS** | 1.2 |
| **Cache TTL Videos** | 1 an (immutable) |
| **Cache TTL Thumbnails** | 1 semaine |
| **Cache TTL API** | No cache (dynamic) |
| **Polish** | Lossy (images) |
| **Brotli** | Actif |
| **Early Hints** | Actif |
| **Argo** | Desactive (MVP) |

---

## 4. Architecture Flutter

### 4.1 Structure des Dossiers

```
lib/
|
+-- main.dart                          # Point d'entree, setup DI
+-- app.dart                           # MaterialApp, theme, routing
|
+-- core/                              # Couche transversale
|   +-- constants/
|   |   +-- app_constants.dart         # Constantes globales
|   |   +-- api_constants.dart         # Endpoints, timeouts
|   |   +-- storage_keys.dart          # Cles Hive/SharedPrefs
|   |
|   +-- errors/
|   |   +-- exceptions.dart            # Exceptions custom
|   |   +-- failures.dart              # Failures pour Either
|   |
|   +-- network/
|   |   +-- api_client.dart            # Dio setup, interceptors
|   |   +-- network_info.dart          # Connectivity check
|   |
|   +-- utils/
|   |   +-- extensions.dart            # Extensions Dart
|   |   +-- validators.dart            # Validations formulaires
|   |   +-- date_formatter.dart
|   |
|   +-- theme/
|       +-- app_theme.dart             # ThemeData
|       +-- colors.dart                # Palette Etoile
|       +-- typography.dart            # Styles texte
|       +-- spacing.dart               # Espacements
|
+-- data/                              # Couche Data (Implementation)
|   +-- datasources/
|   |   +-- remote/
|   |   |   +-- auth_remote_datasource.dart
|   |   |   +-- user_remote_datasource.dart
|   |   |   +-- video_remote_datasource.dart
|   |   |   +-- message_remote_datasource.dart
|   |   |   +-- payment_remote_datasource.dart
|   |   |
|   |   +-- local/
|   |       +-- auth_local_datasource.dart
|   |       +-- cache_datasource.dart
|   |       +-- video_cache_datasource.dart
|   |
|   +-- models/                        # DTOs (Data Transfer Objects)
|   |   +-- user_model.dart
|   |   +-- video_model.dart
|   |   +-- message_model.dart
|   |   +-- subscription_model.dart
|   |
|   +-- repositories/                  # Implementation des repos
|       +-- auth_repository_impl.dart
|       +-- user_repository_impl.dart
|       +-- video_repository_impl.dart
|       +-- message_repository_impl.dart
|       +-- payment_repository_impl.dart
|
+-- domain/                            # Couche Domain (Business Logic)
|   +-- entities/                      # Entites metier pures
|   |   +-- user.dart
|   |   +-- seeker_profile.dart
|   |   +-- recruiter_profile.dart
|   |   +-- video.dart
|   |   +-- message.dart
|   |   +-- conversation.dart
|   |   +-- subscription.dart
|   |
|   +-- repositories/                  # Contrats (interfaces)
|   |   +-- auth_repository.dart
|   |   +-- user_repository.dart
|   |   +-- video_repository.dart
|   |   +-- message_repository.dart
|   |   +-- payment_repository.dart
|   |
|   +-- usecases/                      # Cas d'utilisation
|       +-- auth/
|       |   +-- login_usecase.dart
|       |   +-- register_usecase.dart
|       |   +-- logout_usecase.dart
|       |   +-- forgot_password_usecase.dart
|       |
|       +-- video/
|       |   +-- record_video_usecase.dart
|       |   +-- upload_video_usecase.dart
|       |   +-- get_feed_usecase.dart
|       |   +-- delete_video_usecase.dart
|       |
|       +-- message/
|       |   +-- send_message_usecase.dart
|       |   +-- get_conversations_usecase.dart
|       |   +-- mark_as_read_usecase.dart
|       |
|       +-- payment/
|           +-- subscribe_usecase.dart
|           +-- purchase_credit_usecase.dart
|           +-- cancel_subscription_usecase.dart
|
+-- presentation/                      # Couche Presentation (UI)
|   +-- blocs/                         # BLoCs globaux/partages
|   |   +-- auth/
|   |   |   +-- auth_bloc.dart
|   |   |   +-- auth_event.dart
|   |   |   +-- auth_state.dart
|   |   |
|   |   +-- user/
|   |   |   +-- user_bloc.dart
|   |   |   +-- user_event.dart
|   |   |   +-- user_state.dart
|   |   |
|   |   +-- connectivity/
|   |       +-- connectivity_bloc.dart
|   |
|   +-- pages/                         # Ecrans de l'app
|   |   +-- splash/
|   |   |   +-- splash_page.dart
|   |   |
|   |   +-- onboarding/
|   |   |   +-- welcome_page.dart
|   |   |   +-- role_selection_page.dart
|   |   |
|   |   +-- auth/
|   |   |   +-- login_page.dart
|   |   |   +-- register_page.dart
|   |   |   +-- forgot_password_page.dart
|   |   |   +-- blocs/
|   |   |       +-- login_bloc.dart
|   |   |
|   |   +-- seeker/
|   |   |   +-- profile_setup_page.dart
|   |   |   +-- profile_page.dart
|   |   |   +-- video_record_page.dart
|   |   |   +-- blocs/
|   |   |
|   |   +-- recruiter/
|   |   |   +-- company_setup_page.dart
|   |   |   +-- profile_page.dart
|   |   |   +-- blocs/
|   |   |
|   |   +-- feed/
|   |   |   +-- feed_page.dart
|   |   |   +-- filter_sheet.dart
|   |   |   +-- blocs/
|   |   |       +-- feed_bloc.dart
|   |   |       +-- feed_event.dart
|   |   |       +-- feed_state.dart
|   |   |
|   |   +-- messages/
|   |   |   +-- conversations_page.dart
|   |   |   +-- chat_page.dart
|   |   |   +-- blocs/
|   |   |
|   |   +-- premium/
|   |   |   +-- premium_page.dart
|   |   |   +-- checkout_page.dart
|   |   |
|   |   +-- settings/
|   |       +-- settings_page.dart
|   |       +-- help_page.dart
|   |
|   +-- widgets/                       # Composants reutilisables
|       +-- common/
|       |   +-- etoile_button.dart
|       |   +-- etoile_text_field.dart
|       |   +-- etoile_card.dart
|       |   +-- loading_indicator.dart
|       |   +-- error_view.dart
|       |
|       +-- video/
|       |   +-- video_player_widget.dart
|       |   +-- video_recorder_widget.dart
|       |   +-- video_preview_card.dart
|       |   +-- recording_overlay.dart
|       |
|       +-- profile/
|       |   +-- avatar_widget.dart
|       |   +-- verified_badge.dart
|       |   +-- profile_header.dart
|       |
|       +-- message/
|           +-- message_bubble.dart
|           +-- conversation_tile.dart
|           +-- typing_indicator.dart
|
+-- di/                                # Dependency Injection
|   +-- injection_container.dart       # GetIt setup
|
+-- routes/                            # Navigation
    +-- app_router.dart                # GoRouter config
    +-- route_names.dart               # Constantes routes
```

### 4.2 Patterns Recommandes

#### Clean Architecture

```
+---------------------------------------------------------------------+
|                        PRESENTATION LAYER                            |
|   +----------------------------------------------------------+      |
|   |  Pages (Widgets)  <-->  BLoCs  <-->  ViewModels          |      |
|   +----------------------------------------------------------+      |
+---------------------------------------------------------------------+
                              |
                              | (Events / States)
                              v
+---------------------------------------------------------------------+
|                          DOMAIN LAYER                                |
|   +----------------------------------------------------------+      |
|   |  UseCases  <-->  Entities  <-->  Repository Interfaces   |      |
|   +----------------------------------------------------------+      |
+---------------------------------------------------------------------+
                              |
                              | (Abstraction)
                              v
+---------------------------------------------------------------------+
|                           DATA LAYER                                 |
|   +----------------------------------------------------------+      |
|   |  Repository Impl  <-->  DataSources  <-->  Models (DTO)  |      |
|   +----------------------------------------------------------+      |
+---------------------------------------------------------------------+
                              |
                              v
               +----------------------------+
               |    External Sources        |
               |  (API, DB, Cache, etc.)    |
               +----------------------------+
```

#### Repository Pattern

```dart
// domain/repositories/video_repository.dart
abstract class VideoRepository {
  Future<Either<Failure, Video>> uploadVideo(File videoFile, String categoryId);
  Future<Either<Failure, List<Video>>> getFeed(FeedFilters filters, int page);
  Future<Either<Failure, void>> deleteVideo(String videoId);
  Stream<Video> watchVideoUpdates(String videoId);
}

// data/repositories/video_repository_impl.dart
class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final VideoCacheDataSource cacheDataSource;
  final NetworkInfo networkInfo;

  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Video>>> getFeed(
    FeedFilters filters,
    int page,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final videos = await remoteDataSource.getFeed(filters, page);
        await cacheDataSource.cacheFeed(videos);
        return Right(videos.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cachedVideos = await cacheDataSource.getCachedFeed();
        return Right(cachedVideos.map((m) => m.toEntity()).toList());
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
```

### 4.3 State Management: BLoC

```dart
// presentation/pages/feed/blocs/feed_bloc.dart
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedUseCase getFeedUseCase;
  final RefreshFeedUseCase refreshFeedUseCase;

  FeedBloc({
    required this.getFeedUseCase,
    required this.refreshFeedUseCase,
  }) : super(FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<LoadMoreFeed>(_onLoadMoreFeed);
    on<RefreshFeed>(_onRefreshFeed);
    on<ApplyFilters>(_onApplyFilters);
  }

  Future<void> _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());

    final result = await getFeedUseCase(
      FeedParams(filters: event.filters, page: 1),
    );

    result.fold(
      (failure) => emit(FeedError(failure.message)),
      (videos) => emit(FeedLoaded(
        videos: videos,
        hasMore: videos.length >= 10,
        currentPage: 1,
      )),
    );
  }

  Future<void> _onLoadMoreFeed(LoadMoreFeed event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is! FeedLoaded || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getFeedUseCase(
      FeedParams(
        filters: currentState.filters,
        page: currentState.currentPage + 1,
      ),
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newVideos) => emit(currentState.copyWith(
        videos: [...currentState.videos, ...newVideos],
        hasMore: newVideos.length >= 10,
        currentPage: currentState.currentPage + 1,
        isLoadingMore: false,
      )),
    );
  }
}

// feed_event.dart
abstract class FeedEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFeed extends FeedEvent {
  final FeedFilters? filters;
  LoadFeed({this.filters});
}

class LoadMoreFeed extends FeedEvent {}

class RefreshFeed extends FeedEvent {}

class ApplyFilters extends FeedEvent {
  final FeedFilters filters;
  ApplyFilters(this.filters);
}

// feed_state.dart
abstract class FeedState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Video> videos;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final FeedFilters? filters;

  FeedLoaded({
    required this.videos,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
    this.filters,
  });

  FeedLoaded copyWith({
    List<Video>? videos,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    FeedFilters? filters,
  }) {
    return FeedLoaded(
      videos: videos ?? this.videos,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [videos, hasMore, currentPage, isLoadingMore, filters];
}

class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
}
```

### 4.4 Navigation: GoRouter

```dart
// routes/app_router.dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final isLoggedIn = authNotifier.isLoggedIn;
    final isOnboarding = state.matchedLocation.startsWith('/onboarding');
    final isAuth = state.matchedLocation.startsWith('/auth');

    // Non authentifie -> login
    if (!isLoggedIn && !isAuth && !isOnboarding) {
      return '/auth/login';
    }

    // Authentifie sur page auth -> feed
    if (isLoggedIn && isAuth) {
      return '/feed';
    }

    return null;
  },
  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),

    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const WelcomePage(),
      routes: [
        GoRoute(
          path: 'role',
          builder: (context, state) => const RoleSelectionPage(),
        ),
      ],
    ),

    // Auth
    GoRoute(
      path: '/auth',
      redirect: (_, __) => '/auth/login',
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: 'register/:role',
          builder: (context, state) {
            final role = state.pathParameters['role']!;
            return RegisterPage(role: role);
          },
        ),
        GoRoute(
          path: 'forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
      ],
    ),

    // Main App (avec Shell pour navigation bottom)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/feed',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FeedPage(),
          ),
        ),
        GoRoute(
          path: '/messages',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ConversationsPage(),
          ),
          routes: [
            GoRoute(
              path: ':conversationId',
              builder: (context, state) {
                final id = state.pathParameters['conversationId']!;
                return ChatPage(conversationId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfilePage(),
          ),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => const EditProfilePage(),
            ),
          ],
        ),
        GoRoute(
          path: '/record',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: VideoRecordPage(),
          ),
        ),
      ],
    ),

    // Premium
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumPage(),
      routes: [
        GoRoute(
          path: 'checkout/:plan',
          builder: (context, state) {
            final plan = state.pathParameters['plan']!;
            return CheckoutPage(plan: plan);
          },
        ),
      ],
    ),

    // Settings
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'help',
          builder: (context, state) => const HelpPage(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => ErrorPage(error: state.error),
);
```

### 4.5 Modules Principaux

| Module | Responsabilite | Dependencies Cles |
|--------|----------------|-------------------|
| **Auth** | Connexion, inscription, session | supabase_flutter, flutter_secure_storage |
| **Video** | Enregistrement, upload, lecture | camera, video_player, chewie |
| **Feed** | Liste videos, filtres, pagination | cached_network_image, shimmer |
| **Messages** | Conversations, temps reel | supabase_flutter (realtime) |
| **Profile** | Gestion profil, stats | image_picker |
| **Payment** | Abonnements, achats | flutter_stripe |
| **Push** | Notifications | firebase_messaging |

---

## 5. Architecture Backend

### 5.1 API REST Design

#### Conventions

| Aspect | Convention |
|--------|------------|
| **Base URL** | `https://api.etoile-app.fr/v1` |
| **Format** | JSON |
| **Authentification** | Bearer Token (JWT) |
| **Versioning** | URL path (`/v1/`) |
| **Pagination** | Cursor-based (`?cursor=xxx&limit=10`) |
| **Erreurs** | RFC 7807 (Problem Details) |
| **Dates** | ISO 8601 (UTC) |

#### Endpoints Detailles

```yaml
# OpenAPI 3.0 Specification (resume)

paths:
  # ============ AUTH ============
  /auth/register:
    post:
      summary: Inscription utilisateur
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [email, password, role]
              properties:
                email: { type: string, format: email }
                password: { type: string, minLength: 8 }
                role: { type: string, enum: [seeker, recruiter] }
      responses:
        201: { description: Compte cree, verification email envoyee }
        400: { description: Donnees invalides }
        409: { description: Email deja utilise }

  /auth/login:
    post:
      summary: Connexion
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [email, password]
              properties:
                email: { type: string }
                password: { type: string }
      responses:
        200:
          description: Connexion reussie
          content:
            application/json:
              schema:
                type: object
                properties:
                  access_token: { type: string }
                  refresh_token: { type: string }
                  expires_in: { type: integer }
                  user: { $ref: '#/components/schemas/User' }
        401: { description: Identifiants invalides }

  /auth/refresh:
    post:
      summary: Rafraichir le token
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [refresh_token]
              properties:
                refresh_token: { type: string }
      responses:
        200: { description: Nouveau token }
        401: { description: Refresh token invalide }

  # ============ USERS ============
  /users/me:
    get:
      summary: Profil utilisateur courant
      security: [bearerAuth: []]
      responses:
        200:
          content:
            application/json:
              schema:
                oneOf:
                  - $ref: '#/components/schemas/SeekerProfile'
                  - $ref: '#/components/schemas/RecruiterProfile'

    patch:
      summary: Mettre a jour le profil
      security: [bearerAuth: []]
      requestBody:
        content:
          application/json:
            schema:
              type: object
              # Champs variables selon role
      responses:
        200: { description: Profil mis a jour }

  /users/{id}/public:
    get:
      summary: Profil public d'un utilisateur
      parameters:
        - name: id
          in: path
          required: true
          schema: { type: string, format: uuid }
      responses:
        200:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PublicProfile'

  # ============ VIDEOS ============
  /videos/upload-url:
    post:
      summary: Obtenir une URL presignee pour upload
      security: [bearerAuth: []]
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [category_id, content_type]
              properties:
                category_id: { type: string, format: uuid }
                content_type: { type: string, enum: [video/mp4, video/quicktime] }
                file_size: { type: integer }
      responses:
        200:
          content:
            application/json:
              schema:
                type: object
                properties:
                  upload_url: { type: string }
                  video_id: { type: string }
                  expires_at: { type: string, format: date-time }

  /videos/{id}/confirm:
    post:
      summary: Confirmer l'upload termine
      security: [bearerAuth: []]
      parameters:
        - name: id
          in: path
          required: true
          schema: { type: string, format: uuid }
      responses:
        200: { description: Video en traitement }

  /videos/feed:
    get:
      summary: Recuperer le feed de videos
      security: [bearerAuth: []]
      parameters:
        - name: type
          in: query
          schema: { type: string, enum: [seekers, recruiters] }
        - name: category
          in: query
          schema: { type: string }
        - name: region
          in: query
          schema: { type: string }
        - name: cursor
          in: query
          schema: { type: string }
        - name: limit
          in: query
          schema: { type: integer, default: 10, maximum: 50 }
      responses:
        200:
          content:
            application/json:
              schema:
                type: object
                properties:
                  videos:
                    type: array
                    items:
                      $ref: '#/components/schemas/FeedVideo'
                  next_cursor: { type: string, nullable: true }
                  has_more: { type: boolean }

  /videos/{id}:
    get:
      summary: Details d'une video
      parameters:
        - name: id
          in: path
          required: true
          schema: { type: string, format: uuid }
      responses:
        200:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Video'

    delete:
      summary: Supprimer une video
      security: [bearerAuth: []]
      responses:
        204: { description: Video supprimee }

  /videos/{id}/view:
    post:
      summary: Enregistrer une vue
      security: [bearerAuth: []]
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                watch_duration: { type: integer }
                completed: { type: boolean }
      responses:
        204: { description: Vue enregistree }

  # ============ MESSAGES ============
  /conversations:
    get:
      summary: Liste des conversations
      security: [bearerAuth: []]
      parameters:
        - name: cursor
          in: query
          schema: { type: string }
      responses:
        200:
          content:
            application/json:
              schema:
                type: object
                properties:
                  conversations:
                    type: array
                    items:
                      $ref: '#/components/schemas/ConversationPreview'
                  next_cursor: { type: string, nullable: true }

    post:
      summary: Demarrer une conversation
      security: [bearerAuth: []]
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [recipient_id, message]
              properties:
                recipient_id: { type: string, format: uuid }
                video_id: { type: string, format: uuid }
                message: { type: string, maxLength: 1000 }
      responses:
        201:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Conversation'

  /conversations/{id}/messages:
    get:
      summary: Messages d'une conversation
      security: [bearerAuth: []]
      parameters:
        - name: id
          in: path
          required: true
          schema: { type: string, format: uuid }
        - name: cursor
          in: query
          schema: { type: string }
      responses:
        200:
          content:
            application/json:
              schema:
                type: object
                properties:
                  messages:
                    type: array
                    items:
                      $ref: '#/components/schemas/Message'
                  next_cursor: { type: string, nullable: true }

    post:
      summary: Envoyer un message
      security: [bearerAuth: []]
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [content]
              properties:
                content: { type: string, maxLength: 1000 }
      responses:
        201:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Message'

  /conversations/{id}/read:
    post:
      summary: Marquer comme lu
      security: [bearerAuth: []]
      responses:
        204: { description: Marque comme lu }

  # ============ PAYMENTS ============
  /payments/subscribe:
    post:
      summary: Creer un abonnement
      security: [bearerAuth: []]
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [plan_type]
              properties:
                plan_type: { type: string, enum: [seeker_premium, recruiter_premium] }
      responses:
        200:
          content:
            application/json:
              schema:
                type: object
                properties:
                  client_secret: { type: string }
                  subscription_id: { type: string }

  /payments/subscription:
    get:
      summary: Statut de l'abonnement
      security: [bearerAuth: []]
      responses:
        200:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Subscription'

  /payments/purchase:
    post:
      summary: Achat a l'unite
      security: [bearerAuth: []]
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [product_type, quantity]
              properties:
                product_type: { type: string, enum: [video_credit, poster_credit] }
                quantity: { type: integer, minimum: 1 }
      responses:
        200:
          content:
            application/json:
              schema:
                type: object
                properties:
                  client_secret: { type: string }
                  purchase_id: { type: string }

  /payments/webhook:
    post:
      summary: Webhook Stripe
      requestBody:
        content:
          application/json:
            schema:
              type: object
      responses:
        200: { description: Webhook traite }

  # ============ ADMIN ============
  /admin/recruiters/pending:
    get:
      summary: Recruteurs en attente de verification
      security: [bearerAuth: []]
      responses:
        200:
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/RecruiterProfile'

  /admin/recruiters/{id}/verify:
    post:
      summary: Verifier un recruteur
      security: [bearerAuth: []]
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [action]
              properties:
                action: { type: string, enum: [approve, reject] }
                reason: { type: string }
      responses:
        200: { description: Action effectuee }

  /admin/reports:
    get:
      summary: Signalements en attente
      security: [bearerAuth: []]
      responses:
        200:
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Report'

  /admin/stats:
    get:
      summary: Statistiques globales
      security: [bearerAuth: []]
      responses:
        200:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AdminStats'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

### 5.2 Authentification JWT Flow

```
+----------+                                +----------+                    +----------+
|  Client  |                                | Supabase |                    | Database |
+----+-----+                                +----+-----+                    +----+-----+
     |                                           |                              |
     | 1. POST /auth/login (email, password)     |                              |
     |------------------------------------------>|                              |
     |                                           |                              |
     |                                           | 2. Verify credentials        |
     |                                           |----------------------------->|
     |                                           |                              |
     |                                           | 3. User data                 |
     |                                           |<-----------------------------|
     |                                           |                              |
     |                                           | 4. Generate JWT              |
     |                                           |   (access + refresh)         |
     |                                           |                              |
     | 5. { access_token, refresh_token, user }  |                              |
     |<------------------------------------------|                              |
     |                                           |                              |
     | 6. Store tokens securely                  |                              |
     |   (flutter_secure_storage)                |                              |
     |                                           |                              |
     |========================================== |==============================|
     |                                           |                              |
     | 7. GET /api/resource                      |                              |
     |    Authorization: Bearer <access_token>   |                              |
     |------------------------------------------>|                              |
     |                                           |                              |
     |                                           | 8. Validate JWT              |
     |                                           |   - Signature                |
     |                                           |   - Expiration               |
     |                                           |   - Claims                   |
     |                                           |                              |
     |                                           | 9. Extract user_id           |
     |                                           |   Apply RLS policies         |
     |                                           |----------------------------->|
     |                                           |                              |
     | 10. Response data                         |                              |
     |<------------------------------------------|                              |
     |                                           |                              |
     |========================================== |==============================|
     |                                           |                              |
     | 11. Access token expired                  |                              |
     |     POST /auth/refresh                    |                              |
     |     { refresh_token }                     |                              |
     |------------------------------------------>|                              |
     |                                           |                              |
     |                                           | 12. Validate refresh token   |
     |                                           |----------------------------->|
     |                                           |                              |
     | 13. New { access_token, refresh_token }   |                              |
     |<------------------------------------------|                              |
     |                                           |                              |
```

#### Configuration JWT

| Parametre | Valeur | Justification |
|-----------|--------|---------------|
| **Algorithme** | RS256 | Asymetrique, cles rotatives |
| **Access Token TTL** | 15 minutes | Securite, refresh frequent |
| **Refresh Token TTL** | 7 jours | UX, session longue |
| **Claims requis** | sub, role, email, iat, exp | Identification + autorisation |

### 5.3 Gestion des Videos

#### Flow Upload

```
+----------+                    +----------+                    +-------------+
|  Client  |                    |  Backend |                    | Cloudflare  |
|  Flutter |                    | Supabase |                    |     R2      |
+----+-----+                    +----+-----+                    +------+------+
     |                               |                                 |
     | 1. POST /videos/upload-url    |                                 |
     |   { category_id, size }       |                                 |
     |------------------------------>|                                 |
     |                               |                                 |
     |                               | 2. Validate quota               |
     |                               |    Generate video_id            |
     |                               |                                 |
     |                               | 3. Create presigned URL         |
     |                               |    (via Workers)                |
     |                               |-------------------------------->|
     |                               |                                 |
     |                               |<--------------------------------|
     |                               |                                 |
     | 4. { upload_url, video_id }   |                                 |
     |<------------------------------|                                 |
     |                                                                 |
     | 5. PUT upload_url             |                                 |
     |    [video binary]             |                                 |
     |---------------------------------------------------------------->|
     |                                                                 |
     |                               |                                 |
     | 6. 200 OK                     |                                 |
     |<----------------------------------------------------------------|
     |                               |                                 |
     | 7. POST /videos/{id}/confirm  |                                 |
     |------------------------------>|                                 |
     |                               |                                 |
     |                               | 8. Trigger processing           |
     |                               |    - Validate duration (40s)    |
     |                               |    - Generate thumbnail         |
     |                               |    - Create CDN URL             |
     |                               |                                 |
     |                               | 9. Update video status          |
     |                               |    (processing -> active)       |
     |                               |                                 |
     | 10. { video: {...} }          |                                 |
     |<------------------------------|                                 |
     |                               |                                 |
     | 11. Realtime subscription     |                                 |
     |    (video status updates)     |                                 |
     |<=============================>|                                 |
```

#### Transcoding (Optionnel MVP+)

Pour le MVP, pas de transcoding cote serveur. Les videos sont:
- Enregistrees en 1080p via l'app (camera native)
- Compressees cote client avant upload
- Servies en qualite originale

Post-MVP, envisager:
- Cloudflare Stream pour transcoding automatique
- Adaptive bitrate streaming (HLS/DASH)
- Plusieurs resolutions (1080p, 720p, 480p)

### 5.4 WebSocket pour Messagerie Temps Reel

```dart
// Cote client Flutter - Supabase Realtime

class MessageRealtimeService {
  final SupabaseClient supabase;
  RealtimeChannel? _channel;

  MessageRealtimeService(this.supabase);

  void subscribeToConversation(String conversationId, Function(Message) onMessage) {
    _channel = supabase.channel('conversation:$conversationId');

    _channel!
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'conversation_id',
          value: conversationId,
        ),
        callback: (payload) {
          final message = Message.fromJson(payload.newRecord);
          onMessage(message);
        },
      )
      .subscribe();
  }

  void subscribeToAllConversations(String userId, Function(Conversation) onUpdate) {
    _channel = supabase.channel('user_conversations:$userId');

    _channel!
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'conversations',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.or,
          filters: [
            PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'participant_1',
              value: userId,
            ),
            PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'participant_2',
              value: userId,
            ),
          ],
        ),
        callback: (payload) {
          final conversation = Conversation.fromJson(payload.newRecord);
          onUpdate(conversation);
        },
      )
      .subscribe();
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}
```

---

## 6. Securite

### 6.1 Authentification / Autorisation

| Couche | Implementation |
|--------|----------------|
| **Transport** | TLS 1.3 obligatoire, HSTS |
| **Auth** | JWT RS256 via Supabase Auth |
| **Password** | bcrypt (cost 12), politique complexite |
| **Session** | Refresh token rotation |
| **MFA** | Non MVP, a envisager V2 |

#### Politique Mots de Passe

```javascript
// Validation cote serveur (Edge Function)
const passwordPolicy = {
  minLength: 8,
  maxLength: 128,
  requireUppercase: false,  // Simplifie pour MVP
  requireNumber: false,
  requireSpecial: false,
  // Verification contre liste de mots de passe compromis
  checkBreached: true,
};
```

### 6.2 Protection des Donnees

| Donnee | Protection | Stockage |
|--------|------------|----------|
| **Mots de passe** | bcrypt hash | PostgreSQL |
| **Tokens** | Chiffrement AES-256 | flutter_secure_storage |
| **Videos** | URLs signees temporaires | Cloudflare R2 |
| **Documents recruteurs** | Acces restreint | Supabase Storage (prive) |
| **PII** | Chiffrement at-rest | PostgreSQL (Supabase) |

#### Row Level Security (RLS)

```sql
-- Les utilisateurs ne peuvent voir que leurs propres donnees sensibles
CREATE POLICY "Users can only view own subscription" ON subscriptions
    FOR SELECT USING (auth.uid() = user_id);

-- Les recruteurs verifies peuvent voir les profils chercheurs
CREATE POLICY "Verified recruiters can view seeker profiles" ON seeker_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM recruiter_profiles rp
            WHERE rp.user_id = auth.uid()
            AND rp.verification_status = 'verified'
        )
    );

-- Les chercheurs peuvent voir les offres des recruteurs verifies
CREATE POLICY "Seekers can view verified recruiter videos" ON videos
    FOR SELECT USING (
        type = 'offer'
        AND status = 'active'
        AND EXISTS (
            SELECT 1 FROM recruiter_profiles rp
            WHERE rp.user_id = videos.user_id
            AND rp.verification_status = 'verified'
        )
    );

-- Blocages effectifs
CREATE POLICY "Blocked users cannot view blocker content" ON videos
    FOR SELECT USING (
        NOT EXISTS (
            SELECT 1 FROM blocks
            WHERE blocks.blocker_id = videos.user_id
            AND blocks.blocked_id = auth.uid()
        )
    );
```

### 6.3 Rate Limiting

| Endpoint | Limite | Fenetre | Justification |
|----------|--------|---------|---------------|
| `/auth/login` | 5 | 15 min | Anti-brute force |
| `/auth/register` | 3 | 1 heure | Anti-spam |
| `/videos/upload-url` | 10 | 1 heure | Limite uploads |
| `/messages/send` | 60 | 1 min | Anti-spam |
| `/feed` | 100 | 1 min | Usage normal |
| `Global` | 1000 | 1 min | Protection DDoS |

```typescript
// Cloudflare Worker - Rate Limiting
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const clientIP = request.headers.get('CF-Connecting-IP') || 'unknown';
    const path = new URL(request.url).pathname;

    // Determiner la limite selon le path
    const limits = {
      '/auth/login': { limit: 5, window: 900 },
      '/auth/register': { limit: 3, window: 3600 },
      '/videos/upload-url': { limit: 10, window: 3600 },
      default: { limit: 1000, window: 60 },
    };

    const config = limits[path] || limits.default;
    const key = `rate:${clientIP}:${path}`;

    // Utiliser Cloudflare KV ou Durable Objects
    const current = await env.RATE_LIMIT.get(key);
    const count = current ? parseInt(current) : 0;

    if (count >= config.limit) {
      return new Response(JSON.stringify({
        type: 'https://api.etoile-app.fr/errors/rate-limit',
        title: 'Too Many Requests',
        status: 429,
        detail: `Rate limit exceeded. Try again in ${config.window} seconds.`,
      }), {
        status: 429,
        headers: {
          'Content-Type': 'application/problem+json',
          'Retry-After': config.window.toString(),
        },
      });
    }

    // Incrementer le compteur
    await env.RATE_LIMIT.put(key, (count + 1).toString(), {
      expirationTtl: config.window,
    });

    // Continuer vers l'origine
    return fetch(request);
  },
};
```

### 6.4 Validation SIRET

#### MVP: Validation Manuelle

```typescript
// Edge Function: Verification manuelle via back-office
export async function verifyRecruiter(recruiterId: string, action: 'approve' | 'reject', reason?: string) {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

  if (action === 'approve') {
    await supabase
      .from('recruiter_profiles')
      .update({
        verification_status: 'verified',
        verified_at: new Date().toISOString(),
        verified_by: adminUserId,
      })
      .eq('user_id', recruiterId);

    // Envoyer email de confirmation
    await sendEmail({
      to: recruiterEmail,
      template: 'recruiter_verified',
      data: { companyName },
    });
  } else {
    await supabase
      .from('recruiter_profiles')
      .update({
        verification_status: 'rejected',
        rejection_reason: reason,
      })
      .eq('user_id', recruiterId);

    await sendEmail({
      to: recruiterEmail,
      template: 'recruiter_rejected',
      data: { companyName, reason },
    });
  }
}
```

#### V2: Validation Automatique (API INSEE)

```typescript
// Future implementation avec API Sirene
interface SireneResponse {
  etablissement: {
    siret: string;
    denominationUniteLegale: string;
    etatAdministratifEtablissement: 'A' | 'F'; // A=Actif, F=Ferme
    dateCreationEtablissement: string;
  };
}

export async function validateSiret(siret: string): Promise<ValidationResult> {
  // Appel API INSEE Sirene
  const response = await fetch(
    `https://api.insee.fr/entreprises/sirene/V3/siret/${siret}`,
    {
      headers: {
        'Authorization': `Bearer ${INSEE_API_TOKEN}`,
      },
    }
  );

  if (!response.ok) {
    return { valid: false, reason: 'SIRET introuvable' };
  }

  const data: SireneResponse = await response.json();

  if (data.etablissement.etatAdministratifEtablissement === 'F') {
    return { valid: false, reason: 'Etablissement ferme' };
  }

  return {
    valid: true,
    companyName: data.etablissement.denominationUniteLegale,
    creationDate: data.etablissement.dateCreationEtablissement,
  };
}
```

---

## 7. Scalabilite

### 7.1 Strategie de Scaling

#### Phase 1: MVP (500 users simultanes)

```
                    +------------------+
                    |   Cloudflare     |
                    |   CDN + WAF      |
                    +--------+---------+
                             |
              +--------------+--------------+
              |                             |
    +---------v---------+         +---------v---------+
    |    Supabase       |         |   Cloudflare R2   |
    |   (Free/Pro)      |         |   (Pay as you go) |
    |                   |         |                   |
    | - PostgreSQL 500MB|         | - Videos          |
    | - 50k MAU Auth    |         | - Thumbnails      |
    | - 5GB bandwidth   |         | - 0$ egress       |
    | - Edge Functions  |         |                   |
    +-------------------+         +-------------------+
```

**Configuration:**
- Supabase Pro: 1 instance
- R2: 1 bucket videos, 1 bucket thumbnails
- CDN: Cache agressif sur videos

#### Phase 2: Croissance (2000 users simultanes)

```
                    +------------------+
                    |   Cloudflare     |
                    |   CDN + WAF      |
                    |   + Workers      |
                    +--------+---------+
                             |
    +------------------------+------------------------+
    |                        |                        |
+---v---+              +-----v-----+            +-----v-----+
|Supabase|             |  Supabase |            |Cloudflare |
|  Pro   |             |  Realtime |            |    R2     |
|        |             |  (Scale)  |            |           |
+---+----+             +-----------+            +-----------+
    |
    v
+---+----+
|PostgreSQL|
| Replica  |
| (Read)   |
+----------+
```

**Ajouts:**
- Read replica PostgreSQL
- Workers pour logique edge
- Realtime connections augmentees

#### Phase 3: Scale (10000+ users simultanes)

```
                         +------------------+
                         |   Cloudflare     |
                         |   Enterprise     |
                         +--------+---------+
                                  |
         +------------------------+------------------------+
         |                        |                        |
+--------v--------+      +--------v--------+      +--------v--------+
|   Load Balancer |      |   Load Balancer |      |   Cloudflare    |
|     (API)       |      |   (Realtime)    |      |   Stream        |
+--------+--------+      +--------+--------+      +--------+--------+
         |                        |                        |
    +----+----+              +----+----+                   |
    |         |              |         |                   |
+---v---+ +---v---+      +---v---+ +---v---+          +----v----+
|Supabase| |Supabase|    |Realtime| |Realtime|        |  R2     |
|Node 1  | |Node 2  |    |Node 1  | |Node 2  |        | Multi   |
+---+----+ +---+----+    +--------+ +--------+        +---------+
    |           |
    +-----+-----+
          |
   +------v------+
   |  PostgreSQL |
   |   Cluster   |
   | (Primary +  |
   |  Replicas)  |
   +-------------+
```

**Ajouts:**
- PostgreSQL cluster avec replicas
- Multiple instances Supabase
- Cloudflare Stream pour transcoding
- Sharding eventuel par region

### 7.2 Caching Strategy

| Niveau | Technologie | Donnees | TTL |
|--------|-------------|---------|-----|
| **CDN Edge** | Cloudflare | Videos, thumbnails | 1 an |
| **API Cache** | Cloudflare Workers KV | Feed, categories | 5 min |
| **Database** | PostgreSQL | Query results | N/A (connexions) |
| **Client** | Hive | Feed, messages, profil | Variable |

#### Implementation Cache Client

```dart
// data/datasources/local/cache_datasource.dart
class CacheDataSource {
  static const String feedBoxName = 'feed_cache';
  static const String profileBoxName = 'profile_cache';
  static const String messagesBoxName = 'messages_cache';

  late Box<dynamic> _feedBox;
  late Box<dynamic> _profileBox;
  late Box<dynamic> _messagesBox;

  Future<void> init() async {
    _feedBox = await Hive.openBox(feedBoxName);
    _profileBox = await Hive.openBox(profileBoxName);
    _messagesBox = await Hive.openBox(messagesBoxName);
  }

  // Feed cache avec expiration
  Future<List<VideoModel>?> getCachedFeed(String cacheKey) async {
    final cached = _feedBox.get(cacheKey);
    if (cached == null) return null;

    final expiry = DateTime.parse(cached['expiry']);
    if (DateTime.now().isAfter(expiry)) {
      await _feedBox.delete(cacheKey);
      return null;
    }

    return (cached['videos'] as List)
        .map((v) => VideoModel.fromJson(v))
        .toList();
  }

  Future<void> cacheFeed(String cacheKey, List<VideoModel> videos) async {
    await _feedBox.put(cacheKey, {
      'videos': videos.map((v) => v.toJson()).toList(),
      'expiry': DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
    });
  }

  // Preloading videos
  Future<void> preloadNextVideos(List<String> videoUrls) async {
    for (final url in videoUrls.take(3)) {
      // Utiliser cached_network_image ou flutter_cache_manager
      await DefaultCacheManager().downloadFile(url);
    }
  }
}
```

### 7.3 CDN Configuration

```yaml
# cloudflare-config.yaml (conceptuel)

zones:
  - name: etoile-app.fr
    ssl:
      mode: full_strict
      min_tls_version: "1.2"

    cache:
      # Videos - cache long
      page_rules:
        - match: "*.etoile-videos-prod.r2.cloudflarestorage.com/*"
          cache_level: cache_everything
          edge_cache_ttl: 31536000  # 1 an
          browser_cache_ttl: 86400  # 1 jour

        # Thumbnails - cache moyen
        - match: "*.etoile-thumbnails-prod.r2.cloudflarestorage.com/*"
          cache_level: cache_everything
          edge_cache_ttl: 604800  # 1 semaine
          browser_cache_ttl: 86400

        # API - pas de cache
        - match: "api.etoile-app.fr/*"
          cache_level: bypass

    security:
      waf: enabled
      ddos_protection: enabled
      bot_management: enabled
      rate_limiting:
        enabled: true
        threshold: 1000
        period: 60

    performance:
      polish: lossy
      brotli: enabled
      early_hints: enabled
      rocket_loader: disabled  # Pas de JS cote CDN
```

---

## 8. Infrastructure

### 8.1 Environnements

| Environnement | Usage | URL | Base de donnees |
|---------------|-------|-----|-----------------|
| **Development** | Dev local | localhost:3000 | Supabase local (Docker) |
| **Staging** | Tests, QA | staging.etoile-app.fr | Supabase projet staging |
| **Production** | Utilisateurs | api.etoile-app.fr | Supabase projet prod |

#### Configuration par Environnement

```dart
// lib/core/config/environment.dart
enum Environment { development, staging, production }

class EnvironmentConfig {
  final Environment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String stripePublishableKey;
  final String sentryDsn;
  final bool enableLogging;

  const EnvironmentConfig._({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.stripePublishableKey,
    required this.sentryDsn,
    required this.enableLogging,
  });

  static const development = EnvironmentConfig._(
    environment: Environment.development,
    supabaseUrl: 'http://localhost:54321',
    supabaseAnonKey: 'eyJ...',
    stripePublishableKey: 'pk_test_...',
    sentryDsn: '',
    enableLogging: true,
  );

  static const staging = EnvironmentConfig._(
    environment: Environment.staging,
    supabaseUrl: 'https://xxxxx.supabase.co',
    supabaseAnonKey: 'eyJ...',
    stripePublishableKey: 'pk_test_...',
    sentryDsn: 'https://xxx@sentry.io/xxx',
    enableLogging: true,
  );

  static const production = EnvironmentConfig._(
    environment: Environment.production,
    supabaseUrl: 'https://yyyyy.supabase.co',
    supabaseAnonKey: 'eyJ...',
    stripePublishableKey: 'pk_live_...',
    sentryDsn: 'https://yyy@sentry.io/yyy',
    enableLogging: false,
  );

  static EnvironmentConfig get current {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    switch (env) {
      case 'production':
        return production;
      case 'staging':
        return staging;
      default:
        return development;
    }
  }
}
```

### 8.2 CI/CD Pipeline

```yaml
# .github/workflows/main.yml

name: Etoile Mobile CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: '3.19.0'
  JAVA_VERSION: '17'

jobs:
  # ========== ANALYSE & TESTS ==========
  analyze:
    name: Analyze & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze --fatal-infos

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  # ========== BUILD ANDROID ==========
  build-android:
    name: Build Android
    needs: analyze
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    steps:
      - uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: ${{ env.JAVA_VERSION }}

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Decode keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks
          echo "${{ secrets.ANDROID_KEY_PROPERTIES }}" > android/key.properties

      - name: Set environment
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            echo "BUILD_ENV=production" >> $GITHUB_ENV
          else
            echo "BUILD_ENV=staging" >> $GITHUB_ENV
          fi

      - name: Build APK
        run: |
          flutter build apk --release \
            --dart-define=ENV=${{ env.BUILD_ENV }} \
            --build-number=${{ github.run_number }}

      - name: Build App Bundle
        run: |
          flutter build appbundle --release \
            --dart-define=ENV=${{ env.BUILD_ENV }} \
            --build-number=${{ github.run_number }}

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab

  # ========== BUILD IOS ==========
  build-ios:
    name: Build iOS
    needs: analyze
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install CocoaPods
        run: |
          cd ios
          pod install --repo-update

      - name: Setup signing
        env:
          IOS_CERTIFICATE_BASE64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          IOS_PROVISIONING_PROFILE_BASE64: ${{ secrets.IOS_PROVISIONING_PROFILE_BASE64 }}
        run: |
          # Decode and install certificate
          echo "$IOS_CERTIFICATE_BASE64" | base64 -d > certificate.p12
          security create-keychain -p "" build.keychain
          security import certificate.p12 -k build.keychain -P "${{ secrets.IOS_CERTIFICATE_PASSWORD }}" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple: -s -k "" build.keychain

          # Install provisioning profile
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo "$IOS_PROVISIONING_PROFILE_BASE64" | base64 -d > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision

      - name: Set environment
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            echo "BUILD_ENV=production" >> $GITHUB_ENV
          else
            echo "BUILD_ENV=staging" >> $GITHUB_ENV
          fi

      - name: Build iOS
        run: |
          flutter build ipa --release \
            --dart-define=ENV=${{ env.BUILD_ENV }} \
            --build-number=${{ github.run_number }} \
            --export-options-plist=ios/ExportOptions.plist

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ios-release
          path: build/ios/ipa/*.ipa

  # ========== DEPLOY STAGING ==========
  deploy-staging:
    name: Deploy to Staging
    needs: [build-android, build-ios]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: staging
    steps:
      - name: Download Android artifact
        uses: actions/download-artifact@v4
        with:
          name: android-release
          path: artifacts/android

      - name: Download iOS artifact
        uses: actions/download-artifact@v4
        with:
          name: ios-release
          path: artifacts/ios

      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_ANDROID_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_CREDENTIALS }}
          groups: internal-testers
          file: artifacts/android/app-release.apk

      - name: Upload iOS to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: artifacts/ios/*.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}

  # ========== DEPLOY PRODUCTION ==========
  deploy-production:
    name: Deploy to Production
    needs: [build-android, build-ios]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4

      - name: Upload to Google Play (Internal)
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
          packageName: fr.etoileapp.mobile
          releaseFiles: android-release/app-release.aab
          track: internal
          status: completed

      - name: Upload to App Store Connect
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: ios-release/*.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
```

### 8.3 Monitoring et Alerting

#### Stack de Monitoring

| Outil | Usage | Configuration |
|-------|-------|---------------|
| **Sentry** | Error tracking, performance | SDK Flutter + Edge Functions |
| **Uptime Robot** | Availability monitoring | Endpoints critiques |
| **Supabase Dashboard** | Database metrics | Inclus dans Supabase |
| **Cloudflare Analytics** | Traffic, CDN, security | Inclus dans Cloudflare |
| **Stripe Dashboard** | Paiements | Inclus dans Stripe |

#### Configuration Sentry

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = EnvironmentConfig.current.sentryDsn;
      options.environment = EnvironmentConfig.current.environment.name;
      options.tracesSampleRate = 0.2;  // 20% des transactions
      options.profilesSampleRate = 0.1;  // 10% des profils
      options.attachScreenshot = true;
      options.attachViewHierarchy = true;

      // Ne pas envoyer en dev
      if (EnvironmentConfig.current.environment == Environment.development) {
        options.dsn = '';
      }
    },
    appRunner: () => runApp(const EtoileApp()),
  );
}

// Usage dans le code
class VideoRepository {
  Future<void> uploadVideo(File file) async {
    final transaction = Sentry.startTransaction('video.upload', 'task');
    try {
      // Upload logic...
      transaction.status = SpanStatus.ok();
    } catch (e, stackTrace) {
      transaction.status = SpanStatus.internalError();
      Sentry.captureException(e, stackTrace: stackTrace);
      rethrow;
    } finally {
      await transaction.finish();
    }
  }
}
```

#### Alertes Configurees

| Alerte | Condition | Canal | Severite |
|--------|-----------|-------|----------|
| **API Down** | Uptime < 99% sur 5 min | SMS + Email | Critical |
| **Error Spike** | > 50 errors/min | Slack + Email | High |
| **Slow Response** | P95 > 2s | Slack | Medium |
| **Database Full** | Storage > 80% | Email | Medium |
| **Payment Failure** | > 5% failed | SMS + Email | High |
| **Video Upload Fail** | > 10% failed | Slack | Medium |

---

## 9. Estimations Techniques

### 9.1 Couts Infrastructure Mensuels

#### MVP (0-5000 utilisateurs)

| Service | Tier | Cout Mensuel | Notes |
|---------|------|--------------|-------|
| **Supabase** | Pro | 25$ | 8GB DB, 250k auth, 50GB bandwidth |
| **Cloudflare** | Free | 0$ | CDN, DNS, basic security |
| **Cloudflare R2** | Pay as you go | ~20$ | 100GB stockage, egress gratuit |
| **Stripe** | Standard | ~2.9% + 0.30$ | Par transaction |
| **Resend** | Free | 0$ | 3000 emails/mois |
| **Sentry** | Team | 26$ | 50k events |
| **Apple Developer** | Annual | 8$/mois | 99$/an |
| **Google Play** | One-time | ~2$/mois | 25$ unique |
| **Uptime Robot** | Free | 0$ | 50 monitors |
| **Total MVP** | | **~85$/mois** | Hors transactions Stripe |

#### Croissance (5000-15000 utilisateurs)

| Service | Tier | Cout Mensuel | Notes |
|---------|------|--------------|-------|
| **Supabase** | Pro + addons | 75$ | Read replica, more storage |
| **Cloudflare** | Pro | 20$ | WAF, analytics |
| **Cloudflare R2** | Pay as you go | ~80$ | 500GB stockage |
| **Cloudflare Workers** | Paid | 5$ | 10M requests |
| **Resend** | Pro | 20$ | 50k emails/mois |
| **Sentry** | Team | 52$ | 100k events |
| **Total Croissance** | | **~260$/mois** | |

#### Scale (15000+ utilisateurs)

| Service | Tier | Cout Mensuel | Notes |
|---------|------|--------------|-------|
| **Supabase** | Team | 599$ | Priorite support, SLA |
| **Cloudflare** | Business | 200$ | Advanced security |
| **Cloudflare R2** | Pay as you go | ~200$ | 2TB stockage |
| **Cloudflare Stream** | Pay as you go | ~300$ | Transcoding |
| **Resend** | Enterprise | 100$ | 100k+ emails |
| **Sentry** | Business | 80$ | 500k events |
| **Total Scale** | | **~1500$/mois** | |

### 9.2 Complexite par Module

| Module | Complexite | Temps Estime | Risques |
|--------|------------|--------------|---------|
| **Auth & Profils** | Moyenne | 2 semaines | Integration Supabase Auth |
| **Enregistrement Video** | Haute | 3 semaines | Camera native, permissions |
| **Upload & Processing** | Haute | 2 semaines | Presigned URLs, validation |
| **Feed Vertical** | Moyenne | 2 semaines | Performances, preloading |
| **Filtres & Recherche** | Basse | 1 semaine | Queries PostgreSQL |
| **Messagerie Temps Reel** | Haute | 2 semaines | WebSocket, sync offline |
| **Notifications Push** | Moyenne | 1 semaine | FCM/APNs integration |
| **Paiements Stripe** | Haute | 2 semaines | Webhooks, edge cases |
| **Back-Office Admin** | Moyenne | 1.5 semaines | Interface web simple |
| **Tests & Polish** | Moyenne | 2 semaines | E2E, performance |

**Total estime: 18-20 semaines** (avec 1-2 devs Flutter + 1 dev backend)

### 9.3 Estimation Stockage Video

| Parametre | Valeur |
|-----------|--------|
| Duree video | 40 secondes |
| Resolution | 1080p |
| Bitrate cible | 4 Mbps |
| Taille par video | ~20 MB |
| Thumbnail | ~50 KB |

#### Projection Stockage

| Utilisateurs | Videos Estimees | Stockage Total |
|--------------|-----------------|----------------|
| 1 000 | 1 500 | 30 GB |
| 5 000 | 7 500 | 150 GB |
| 15 000 | 22 500 | 450 GB |
| 50 000 | 75 000 | 1.5 TB |

---

## 10. Decisions d'Architecture (ADR)

### ADR-001: Choix de Flutter comme Framework Mobile

**Statut:** Accepte

**Contexte:**
Etoile necessite une application mobile pour iOS et Android avec une experience utilisateur de haute qualite, notamment pour l'enregistrement et la lecture video.

**Decision:**
Utiliser Flutter 3.x comme framework de developpement cross-platform.

**Alternatives considerees:**
| Option | Avantages | Inconvenients |
|--------|-----------|---------------|
| Flutter | Une codebase, performances natives, hot reload | Taille app plus grande |
| React Native | Large communaute, bridge natif | Performances video moins bonnes |
| Native (Swift/Kotlin) | Performances optimales | Double codebase, cout x2 |

**Consequences:**
- (+) Reduction de 40% du temps de developpement
- (+) Maintenance simplifiee
- (+) Acces aux fonctionnalites camera natives via plugins
- (-) Taille de l'application plus importante (~50MB)
- (-) Dependance a l'ecosysteme Flutter

---

### ADR-002: Supabase comme Backend-as-a-Service

**Statut:** Accepte

**Contexte:**
Le MVP necessite un backend robuste avec authentification, base de donnees, temps reel, et fonctions serverless. L'equipe est reduite et le time-to-market est critique.

**Decision:**
Utiliser Supabase comme BaaS principal.

**Alternatives considerees:**
| Option | Avantages | Inconvenients |
|--------|-----------|---------------|
| Supabase | PostgreSQL, open-source, RLS | Moins mature que Firebase |
| Firebase | Ecosysteme Google, mature | Firestore NoSQL, vendor lock-in |
| Custom (Node.js) | Controle total | Temps de dev x3, infra a gerer |

**Consequences:**
- (+) Time-to-market accelere de 50%
- (+) PostgreSQL standard, migration future possible
- (+) Row Level Security integre
- (+) Realtime natif pour messagerie
- (-) Dependance a Supabase (mitigee par self-hosting possible)

---

### ADR-003: Cloudflare R2 pour le Stockage Video

**Statut:** Accepte

**Contexte:**
Le stockage et la distribution de videos representent potentiellement le cout le plus important de l'infrastructure. Les videos sont consultees frequemment (feed TikTok-like).

**Decision:**
Utiliser Cloudflare R2 pour le stockage video avec distribution via CDN Cloudflare.

**Alternatives considerees:**
| Option | Avantages | Inconvenients |
|--------|-----------|---------------|
| Cloudflare R2 | Egress gratuit, API S3 | Moins mature que S3 |
| AWS S3 + CloudFront | Mature, fiable | Egress couteux (~0.09$/GB) |
| Supabase Storage | Integration native | Moins performant pour video |
| Backblaze B2 | Pas cher | CDN a ajouter |

**Consequences:**
- (+) Economies majeures sur le trafic (egress gratuit vs ~0.09$/GB S3)
- (+) CDN edge global inclus
- (+) API compatible S3
- (-) Service plus recent, moins de retours d'experience

**Estimation economies:**
- 10 000 vues/jour x 20MB = 200GB egress/jour
- AWS S3: 200GB x 30j x 0.09$ = 540$/mois en egress seul
- R2: 0$ egress

---

### ADR-004: BLoC comme Pattern de State Management

**Statut:** Accepte

**Contexte:**
L'application a plusieurs etats complexes (auth, feed avec pagination, messagerie temps reel, upload video). Un pattern de state management robuste est necessaire.

**Decision:**
Utiliser le pattern BLoC (Business Logic Component) avec le package `flutter_bloc`.

**Alternatives considerees:**
| Option | Avantages | Inconvenients |
|--------|-----------|---------------|
| BLoC | Separation claire, testable, scalable | Verbeux, courbe d'apprentissage |
| Riverpod | Moderne, moins verbeux | Plus recent, moins de ressources |
| Provider | Simple, officiel Google | Moins structure pour apps complexes |
| GetX | Tres simple | Moins de separation, debat qualite |

**Consequences:**
- (+) Architecture claire et maintenable
- (+) Excellente testabilite (unit tests BLoC)
- (+) Separation UI / Business Logic
- (-) Plus de boilerplate code
- (-) Courbe d'apprentissage pour nouveaux devs

---

### ADR-005: URLs Presignees pour Upload Video

**Statut:** Accepte

**Contexte:**
Les utilisateurs uploadent des videos de ~20MB. L'upload doit etre fiable, reprendable, et ne pas surcharger le backend.

**Decision:**
Utiliser des URLs presignees R2 generees par le backend. L'upload se fait directement du client vers R2.

**Flow:**
1. Client demande URL presignee au backend
2. Backend valide les quotas, genere l'URL, cree l'entree DB
3. Client uploade directement vers R2
4. Client confirme l'upload au backend
5. Backend valide et traite la video

**Alternatives considerees:**
| Option | Avantages | Inconvenients |
|--------|-----------|---------------|
| Presigned URL | Direct client→storage, scalable | Plus complexe a implementer |
| Proxy backend | Simple | Bande passante backend, latence |
| Multipart via API | Resume possible | Complexite, charge serveur |

**Consequences:**
- (+) Pas de charge sur le backend pour le transfert
- (+) Upload direct, plus rapide
- (+) Scalabilite illimitee
- (-) Implementation plus complexe
- (-) Gestion des echecs a coder cote client

---

### ADR-006: Pas de Transcoding Video MVP

**Statut:** Accepte

**Contexte:**
Le transcoding video (conversion en plusieurs resolutions, formats) est couteux et complexe. La duree video est fixee a 40 secondes.

**Decision:**
Pour le MVP, pas de transcoding cote serveur. Les videos sont:
- Compressees cote client (1080p, H.264)
- Servies en qualite originale
- Validees (duree 40s max) mais pas re-encodees

**Post-MVP:**
- Evaluer Cloudflare Stream pour transcoding automatique
- Implementer adaptive bitrate si necessaire

**Consequences:**
- (+) Simplicite d'implementation
- (+) Couts reduits (pas de transcoding)
- (+) Time-to-market plus rapide
- (-) Pas d'adaptation au reseau (3G vs WiFi)
- (-) Videos potentiellement plus lourdes

---

### ADR-007: JWT avec Refresh Token Rotation

**Statut:** Accepte

**Contexte:**
L'authentification doit etre securisee tout en offrant une bonne UX (pas de reconnexion frequente).

**Decision:**
- Access Token: JWT, 15 minutes de validite
- Refresh Token: Opaque, 7 jours, rotation a chaque utilisation
- Stockage: flutter_secure_storage (Keychain iOS, Keystore Android)

**Consequences:**
- (+) Securite: tokens courts, rotation
- (+) UX: session longue sans reconnexion
- (+) Revocation possible via refresh token
- (-) Complexite: gestion du refresh automatique

---

### ADR-008: Messagerie via Supabase Realtime

**Statut:** Accepte

**Contexte:**
La messagerie entre chercheurs et recruteurs doit etre en temps reel pour une experience moderne.

**Decision:**
Utiliser Supabase Realtime (base sur Phoenix Channels) pour la messagerie instantanee.

**Alternatives considerees:**
| Option | Avantages | Inconvenients |
|--------|-----------|---------------|
| Supabase Realtime | Integre, PostgreSQL triggers | Moins flexible |
| Firebase Realtime DB | Mature, hors-ligne | Vendor lock-in, NoSQL |
| Pusher/Ably | Specialise, fiable | Cout supplementaire |
| Custom WebSocket | Controle total | Complexe a scaler |

**Consequences:**
- (+) Integration native avec la DB
- (+) Pas de service supplementaire
- (+) Row Level Security appliquee
- (-) Moins de fonctionnalites que solutions dediees
- (-) Scalabilite a surveiller

---

### ADR-009: Verification Manuelle des Recruteurs MVP

**Statut:** Accepte

**Contexte:**
La verification des recruteurs (SIRET, justificatifs) est critique pour la confiance. L'API INSEE Sirene necessite un contrat et de l'integration.

**Decision:**
MVP: Verification manuelle via back-office admin. Les admins valident les SIRET et documents uploades.

**Post-MVP:**
- Integration API INSEE Sirene
- Verification automatique du SIRET
- Score de confiance base sur plusieurs signaux

**Consequences:**
- (+) Time-to-market plus rapide
- (+) Controle qualite humain
- (-) Non scalable (temps admin)
- (-) Delai de verification (24-48h)

---

### ADR-010: Architecture Clean avec Repository Pattern

**Statut:** Accepte

**Contexte:**
L'application doit etre maintenable, testable, et evolutive sur le long terme.

**Decision:**
Appliquer Clean Architecture avec 3 couches:
1. **Presentation** (UI, BLoCs)
2. **Domain** (Entities, UseCases, Repository interfaces)
3. **Data** (Repository impl, DataSources, Models)

**Consequences:**
- (+) Testabilite excellente (mock des repositories)
- (+) Separation des responsabilites
- (+) Changement de backend facilite
- (+) Onboarding nouveaux devs structure
- (-) Plus de code boilerplate
- (-) Sur-ingenierie pour petites features

---

## Annexes

### A. Checklist Pre-Deploiement

- [ ] Tests unitaires > 80% coverage
- [ ] Tests d'integration API passes
- [ ] Tests E2E parcours critiques
- [ ] Revue securite (OWASP Mobile Top 10)
- [ ] Performance: chargement < 2s
- [ ] Accessibilite: VoiceOver/TalkBack testes
- [ ] Analytics configures (Sentry, events)
- [ ] Mentions legales, CGU, politique confidentialite
- [ ] Assets stores (icones, screenshots, descriptions)
- [ ] Variables d'environnement production
- [ ] Backup database configure
- [ ] Monitoring et alertes actifs
- [ ] Runbook d'incident documente

### B. Contacts et Ressources

| Ressource | Lien |
|-----------|------|
| Documentation Supabase | https://supabase.com/docs |
| Documentation Cloudflare R2 | https://developers.cloudflare.com/r2 |
| Documentation Flutter | https://docs.flutter.dev |
| Documentation Stripe | https://stripe.com/docs |
| BLoC Library | https://bloclibrary.dev |

---

*Document redige par Winston, Architecte Technique Senior*
*Derniere mise a jour: 2026-02-01*
