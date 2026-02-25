---
status: validated
validatedAt: 2026-02-02
author: BMad Master (avec Bob - SM)
projectName: Etoile Mobile App
totalStories: 47
totalSprints: 10
sprintDuration: 1 week
---

# Etoile Mobile App - Sprint Planning

## Vue d'Ensemble

| Métrique | Valeur |
|----------|--------|
| **Total Stories** | 47 |
| **Total Epics** | 9 (Epic 0-8) |
| **Durée Sprint** | 1 semaine |
| **Durée MVP** | 10 sprints |
| **Statut** | Validé |

---

## Sprint 1: Fondation Backend 🏗️ ✅ COMPLETE

**Objectif:** Finaliser l'infrastructure backend
**Statut:** ✅ TERMINE (4/4 complete)

| ID | Story | Epic | Description | Points | Statut |
|----|-------|------|-------------|--------|--------|
| **0.2** | **Configuration Supabase** | E0 | Auth, DB, Realtime | 5 | ✅ **Complete** |
| **0.3** | **Configuration Cloudflare R2** | E0 | Vidéo storage + Workers | 5 | ✅ **Complete** |
| **0.4** | **Configuration Stripe** | E0 | Mode test, produits, webhooks | 3 | ✅ **Complete** |
| **0.5** | **Schéma Base de Données** | E0 | 14 tables + RLS policies | 8 | ✅ **Complete** |

**Total Points:** 21/21 (100%)

**Critères de Done:**
- [x] Supabase connecté depuis l'app Flutter
- [x] Bucket R2 créé avec Worker presigned URLs
- [x] Stripe en mode test avec produits créés
- [x] Toutes les tables créées avec RLS activé

---

## Sprint 2: Authentification Core 🔐

**Objectif:** Inscription et connexion fonctionnelles
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 1.1 | Inscription Chercheur | E1 | Email, password, rôle seeker | 5 |
| 1.2 | Inscription Recruteur | E1 | SIRET, document upload, pending status | 8 |
| 1.3 | Connexion / Déconnexion | E1 | JWT tokens, secure storage | 5 |
| 1.6 | Réinitialisation MDP | E1 | Email reset flow | 3 |

**Total Points:** 21

**Critères de Done:**
- [ ] Chercheur peut s'inscrire et se connecter
- [ ] Recruteur peut s'inscrire (statut pending)
- [ ] Tokens JWT stockés dans secure storage
- [ ] Reset password fonctionnel

---

## Sprint 3: Profils 👤

**Objectif:** Profils complets pour les deux rôles
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 1.4 | Profil Chercheur | E1 | Secteur, contrat, zone, dispo | 5 |
| 1.5 | Profil Recruteur | E1 | Logo, description, secteur | 5 |
| 2.1 | Enregistrement Vidéo (début) | E2 | Camera preview, UI coaching | 8 |

**Total Points:** 18

**Critères de Done:**
- [ ] Profil chercheur complet et modifiable
- [ ] Profil recruteur avec upload logo
- [ ] Écran caméra avec aperçu fonctionnel

---

## Sprint 4: Vidéo Chercheur 🎬

**Objectif:** Flux complet d'enregistrement et publication vidéo
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 2.1 | Enregistrement Vidéo (fin) | E2 | 40s timer, coaching prompts | 8 |
| 2.2 | Prévisualisation | E2 | Replay, recommencer | 5 |
| 2.3 | Publication Catégorie | E2 | Upload R2, thumbnail | 8 |
| 2.4 | Modification Vidéo | E2 | Remplacer existante | 3 |
| 2.5 | Suppression Vidéo | E2 | Soft delete, RGPD | 2 |

**Total Points:** 26

**Critères de Done:**
- [ ] Enregistrement 40s avec coaching visuel
- [ ] Upload vidéo vers R2 fonctionnel
- [ ] Vidéo visible dans le feed après publication
- [ ] Modification et suppression fonctionnelles

---

## Sprint 5: Vidéo Recruteur 📢

**Objectif:** Publications recruteur (vidéo + affiche)
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 3.1 | Import Vidéo Galerie | E3 | Sélection, crop 40s | 5 |
| 3.2 | Enregistrement In-App | E3 | Même flow que chercheur | 3 |
| 3.3 | Publication Affiche | E3 | Image upload, ratio 9:16 | 5 |
| 3.4 | Gestion Publications | E3 | Liste, stats (premium) | 5 |
| 3.5 | Modification/Suppression | E3 | Edit titre/catégorie | 3 |

**Total Points:** 21

**Critères de Done:**
- [ ] Recruteur peut importer ou enregistrer vidéo
- [ ] Recruteur peut publier affiche
- [ ] Liste des publications accessible
- [ ] Crédits décrémentés après publication

---

## Sprint 6: Feed & Découverte 📱

**Objectif:** Navigation TikTok-style fonctionnelle
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 4.1 | Feed Candidats (Recruteur) | E4 | Swipe vertical, autoplay | 8 |
| 4.2 | Feed Offres (Chercheur) | E4 | Vidéos + affiches | 5 |
| 4.3 | Lecture Vidéo | E4 | Play/pause, progress bar | 5 |
| 4.4 | Filtres | E4 | Catégorie, zone, contrat | 5 |
| 4.5 | Préchargement | E4 | Buffer 2 vidéos suivantes | 5 |
| 4.6 | Profil depuis Feed | E4 | Bottom sheet détail | 3 |

**Total Points:** 31

**Critères de Done:**
- [ ] Feed vertical style TikTok fonctionnel
- [ ] Vidéos se chargent < 2s
- [ ] Filtres appliqués correctement
- [ ] Profil accessible depuis le feed

---

## Sprint 7: Messagerie 💬

**Objectif:** Communication temps réel
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 5.1 | Initier Conversation | E5 | Création conversation | 5 |
| 5.2 | Liste Conversations | E5 | Tri par date, badge unread | 5 |
| 5.3 | Chat Temps Réel | E5 | Supabase Realtime, optimistic UI | 8 |
| 5.4 | Notifications Push | E5 | FCM/APNs integration | 8 |
| 5.5 | Bloquer Utilisateur | E5 | Block list, hide content | 3 |
| 5.6 | Signaler Conversation | E5 | Report avec motif | 2 |

**Total Points:** 31

**Critères de Done:**
- [ ] Messages arrivent en temps réel
- [ ] Notifications push fonctionnelles
- [ ] Blocage et signalement opérationnels

---

## Sprint 8: Paiements 💳

**Objectif:** Monétisation complète
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 6.1 | Page Premium Chercheur | E6 | Avantages, CTA | 3 |
| 6.2 | Page Premium Recruteur | E6 | Avantages, pricing | 3 |
| 6.3 | Paiement Stripe | E6 | Checkout, confirmation | 8 |
| 6.4 | Achat Crédits | E6 | Vidéo 100€, Affiche 50€ | 5 |
| 6.5 | Gestion Abonnement | E6 | Annulation, historique | 5 |
| 6.6 | Webhooks Stripe | E6 | Edge function events | 8 |

**Total Points:** 32

**Critères de Done:**
- [ ] Paiement carte fonctionnel
- [ ] Abonnements activés après paiement
- [ ] Webhooks traitent les événements Stripe
- [ ] Crédits à l'unité fonctionnels

---

## Sprint 9: Admin & Support 🛠️

**Objectif:** Outils d'administration et aide utilisateur
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 7.1 | Liste Recruteurs Pending | E7 | Back-office admin | 5 |
| 7.2 | Validation/Rejet | E7 | Approve/reject flow | 5 |
| 7.3 | Liste Signalements | E7 | Reports pending | 3 |
| 7.4 | Modération Contenus | E7 | Suspend/ban actions | 5 |
| 7.5 | Dashboard Stats | E7 | KPIs, graphiques | 8 |
| 8.1 | FAQ In-App | E8 | Questions/réponses | 3 |
| 8.2 | Formulaire Contact | E8 | Email support | 2 |
| 8.3 | Mentions Légales | E8 | CGU, confidentialité | 2 |

**Total Points:** 33

**Critères de Done:**
- [ ] Admin peut valider/rejeter recruteurs
- [ ] Modération signalements fonctionnelle
- [ ] Dashboard avec métriques clés
- [ ] FAQ et contact support accessibles

---

## Sprint 10: Polish & Beta ✨

**Objectif:** Tests, corrections, préparation lancement
**Statut:** À faire

**Tâches:**
- [ ] Tests unitaires (coverage > 70%)
- [ ] Tests d'intégration critiques
- [ ] Tests E2E parcours principaux
- [ ] Corrections bugs critiques
- [ ] Optimisations performances (vidéo < 2s)
- [ ] Audit accessibilité (WCAG)
- [ ] Préparation App Store (screenshots, description)
- [ ] Préparation Google Play
- [ ] Beta testeurs internes
- [ ] Documentation déploiement

---

## Résumé par Epic

| Epic | Nom | Stories | Sprints |
|------|-----|---------|---------|
| 0 | Fondation Technique | 5 | Sprint 1 |
| 1 | Authentification & Profils | 6 | Sprint 2-3 |
| 2 | Vidéo Chercheur | 5 | Sprint 3-4 |
| 3 | Vidéo & Affiche Recruteur | 5 | Sprint 5 |
| 4 | Feed & Découverte | 6 | Sprint 6 |
| 5 | Messagerie & Contact | 6 | Sprint 7 |
| 6 | Paiements & Abonnements | 6 | Sprint 8 |
| 7 | Administration | 5 | Sprint 9 |
| 8 | Support & Aide | 3 | Sprint 9 |

---

## Dépendances Critiques

```
Sprint 1 (Backend)
    ↓
Sprint 2 (Auth) ← Requis pour tout le reste
    ↓
Sprint 3 (Profils) → Sprint 4 (Vidéo Chercheur)
                   → Sprint 5 (Vidéo Recruteur)
                        ↓
                   Sprint 6 (Feed) ← Vidéos requises
                        ↓
                   Sprint 7 (Messages)
                        ↓
                   Sprint 8 (Paiements)
                        ↓
                   Sprint 9 (Admin)
                        ↓
                   Sprint 10 (Beta)
```

---

## Velocity Cible

| Sprint | Points | Cumul |
|--------|--------|-------|
| 1 | 21 | 21 |
| 2 | 21 | 42 |
| 3 | 18 | 60 |
| 4 | 26 | 86 |
| 5 | 21 | 107 |
| 6 | 31 | 138 |
| 7 | 31 | 169 |
| 8 | 32 | 201 |
| 9 | 33 | 234 |
| 10 | - | - |

**Total Points:** ~234 (hors Sprint 10 polish)
**Vélocité Moyenne:** ~26 points/sprint

---

## Sprints 2-11 : COMPLETS (realite terrain)

> **Note** : Les Sprints 2-10 du plan initial ont ete implementes avec des ajustements.
> Le plan original etait theorique. Voici ce qui a ete reellement livre :

| Sprint reel | Contenu livre | Statut |
|-------------|---------------|--------|
| 2-3 | Auth (inscription, login, reset) + Profils (chercheur, recruteur) | Done |
| 4-5 | Video import galerie + publication (offre video + affiche) | Done |
| 6 | Feed TikTok vertical 2 onglets + profil depuis feed | Done |
| 7-8 | Messagerie temps reel + conversations | Done |
| 9 | Notifications Push (FCM + Edge Function) | Done |
| 10 | Import video + Affichage publications + gestion (sauf camera) | Done |
| 11 | Feed 2 onglets (chercheur/recruteur) + Presentation entreprise | Done |
| FR29 | Carte OpenStreetMap (flutter_map + Photon) | Done |
| Hors sprint | Profil recruteur public + contract_type videos | Done |
| Hors sprint | PRD valide (~85/100) + Architecture complete (8/8) | Done |
| Hors sprint | Design system app_theme.dart (594 lignes) | Done |

---

## Sprint 12 : Infra + Paiements Stripe 💳 ✅ COMPLETE

**Objectif :** Poser les bases de qualite (monitoring, erreurs, donnees de test) et implementer la monetisation (Epic 6 - Paiements)
**Date de planification :** 2026-02-22
**Date de completion :** 2026-02-23
**Velocite realisee :** 26/26 points (100%)

### Etat du code avant Sprint 12

| Element | Statut | Detail |
|---------|--------|--------|
| `StripeService` | Code OK, non wire | 319 lignes, PaymentSheet, cancel, portal |
| `StripePrices` / `StripeProducts` | Constantes OK | IDs placeholder (a remplacer par vrais IDs Stripe) |
| `PaymentFailure` | OK | 4 factories FR dans failures.dart |
| `PaymentResult` | OK | success/failed/cancelled dans stripe_service.dart |
| Table `subscriptions` | OK | Colonnes stripe_*, status, plan_type |
| Table `purchases` | A verifier | Devrait exister dans initial_schema |
| `flutter_stripe` | OK | v11.2.0 dans pubspec.yaml |
| `AppConfig.stripePublishableKey` | OK | Charge depuis .env |
| StripeService dans DI | **MANQUANT** | Pas enregistre dans injection_container.dart |
| Stripe.initialize() dans main | **MANQUANT** | Pas appele au demarrage |
| Edge Functions Stripe | **MANQUANT** | create-subscription-intent, create-payment-intent, stripe-webhook |
| `firebase_crashlytics` | **MANQUANT** | Package absent de pubspec.yaml |
| `error_translator.dart` | **MANQUANT** | core/utils/ n'existe pas encore |
| `seed.sql` | **MANQUANT** | Pas de donnees de test |

---

### Story 12.1 : Creer error_translator.dart (2 pts) 🔧

**En tant que** developpeur,
**Je veux** un traducteur d'exceptions Supabase/Stripe vers des Failure en francais,
**Afin que** les messages d'erreur soient toujours comprehensibles pour l'utilisateur.

**Fichier a creer :** `lib/core/utils/error_translator.dart`

**Criteres d'acceptation :**

- [ ] Creer le dossier `core/utils/` et le fichier `error_translator.dart`
- [ ] Classe `ErrorTranslator` avec methode statique `translate(dynamic exception) → Failure`
- [ ] Gerer les exceptions Supabase : `AuthException`, `PostgrestException`, `StorageException`
- [ ] Gerer les exceptions Stripe : `StripeException`
- [ ] Gerer les exceptions reseau : `SocketException`, `TimeoutException`
- [ ] Mapper vers les Failure existantes (`AuthFailure`, `ServerFailure`, `NetworkFailure`, `PaymentFailure`, etc.)
- [ ] Fallback vers `UnknownFailure` pour les exceptions non reconnues
- [ ] Logs `debugPrint('[ErrorTranslator] ...')` pour chaque traduction

**Contexte technique :**
- Classes Failure existantes dans `core/errors/failures.dart` (263 lignes, toutes en francais)
- Pattern d'utilisation dans les repositories : `try { ... } catch (e) { return ErrorTranslator.translate(e); }`

---

### Story 12.2 : Integrer Firebase Crashlytics (2 pts) 📊

**En tant que** developpeur,
**Je veux** que les crashes et erreurs soient reportes automatiquement,
**Afin que** je puisse monitorer la qualite en production.

**Fichiers a modifier :**
- `pubspec.yaml` : ajouter `firebase_crashlytics`
- `lib/main.dart` : initialiser Crashlytics
- `lib/di/injection_container.dart` : (optionnel) enregistrer le service

**Criteres d'acceptation :**

- [ ] Ajouter `firebase_crashlytics: ^4.3.3` dans pubspec.yaml
- [ ] Initialiser Crashlytics dans `main.dart` (apres Firebase.initializeApp)
- [ ] Configurer `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError`
- [ ] Configurer `PlatformDispatcher.instance.onError` pour les erreurs async
- [ ] Guard `kIsWeb` (Crashlytics ne supporte pas le web)
- [ ] Respecter `AppConfig.enableCrashReporting` (false en dev)
- [ ] Tester que l'init ne crash pas sur Edge (web guard)

**Contexte technique :**
- Firebase deja initialise dans main.dart (ligne 41)
- `AppConfig.enableCrashReporting` existe deja
- Guard `kIsWeb` deja en place pour Firebase Messaging

---

### Story 12.3 : Creer seed.sql (3 pts) 🌱

**En tant que** developpeur,
**Je veux** des donnees de test reproductibles,
**Afin que** je puisse tester toutes les features avec des donnees realistes.

**Fichier a creer :** `supabase/seed.sql`

**Criteres d'acceptation :**

- [ ] Creer des categories (10 secteurs : BTP, IT, Commerce, Sante, etc.)
- [ ] Creer des users de test (3 chercheurs, 2 recruteurs, 1 admin)
- [ ] Creer des seeker_profiles (complets, avec categories et contract_types)
- [ ] Creer des recruiter_profiles (1 verifie avec credits, 1 pending)
- [ ] Creer des videos de test (2 presentations, 2 offres, 1 affiche) avec status 'active'
- [ ] Creer des conversations + messages (1 conversation avec 5 messages)
- [ ] Utiliser des UUIDs deterministes (uuid_generate_v5 ou constantes)
- [ ] Ne PAS inclure de vrais emails/mots de passe — utiliser des donnees fictives
- [ ] Commenter chaque section (-- CATEGORIES, -- USERS, etc.)
- [ ] Compatible avec le schema existant (7 migrations)

**Contexte technique :**
- Tables : users, categories, seeker_profiles, recruiter_profiles, videos, conversations, messages, device_tokens
- Commande : `npx --prefix supabase supabase db reset` execute seed.sql automatiquement
- Compte de test existant : emma@gmail.com (recruteur UDI/BTP) — l'inclure

---

### Story 12.4 : Page Premium Chercheur (3 pts) ⭐

**En tant que** chercheur gratuit,
**Je veux** voir les avantages Premium et pouvoir m'abonner,
**Afin que** je puisse booster ma visibilite.

**Fichiers a creer :**
- `lib/features/payment/presentation/pages/seeker_premium_page.dart`
- `lib/features/payment/presentation/bloc/payment_bloc.dart`
- `lib/features/payment/presentation/bloc/payment_event.dart`
- `lib/features/payment/presentation/bloc/payment_state.dart`

**Criteres d'acceptation :**

- [ ] Page avec liste des avantages Premium chercheur :
  - Voir qui a consulte ta video
  - Statistiques detaillees (vues, duree moyenne)
  - Badge Premium visible dans le feed
  - Priorite dans les resultats
- [ ] Afficher le prix : **4,99 €/mois**
- [ ] Bouton CTA "S'abonner" (jaune, prominent)
- [ ] Si deja premium : afficher statut + date renouvellement + bouton "Gerer"
- [ ] Accessibilite : contrastes, semantique
- [ ] Route GoRouter : `/premium/seeker`

**Contexte technique :**
- Utiliser `AppTheme` pour le design (app_theme.dart)
- `AppColors.primaryYellow` pour le CTA
- Creer le feature folder `payment/` avec architecture BLoC standard

---

### Story 12.5 : Page Premium Recruteur (3 pts) ⭐

**En tant que** recruteur verifie gratuit,
**Je veux** voir les avantages Premium et acheter des credits,
**Afin que** je puisse publier plus d'offres.

**Fichier a creer :** `lib/features/payment/presentation/pages/recruiter_premium_page.dart`

**Criteres d'acceptation :**

- [ ] Page avec liste des avantages Premium recruteur :
  - 2 publications video + 2 affiches par semaine (incluses)
  - Statistiques detaillees (vues, qui a vu)
  - Badge Premium visible
  - Acces prioritaire aux profils
- [ ] Afficher le prix : **499 €/mois**
- [ ] Section "Credits a l'unite" :
  - +1 publication video : **99 €**
  - +1 affiche : **49 €**
- [ ] Bouton CTA "S'abonner" + boutons "Acheter" par credit
- [ ] Si deja premium : statut + credits restants + bouton "Gerer"
- [ ] Route GoRouter : `/premium/recruiter`

**Contexte technique :**
- Reutiliser le `PaymentBloc` de la story 12.4
- `StripeProducts.seekerPremium`, `recruiterPremium`, `videoCredit`, `posterCredit` deja definis

---

### Story 12.6 : Integration Stripe Checkout (8 pts) 💳

**En tant qu'** utilisateur,
**Je veux** payer par carte bancaire pour m'abonner ou acheter des credits,
**Afin que** mon abonnement/credits soient actives immediatement.

**Fichiers a modifier/creer :**
- `lib/di/injection_container.dart` : enregistrer StripeService
- `lib/main.dart` : appeler StripeService.initialize()
- `lib/features/payment/data/repositories/payment_repository.dart`
- `lib/features/payment/presentation/bloc/payment_bloc.dart` (enrichir)
- `supabase/functions/create-subscription-intent/index.ts` : **CREER**
- `supabase/functions/create-payment-intent/index.ts` : **CREER**

**Criteres d'acceptation :**

- [ ] Wire `StripeService` dans injection_container.dart (lazy singleton)
- [ ] Appeler `stripeService.initialize()` dans main.dart (apres Firebase, avant runApp)
- [ ] `PaymentRepository` :
  - `subscribeSeeker()` → appelle `presentSubscriptionPaymentSheet(priceId: StripePrices.seekerPremiumMonthly)`
  - `subscribeRecruiter()` → appelle `presentSubscriptionPaymentSheet(priceId: StripePrices.recruiterPremiumMonthly)`
  - `buyVideoCredit()` → appelle `presentOneTimePaymentSheet(priceId: StripePrices.videoCreditUnit)`
  - `buyPosterCredit()` → appelle `presentOneTimePaymentSheet(priceId: StripePrices.posterCreditUnit)`
  - `getSubscriptionStatus()` → query table subscriptions
  - `cancelSubscription(id)` → appelle StripeService.cancelSubscription
- [ ] `PaymentBloc` :
  - Events : Subscribe, BuyCredit, CancelSubscription, LoadSubscriptionStatus
  - States : PaymentInitial, PaymentLoading, PaymentSuccess, PaymentFailed, PaymentCancelled, SubscriptionLoaded
- [ ] Edge Function `create-subscription-intent` :
  - Recoit `priceId`, `userId`
  - Cree/recupere Stripe Customer
  - Cree Subscription avec `payment_behavior: 'default_incomplete'`
  - Retourne `clientSecret`, `ephemeralKey`, `customerId`, `subscriptionId`
- [ ] Edge Function `create-payment-intent` :
  - Recoit `priceId`, `quantity`, `userId`
  - Cree PaymentIntent
  - Retourne `clientSecret`, `paymentIntentId`
- [ ] Gestion d'erreur via `ErrorTranslator` (story 12.1)
- [ ] Tester le flow complet en mode test Stripe

**Contexte technique :**
- `StripeService` existe deja (stripe_service.dart, 319 lignes) — NE PAS le reecrire
- `PaymentResult` + `PaymentStatus` + `StripeProducts` + `StripePrices` deja definis
- Prix Stripe IDs a configurer dans le Dashboard Stripe (mode test)
- `.env` doit contenir `STRIPE_PUBLISHABLE_KEY=pk_test_...`

---

### Story 12.7 : Webhooks Stripe (5 pts) 🔔

**En tant que** systeme,
**Je veux** traiter les evenements Stripe automatiquement,
**Afin que** les statuts d'abonnement soient toujours a jour.

**Fichier a creer :** `supabase/functions/stripe-webhook/index.ts`

**Criteres d'acceptation :**

- [ ] Edge Function `stripe-webhook` deployee sur Supabase
- [ ] Verification de la signature Stripe (`stripe.webhooks.constructEvent`)
- [ ] Gerer les evenements :
  - `checkout.session.completed` → creer/activer subscription dans BDD
  - `invoice.paid` → mettre a jour `current_period_end`
  - `invoice.payment_failed` → statut `past_due`, notifier user
  - `customer.subscription.updated` → sync statut
  - `customer.subscription.deleted` → statut `expired`, `is_premium = false`
- [ ] Mettre a jour la table `subscriptions` a chaque evenement
- [ ] Mettre a jour `users.is_premium` et `users.premium_until`
- [ ] Pour les achats credits : incrementer `recruiter_profiles.video_credits` ou `poster_credits`
- [ ] Logger chaque evenement traite (pour debug)
- [ ] Retourner 200 OK meme si l'evenement n'est pas gere (Stripe best practice)
- [ ] Configurer le webhook URL dans Stripe Dashboard : `https://ojslqytmuifaofojutgb.supabase.co/functions/v1/stripe-webhook`

**Contexte technique :**
- Supabase Edge Functions (Deno, TypeScript)
- Secret `STRIPE_WEBHOOK_SECRET` dans Supabase secrets
- Pattern similaire a `supabase/functions/send-push/` existant
- Tables cibles : `subscriptions`, `purchases`, `users`, `recruiter_profiles`

---

### Resume Sprint 12

| Story | Titre | Points | Dependances |
|-------|-------|--------|-------------|
| 12.1 | error_translator.dart | 2 | Aucune |
| 12.2 | Firebase Crashlytics | 2 | Aucune |
| 12.3 | seed.sql | 3 | Aucune |
| 12.4 | Page Premium Chercheur | 3 | Aucune |
| 12.5 | Page Premium Recruteur | 3 | 12.4 (reutilise PaymentBloc) |
| 12.6 | Integration Stripe Checkout | 8 | 12.1, 12.4, 12.5 |
| 12.7 | Webhooks Stripe | 5 | 12.6 |
| **Total** | | **26** | |

**Ordre d'implementation recommande :**
```
12.1 (error_translator) ─┐
12.2 (Crashlytics)       ├─→ 12.4 (Premium Chercheur) ─→ 12.5 (Premium Recruteur) ─→ 12.6 (Stripe Checkout) ─→ 12.7 (Webhooks)
12.3 (seed.sql)          ─┘
```

Les 3 premieres stories (12.1, 12.2, 12.3) sont independantes et peuvent etre faites en parallele.

**Criteres de Done Sprint 12 :**
- [x] Erreurs traduites en francais dans toute l'app
- [x] Crashlytics actif (hors web)
- [x] Donnees de test reproductibles via seed.sql
- [x] Chercheur peut s'abonner Premium (4,99€/mois)
- [x] Recruteur peut s'abonner Premium (499€/mois) et acheter des credits
- [x] Webhooks traitent les evenements Stripe
- [x] Tout configure en mode Stripe test

---

## Sprint 13 : Camera + Stats + Settings 📷

**Objectif :** Integrer la camera in-app, afficher les statistiques premium, et completer l'experience utilisateur (parametres, FAQ, support, mentions legales).
**Date de planification :** 2026-02-23
**Velocite ciblee :** 23 points

### Etat du code avant Sprint 13

| Element | Statut | Detail |
|---------|--------|--------|
| `video_record_page.dart` | UI OK, pas de camera | Timer 40s, 3 phases, mais Container noir placeholder |
| Package `camera: ^0.11.0+2` | Present dans pubspec | Non importe dans le code |
| Stats Premium | Card UI + gate | Texte placeholder "Stats detaillees ici" |
| `video_views` table | OK en BDD | Enregistre les vues, pas encore exploitee |
| Page Parametres | Stub | "A implementer" |
| Page Aide | Stub | "A implementer" |
| Filtres/Recherche | FAIT | Bottom sheet avancee (secteur, localisation, contrat, dispo) |

---

### Story 13.1 : Camera in-app chercheur + recruteur (8 pts) 📷

**En tant que** chercheur ou recruteur,
**Je veux** enregistrer une video directement dans l'app,
**Afin de** publier ma presentation ou mon offre sans quitter l'app.

**Fichiers a modifier :**
- `lib/features/video/presentation/pages/video_record_page.dart` — integrer `CameraController`
- `lib/features/video/presentation/bloc/video_bloc.dart` — evenements camera (init, start, stop, dispose)
- `pubspec.yaml` — verifier permissions camera/micro

**Criteres d'acceptation :**

- [ ] A l'ouverture, la camera frontale s'affiche en preview (miroir)
- [ ] Bouton "Demarrer" lance l'enregistrement avec timer 40s
- [ ] 3 phases de coaching affichees (0-10s, 10-30s, 30-40s)
- [ ] Arret automatique a 40s, video sauvegardee localement
- [ ] Preview de la video enregistree avec boutons "Recommencer" / "Valider"
- [ ] "Valider" envoie vers le flow de publication existant (upload R2)
- [ ] Gestion des permissions camera/micro (demande + message si refuse)
- [ ] Fonctionne pour chercheur ET recruteur (meme ecran)
- [ ] Guard `!kIsWeb` — afficher message "Camera non disponible sur web"

**Contexte technique :**
- Package `camera` deja dans pubspec, juste pas utilise
- `video_record_page.dart` a deja toute la logique de timer/phases/etats — juste remplacer le Container noir par CameraPreview
- L'upload vers R2 est deja fonctionnel (VideoUploadService + Cloudflare Worker)
- Tester sur emulateur Android (pas sur Edge)

---

### Story 13.2 : Stats Premium (vues, profils, tendances) (5 pts) 📊

**En tant que** utilisateur premium,
**Je veux** voir les statistiques de mes videos,
**Afin de** comprendre ma visibilite sur la plateforme.

**Fichiers a creer/modifier :**
- `lib/features/profile/data/repositories/stats_repository.dart` — **CREER** : requetes video_views
- `lib/features/profile/presentation/widgets/stats_card.dart` — **CREER** : widget stats reel
- `lib/features/profile/presentation/pages/profile_page.dart` — remplacer placeholder stats

**Criteres d'acceptation :**

- [ ] **Chercheur premium** voit :
  - Nombre total de vues de sa video
  - Nombre de recruteurs uniques qui ont vu
  - Tendance (vues cette semaine vs semaine derniere : +X%)
- [ ] **Recruteur premium** voit :
  - Nombre total de vues par publication
  - Nombre de chercheurs uniques qui ont vu
  - Tendance hebdomadaire
- [ ] **Non-premium** : message inchange ("Passez Premium pour les details")
- [ ] Donnees chargees depuis la table `video_views` (count + distinct user_id)
- [ ] Affichage avec icones et couleurs (vert = hausse, rouge = baisse)

**Contexte technique :**
- Table `video_views` existe deja (user_id, video_id, viewed_at)
- Requetes : `count(*)`, `count(distinct user_id)`, filtre par `viewed_at` pour tendance
- ProfileBloc peut etre enrichi ou nouveau StatsBloc cree

---

### Story 13.3 : Page Parametres complete (3 pts) ⚙️

**En tant que** utilisateur,
**Je veux** acceder a mes parametres,
**Afin de** gerer mon compte et acceder aux informations utiles.

**Fichiers a modifier :**
- `lib/core/router/app_router.dart` — remplacer `_SettingsPage` stub par vraie page
- `lib/features/settings/presentation/pages/settings_page.dart` — **CREER**

**Criteres d'acceptation :**

- [ ] Menu liste avec les items suivants :
  - Mon profil → navigation vers edit profile
  - Premium → navigation vers page premium (selon role)
  - Aide / FAQ → navigation vers `/settings/help`
  - Contacter le support → navigation vers formulaire
  - Mentions legales → navigation vers page legale
  - CGU → navigation vers page CGU
  - Politique de confidentialite → navigation vers page confidentialite
  - Version de l'app (texte grise, non cliquable)
  - Se deconnecter (bouton rouge en bas)
- [ ] Deconnexion : confirmation dialog → AuthBloc.logout → retour welcome
- [ ] UI coherente avec le design system (ListTile, icones, AppTheme)

---

### Story 13.4 : FAQ in-app (3 pts) ❓

**En tant que** utilisateur,
**Je veux** consulter une FAQ,
**Afin de** trouver des reponses a mes questions courantes.

**Fichiers a creer :**
- `lib/features/settings/presentation/pages/faq_page.dart` — **CREER**

**Criteres d'acceptation :**

- [ ] Liste de questions organisees par theme (ExpansionTile) :
  - **Compte & Profil** (3-4 questions)
  - **Video** (3-4 questions)
  - **Messages** (2-3 questions)
  - **Paiements & Premium** (3-4 questions)
  - **Technique** (2-3 questions)
- [ ] Chaque question s'ouvre/ferme au tap (accordeon)
- [ ] Barre de recherche en haut (filtre les questions par mot-cle)
- [ ] Bouton "Contacter le support" en bas de la page
- [ ] Contenu en francais, ton chaleureux et accessible

---

### Story 13.5 : Formulaire contact support (2 pts) 📧

**En tant que** utilisateur,
**Je veux** contacter le support,
**Afin de** signaler un probleme ou poser une question.

**Fichiers a creer :**
- `lib/features/settings/presentation/pages/contact_support_page.dart` — **CREER**

**Criteres d'acceptation :**

- [ ] Formulaire avec : Sujet (dropdown), Description (TextArea), bouton Envoyer
- [ ] Sujets : Probleme technique, Question sur Premium, Signaler un bug, Autre
- [ ] Validation : sujet requis, description min 20 caracteres
- [ ] Envoi : ouvre le client mail avec `url_launcher` (`mailto:support@etoile-app.fr?subject=...&body=...`)
- [ ] Message de confirmation apres envoi
- [ ] Pre-remplir l'email de l'utilisateur connecte

---

### Story 13.6 : Mentions legales / CGU / Confidentialite (2 pts) 📜

**En tant que** utilisateur,
**Je veux** consulter les documents legaux,
**Afin de** connaitre mes droits et les conditions d'utilisation.

**Fichiers a creer :**
- `lib/features/settings/presentation/pages/legal_page.dart` — **CREER** (page generique)

**Criteres d'acceptation :**

- [ ] 3 pages accessibles depuis Parametres : Mentions legales, CGU, Confidentialite
- [ ] Contenu en texte statique (pas de WebView MVP) dans des ScrollView
- [ ] Contenu placeholder realiste (structure type, sections principales)
- [ ] Une seule page generique `LegalPage(title, content)` reutilisee 3 fois
- [ ] URLs definies dans AppConfig (`privacyPolicyUrl`, `termsOfServiceUrl`)

---

### Resume Sprint 13

| Story | Titre | Points | Dependances |
|-------|-------|--------|-------------|
| 13.1 | Camera in-app | 8 | Aucune |
| 13.2 | Stats Premium | 5 | Aucune |
| 13.3 | Page Parametres | 3 | Aucune |
| 13.4 | FAQ in-app | 3 | 13.3 (route settings) |
| 13.5 | Formulaire contact | 2 | 13.3 (route settings) |
| 13.6 | Mentions legales | 2 | 13.3 (route settings) |
| **Total** | | **23** | |

**Ordre d'implementation recommande :**
```
13.1 (Camera) ──────────────────────────────────────┐
13.2 (Stats Premium) ──────────────────────────────┤
13.3 (Parametres) ─→ 13.4 (FAQ) ─→ 13.5 (Contact) ─→ 13.6 (Legal) ─┤
                                                    └─→ DONE
```

13.1 et 13.2 sont independantes. 13.3 debloque 13.4/13.5/13.6.

**Criteres de Done Sprint 13 :**
- [ ] Camera in-app fonctionnelle (enregistrement 40s, preview, upload)
- [ ] Stats Premium affichent les vraies donnees (vues, tendances)
- [ ] Page Parametres complete avec tous les liens
- [ ] FAQ consultable avec recherche
- [ ] Formulaire de contact operationnel
- [ ] Pages legales accessibles

---

## Sprint 14 : Administration 🛡️

**Objectif :** Administration in-app (verification recruteurs, moderation, stats) + verification SIRET automatisee via API Sirene + upload document justificatif.
**Date de planification :** 2026-02-24
**Velocite ciblee :** 34 points

### Etat du code avant Sprint 14

| Element | Statut | Detail |
|---------|--------|--------|
| Table `reports` | OK en BDD | 4 statuts (pending/reviewing/actioned/dismissed), RLS admin |
| Table `blocks` | OK en BDD | blocker_id/blocked_id, unique constraint |
| Table `audit_logs` | OK en BDD | action, entity_type, old/new_values JSONB |
| RLS admin | OK | Policy "Admins can manage reports" + "Admins can read all recruiter profiles" |
| `AuthAuthenticated.isAdmin` | OK | Getter `role == 'admin'` dans auth_state.dart |
| `RecruiterProfileModel` | OK | verificationStatus, verifiedAt, verifiedBy, rejectionReason, siret, documentUrl |
| Feature `admin/` | CREE (14.1) | Structure + dashboard + routes + guard |
| Routes admin | CREE (14.1) | `/admin`, `/admin/verifications`, `/admin/reports`, `/admin/stats` |
| Compte admin en BDD | **MANQUANT** | Aucun user avec role='admin' — a creer via seed ou SQL |
| SIRET a l'inscription | **MANQUANT** | Pas collecte dans register_page.dart |
| API Sirene | **MANQUANT** | Pas d'appel de verification SIRET |
| Upload document | **MANQUANT** | Colonnes BDD ok, pas d'UI |

---

### Story 14.1 : Structure admin + route guard + dashboard hub (3 pts) 🏗️

**En tant qu'** admin,
**Je veux** acceder a un espace d'administration protege,
**Afin de** gerer la plateforme depuis l'app.

**Fichiers a creer :**
- `lib/features/admin/presentation/pages/admin_dashboard_page.dart` — Page hub avec navigation
- `lib/features/admin/presentation/bloc/admin_bloc.dart` — BLoC admin (events + states)
- `lib/features/admin/presentation/bloc/admin_event.dart`
- `lib/features/admin/presentation/bloc/admin_state.dart`

**Fichiers a modifier :**
- `lib/core/router/app_router.dart` — Ajouter routes admin avec guard isAdmin
- `lib/features/settings/presentation/pages/settings_page.dart` — Ajouter lien "Administration" (visible uniquement si admin)

**Criteres d'acceptation :**

- [ ] Creer la structure `features/admin/` (data/models, data/repositories, presentation/bloc, presentation/pages, presentation/widgets)
- [ ] Route `/admin` avec guard : redirect vers `/feed` si non-admin
- [ ] Routes enfants : `/admin/verifications`, `/admin/reports`, `/admin/stats`
- [ ] Dashboard hub avec 3 cards navigables : Verifications (badge count), Signalements (badge count), Statistiques
- [ ] Lien "Administration" visible dans settings_page.dart UNIQUEMENT si `authState.isAdmin`
- [ ] AdminBloc charge les counts au demarrage (pendingRecruiters, pendingReports)

---

### Story 14.2 : Models + AdminRepository (3 pts) 📦

**En tant que** developpeur,
**Je veux** des modeles et un repository admin,
**Afin que** les BLoCs puissent acceder aux donnees admin.

**Fichiers a creer :**
- `lib/features/admin/data/models/report_model.dart` — Modele Report
- `lib/features/admin/data/repositories/admin_repository.dart` — Repository admin

**Criteres d'acceptation :**

- [ ] `ReportModel` : id, reporterId, reportedUserId, reportedVideoId, reportedMessageId, reason, description, status, actionTaken, reviewedBy, reviewedAt, adminNotes, createdAt
- [ ] `ReportModel.fromJson()` et `toJson()`
- [ ] `AdminRepository` avec les methodes :
  - `getPendingRecruiters()` → liste RecruiterProfileModel avec verification_status='pending'
  - `getRecruiterDetail(userId)` → profil complet avec SIRET
  - `approveRecruiter(userId)` → UPDATE verification_status='verified', verified_at, verified_by
  - `rejectRecruiter(userId, reason)` → UPDATE verification_status='rejected', rejection_reason
  - `getPendingReports()` → liste ReportModel avec status='pending'
  - `dismissReport(reportId)` → UPDATE status='dismissed'
  - `actionReport(reportId, action, notes)` → UPDATE status='actioned', action_taken
  - `suspendUser(userId)` → UPDATE users.status='suspended'
  - `suspendVideo(videoId)` → UPDATE videos.status='suspended'
  - `getDashboardStats()` → Map avec counts (users, videos, messages, revenue)
- [ ] Enregistrer dans `injection_container.dart`

---

### Story 14.3 : Liste recruteurs en attente de verification (5 pts) ✅

**En tant qu'** admin,
**Je veux** voir la liste des recruteurs en attente,
**Afin de** les verifier avant qu'ils puissent publier.

**Fichier a creer :** `lib/features/admin/presentation/pages/verification_queue_page.dart`

**Criteres d'acceptation :**

- [ ] Page accessible depuis `/admin/verifications`
- [ ] Liste des recruteurs avec verification_status='pending'
- [ ] Chaque item affiche : nom entreprise, SIRET, secteur, date inscription
- [ ] Badge "En attente" orange
- [ ] Pull-to-refresh pour recharger la liste
- [ ] Etat vide : "Aucun recruteur en attente" avec icone
- [ ] Tap sur un item → navigation vers la page detail (Story 14.4)
- [ ] Count dans l'AppBar (ex: "Verifications (3)")

---

### Story 14.4 : Validation / rejet recruteur (5 pts) ✅❌

**En tant qu'** admin,
**Je veux** approuver ou rejeter un recruteur,
**Afin que** seules les vraies entreprises puissent publier.

**Fichier a creer :** `lib/features/admin/presentation/pages/recruiter_verification_page.dart`

**Criteres d'acceptation :**

- [ ] Page detail avec toutes les infos du recruteur :
  - Nom entreprise, SIRET (14 chiffres), secteur, description
  - Date d'inscription, email
  - Logo (si uploade)
- [ ] Bouton "Approuver" (vert) → confirmation dialog → appelle `approveRecruiter()`
  - Met verification_status='verified', verified_at=now, verified_by=adminId
  - Affiche SnackBar "Recruteur approuve"
  - Retour a la liste (qui se rafraichit)
- [ ] Bouton "Rejeter" (rouge) → dialog avec TextFormField pour le motif (obligatoire)
  - Met verification_status='rejected', rejection_reason
  - Affiche SnackBar "Recruteur rejete"
  - Retour a la liste
- [ ] Loading state pendant l'action

---

### Story 14.5 : Liste + moderation signalements (5 pts) 🚨

**En tant qu'** admin,
**Je veux** voir et traiter les signalements,
**Afin que** la plateforme reste sure.

**Fichier a creer :** `lib/features/admin/presentation/pages/reports_page.dart`

**Criteres d'acceptation :**

- [ ] Page accessible depuis `/admin/reports`
- [ ] Liste des signalements avec status='pending'
- [ ] Chaque item affiche : motif (reason), date, type (user/video/message), signale par
- [ ] Tap sur un item → bottom sheet avec details + actions :
  - "Ignorer" → status='dismissed'
  - "Supprimer le contenu" → status='actioned' + suspend video/message
  - "Suspendre l'utilisateur" → status='actioned' + suspend user
- [ ] Dialog de confirmation avant chaque action
- [ ] Champ "Notes admin" optionnel
- [ ] Etat vide : "Aucun signalement en attente"
- [ ] Count dans l'AppBar (ex: "Signalements (2)")

---

### Story 14.6 : Dashboard statistiques admin (5 pts) 📊

**En tant qu'** admin,
**Je veux** voir les metriques cles de la plateforme,
**Afin de** suivre la sante du service.

**Fichier a creer :** `lib/features/admin/presentation/pages/admin_stats_page.dart`

**Criteres d'acceptation :**

- [ ] Page accessible depuis `/admin/stats`
- [ ] Cards de metriques :
  - Nombre total d'utilisateurs (avec breakdown chercheurs/recruteurs)
  - Nombre de recruteurs verifies / en attente / rejetes
  - Nombre de videos actives (presentations / offres / affiches)
  - Nombre de messages echanges
  - Nombre d'abonnes premium (chercheurs / recruteurs)
  - Revenus (count subscriptions actives × prix)
- [ ] Chaque card avec icone et couleur distinctive
- [ ] Derniere mise a jour affichee en haut (timestamp)
- [ ] Pull-to-refresh
- [ ] Pas de graphiques MVP — juste des compteurs clairs

**Requetes SQL (via AdminRepository) :**
```sql
-- Users
SELECT role, COUNT(*) FROM users GROUP BY role
-- Recruiter verification
SELECT verification_status, COUNT(*) FROM recruiter_profiles GROUP BY verification_status
-- Videos
SELECT type, COUNT(*) FROM videos WHERE status='active' GROUP BY type
-- Messages
SELECT COUNT(*) FROM messages
-- Premium
SELECT COUNT(*) FROM users WHERE is_premium = true
-- Subscriptions active
SELECT plan_type, COUNT(*) FROM subscriptions WHERE status='active' GROUP BY plan_type
```

---

### Story 14.7 : Verification SIRET via API Sirene (5 pts) 🔍

**En tant que** recruteur,
**Je veux** que mon SIRET soit verifie automatiquement a l'inscription,
**Afin que** seules les vraies entreprises puissent s'inscrire.

**API utilisee :** `https://recherche-entreprises.api.gouv.fr/search?q={siret}` (gratuite, sans cle)

**Fichiers a creer :**
- `lib/core/services/sirene_service.dart` — Service d'appel API Sirene

**Fichiers a modifier :**
- `lib/features/auth/presentation/pages/register_page.dart` — Ajouter champ SIRET (si role=recruiter), validation temps reel
- `lib/features/auth/presentation/bloc/auth_bloc.dart` — Passer le SIRET au signup metadata

**Criteres d'acceptation :**

- [ ] Champ SIRET visible uniquement si role = recruteur
- [ ] Validation format : exactement 14 chiffres
- [ ] Appel API Sirene au submit (avant creation compte)
  - SIRET valide + entreprise active → continue inscription, auto-remplit nom entreprise en metadata
  - SIRET invalide ou entreprise fermee → message "Ce SIRET n'est pas valide, verifiez et reessayez" → bloque
  - Erreur reseau API → message "Verification impossible, reessayez plus tard" → bloque
- [ ] SIRET stocke dans recruiter_profiles.siret apres creation du compte
- [ ] Nom entreprise recupere depuis l'API stocke dans recruiter_profiles.company_name
- [ ] Loading indicator pendant la verification
- [ ] debounce ou verification uniquement au submit (pas a chaque frappe)

---

### Story 14.8 : Upload document justificatif recruteur (3 pts) 📄

**En tant que** recruteur inscrit,
**Je veux** uploader un document justificatif (Kbis, carte pro),
**Afin que** mon compte puisse etre verifie par un admin.

**Fichiers a modifier :**
- `lib/features/profile/presentation/pages/edit_recruiter_profile_page.dart` — Ajouter section upload document
- `lib/features/profile/data/repositories/profile_repository.dart` — Methode `uploadDocument()`

**Criteres d'acceptation :**

- [ ] Section "Document de verification" dans la page edit profil recruteur
- [ ] Si pas de document : message "Uploadez un justificatif (Kbis, carte pro) pour faire verifier votre compte"
- [ ] Bouton "Choisir un fichier" → ouvre file picker (image JPG/PNG ou PDF)
- [ ] Preview du document apres selection
- [ ] Upload vers Supabase Storage (bucket prive `verification-docs`)
- [ ] Met a jour recruiter_profiles : document_url, document_type, document_uploaded_at
- [ ] Si document deja uploade : affiche "Document envoye le XX/XX/XXXX — En attente de verification"
- [ ] Si recruteur deja verifie : affiche "Compte verifie" avec badge vert
- [ ] Si rejete : affiche motif + possibilite de re-uploader

---

### Resume Sprint 14

| Story | Titre | Points | Dependances |
|-------|-------|--------|-------------|
| 14.1 | Structure admin + route guard + dashboard | 3 | Aucune | ✅ DONE |
| 14.2 | Models + AdminRepository | 3 | Aucune | ✅ DONE |
| 14.3 | Liste recruteurs en attente | 5 | 14.1, 14.2 | ✅ DONE |
| 14.4 | Validation / rejet recruteur | 5 | 14.3 | ✅ DONE |
| 14.5 | Liste + moderation signalements | 5 | 14.1, 14.2 | ✅ DONE |
| 14.6 | Dashboard statistiques | 5 | 14.1, 14.2 | ✅ DONE |
| 14.7 | Verification SIRET API Sirene | 5 | Aucune | ✅ DONE |
| 14.8 | Upload document justificatif | 3 | Aucune | ✅ DONE |
| **Total** | | **34** | |

**Ordre d'implementation recommande :**
```
14.1 (Structure + routes) ──DONE──┐
14.2 (Models + repo)              ┤─→ 14.3 (Liste recruteurs) ─→ 14.4 (Validation/rejet)
                                  ├─→ 14.5 (Signalements)
                                  └─→ 14.6 (Dashboard stats)
14.7 (SIRET API Sirene) ──────────── independante
14.8 (Upload document) ───────────── independante
```

**Criteres de Done Sprint 14 :**
- [ ] Admin peut acceder a un espace dedie (route protegee)
- [ ] Admin peut lister et verifier/rejeter les recruteurs pending
- [ ] Admin peut lister et traiter les signalements
- [ ] Admin peut voir les metriques cles de la plateforme
- [ ] SIRET verifie automatiquement a l'inscription recruteur via API Sirene
- [ ] Recruteur peut uploader un document justificatif
- [ ] Toutes les actions loguees (debugPrint)
- [ ] flutter analyze : 0 erreur

**Pre-requis :** Creer un compte admin dans Supabase (UPDATE users SET role='admin' WHERE email='gzzadri@gmail.com')

---

### Rappel : Stories reportees

| Story | Titre | Points | Raison |
|-------|-------|--------|--------|
| 13.1 | Camera in-app | 8 | Emulateur Android requis |

---

## Notes

- Sprint 0.1 (Setup Flutter) deja complete
- Sprints 1-16 complets (sauf camera 13.1)
- Priorite: fonctionnalites core avant premium
- Tests en continu : 25/25 tests
- Camera : tester UNIQUEMENT sur emulateur Android (pas Edge/web)
- Admin role deploye en production (gzzadri@gmail.com)
- VIEW `public.users` deploye (join auth.users + user_roles)
- Edge Functions deployees : send-push, delete-account, export-user-data, stripe-webhook, create-payment-intent, create-subscription-intent

---

*Document genere par BMad Master le 2026-02-02*
*Sprint 12 TERMINE le 2026-02-23 (7/7 stories, 26/26 pts)*
*Sprint 13 TERMINE le 2026-02-23 (5/6 stories, 15/23 pts — camera reportee)*
*Sprint 14 TERMINE le 2026-02-24 (8/8 stories, 34/34 pts)*
*Sprint 15 TERMINE le 2026-02-25 (6/6 stories, 25/25 pts)*
*Sprint 16 TERMINE le 2026-02-25 (6/6 stories, 17/17 pts)*

---

## Sprint 15 : RGPD + Signalement + Polish 🛡️

**Objectif :** Conformite RGPD (suppression compte, export donnees), systeme de signalement utilisateur, lien admin manquant, et polish pre-beta.
**Date de planification :** 2026-02-24
**Velocite ciblee :** 25 points

### Etat du code avant Sprint 15

| Element | Statut | Detail |
|---------|--------|--------|
| Table `reports` | OK en BDD | 13 colonnes, reporter_id, reported_user/video/message_id |
| Admin moderation reports | OK (Sprint 14) | Liste + actions (ignorer/suspendre) |
| Creation report (UI user) | **MANQUANT** | Pas de bouton Signaler dans chat ni feed |
| Suppression compte | **MANQUANT** | Pas d'event AuthDeleteAccount, pas d'UI |
| Export donnees RGPD | **MANQUANT** | Pas d'Edge Function export-user-data |
| Lien Admin dans Settings | **MANQUANT** | Prevu 14.1 mais non implemente |
| Gestion abonnement | PARTIEL | Annulation inline sur page premium, pas d'historique |
| StatsRepository bug | CORRIGE | `users` → `user_roles` |

---

### Story 15.1 : RGPD — Suppression de compte (5 pts) 🗑️

**En tant qu'** utilisateur,
**Je veux** supprimer mon compte definitivement,
**Afin que** mes donnees personnelles soient effacees conformement au RGPD.

**Fichiers a creer :**
- `supabase/functions/delete-account/index.ts` — Edge Function soft delete

**Fichiers a modifier :**
- `lib/features/auth/presentation/bloc/auth_event.dart` — +`AuthDeleteAccountRequested`
- `lib/features/auth/presentation/bloc/auth_state.dart` — +`AuthAccountDeleted`
- `lib/features/auth/presentation/bloc/auth_bloc.dart` — +handler `_onDeleteAccountRequested`
- `lib/features/settings/presentation/pages/settings_page.dart` — Ajouter bouton "Supprimer mon compte"

**Criteres d'acceptation :**

- [ ] Bouton "Supprimer mon compte" en bas de la page Settings (rouge, sous Deconnexion)
- [ ] Tap → Dialog d'avertissement :
  - Titre : "Supprimer votre compte ?"
  - Corps : "Cette action est irreversible apres 30 jours. Toutes vos donnees (profil, videos, messages) seront supprimees. Vous avez 30 jours pour vous reconnecter et annuler."
  - Champ mot de passe (obligatoire, pour confirmer l'identite)
  - Boutons : "Annuler" / "Supprimer definitivement" (rouge)
- [ ] Verification du mot de passe via `supabase.auth.signInWithPassword()` avant suppression
- [ ] Si mot de passe incorrect → message "Mot de passe incorrect"
- [ ] Si correct → appelle Edge Function `delete-account`
- [ ] Edge Function `delete-account` :
  - Recoit `userId` (depuis le JWT)
  - Met `user_roles.status = 'deleted'`, `user_roles.updated_at = now()`
  - Met `videos.status = 'deleted'` pour toutes les videos de l'utilisateur
  - Ajoute `deleted_at = now()` dans les metadata de `auth.users`
  - NE supprime PAS physiquement — soft delete 30 jours
  - Retourne `{ success: true }`
- [ ] Apres suppression : logout automatique → retour page Welcome
- [ ] SnackBar "Votre compte sera supprime dans 30 jours"
- [ ] Un utilisateur soft-delete ne peut plus se connecter (checker au login)

**Contexte technique :**
- Edge Function pattern : identique a `send-push/index.ts`
- Auth JWT : `const { data: { user } } = await supabaseClient.auth.getUser()`
- La suppression physique (apres 30j) sera geree par un cron Supabase (hors scope MVP)

---

### Story 15.2 : RGPD — Export des donnees personnelles (5 pts) 📦

**En tant qu'** utilisateur,
**Je veux** exporter toutes mes donnees personnelles en JSON,
**Afin d'** exercer mon droit a la portabilite (RGPD Art. 20).

**Fichiers a creer :**
- `supabase/functions/export-user-data/index.ts` — Edge Function export JSON

**Fichiers a modifier :**
- `lib/features/settings/presentation/pages/settings_page.dart` — Ajouter "Exporter mes donnees"

**Criteres d'acceptation :**

- [ ] Bouton "Exporter mes donnees" dans la section Compte des Settings (sous Premium)
- [ ] Tap → Dialog de confirmation : "Vos donnees seront preparees et telechargees au format JSON."
- [ ] Loading indicator pendant la generation
- [ ] Edge Function `export-user-data` :
  - Authentification JWT requise
  - Collecte toutes les donnees de l'utilisateur :
    - `user_roles` : role, is_premium, status, created_at
    - `seeker_profiles` OU `recruiter_profiles` : tous les champs
    - `videos` : titre, categorie, status, created_at (pas le fichier video)
    - `conversations` : id, created_at (sans les messages de l'autre participant)
    - `messages` : contenu des messages ENVOYES par l'utilisateur uniquement
    - `subscriptions` : plan_type, status, created_at
  - Retourne un objet JSON structure :
    ```json
    {
      "export_date": "2026-02-24T12:00:00Z",
      "user": { ... },
      "profile": { ... },
      "videos": [ ... ],
      "conversations": [ ... ],
      "my_messages": [ ... ],
      "subscriptions": [ ... ]
    }
    ```
- [ ] Le JSON est affiche dans un dialog scrollable avec bouton "Copier" (MVP web)
- [ ] Ou telecharge en fichier `etoile-export-{date}.json` (si possible sur la plateforme)
- [ ] Pas d'envoi par email MVP — telechargement direct

**Contexte technique :**
- Edge Function : utiliser `supabaseClient.from(...).select().eq('user_id', userId)`
- Pour les messages : filtrer `sender_id = userId` (ne pas exporter les messages recus)
- Format JSON brut, pas de PDF MVP

---

### Story 15.3 : Signaler depuis conversation et feed (5 pts) 🚨

**En tant qu'** utilisateur,
**Je veux** signaler un contenu ou un utilisateur inapproprie,
**Afin que** les admins puissent moderer la plateforme.

**Fichiers a creer :**
- `lib/features/report/presentation/widgets/report_dialog.dart` — Widget reutilisable
- `lib/features/report/data/repositories/report_repository.dart` — Repository creation report

**Fichiers a modifier :**
- `lib/features/messages/presentation/pages/chat_page.dart` — Ajouter menu "..." → "Signaler"
- `lib/features/feed/presentation/pages/feed_page.dart` — Ajouter icone Signaler sur les videos
- `lib/di/injection_container.dart` — Enregistrer ReportRepository

**Criteres d'acceptation :**

- [ ] **Widget `ReportDialog`** reutilisable (bottom sheet) :
  - Titre : "Signaler"
  - Liste de motifs (radio) :
    - "Contenu inapproprie"
    - "Spam ou publicite"
    - "Fausse identite"
    - "Harcelement"
    - "Autre"
  - Champ description optionnel (TextArea, max 500 caracteres)
  - Bouton "Envoyer le signalement"
  - Loading state pendant l'envoi
  - SnackBar succes : "Merci pour votre signalement. Nous allons examiner ce contenu."

- [ ] **Depuis le chat** (`chat_page.dart`) :
  - Ajouter un `PopupMenuButton` dans l'AppBar (icone "...")
  - Option "Signaler cette conversation"
  - Ouvre `ReportDialog` avec `reported_user_id` = l'autre participant
  - Le `reported_message_id` = dernier message de l'autre (ou null)

- [ ] **Depuis le feed** (`feed_page.dart`) :
  - Ajouter une icone drapeau (🚩) ou "..." sur chaque video card
  - Option "Signaler"
  - Ouvre `ReportDialog` avec `reported_video_id` = la video courante
  - `reported_user_id` = proprietaire de la video

- [ ] **`ReportRepository`** :
  - Methode `createReport({reason, description, reportedUserId, reportedVideoId, reportedMessageId})`
  - INSERT dans la table `reports` avec `reporter_id = currentUserId`, `status = 'pending'`
  - debugPrint log

- [ ] Un utilisateur ne peut pas se signaler lui-meme (guard cote client)
- [ ] Un utilisateur ne peut pas signaler 2 fois le meme contenu (check doublon optional)

**Contexte technique :**
- Table `reports` existe deja avec toutes les colonnes necessaires
- RLS : verifier que les users authentifies peuvent INSERT dans reports
- L'admin modere deja les reports (Sprint 14.5) — cette story complete le flow user → admin

---

### Story 15.4 : Lien Administration dans Settings (2 pts) 🔗

**En tant qu'** admin,
**Je veux** acceder au dashboard admin depuis les parametres,
**Afin de** ne pas avoir a taper l'URL manuellement.

**Fichiers a modifier :**
- `lib/features/settings/presentation/pages/settings_page.dart`

**Criteres d'acceptation :**

- [ ] Si l'utilisateur connecte a `role == 'admin'` (via `authState.isAdmin`) :
  - Afficher une section "Administration" en haut des Settings (avant "Compte")
  - Un ListTile avec icone `Icons.admin_panel_settings`, titre "Administration"
  - Tap → `context.push('/admin')`
  - Badge couleur differente (violet ou bleu) pour distinguer visuellement
- [ ] Si l'utilisateur n'est PAS admin : la section n'apparait pas du tout
- [ ] Le getter `isAdmin` existe deja dans `AuthAuthenticated` (auth_state.dart)

**Contexte technique :**
- Simple modification de `settings_page.dart` (10-15 lignes)
- Etait prevu dans Story 14.1 mais non implemente
- Les routes admin existent deja (`/admin`, `/admin/verifications`, etc.)

---

### Story 15.5 : Gestion abonnement — historique et annulation (5 pts) 💳

**En tant qu'** utilisateur premium,
**Je veux** voir mon historique de paiements et gerer mon abonnement,
**Afin de** suivre mes depenses et annuler si besoin.

**Fichiers a creer :**
- `lib/features/payment/presentation/pages/subscription_management_page.dart`

**Fichiers a modifier :**
- `lib/features/payment/presentation/bloc/payment_event.dart` — +`PaymentLoadHistory`
- `lib/features/payment/presentation/bloc/payment_state.dart` — +`PaymentHistoryLoaded`
- `lib/features/payment/presentation/bloc/payment_bloc.dart` — +handler historique
- `lib/features/payment/data/repositories/payment_repository.dart` — +`getPaymentHistory()`
- `lib/core/router/app_router.dart` — Route `/premium/manage`
- `lib/features/settings/presentation/pages/settings_page.dart` — Lien "Mon abonnement" (si premium)

**Criteres d'acceptation :**

- [ ] Route `/premium/manage` accessible depuis Settings (visible uniquement si `is_premium == true`)
- [ ] Section "Mon abonnement" :
  - Type : Premium Chercheur ou Premium Recruteur
  - Statut : Actif / Annule (expire le...)
  - Date de renouvellement : JJ/MM/AAAA
  - Bouton "Annuler l'abonnement" (si actif) → dialog confirmation → appelle Stripe cancel
  - Si deja annule : texte "Votre abonnement reste actif jusqu'au JJ/MM/AAAA"
- [ ] Section "Historique des paiements" :
  - Liste des transactions depuis la table `purchases` + `subscriptions`
  - Chaque ligne : date, description (Premium/Credit video/Credit affiche), montant, statut
  - Trie par date decroissante
  - Etat vide : "Aucun paiement"
- [ ] Si recruteur : section "Mes credits" affichant `video_credits` et `poster_credits` restants
- [ ] Pull-to-refresh

**Contexte technique :**
- Tables : `subscriptions` (plan_type, status, current_period_end), `purchases` (amount, description, created_at)
- L'annulation Stripe existe deja dans `StripeService.cancelSubscription()` et `PaymentBloc`
- Cette page centralise ce qui etait inline sur les pages premium

---

### Story 15.6 : Tests unitaires critiques (3 pts) 🧪

**En tant que** developpeur,
**Je veux** des tests unitaires sur les repositories et BLoCs critiques,
**Afin de** garantir la stabilite avant la beta.

**Fichiers a creer :**
- `test/features/auth/presentation/bloc/auth_bloc_test.dart`
- `test/features/report/data/repositories/report_repository_test.dart`
- `test/features/profile/data/repositories/profile_repository_test.dart`

**Criteres d'acceptation :**

- [ ] **AuthBloc tests** (minimum 8 tests) :
  - Login succes → AuthAuthenticated
  - Login echec (mauvais MDP) → AuthError
  - Register succes → AuthAuthenticated
  - Register echec (email existe) → AuthError
  - Logout → AuthUnauthenticated
  - Delete account → AuthAccountDeleted (apres story 15.1)
  - Check auth avec session → AuthAuthenticated
  - Check auth sans session → AuthUnauthenticated

- [ ] **ReportRepository tests** (minimum 3 tests) :
  - createReport succes → retourne void, pas d'exception
  - createReport sans raison → throw exception
  - createReport auto-signalement → bloque

- [ ] **ProfileRepository tests** (minimum 5 tests) :
  - getSeekerProfile retourne profil
  - getSeekerProfile retourne null si pas de profil
  - updateSeekerProfile retourne profil mis a jour
  - getRecruiterProfile retourne profil
  - uploadLogo retourne URL

- [ ] Utiliser `mocktail` pour mocker `SupabaseClient`
- [ ] Utiliser `bloc_test` pour tester les BLoCs
- [ ] `flutter test` passe sans erreur

**Contexte technique :**
- Packages deja dans pubspec : `flutter_test`, `mocktail`, `bloc_test`
- Pattern de test : `when(() => mock.method()).thenReturn(value)`
- Le dossier `test/` existe peut-etre deja — verifier

---

### Resume Sprint 15

| Story | Titre | Points | Dependances |
|-------|-------|--------|-------------|
| 15.1 | RGPD : Suppression de compte | 5 | Aucune |
| 15.2 | RGPD : Export donnees personnelles | 5 | Aucune |
| 15.3 | Signaler depuis conversation + feed | 5 | Aucune |
| 15.4 | Lien Administration dans Settings | 2 | Aucune |
| 15.5 | Gestion abonnement (historique + annulation) | 5 | Aucune |
| 15.6 | Tests unitaires critiques | 3 | 15.1 (pour tester delete) |
| **Total** | | **25** | |

**Ordre d'implementation recommande :**
```
15.4 (Lien admin — rapide) ───┐
15.1 (Suppression compte)     ├─→ 15.3 (Signaler)
15.2 (Export RGPD)             ├─→ 15.5 (Gestion abo)
                               └─→ 15.6 (Tests) → DONE
```

15.4 est rapide (2 pts, 10 min). 15.1 et 15.2 sont RGPD prioritaires et independantes. 15.3 complete le flow signalement. 15.5 complete les paiements. 15.6 en dernier car depend de 15.1.

**Criteres de Done Sprint 15 :**
- [ ] Un utilisateur peut supprimer son compte (soft delete 30j)
- [ ] Un utilisateur peut exporter ses donnees en JSON
- [ ] Un utilisateur peut signaler un contenu/utilisateur depuis chat et feed
- [ ] Un admin accede au dashboard depuis Settings
- [ ] Un premium peut voir son historique et gerer son abonnement
- [ ] Tests unitaires critiques passent (AuthBloc, ReportRepo, ProfileRepo)
- [ ] flutter analyze : 0 erreur

**Pre-requis :**
- RLS sur `reports` : permettre INSERT pour les utilisateurs authentifies
- Deployer Edge Functions `delete-account` et `export-user-data` sur Supabase

---

### Stories reportees

| Story | Titre | Points | Raison |
|-------|-------|--------|--------|
| 13.1 | Camera in-app | 8 | Emulateur Android requis |

*Sprint 15 planifie par Bob (SM) le 2026-02-24*
*Sprint 15 TERMINE le 2026-02-25 (6/6 stories, 25/25 pts)*

---

## Sprint 16 : Polish + Beta ✨ ✅ COMPLETE

**Objectif :** Corriger les deprecations, completer les features manquantes (bloquer utilisateur), splash screen, tests, navigation guards et UX polish.
**Date :** 2026-02-25
**Velocite realisee :** 17/17 points (6/6 stories)

### Resume Sprint 16

| Story | Titre | Points | Statut |
|-------|-------|--------|--------|
| 16.1 | Fix deprecations (withOpacity, value) | 2 | ✅ DONE |
| 16.2 | Bloquer utilisateur (FR-5.3) | 5 | ✅ DONE |
| 16.3 | Splash screen anime + App icon | 3 | ✅ DONE |
| 16.4 | Fix widget_test + tests supplementaires | 3 | ✅ DONE |
| 16.5 | Navigation guards + UX polish | 3 | ✅ DONE |
| 16.6 | Update docs (session + sprint plan) | 1 | ✅ DONE |
| **Total** | | **17** | **17/17 pts** |

### Details Story 16.2 — Bloquer utilisateur

**Fichier cree :** `lib/features/messages/data/repositories/block_repository.dart`
- `blockUser()`, `unblockUser()`, `isBlocked()`, `getBlockedUserIds()`

**Fichiers modifies :**
- `chat_page.dart` — Option "Bloquer" (rouge) dans PopupMenu + dialog confirmation + retour conversations
- `conversations_page.dart` — Filtre les conversations avec utilisateurs bloques
- `feed_bloc.dart` — Filtre les videos d'utilisateurs bloques du feed
- `injection_container.dart` — +BlockRepository + FeedBloc(blockRepository)

### Details Story 16.3 — Splash screen + App icon

**Fichier cree :** `lib/shared/widgets/splash_screen.dart`
- Gradient background sombre, icone etoile dans cercle gradient
- ShaderMask titre "ETOILE" avec gradient jaune-orange
- Tagline "Recrutement par video"
- Animations fade-in + scale avec stagger timing

**Fichier modifie :** `lib/app.dart` — Remplace le loading inline par SplashScreen

**App icon :** `flutter_launcher_icons` v0.14.3
- Source : `assets/icon/app_icon.png` (etoile doree 3D sur fond #333333)
- Mascotte : `assets/images/mascotte.png` (personnage etoile avec telephone)
- Android : mipmap-* (5 tailles) + drawable-* adaptive icons (fond #333333)
- iOS : AppIcon.appiconset (alpha removed pour App Store)
- Web : favicon.png + Icon-192/512 + maskable variants
- Windows : icone native generee
- Config dans pubspec.yaml (`flutter_launcher_icons` section + `remove_alpha_ios: true`)

### Details Story 16.5 — Navigation guards

**Fichier modifie :** `lib/core/router/app_router.dart`
- Guard /record : redirect vers /publish si recruteur
- Guard /publish : redirect vers /record si seeker
- Splash route utilise SplashScreen widget
- Welcome page polie : logo etoile + ShaderMask + AppColors

### Bilan tests

- **25/25 tests pass** (+6 tests ce sprint)
- widget_test.dart : corrige (teste SplashScreen)
- block_repository_test.dart : 5 nouveaux tests (guards, null safety)
- flutter analyze : 0 erreurs, 0 warnings (sauf 1 pre-existant)

---

### Stories reportees (toutes sessions)

| Story | Titre | Points | Raison |
|-------|-------|--------|--------|
| 13.1 | Camera in-app | 8 | Emulateur Android requis |

*Sprint 16 complete le 2026-02-25 (6/6 stories, 17/17 pts)*
*App quasi-complete pour beta (manque uniquement camera 13.1)*
