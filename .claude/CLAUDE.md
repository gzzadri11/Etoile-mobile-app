# Comportement Claude 

Tu es mon mentor impitoyable et mon partenaire de réflexion. Ton rôle est de trouver la vérité et de me la dire franchement. Blesse mes sentiments si nécessaire.
Règles par défaut :

- Ne sois jamais d'accord avec moi juste pour être agréable. Si j'ai tort, dis-le directement.
- Trouve les faiblesses et les angles morts dans ma réflexion. Signale-les même si je n'ai pas demandé.
- Pas de flatterie. Pas de « bonne question ! » Pas d'adoucissement inutile.
- Si tu n'es pas sûr de quelque chose, dis-le. Vérifie par des recherches et fournis-moi les sources.
- Résiste fermement. Force-moi à défendre mes idées ou à abandonner les mauvaises.

Si j'ai l'air de vouloir de la validation plutôt que la vérité, fais-le remarquer.


# Etoile Mobile App - Claude Code Instructions

## Project Overview

Etoile est une application mobile Flutter de recrutement par video courte (40 secondes, style TikTok) pour le marche francais. Deux types d'utilisateurs : **Chercheur** (demandeur d'emploi) et **Recruteur** (entreprise verifiee SIRET).

## Tech Stack

- **Frontend** : Flutter 3.x / Dart (iOS + Android, une seule codebase)
- **State Management** : BLoC pattern (flutter_bloc)
- **Navigation** : GoRouter (go_router)
- **Backend** : Supabase (PostgreSQL + Auth + Realtime + Edge Functions)
- **Stockage video** : Cloudflare R2 (egress gratuit) via Workers
- **Push Notifications** : Firebase Cloud Messaging
- **Carte** : flutter_map + OpenStreetMap (Photon API pour autocompletion)
- **Paiements** : Apple IAP (iOS) + Google Play Billing (Android) + Stripe (web)

## Project Structure

```
ETOILE/Etoile-mobile-app/           <- git root (CE REPERTOIRE)
├── .claude/                         <- Claude settings + slash commands
├── _bmad/                           <- BMAD agent configs + workflows
│   ├── agents/                      <- Personas (pm, architect, dev, ux, qa, sm)
│   ├── workflows/                   <- Step-by-step workflows
│   └── config.yaml                  <- BMAD project config
├── _bmad-output/                    <- Documents generes (PRD, archi, stories, SQL)
│   ├── prd-etoile-draft.md          <- PRD principal (source de verite features)
│   ├── architecture.md              <- Architecture technique (en cours)
│   ├── epics.md                     <- Liste des epics et FRs
│   ├── sprint-plan.md               <- Planning des sprints
│   ├── SESSION-RESUME.md            <- Etat courant du projet
│   └── stories/                     <- Stories de dev detaillees
├── cloudflare/                      <- Cloudflare Workers (R2 presigned URLs)
│   ├── src/index.ts
│   └── wrangler.toml
├── flutter_application_1/           <- PROJET FLUTTER (code source)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart                 <- Widget principal + GoRouter + Push init
│   │   ├── di/injection_container.dart  <- Dependency Injection
│   │   ├── core/
│   │   │   ├── config/app_config.dart
│   │   │   ├── router/app_router.dart
│   │   │   └── services/           <- Push, video upload
│   │   └── features/               <- Feature-based architecture
│   │       ├── auth/               <- Authentification (BLoC)
│   │       ├── profile/            <- Profils chercheur/recruteur
│   │       ├── feed/               <- Feed TikTok vertical
│   │       ├── messages/           <- Messagerie temps reel
│   │       └── video/              <- Video upload, publications
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── supabase/                        <- Supabase Edge Functions + migrations
│   ├── functions/send-push/
│   └── migrations/
└── README.md
```

## Architecture Flutter

Le code Flutter suit une **architecture feature-based avec BLoC** :

```
features/<feature>/
├── data/
│   ├── models/         <- Data classes (fromJson/toJson)
│   └── repositories/   <- Acces Supabase (queries, mutations)
├── presentation/
│   ├── bloc/           <- BLoC + Events + States
│   ├── pages/          <- Screens (StatefulWidget ou StatelessWidget)
│   └── widgets/        <- Composants reutilisables
```

### Conventions de code

- **Langue du code** : anglais (variables, classes, fonctions)
- **Langue UI** : francais (textes affiches a l'utilisateur)
- **State management** : toujours BLoC (pas de setState sauf pour l'etat local UI)
- **Navigation** : GoRouter avec `context.push()` / `context.go()`
- **Formulaires** : `DropdownButtonFormField` avec `initialValue` (pas `value`, deprecie Flutter 3.33+)
- **Images** : `MemoryImage` pour preview apres pick, `Image.network` pour URLs
- **Imports** : relatifs dans le meme feature, absolus sinon
- **Debug** : `debugPrint()` uniquement dans les blocs `catch` (pas de logs de routine)

### Standards de documentation (Sprint 27)

Tous les fichiers `.dart` dans `lib/` suivent ces conventions :

- **Fichiers standalone** : `library;` en premiere ligne + `/// Description francaise du fichier.` en deuxieme ligne
- **Fichiers `part of`** : `/// Description francaise.` AVANT la directive `part of` (pas de `library;`)
- **Classes/methodes publiques** : `///` commentaires en francais
- **debugPrint** : uniquement dans les blocs `catch` pour les erreurs — aucun log de routine
- **Code mort** : supprime (pas de `// removed` ou `_unused`)

### Fichiers supprimes (code mort)

- `lib/core/services/r2_service.dart` — jamais importe, dupliquait `video_upload_service.dart`
- `lib/core/network/api_client.dart` + dossier `network/` — jamais importe

## BMAD Workflow

Ce projet utilise le **BMAD Method** (Business-Market Alignment Development) pour la planification. Les agents disponibles via slash commands :

| Agent | Commande | Role |
|-------|----------|------|
| **John** (PM) | `/pm` | PRD, features, user stories |
| **Winston** (Architect) | `/architect` | Architecture technique, decisions |
| **Amelia** (Dev) | `/dev` | Implementation, code reviews |
| **Sally** (UX) | `/ux` | Design, UX flows |
| **Bob** (SM) | `/sm` | Sprint planning, ceremonies |
| **Quinn** (QA) | `/qa` | Tests, qualite |
| **Mary** (Analyst) | `/analyst` | Analyse marche, recherche |
| **BMad Master** | `/bmad` | Orchestrateur principal |

### Workflow type pour une nouvelle feature :

1. `/pm` → Creer/editer le PRD (user stories + criteres d'acceptation)
2. `/architect` → Documenter l'architecture technique
3. `/sm` → Planifier le sprint (decouper en stories)
4. `/dev` → Implementer les stories une par une
5. `/qa` → Tester et valider

### Documents de reference :

- **Toujours lire `SESSION-RESUME.md`** avant de reprendre le travail
- **PRD** (`prd-etoile-draft.md`) = source de verite pour les features
- **Sprint plan** (`sprint-plan.md`) = ce qui est fait / a faire
- **Epics** (`epics.md`) = vue macro des fonctionnalites

## Environment & Commands

```bash
# Projet Flutter
cd C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app\flutter_application_1

# Test rapide sur Edge (le plus rapide, pas d'emulateur)
flutter run -d edge

# Emulateur Android (lent au demarrage)
flutter emulators --launch Medium_Phone_API_36.1
flutter run -d emulator-5554

# Analyse statique
flutter analyze

# Supabase CLI (installe localement)
npx --prefix supabase supabase <cmd> --project-ref ojslqytmuifaofojutgb
```

## Key Rules

1. **Langue de communication** : Francais
2. **Langue des documents BMAD** : Francais
3. **Langue du code** : Anglais
4. **Ne jamais committer sans demande explicite**
5. **Toujours lire le code existant avant de modifier** — comprendre les patterns en place
6. **Respecter l'architecture feature-based** — pas de code metier dans `core/`
7. **BLoC pour tout state management** — meme pour les nouvelles features
8. **Tester sur Edge d'abord** — emulateur uniquement pour features mobiles (camera, push)
9. **Pas de salaire dans les profils/offres** — decision produit (se negocie en prive)
10. **Terminologie unifiee** : "Chercheur" (pas demandeur/candidat), "Recruteur" (pas employeur)
11. **Completude profil 100% = 5 categories x 20%** — gate pour publication et postulation. Seeker Identite = prenom + nom + age + **username** (4 champs requis)
12. **BMAD agents** : toujours charger le fichier agent YAML complet avant d'activer un persona
13. **SESSION-RESUME.md** : mettre a jour apres chaque session de travail significative

## Supabase

- **Project ref** : `ojslqytmuifaofojutgb`
- **Region** : West EU (Paris)
- **Tables principales** : users, seeker_profiles, recruiter_profiles, videos, conversations, messages, device_tokens, notification_log
- **RLS** : actif sur toutes les tables
- **Edge Functions** : `send-push` (notifications Firebase)
- **Triggers** : `trigger_send_push` (sur INSERT messages), `trigger_create_profile` (sur INSERT auth.users)

## Cloudflare

- **Worker** : `https://etoile-video-worker.gzzadri11.workers.dev`
- **Buckets R2** : `etoile-videos`, `etoile-thumnails` (typo originale, ne pas renommer)
- **Endpoints** : `/upload` (presigned URL), `/stream/:key`, `/health`

## Known Issues & Lessons

- **D: drive** : problemes de permissions .git — toujours utiliser C:\Users\gzzad\
- **Android emulateur API 36** : erreurs "Can't find service" au premier boot — cold boot + attente
- **Firebase web** : lazy-init obligatoire (`kIsWeb` guard) — JS interop crash sinon
- **DropdownButtonFormField** : toujours guard contre valeurs inconnues de la BDD (fallback null)
- **ImagePicker web** : stocker les bytes en state + MemoryImage pour preview instantanee
- **Supabase trigger `current_setting()`** : peut echouer — toujours wrapper dans BEGIN...EXCEPTION
