# Session BMAD - Etoile Mobile App

**Date de mise a jour** : 2026-02-25
**Statut** : Sprint 16 TERMINE (6/6 stories, 17/17 pts). Sprint 13 camera toujours reportee.

---

## Pour reprendre

```bash
# 1. Ouvrir le terminal dans le projet
cd C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app\flutter_application_1

# 2. Lancer l'app sur Edge (test rapide) ou emulateur (test push/camera)
flutter run -d edge
```

Puis tape `/bmad` et dis : **"reprend la ou on s'est arrete"**

---

## Ce qui a ete fait — Sprint 16 (2026-02-25)

### Pre-requis Sprint 15 deployes
- Edge Functions `delete-account` et `export-user-data` deployees sur Supabase
- Migration SQL poussee : VIEW `public.users`, admin role, bucket `verification-docs`, RLS policies
- Fix `users` → `user_roles` dans admin_repository, payment_repository, admin_state, admin_bloc

### Story 16.1 : Fix deprecations (2 pts) — DONE
- 13x `withOpacity()` → `withValues(alpha:)` dans 4 fichiers
- 2x `value:` → `initialValue:` dans edit_recruiter_profile_page.dart
- 2x `value:` → `initialValue:` dans edit_seeker_profile_page.dart
- Resultat : 0 deprecation warnings (Flutter 3.38+)

### Story 16.2 : Bloquer utilisateur FR-5.3 (5 pts) — DONE
**Fichier cree :** `lib/features/messages/data/repositories/block_repository.dart`
- blockUser(), unblockUser(), isBlocked(), getBlockedUserIds()

**Fichiers modifies :**
- `chat_page.dart` — Ajout "Bloquer" (rouge) dans PopupMenu + dialog confirmation
- `conversations_page.dart` — Filtrage conversations avec utilisateurs bloques
- `feed_bloc.dart` — Filtrage videos d'utilisateurs bloques dans le feed
- `injection_container.dart` — +BlockRepository + FeedBloc(blockRepository)

### Story 16.3 : Splash screen anime + App icon (3 pts) — DONE
**Fichier cree :** `lib/shared/widgets/splash_screen.dart`
- Splash anime avec gradient, icone etoile, ShaderMask titre, fade-in + scale
- Remplace le loading basique dans app.dart

**Fichier modifie :** `lib/app.dart` — Utilise SplashScreen au lieu du loading inline

**App icon :** `flutter_launcher_icons` configure avec logo etoile doree 3D
- Logo source : `assets/icon/app_icon.png` (etoile doree sur fond #333)
- Mascotte : `assets/images/mascotte.png` (personnage etoile avec telephone)
- Icones generees : Android (mipmap + adaptive), iOS (alpha removed), Web (favicon + 192/512), Windows
- Package `flutter_launcher_icons: ^0.14.3` dans dev_dependencies

### Story 16.4 : Fix widget_test + tests supplementaires (3 pts) — DONE
**Fichier modifie :** `test/widget_test.dart` — Teste SplashScreen (ETOILE + tagline)
**Fichier cree :** `test/features/messages/data/repositories/block_repository_test.dart` — 5 tests
- Resultat : **25/25 tests pass** (avant 19+1 fail = 20 tests)

### Story 16.5 : Navigation guards + UX polish (3 pts) — DONE
**Fichier modifie :** `lib/core/router/app_router.dart`
- Role-based guards : /record → /publish si recruteur, /publish → /record si seeker
- Splash route utilise SplashScreen (remplace _SplashPage inline)
- Welcome page polie : logo etoile, ShaderMask titre, AppColors/AppTheme

### Story 16.6 : Update docs — CE DOCUMENT

---

## Ce qui a ete fait — Sprint 15 (2026-02-25)

### Story 15.4 : Lien Administration dans Settings (2 pts) — DEJA FAIT
- Etait deja implemente dans Sprint 14 (lignes 29-39 de settings_page.dart)

### Story 15.1 : RGPD - Suppression de compte (5 pts) — DONE

**Fichiers modifies :**
- `lib/features/auth/presentation/bloc/auth_event.dart` — +`AuthDeleteAccountRequested` (avec password)
- `lib/features/auth/presentation/bloc/auth_state.dart` — +`AuthAccountDeleted`
- `lib/features/auth/presentation/bloc/auth_bloc.dart` — +handler `_onDeleteAccountRequested` (verify password → Edge Function → signOut)
- `lib/features/settings/presentation/pages/settings_page.dart` — Bouton "Supprimer mon compte" + dialog confirmation avec mot de passe

**Fichier cree :**
- `supabase/functions/delete-account/index.ts` — Soft delete 30j (user_roles.status='deleted', videos.status='deleted', auth metadata deleted_at, cancel subscriptions, remove device_tokens)

### Story 15.2 : RGPD - Export donnees personnelles (5 pts) — DONE

**Fichiers modifies :**
- `lib/features/settings/presentation/pages/settings_page.dart` — Bouton "Exporter mes donnees" + dialog JSON scrollable + copier presse-papiers

**Fichier cree :**
- `supabase/functions/export-user-data/index.ts` — Collecte user, profile, videos, conversations, messages (envoyes), subscriptions, purchases → JSON

### Story 15.3 : Signaler depuis conversation et feed (5 pts) — DONE

**Fichiers crees :**
- `lib/features/report/data/repositories/report_repository.dart` — INSERT reports + guard auto-signalement
- `lib/features/report/presentation/widgets/report_dialog.dart` — Bottom sheet reutilisable (5 motifs + description optionnelle)

**Fichiers modifies :**
- `lib/features/messages/presentation/pages/chat_page.dart` — PopupMenuButton "Signaler" dans AppBar
- `lib/features/feed/presentation/pages/feed_page.dart` — Bouton Signaler (drapeau) sur chaque video card
- `lib/di/injection_container.dart` — +ReportRepository singleton

### Story 15.5 : Gestion abonnement (historique + annulation) (5 pts) — DONE

**Fichier cree :**
- `lib/features/payment/presentation/pages/subscription_management_page.dart` — Mon abonnement (status, renouvellement, annulation) + credits recruteur + historique transactions

**Fichiers modifies :**
- `lib/features/payment/presentation/bloc/payment_event.dart` — +`PaymentLoadHistory`
- `lib/features/payment/presentation/bloc/payment_state.dart` — +`PaymentHistoryLoaded` (isPremium, planType, credits, transactions)
- `lib/features/payment/presentation/bloc/payment_bloc.dart` — +handler `_onLoadHistory`
- `lib/features/payment/data/repositories/payment_repository.dart` — +`getPaymentHistory()` + `getRecruiterCredits()`
- `lib/core/router/app_router.dart` — Route `/premium/manage` avec BlocProvider
- `lib/features/settings/presentation/pages/settings_page.dart` — Lien "Mon abonnement"

### Story 15.6 : Tests unitaires critiques (3 pts) — DONE

**Fichiers crees :**
- `test/features/auth/presentation/bloc/auth_bloc_test.dart` — 9 tests (check, login, register, logout, delete, reset)
- `test/features/report/data/repositories/report_repository_test.dart` — 3 tests (self-report guard, reasons)
- `test/features/profile/data/repositories/profile_repository_test.dart` — 7 tests (currentUserId, role, null guards)

**Packages ajoutes :** `mocktail: ^1.0.4`, `bloc_test: ^9.1.7`
**Resultat :** 19/19 tests passed

---

## Ce qui a ete fait — Sprint 14 (2026-02-24)

### Story 14.1 : Structure admin + route guard + dashboard (3 pts) — DONE

**Fichiers crees :**
- `lib/features/admin/presentation/pages/admin_dashboard_page.dart` — Hub 3 cards
- `lib/features/admin/presentation/bloc/admin_bloc.dart`
- `lib/features/admin/presentation/bloc/admin_event.dart`
- `lib/features/admin/presentation/bloc/admin_state.dart`

**Fichiers modifies :**
- `app_router.dart` — Routes admin avec guard isAdmin + BlocProvider
- `injection_container.dart` — +AdminRepository singleton

### Story 14.2 : Models + AdminRepository (3 pts) — DONE

**Fichiers crees :**
- `lib/features/admin/data/models/report_model.dart` — ReportModel (joined data)
- `lib/features/admin/data/repositories/admin_repository.dart` — 10 methodes admin

### Story 14.3 : Liste recruteurs en attente (5 pts) — DONE

**Fichier cree :** `lib/features/admin/presentation/pages/verification_queue_page.dart`
- Liste cards recruteurs pending, pull-to-refresh, count AppBar, empty/error states

### Story 14.4 : Validation / rejet recruteur (5 pts) — DONE

**Fichier cree :** `lib/features/admin/presentation/pages/recruiter_verification_page.dart`
- Detail complet recruteur (header, infos, document, description, locations)
- Boutons Approuver/Rejeter avec dialogs de confirmation
- BlocConsumer pour SnackBar succes/erreur + retour liste

### Story 14.5 : Liste + moderation signalements (5 pts) — DONE

**Fichier cree :** `lib/features/admin/presentation/pages/reports_page.dart`
- Liste signalements pending avec type icon (video/message/utilisateur)
- Bottom sheet draggable avec detail + actions (Ignorer / Supprimer video / Suspendre utilisateur)
- Dialog de confirmation + champ Notes admin optionnel

### Story 14.6 : Dashboard statistiques (5 pts) — DONE

**Fichier cree :** `lib/features/admin/presentation/pages/admin_stats_page.dart`
- 5 sections de metriques en grille : Utilisateurs, Verification, Videos, Activite, Abonnements
- 14 compteurs dans des _StatCard colorees
- Timestamp mise a jour, pull-to-refresh
- Suppression de _AdminPlaceholderPage (plus utilisee)

### Story 14.7 : Verification SIRET via API Sirene (5 pts) — DONE

**Fichier cree :** `lib/core/services/sirene_service.dart`
- Appel API `recherche-entreprises.api.gouv.fr` (gratuit, sans cle)
- SiretVerificationResult (valid/invalid + companyName, siren, legalForm)
- Gestion erreurs : SIRET invalide, entreprise fermee, timeout, reseau

**Fichiers modifies :**
- `auth_event.dart` — +champs optionnels siret, companyName, siren, legalForm
- `auth_bloc.dart` — Metadata enrichies pour recruteurs
- `register_page.dart` — Champ SIRET (14 digits, visible si recruteur) + verification API au submit

### Story 14.8 : Upload document justificatif (3 pts) — DONE

**Fichiers modifies :**
- `profile_repository.dart` — +`uploadDocument()` (Supabase Storage bucket `verification-docs`)
- `edit_recruiter_profile_page.dart` — Section "Document de verification" avec 4 etats :
  - Verifie (badge vert)
  - Rejete (motif + re-upload)
  - Document envoye (en attente de verification)
  - Pas de document (choix type → pick image → preview → upload)

---

## Ce qui a ete fait — Sprint 13 (2026-02-23)

### Stories 13.2-13.6 (15 pts) — DONE

- **13.2** Stats Premium — vues + viewers + tendance hebdo
- **13.3** Page Parametres — menu complet settings
- **13.4** FAQ in-app — 5 sections, 18 questions, recherche
- **13.5** Contact support — formulaire mailto
- **13.6** Mentions legales — CGU + Confidentialite + Mentions

### Story 13.1 : Camera in-app (8 pts) — REPORTEE (emulateur requis)

---

## Ce qui a ete fait — Sprint 12 (2026-02-22/23)

### Stories 12.1-12.7 (26 pts) — DONE

- **12.1** error_translator.dart — traduction exceptions → Failure
- **12.2** Firebase Crashlytics — init + guards web
- **12.3** seed.sql — 6 users, profiles, videos, messages
- **12.4** Page Premium Chercheur — BLoC + UI
- **12.5** Page Premium Recruteur — offre + credits
- **12.6** Integration Stripe Checkout — PaymentSheet + Edge Functions
- **12.7** Webhooks Stripe — 5 evenements, RPC credits

### Configuration Stripe (mode test)

| Element | Valeur |
|---------|--------|
| Publishable Key | `pk_test_51T3hr...` (dans `.env`) |
| Secret Key | `sk_test_51T3hr...` (dans Supabase secrets) |
| Webhook Secret | `whsec_c1yCS0N...` (dans Supabase secrets) |
| Webhook URL | `https://ojslqytmuifaofojutgb.supabase.co/functions/v1/stripe-webhook` |
| Premium Chercheur | `price_1T3hupIKNrg8W1BsqQFqUKu5` (4,99 EUR/mois) |
| Premium Recruteur | `price_1T3hwgIKNrg8W1Bs9MJ5To2P` (499 EUR/mois) |
| Credit Video | `price_1T3hxYIKNrg8W1Bs1iKdjUq2` (99 EUR) |
| Credit Affiche | `price_1T3hy2IKNrg8W1BsC4f0QGuJ` (49 EUR) |
| Carte test | `4242 4242 4242 4242` |

---

## Sessions precedentes

### PRD + Architecture (2026-02-18)

- PRD valide (~85/100) : `_bmad-output/prd-etoile-draft.md`
- Architecture COMPLETE (8/8 etapes) : `_bmad-output/architecture.md`
- 6 ADR + 17 decisions categorielles

### Profil Recruteur Public (TERMINE)

- Page profil public read-only pour seekers
- Migration `video_contract_type`, dropdown type contrat
- Fix messagerie web (Firebase lazy-init + trigger push resilient)

### FR29 - Carte OpenStreetMap (TERMINE)

- Autocompletion Photon API, markers batiment, carte lecture/edition

---

## Sprints completes

| Sprint | Contenu | Statut |
|--------|---------|--------|
| 1-8 | Auth, Profil, Feed, Messages, Worker, etc. | Done |
| 9 | Notifications Push | Done |
| 10 | Import video + Affiche + Publications | Done (sauf camera) |
| 11 | Feed 2 onglets + Presentation entreprise | Done |
| FR29 | Carte OpenStreetMap | Done |
| - | Profil recruteur public + contract_type | Done |
| - | PRD validation + Architecture complete | Done |
| 12 | Infra + Paiements Stripe (7/7 stories, 26 pts) | Done |
| 13 | Stats + Parametres + FAQ + Contact + Legal (5/6, 15 pts) | Done (sauf camera) |
| **14** | **Administration + SIRET + Document (8/8 stories, 34 pts)** | **DONE** |
| **15** | **RGPD + Signalement + Gestion abo + Tests (6/6 stories, 25 pts)** | **DONE** |
| **16** | **Polish + Beta (6/6 stories, 17/17 pts)** | **DONE** |

### Prochains sprints

- Story reportee : 13.1 Camera in-app (8 pts, emulateur requis)
- Sprint 17 : Camera in-app + Beta testing
- Tous les pre-requis (admin role, bucket, Edge Functions, RLS, VIEW users) sont deployes

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

### Stripe
- **Dashboard** : https://dashboard.stripe.com (mode test)
- **Account** : gzzadri@gmail.com

### Comptes de test
- **Recruteur** : emma@gmail.com (entreprise UDI, secteur BTP)

---

## Documents BMAD

| Document | Fichier | Statut |
|----------|---------|--------|
| PRD | `_bmad-output/prd-etoile-draft.md` | Valide (~85/100) |
| Architecture | `_bmad-output/architecture.md` | COMPLETE (8/8 etapes) |
| Architecture draft (extrait PRD) | `_bmad-output/architecture-etoile-draft.md` | Draft (reference) |
| UX Design | `_bmad-output/ux-design-etoile-draft.md` | Draft |
| Sprint Plan | `_bmad-output/sprint-plan.md` | Sprint 16 DONE (6/6) |
| Epics | `_bmad-output/epics.md` | Complet |
| PRD Notifications | `_bmad-output/prd-notifications-push.md` | Complet |
| Archi Notifications | `_bmad-output/architecture-notifications-push.md` | Complet |
| Instructions Claude | `CLAUDE.md` | Cree |

---

*Sauvegarde mise a jour le 2026-02-25*
*Sprint 16 TERMINE (6/6 stories, 17/17 pts). Deprecations fix, Bloquer utilisateur, Splash screen + App icon, 25 tests, Navigation guards, Welcome page polish. App quasi-complete pour beta (manque camera 13.1).*
