# Story 0.4: Configuration Stripe

---
status: complete
epic: 0 - Fondation Technique
sprint: 1
points: 3
created: 2026-02-02
completed: 2026-02-02
author: John (PM)
developer: Amelia (Dev)
---

## Story

**As a** developpeur,
**I want** Stripe configure en mode test,
**So that** les paiements puissent etre testes.

---

## Acceptance Criteria

### AC-1: Variables d'environnement Stripe
**Given** un compte Stripe existe
**When** je configure les cles API
**Then** les cles test sont dans .env
**And** StripeService charge les cles au demarrage

### AC-2: Produits et Prix
**Given** Stripe est configure
**When** je definis les produits
**Then** les produits suivants sont documentes:
- seeker_premium (~5€/mois)
- recruiter_premium (~500€/mois)
- video_credit (~100€)
- poster_credit (~50€)

### AC-3: StripeService Flutter
**Given** les cles sont configurees
**When** je veux utiliser Stripe
**Then** un StripeService est disponible
**And** il initialise flutter_stripe
**And** il prepare les methodes de paiement

### AC-4: Webhook Edge Function
**Given** Supabase est configure
**When** je recois un evenement Stripe
**Then** une Edge Function traite les webhooks
**And** elle met a jour les abonnements en DB

---

## Tasks/Subtasks

### Task 1: Configuration Flutter Stripe
- [x] 1.1 Verifier flutter_stripe dans pubspec.yaml
- [x] 1.2 Ajouter STRIPE_PUBLISHABLE_KEY dans .env
- [x] 1.3 Mettre a jour AppConfig pour Stripe

### Task 2: Creer StripeService
- [x] 2.1 Creer lib/core/services/stripe_service.dart
- [x] 2.2 Initialiser Stripe au demarrage
- [x] 2.3 Methodes pour Payment Sheet
- [x] 2.4 Enregistrer dans injection_container.dart

### Task 3: Edge Function Webhook
- [x] 3.1 Creer supabase/functions/stripe-webhook/
- [x] 3.2 Handler pour invoice.paid
- [x] 3.3 Handler pour customer.subscription.updated
- [x] 3.4 Handler pour customer.subscription.deleted

### Task 4: Documentation
- [x] 4.1 Documenter les produits Stripe a creer
- [x] 4.2 Documenter le setup webhook

---

## Dev Notes

### Produits Stripe (a creer dans Dashboard)

| Product ID | Nom | Prix | Type |
|------------|-----|------|------|
| seeker_premium | Premium Chercheur | 5€/mois | Subscription |
| recruiter_premium | Premium Recruteur | 500€/mois | Subscription |
| video_credit | Credit Video | 100€ | One-time |
| poster_credit | Credit Affiche | 50€ | One-time |

### Webhooks a gerer
- invoice.paid - Paiement reussi
- invoice.payment_failed - Echec paiement
- customer.subscription.updated - Changement abo
- customer.subscription.deleted - Annulation

---

## Dev Agent Record

### Implementation Plan
1. StripeService Flutter avec Payment Sheet
2. Edge Functions pour payment intents
3. Webhook handler pour synchronisation DB
4. Documentation complete

### Debug Log
- Aucun probleme rencontre

### Completion Notes
Implementation complete de la configuration Stripe:

**StripeService Flutter:**
- Initialisation Stripe SDK
- presentSubscriptionPaymentSheet() pour abonnements
- presentOneTimePaymentSheet() pour achats
- cancelSubscription() pour annulation
- getCustomerPortalUrl() pour gestion

**Edge Functions:**
- stripe-webhook: Traite tous les evenements Stripe
- create-payment-intent: Achats unitaires
- create-subscription-intent: Abonnements

**Webhooks:**
- invoice.paid -> active subscription + update user.is_premium
- invoice.payment_failed -> past_due status
- customer.subscription.updated -> sync status
- customer.subscription.deleted -> expire + remove premium
- checkout.session.completed -> credit purchases

---

## File List

### Fichiers Crees
- `flutter_application_1/lib/core/services/stripe_service.dart` (NEW)
- `supabase/functions/stripe-webhook/index.ts` (NEW)
- `supabase/functions/create-payment-intent/index.ts` (NEW)
- `supabase/functions/create-subscription-intent/index.ts` (NEW)

### Fichiers Modifies
- `flutter_application_1/lib/di/injection_container.dart` (+StripeService)
- `flutter_application_1/lib/main.dart` (+Stripe init)
- `supabase/README.md` (+Edge Functions docs)

---

## Change Log
| Date | Changement | Auteur |
|------|------------|--------|
| 2026-02-02 | Creation de la story | John (PM) |
| 2026-02-02 | Implementation complete | Amelia (Dev) |

---

## Status
complete
