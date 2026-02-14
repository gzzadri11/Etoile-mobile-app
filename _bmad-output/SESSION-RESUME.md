# Session BMAD - Etoile Mobile App

**Date de mise a jour** : 2026-02-14
**Statut** : Sprint 9 - Notifications Push en cours. Edge Function deployee + secrets configures. Reste: Database Webhooks + test Android.

---

## Pour reprendre

```bash
# 1. Ouvrir le terminal dans le projet
cd C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app\flutter_application_1

# 2. Lancer l'app sur Edge (test rapide) ou emulateur (test push)
flutter run -d edge
# OU pour tester les notifications push:
flutter emulators --launch Medium_Phone_API_36.1
flutter run -d emulator-5554
```

Puis tape `/bmad` et dis : **"reprend la ou on s'est arrete"**

---

## Sprint 9 - Notifications Push (EN COURS)

### Ce qui est FAIT

| # | Composant | Statut |
|---|-----------|--------|
| 1 | PRD (`prd-notifications-push.md`) | Done |
| 2 | Architecture (`architecture-notifications-push.md`) | Done |
| 3 | Migration SQL (`device_tokens` + `notification_log`) | Done (execute sur Supabase) |
| 4 | Flutter: `push_notification_service.dart` | Done |
| 5 | Flutter: `main.dart` (Firebase init + background handler) | Done |
| 6 | Flutter: `injection_container.dart` (PushNotificationService) | Done |
| 7 | Flutter: `auth_bloc.dart` (registerToken/removeToken) | Done |
| 8 | Flutter: `app.dart` (pushService.initialize + registerToken) | Done |
| 9 | Edge Function `send-push/index.ts` (FCM v1, dedup, 3 types notifs) | Done |
| 10 | Android: `google-services.json` | Done |
| 11 | Android: Gradle + Manifest modifies | Done |
| 12 | **Edge Function deployee sur Supabase** | **Done** |
| 13 | **Secret `FIREBASE_SERVICE_ACCOUNT_KEY` configure** | **Done** |
| 14 | **Supabase CLI installe** (local dans `supabase/node_modules`) | **Done** |

### Ce qui RESTE a faire

| # | Tache | Description | Priorite |
|---|-------|-------------|----------|
| 1 | **Database Webhooks Supabase** | Configurer 2 webhooks dans Dashboard Supabase | **NEXT** |
| 2 | **Test sur emulateur Android** | Build + verifier reception notifications push | Haute |
| 3 | **Chat page: activeConversationId** | Tracker la conversation active pour eviter notifs quand on est deja sur le chat | Moyenne |
| 4 | **CRON rappel profil incomplet** (optionnel) | pg_cron pour appeler send-push quotidiennement | Basse |

### Details Webhook a configurer

Dashboard : https://supabase.com/dashboard/project/ojslqytmuifaofojutgb/database/hooks

**Webhook 1 : `on-new-message`**
- Table : `messages`
- Events : `INSERT`
- Type : Supabase Edge Function
- Function : `send-push`

**Webhook 2 : `on-new-conversation`**
- Table : `conversations`
- Events : `INSERT`
- Type : Supabase Edge Function
- Function : `send-push`

---

## Supabase CLI

- Installe localement dans `supabase/node_modules/` (pas global)
- Utiliser : `cd supabase && npx supabase <commande>`
- OU depuis la racine : `npx --prefix supabase supabase <commande> --project-ref ojslqytmuifaofojutgb`
- Access Token Supabase : `sbp_9ab83a87cc77ec01e864f0400f77d364572650dd`
- Project Ref : `ojslqytmuifaofojutgb`
- Projet link OK (fait le 2026-02-14)

---

## Firebase

- **Project ID** : `etoile-app-b80e2`
- **Service Account** : `firebase-adminsdk-fbsvc@etoile-app-b80e2.iam.gserviceaccount.com`
- **Service Account Key** : `C:\Users\gzzad\Downloads\etoile-app-b80e2-firebase-adminsdk-fbsvc-8103287027.json`
- **google-services.json** : `flutter_application_1/android/app/google-services.json`

---

## Cloudflare Worker (Session precedente)

- **Worker deploye** : `https://etoile-video-worker.gzzadri11.workers.dev`
- **Health check** : `GET /health` → OK
- **Buckets R2** : `etoile-videos` + `etoile-thumnails`
- **Token API** : set via `$env:CLOUDFLARE_API_TOKEN` en PowerShell

---

## Historique des changements

### 2026-02-14 - Sprint 9 : Notifications Push (en cours)
- PRD + Architecture notifications push crees
- Migration SQL executee (tables `device_tokens` + `notification_log`)
- Code Flutter complet : PushNotificationService, Firebase init, token management, snackbar in-app, deep linking
- Edge Function `send-push` deployee sur Supabase (FCM v1, dedup, 3 types)
- Secret Firebase configure sur Supabase
- Supabase CLI installe localement
- **Reste** : Database Webhooks + test Android + activeConversationId

### 2026-02-13 - Messagerie temps reel + Worker Cloudflare
- Messagerie temps reel validee (test E2E OK entre 2 utilisateurs)
- Worker Cloudflare deploye (`etoile-video-worker`)
- 5 videos test uploadees sur R2
- Feed video 100% fonctionnel sur Edge avec preload

### 2026-02-10 - Edition Profil Recruteur
- Edition profil recruteur : logo, couverture, vue profil visuelle

### 2026-02-07/08 - Feed par Profil
- Feed specifique par role, filtres, boutons contextuels

---

## Resume complet du projet

### Ce qui fonctionne

| Fonctionnalite | Statut | Sprint |
|----------------|--------|--------|
| Connexion Supabase | OK | 1 |
| Cloudflare R2 (2 buckets) | OK | 1 |
| Base de donnees (12 tables + RLS) | OK | 1 |
| Trigger creation profil | OK | 1 |
| Inscription (chercheur/recruteur) | OK | 2 |
| Connexion / Deconnexion | OK | 2 |
| Mot de passe oublie | OK | 2 |
| Navigation GoRouter | OK | 2 |
| Affichage profil (donnees reelles) | OK | 3 |
| Edition profil chercheur | OK | 3 |
| Structure video (model, bloc, repo) | OK | 4 |
| Feed vertical TikTok-style | OK | 5 |
| Prechargement 2 videos suivantes | OK | 5 |
| Bouton Profil (bottom sheet) | OK | 5 |
| Bouton Message (creation conversation) | OK | 6 |
| Feed par Profil (chercheur vs recruteur) | OK | 7 |
| Filtres specifiques par role | OK | 7 |
| Boutons Postuler / Contacter | OK | 7 |
| Edition profil recruteur (logo + couverture) | OK | 8 |
| Messagerie temps reel (Realtime) | OK | 8 |
| Worker Cloudflare deploye | OK | 8 |
| Video test sur R2 | OK | 8 |
| **Tables device_tokens + notification_log** | **OK** | **9** |
| **Edge Function send-push deployee** | **OK** | **9** |
| **Secret Firebase configure** | **OK** | **9** |
| **Code Flutter push notifications** | **OK** | **9** |

### Ce qui reste a faire

| # | Tache | Priorite | Prerequis |
|---|-------|----------|-----------|
| 1 | Database Webhooks Supabase (2 triggers) | **NEXT** | Dashboard |
| 2 | Test notifications push Android | Haute | Emulateur |
| 3 | activeConversationId dans ChatPage | Moyenne | - |
| 4 | CRON rappel profil incomplet | Basse | pg_cron |
| 5 | Test camera + upload R2 depuis app | Moyenne | Mobile Android |
| 6 | Configuration Stripe | Basse | Compte Stripe |

---

## Fichiers cles

```
ETOILE/Etoile-mobile-app/
├── cloudflare/
│   ├── src/index.ts              # Worker R2 (upload, stream, CORS)
│   └── wrangler.toml             # Config Worker
├── flutter_application_1/
│   ├── lib/
│   │   ├── app.dart                    # Widget principal + GoRouter + Push init
│   │   ├── main.dart                   # Firebase init + background handler
│   │   ├── di/injection_container.dart # DI (PushNotificationService inclus)
│   │   ├── core/
│   │   │   ├── config/app_config.dart
│   │   │   ├── router/app_router.dart
│   │   │   └── services/push_notification_service.dart  # NOUVEAU Sprint 9
│   │   └── features/
│   │       ├── auth/presentation/bloc/auth_bloc.dart  # + registerToken/removeToken
│   │       ├── profile/
│   │       ├── feed/
│   │       ├── messages/
│   │       └── video/
│   ├── android/app/google-services.json  # Config Firebase Android
│   └── pubspec.yaml                       # + firebase_core, firebase_messaging, flutter_local_notifications
├── supabase/
│   ├── package.json                       # Supabase CLI local
│   ├── migrations/
│   │   ├── 20260202000000_initial_schema.sql
│   │   ├── 20260210000000_enable_realtime_messages.sql
│   │   └── 20260214000000_device_tokens.sql  # NOUVEAU Sprint 9
│   └── functions/
│       ├── send-push/index.ts              # NOUVEAU Sprint 9 - FCM notifications
│       ├── create-payment-intent/index.ts
│       ├── create-subscription-intent/index.ts
│       └── stripe-webhook/index.ts
└── _bmad-output/
    ├── SESSION-RESUME.md
    ├── prd-notifications-push.md           # NOUVEAU Sprint 9
    └── architecture-notifications-push.md  # NOUVEAU Sprint 9
```

---

## Identifiants

### Supabase
- **Dashboard** : https://supabase.com/dashboard
- **Projet** : etoile-app (ref: `ojslqytmuifaofojutgb`)
- **Region** : West EU (Paris)
- **Edge Functions** : https://supabase.com/dashboard/project/ojslqytmuifaofojutgb/functions
- **Database Hooks** : https://supabase.com/dashboard/project/ojslqytmuifaofojutgb/database/hooks
- **Access Token CLI** : `sbp_9ab83a87cc77ec01e864f0400f77d364572650dd`

### Firebase
- **Project ID** : `etoile-app-b80e2`
- **Console** : https://console.firebase.google.com/project/etoile-app-b80e2
- **Service Account Key** : `C:\Users\gzzad\Downloads\etoile-app-b80e2-firebase-adminsdk-fbsvc-8103287027.json`

### Cloudflare
- **Worker URL** : https://etoile-video-worker.gzzadri11.workers.dev
- **Account ID** : 91852e840042405a28e7ad2dd08d4fa8
- **Buckets** : etoile-videos, etoile-thumnails

### Comptes de test
- **Recruteur** : emma@gmail.com (entreprise UDI, secteur BTP)

---

*Sauvegarde mise a jour le 2026-02-14*
*Prochaine etape : Configurer Database Webhooks dans le Dashboard Supabase*
