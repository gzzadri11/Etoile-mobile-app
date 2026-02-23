---
sourceDocument: prd-etoile-draft.md
extractedFrom: "Section Spécifications Techniques"
date: 2026-02-18
status: draft
author: John (PM) → extrait pour validation architecte
---

# Architecture Technique - Etoile Mobile App

> Ce document a été extrait du PRD pour respecter la séparation des responsabilités (PRD = quoi, Architecture = comment).

## Architecture Globale

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            CLIENTS                                       │
│  ┌─────────────────┐                    ┌─────────────────┐             │
│  │  iOS App        │                    │  Android App    │             │
│  │  (Flutter/Dart) │                    │  (Flutter/Dart) │             │
│  └────────┬────────┘                    └────────┬────────┘             │
└───────────┼──────────────────────────────────────┼──────────────────────┘
            │                                      │
            └──────────────┬───────────────────────┘
                           │ HTTPS
                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         CLOUDFLARE                                       │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐     │
│  │      CDN        │    │    Workers      │    │       R2        │     │
│  │  (Cache global) │    │  (Edge compute) │    │ (Stockage vidéo)│     │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘     │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     SUPABASE (Backend-as-a-Service)                      │
│                                  │                                       │
│         ┌────────────────────────┼────────────────────────┐             │
│         ▼                        ▼                        ▼             │
│  ┌─────────────┐         ┌─────────────┐         ┌─────────────┐       │
│  │ PostgreSQL  │         │  Realtime   │         │   Stripe    │       │
│  │ (Database)  │         │ (WebSocket) │         │ (Paiements) │       │
│  └─────────────┘         └─────────────┘         └─────────────┘       │
│         │                                                │              │
│         ▼                                                ▼              │
│  ┌─────────────┐         ┌─────────────┐         ┌─────────────┐       │
│  │ Edge Funct. │         │  SMS OTP    │         │ Email OTP   │       │
│  │ (Push notif)│         │(Twilio/etc) │         │(Resend/etc) │       │
│  └─────────────┘         └─────────────┘         └─────────────┘       │
└─────────────────────────────────────────────────────────────────────────┘
```

## Stack Technique

| Couche | Technologie | Justification |
|--------|-------------|---------------|
| **Frontend** | Flutter 3.x / Dart | Cross-platform iOS + Android, une seule codebase |
| **Backend** | Supabase | Auth intégrée, PostgreSQL, temps réel, open-source |
| **Base de données** | PostgreSQL | Robuste, scalable, support JSON natif |
| **Stockage vidéo** | Cloudflare R2 | Egress gratuit, compatible S3, CDN intégré |
| **CDN** | Cloudflare | Performance globale, protection DDoS |
| **Paiements** | Stripe | Fiabilité, API moderne, conformité PCI |
| **Email** | Resend ou SendGrid | OTP email + notifications transactionnelles |
| **SMS OTP** | Twilio ou Vonage | Validation téléphone chercheurs |
| **Push notifications** | Firebase Cloud Messaging | Alertes filtrées + messages |
| **Monitoring** | Sentry + Uptime Robot | Erreurs temps réel, alertes uptime |

## Modèle de Données Simplifié

```sql
-- Table Utilisateurs
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    role            VARCHAR(20) NOT NULL CHECK (role IN ('seeker', 'recruiter', 'admin')),
    email_verified  BOOLEAN DEFAULT FALSE,
    phone_verified  BOOLEAN DEFAULT FALSE,
    is_premium      BOOLEAN DEFAULT FALSE,
    profile_completion INTEGER DEFAULT 0, -- 0 à 100
    status          VARCHAR(20) DEFAULT 'active',
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Profils Chercheurs
CREATE TABLE seeker_profiles (
    user_id         UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    phone           VARCHAR(20),
    photo_url       VARCHAR(500),
    country         VARCHAR(100) DEFAULT 'France',
    city            VARCHAR(100),
    category        VARCHAR(100),
    contract_type   VARCHAR(50),
    experience      VARCHAR(50),
    sector          VARCHAR(100),
    availability    VARCHAR(50),
    situation       VARCHAR(50),
    diploma         VARCHAR(100),
    bio             TEXT,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Profils Recruteurs
CREATE TABLE recruiter_profiles (
    user_id         UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    company_name    VARCHAR(255) NOT NULL,
    siret           VARCHAR(14),
    siret_verified  BOOLEAN DEFAULT FALSE,
    logo_url        VARCHAR(500),
    cover_url       VARCHAR(500),
    description     TEXT,
    sector          VARCHAR(100),
    locations       TEXT[],
    map_markers     JSONB,
    verification_status VARCHAR(20) DEFAULT 'pending',
    verified_at     TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Vidéos
CREATE TABLE videos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            VARCHAR(20) NOT NULL CHECK (type IN ('presentation', 'offer', 'poster')),
    category        VARCHAR(100),
    title           VARCHAR(255),
    contract_type   VARCHAR(50),
    url             VARCHAR(500) NOT NULL,
    thumbnail_url   VARCHAR(500),
    duration        INTEGER,
    status          VARCHAR(20) DEFAULT 'active',
    views_count     INTEGER DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at      TIMESTAMP WITH TIME ZONE
);

-- Table Dossiers de candidature
CREATE TABLE application_folders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id        UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    owner_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    applications_count INTEGER DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Candidatures (dans les dossiers)
CREATE TABLE folder_applications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    folder_id       UUID NOT NULL REFERENCES application_folders(id) ON DELETE CASCADE,
    applicant_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message         TEXT,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(folder_id, applicant_id)
);

-- Table Conversations
CREATE TABLE conversations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participant_1   UUID NOT NULL REFERENCES users(id),
    participant_2   UUID NOT NULL REFERENCES users(id),
    video_id        UUID REFERENCES videos(id),
    last_message_at TIMESTAMP WITH TIME ZONE,
    last_message_preview TEXT,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(participant_1, participant_2)
);

-- Table Messages
CREATE TABLE messages (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id),
    sender_id       UUID NOT NULL REFERENCES users(id),
    content         TEXT NOT NULL,
    content_type    VARCHAR(20) DEFAULT 'text',
    is_read         BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Alertes filtrées
CREATE TABLE alerts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(255),
    filters         JSONB NOT NULL,
    frequency       VARCHAR(20) NOT NULL CHECK (frequency IN ('daily', 'every_2_days', 'weekly')),
    is_active       BOOLEAN DEFAULT TRUE,
    last_sent_at    TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Abonnements
CREATE TABLE subscriptions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan            VARCHAR(50) NOT NULL,
    stripe_subscription_id VARCHAR(255),
    stripe_customer_id     VARCHAR(255),
    status          VARCHAR(20) DEFAULT 'active',
    current_period_start   TIMESTAMP WITH TIME ZONE,
    current_period_end     TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Blocages
CREATE TABLE blocks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id      UUID NOT NULL REFERENCES users(id),
    blocked_id      UUID NOT NULL REFERENCES users(id),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(blocker_id, blocked_id)
);

-- Index pour performances
CREATE INDEX idx_videos_user_id ON videos(user_id);
CREATE INDEX idx_videos_category ON videos(category);
CREATE INDEX idx_videos_status ON videos(status);
CREATE INDEX idx_folders_owner ON application_folders(owner_id);
CREATE INDEX idx_folders_video ON application_folders(video_id);
CREATE INDEX idx_folder_apps_folder ON folder_applications(folder_id);
CREATE INDEX idx_folder_apps_applicant ON folder_applications(applicant_id);
CREATE INDEX idx_alerts_user ON alerts(user_id);
CREATE INDEX idx_alerts_active ON alerts(is_active, frequency);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_seeker_profiles_category ON seeker_profiles(category);
CREATE INDEX idx_seeker_profiles_city ON seeker_profiles(city);
```

## Sécurité

| Aspect | Implémentation |
|--------|----------------|
| **Authentification** | Email OTP + mot de passe compte, JWT avec refresh tokens |
| **Validation identité** | OTP email (tous), OTP SMS (chercheurs), SIRET (recruteurs) |
| **Transport** | HTTPS obligatoire (TLS 1.2+) |
| **Stockage mot de passe** | bcrypt (cost factor 12) |
| **Rate Limiting** | 100 req/min par IP, 5 OTP/heure par email/téléphone |
| **Upload vidéo** | Presigned URLs (pas d'upload direct vers API) |
| **Données personnelles** | Visibles uniquement par recruteurs vérifiés |
| **CORS** | Domaines autorisés uniquement |

---

*Extrait du PRD le 2026-02-18 — À compléter par l'architecte (Winston)*
