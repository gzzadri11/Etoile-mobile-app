---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments:
  - prd-etoile-draft.md
  - architecture-etoile.md
  - architecture-etoile-draft.md
  - ux-design-etoile-draft.md
workflowType: 'architecture'
lastStep: 8
status: 'complete'
completedAt: '2026-02-18'
project_name: 'Etoile Mobile App'
user_name: 'Developer'
date: '2026-02-18'
---

# Architecture Decision Document — Etoile Mobile App

_Ce document se construit collaborativement par etapes. Les sections sont ajoutees au fur et a mesure des decisions architecturales._

---

## Project Context Analysis

### Requirements Overview

**Functional Requirements (9 Epics, 32 US) :**

| Epic | US | Complexite archi |
|------|-----|-----------------|
| 1. Onboarding, Inscription, Profil | 12 US (1.0-1.11) | Haute — OTP email+SMS, completude 5x20%, gates, suppression RGPD |
| 2. Video Chercheur | 4 US (2.1-2.4) | Haute — camera in-app, upload R2, tuto mascotte, dossiers auto |
| 3. Video/Affiche Recruteur | 4 US (3.1-3.4) | Moyenne — import + enregistrement, 3 types publication, credits |
| 4. Feed et Decouverte | 5 US (4.1-4.5) | Haute — feed TikTok, prechargement, filtres multi-criteres, postulation + dossiers |
| 5. Messagerie et Dossiers | 4 US (5.1-5.4) | Haute — temps reel, dossiers auto, vue recruteur/chercheur, blocage |
| 6. Paiements | 4 US (6.1-6.4) | Haute — Stripe direct (argument service reel), portail web recruteurs |
| 7. Administration | 3 US (7.1-7.3) | Moyenne — SIRET validation, moderation, stats |
| 8. Support | 2 US (8.1-8.2) | Basse — FAQ, formulaire contact |
| 9. Alertes Filtrees | 3 US (9.1-9.3) | Moyenne — CRON digest, push notification, filtres configurables |

**Non-Functional Requirements :**

| NFR | Implication architecturale |
|-----|---------------------------|
| Performance (video < 2s) | CDN edge, prechargement, compression video |
| Temps reel (messagerie) | WebSocket persistent, Supabase Realtime |
| SLA 99.5% | Architecture serverless, pas de SPOF |
| RGPD complet | Suppression cascade, export JSON, consentement, registre |
| Anti-discrimination | Pas de traitement biometrique automatise, avertissements |
| Mode offline | Cache local Hive, queue messages, retry automatique |
| A11y WCAG AA | Semantique, contraste 4.5:1, screen readers |
| Paiements | Stripe direct (service recrutement = monde reel), plan B IAP si rejet Apple |

**Scale & Complexity :**

- Domaine principal : **Mobile full-stack** (Flutter cross-platform)
- Niveau de complexite : **Haute**
- Composants architecturaux estimes : **15-20**

### Technical Constraints & Dependencies

| Contrainte | Impact |
|------------|--------|
| Flutter cross-platform (iOS + Android) | Une seule codebase, packages natifs pour camera/gallery/push |
| Categorie App Store : Business/Recruitment | Stripe direct legal (service monde reel, pas contenu digital) |
| Plan B si rejet Apple | RevenueCat ou Apple IAP en fallback |
| Cloudflare R2 (egress gratuit) | Upload via presigned URLs, streaming CDN |
| Supabase (PostgreSQL + Realtime + Edge Functions) | Auth, BDD, temps reel, logique serveur |
| Firebase Cloud Messaging | Push notifications cross-platform |
| OTP Email + SMS | Supabase Auth natif (email) + Twilio via Edge Function (SMS) |
| France uniquement V1 | Pas de i18n, pas de multi-devise |

### Cross-Cutting Concerns

1. **Completude profil (gates)** — Trigger SQL + cache client + RLS policies
2. **Authentification multi-canal** — Supabase Auth (email OTP) + Twilio (SMS OTP) + mot de passe
3. **RGPD** — Suppression cascade, export JSON, consentement, registre traitements
4. **Paiements** — Stripe direct (argument service reel) + portail web recruteurs + plan B IAP
5. **Dossiers auto** — Trigger PostgreSQL a la publication
6. **Notifications** — Push (messages, alertes digest), in-app

---

## Architecture Decision Records (ADR)

### ADR-001 : Systeme de paiements

**Contexte** : Etoile est une plateforme de mise en relation professionnelle (recrutement). Les abonnements et credits servent a faciliter le recrutement (service du monde reel), pas a consommer du contenu digital. Cela ouvre la possibilite d'utiliser Stripe direct, comme LinkedIn, Indeed, Airbnb.

**Decision : Stripe direct in-app (strategie "service du monde reel") + portail web recruteurs**

| Utilisateur | Methode de paiement | Commission | Justification |
|-------------|---------------------|------------|---------------|
| Chercheur premium (4,99€/mois) | Stripe direct in-app | ~3% | Outils de recrutement = service reel |
| Recruteur premium (499€/mois) | Stripe via portail web | ~3% | B2B, facture entreprise, montant eleve |
| Credits unitaires (99€/49€) | Stripe direct in-app | ~3% | Credits de publication = outil professionnel |

**Strategie App Store :**
- Categorie : **Business** ou **Recruitment** (pas Entertainment/Social)
- Description : "Plateforme de recrutement par video" (pas "app de contenu video")
- Les videos ne sont pas du "contenu a vendre" mais des "CV video" = outils professionnels

**Plan B si rejet Apple :**
- Basculer sur RevenueCat (SDK unifie Apple IAP + Google Play + Stripe)
- RevenueCat gratuit < 2 500$/mois de revenu, puis 1%
- Migration simple : remplacer les appels Stripe par RevenueCat SDK

**Trade-offs :**
- (+) Economie massive : ~3% vs 15-30% de commission
- (+) Controle total sur l'experience de paiement
- (+) Facturation entreprise native (Stripe Billing)
- (-) Risque de rejet App Store (mitige par le plan B)
- (-) Necessite un argument solide lors du review Apple

**Package Flutter** : `flutter_stripe` (Stripe SDK) — plan B : `purchases_flutter` (RevenueCat)

---

### ADR-002 : Architecture de la completude profil (gates)

**Contexte** : 5 categories x 20% = 100%. Sous 100%, publication et postulation bloquees. Ce gate affecte presque toutes les features.

**Decision : Hybride (trigger SQL + cache client + RLS)**

**Implementation :**
1. Colonne `profile_completion INTEGER DEFAULT 0` dans table `users`
2. Trigger PostgreSQL `AFTER UPDATE` sur `seeker_profiles` et `recruiter_profiles` :
   - Calcule le % en verifiant chaque categorie (champs non-null)
   - Met a jour `users.profile_completion`
3. Flutter lit `profile_completion` depuis le profil utilisateur (cache local)
4. RLS policies sur `videos` et `folder_applications` : `WHERE auth.uid() IN (SELECT id FROM users WHERE profile_completion = 100)`

**Trade-offs :**
- (+) Source de verite unique (serveur), non contournable
- (+) UX rapide (cache client pour affichage barre)
- (+) RLS bloque les actions cote serveur — securise
- (-) Deux endroits a maintenir (trigger SQL + affichage Flutter)

---

### ADR-003 : OTP Email + SMS

**Contexte** : Double verification pour les chercheurs (email + telephone). Recruteurs : email uniquement.

**Decision : Supabase Auth natif (email OTP) + Twilio via Edge Function (SMS)**

**Implementation :**
1. **Email OTP** : Supabase Auth `.signUp()` → email OTP automatique → `.verifyOtp()`
2. **SMS OTP** : Edge Function `send-sms-otp` :
   - Genere un code 6 chiffres
   - Stocke dans table `sms_verifications` (user_id, code, phone, expires_at)
   - Appelle Twilio API pour envoyer le SMS
   - Flutter envoie le code → Edge Function `verify-sms-otp` verifie et met a jour `users.phone_verified`
3. **Rate limiting** : 5 OTP/heure par email ou telephone (anti-abus)

**Trade-offs :**
- (+) Supabase Auth gere nativement l'email OTP (zero code custom)
- (+) Twilio = provider SMS fiable, API simple
- (-) Deux systemes differents (Supabase Auth + Edge Function custom)
- (-) Cout SMS Twilio (~0.05€/SMS, negligeable au MVP)

---

### ADR-004 : Dossiers de candidature — creation automatique

**Contexte** : A chaque publication (offre/poster), un dossier est auto-cree. Les postulations y atterrissent.

**Decision : Trigger PostgreSQL sur INSERT videos**

**Implementation :**
```sql
CREATE OR REPLACE FUNCTION create_application_folder()
RETURNS trigger AS $$
BEGIN
  IF NEW.type IN ('offer', 'poster') THEN
    INSERT INTO application_folders (video_id, owner_id, name)
    VALUES (NEW.id, NEW.user_id, COALESCE(NEW.title, 'Sans titre'));
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_folder
AFTER INSERT ON videos
FOR EACH ROW EXECUTE FUNCTION create_application_folder();
```

**Trade-offs :**
- (+) Atomique, garanti, zero risque de desync
- (+) Meme pattern que `trigger_create_profile` (deja eprouve)
- (-) Couplage fort BDD, logique invisible dans le code Flutter

---

### ADR-005 : Mode offline et cache local

**Contexte** : Cache local pour profil, feed recent, queue d'envoi messages.

**Decision : Hive (NoSQL local)**

**Implementation :**
- Box `user_profile` : profil utilisateur cache
- Box `feed_cache` : derniers items du feed
- Box `pending_messages` : messages en attente d'envoi (videe au retour connexion)
- Chiffrement Hive active pour les donnees sensibles
- `ConnectivityPlus` pour detecter l'etat reseau → banniere si offline

**Trade-offs :**
- (+) Rapide, leger, chiffrement natif
- (+) Simple pour du cache MVP
- (-) Pas de requetes complexes (pas SQL)

---

### ADR-006 : Feed TikTok — prechargement video

**Contexte** : Feed vertical, prechargement 2 videos suivantes, mix videos + affiches.

**Decision : PageView + pool de VideoPlayerControllers (deja implemente Sprint 5)**

**Implementation :**
- Pool de 3 controllers : current + 2 next
- Dispose le controller precedent quand on scroll
- Affiches : `Image.network` avec `precacheImage()`
- Algorithme feed : matching (region, metier) + rotation aleatoire

**Trade-offs :**
- (+) Confirme et fonctionnel depuis Sprint 5
- (+) Controle total sur la memoire
- (-) Gestion manuelle du lifecycle des controllers

---

## Starter Template Evaluation

**Projet existant** — Sprints 1-11 complets + FR29. Pas de starter template a appliquer.

**Stack confirme :**
- Flutter 3.38.9 / Dart (cross-platform iOS + Android)
- Supabase (PostgreSQL + Realtime + Edge Functions + Auth)
- Cloudflare R2 + Workers (stockage video, presigned URLs)
- Firebase Cloud Messaging (push notifications)
- BLoC pattern (state management)
- GoRouter (navigation)
- Hive (cache local)

**Structure existante :** Feature-first (`lib/features/{feature}/data|presentation/`)

**Decision :** Pas de changement de structure. Continuer avec l'architecture existante qui a fait ses preuves sur 11 sprints.

---

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (bloquent l'implementation) :**
- RLS par role (securite de toutes les tables)
- RGPD Art. 17 : soft delete + purge 30 jours
- RGPD Art. 15/20 : export JSON via Edge Function
- Double validation (client + serveur)

**Important Decisions (structurent l'architecture) :**
- Convention Edge Functions (verb-noun, reponse JSON standard)
- Gestion d'erreurs BLoC (ErrorState + traduction francais)
- Firebase Crashlytics (monitoring)
- Design system centralise (app_theme.dart)
- Tests critiques (repositories + BLoCs)
- Moderation manuelle (table reports)

**Decisions differees (post-MVP) :**
- Compression video (ffmpeg_kit_flutter) → apres validation UX avec limites taille
- CI/CD Codemagic (build iOS) → au moment du release App Store
- 2e projet Supabase (dev/prod) → avant release store
- Accessibilite complete WCAG AA → progressif
- Sentry performance monitoring → si Crashlytics insuffisant
- Moderation IA hybride → quand volume > 100 videos/jour

---

### Cat. 1 — Data Architecture

#### 1.1 Validation des donnees

**Decision : Double validation (client + serveur)**
- **Flutter** : validation UX dans les formulaires (feedback immediat, messages francais)
- **PostgreSQL** : contraintes SQL (CHECK, NOT NULL, FK, triggers) comme filet de securite
- **RLS** : controle d'acces par `auth.uid()` + `users.role`
- **Edge Functions** : validation metier complexe (SIRET, credits, etc.)
- **Rationale** : Securise + bonne UX. Pattern deja en place, on le formalise.
- **Affecte** : Toutes les epics

#### 1.2 Pipeline video

**Decision : Limite taille + resolution client (MVP) → compression ffmpeg Phase 2**
- Camera forcee a 720p/30fps, duree max 42s
- Rejet import si fichier > 50 MB
- Pas de re-encoding client au MVP (evite ffmpeg_kit_flutter +30 MB APK)
- **Rationale** : Compromis simple, 720p suffisant pour video mobile, TikTok fait pareil
- **Affecte** : Epic 2 (Video Chercheur), Epic 3 (Video Recruteur)
- **Evolution** : ffmpeg_kit_flutter quand l'UX le justifie

#### 1.3 Migrations BDD

**Decision : Supabase CLI + seed data**
- Fichiers SQL numerotes dans `supabase/migrations/` (YYYYMMDDHHMMSS_description.sql)
- Application via `supabase db push`
- Fichier `supabase/seed.sql` pour donnees de test reproductibles
- **Rationale** : Reproductibilite, onboarding dev, zero risque en prod
- **Affecte** : Toutes les epics

---

### Cat. 2 — Securite & RGPD

#### 2.1 RLS Policies

**Decision : Pattern par role (auth.uid() + users.role)**

Pattern universel pour chaque table :
```sql
-- SELECT propre : l'utilisateur voit ses donnees
CREATE POLICY "select_own" ON {table} FOR SELECT USING (user_id = auth.uid());

-- SELECT role : recruteurs voient profils chercheurs
CREATE POLICY "recruiters_select" ON {table} FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'recruiter')
);

-- WRITE propre : uniquement ses donnees
CREATE POLICY "update_own" ON {table} FOR UPDATE USING (user_id = auth.uid());

-- Admin : acces total
CREATE POLICY "admin_all" ON {table} FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
```
- **Rationale** : Source de verite BDD (pas JWT cache), pattern coherent, deja en place partiellement
- **Affecte** : Toutes les tables

#### 2.2 RGPD

**Art. 15 — Droit d'acces :** Edge Function `export-user-data` → JSON telecharge
- Donnees : user + profil + videos (metadata) + messages + candidatures + alertes + abonnements + consentements
- MVP : export synchrone. Evolution vers async + email si timeout.

**Art. 17 — Droit a l'effacement :** Soft delete + purge 30 jours
1. Bouton "Supprimer mon compte" → confirmation + mot de passe
2. `UPDATE users SET status = 'deleted', deleted_at = NOW()`
3. RLS filtre `WHERE status != 'deleted'` (invisible partout)
4. CRON quotidien purge apres 30 jours → CASCADE supprime tout
5. Edge Function post-delete supprime fichiers R2 (videos, images)

**Art. 20 — Portabilite :** Meme Edge Function que Art. 15, format JSON standard

- **Rationale** : Soft delete = grace period, protection piratage, standard industrie (LinkedIn, Facebook)
- **Affecte** : Epic 1 (US-1.10 Suppression compte)

#### 2.3 Moderation

**Decision : Moderation manuelle (MVP) → hybride IA Phase 2**
- Table `reports` (reporter_id, reported_user/video, reason, status)
- Raisons : inappropriate, discrimination, fake, other
- Workflow : pending → reviewed → action_taken / dismissed
- **Rationale** : Volume faible au lancement, zero faux positif, gratuit
- **Affecte** : Epic 7 (Administration), US-1.11 (Signaler)

#### 2.4 Rate Limiting

**Decision : Supabase natif + compteur OTP custom**
- Auth rate limiting integre Supabase (30 req/h)
- SMS OTP : compteur BDD (max 5/heure par numero)
- **Rationale** : Suffisant MVP, pas besoin de Cloudflare WAF payant
- **Affecte** : Epic 1 (OTP)

---

### Cat. 3 — API & Communication

#### 3.1 Convention Edge Functions

**Decision : Convention REST-like (verb-noun)**
- Nommage : `verb-noun` kebab-case (send-push, export-user-data, check-siret)
- Reponse standard : `{ "success": true/false, "data": {...}, "error": "..." }`
- Codes HTTP : 200 (succes), 400 (validation), 401 (auth), 500 (serveur)
- Auth : Bearer token JWT Supabase

**Edge Functions prevues :**
| Fonction | Epic | Statut |
|----------|------|--------|
| send-push | 9 | Deployee |
| send-sms-otp | 1 | A creer |
| verify-sms-otp | 1 | A creer |
| export-user-data | 1 (RGPD) | A creer |
| delete-user-data | 1 (RGPD) | A creer |
| stripe-webhook | 6 | A creer |
| check-siret | 7 | A creer |

#### 3.2 Gestion d'erreurs Flutter

**Decision : Pattern BLoC Error State + helper traduction**
- Chaque BLoC emet un `ErrorState(message)` en cas d'erreur
- UI affiche via `BlocListener` + `SnackBar`
- Helper `translateSupabaseError()` pour messages francais :
  - AuthException → "Email ou mot de passe incorrect", "Verifiez votre email"
  - PostgrestException 23505 → "Cette donnee existe deja"
  - PostgrestException 42501 → "Action non autorisee"
  - Defaut → "Une erreur est survenue"
- **Affecte** : Toutes les epics

#### 3.3 Communication entre services

**Decision : Pattern actuel (SDK directs + webhooks)**
- Flutter → Supabase : SDK `supabase_flutter`
- Flutter → Worker CF : HTTP direct
- Flutter → Firebase : SDK `firebase_messaging`
- Supabase → Firebase : Database Webhook → Edge Function
- Supabase → Stripe : Edge Function webhook
- URLs centralisees dans `app_config.dart`
- **Rationale** : Simple, fonctionne, pas besoin d'API Gateway pour le MVP

---

### Cat. 4 — Frontend (Flutter)

#### 4.1 Strategie de tests

**Decision : Tests critiques uniquement (repositories + BLoCs)**

Priorite 1 (bloquant) : Repositories
- video_repository_test.dart
- profile_repository_test.dart
- conversation_repository_test.dart

Priorite 2 (important) : BLoCs
- auth_bloc_test.dart
- feed_bloc_test.dart
- video_bloc_test.dart

Priorite 3 (post-MVP) : Widget tests + Integration tests

**Outils** : flutter_test, mocktail, bloc_test
- **Rationale** : Compromis couverture/effort, teste les couches qui cassent le plus

#### 4.2 Design System

**Decision : Constantes + ThemeData (fichier app_theme.dart)**
- `AppColors` : primary (orange), secondary, background, success, error, text
- `AppSpacing` : xs(4), sm(8), md(16), lg(24), xl(32)
- `AppTheme.light` : ThemeData complet
- Migration progressive des widgets existants
- **Affecte** : Toutes les pages

#### 4.3 Accessibilite

**Decision : Semantique de base (MVP) → WCAG AA complet progressivement**
- Tous les `IconButton` ont un `tooltip`
- Toutes les images ont un `semanticLabel`
- Contraste minimum 4.5:1 (attention : orange #FF6B35 sur blanc = 3.2:1, insuffisant)
- Tailles texte minimum 14sp
- Zones tactiles minimum 48x48 dp
- **Affecte** : Toutes les pages

#### 4.4 Performance

**Decision : Conventions formalisees (pas d'action immediate)**
- Images : `cached_network_image` + placeholder shimmer
- Videos : Pool 3 controllers (ADR-006)
- Listes : `ListView.builder` (jamais `ListView(children:)`)
- Rebuild : `const` constructors, `BlocSelector` quand possible
- Bundle : tree-shaking natif Flutter

---

### Cat. 5 — Infrastructure & Deploiement

#### 5.1 CI/CD

**Decision : GitHub Actions (MVP) → + Codemagic au release store**
- Pipeline : checkout → flutter pub get → flutter analyze → flutter test
- Runner : ubuntu-latest (gratuit, 2000 min/mois)
- Trigger : push + pull_request
- **Evolution** : Codemagic pour build + signing iOS au moment du release App Store

#### 5.2 Monitoring

**Decision : Firebase Crashlytics**
- Deja Firebase integre (FCM) → ajout minimal
- `FlutterError.onError` + `PlatformDispatcher.instance.onError` → Crashlytics
- Gratuit sans limite
- **Evolution** : Sentry si besoin de performance monitoring

#### 5.3 Environnements

**Decision : 1 projet Supabase (MVP) → 2 projets avant release**
- Actuellement : un seul projet (dev = prod)
- Comptes de test clairement identifies (emma@gmail.com)
- Avant release store : creer projet prod, garder actuel comme dev
- Config via `String.fromEnvironment` dans app_config.dart

#### 5.4 Scaling

**Decision : Documenter les seuils, pas d'action immediate**
- 0-10K users : Supabase free/pro suffit
- 10K-100K : Supabase Pro (25$/mois), index optimises, pagination curseur
- 100K-1M : R2 egress gratuit, Supabase Team (599$/mois)
- 1M+ : Supabase Enterprise ou infra custom
- **Action immediate** : pagination curseur (WHERE created_at < X) au lieu de OFFSET

---

### Decision Impact Analysis

**Sequence d'implementation recommandee :**
1. RLS policies (Cat. 2.1) — securise toutes les tables existantes
2. Crashlytics (Cat. 5.2) — monitoring avant nouvelles features
3. app_theme.dart (Cat. 4.2) — base design system
4. Error handler (Cat. 3.2) — translateSupabaseError()
5. Edge Functions conventions (Cat. 3.1) — avant de creer les prochaines
6. Limite video 50MB/720p (Cat. 1.2) — avant de deployer la camera
7. Tests critiques (Cat. 4.1) — en parallele des nouveaux sprints
8. seed.sql (Cat. 1.3) — pour reproductibilite
9. RGPD soft delete (Cat. 2.2) — avant release store
10. Table reports (Cat. 2.3) — avant release store
11. GitHub Actions CI (Cat. 5.1) — avant release store
12. 2e projet Supabase (Cat. 5.3) — juste avant release store

**Dependances croisees :**
- RGPD (2.2) necessite Edge Functions conventions (3.1)
- Tests (4.1) necessitent seed.sql (1.3) pour donnees de test
- Monitoring (5.2) doit etre en place avant chaque nouveau sprint
- CI/CD (5.1) necessite tests (4.1) pour etre utile

---

## Implementation Patterns & Consistency Rules

### Points de conflit identifies : 12 zones

| # | Zone | Resolution |
|---|------|-----------|
| 1 | Nommage tables/colonnes SQL | snake_case pluriel / snake_case |
| 2 | Nommage fichiers Dart | snake_case.dart |
| 3 | Nommage BLoC events/states | PascalCase VerbNom / EtatNom |
| 4 | Format JSON BDD ↔ Dart | snake_case BDD, camelCase Dart, conversion dans fromJson/toJson |
| 5 | Structure dossiers features | feature-first avec data/ + presentation/ |
| 6 | Placement des tests | test/features/{name}/ miroir de lib/ |
| 7 | Format reponses Edge Functions | { success, data, error } standard |
| 8 | Loading states | Loading → Loaded/Error dans chaque BLoC |
| 9 | Format dates | TIMESTAMPTZ en BDD, ISO 8601 en JSON, locale en UI |
| 10 | Import paths | Package imports absolus (pas de ../../) |
| 11 | Null handling | Dart null safety strict, ?? pour fallbacks |
| 12 | Constantes | AppColors, AppSpacing, AppConfig (pas en dur) |

### Naming Patterns

**Base de donnees PostgreSQL :**
- Tables : snake_case pluriel → `users`, `seeker_profiles`, `application_folders`
- Colonnes : snake_case → `user_id`, `created_at`, `profile_completion`
- Foreign keys : `{table_singulier}_id` → `user_id`, `video_id`, `folder_id`
- Index : `idx_{table}_{colonne}` → `idx_videos_user_id`
- Triggers : `trigger_{action}_{objet}` → `trigger_create_profile`
- Functions : `{action}_{objet}()` → `create_application_folder()`

**Dart / Flutter :**
- Fichiers : snake_case.dart → `video_model.dart`, `feed_bloc.dart`
- Classes : PascalCase → `VideoModel`, `FeedBloc`, `AppRouter`
- Variables : camelCase → `userId`, `contractType`, `isLoading`
- Constantes globales : camelCase → `maxVideoSize`, `apiTimeout`
- BLoC Events : PascalCase verbe+nom → `LoadFeed`, `PublishVideo`, `SendMessage`
- BLoC States : PascalCase etat+nom → `FeedLoading`, `FeedLoaded`, `FeedError`
- Enum values : camelCase → `ContractType.cdi`, `UserRole.seeker`

**Conversion BDD ↔ Dart :**
```dart
// fromJson : snake_case → camelCase
contractType: json['contract_type'] as String?

// toJson : camelCase → snake_case
'contract_type': contractType
```

### Structure Patterns

**Arborescence feature :**
```
lib/features/{feature_name}/
├── data/
│   ├── models/          → {name}_model.dart (fromJson/toJson)
│   └── repositories/    → {name}_repository.dart (appels Supabase)
└── presentation/
    ├── bloc/            → {name}_bloc.dart, {name}_event.dart, {name}_state.dart
    ├── pages/           → {name}_page.dart (pages completes avec Scaffold)
    └── widgets/         → {name}_widget.dart (composants reutilisables)
```

**Fichiers partages :**
```
lib/core/
├── config/              → app_config.dart (URLs, constantes globales)
├── router/              → app_router.dart (GoRouter, toutes les routes)
├── services/            → services transversaux (push, upload)
├── theme/               → app_theme.dart (AppColors, AppSpacing, AppTheme)
└── utils/               → helpers (error_translator.dart)

lib/shared/widgets/      → widgets reutilises entre features
```

**Tests :**
```
test/features/{feature_name}/
├── data/repositories/   → {name}_repository_test.dart
└── presentation/bloc/   → {name}_bloc_test.dart

test/core/utils/         → error_translator_test.dart
```

### Format Patterns

**Edge Functions — reponse standard :**
```json
{ "success": true, "data": { ... } }              // 200
{ "success": false, "error": "Message francais" }  // 400/401/500
```

**Dates :**
- BDD : `TIMESTAMPTZ` (ISO 8601 avec timezone)
- JSON/API : ISO 8601 string → `"2026-02-18T14:30:00+01:00"`
- Flutter UI : format local → `"18 fev. 2026"` ou `"il y a 2h"` (package intl)

**Null handling Dart :**
- Toujours utiliser null safety (`String?` pour nullable)
- Fallback avec `??` : `profile?.companyName ?? 'Sans nom'`
- Pattern matching : `if (user case final user?) { ... }`

### Communication Patterns (BLoC)

**Pattern standard :**
```dart
// Events : verbe imperatif
class LoadFeed extends FeedEvent {}
class RefreshFeed extends FeedEvent {}

// States : etat descriptif
class FeedInitial extends FeedState {}
class FeedLoading extends FeedState {}
class FeedLoaded extends FeedState { final List<FeedItem> items; }
class FeedError extends FeedState { final String message; }

// Bloc : on<Event> → try/catch → emit
on<LoadFeed>((event, emit) async {
  emit(FeedLoading());
  try {
    final items = await repo.getFeed();
    emit(FeedLoaded(items));
  } catch (e) {
    emit(FeedError(translateSupabaseError(e)));
  }
});
```

### Process Patterns

**Loading states UI :**
```dart
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) => switch (state) {
    MyLoading() => const Center(child: CircularProgressIndicator()),
    MyError(:final message) => Center(child: Text(message)),
    MyLoaded(:final data) => _buildContent(data),
    _ => const SizedBox.shrink(),
  },
)
```

**Navigation : toujours GoRouter**
```dart
context.push(AppRoutes.chatWith(id));   // OK
context.go(AppRoutes.home);              // OK
Navigator.push(context, ...);           // INTERDIT
```

**Imports : toujours absolus (package)**
```dart
import 'package:flutter_application_1/features/feed/presentation/bloc/feed_bloc.dart'; // OK
import '../../data/models/video_model.dart';  // EVITER
```

### Enforcement Guidelines

**Tout agent IA DOIT :**
1. Suivre la structure feature-first pour tout nouveau code
2. Utiliser snake_case pour fichiers Dart et colonnes SQL
3. Convertir snake_case ↔ camelCase dans fromJson/toJson
4. Emettre Loading → Loaded/Error dans chaque BLoC
5. Utiliser `translateSupabaseError()` pour les messages d'erreur
6. Ajouter `tooltip` a tout `IconButton`
7. Utiliser GoRouter pour toute navigation
8. Utiliser `AppColors`/`AppSpacing` (pas de couleurs/tailles en dur)
9. Utiliser les imports absolus (package:)
10. Documenter chaque nouvelle Edge Function dans la table ci-dessus

**Anti-patterns a eviter :**
- Creer un fichier dans `lib/` a la racine → toujours dans `features/` ou `core/`
- Utiliser `setState` dans un widget qui a un BLoC
- Hardcoder des URLs → toujours dans `app_config.dart`
- Creer une table SQL en camelCase
- Retourner `Map<String, dynamic>` brut depuis un repo → toujours un Model typé
- Utiliser `Navigator.push` → toujours GoRouter
- Utiliser imports relatifs `../../` → toujours package imports

---

## Project Structure & Boundaries

### Complete Project Directory Structure

```
ETOILE/Etoile-mobile-app/                    ← git root
├── .github/
│   └── workflows/
│       └── flutter-ci.yml                    [A CREER] CI/CD
├── .claude/                                  ← Claude Code settings
├── _bmad/                                    ← BMAD agent configs
├── _bmad-output/                             ← Documents BMAD (PRD, archi, stories)
├── cloudflare/                               ← Cloudflare Workers
│   ├── src/index.ts                          → Worker R2 (upload, stream, CORS)
│   ├── wrangler.toml                         → Config Worker
│   ├── package.json
│   └── tsconfig.json
├── flutter_application_1/                    ← Flutter project
│   ├── lib/
│   │   ├── main.dart                         → Firebase init + entry point
│   │   ├── app.dart                          → MaterialApp + GoRouter + Push init
│   │   ├── di/
│   │   │   └── injection_container.dart      → DI manuelle
│   │   ├── core/
│   │   │   ├── config/app_config.dart        → URLs, constantes
│   │   │   ├── router/app_router.dart        → GoRouter (toutes les routes)
│   │   │   ├── services/
│   │   │   │   ├── push_notification_service.dart
│   │   │   │   └── video_upload_service.dart
│   │   │   ├── theme/app_theme.dart          [A CREER]
│   │   │   └── utils/error_translator.dart   [A CREER]
│   │   ├── shared/widgets/
│   │   │   ├── location_map_widget.dart
│   │   │   └── location_picker_widget.dart
│   │   └── features/
│   │       ├── auth/
│   │       │   ├── data/repositories/auth_repository.dart
│   │       │   └── presentation/
│   │       │       ├── bloc/(auth_bloc, auth_event, auth_state)
│   │       │       └── pages/(login, register, forgot_password)
│   │       ├── profile/
│   │       │   ├── data/
│   │       │   │   ├── models/(seeker_profile_model, recruiter_profile_model)
│   │       │   │   └── repositories/profile_repository.dart
│   │       │   └── presentation/
│   │       │       ├── bloc/(profile_bloc, profile_event, profile_state)
│   │       │       └── pages/(profile, edit_seeker, edit_recruiter, public_recruiter)
│   │       ├── feed/
│   │       │   ├── data/
│   │       │   │   ├── models/feed_item_model.dart
│   │       │   │   └── repositories/feed_repository.dart
│   │       │   └── presentation/
│   │       │       ├── bloc/(feed_bloc, feed_event, feed_state)
│   │       │       └── pages/feed_page.dart
│   │       ├── messages/
│   │       │   ├── data/
│   │       │   │   ├── models/(conversation_model, message_model)
│   │       │   │   └── repositories/conversation_repository.dart
│   │       │   └── presentation/
│   │       │       ├── bloc/(chat_bloc, chat_event, chat_state)
│   │       │       └── pages/(conversations_page, chat_page)
│   │       ├── video/
│   │       │   ├── data/
│   │       │   │   ├── models/video_model.dart
│   │       │   │   └── repositories/video_repository.dart
│   │       │   └── presentation/
│   │       │       ├── bloc/(video_bloc, video_event, video_state)
│   │       │       └── pages/(publish_offer, my_publications, video_record)
│   │       ├── payment/                      [A CREER - Epic 6]
│   │       │   ├── data/
│   │       │   │   ├── models/subscription_model.dart
│   │       │   │   └── repositories/payment_repository.dart
│   │       │   └── presentation/
│   │       │       ├── bloc/(payment_bloc, payment_event, payment_state)
│   │       │       └── pages/(subscription_page, credits_page)
│   │       ├── admin/                        [A CREER - Epic 7]
│   │       ├── support/                      [A CREER - Epic 8]
│   │       └── alerts/                       [A CREER - Epic 9]
│   ├── test/                                 [A CREER]
│   │   ├── features/
│   │   │   ├── video/data/repositories/video_repository_test.dart
│   │   │   ├── profile/data/repositories/profile_repository_test.dart
│   │   │   ├── messages/data/repositories/conversation_repository_test.dart
│   │   │   ├── auth/presentation/bloc/auth_bloc_test.dart
│   │   │   ├── feed/presentation/bloc/feed_bloc_test.dart
│   │   │   └── video/presentation/bloc/video_bloc_test.dart
│   │   └── core/utils/error_translator_test.dart
│   ├── android/app/google-services.json
│   └── pubspec.yaml
├── supabase/
│   ├── package.json
│   ├── seed.sql                              [A CREER]
│   ├── migrations/
│   │   ├── 20260201000000_initial_schema.sql
│   │   ├── 20260217000000_recruiter_coordinates.sql
│   │   ├── 20260218000000_video_contract_type.sql
│   │   └── 20260218100000_reports_table.sql  [A CREER]
│   └── functions/
│       ├── send-push/index.ts                (DEPLOYEE)
│       ├── send-sms-otp/index.ts             [A CREER]
│       ├── verify-sms-otp/index.ts           [A CREER]
│       ├── export-user-data/index.ts         [A CREER]
│       ├── delete-user-data/index.ts         [A CREER]
│       ├── stripe-webhook/index.ts           [A CREER]
│       └── check-siret/index.ts              [A CREER]
├── CLAUDE.md
└── README.md
```

### Architectural Boundaries

**Regles de frontiere Flutter :**
```
Pages → BLoCs → Repositories → Supabase SDK / HTTP
  │                                    │
  │ (ne parlent JAMAIS directement)    │
  └────────────────────────────────────┘
```
- Pages ne parlent qu'aux BLoCs (via BlocProvider/BlocBuilder)
- BLoCs ne parlent qu'aux Repositories
- Repositories sont la seule couche qui connait Supabase/HTTP
- Services transversaux (push, upload) injectes via DI
- Exception : video_upload_service appele directement depuis pages publication (upload progressif)

**Frontieres API externes :**

| Service | Point d'entree | Protocole | Auth |
|---------|---------------|-----------|------|
| Supabase REST | `supabase_flutter` SDK | HTTPS | JWT auto |
| Supabase Realtime | `supabase_flutter` SDK | WebSocket | JWT auto |
| Supabase Edge Functions | `supabase.functions.invoke()` | HTTPS | JWT Bearer |
| Cloudflare Worker | HTTP direct (`app_config.dart` URL) | HTTPS | Aucune (presigned URLs) |
| Firebase FCM | `firebase_messaging` SDK | HTTPS | google-services.json |
| Photon API (geocoding) | HTTP direct | HTTPS | Aucune (gratuit) |

**Frontieres data :**

| Couche | Responsabilite | Format |
|--------|---------------|--------|
| PostgreSQL (Supabase) | Source de verite | snake_case, TIMESTAMPTZ |
| Cloudflare R2 | Fichiers binaires (videos, images) | Presigned URLs |
| Hive (local) | Cache profil + feed | Dart objects |
| BLoC State | Etat UI | Dart models (camelCase) |

### Epic → Structure Mapping

| Epic | Feature dir | Models | Repos | BLoC | Pages | Edge Functions | Migrations |
|------|------------|--------|-------|------|-------|----------------|------------|
| 1. Inscription | auth/, profile/ | seeker_profile, recruiter_profile | auth_repo, profile_repo | auth_bloc, profile_bloc | login, register, edit_profile | send-sms-otp, verify-sms-otp | initial_schema |
| 2. Video Chercheur | video/ | video_model | video_repo | video_bloc | publish_offer, video_record | — | — |
| 3. Video Recruteur | video/ | video_model | video_repo | video_bloc | publish_offer, my_publications | — | video_contract_type |
| 4. Feed | feed/ | feed_item_model | feed_repo | feed_bloc | feed_page | — | — |
| 5. Messagerie | messages/ | conversation, message | conversation_repo | chat_bloc | conversations, chat | — | — |
| 6. Paiements | payment/ [CREER] | subscription_model | payment_repo | payment_bloc | subscription, credits | stripe-webhook | subscriptions |
| 7. Admin | admin/ [CREER] | — | — | — | — | check-siret | reports_table |
| 8. Support | support/ [CREER] | — | — | — | faq, contact | — | — |
| 9. Alertes | alerts/ [CREER] | alert_model | alert_repo | alert_bloc | alerts_page | — | — |

### Data Flow

```
Utilisateur → UI (Page)
  → BLoC Event (ex: PublishVideo)
    → Repository.createVideo(data)
      → Supabase.from('videos').insert(data.toJson())
        → PostgreSQL INSERT
          → Trigger create_application_folder()
            → PostgreSQL INSERT application_folders
          → Database Webhook
            → Edge Function send-push
              → Firebase FCM → Notification push
      ← Video model (fromJson)
    ← emit(VideoPublished(video))
  ← BlocBuilder rebuild UI
```

---

## Architecture Validation Results

### Coherence Validation ✅

**Compatibilite des decisions :** Toutes les decisions sont compatibles. Aucune contradiction detectee entre les 6 ADR et les 17 decisions categorielles. Points verifies :
- Supabase Auth ↔ RLS par role : `auth.uid()` nativement disponible
- Stripe direct ↔ Edge Functions : stripe-webhook suit convention verb-noun
- BLoC ↔ Error handler : ErrorState + translateSupabaseError()
- Hive cache ↔ RGPD soft delete : cache invalide au logout
- Firebase Crashlytics ↔ Firebase FCM : meme SDK, un seul init
- Limite video 50MB ↔ Workers Paid limit 100MB : compatible

**Coherence des patterns :** Naming (snake_case SQL, camelCase Dart), structure (feature-first), communication (BLoC events/states) — tous alignes avec le code existant des 11 sprints.

### Requirements Coverage ✅

**Epics :** 9/9 couverts architecturalement
**NFRs :** 8/8 adresses (performance, temps reel, SLA, RGPD, anti-discrimination, offline, a11y, paiements)
**Cross-cutting :** 6/6 mappes (completude profil, auth multi-canal, RGPD, paiements, dossiers auto, notifications)

### Implementation Readiness ✅

- 6 ADR + 17 decisions categorielles documentes
- Patterns complets avec exemples de code (Dart, SQL, JSON)
- 7 anti-patterns explicites
- Arborescence complete avec 12 fichiers [A CREER] identifies
- Sequence d'implementation en 12 etapes ordonnees
- Mapping 9 epics → fichiers concrets

### Gap Analysis

**Gaps critiques : 0**

**Gaps importants resolus :**
1. Dashboard admin → moderation via Supabase Dashboard au MVP, sprint dedie plus tard
2. Portail web recruteurs (paiements B2B) → projet separe hors scope Flutter, Stripe Customer Portal
3. i18n → V1 France uniquement, `flutter_localizations` + ARB quand necessaire

### Architecture Completeness Checklist

- [x] Contexte projet analyse (9 Epics, 32 US, NFRs)
- [x] 6 ADR documentes (paiements, gates, OTP, dossiers, offline, feed)
- [x] 17 decisions categorielles (data, securite, API, frontend, infra)
- [x] Patterns de nommage (SQL, Dart, BLoC, JSON)
- [x] Structure feature-first detaillee
- [x] Frontieres architecturales definies
- [x] 9 epics mappes aux fichiers
- [x] 12 fichiers [A CREER] identifies avec priorite
- [x] Sequence d'implementation ordonnee
- [x] 0 gap critique

### Architecture Readiness Assessment

**Statut : PRET POUR L'IMPLEMENTATION**
**Confiance : Haute**

**Forces :**
- Architecture validee par 11 sprints de code fonctionnel
- Stack serverless (Supabase + CF + Firebase) = scale automatique, pas de SPOF
- R2 egress gratuit = cout video maitrise meme a grande echelle
- Stripe direct = economie massive vs Apple IAP (3% vs 30%)
- Patterns coherents avec le code existant (pas de refactoring)

**Ameliorations futures :**
- Compression video client (ffmpeg_kit_flutter) quand UX le justifie
- Moderation IA hybride quand volume > 100 videos/jour
- CI/CD Codemagic pour build iOS au release store
- 2e projet Supabase (dev/prod) avant release store
- Sentry si Crashlytics insuffisant

### Implementation Handoff

**Tout agent IA doit :**
1. Lire ce document AVANT toute implementation
2. Suivre les patterns de nommage, structure et communication
3. Respecter les frontieres (Pages → BLoCs → Repos → Supabase)
4. Consulter le mapping Epic → fichiers pour savoir ou coder

**Premiere priorite d'implementation :**
1. `app_theme.dart` (design system)
2. `error_translator.dart` (gestion erreurs)
3. Firebase Crashlytics (monitoring)
4. `seed.sql` (donnees de test)
