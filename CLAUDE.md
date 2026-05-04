# CLAUDE.md — Étoile

Dernière mise à jour : 2026-05-05

## Présentation du projet

Étoile est une plateforme de recrutement par vidéo courte (40 secondes) pour l'alternance en Île-de-France. Elle se compose de DEUX produits distincts partageant le même backend Supabase.

## Architecture deux produits

| Produit | Public | Stack | Statut |
|---------|--------|-------|--------|
| App mobile | Chercheurs d'alternance | Flutter 3.x (iOS + Android) | En cours |
| SaaS web | Recruteurs vérifiés (SIRET) | Next.js 16 + Tailwind + Shadcn/ui | En cours |
| Backend | Partagé | Supabase (Auth + PostgreSQL + Realtime + Edge Functions) | Prod |
| Vidéos | Partagé | Cloudflare R2 + Worker | Prod |
| Paiements | SaaS uniquement | Stripe direct (web) — PAS d'IAP | À configurer |

## Chartes graphiques

### SaaS Web (Next.js) — Style Stripe/Notion
- Police : Sora (Google Fonts)
- Accent : #635BFF (violet sobre)
- Fond : #FFFFFF / #F9FAFB
- Texte : #0A0A0B / #6B7280
- Succès : #10B981 | Warning : #F59E0B | Danger : #EF4444
- Style : minimal, professionnel, desktop-first, sans dégradés criards

### App Mobile (Flutter) — Violet Moderne
- Police : Sora (Google Fonts)
- Accent : #635BFF (violet sobre, harmonisé avec le SaaS)
- Texte : #0A0A0B / #6B7280 / #9CA3AF
- Fond : #FFFFFF / #F9FAFB / #F3F4F6
- Sémantique : Success #10B981, Warning #F59E0B, Danger #EF4444
- Style : moderne, épuré, mobile-first, adapté chercheurs 18-25 ans

## Règles absolues

- Les chercheurs sont UNIQUEMENT sur l'app mobile Flutter
- Les recruteurs sont UNIQUEMENT sur le SaaS web Next.js
- AUCUN IAP (In-App Purchase) — les paiements se font via Stripe sur le web
- Le backend Supabase est PARTAGÉ entre les deux produits (même projet, même Auth)
- Chaque chercheur a un @username unique (VARCHAR UNIQUE en base)
- Score de matching : secteur (30%) + ville IdF (25%) + niveau (25%) + spécialité (20%)

## Structure des fichiers de référence

| Fichier | Contenu | Statut |
|---------|---------|--------|
| `_bmad-output/prd-etoile-draft.md` | Product Requirements Document complet | ✅ À jour (post-pivot) |
| `_bmad-output/architecture.md` | Architecture technique détaillée | ✅ À jour |
| `_bmad-output/SESSION-RESUME.md` | Résumé exécutif du projet + état courant | ✅ À jour |
| `_bmad-output/epics.md` | Liste des epics et FRs | ✅ À jour |

## Stack technique complète

### App Mobile (Flutter)
- Flutter 3.x, Dart
- State management : BLoC (flutter_bloc)
- Auth : Supabase Auth (email + OTP 6 chiffres)
- DB : Supabase PostgreSQL via supabase_flutter
- Vidéo : camera + upload Cloudflare R2
- Notifications : FCM (Firebase Cloud Messaging)
- Navigation : go_router
- Design System : AppColors + AppTextStyles + AppWidgets (Sora)

### SaaS Web (Next.js)
- Next.js 16 (App Router), TypeScript
- Style : Tailwind CSS + Shadcn/ui
- Auth : Supabase Auth SSR (même instance que Flutter)
- DB : Supabase (mêmes tables)
- Paiements : Stripe Checkout + Customer Portal
- Déploiement : Vercel
- Domaine : app.etoile-recrutement.fr

### Backend partagé (Supabase)
- Auth : email + OTP
- PostgreSQL : tables partagées
- Realtime : messagerie synchronisée Flutter ↔ Next.js
- Edge Functions : score matching, suppression compte, alertes
- Storage : photos profil, documents vérification
- RLS (Row Level Security) : actif sur toutes les tables

## Tables DB principales

Tables existantes (à NE PAS modifier sans PRD) :
- user_roles, seeker_profiles, recruiter_profiles
- videos, offers, applications
- conversations, messages
- alerts, alert_configs
- match_scores, candidate_evaluations

Colonnes clés ajoutées post-pivot :
- `seeker_profiles.username` (VARCHAR UNIQUE)
- `seeker_profiles.skills` (TEXT[] DEFAULT '{}')
- `seeker_profiles.rhythm` (VARCHAR nullable)
- `videos.sector` (TEXT)
- `videos.keywords` (TEXT[] DEFAULT '{}')
- `recruiter_profiles.photo_url` (TEXT nullable)
- `user_roles.last_login_at` (TIMESTAMPTZ)

Tables ajoutées post-pivot :
- `candidate_evaluations` (rating, notes, recruiter_id, application_id)
- `match_scores` (scores pré-calculés, 5 critères)

## Commandes utiles

```bash
# Flutter
cd D:\gzzad\Documents\IDEES\Etoile\Etoile-mobile-app\flutter_application_1
flutter run -d edge              # Lancer l'app en dev (Edge, le plus rapide)
flutter analyze                  # Analyse statique
flutter test                     # Tests unitaires

# Next.js SaaS
cd D:\gzzad\Documents\IDEES\Etoile\Etoile-mobile-app\saas-etoile
npm run dev                      # Lancer en dev (port 3000)
npm run build                    # Build production
npx shadcn@latest add <component> --yes  # Ajouter composant Shadcn

# Supabase
npx --prefix supabase supabase db push --workdir "D:\gzzad\Documents\IDEES\Etoile\Etoile-mobile-app"
```

## Ce qui a été décidé (NE PAS remettre en question)

- Pas de version web pour les chercheurs (mobile only)
- Pas de multi-langue (France V1)
- Pas de salaire dans les profils/offres (négociation privée)
- Pas de likes/favoris (shortlist uniquement côté recruteur)
- Pas de messages vocaux ni appels in-app
- Enregistrement vidéo in-app uniquement (pas d'import externe)
- Charte graphique unifiée violet #635BFF entre mobile et SaaS

## État du projet (2026-05-05)

### Statut technique
- **Flutter** : `flutter analyze` → 0 erreurs ✅ | `flutter run` → OK sur téléphone (SM S721B) ✅
- **Next.js** : `npm run dev` → OK sur localhost:3000 ✅ | build production ✅
- **Supabase** : 30/30 migrations déployées ✅
- **Tests Flutter** : 85/85 passent ✅

### ⚠️ Migration disque C: → D: (2026-05-04) — EFFECTUÉE ET VALIDÉE
- Projet Flutter : `D:\gzzad\Documents\IDEES\Etoile\Etoile-mobile-app\flutter_application_1`
- Projet Next.js : `D:\gzzad\Documents\IDEES\Etoile\Etoile-mobile-app\saas-etoile`
- Flutter SDK + Android SDK + Pub Cache : restent sur `C:\Users\gzzad\` (NE PAS déplacer)

### Epics et sprints complétés
- **Sprint 31 DONE** : Ouverture France entière + 15 secteurs + GPS proximité
- **Sprint SaaS-1 DONE** : Init Next.js + Auth + Dashboard
- **Sprint SaaS-2 DONE** : Publication offres (Epic 11)
- **Epic 12 DONE** : Grille candidats (scoring, modal, filtres)
- **Epic 13 DONE** : Dashboard briefing (KPIs PostgreSQL)
- **Epic 14 DONE** : Scoring PostgreSQL (match_scores)
- **Epic 15 DONE** : Messagerie temps réel (Supabase Realtime)
- **Epic 10 Phase 2 DONE** : Photo profil (10.6) + Preview mobile (10.7) + Settings (10.8)

### Fonctionnalités Flutter récentes (mai 2026)
- Compétences chercheur (texte libre, tags, scoring 20%)
- Rythmes alternance — 11 rythmes officiels (`app_constants.dart`)
- Type contrat → Alternance uniquement (Stage/Pro supprimés)
- Filtres recherche globaux (6 filtres : secteur, spécialité, niveau, ville, rythme, proximité)
- Splash screen violet + Messagerie bulles violet/gris
- Page profil entreprise + Page détail offre (créées, non encore intégrées au router)

### Fonctionnalités SaaS récentes (mai 2026)
- Settings recruteur complet (7 sections, photo, document, SIRET)
- Évaluation candidat 3 états (intéressé/neutre/pas intéressé)
- Formulaire offre : boutons Annuler sur toutes les étapes
- Messagerie complète (ConversationList + MessageThread + Realtime)

### Score de matching (mis à jour)
secteur (30%) + ville (25%) + niveau (25%) + spécialité (20%) — ANCIENNE formule
secteur (25%) + ville (20%) + niveau (20%) + spécialité (15%) + compétences (20%) — NOUVELLE formule avec skills

### Fichiers non commités (présents dans le working tree, fonctionnels)
**Flutter :** `app_constants.dart`, `app_widgets.dart`, `features/company/`, `features/offer/`
**SaaS :** settings/, candidates/, messages/, offers/new, dashboard/, components/settings/, components/messages/

## Prochaines étapes

**Track 1 (mobile)** : Brancher `CompanyProfilePage` + `OfferDetailPage` au router Flutter
**Track 2 (SaaS)** : Epic 6 (Paiements Stripe) ou Epic 7 (Admin) ← **À DÉFINIR**
**Infra** : Soumission stores (App Store + Google Play), déploiement Vercel, config Stripe
