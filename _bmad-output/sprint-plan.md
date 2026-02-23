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

## Notes

- Sprint 0.1 (Setup Flutter) deja complete
- Sprints 1-12 complets (voir sections ci-dessus)
- Priorite: fonctionnalites core avant premium
- Tests en continu, pas seulement Sprint 10
- Revue de sprint hebdomadaire recommandee
- Camera : tester UNIQUEMENT sur emulateur Android (pas Edge/web)

---

*Document genere par BMad Master le 2026-02-02*
*Sprint 12 planifie par Bob (SM) le 2026-02-22*
*Sprint 12 TERMINE le 2026-02-23 (7/7 stories, 26/26 pts)*
*Sprint 13 planifie par Bob (SM) le 2026-02-23*
*Valide par: Utilisateur*
