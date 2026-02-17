# Session BMAD - Etoile Mobile App

**Date de mise a jour** : 2026-02-16
**Statut** : Sprint 11 termine et teste. Prochaine etape : planifier Sprint 12.

---

## Pour reprendre

```bash
# 1. Ouvrir le terminal dans le projet
cd C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app\flutter_application_1

# 2. Lancer l'app sur Edge (test rapide) ou emulateur (test push/camera)
flutter run -d edge
# OU pour tester les notifications push / camera:
flutter emulators --launch Medium_Phone_API_36.1
flutter run -d emulator-5554
```

Puis tape `/bmad` et dis : **"reprend la ou on s'est arrete"**

---

## Sprint 11 - Feed 2 onglets + Presentation entreprise (TERMINE)

### Ce qui a ete fait

| Changement | Fichier(s) | Description |
|------------|-----------|-------------|
| Feed 2 onglets (seeker) | feed_page.dart, feed_bloc.dart, feed_event.dart, feed_state.dart | Onglets "Entreprises" (discover) et "Offres" style TikTok dans l'AppBar |
| Nouveau feed discover | feed_repository.dart | `getSeekerDiscoverFeed()` : presentations des recruteurs verifies |
| Rename feed offers | feed_repository.dart | `getSeekerFeed()` → `getSeekerOffersFeed()` |
| Affiches en image | feed_page.dart | Les posters s'affichent en `Image.network` plein ecran au lieu du video player |
| Publication 3 choix | publish_offer_page.dart | "Presentation entreprise" (gratuit) / "Offre video" / "Offre affiche" |
| Credits gratuits | publish_offer_page.dart | `decrementCredits()` skip quand `_publishType == 'presentation'` |
| Profil 2 sections | profile_page.dart, profile_state.dart, profile_bloc.dart | 2 cards : "Presentations entreprise" + "Publications de recrutement" avec compteurs |
| Mes publications tabs | my_publications_page.dart | TabBar "Presentations" / "Recrutement" avec filtre par type |
| Type badge 3 types | my_publications_page.dart | Badge "Presentation" (vert), "Video" (bleu), "Affiche" (orange) |
| Router query param | app_router.dart | `?tab=presentations` ou `?tab=recruitment` passe a MyPublicationsPage |
| DI update | injection_container.dart | ProfileBloc recoit VideoRepository pour compter les publications |

### Tests a effectuer

1. **Recruteur (emma@gmail.com)** :
   - Page Publier : 3 boutons visibles (Presentation / Offre video / Offre affiche)
   - Publier une presentation entreprise → credits NON decrementes
   - Publier une offre video/affiche → credits decrementes
   - Profil : 2 sections avec compteurs corrects
   - Mes publications : 2 onglets filtres correctement

2. **Chercheur** :
   - Feed : 2 onglets "Entreprises" / "Offres" dans l'AppBar
   - Entreprises → presentations des recruteurs
   - Offres → offres video + affiches
   - Affiches → image plein ecran (pas video player)

3. **Feed recruteur** : doit toujours montrer les videos de seekers

### flutter analyze : 0 erreurs (31 info/warning pre-existants)

---

## Sprint 10 - Import Video + Affiche + Publications (TERMINE)

### Stories completees

| Story | Description | Commit |
|-------|-------------|--------|
| S1 | VideoUploadService (upload R2 via Worker) | a82c2c7 |
| S2 | Import video galerie (PublishOfferPage) | a82c2c7 |
| S3 | Enregistrement video in-app (camera) | **DEFERRED** (mobile only) |
| S4 | Publication affiche image (poster) | a82c2c7 |
| S5 | Page "Mes publications" (liste) | a82c2c7 |
| S6 | Modification / Suppression publications | a82c2c7 |

---

## Sprint 9 - Notifications Push (TERMINE)

| # | Composant | Statut |
|---|-----------|--------|
| 1-18 | Tous composants (PRD, archi, SQL, Flutter, Edge Function, Webhooks, CRON) | Done |

---

## Sprints restants (depuis sprint-plan.md)

| Sprint | Contenu | Statut |
|--------|---------|--------|
| 1-8 | Auth, Profil, Feed, Messages, etc. | Done |
| 9 | Notifications Push | **Done** |
| 10 | Import video + Affiche + Publications | **Done** (sauf S3 camera) |
| 11 | Feed 2 onglets + Presentation entreprise | **Done** |
| 12 | A planifier - Features restantes du backlog | **NEXT** |

### Features disponibles pour Sprint 12

1. Carte interactive OpenStreetMap (FR29, Phase 3)
2. Statistiques avancees (vues, engagement)
3. Systeme de paiement Stripe (premium)
4. Recherche avancee candidats
5. S3: Camera in-app (report du Sprint 10)

---

## Supabase CLI

- Installe localement dans `supabase/node_modules/` (pas global)
- Utiliser : `cd supabase && npx supabase <commande>`
- OU depuis la racine : `npx --prefix supabase supabase <commande> --project-ref ojslqytmuifaofojutgb`
- Access Token Supabase : `sbp_9ab83a87cc77ec01e864f0400f77d364572650dd`
- Project Ref : `ojslqytmuifaofojutgb`

---

## Firebase

- **Project ID** : `etoile-app-b80e2`
- **Service Account** : `firebase-adminsdk-fbsvc@etoile-app-b80e2.iam.gserviceaccount.com`
- **Service Account Key** : `C:\Users\gzzad\Downloads\etoile-app-b80e2-firebase-adminsdk-fbsvc-8103287027.json`
- **google-services.json** : `flutter_application_1/android/app/google-services.json`

---

## Cloudflare Worker

- **Worker deploye** : `https://etoile-video-worker.gzzadri11.workers.dev`
- **Health check** : `GET /health` → OK
- **Buckets R2** : `etoile-videos` + `etoile-thumnails`
- **Token API** : set via `$env:CLOUDFLARE_API_TOKEN` en PowerShell
- **Account ID** : 91852e840042405a28e7ad2dd08d4fa8

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
| Tables device_tokens + notification_log | OK | 9 |
| Edge Function send-push deployee | OK | 9 |
| Secret Firebase configure | OK | 9 |
| Code Flutter push notifications | OK | 9 |
| Database Webhooks (messages + conversations) | OK | 9 |
| CRON rappel profil + cleanup logs | OK | 9 |
| VideoUploadService (upload R2 reel) | OK | 10 |
| Import video galerie (recruteur) | OK | 10 |
| Publication affiche image (poster) | OK | 10 |
| Page Mes publications (liste + edit/delete) | OK | 10 |
| Onglet Publier (bottom nav recruteur) | OK | 10 |
| Fix Firebase web (kIsWeb guard) | OK | 10 |
| Feed 2 onglets chercheur (Entreprises/Offres) | OK | 11 |
| Publication presentation entreprise (gratuit) | OK | 11 |
| Profil recruteur 2 sections publications | OK | 11 |
| Mes publications avec tabs | OK | 11 |
| Affiches en image plein ecran dans feed | OK | 11 |

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
│   │   ├── di/injection_container.dart # DI (tous les services)
│   │   ├── core/
│   │   │   ├── config/app_config.dart
│   │   │   ├── router/app_router.dart
│   │   │   ├── services/push_notification_service.dart
│   │   │   └── services/video_upload_service.dart
│   │   └── features/
│   │       ├── auth/presentation/bloc/auth_bloc.dart
│   │       ├── profile/
│   │       ├── feed/
│   │       ├── messages/
│   │       └── video/
│   │           ├── data/models/video_model.dart
│   │           ├── data/repositories/video_repository.dart
│   │           ├── presentation/bloc/video_bloc.dart
│   │           └── presentation/pages/
│   │               ├── publish_offer_page.dart
│   │               ├── my_publications_page.dart
│   │               └── video_record_page.dart
│   ├── android/app/google-services.json
│   └── pubspec.yaml
├── supabase/
│   ├── package.json
│   ├── migrations/
│   └── functions/send-push/index.ts
└── _bmad-output/
    ├── SESSION-RESUME.md
    ├── sprint-plan.md
    ├── epics.md
    ├── prd-notifications-push.md
    └── architecture-notifications-push.md
```

---

## Identifiants

### Supabase
- **Dashboard** : https://supabase.com/dashboard
- **Projet** : etoile-app (ref: `ojslqytmuifaofojutgb`)
- **Region** : West EU (Paris)
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

*Sauvegarde mise a jour le 2026-02-16*
*Sprint 11 termine et teste. Prochaine etape : planifier Sprint 12.*
