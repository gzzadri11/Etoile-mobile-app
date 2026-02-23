# Session BMAD - Etoile Mobile App

**Date de mise a jour** : 2026-02-23
**Statut** : Sprint 13 quasi TERMINE (5/6 stories, 15 pts). Camera reportee (emulateur requis).

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

## Ce qui a ete fait — Sprint 13 (2026-02-23)

### Story 13.2 : Stats Premium (5 pts) — DONE

**Fichiers crees :**
- `lib/features/profile/data/models/video_stats.dart` — Data class VideoStats
- `lib/features/profile/data/repositories/stats_repository.dart` — Requetes video_views + check isPremium
- `lib/features/profile/presentation/widgets/stats_card.dart` — Widget stats reel

**Fichiers modifies :**
- `profile_state.dart` — +`isPremium` et `stats` sur SeekerProfileLoaded et RecruiterProfileLoaded
- `profile_bloc.dart` — +StatsRepository, charge premium+stats en parallele
- `profile_page.dart` — Remplace `_StatisticsCard` placeholder par `StatsCard` reel
- `injection_container.dart` — +StatsRepository singleton

**Comportement :**
- Premium : vues totales + viewers uniques + tendance hebdo (vert/rouge/gris)
- Non-premium : message teaser + CTA "Passer Premium" (route adaptee seeker/recruteur)
- Donnees chargees depuis `video_views` (RLS filtre auto)

### Story 13.3 : Page Parametres (3 pts) — DONE

**Fichier cree :** `lib/features/settings/presentation/pages/settings_page.dart`
- Menu : Mon profil, Premium, FAQ, Contact support, CGU, Confidentialite, Version, Deconnexion
- Navigation adaptee selon role (seeker/recruteur) pour profil et premium
- Dialog de confirmation pour la deconnexion

**Fichier modifie :** `app_router.dart` — +4 nouvelles routes (faq, contact, terms, privacy)

### Story 13.4 : FAQ in-app (3 pts) — DONE

**Fichier cree :** `lib/features/settings/presentation/pages/faq_page.dart`
- 5 sections, 18 questions : Compte, Video, Messages, Paiements, Technique
- Barre de recherche temps reel (filtre question + reponse)
- Accordeon ExpansionTile dans des Card
- Bouton "Contacter le support" en bas

### Story 13.5 : Formulaire contact support (2 pts) — DONE

**Fichier cree :** `lib/features/settings/presentation/pages/contact_support_page.dart`
- Formulaire : Sujet (dropdown 4 choix) + Description (min 20 car.)
- Envoi via `url_launcher` (mailto:support@etoile-app.fr)
- Ecran de confirmation apres envoi

### Story 13.6 : Mentions legales / CGU / Confidentialite (2 pts) — DONE

**Fichier cree :** `lib/features/settings/presentation/pages/legal_page.dart`
- Page generique `LegalPage` reutilisee 3 fois via factory constructors
- `LegalPage.termsOfService()` — CGU (8 sections)
- `LegalPage.privacyPolicy()` — Confidentialite RGPD (8 sections)
- `LegalPage.legalNotice()` — Mentions legales (5 sections)

### Story 13.1 : Camera in-app (8 pts) — REPORTEE

- Necessite emulateur Android (pas faisable sur Edge)
- A faire lors d'une session avec emulateur

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
| **12** | **Infra + Paiements Stripe (7/7 stories, 26 pts)** | **DONE** |
| **13** | **Stats + Parametres + FAQ + Contact + Legal (5/6, 15 pts)** | **DONE (sauf camera)** |

### Prochains sprints

- Sprint 13 restant : Story 13.1 Camera in-app (8 pts, emulateur requis)
- Sprint 14 : Administration (Epic 7) + Support (Epic 8)
- Sprint 15 : Polish + Beta

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
| Sprint Plan | `_bmad-output/sprint-plan.md` | Sprint 13 quasi DONE |
| Epics | `_bmad-output/epics.md` | Complet |
| PRD Notifications | `_bmad-output/prd-notifications-push.md` | Complet |
| Archi Notifications | `_bmad-output/architecture-notifications-push.md` | Complet |
| Instructions Claude | `CLAUDE.md` | Cree |

---

*Sauvegarde mise a jour le 2026-02-23*
*Sprint 13 quasi TERMINE (5/6 stories). Camera reportee. Pret pour Sprint 14 ou camera avec emulateur.*
