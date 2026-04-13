# Session BMAD - Etoile Mobile App

**Date de mise a jour** : 2026-04-13
**Statut** : Sprint 30 DONE + Camera 13.1 DONE (testee Android physique). App mobile = chercheurs only, prete pour store. SaaS web = recruteurs only, a construire. 73/73 tests, 0 issues analyze. 22/22 migrations deployees.

---

## PIVOT (2026-04-03) : Modele Deux Plateformes

### Ancien modele
- App mobile unique pour chercheurs ET recruteurs

### Nouveau modele
- **App mobile (Flutter)** = chercheurs d'alternance uniquement
- **SaaS web (Next.js + Tailwind + Shadcn/ui)** = recruteurs uniquement
- **Backend partage** = meme projet Supabase (Auth, DB, Realtime, Edge Functions, R2)
- **Paiements** : Stripe direct sur le web SaaS (plus besoin d'IAP Apple/Google)
- **Positionnement** : complement au CV, pre-selection par soft skills

### Decisions techniques SaaS
- Stack : Next.js + Tailwind + Shadcn/ui + Recharts
- Deploiement : Vercel + domaine custom (app.etoile-recrutement.fr)
- Backend : Supabase partage (zero infra supplementaire, cout ~10€/an)
- Nouvelles tables : ~5 (candidate_evaluations, candidate_tags, evaluation_tags, team_shares, match_scores)
- Nouvelle colonne : `seeker_profiles.username` (UNIQUE)
- Scoring : Edge Function secteur(30%) + ville(25%) + niveau(25%) + specialite(20%)

### PRD mis a jour
- `_bmad-output/prd-etoile-draft.md` — reecrit avec 17 Epics (7 mobile + 8 SaaS + admin + alertes)
- Source brainstorming : `saas-etoile/` (47 idees, 4 phases)

### Prochaines etapes
1. **App mobile** : ~~tester camera (Story 13.1)~~ DONE — preparation store listing (screenshots, description)
2. **SaaS web** : init projet Next.js, migrations DB (~5 tables), pages core, integration ← **EN COURS**

---

## Pour reprendre

```bash
# App mobile (Flutter)
cd C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app\flutter_application_1
flutter run -d edge

# SaaS web (Next.js) — a creer
cd C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app\saas-etoile
```

Puis tape `/bmad` et dis : **"reprend la ou on s'est arrete"**

---

## Ce qui a ete fait — Pivot PRD Deux Plateformes (2026-04-03)

### PRD reecrit
- Executive Summary : modele deux plateformes (app mobile chercheur + SaaS web recruteur)
- 17 Epics (vs 9 avant) : 7 Epics app mobile + 8 Epics SaaS + 1 admin + 1 alertes
- Suppression IAP Apple/Google (plus necessaire)
- Ajout : username chercheur (@pseudo), score de matching, grille candidats, modal decision
- Modele economique : chercheurs gratuits, recruteurs Stripe web (499€/mois)
- Timeline : 6-8 semaines en deux tracks paralleles

### Nouvelles Epics SaaS
- Epic 10 : Auth & Profil Recruteur
- Epic 11 : Publication Offres
- Epic 12 : Grille & Modal Candidats (grille miniatures, hover preview, actions rapides, raccourcis clavier)
- Epic 13 : Dashboard Recruteur (briefing, funnel, KPIs)
- Epic 14 : Scoring & Matching (Edge Function, recherche @username)
- Epic 15 : Messagerie Recruteur (sync Realtime avec app mobile)
- Epic 16 : Paiements Recruteur (Stripe direct web)
- Epic 17 : Administration

---

## Ce qui a ete fait — Sprint 30 : Nettoyage DB — Suppression tables et colonnes inutilisees (2026-04-13)

### Objectif
Apres le pivot deux plateformes, supprimer les tables, colonnes et fichiers devenus du code mort.

### Migration SQL `20260413200000_cleanup_unused.sql` — DONE (deployee)
- **4 tables DROP** : `purchases` (paiements IAP migres Stripe), `notification_log` (jamais requetee), `admin_secrets` (plus de page admin_auth), `push_tokens` (remplacee par `device_tokens`)
- **10 colonnes seeker_profiles DROP** : `phone`, `birth_date`, `postal_code`, `categories`, `contract_types`, `experience_level`, `availability`, `salary_expectation`, `bio`, `profile_complete`
- **6 colonnes recruiter_profiles DROP** : `cover_url`, `website`, `company_size`, `latitude`, `longitude`, `map_markers`
- **1 colonne videos DROP** : `codec`

### Code Dart nettoye — DONE
- **SeekerProfileModel** : 10 champs retires (props, fromJson, toJson, copyWith)
- **RecruiterProfileModel** : 6 champs + classe `MapMarker` + getter `hasMapMarkers` retires ; completionPercentage simplifie (locations only, plus mapMarkers)
- **FeedItem** : 5 champs retires (`categories`, `contractTypes`, `availability`, `experienceLevel`, `salaryExpectation`)
- **FeedFilters** : 6 champs retires (`categoryId`, `categoryName`, `contractType`, `availability`, `experienceLevel`, `salaryRange`) — ne garde que `region`, `sector`, `specialty`, `city`, `studyLevel`
- **FeedRepository** : `getCategories()` supprime, `_parseStringList()` supprime, filtres simplifies
- **FeedBloc** : plus d'appels `getCategories()`, `categories` retire de `FeedLoaded`
- **FeedState** : `categories` retire de `FeedLoaded` (constructeur, copyWith, props)
- **ProfileRepository** : `getCategories()` supprime
- **ProfileBloc/State** : `categories` retire de `SeekerProfileLoaded`
- **UI** : `coverUrl`/`website`/`companySize` retires des pages admin verification + profil public recruteur

### Fichiers orphelins supprimes — DONE
- `lib/features/feed/presentation/widgets/profile_bottom_sheet.dart`
- `lib/shared/widgets/location_map_widget.dart`
- `lib/shared/widgets/location_picker_widget.dart`

### Tests adaptes — DONE
- `feed_bloc_test.dart` : mock `getCategories` retire, `FeedLoaded` sans `categories`, filtre test `categoryId` → `sector`
- `profile_completion_test.dart` : aucun changement (champs supprimes deja optionnels)

### Resultats
- **73/73 tests pass**, 0 issues flutter analyze
- Migration deployee en production (22/22 total)

### Tables/colonnes CONSERVEES
- Table `categories` en DB (pas de DROP) — juste retrait des requetes Dart
- Table `subscriptions` — utilisee dans admin stats
- `recruiter_profiles.logo_url` — utilisee dans feed pour avatar recruteur
- `seeker_profiles.region` — pourrait servir plus tard

---

## Ce qui a ete fait — Sprint 29 : Username @pseudo chercheur (2026-04-13)

### Objectif
Ajouter un champ `@username` unique au profil chercheur pour identification sur le SaaS web recruteur.

### Migration SQL — DONE
- `20260413000000_seeker_username.sql` : colonne `username VARCHAR(10) UNIQUE` + index
- `20260413100000_seeker_username_max10.sql` : reduction VARCHAR(50) → VARCHAR(10)
- Deployees en production (21/21 migrations)

### Modele SeekerProfile — DONE
- `seeker_profile_model.dart` : +propriete `username` (fromJson/toJson/copyWith/props)
- **Completude profil** : categorie Identite exige maintenant prenom + nom + age + **username** (4 champs)
- Seekers existants passent de 100% a 80% → profile gate les redirige pour completer

### Repository — DONE
- `profile_repository.dart` : +`isUsernameAvailable(username)` — verification unicite temps reel

### Formulaire profil — DONE
- `edit_seeker_profile_page.dart` : champ username dans section Identite (apres Nom)
  - Icone `@` (alternate_email), InputFormatter `[a-z0-9_-]`, max 10 chars
  - Debounce 500ms verification unicite Supabase
  - Feedback visuel : spinner (checking), check vert (disponible), croix rouge (pris)
  - Validator : requis, min 3 chars, regex, unicite

### Tests — DONE
- `profile_completion_test.dart` : tous les tests mis a jour (identite = 4 champs)
- **73/73 tests pass**, 0 issues flutter analyze

### Unicite garantie a 3 niveaux
1. PostgreSQL : UNIQUE constraint (rejet en base)
2. Repository : `isUsernameAvailable()` (verification avant save)
3. UI : feedback temps reel + validation au submit

---

## Ce qui a ete fait — Sprint 27 : Nettoyage et documentation du codebase (2026-03-31)

### Objectif
Homogeneiser tout le codebase Flutter (~98 fichiers) avec des conventions de documentation francaise, supprimer le code mort, et reduire les debugPrints excessifs. Aucune modification de logique.

### Suppression de code mort — DONE
- **Supprime** : `lib/core/services/r2_service.dart` (377 lignes) — jamais importe, dupliquait video_upload_service.dart
- **Supprime** : `lib/core/network/api_client.dart` (348 lignes) + dossier `network/` — jamais importe
- **Retire** : shadow tokens inutilises dans `app_theme.dart` (shadowSm/Md/Lg/Xl, 34 lignes)
- **Retire** : 1 TODO stale dans `video_record_page.dart`
- **Total** : 725 lignes mortes supprimees

### Documentation francaise ~98 fichiers — DONE
- Tous les fichiers standalone : `library;` + `/// Description francaise.`
- Tous les fichiers `part of` : `/// Description francaise.` avant `part of`
- Tous les `///` anglais traduits en francais sur classes/methodes publiques

### Reduction debugPrints — DONE
- ~100 debugPrints de routine supprimes (sur 224 total)
- Restent ~130 debugPrints, tous dans des blocs `catch` (diagnostics d'erreur uniquement)
- Fichiers principaux nettoyes : push_notification_service, sirene_service, feed_page, message_repository, conversation_repository, application_repository, admin_repository, admin_bloc

### Resultats
- **89/89 tests pass**, 0 issues flutter analyze
- 0 appels `print()`, 0 `withOpacity()` deprecie, 0 TODO/FIXME
- CLAUDE.md mis a jour avec les nouveaux standards de documentation

---

## Ce qui a ete fait — Sprint 26 : Decoupler Candidatures des Conversations (2026-03-20)

### Objectif
Les candidatures deviennent un acte simple en 1 clic (sans chat). Seul le recruteur peut initier le contact. Le chercheur voit ses candidatures dans son profil.

### Story 26.1 : Migration SQL table `applications` — DONE
- **Nouveau** : `supabase/migrations/20260320000000_applications_table.sql`
  - Table `applications` (id, video_id, seeker_id, recruiter_id, status, applied_at)
  - UNIQUE(video_id, seeker_id), index sur seeker_id/recruiter_id/video_id
  - RLS : seeker SELECT/INSERT/UPDATE own, recruiter SELECT/UPDATE own
  - Status : 'pending', 'contacted', 'withdrawn'

### Story 26.2 : Rewrite ApplicationRepository — DONE
- `application_repository.dart` : toutes les methodes lisent/ecrivent `applications` (plus `conversations`)
  - +`applyToOffer(videoId, recruiterId)` — INSERT dans applications
  - +`getAppliedVideoIds()` — Set<String> des video_id du seeker
  - +`getSeekerApplications()` — liste enrichie (titre, entreprise, status)
  - +`withdrawApplication(applicationId)` — UPDATE status = 'withdrawn'
  - +`markAsContacted(applicationId)` — UPDATE status = 'contacted'
  - Rewrite `getOffersWithApplicationCount()` — COUNT depuis applications
  - Rewrite `getCandidatesForOffer()` — SELECT depuis applications + join seeker_profiles
- `OfferCandidate` : `conversationId` remplace par `applicationId` + `applicationStatus`
- **Nouveau modele** : `SeekerApplication` (id, videoId, status, offerTitle, companyName, contractType)

### Story 26.3 : Feed bouton Postuler decouple — DONE
- `feed_event.dart` : +`FeedApplyToOffer(videoId, recruiterId)`
- `feed_state.dart` : +`appliedVideoIds` dans `FeedLoaded` + copyWith
- `feed_bloc.dart` : +dependance `ApplicationRepository`, charge `appliedVideoIds` au load seeker, handler `_onApplyToOffer` (optimistic + rollback)
- `injection_container.dart` : +`applicationRepository: sl()` dans FeedBloc
- `feed_page.dart` : bouton "Postule" (grise + check) si deja applique, sinon "Postuler" → dispatch + animation succes

### Story 26.4 : Animation de succes "Candidature envoyee" — DONE
- **Nouveau** : `features/applications/presentation/widgets/apply_success_overlay.dart`
  - OverlayEntry avec animation pure Flutter (fade in, scale circle + check, texte, hold, fade out)
  - 1600ms total, IgnorePointer pour ne pas bloquer les interactions

### Story 26.5 : Recruteur "Contacter" cree la conversation — DONE
- `offer_candidates_page.dart` : `_openChat` reecrit :
  1. `ConversationRepository.findOrCreateConversation(otherUserId)`
  2. `ApplicationRepository.markAsContacted(applicationId)`
  3. Navigation vers chat
- Badge status sur chaque candidat : "En attente" (orange) / "Contacte" (vert)

### Story 26.6 : Page "Mes candidatures" chercheur — DONE
- **Nouveau** : `features/applications/presentation/pages/seeker_applications_page.dart`
  - Liste cartes avec titre offre, nom entreprise, type contrat, status badge, date
  - Bouton "Retirer" avec dialog confirmation (status pending uniquement)
  - Pull-to-refresh + EmptyStateWidget
- `profile_page.dart` : section "Mes candidatures" dans `_SeekerProfileView` → `/my-applications`
- `app_router.dart` : +route `/my-applications` + import

### Story 26.7 : Tests — DONE
- `application_repository_test.dart` : adapte pour applicationId/applicationStatus + tests SeekerApplication (4 nouveaux)
- `feed_bloc_test.dart` : +MockApplicationRepository, +tests FeedApplyToOffer (success + rollback), +test appliedVideoIds charge au load seeker, +test recruiter ne charge pas appliedVideoIds

### Resultats
- **88/88 tests pass** (8 nouveaux), 0 issues flutter analyze
- Migration SQL a deployer : `20260320000000_applications_table.sql`

---

## Ce qui a ete fait — Sprint 25 : Dossiers Candidatures par Offre (2026-03-20)

### Changement 1 : Modele Conversation enrichi (Story 25.1) — DONE
- `message_model.dart` : +3 champs `videoTitle`, `videoType`, `videoThumbnailUrl` (constructor, copyWith, props)
- `message_repository.dart` : +`_enrichWithVideoInfo()` — fetch video info quand `videoId` non-null

### Changement 2 : Repository candidatures (Story 25.2) — DONE
- **Nouveau** : `features/applications/data/repositories/application_repository.dart`
  - `OfferWithApplications` : modele offre + compteur candidats
  - `OfferCandidate` : modele candidat complet (profil seeker + video presentation)
  - `getOffersWithApplicationCount()` : offres du recruteur avec count conversations
  - `getCandidatesForOffer(videoId)` : liste candidats avec profil + video
- `injection_container.dart` : +`ApplicationRepository` singleton

### Changement 3 : Page "Mes offres — Candidatures" (Story 25.3) — DONE
- **Nouveau** : `features/applications/presentation/pages/offer_applications_page.dart`
  - Liste offres du recruteur avec thumbnail, titre, type, badge compteur candidats (jaune/gris)
  - Pull-to-refresh, empty state mascotte, error state

### Changement 4 : Fiche candidat avec video (Story 25.4) — DONE
- **Nouveau** : `features/applications/presentation/pages/offer_candidates_page.dart`
  - Liste candidats par offre avec card : photo + nom + age + ecole + ville + domaine
  - Video presentation inline (VideoPlayer avec play/pause + progress bar)
  - Bouton "Contacter" pleine largeur → ouvre chat existant

### Changement 5 : Badge offre dans conversations (Story 25.5) — DONE
- `conversations_page.dart` : affiche "Offre : {titre}" en orange sous le nom du chercheur

### Changement 6 : Navigation + integration (Story 25.6) — DONE
- `app_router.dart` : +routes `/offers/applications` et `/offers/:videoId/candidates`
- `my_publications_page.dart` : +bouton "Candidatures" dans AppBar + "Voir candidats" dans menu de chaque offre

### Changement 7 : Tests (Story 25.7) — DONE
- `application_repository_test.dart` : 6 tests (OfferWithApplications + OfferCandidate modeles)
- `conversation_video_enrichment_test.dart` : 5 tests (enrichissement video conversation)

### Resultats
- **80/80 tests pass** (11 nouveaux), 0 issues flutter analyze
- Pas de migration SQL requise (video_id existait deja dans conversations)

---

## Ce qui a ete fait — Sprint 24 : Photo profil chercheur + Profil public + Feed optimise (2026-03-17)

### Changement 1 : Photo profil chercheur — DONE
- `seeker_profile_model.dart` : +champ `photoUrl` (fromJson/toJson/copyWith/props)
- `edit_seeker_profile_page.dart` : photo picker (ImagePicker) + crop circulaire (CircleCropDialog) + upload Supabase Storage
- `profile_repository.dart` : +`uploadSeekerPhoto()` (bucket `seeker-photos`), +`getSeekerProfileById()`
- `profile_page.dart` : affiche photo dans header seeker (CircleAvatar avec NetworkImage)
- **Completude profil redefinie** : photo(20%) + identite(20%) + etudes(20%) + localisation(20%) + domaine(20%) = 100%
  - L'ancien 20% "inscription" est remplace par 20% "photo" (obligatoire pour completer)
- **Nouveau** : `circle_crop_dialog.dart` — dialog plein ecran crop circulaire (lib `crop_your_image`)

### Changement 2 : Profil public chercheur — DONE
- **Nouveau** : `public_seeker_profile_page.dart` — page read-only vue par recruteurs
  - Header avec photo + nom + age
  - Infos : ecole/niveau, ville, domaine/specialite
  - Grille videos avec thumbnails (CachedNetworkImage)
  - Bouton "Envoyer un message" (recruteurs uniquement, gate profil, guard block)
- `app_router.dart` : route `/public-profile/:userId` transformee en `_PublicProfileRouter` intelligent
  - Charge seeker + recruiter profiles en parallele, detecte le role, redirige vers la bonne page

### Changement 3 : Optimisation preload video feed — DONE
- `video_preload_manager.dart` : reecrit — strategie bandwidth-aware
  - Priorite : charge video courante d'abord, preload suivante APRES que la courante joue
  - Cache LRU max 4 controleurs (prev, current, next, +1 buffer)
  - Extends ChangeNotifier pour rebuild reactifs
  - Header HTTP `Connection: keep-alive` sur toutes les requetes
- `feed_video_player.dart` : integration nouveau preload manager
  - Fallback 600ms : attend controleur precharge, sinon cree le sien
  - Indicateur buffering separe du loading
  - CachedNetworkImage pour thumbnails
  - Meilleure gestion lifecycle + disposal
- `feed_page.dart` : integration listener pattern avec preload manager

### Changement 4 : Navigation messagerie vers profils — DONE
- `conversations_page.dart` : recruteurs voient profil public seeker avant le chat
- `chat_page.dart` : titre cliquable → navigation vers profil public de l'interlocuteur
- `message_model.dart` : +champ `otherUserRole` sur Conversation
- `message_repository.dart` : hydrate `otherUserRole` + `otherUserAvatar` (photo_url seeker / logo_url recruiter)

### Changement 5 : Migration categories → secteurs (publish) — DONE
- `publish_offer_page.dart` : dropdown categories dynamiques remplace par secteurs statiques (SectorConstants)
- `feed_repository.dart` : suppression `_loadCategories`
- Labels "Categorie" → "Secteur" dans l'UI

### Changement 6 : Migration SQL — A DEPLOYER
- `20260318000000_seeker_photo_url.sql` : `ALTER TABLE seeker_profiles ADD COLUMN photo_url`
  - Bucket storage `seeker-photos` (public, 5MB max, images only)
  - RLS : upload/update own folder, public read

### Resultats
- **69/69 tests pass** (4 nouveaux tests profil), 0 issues flutter analyze
- Dependency ajoutee : `crop_your_image: ^1.1.0`
- Migration SQL prete (a deployer via `supabase db push`)

---

## Ce qui a ete fait — Sprint 23 : Correction 9 bugs beta + admin RLS + verification auto 100% (2026-03-11)

*(Commite le 2026-03-11 — voir commit 649d654)*

---

## Ce qui a ete fait — Deploiement infra (2026-03-11)

### Migrations SQL deployees en production — DONE
- `20260303000000_fix_trigger_copy_siret.sql` — trigger `handle_new_user()` copie SIRET/SIREN/legal_form + backfill recruteurs existants
- `20260306000000_seeker_specialty.sql` — colonne `specialty` sur `seeker_profiles` (deja existante, IF NOT EXISTS safe)
- **15/15 migrations synchronisees** (Local = Remote)
- Supabase CLI configure : `config.toml` + projet linke (`--workdir` = racine du projet)

### Configuration Supabase Auth OTP — DONE
- Email confirmation activee (`mailer_autoconfirm: false`)
- Template email custom "Votre code de verification ETOILE" avec `{{ .Token }}` orange
- OTP length corrige de 8 → **6 chiffres** (via Management API)
- OTP expiration : 3600s (1h)

### Supabase CLI corrige — DONE
- `supabase/config.toml` cree (etait manquant)
- Projet linke avec `--workdir "C:\...\Etoile-mobile-app"` (parent du dossier supabase/)
- Ancien nested `supabase/supabase/` nettoye
- Commande : `npx --prefix supabase supabase db push --workdir "C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app"`

### Stripe — NOTE POUR PLUS TARD
- Actuellement en **mode test** — garder test pendant toute la beta
- Passage en prod Stripe a faire **juste avant soumission store** :
  1. Completer KYC Stripe (1-3 jours, lancer en avance)
  2. Remplacer cles `pk_test_` → `pk_live_`, `sk_test_` → `sk_live_`
  3. Recreer webhook live + nouveau `whsec_`
  4. Recreer Products/Prices en mode live (nouveaux `price_` IDs)
  5. Mettre a jour Supabase secrets
  6. Tester un vrai paiement petit montant

### Resultats
- **65/65 tests pass**, 0 issues flutter analyze
- Toutes les migrations deployees, OTP configure

---

## Ce qui a ete fait — Sprint 22 : Ameliorations UX + Verification Email + Sous-secteurs (2026-03-06)

### Changement 1 : Retirer mascotte de Welcome — DONE
- `welcome_page.dart` : supprime Image.asset mascotte + SizedBox. Logo + texte ETOILE + CTAs restent.

### Changement 2 : Profil recruteur sans logo — DONE
- `edit_recruiter_profile_page.dart` : supprime logo (CircleAvatar, _pickLogo, upload), hauteur header 220→180
- `profile_page.dart` (_RecruiterHeader) : supprime logo Positioned, hauteur 240→200, repositionner texte `left: AppTheme.spaceMd`
- `public_recruiter_profile_page.dart` : supprime logo Positioned, hauteur 240→200, repositionner texte
- `recruiter_profile_model.dart` : `logoUrl` garde en DB (backward compat), plus affiche ni uploade

### Changement 3 : Sous-secteurs (specialites) + Constants centralisees — DONE
- **Nouveau** : `lib/core/constants/sector_constants.dart` — secteurs, specialites par secteur, niveaux etudes, labels, helpers
- **Migration** : `supabase/migrations/20260306000000_seeker_specialty.sql` — `ALTER TABLE seeker_profiles ADD COLUMN specialty text`
- `seeker_profile_model.dart` : +champ `specialty` (fromJson/toJson/copyWith/props)
- `edit_seeker_profile_page.dart` : remplace constantes locales par SectorConstants, +dropdown specialite conditionnel
- `profile_page.dart` : affiche specialite a cote du domaine

### Changement 4 : Verification email OTP a l'inscription — DONE
- `auth_state.dart` : `AuthEmailVerificationRequired` +email +role
- `auth_event.dart` : +`AuthVerifyOtpRequested`, +`AuthResendOtpRequested`
- `auth_bloc.dart` : +handlers OTP (verifyOTP, resend), emit AuthEmailVerificationRequired dans register
- `register_page.dart` : redirige vers /verify-email au lieu de dialog
- **Nouveau** : `otp_verification_page.dart` — champ 6 chiffres, timer 60s resend, BlocConsumer
- `app_router.dart` : +route `/verify-email` + ajout a isAuthRoute
- **Prerequis** : activer "Enable email confirmations" dans Supabase dashboard + template OTP 6 chiffres

### Changement 5 : Page recherche differenciee seeker/recruteur — DONE
- `search_page.dart` : reecrit en wrapper role-aware (_SeekerSearchView + _RecruiterSearchView)
  - Seeker : secteur + specialite + localisation IdF + rechercher/parcourir
  - Recruteur : domaine + specialite + ville CityAutocompleteField + niveau etudes + rechercher/parcourir
- `feed_page.dart` : +params `initialSpecialty`, `initialCity`, `initialStudyLevel`
- `feed_item_model.dart` : FeedItem +specialty +studyLevel, FeedFilters +specialty +city +studyLevel
- `feed_repository.dart` : getRecruiterFeed inclut specialty/studyLevel, _applyRecruiterFilters filtre par specialty/city/studyLevel
- `app_router.dart` : query params supplementaires (specialty, city, studyLevel) dans route /feed

### Changement 6 : Gate profil obligatoire (hard redirect) — DONE
- `app_router.dart` : +statics `_profileComplete`, `_profileChecked`, `updateProfileComplete()`, `isProfileComplete`, `resetProfileCheck()`
  - Redirect : si profileChecked && !profileComplete && !admin → edit profile (sauf routes autorisees)
- `profile_bloc.dart` : appelle `AppRouter.updateProfileComplete()` apres load/save
- `auth_bloc.dart` : pre-charge completude profil dans `_onCheckRequested`, reset dans logout
- `edit_seeker_profile_page.dart` + `edit_recruiter_profile_page.dart` : apres save OK, check `AppRouter.isProfileComplete` pour naviguer

### Resultats
- **65/65 tests pass**, 0 issues flutter analyze
- Migration SQL prete (a deployer via Supabase dashboard)

---

## Ce qui a ete fait — Sprint 21 : Systeme Admin (2026-03-02)

### Fix ProfileBloc crash pour admin — DONE
- `profile_state.dart` : +`AdminProfileLoaded` state (userId, email)
- `profile_bloc.dart` : +branche `role == 'admin'` dans `_onLoadRequested`, +SupabaseClient dependency
- `profile_page.dart` : +`_AdminProfileView` (icone admin, bouton dashboard, deconnexion)
- `injection_container.dart` : passe `supabaseClient` au ProfileBloc

### Navigation admin dediee — DONE
- `admin_scaffold.dart` : **NOUVEAU** — Bottom nav 4 onglets (Dashboard, Verifications, Signalements, Stats)
- `app_router.dart` : Routes admin restructurees en `ShellRoute` avec `AdminScaffold`
  - `_adminShellNavigatorKey` pour navigator separe
  - `NoTransitionPage` sur chaque route (meme pattern que MainScaffold)
  - Detail verification (`/admin/verifications/:userId`) hors shell (plein ecran)
  - Guard isAdmin sur chaque route
- Redirect splash/auth : admin → `/admin` au lieu de `/search`

### Fix dispatches en build() — DONE
- Retire `context.read<AdminBloc>().add(...)` dans `build()` de 4 pages admin :
  - `admin_dashboard_page.dart`, `admin_stats_page.dart`, `verification_queue_page.dart`, `reports_page.dart`
- Les events sont deja fires dans `BlocProvider.create` du router

### Audit logging — DONE
- `admin_repository.dart` : +`_logAction()` methode privee (insert audit_logs, silent catch)
- 6 actions auditees : `recruiter_approved`, `recruiter_rejected`, `report_dismissed`, `report_actioned`, `user_suspended`, `video_suspended`
- Migration SQL `20260302000000_audit_logs_rls.sql` : CREATE TABLE audit_logs + RLS (admin INSERT/SELECT)
- Migration deployee en production

### Nettoyage — DONE
- `auth_bloc.dart` : retire 3 debugPrint temporaires dans `_getUserRole`

### Resultats
- **65/65 tests pass**, 0 issues flutter analyze
- Migration deployee sur Supabase production

---

## Ce qui a ete fait — Sprint 20 : Ameliorations UX + Corrections A11y (2026-03-01)

### Story 20.1 : Bundler Inter en local (P5) — 3 pts — DONE
- Retire `google_fonts: ^6.2.1` des dependencies
- Declare font Inter locale dans pubspec.yaml (4 weights: 400, 500, 600, 700)
- Remplace 15x `GoogleFonts.inter()` par `TextStyle(fontFamily: 'Inter')` dans app_theme.dart
- Font chargee depuis `assets/fonts/Inter-*.ttf` (fonctionne offline)

### Story 20.2 : Lien "Parcourir tout le feed" plus visible (P3) — 1 pt — DONE
- Remplace `TextButton` par `OutlinedButton.icon` avec icone `Icons.explore` dans search_page.dart
- Bordure jaune via le theme outlined button existant

### Story 20.3 : Mini progress bar formulaires profil (P4) — 2 pts — DONE
- Ajoute `LinearProgressIndicator` (4px, couleur primaryYellow) + texte "X% complet" en haut des formulaires
- edit_seeker_profile_page.dart : calcul temps reel (5x20%)
- edit_recruiter_profile_page.dart : calcul temps reel (5x20%)

### Story 20.4 : MascotteMessage + paliers profil (P2) — 3 pts — DONE
- Fichier cree : `lib/shared/widgets/mascotte_message.dart`
  - Widget Row [mascotte 48px | bulle (titre + message)]
  - 3 variantes : info (bleu), success (vert), encouragement (jaune)
  - Factory `forCompletion()` : 40% info, 60% encouragement, 80% success
  - Dismissible via bouton close
- Integre dans edit_seeker_profile_page.dart et edit_recruiter_profile_page.dart

### Story 20.5 : Composant EtoileBadge (P1 component strategy) — 2 pts — DONE
- Fichier cree : `lib/shared/widgets/etoile_badge.dart`
  - Props : label, icon, backgroundColor, textColor, compact
  - Height 24px (compact) / 28px (normal), borderRadius radiusMd
- Remplace `_VerifiedBadge` et `_RecruiterBadge` inline dans feed_page.dart

### Story 20.6 : Corrections accessibilite — Semantics labels — 2 pts — DONE
- `empty_state_widget.dart` : Semantics sur mascotte Image.asset
- `splash_screen.dart` : Semantics sur logo + titre ETOILE
- `search_page.dart` : Semantics sur mascotte, ExcludeSemantics sur icone location decorative
- `feed_page.dart` : Semantics button+label sur _ActionButton (Postuler/Contacter/Profil/Signaler)
- `conversations_page.dart` : Semantics sur avatar + badge non-lu
- `profile_page.dart` : Semantics sur video placeholder + logo recruteur

### Story 20.7 : Tests + documentation — 1 pt — DONE
- Tests crees : `test/shared/widgets/etoile_badge_test.dart` (5 tests)
- Tests crees : `test/shared/widgets/mascotte_message_test.dart` (8 tests)
- Resultat : **65/65 tests pass**, 0 issues flutter analyze
- SESSION-RESUME.md mis a jour

---

## Ce qui a ete fait — Sprint 19 : UX Design Review (2026-02-27)

### Agent BMAD Sally (UX Designer) — Workflow create-ux-design COMPLETE (14/14 steps)

**Delivrable** : `_bmad-output/ux-design-specification.md` (~1400 lignes)

**Contenu :**
1. Executive Summary — Vision projet, target users, design challenges
2. Core User Experience — Principes d'experience, moments critiques
3. Desired Emotional Response — Journeys emotionnels seeker/recruiter
4. UX Pattern Analysis & Inspiration — TikTok, Duolingo, Indeed, WhatsApp
5. Design System Foundation — Material Design 3 customise Flutter
6. Defining Core Experience — "40 secondes pour briller"
7. Visual Design Foundation — Audit code (app_theme.dart, app_colors.dart)
8. Design Direction Decision — "Chaleur Fonctionnelle" + 5 ameliorations P1-P5
9. User Journey Flows — 5 parcours critiques avec diagrammes Mermaid
10. Component Strategy — 9 widgets existants audites + 3 a creer (EtoileBadge, MascotteMessage, SkeletonLoader)
11. UX Consistency Patterns — Boutons, feedback, forms, navigation, modals, empty states
12. Responsive Design & Accessibility — WCAG 2.1 AA, audit contraste, checklist dev

**Ameliorations prioritaires identifiees :**

| ID | Amelioration | Impact | Effort |
|----|-------------|--------|--------|
| P1 | Gradient jaune→orange sur messages envoyes | Personnalite visuelle | Faible |
| P2 | Mascotte aux paliers profil (40%, 60%, 80%) | Motivation | Moyen |
| P3 | Lien "Parcourir tout le feed" plus visible | Reduction friction | Faible |
| P4 | Mini progress bar formulaires profil | Progression | Faible |
| P5 | Bundler Inter en local (perf/offline) | Performance | Moyen |

**Actions a11y prioritaires :**

- Assombrir `greyWarm` #9E9E9E → #757575 (contraste WCAG AA)
- Ajouter Semantics labels francais sur images/icones
- Touch targets 48px minimum partout

---

## Ce qui a ete fait — Sprint 18 : Pivot Beta Alternance IdF (2026-02-28)

### Decisions cles
- **Beta cible** : Chercheurs d'alternance en Ile-de-France uniquement
- **2 secteurs** : Commerce/Vente + Restauration/Hotellerie (codes: commerce_vente, restauration_hotellerie)
- **Landing** : Page de recherche (SearchPage) au lieu du feed direct
- **Profil seeker** : prenom, nom, age, ecole, niveau etude, ville (autocomplete IdF), domaine
- **Profil recruteur** : secteur restreint a 2 options + localisation IdF (CityAutocompleteField)
- **Anciens champs seeker** : gardes en DB pour backward compat (categories, contractTypes, etc.)

### Story 18.1 : Migration DB + Modele SeekerProfile (3 pts) — DONE
- Migration SQL : 4 colonnes ajoutees (age, school, study_level, domain)
- seeker_profile_model.dart : +4 champs, nouveau completionPercentage (5x20%)
- Completion: Inscription(20%) + Identite(prenom+nom+age=20%) + Etudes(ecole+niveau=20%) + Localisation(ville=20%) + Domaine(20%)

### Story 18.2 : Refonte formulaire profil chercheur (5 pts) — DONE
- edit_seeker_profile_page.dart : reecrit — dropdowns (age, niveau, domaine) + CityAutocompleteField + EtoileTextField (ecole)
- profile_page.dart : _SeekerProfileView affiche domaine + etudes au lieu de jobTitle/availability
- profile_repository.dart : isSeekerProfileComplete utilise completionPercentage >= 100

### Story 18.3 : Autocompletion ville filtree IdF (3 pts) — DONE
- Fichier cree : shared/widgets/city_autocomplete_field.dart
- Photon API avec bbox IdF (1.44,48.12,3.56,49.24), debounce 400ms, max 5 resultats

### Story 18.4 : Restrictions recruteur beta (3 pts) — DONE
- edit_recruiter_profile_page.dart : secteur restreint a 2 options (codes) + LocationPickerWidget remplace par CityAutocompleteField
- profile_page.dart : _RecruiterProfileView affiche label secteur (pas le code) + ville texte au lieu de carte
- public_recruiter_profile_page.dart : carte remplacee par ville texte + secteur label

### Story 18.5 + 18.6 : Page de recherche + Routeur (5+3 pts) — DONE
- Fichier cree : features/feed/presentation/pages/search_page.dart (landing avec secteur dropdown + IdF badge + mascotte)
- app_router.dart : route /search ajoutee, redirect initial → /search
- main_scaffold.dart : 5 onglets bottom nav (Rechercher, Feed, Messages, Profil, Enregistrer/Publier)
- Redirections mises a jour : login, onboarding, error page, conversations → /search

### Story 18.7 : Adaptation filtres feed (3 pts) — DONE
- feed_page.dart : filtres seeker et recruteur simplifies (secteur/domaine uniquement, 2 options avec labels)
- _FilterSection : +optionLabels param pour afficher labels au lieu de codes
- FeedPage : +initialSector param (recoit secteur depuis query params de SearchPage)

### Story 18.8 : Tests + documentation (1 pt) — DONE
- profile_completion_test.dart : 8 tests seeker reecrits pour nouveaux champs (age, school, studyLevel, domain)
- Resultat : **52/52 tests pass**, 0 issues flutter analyze
- SESSION-RESUME.md mis a jour

---

## Ce qui a ete fait — Sprint 17 : Finitions Pre-Beta (2026-02-27)

### Story 17.1 : Modele B2B — premium chercheur supprime — DONE
- Suppression de SeekerPremiumPage, SeekerPremiumBloc
- FeedBloc : stats toujours accessibles (chercheurs gratuits)
- Settings : masque les liens premium pour chercheurs

### Story 17.2 : Fix 21 warnings analyse (2 pts) — DONE
**6 fichiers modifies :**
- `feed_page.dart` — 6x `__`/`___` → `_` + suppression `_getCategoryName` (unused)
- `feed_video_player.dart` — 4x `___` → `_`
- `conversations_page.dart` — import unused supprime + 1x `__` → `_`
- `public_recruiter_profile_page.dart` — 6x `__`/`___` → `_`
- `location_picker_widget.dart` — 1x `__` → `_`
- `feed_repository.dart` — doc comment `List<String>` → `List of String`
- Resultat : **0 issues**

### Story 17.3 : EmptyStateWidget reutilisable avec mascotte (3 pts) — DONE
**Fichier cree :** `lib/shared/widgets/empty_state_widget.dart`
- Parametres : icon, iconColor, title, subtitle, actionLabel, onAction, showMascotte, compact
- Deux modes : full (Center + Column) et compact (petit, inline)

**8 fichiers modifies :** Remplacement de 8 empty states inline :
- feed_page, conversations_page, chat_page, my_publications_page, verification_queue_page, reports_page, subscription_management_page, faq_page

### Story 17.4 : Welcome + Onboarding avec mascotte (5 pts) — DONE
**Fichiers crees :**
- `lib/features/auth/presentation/pages/welcome_page.dart` — Mascotte + logo + 3 boutons CTA
- `lib/features/onboarding/presentation/pages/onboarding_page.dart` — 3 slides PageView role-specific + dots + SharedPreferences flag

**Fichiers modifies :**
- `app_router.dart` — Suppression `_WelcomePage` inline, import WelcomePage/OnboardingPage, routes onboarding
- `register_page.dart` — Post-inscription redirige vers onboarding au lieu du feed

### Story 17.5 : Gestion complete utilisateurs bloques (3 pts) — DONE
**Fichier cree :** `lib/features/settings/presentation/pages/blocked_users_page.dart`
- Liste utilisateurs bloques + bouton Debloquer + confirmation dialog + EmptyStateWidget

**Fichiers modifies :**
- `block_repository.dart` — +`getBlockedUsersWithDetails()` (join seeker/recruiter profiles)
- `settings_page.dart` — Lien "Utilisateurs bloques"
- `app_router.dart` — Route `/settings/blocked`
- `public_recruiter_profile_page.dart` — Guard _isBlocked avant Contacter

### Story 17.6 : Gate profil — completude requise pour actions (5 pts) — DONE
**Fichier cree :** `lib/shared/widgets/profile_gate.dart`
- Dialog bloquant "Profil incomplet (X%)" avec bouton "Completer mon profil"

**Fichiers modifies :**
- `seeker_profile_model.dart` — +getter `completionPercentage` (5x20%)
- `recruiter_profile_model.dart` — +getter `completionPercentage` (5x20%)
- `profile_repository.dart` — +`getProfileCompletionPercentage()`
- `profile_page.dart` — `_ProfileCompletionCard` avec %, progress bar, badge "Profil complet" a 100%
- `video_record_page.dart` — Gate avant _startRecording
- `publish_offer_page.dart` — Gate avant _pickPresentation, _pickVideo, _pickPoster
- `feed_page.dart` — Gate avant _onMessageTap (Postuler/Contacter)
- `public_recruiter_profile_page.dart` — Gate avant _startConversation

### Story 17.7 : Tests supplementaires (3 pts) — DONE
**Fichiers crees :**
- `test/features/feed/presentation/bloc/feed_bloc_test.dart` — 6 tests (load, empty, error, blocked filter, refresh, filters)
- `test/shared/widgets/empty_state_widget_test.dart` — 6 tests (title, subtitle, icon, action, no-action, compact)
- `test/features/profile/profile_completion_test.dart` — 14 tests (seeker 20-100%, recruiter 20-100%, edge cases)
- Resultat : **51/51 tests pass** (objectif 38+)

### Story 17.8 : Update docs (1 pt) — DONE
- SESSION-RESUME.md, sprint-plan.md, MEMORY.md mis a jour

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
| **17** | **Finitions Pre-Beta (8/8 stories, 22/22 pts)** | **DONE** |
| **18** | **Pivot Beta Alternance IdF (8/8 stories, 26/26 pts)** | **DONE** |
| **19** | **UX Design Review — Sally (14/14 steps)** | **DONE** |
| **20** | **Ameliorations UX + A11y (7/7 stories, 14/14 pts)** | **DONE** |
| **21** | **Systeme Admin (fix crash + nav dediee + audit logs)** | **DONE** |
| **22** | **Ameliorations UX + Verification Email + Sous-secteurs (6 changements)** | **DONE** |
| **23** | **Correction 9 bugs beta + admin RLS + verification auto 100%** | **DONE** |
| **24** | **Photo profil chercheur + Profil public seeker + Feed optimise + Nav messagerie (6 changements)** | **DONE** |
| **25** | **Dossiers Candidatures par Offre — page offres + fiche candidat avec video + badge conversations (7 stories, 26 pts)** | **DONE** |
| **26** | **Decoupler Candidatures des Conversations — table applications, postuler 1-clic, animation, page seeker, contacter (7 stories, 27 pts)** | **DONE** |
| **27** | **Nettoyage codebase — doc FR ~98 fichiers, suppression 725 lignes mortes, reduction debugPrints** | **DONE** |
| **29** | **Username @pseudo chercheur — migration SQL, modele, formulaire, verification unicite temps reel** | **DONE** |
| **30** | **Nettoyage DB — DROP 4 tables + 17 colonnes, suppression 3 fichiers orphelins, retrait categories du code** | **DONE** |
| **13.1** | **Camera in-app — testee et validee sur Android physique** | **DONE** |

### Prochains sprints

**Track 1 : App Mobile (Chercheur only)**
- [x] ~~Nettoyer/masquer le code recruteur dans l'app Flutter~~
- [x] ~~Ajouter champ username (@pseudo) dans le profil chercheur~~
- [x] ~~Deployer migrations username~~
- [x] ~~Nettoyage DB : tables/colonnes/fichiers inutilises~~
- [x] Story 13.1 : Camera in-app (8 pts) — DONE (testee Android physique 2026-04-13)
- [ ] Preparation store (screenshots, description, soumission)

**Track 2 : SaaS Web (Recruteur)**
- [ ] Init projet Next.js + Tailwind + Shadcn/ui + Supabase
- [ ] Migrations DB (~5 tables)
- [ ] Pages core : login, briefing, grille, modal, dashboard, messages
- [ ] Edge Function scoring
- [ ] Integration & Tests (Playwright)
- [ ] Beta recruteurs (5-10 invites)

**Infra**
- ~~Deployer migrations SQL~~ — **FAIT** (22/22 synchronisees)
- Stripe : rester en mode test pendant la beta, passage prod avant soumission store (KYC 1-3j)
- Tous les pre-requis infra sont deployes (migrations, OTP, admin, bucket, Edge Functions, RLS)

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
| UX Design Spec | `_bmad-output/ux-design-specification.md` | **COMPLETE** (14/14 steps) |
| UX Design draft | `_bmad-output/ux-design-etoile-draft.md` | Draft (reference historique) |
| Sprint Plan | `_bmad-output/sprint-plan.md` | Sprint 18 DONE (8/8) |
| Epics | `_bmad-output/epics.md` | Complet |
| PRD Notifications | `_bmad-output/prd-notifications-push.md` | Complet |
| Archi Notifications | `_bmad-output/architecture-notifications-push.md` | Complet |
| Instructions Claude | `CLAUDE.md` | Cree |

---

*Sauvegarde mise a jour le 2026-04-14*
*Sprint 30 TERMINE + Story 13.1 Camera DONE (Android physique). App mobile prete pour store. Next: Init SaaS Next.js (Track 2 recruteurs) + preparation store listing.*
