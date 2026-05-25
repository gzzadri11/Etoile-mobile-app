# Session BMAD - Etoile Mobile App

**Date de mise a jour** : 2026-05-16
**Statut** : **Session profil entreprise + thumbnails vidéo + notifications push**. CompanyProfilePage restructurée (3 sections, carousel, bottom sheet). OfferDetailPage avec thumbnail vidéo. Notifications push entièrement fonctionnelles (bug routing Edge Function corrigé). **32/32 migrations** déployées. 85/85 tests Flutter ✅.

---

## SESSION 2026-05-16 : Profil entreprise + Push notifications

### Tasks complétées

- ✅ Rythme alternance — dropdown overflow corrigé (`isExpanded: true` + `TextOverflow.ellipsis`)
- ✅ Feed — pause vidéo avant navigation vers profil entreprise
- ✅ Feed — navigation directe vers `CompanyProfilePage` (skip `PublicRecruiterProfilePage`)
- ✅ CompanyProfilePage — restructuration complète en 3 sections :
  - En-tête : logo/initiales (radius 44) + badge "Entreprise vérifiée"
  - À propos : description texte
  - Nos offres : carousel horizontal (height 320), tap → bottom sheet titre + description
- ✅ Carousel — miniatures correctes : `image` → `Image.network`, `video` → `VideoThumbnail.thumbnailData()`
- ✅ `OfferDetailPage` — thumbnail vidéo (même logique `video_thumbnail`) pour la zone média 300px
- ✅ `pubspec.yaml` — ajout `video_thumbnail: ^0.5.3`
- ✅ `OfferModel` — ajout champ `mediaType` ('image' | 'video') + mapping dans `app_router.dart`
- ✅ Push notifications — correction complète :
  - Migration `20260516000001_recreate_notification_log.sql` (table supprimée par erreur)
  - `send-push/index.ts` — try/catch sur `shouldSendNotification` + `logNotification` (fail-open)
  - Bug routing : payload trigger contient `"type":"INSERT"` ET `"table"` → vérifier `"table"` en premier
  - Résultat : notifications reçues ✅ testé sur SM S721B

### Fichiers modifiés
- `flutter_application_1/lib/features/profile/presentation/pages/edit_seeker_profile_page.dart`
- `flutter_application_1/lib/features/feed/presentation/pages/feed_page.dart`
- `flutter_application_1/lib/features/company/pages/company_profile_page.dart`
- `flutter_application_1/lib/features/company/models/company_model.dart`
- `flutter_application_1/lib/features/offer/pages/offer_detail_page.dart`
- `flutter_application_1/lib/core/router/app_router.dart`
- `flutter_application_1/pubspec.yaml`
- `supabase/functions/send-push/index.ts`
- `supabase/migrations/20260516000001_recreate_notification_log.sql` (nouveau)

### Migration déployée ✅
- `20260516000001_recreate_notification_log.sql` — table pour déduplication notifications push

**Total migrations** : 32/32

### Prochaines étapes
- **Track SaaS** : Epic 6 (Paiements Stripe) ou Epic 7 (Admin) — à définir
- **Infra** : Soumission stores (App Store + Google Play), déploiement Vercel, config Stripe

---

## SESSION 2026-05-25 : Améliorations SaaS + Pivot navigation

### Pivot navigation SaaS (décision définitive)
**L'onglet "Candidats" est supprimé.** Le recruteur accède aux candidatures via Mes offres → clic sur une offre → liste des candidats de cette offre. Mental model = par poste, pas par candidat. **Ne pas recréer cet onglet.**

Navigation post-pivot :
- Dashboard → KPIs, nouvelles candidatures (lien vers offre concernée)
- Mes offres → Liste des offres → Clic → Candidatures de cette offre → Modal candidat
- Rechercher → Recherche globale @username / nom / filtres
- Paramètres → Profil recruteur

### Améliorations UX appliquées (session précédente)
- Score dashboard : fetché depuis `match_scores` (était hardcodé à 0)
- CandidateCard : photo de profil par défaut (pas la thumbnail vidéo)
- Bouton "Passer" avec retrait optimiste + update `withdrawn` en base
- Déduplication par `seeker_id` dans la grille candidats
- OfferCard : icône play ▶ superposée sur les offres vidéo
- Page Recherche : implémentation complète (texte libre + 3 filtres + debounce 400ms)

### Fichiers modifiés (pivot navigation)
- `components/layout/sidebar.tsx` — Candidats supprimé
- `app/(dashboard)/offers/page.tsx` — deux états : liste / candidatures
- `components/offers/offer-card.tsx` — cliquable + chevron + compteur
- `components/offers/OfferCandidatesView.tsx` — nouveau composant
- `hooks/useDashboardData.ts` — videoId dans RecentActivity
- `components/dashboard/ActivityFeed.tsx` — lien vers offre concernée
- Supprimé : `app/(dashboard)/candidates/page.tsx`

### Prochaines étapes
- **Track SaaS** : Epic 6 (Paiements Stripe) — PRIORITÉ
- **Infra** : Déploiement Vercel + config Stripe + soumission stores

---

## SESSION 2026-05-10 : Onboarding + Fixes Flutter

### Tasks complétées

- ✅ Onboarding — retrait cadre blanc offres (page 2) + bulle message (page 3)
- ✅ Onboarding — suppression paramètre `decorativeWidget` + classes mortes (`_OffersList`, `_OfferRow`, `_MessageBubble`)
- ✅ Onboarding — images agrandies (flex 6→7) + textes agrandis (titre 30, description 17)
- ✅ Onboarding — fix timing : ajout flag `_isNewAuthSession` dans `AppRouter`
  - L'onboarding ne se déclenche plus au lancement de l'app (session restaurée)
  - `AppRouter.markFreshLogin()` appelé avant `emit(AuthAuthenticated)` dans `_onLoginRequested` et `_onRegisterRequested`
  - `resetProfileCheck()` remet `_isNewAuthSession = false` au logout
- ✅ Feed — fix overflow "bottom overflowed by 538 pixels" dans le bottom sheet "Voir la description"
  - Cause : `Column(mainAxisSize: min)` sans contrainte de hauteur → dépasse l'écran si description longue
  - Fix : `ConstrainedBox(maxHeight: 75% écran)` + `SingleChildScrollView` autour du contenu
- ✅ `OfferDetailPage` — `AspectRatio(9/16)` (~700px) remplacé par `SizedBox(height: 300)` + `BoxFit.cover`

### Fichiers modifiés
- `flutter_application_1/lib/features/onboarding/presentation/pages/onboarding_page.dart`
- `flutter_application_1/lib/core/router/app_router.dart`
- `flutter_application_1/lib/features/auth/presentation/bloc/auth_bloc.dart`
- `flutter_application_1/lib/features/offer/pages/offer_detail_page.dart`
- `flutter_application_1/lib/features/feed/presentation/pages/feed_page.dart`

---

## SESSION 2026-05-03 : Corrections UX + Rythmes + Évaluations

### Tasks complétées (11/12)
- ✅ #1 : Messagerie temps réel (Epic 15)
- ✅ #2 : Évaluation candidat 3 états (SaaS)
- ✅ #3 : Recherche filtres globaux (Mobile - 6 filtres)
- ✅ #4 : Feed bouton description TikTok
- ✅ #5 : Profil compétences chercheur ✅ **VALIDÉ**
- ✅ #6 : Splash screen violet
- ✅ #7 : Messagerie bulles violet/gris
- ✅ #9 : Contrats - supprimer Stage/Pro
- ✅ #10 : Profil rythme alternance
- ✅ #11 : Formulaire offre - boutons Annuler ✅ **DONE**
- ⏳ #8, #12 : À faire

### Rythmes d'alternance - Standardisation
**Fichier créé** : `lib/core/constants/app_constants.dart`
- **11 rythmes officiels** (hebdo, bi-hebdo, mensuel, blocs, personnalisé)
- **Mappings bidirectionnels** : `rhythmShortToFull` (DB→UI) + `rhythmFullToShort` (UI→DB)
- **Fichiers mis à jour** : search_page.dart, edit_seeker_profile_page.dart
- **Cohérence** : source unique de vérité pour tous les rythmes

### Task #2 : Évaluation candidats (SaaS Next.js)
**Migration** : `20260503000002_create_candidate_evaluations.sql`
- Table `candidate_evaluations` (rating: interested/neutral/not_interested, notes TEXT)
- RLS policies : SELECT/INSERT/UPDATE/DELETE own evaluations
- Index : recruiter_id, application_id

**Server Actions** :
- `saveEvaluation(applicationId, rating, notes)` - upsert pattern
- `getEvaluation(applicationId)` - récupération

**UI** : `components/candidates/candidate-modal.tsx`
- Onglet "Évaluer" : 3 boutons rating (ThumbsUp/Minus/ThumbsDown)
- Textarea notes privées avec auto-save au blur
- Loading states + feedback visuel

**Build** : ✅ Next.js production successful

### Task #3 : Filtres recherche globaux (Mobile Flutter)
**Ajout de 3 nouveaux filtres** dans SearchPage :
1. **Niveau d'études** : Dropdown avec SectorConstants.studyLevelOptions
2. **Ville** : CityAutocompleteField (API Adresse gouvernement, debounce 400ms)
3. **Rythme** : 11 chips avec mapping complet

**Modèle** : FeedFilters.rhythm ajouté (+ copyWith, hasFilters, props)
**Transmission** : Query params sector/specialty/studyLevel/city/rhythm/proximityKm → FeedPage

**Avant** : 3 filtres (secteur, spécialité, proximité)
**Après** : 6 filtres (+ niveau, ville, rythme)

### Task #10 : Rythme profil chercheur (Mobile Flutter)
**Migration** : `20260503000001_add_seeker_rhythm.sql`
- Colonne `seeker_profiles.rhythm VARCHAR` nullable
- Comment : "Rythme d'alternance souhaité (3j/2j, 1sem/1sem, ...)"

**Modèle** : SeekerProfile.rhythm
- Ajouté : property, constructor, fromJson, toJson, copyWith, props

**UI** : edit_seeker_profile_page.dart
- Dropdown "Rythme d'alternance (optionnel)"
- 11 options depuis rhythmShortToFull
- Sauvegarde automatique avec le profil

### Corrections UX Feed
**Bouton "Description"** repositionné :
- **Avant** : `bottom: 12` (chevauchement avec infos vidéo)
- **Après** : `bottom: 130 + MediaQuery.padding.bottom` (au-dessus des infos)
- **Icône** : `info_outline` (plus claire que keyboard_arrow_up)
- **Alignement** : gauche (au lieu de centré)
- **Style** : border blanche subtile pour contraste

### Task #5 : Compétences chercheur ✅ VALIDÉ
**Migration** : `20260503000003_add_skills_to_profiles.sql`
- Colonne `seeker_profiles.skills TEXT[]` DEFAULT '{}'
- Colonne `videos.keywords TEXT[]` DEFAULT '{}' (pour scoring)
- Index GIN sur les deux colonnes
- Fonction `calculate_match_score()` mise à jour : +20% skills matching

**Flutter** : `lib/features/profile/presentation/pages/profile_page.dart`
- Section interactive avec tags + bouton "+"
- Bottom sheet pour ajouter compétences (TextField + validation)
- Suppression individuelle par tag (icône close)
- **Fix persistence** : dispatch `ProfileRefreshRequested()` après sauvegarde

**SaaS** : `components/candidates/candidate-modal.tsx`
- Affichage read-only badges violet clair
- Condition `seeker.skills && seeker.skills.length > 0`
- Debug console temporaire ajouté

**Scoring** : Compétences = 20% du match total
- Fuzzy matching case-insensitive
- Score = (nb_matches / nb_keywords) * 20
- Si offre sans keywords → 10/20 (neutre)
- Si chercheur sans skills → 0/20

**Statut** : ✅ Testé et validé (persistence Flutter + affichage SaaS OK)

### Task #11 : Formulaire offre - Boutons Annuler ✅ DONE
**Fichier** : `saas-etoile/app/(dashboard)/offers/new/page.tsx`

**Contexte** : Le wizard de création d'offre (3 étapes : type → upload → details) ne permettait pas de quitter le formulaire une fois commencé.

**Modifications** :
- Étape "type" : Ajout bouton "Annuler" (outline) → redirect `/offers`
- Étape "upload" : Ajout bouton "Annuler" (ghost) + "Retour"
- Étape "details" : Ajout bouton "Annuler" (ghost) + "Retour"

**Navigation** :
- Avant : Impossible de quitter sans finir le wizard
- Après : Bouton "Annuler" sur chaque étape → sortie rapide vers /offers

**Build** : ✅ Compiled successfully in 12.6s
**Commit** : `b37cb4d` (1 fichier, 471 insertions)

**Bug Fix - Navigation entre étapes** :
- **Problème** : URL blob révoquée trop tôt → erreur "type MIME non géré" au retour arrière
- **Solution** : Cleanup automatique via useEffect, pas de revoke pendant navigation
- **Commit** : `0fb52da` (14 insertions, 1 suppression)
- **Tests** : ✅ Navigation type→upload→details→upload→details fluide

### Migrations déployées ✅
1. ✅ `20260503000001_add_seeker_rhythm.sql`
2. ✅ `20260503000002_create_candidate_evaluations.sql`
3. ✅ `20260503000003_add_skills_to_profiles.sql`

**Total** : 30/30 migrations déployées

### Tests & Build
- **Flutter** : 85/85 tests ✅ | 0 erreur analyze (2 info bénignes prefer_final_fields)
- **Next.js** : Build production ✅ | TypeScript OK

---

## SESSION PRÉCÉDENTE 2026-05-02 : Epic 10 Phase 2 DONE

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
1. **App mobile** : preparation store listing (screenshots, description)
2. **SaaS web** : ~~Publication offres (Epic 11)~~ DONE + ~~Epic 12-15~~ DONE + ~~Epic 10 Phase 2~~ DONE — **prochaine etape : Epic 6 (Paiements Stripe) ou Epic 7 (Admin)** ← **À DÉFINIR**

---

## Ce qui a ete fait — Sprint SaaS-2 : Publication Offres (Epic 11) (2026-04-21)

### Objectif
Debloquer le flux complet : Recruteur publie offre → Chercheur postule (mobile) → Recruteur voit candidatures (SaaS).

### Migration SQL — DONE
- `20260421000000_video_sector.sql` : colonne `sector TEXT` sur `videos` + index conditionnel sur actives
- A deployer via `supabase db push`

### Composants Shadcn installes (7) — DONE
- dialog, select, badge, textarea, progress, dropdown-menu, tooltip

### Types & Constantes — DONE
- `database.ts` : +`Video` + `Application` interfaces TypeScript
- `contracts.ts` : types de contrat (alternance, stage, professionnalisation) + helper
- `routes.ts` : +`OFFERS_NEW: "/offers/new"`

### Systeme d'upload — DONE
- `app/api/upload/presigned-url/route.ts` : proxy API route (session Supabase → Worker Cloudflare)
- `lib/upload.ts` : utilitaire browser-side avec progress tracking (XMLHttpRequest)
- `.env.local` : +`NEXT_PUBLIC_CLOUDFLARE_WORKER_URL`
- `.env.example` : cree (3 variables)

### Page `/offers` — Liste des offres — DONE
- Grille de cartes offres (thumbnail, titre, badges secteur/contrat/status, compteur candidatures)
- Empty state avec CTA "Publier une offre"
- Edit dialog (titre, secteur, contrat, description) + Delete dialog (soft-delete)
- Menu actions sur chaque carte (modifier/supprimer)

### Page `/offers/new` — Wizard multi-etapes — DONE
- **Etape 1** : choix type (Video / Affiche) — 2 cards cliquables
- **Etape 2** : drag & drop + file picker + preview (video player ou image)
  - Video : MP4/MOV/WebM, validation duree <=40s via `<video>` element, max 50 Mo
  - Affiche : JPEG/PNG/WebP, max 10 Mo
- **Etape 3** : formulaire details (titre, secteur Select, contrat Select, description Textarea)
- **Etape 4** : progress bar pendant upload, INSERT dans `videos`, redirect `/offers`
- **Gate d'acces** : recruteur non verifie → alerte + redirection parametres

### Dashboard updates — DONE
- Vrais compteurs (candidatures, conversations, offres actives) via requetes Supabase
- Cards cliquables (liens vers pages correspondantes)

### Layout updates — DONE
- Sidebar : active state `startsWith()` (highlight `/offers` quand sur `/offers/new`)
- Header : titre "Nouvelle offre" pour `/offers/new`

### Resultats
- **Build Next.js OK** : 0 erreurs TypeScript
- **85/85 tests Flutter** : pas de regression
- **0 issues flutter analyze**
- Note : Shadcn v4 utilise `@base-ui/react` — pas de `asChild` prop, utiliser `render` ou classes CSS directement

### Bugfix: pages placeholder manquantes — DONE
- `/candidates`, `/messages`, `/settings` retournaient 404 (pages inexistantes)
- 3 pages placeholder creees avec message "arrive bientot"

### Fichiers crees (13 + 7 Shadcn auto)
- `supabase/migrations/20260421000000_video_sector.sql`
- `saas-etoile/lib/constants/contracts.ts`
- `saas-etoile/lib/upload.ts`
- `saas-etoile/app/api/upload/presigned-url/route.ts`
- `saas-etoile/app/(dashboard)/offers/page.tsx`
- `saas-etoile/app/(dashboard)/offers/new/page.tsx`
- `saas-etoile/components/offers/offer-card.tsx`
- `saas-etoile/components/offers/file-drop-zone.tsx`
- `saas-etoile/components/offers/edit-offer-dialog.tsx`
- `saas-etoile/components/offers/delete-offer-dialog.tsx`
- `saas-etoile/.env.example`
- `saas-etoile/app/(dashboard)/candidates/page.tsx` (placeholder)
- `saas-etoile/app/(dashboard)/messages/page.tsx` (placeholder)
- `saas-etoile/app/(dashboard)/settings/page.tsx` (placeholder)

### Fichiers modifies (5)
- `saas-etoile/lib/types/database.ts` — +Video, +Application
- `saas-etoile/lib/constants/routes.ts` — +OFFERS_NEW
- `saas-etoile/app/(dashboard)/dashboard/page.tsx` — vrais compteurs + liens
- `saas-etoile/components/layout/sidebar.tsx` — fix active state startsWith
- `saas-etoile/components/layout/header.tsx` — +titre /offers/new

---

## Ce qui a ete fait — Epic 12 Phases 1-4 : Grille Candidats Complète (2026-04-23)

### Objectif
Epic 12 = **cœur du SaaS recruteur** (80% du temps passé). Implémentation complète de la page de visualisation et évaluation des candidatures.

### Contexte
Le SaaS avait auth + publication offres + dashboard, mais manquait la page où le recruteur **visualise et évalue les candidatures**. Epic 12 débloque le flux complet.

**Flux complet débloqué** :
1. Chercheur postule (app mobile) → application créée
2. **Recruteur voit grille candidats** ← ✅ Phase 1
3. **Recruteur clique → modal vidéo + profil** ← ✅ Phase 2
4. **Recruteur filtre par score/secteur** ← ✅ Phase 3
5. **Recruteur navigue au clavier** ← ✅ Phase 4
6. Recruteur évalue + contacte → conversation démarre

### Phases implémentées
- ✅ **Phase 1** : Scoring + grille améliorée
- ✅ **Phase 2** : Modal 60/40 + tabs (Profil/Évaluer/Messages)
- ✅ **Phase 3** : Filtres avancés sidebar (statut, offre, secteur, score)
- ✅ **Phase 4** : Raccourcis clavier (Espace, Esc, C)
- ⏸️ **Phase 5** : Tables évaluations (reporté V2)

---

### Phase 1 : Scoring + Grille — DONE

**Algorithme de scoring** : `saas-etoile/lib/scoring.ts` (nouveau)

Poids du matching :
- **Secteur** (30%) : seeker.domain === offer.sector
- **Niveau d'études** (25%) : bac+2+ = 25pts, bac/bac+1 = 15pts, CAP/BEP = 5pts
- **Localisation** (25%) : fuzzy match city avec recruiter.locations
- **Spécialité** (20%) : 20pts si rempli (fuzzy matching en V2)

Helpers :
- `calculateMatchScore()` : score 0-100
- `getScoreBadgeVariant()` : couleur badge (≥80% default/vert, ≥60% secondary/orange, <60% destructive/rouge)
- `getScoreRangeLabel()` : "Excellent match", "Bon match", "Match moyen", "Faible match"

**Amélioration carte** : `components/candidates/candidate-card.tsx`
- Badge score en coin supérieur droit (toujours visible)
- Hover preview : vidéo présentation joue dans l'avatar (muted, loop)
- Fallback intelligent : thumbnail → photo → initiale
- Layout optimisé : transitions fluides, hover effects

**Page candidats** : `app/(dashboard)/candidates/page.tsx`
- Chargement `recruiter.locations` pour scoring
- Calcul score pour chaque candidat
- Tri par score décroissant
- Type `CandidateWithScore` = `CandidateWithProfile & { matchScore: number }`

---

### Phase 2 : Modal 60/40 + Tabs — DONE

**Composant Shadcn** : `components/ui/tabs.tsx` (installé via CLI)

**Refacto modal** : `components/candidates/candidate-modal.tsx`

**Layout 60/40** :
- **Gauche (60%)** : vidéo plein écran (autoplay, controls, object-contain)
- **Droite (40%)** : panneau infos avec header + tabs

**Header modal** :
- Photo + nom + @username
- Badges : score matching (coloré), âge, ville

**3 onglets** :
1. **Profil** : formation (école, niveau), domaine (secteur, spécialité), candidature (offre, date, statut), score détaillé
2. **Évaluer** : notes privées (Textarea), actions (contacter/non intéressé), tags (à venir)
3. **Messages** : placeholder conversation (à implémenter)

**Bouton Contacter** :
- Visible onglet "Évaluer" si status = "pending"
- Crée conversation + marque application "contacted"
- Si déjà contacté : affiche bouton "Voir la conversation"

---

### Phase 3 : Filtres Avancés — DONE

**Composant filtres** : `components/candidates/candidate-filters.tsx` (nouveau)

**Sidebar filtres** (sidebar fixe 256px, scroll indépendant) :
1. **Statut** (Select) : Tous / En attente / Contactés
2. **Offre** (Select) : Toutes / Liste des offres du recruteur
3. **Secteur** (Select) : Tous / 15 secteurs
4. **Score matching** (3 badges cliquables) :
   - Excellent (>80%)
   - Bon (60-80%)
   - Faible (<60%)
5. **Bouton Réinitialiser** (visible si filtre actif)

**Logique filtrage** : `app/(dashboard)/candidates/page.tsx`
- État `CandidateFilters` : `{ status, offerId, sector, scoreRange }`
- Filtrage client-side (useEffect sur `[candidates, filters]`)
- Compteur dynamique : "X candidat(s)"
- Empty state adaptatif : "Aucun candidat" vs "Modifiez vos filtres"

**Layout page** :
- Flex horizontal : sidebar (w-64) + main content (flex-1)
- Main content : header (titre + compteur) + grid responsive
- Grid : 4 cols 2xl, 3 cols lg, 2 cols sm, 1 col mobile

---

### Phase 4 : Raccourcis Clavier — DONE

**Hook custom** : `hooks/use-keyboard-shortcuts.ts` (nouveau)

Signature :
```ts
useKeyboardShortcuts(
  shortcuts: Record<string, () => void>,
  enabled: boolean
)
```

Protection :
- Ignore si typing dans input/textarea
- Active uniquement si `enabled = true`

**Intégration modal** : `candidate-modal.tsx`
- **Espace** : pause/play vidéo (videoRef.current.paused toggle)
- **Escape** : fermer modal
- **C** : contacter candidat (si status = pending + !contacting)

Ref vidéo : `useRef<HTMLVideoElement>()` attaché au `<video>`

---

### Fichiers impactés (7)

**Nouveaux (4)** :
- `saas-etoile/lib/scoring.ts` — algorithme matching
- `saas-etoile/components/candidates/candidate-filters.tsx` — sidebar filtres
- `saas-etoile/hooks/use-keyboard-shortcuts.ts` — hook raccourcis
- `saas-etoile/components/ui/tabs.tsx` — Shadcn tabs

**Modifiés (3)** :
- `saas-etoile/components/candidates/candidate-card.tsx` — score badge + hover preview
- `saas-etoile/components/candidates/candidate-modal.tsx` — layout 60/40 + tabs + shortcuts
- `saas-etoile/app/(dashboard)/candidates/page.tsx` — sidebar + filtres + scoring

---

### Tests manuels réalisés
- ✅ Build Next.js : 0 erreurs TypeScript, 0 warnings critiques
- ⏳ Score affiché sur chaque carte (badge coloré)
- ⏳ Hover carte → vidéo preview joue
- ⏳ Clic carte → modal 60/40 s'ouvre
- ⏳ Modal : 3 onglets fonctionnels
- ⏳ Filtres sidebar : status, offre, secteur, score
- ⏳ Raccourcis : Espace (pause/play), Esc (fermer), C (contacter)
- ⏳ Grille responsive : 4 → 3 → 2 → 1 colonnes

---

## Ce qui a ete fait — Epic 13 : Dashboard Briefing (2026-04-25)

### Objectif
Donner au recruteur une vue quotidienne de son activité : nouvelles candidatures depuis dernière connexion, KPIs globaux (taux de réponse, taux de shortlist, top offres), funnel de conversion.

### Migrations SQL (2) — DONE

**1. `20260425000001_add_last_login_at.sql`**
- Ajout colonne `last_login_at TIMESTAMPTZ` sur `user_roles`
- Index conditionnel sur `role = 'recruiter'`
- Tracking silencieux dans `middleware.ts` (ligne 36-47)

**2. `20260425000002_create_kpi_functions.sql`**
- 3 fonctions PostgreSQL :
  - `calculate_avg_response_time(recruiter_id)` : délai moyen entre candidature et premier message
  - `calculate_shortlist_rate(recruiter_id)` : % candidats contactés
  - `get_top_performing_offers(recruiter_id)` : top 5 offres par nombre de candidatures
- Pattern Epic 13 : PostgreSQL Functions > Edge Functions (performance)

### Composants créés (3) — DONE

**1. `components/dashboard/daily-briefing.tsx`** (Client Component)
- Compteur nouvelles candidatures depuis `last_login_at`
- Polling 60s (setInterval) pour mise à jour temps réel
- Badge rouge si `newCount > 0`
- Server Action : `getNewApplicationsCount()`

**2. `components/dashboard/global-kpis.tsx`** (Server Component)
- 3 cartes KPI : délai réponse moyen, taux shortlist, top offres
- Icons : Clock, Target, TrendingUp
- Cache 5 min via `revalidate = 300`

**3. `components/dashboard/conversion-funnel.tsx`** (Client Component)
- BarChart Recharts horizontal (3 étapes)
- Couleurs : pending (#C8A84B or), contacted (#2D6A4F vert), withdrawn (#9B2335 bordeaux)
- Data : compteurs agrégés par status

### Server Actions — DONE

**Fichier** : `app/(dashboard)/dashboard/actions.ts`

- `getAverageResponseTime()` : appelle fonction PostgreSQL
- `getShortlistRate()` : appelle fonction PostgreSQL
- `getTopPerformingOffers()` : appelle fonction PostgreSQL
- `getConversionFunnelData()` : agrège compteurs par status
- `getNewApplicationsCount()` : compte candidatures > last_login_at

### Page Dashboard refacto — DONE

**Fichier** : `app/(dashboard)/dashboard/page.tsx`
- Converti en Server Component (cache 5 min)
- Fetch `company_name` pour message de bienvenue
- Intégration 3 composants Epic 13 :
  - `<DailyBriefing />` (Client, polling)
  - `<GlobalKpis />` (Server, cache)
  - `<ConversionFunnel data={funnelData} />` (Client)
- Quick actions (boutons "Publier offre" + "Voir candidats")

### Résultats

- ✅ 2 migrations déployées (last_login_at + 3 fonctions PostgreSQL)
- ✅ Build Next.js OK (0 erreurs TypeScript)
- ✅ Middleware tracking silencieux (async IIFE, pas de blocage navigation)
- ✅ Pattern PostgreSQL Functions validé (cohérence Epic 13/14)

---

## Ce qui a ete fait — Epic 14 : Scoring PostgreSQL + Persistance (2026-04-25)

### Objectif
Déplacer le calcul de scoring côté PostgreSQL (vs client-side), persister les scores dans une table dédiée, invalidation automatique via trigger quand profil seeker change.

### Architecture (Winston)

**Document** : `_bmad-output/architecture-epic-14-scoring.md` (~550 lignes)

**5 décisions architecturales critiques** :
1. **Table schema** : cache invalidation (colonne `computed_at` pour staleness Phase 2)
2. **Fonction PostgreSQL** : buckets études + fuzzy ville + STABLE
3. **Trigger auto-update** : DELETE lazy (pas de recalcul immédiat)
4. **RLS policies** : SELECT + DELETE + INSERT + UPDATE (least privilege)
5. **Staleness management** : YAGNI MVP (pas de TTL)

### Migrations SQL (2) — DONE

**1. `20260425000003_create_match_scores.sql`**
- Table `match_scores` (5 colonnes : id, seeker_id, video_id, score, computed_at)
- UNIQUE constraint `(seeker_id, video_id)`
- 2 indexes : composite `(video_id, score DESC)` + `computed_at`
- Fonction `calculate_match_score(p_seeker_id, p_video_id)` :
  - Algorithme : secteur(30%) + études(25%) + ville(25%) + spécialité(20%)
  - Cohérent avec `lib/scoring.ts` client-side
  - Buckets études : bac+2+ = 25, bac/bac+1 = 15, cap/bep = 5
  - Fuzzy ville : `LIKE '%...%'` bidirectionnel
  - Spécialité MVP : 20pts si rempli (fuzzy matching Phase 2)
- Trigger `trigger_seeker_profile_change` :
  - AFTER UPDATE sur `seeker_profiles`
  - Track 4 champs : `domain`, `city`, `study_level`, `specialty`
  - DELETE lazy : supprime scores du seeker (recalcul à la demande)
- RLS policies initiales : SELECT + DELETE only

**2. `20260425000004_fix_match_scores_rls.sql`** (bugfix)
- Ajout policies INSERT + UPDATE
- Nécessaire pour Server Action `calculateAndStoreMatchScore()`
- Erreur détectée : code `42501` (RLS violation)

### Types & Server Actions — DONE

**Type** : `lib/types/database.ts`
- Interface `MatchScore` : id, seeker_id, video_id, score, computed_at

**Server Actions** : `app/(dashboard)/candidates/actions.ts`
- `getMatchScoresForOffer(videoId)` : fetch scores triés DESC
- `calculateAndStoreMatchScore(seekerId, videoId)` : calcul + upsert via PostgreSQL function

### Intégration grille candidats — DONE

**Fichier** : `app/(dashboard)/candidates/page.tsx`

**Optimisations** :
- Préchargement batch des scores (1 query pour tous les candidats)
- Map pour lookup O(1) : `scoresMap.get(${seekerId}_${videoId})`
- Fallback gracieux : PostgreSQL function → calcul client si échec
- Tri existant conservé (ligne 115, client-side)

**Pattern** :
```ts
// Load all scores in batch
const { data: existingScores } = await supabase
  .from("match_scores")
  .select("seeker_id, video_id, score")
  .in("video_id", offerIds);

// If score missing, calculate and store
if (matchScore === undefined) {
  matchScore = await calculateAndStoreMatchScore(seekerId, videoId);
}
```

### Résultats

- ✅ 2 migrations déployées (table + fonction + trigger + RLS fix)
- ✅ Type TypeScript ajouté
- ✅ 2 Server Actions créées
- ✅ Intégration grille sans régression
- ✅ Build Next.js OK (0 erreurs)
- ⚠️ RLS fix nécessaire (policies INSERT/UPDATE manquantes initialement)

### Tests de validation

**SQL tests** :
```sql
-- Test fonction
SELECT calculate_match_score(
  (SELECT user_id FROM seeker_profiles LIMIT 1),
  (SELECT id FROM videos WHERE type = 'offer' LIMIT 1)
);

-- Vérifier trigger
UPDATE seeker_profiles SET domain = 'commerce_vente' WHERE user_id = '...';
SELECT COUNT(*) FROM match_scores WHERE seeker_id = '...'; -- Devrait être 0
```

---

### Prochaines étapes

**Track 1 (Mobile)** :
- Store listing restant (screenshots, description)
- Soumission Apple App Store + Google Play Store

**Track 2 (SaaS)** :
- ~~Epic 13 : Dashboard briefing~~ ✅ DONE
- ~~Epic 14 : Scoring PostgreSQL~~ ✅ DONE
- **Epic 15 : Messagerie temps réel** ← PROCHAIN
- Epic 16 : Settings + abonnement Stripe

**Phase 5 Epic 12 (reporté V2)** :
- Tables évaluations (`candidate_evaluations`, `candidate_tags`)
- Persistance notes + tags

**Améliorations futures** :
- Navigation candidats dans modal (← → pour prev/next)
- Recherche par @username
- Export liste candidats (CSV)
- Fuzzy matching spécialités (score +20% affiné)
- Filtre ville (autocomplete Photon)
- Onglet Messages intégré (inline chat)
- Shortlist/favoris (badge étoile)

**Epic 13 (Dashboard briefing)** — NEXT
- Compteur "Candidats forte compatibilité (>80%)"
- Graphique évolution candidatures
- Quick actions dashboard

---

## Corrections UX Epic 12 (2026-04-23)

### Problèmes identifiés et résolus

**1. Erreur React Hooks**
- **Problème** : "React has detected a change in the order of Hooks" dans CandidateModal
- **Cause** : `if (!candidate) return null;` appelé AVANT `useKeyboardShortcuts`
- **Solution** : Déplacé tous les hooks (useState, useRef, useKeyboardShortcuts) AVANT le early return
- **Fichier** : `components/candidates/candidate-modal.tsx`

**2. Modal trop petit**
- **Problème** : Fenêtre modale illisible, texte trop petit
- **Cause** : DialogContent Shadcn par défaut = `sm:max-w-sm` (très petit)
- **Solution** :
  - Taille forcée `!max-w-[96vw] !h-[92vh] !w-[96vw]` (important override)
  - Bouton close custom (showCloseButton={false})
  - Modal occupe maintenant 96% de l'écran
- **Fichier** : `components/candidates/candidate-modal.tsx`

**3. Vidéo non visible entièrement**
- **Problème** : Vidéo coupée, scroll nécessaire
- **Cause** : `w-full h-full` forçait la vidéo à dépasser le conteneur
- **Solution** :
  - `max-w-full max-h-full` au lieu de `w-full h-full`
  - `object-contain` pour respecter ratio
  - Padding `p-6` autour de la vidéo
  - Coins arrondis `rounded-lg`
- **Fichier** : `components/candidates/candidate-modal.tsx`

**4. Texte illisible**
- **Problème** : Texte trop petit (text-xs, text-sm partout)
- **Solution** : Tailles augmentées globalement
  - Header : photo 14→16, nom text-lg→text-xl, username text-xs→text-sm
  - Tabs : h-12, text-base
  - Labels : text-xs→text-sm
  - Valeurs : text-sm→text-base + font-medium
  - Badges : text-xs→text-sm + px-3 py-1
  - Boutons : text-base + h-11
  - Score : text-2xl→text-3xl
  - Padding global : p-4→p-6
- **Fichier** : `components/candidates/candidate-modal.tsx`

**5. Layout modal déséquilibré**
- **Problème** : Vidéo 60% / Panneau 40% = déséquilibre visuel
- **Solution** :
  - **50/50** au lieu de 60/40
  - `shrink-0` sur les deux colonnes
  - `w-1/2` pour équilibre parfait
  - Vidéo toujours visible à gauche, panneau scroll indépendant à droite
- **Fichier** : `components/candidates/candidate-modal.tsx`

**6. Onglets modal disparaissent au scroll**
- **Problème** : Tabs (Profil/Évaluer/Messages) disparaissent quand on scroll
- **Solution** :
  - `sticky top-0 z-10` sur TabsList
  - `bg-background` pour fond opaque
  - `border-b` pour séparation visuelle
  - Tabs restent collés en haut pendant le scroll
- **Fichier** : `components/candidates/candidate-modal.tsx`

**7. Sidebar navigation cachée**
- **Problème** : Sidebar principale (Dashboard/Candidats/Offres) parfois cachée sur page candidats
- **Cause** : Layout page candidats avec `h-[calc(100vh-4rem)]` créait conflit
- **Solution** :
  - `-m-8` pour annuler padding du main
  - `h-[calc(100vh-5rem)]` ajusté pour header
  - Header "Candidats" en sticky `top-0`
  - `gap-6` entre sidebar filtres et contenu
  - Layout qui s'intègre au dashboard sans conflit
- **Fichier** : `app/(dashboard)/candidates/page.tsx`

---

### Résumé des fichiers modifiés (corrections UX)

**2 fichiers impactés** :
1. `components/candidates/candidate-modal.tsx` — 6 corrections (hooks, taille, vidéo, texte, layout, tabs sticky)
2. `app/(dashboard)/candidates/page.tsx` — 1 correction (sidebar navigation)

---

### Tests manuels validés
- ✅ Aucune erreur React Hooks
- ✅ Modal occupe 96% de l'écran (lisible)
- ✅ Vidéo visible entièrement sans scroll
- ✅ Texte lisible (tailles augmentées)
- ✅ Layout 50/50 équilibré
- ✅ Onglets modal restent visibles (sticky)
- ✅ Sidebar navigation toujours visible
- ✅ Header "Candidats" sticky pendant scroll
- ✅ Build Next.js : 0 erreurs

---

## Ce qui a ete fait — Sprint 31 : Ouverture France + 15 secteurs + GPS proximite (2026-04-20)

### Objectif
Passer de la beta IdF (2 secteurs) a la France entiere (15 secteurs) avec filtre de proximite GPS.

### Expansion des secteurs (2 → 15) — DONE
- `sector_constants.dart` : 15 secteurs + ~55 specialites + labels complets
- `saas-etoile/lib/constants/sectors.ts` : miroir TypeScript identique (70 codes, parite verifiee)
- Feed : nouveau **picker secteur searchable** (bottom sheet avec barre de recherche) au lieu de 2 chips
- Filtres specialites dynamiques : chips s'adaptent au secteur selectionne

### Ouverture geographique IdF → France metropolitaine — DONE
- `city_autocomplete_field.dart` : bbox `1.44,48.12,3.56,49.24` → `-5.14,41.33,9.56,51.09`
- `search_page.dart` : suppression bloc "Ile-de-France / Zone beta"
- `edit_seeker_profile_page.dart` : suppression label "Ile-de-France uniquement"
- Callback ville enrichi : `onCitySelected(city, lat, lng)` — extrait coords GeoJSON Photon

### Coordonnees GPS sur les profils — DONE
- Migration SQL `20260419000000_add_coordinates.sql` : `latitude`/`longitude` sur `recruiter_profiles` + `seeker_profiles` + index conditionnel
- `seeker_profile_model.dart` + `recruiter_profile_model.dart` : +`latitude`/`longitude` (fromJson/toJson/copyWith/props)
- `database.ts` (SaaS) : miroir TypeScript
- `edit_seeker_profile_page.dart` : sauvegarde lat/lng au choix de ville

### Filtre de proximite GPS dans le feed — DONE
- `feed_item_model.dart` : +`latitude`/`longitude` sur `FeedItem`, +`proximityKm`/`userLatitude`/`userLongitude` sur `FeedFilters`
- `feed_repository.dart` : +`haversineDistance()` (Haversine formula), filtre proximite dans `_applySeekerFilters()`
- `feed_page.dart` : section "A proximite" dans les filtres (chips 5/10/15/25/50 km)
- Package `geolocator: ^13.0.2` pour position GPS utilisateur
- `AndroidManifest.xml` : +`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- `Info.plist` : +`NSLocationWhenInUseUsageDescription`

### Splash screen redesign — DONE
- Fond blanc au lieu de gradient sombre, "Etoile" (minuscules) au lieu de "ETOILE"
- Suppression tagline "Recrutement par video"
- Animation simplifiee (fade 800ms, loading orange)

### Tests — DONE
- **Nouveau** : `test/features/feed/data/feed_proximity_test.dart` — 12 tests
  - Haversine : Paris-Lyon ~392km, Paris-Creteil ~11km, Paris-Marseille ~661km, point identique = 0
  - FeedFilters : hasFilters, copyWith proximite, clear, empty
  - FeedItem : coords, null coords, equality
- `widget_test.dart` : adapte pour "Etoile" au lieu de "ETOILE"

### Resultats
- **85/85 tests pass** (73 + 12 nouveaux), 0 issues flutter analyze
- Build Next.js OK
- Migration deployee (23/23 total)

---

## Ce qui a ete fait — Epic 10 Phase 2 : Profil Recruteur Complet (SaaS) (2026-05-01 → 2026-05-02)

### Objectif
Finaliser le profil recruteur SaaS avec photo, page Settings complète, et preview format mobile pour validation des offres avant publication.

### Contexte
Après les Epics 11-15 (Publication, Grille candidats, Dashboard, Scoring, Messagerie), il manquait 3 fonctionnalités pour compléter l'expérience recruteur :
1. **Photo de profil** — humaniser le compte (actuellement seulement logo entreprise)
2. **Page Settings** — modification profil complet (nom, secteur, description, adresse, documents)
3. **Preview mobile** — voir le rendu de l'offre côté chercheur avant publication

### Architecture complète — DONE
**Document** : `_bmad-output/architecture-epic-10-phase-2.md` (~600 lignes)
- Décisions techniques : R2 bucket `etoile-photos`, react-easy-crop, AddressAutocomplete
- Patterns : uploadFile.ts générique (3 buckets), RecruiterAvatar component (3 tailles)
- 10 fichiers mappés : 8 nouveaux + 2 modifiés

### Story 10.6 : Photo profil recruteur — DONE (2026-05-01)

**Objectif** : Permettre au recruteur d'uploader une photo de profil (distinct du logo entreprise).

**Migration SQL** : `20260501000001_add_recruiter_photo.sql`
- Colonne `recruiter_profiles.photo_url TEXT` (nullable)
- Commentaire : "URL photo profil recruteur (personne physique, distinct du logo)"

**Composants créés** (2) :
1. **PhotoUploadSection** — `components/settings/PhotoUploadSection.tsx`
   - Upload image + crop circulaire (react-easy-crop)
   - Preview instantané (MemoryImage → Canvas)
   - Validation 5 Mo max, formats JPEG/PNG/WebP
   - Upload R2 bucket `etoile-photos` via `uploadFile.ts`

2. **RecruiterAvatar** — `components/settings/RecruiterAvatar.tsx`
   - Affichage avatar avec 3 tailles : sm (48px), md (80px), lg (200px)
   - Fallback intelligent : photo → initiale nom entreprise
   - Pattern cohérent avec avatar chercheur mobile

**Server Action** : `app/(dashboard)/settings/actions.ts`
- `updateRecruiterPhoto(photoUrl)` — UPDATE avec RLS policy

**Résultats** :
- ✅ Build Next.js OK (0 erreurs TypeScript)
- ✅ Crop fonctionnel (zoom + rotation)
- ✅ Avatar affiché dans sidebar (taille md)

---

### Story 10.7 : Preview format mobile — DONE (2026-05-01)

**Objectif** : Afficher un aperçu du rendu mobile de l'offre (9:16) avant publication, validant que la vidéo/poster est bien formatée.

**Constantes hard-codées** : `lib/constants/mobile-preview.ts`
- Device dimensions : 375×667 (iPhone SE 2020, ratio 9:16)
- Feed card : 375×667 plein écran
- Header height : 60px
- Action buttons : 52px width, 8px gap
- Mirroir exact du FeedVideoPlayer Flutter

**Composant créé** : `components/offers/MobilePreview.tsx`
- Toggle 9:16 / 16:9 (boutons ratio en haut à droite)
- Validation aspect ratio : affiche badge vert (9:16 ±5%) ou warning (autre ratio)
- Preview temps réel : vidéo ou image, infos offre (titre, entreprise, secteur, contrat)
- Icônes actions (play, like, share, apply) — non fonctionnelles, juste visuel

**Intégration page `/offers/new`** : `app/(dashboard)/offers/new/page.tsx`
- Layout 2 colonnes responsive : formulaire (gauche) + preview sticky (droite)
- Largeur max dynamique : 2xl pour steps 1-2, 6xl pour step 3 (form + preview)
- Preview en temps réel : mise à jour automatique quand titre/secteur/contrat changent

**Résultats** :
- ✅ Preview fidèle au rendu mobile (9:16, header, actions)
- ✅ Validation ratio automatique (badge coloré)
- ✅ Toggle fonctionnel (9:16 ↔ 16:9)

---

### Story 10.8 : Page Settings complète — DONE (2026-05-02)

**Objectif** : Créer la page Settings pour modification complète du profil recruteur (photo, entreprise, description, adresse, SIRET, documents).

**Migration SQL** : `20260502000002_add_recruiter_address.sql`
- Colonne `recruiter_profiles.address TEXT` (adresse complète entreprise)
- Remplace l'ancien champ `locations: string[]` (multi-villes) qui ne servait à rien

**Composants Shadcn installés** (4) :
- form, label, textarea, select

**Zod schema** : `lib/validations/recruiter-settings.ts`
- 7 champs validés : photo_url, company_name, sector, description (min 50 chars), address (min 10 chars), siret, document_url

**Composants créés** (4) :
1. **ProfileProgressBar** — `components/settings/ProfileProgressBar.tsx`
   - Barre progression dynamique (0-100%)
   - Couleurs : vert (100%), jaune (60-99%), rouge (<60%)
   - Sticky top, calcul temps réel via `watch()` form

2. **AddressAutocomplete** — `components/ui/address-autocomplete.tsx`
   - API Adresse gouvernement français (api-adresse.data.gouv.fr)
   - Debounce 400ms, min 3 caractères
   - Dropdown suggestions avec icône MapPin
   - Pattern miroir du `CityAutocompleteField` Flutter

3. **DocumentUploadSection** — `components/settings/DocumentUploadSection.tsx`
   - Upload PDF/JPG/PNG (max 5 Mo)
   - Storage R2 bucket `verification-docs`
   - Status badges (vérifié/en attente/rejeté)
   - Re-upload possible si statut = rejected

4. **PhotoUploadSection** — réutilisé depuis Story 10.6

**Fonction calcul complétude** : `lib/utils/profile-completion.ts`
- 5 catégories × 20% = 100% :
  1. Inscription (20%) : toujours 20% (compte créé)
  2. Entreprise + secteur (20%) : company_name && sector
  3. Description (20%) : description ≥ 50 caractères
  4. Adresse (20%) : address ≥ 10 caractères (modifié suite feedback user)
  5. SIRET + document (20%) : siret && document_url

**Server Action** : `app/(dashboard)/settings/actions.ts`
- `updateRecruiterProfile(data)` — double validation Zod (client + serveur)
- RLS policy enforce `user_id = auth.uid()`
- **SIRET read-only** — intentionnellement exclu de l'UPDATE (sécurité fraude)

**Page Settings** : `app/(dashboard)/settings/page.tsx` (400+ lignes)
- Single-scroll form (1 formulaire, 7 sections)
- React Hook Form + Zod resolver
- Progress bar en Card en haut (Option A après feedback user)
- 7 sections dans Cards séparées :
  1. Photo de profil (PhotoUploadSection)
  2. Informations entreprise (Input company_name + Select secteur)
  3. Description (Textarea min 50 chars)
  4. Adresse complète (AddressAutocomplete)
  5. SIRET (Input disabled, affichage status vérification)
  6. Document justificatif (DocumentUploadSection)
  7. Bouton "Enregistrer" en bas

**Feedback utilisateur appliqué** (4 corrections) :
1. ❌ **Localisation inutile** : champ `locations: string[]` supprimé, remplacé par `address: string`
2. ❌ **Progress bar mal intégrée** : déplacée dans Card dédiée en haut (Option A)
3. ❌ **Documents justificatifs pas clair** : composant DocumentUploadSection créé avec upload complet
4. 🆕 **Address autocomplete** : API Adresse gouvernement intégrée (comme sur app mobile)

**uploadFile.ts générique** — modifié pour supporter 3 buckets :
- `etoile-videos` (vidéos offres, max 50 Mo)
- `etoile-photos` (photos profil, max 5 Mo)
- `verification-docs` (documents Kbis/carte pro, max 5 Mo, PDF/JPG/PNG)

**Résultats** :
- ✅ Build Next.js OK (0 erreurs TypeScript)
- ✅ Formulaire complet avec 7 sections
- ✅ Autocomplete adresse fonctionnel (API gouv)
- ✅ Upload documents fonctionnel (R2)
- ✅ Progress bar temps réel (useMemo + watch)
- ✅ Toast feedback (MVP console.log)
- ✅ Lien Settings déjà présent dans sidebar

---

### Récapitulatif Epic 10 Phase 2

**3 stories complétées** :
- ✅ Story 10.6 : Photo profil recruteur
- ✅ Story 10.7 : Preview format mobile
- ✅ Story 10.8 : Page Settings complète

**Fichiers créés** (11) :
- `supabase/migrations/20260501000001_add_recruiter_photo.sql`
- `supabase/migrations/20260502000002_add_recruiter_address.sql`
- `saas-etoile/lib/validations/recruiter-settings.ts`
- `saas-etoile/lib/utils/profile-completion.ts`
- `saas-etoile/lib/constants/mobile-preview.ts`
- `saas-etoile/lib/uploadFile.ts` (générique)
- `saas-etoile/components/settings/PhotoUploadSection.tsx`
- `saas-etoile/components/settings/RecruiterAvatar.tsx`
- `saas-etoile/components/settings/ProfileProgressBar.tsx`
- `saas-etoile/components/settings/DocumentUploadSection.tsx`
- `saas-etoile/components/ui/address-autocomplete.tsx`
- `saas-etoile/components/offers/MobilePreview.tsx`
- `saas-etoile/components/ui/form.tsx` (manual, Shadcn registry error)
- `saas-etoile/hooks/use-toast.ts` (MVP console.log)

**Fichiers modifiés** (4) :
- `saas-etoile/app/(dashboard)/settings/page.tsx` — rewrite complet (7 sections)
- `saas-etoile/app/(dashboard)/settings/actions.ts` — +updateRecruiterProfile
- `saas-etoile/app/(dashboard)/offers/new/page.tsx` — intégration MobilePreview
- `saas-etoile/lib/types/database.ts` — +photo_url, +address

**Total** : 15 nouveaux fichiers, 4 modifiés, 2 migrations SQL déployées

**Tests** : Build Next.js successful (0 erreurs TypeScript)

---

## Pour reprendre

```bash
# App mobile (Flutter)
cd C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app\flutter_application_1
flutter run -d edge

# SaaS web (Next.js)
cd C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app\saas-etoile
npm run dev          # http://localhost:3000
npm run build        # verif build prod
```

Puis tape `/bmad` et dis : **"reprend la ou on s'est arrete"**

### Prochaine session SaaS — quoi faire
1. **Migrations DB** : creer ~5 nouvelles tables (`candidate_evaluations`, `candidate_tags`, `evaluation_tags`, `team_shares`, `match_scores`) + RLS
2. **Publication offres (Epic 11)** : page creation d'offre recruteur — c'est le maillon manquant qui debloque tout le flux (offre → candidature chercheur → grille recruteur)
3. **Grille candidats (Epic 12)** : miniatures video, hover preview, score matching, modal decision
4. **Dashboard briefing (Epic 13)** : nouvelles candidatures, messages non lus, KPIs

**Reference brainstorming** : `saas-etoile/brainstorming-architecture-saas.md` (47 idees, decisions techniques, roadmap)

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

## Ce qui a ete fait — Sprint SaaS-1 : Init projet Next.js recruteurs (2026-04-14)

### Objectif
Scaffold fonctionnel du SaaS web recruteur avec auth (login + register + OTP) + layout dashboard + connexion Supabase. Fondation sans features metier.

### Setup — DONE
- **Scaffold** : Next.js 16 + TypeScript + Tailwind v4 + ESLint + App Router
- **Dependances** : `@supabase/supabase-js`, `@supabase/ssr`, 6 composants Shadcn/ui (button, input, label, card, separator, sonner)
- **Theme Etoile** : palette couleurs complete miroir `app_colors.dart` (jaune #FFB800, orange #FF8C00, neutres, semantiques)
- **Supabase SSR** : `lib/supabase/client.ts` (browser), `lib/supabase/server.ts` (server), `middleware.ts` (session refresh + route protection), `app/auth/callback/route.ts`
- **.env.local** : NEXT_PUBLIC_SUPABASE_URL + NEXT_PUBLIC_SUPABASE_ANON_KEY (gitignore, pas commite)

### Types & Constantes — DONE
- `lib/types/database.ts` : interfaces TypeScript `RecruiterProfile`, `SeekerProfile`, `UserRole` (miroir modeles Dart)
- `lib/constants/sectors.ts` : secteurs, specialites, niveaux etudes (miroir `sector_constants.dart`)
- `lib/constants/routes.ts` : paths constants (/login, /register, /dashboard, etc.)

### Layouts — DONE
- **Root** (`app/layout.tsx`) : Font Inter, `<html lang="fr">`, metadata "Etoile Recruteurs", Toaster
- **Auth** (`app/(auth)/layout.tsx`) : centrage vertical, logo E, pas de sidebar
- **Dashboard** (`app/(dashboard)/layout.tsx`) : sidebar 240px (5 nav items + deconnexion) + header titre dynamique

### Pages — DONE
- **Landing** (`/`) : hero "Recrutez vos alternants par la video", 3 features, CTAs
- **Login** (`/login`) : email + mdp, `signInWithPassword()`, erreurs FR
- **Register** (`/register`) : entreprise + email + SIRET 14 chiffres (filtre digits) + mdp + confirmer + CGU, `signUp()` avec metadata `role: "recruiter"`
- **OTP** (`/verify`) : 6 inputs, auto-focus, paste support, auto-submit, timer resend 60s, `verifyOtp()`, Suspense boundary
- **Dashboard** (`/dashboard`) : "Bonjour {entreprise}", 3 cards placeholder (Candidatures 0, Messages 0, Offres 0)
- **Deconnexion** : sidebar → `signOut()` + redirect `/login`

### Resultats
- **Build production OK** : `npm run build` sans erreur, 0 erreur TypeScript
- **Flutter** : 73/73 tests, 0 issues analyze (pas de regression)
- Warning : Next.js 16 deprecie `middleware.ts` au profit de `proxy` — fonctionnel, migration optionnelle

### Structure fichiers (39 fichiers commites)
```
saas-etoile/
├── .env.local (gitignore) / .env.example (commite)
├── middleware.ts
├── lib/supabase/{client,server}.ts
├── lib/types/database.ts
├── lib/constants/{sectors,routes}.ts
├── components/layout/{sidebar,header}.tsx
├── components/ui/{button,input,label,card,separator,sonner}.tsx
├── app/layout.tsx, page.tsx (landing)
├── app/(auth)/{login,register,verify}/page.tsx
├── app/(dashboard)/dashboard/page.tsx
└── app/auth/callback/route.ts
```

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
| **SaaS-1** | **Init Next.js recruteurs — auth + layout + dashboard placeholder** | **DONE** |
| **31** | **Ouverture France + 15 secteurs + GPS proximite + splash redesign** | **DONE** |
| **SaaS-2** | **Publication offres — wizard upload, liste, edit/delete, dashboard compteurs** | **DONE** |
| **Epic 12** | **Grille candidats — scoring client-side, modal 50/50, filtres, raccourcis clavier** | **DONE** |
| **Epic 13** | **Dashboard briefing — KPIs PostgreSQL, polling 60s, funnel conversion** | **DONE** |
| **Epic 14** | **Scoring PostgreSQL — table match_scores, fonction, trigger, RLS, integration grille** | **DONE** |
| **Epic 15** | **Messagerie temps réel — conversations synchronisées, contacter depuis modal, Supabase Realtime** | **DONE** |

### Prochains sprints

**Track 1 : App Mobile (Chercheur only)**
- [x] ~~Nettoyer/masquer le code recruteur dans l'app Flutter~~
- [x] ~~Ajouter champ username (@pseudo) dans le profil chercheur~~
- [x] ~~Nettoyage DB : tables/colonnes/fichiers inutilises~~
- [x] Story 13.1 : Camera in-app DONE
- [x] Ouverture France + 15 secteurs + GPS proximite (Sprint 31) DONE
- [ ] Preparation store (screenshots, description, soumission)

**Track 2 : SaaS Web (Recruteur)**
- [x] ~~Init projet Next.js + Tailwind + Shadcn/ui + Supabase~~ — **DONE** (Sprint SaaS-1)
- [x] ~~Publication offres (Epic 11)~~ — **DONE** (Sprint SaaS-2)
- [x] ~~Grille candidats (Epic 12)~~ — **DONE** (scoring client-side, modal 50/50, filtres, raccourcis)
- [x] ~~Dashboard briefing (Epic 13)~~ — **DONE** (KPIs PostgreSQL, polling 60s, funnel)
- [x] ~~Scoring PostgreSQL (Epic 14)~~ — **DONE** (match_scores + fonction + trigger + RLS)
- [x] ~~Messagerie temps reel (Epic 15)~~ — **DONE** (conversations synchronisees, contacter depuis modal, Realtime)
- [ ] **Features profil recruteur** — photo profil, vidéo présentation entreprise, preview offre format mobile ← **PROCHAIN**
- [ ] Integration & Tests (Playwright)
- [ ] Beta recruteurs (5-10 invites)

**Infra**
- ~~Deployer migrations SQL~~ — **FAIT** (27/27 synchronisees, Epic 13: 2, Epic 14: 2)
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

---

## Nouvelles Features Demandées (2026-04-30)

### Epic 16 : Profil Recruteur Complet

**Objectifs** :
1. **Photo de profil recruteur** — upload + crop + stockage R2 + affichage dans app mobile
2. **Vidéo présentation entreprise** — upload vidéo (max 60s) pour présenter l'entreprise aux chercheurs
3. **Preview offre format mobile** — lors de la publication d'affiche/vidéo, preview redimensionné exactement comme dans l'app mobile
4. **Modification profil** — page /settings avec formulaire complet (nom entreprise, secteur, description, photo, vidéo)

**Justification** :
- App mobile chercheur affiche déjà profil recruteur (entreprise, secteur) mais sans photo ni vidéo
- Transparence : chercheur doit savoir explicitement à qui il s'adresse
- Preview format mobile : recruteur doit voir exactement comment son offre apparaît aux chercheurs

**Tables DB impactées** :
- `recruiter_profiles.photo_url` (nouvelle colonne TEXT nullable)
- `recruiter_profiles.presentation_video_id` (nouvelle colonne UUID nullable, FK videos)
- `videos` table déjà prête (type='recruiter_presentation')

**Prochaine étape** :
→ Comparer features app mobile vs SaaS (voir ci-dessous)
→ Décider si PRD doit être mis à jour ou si c'est une évolution naturelle

---

## Comparaison Features App Mobile vs SaaS

**Besoin** : Analyser ce que l'app mobile a déjà vs ce que le SaaS doit avoir pour assurer cohérence UX.

| Feature | App Mobile (Chercheur) | SaaS Web (Recruteur) | Gap Identifié |
|---------|------------------------|----------------------|---------------|
| **Profil photo** | ✅ Seeker upload photo | ❌ Recruteur pas de photo | **GAP** — Ajouter upload photo recruteur |
| **Vidéo présentation** | ✅ Seeker vidéo 40s (type=presentation) | ❌ Recruteur pas de vidéo entreprise | **GAP** — Ajouter vidéo présentation entreprise |
| **Preview offre** | ✅ Feed vertical TikTok | ❌ Upload direct sans preview format mobile | **GAP** — Ajouter preview redimensionné lors publication |
| **Messagerie** | ✅ Chat temps réel (Flutter) | ✅ Chat temps réel (Next.js Realtime) | **OK** — Synchronisé |
| **Profil public** | ✅ Profil seeker visible par recruteurs | ⚠️ Profil recruteur visible par seekers (pas photo/vidéo) | **PARTIEL** — Manque photo + vidéo |
| **Modification profil** | ✅ Page settings seeker | ⚠️ Page /settings placeholder | **GAP** — Implémenter formulaire complet |
| **Upload offre** | N/A | ✅ Wizard /offers/new (15KB) | **OK** — Existe déjà |
| **Grille candidats** | N/A | ✅ Page /candidates avec modal | **OK** — Epic 12 done |

**Conclusion** :
- **3 gaps majeurs** identifiés : photo profil, vidéo présentation, preview format mobile
- **Cohérence UX** : Si chercheur peut montrer son visage en vidéo, recruteur doit aussi se présenter (équité, transparence)
- **Impact PRD** : Epic 16 à créer OU considérer comme évolution naturelle des features profil

**Actions suggérées** :
1. **Option A** : Créer Epic 16 avec architecture complète (recommandé si > 10 stories)
2. **Option B** : Traiter comme micro-sprints (3 features séparées)
3. **Option C** : Mettre à jour PRD avec section "Profil Recruteur Amélioré"

---

*Sauvegarde mise a jour le 2026-04-30 (Epic 15 DONE + Analyse features recruteur)*
*Epics 11-15 SaaS TOUS TERMINES (100%). Next: Epic 16 Profil Recruteur OU comparaison features app/SaaS détaillée + révision PRD.*

---

## Session 2026-05-01 : Révision PRD — Epic 10 Phase 2 (Profil Recruteur Complet)

### ✅ Travail Effectué

**Décision** : Enrichir Epic 10 existant avec une **Phase 2 : Profil Complet (Post-MVP)** au lieu de créer un nouvel Epic 16.

**Raison** :
- Cohérence thématique (tout lié au profil recruteur)
- Évite le renommage des Epics suivants (16 Paiements, 17 Administration)
- Distinction claire MVP (auth basique) vs Complet (éléments visuels)

### 📝 User Stories Ajoutées au PRD

| US | Titre | Description |
|----|-------|-------------|
| **US-10.6** | Photo de profil recruteur | Upload + crop carré (1:1, 200x200px), stockage R2, affichage app mobile + SaaS |
| **US-10.7** | Preview format mobile | Preview 9:16 lors publication offre, toggle Desktop/Mobile, validation visuelle |
| **US-10.8** | Page Settings complète | Route `/settings`, 7 sections éditables, barre progression temps réel |

### ❌ Features Retirées

**Vidéo présentation entreprise (60s)** — Décision utilisateur : ne sert à rien, on garde uniquement photo + preview + settings.

**Colonnes DB retirées** :
- ~~`recruiter_profiles.presentation_video_id`~~ (initialement prévue, retirée)

**Colonnes DB conservées** :
- `recruiter_profiles.photo_url` (TEXT nullable) ✅

### 🎯 Gaps Corrigés

| Gap Identifié | Solution PRD |
|---------------|-------------|
| 📸 Recruteur pas de photo (vs chercheur oui) | US-10.6 Photo profil |
| 👁️ Pas de preview format mobile | US-10.7 Preview 9:16 |
| ⚙️ Page /settings placeholder | US-10.8 Settings complet |

### 📋 Prochaines Étapes (TODO)

1. **Mettre à jour section "Nouvelles Tables DB (SaaS)"** dans le PRD → Ajouter `recruiter_profiles.photo_url`
2. **Vérifier section V2** → Retirer ces features si elles y étaient mentionnées
3. **Créer architecture Epic 10 Phase 2** (optionnel selon complexité)
4. **Sprint planning** pour Phase 2 (estimation 1-2 semaines)

### 📊 État du Projet

- **PRD** : `prd-etoile-draft.md` — Mis à jour (Epic 10 Phase 2 ajoutée)
- **Epics 11-15 SaaS** : TOUS TERMINÉS (100%)
- **Prochaine implémentation** : Epic 10 Phase 2 (3 user stories)

---

*Sauvegarde mise à jour le 2026-05-01 (Révision PRD Epic 10 Phase 2 — Photo recruteur + Preview mobile + Settings)*
*Next: Finaliser PRD (section Tables DB) → Architecture Phase 2 → Sprint planning → Implémentation*

---

## Session 2026-05-01 (Suite) : Architecture Epic 10 Phase 2 — COMPLÈTE ✅

### ✅ Architecture Créée

**Document** : `_bmad-output/architecture-epic-10-phase-2.md` (STATUS: COMPLETE)

**Workflow Winston (8/8 étapes)** :
1. ✅ Analyse contexte projet (3 US, NFRs, complexité)
2. ✅ Évaluation starter template (stack Next.js confirmé)
3. ✅ Décisions architecturales critiques (7 décisions documentées)
4. ✅ Patterns d'implémentation (3 patterns spécifiques)
5. ✅ Structure projet (10 fichiers mappés)
6. ✅ Validation architecture (100% couverture)
7. ✅ Revue cohérence (0 gaps critiques)
8. ✅ Complétion finale

### 🏗️ Décisions Architecturales Clés

| # | Décision | Choix Retenu |
|---|----------|--------------|
| **2.1** | Bibliothèque crop image | `react-easy-crop` (A) — Composant React natif, 200KB, tactile |
| **2.2** | Fonction upload générique | `lib/uploadFile.ts` (C) — 3 buckets (videos, photos, docs) |
| **2.3** | Structure form Settings | **Single scroll** (C) — 7 sections dans 1 page, pas de tabs |
| **2.4** | Preview mobile | Constants hard-codées (`9/16`, `375x667`) — pas de resize dynamique |
| **1.1** | Migration DB | `ALTER TABLE recruiter_profiles ADD COLUMN photo_url TEXT` |
| **1.2** | Sécurité RLS | Policy `UPDATE recruiter_profiles WHERE user_id = auth.uid()` |
| **3.1** | Component réutilisable | `RecruiterAvatar` (3 tailles : sm=48px, md=80px, lg=200px) |

### 📂 Fichiers à Implémenter (10 au total)

**Nouveaux (8 fichiers)** :
- `lib/uploadFile.ts` — Fonction upload générique R2 (3 buckets)
- `components/settings/RecruiterAvatar.tsx` — Avatar 3 tailles
- `components/settings/PhotoUploadSection.tsx` — Upload + crop photo
- `components/settings/SettingsForm.tsx` — Form 7 sections
- `components/offers/MobilePreview.tsx` — Preview 9:16 toggle Desktop/Mobile
- `app/(dashboard)/settings/page.tsx` — Page Settings
- `app/(dashboard)/settings/actions.ts` — Server Actions CRUD settings
- `supabase/migrations/[timestamp]_add_recruiter_photo.sql` — Migration

**Modifiés (2 fichiers)** :
- `app/(dashboard)/offers/new/page.tsx` — Intégrer `<MobilePreview>`
- `lib/types/database.ts` — Ajouter `photo_url?: string | null`

### 🎯 Validation Architecture

| Critère | Résultat |
|---------|----------|
| **Couverture exigences** | ✅ 100% (20/20 critères US couverts) |
| **Gaps critiques** | ✅ 0 (aucun) |
| **Gaps importants** | ✅ 0 (aucun) |
| **Cohérence décisions** | ✅ Validée (compatibilité confirmée) |
| **Patterns réutilisables** | ✅ 3 patterns documentés |
| **Prêt implémentation** | ✅ OUI |

### 📋 Prochaines Étapes (TODO)

**Option 1 : Sprint Planning (Recommandée)** 
→ `/sm` (Bob Scrum Master)  
→ Découper Epic 10 Phase 2 en stories avec séquencement

**Option 2 : Implémentation Directe**  
→ `/dev` (Amelia Developer)  
→ Séquence : Migration DB → Lib partagé → Features (Photo → Preview → Settings)

**Option 3 : QA Review (Optionnel)**  
→ `/qa` (Quinn QA)  
→ Review architecture avant implémentation

### 📊 État du Projet (Mise à Jour)

| Epic | Statut | Composants |
|------|--------|-----------|
| **Epic 11** (Publication offres) | ✅ DONE | Wizard upload, liste, CRUD |
| **Epic 12** (Grille candidats) | ✅ DONE | Scoring, modal, filtres |
| **Epic 13** (Dashboard briefing) | ✅ DONE | KPIs PostgreSQL, polling |
| **Epic 14** (Scoring PostgreSQL) | ✅ DONE | Table match_scores, trigger |
| **Epic 15** (Messagerie) | ✅ DONE | Realtime Supabase |
| **Epic 10 Phase 2** | 🔧 ARCHITECTURE READY | Photo + Preview + Settings |

**Migrations déployées** : 27/27 (Epic 13: 2, Epic 14: 2)  
**Tests Flutter** : 85/85 passing  
**Analyse statique** : 0 errors

---

*Sauvegarde mise à jour le 2026-05-01 (Architecture Epic 10 Phase 2 COMPLÈTE — Prêt pour implémentation)*  
*Next Track SaaS: Sprint Planning Epic 10 Phase 2 OU implémentation directe (10 fichiers)*
## Session 2026-05-02 : Corrections Feed Mobile ✅

### 🐛 Bug Fix 1 : Affichage Posters

**Problème** : Les posters (images statiques d'offres) ne s'affichaient pas dans le feed mobile, alors que les vidéos fonctionnaient.

**Cause Identifiée** :
- Dans `feed_page.dart` ligne ~510, le widget `_VideoCard` utilisait `feedItem.video.videoUrl` pour afficher les posters
- OR dans la BDD, les posters stockent l'image dans `thumbnail_url` (pas `video_url` qui est null)
- Le SaaS recruteur enregistre : `video_url: null, thumbnail_url: result.url` pour type='poster'

**Solution Appliquée** :
```dart
// AVANT (ligne 510)
child: feedItem.video.videoUrl != null
    ? CachedNetworkImage(imageUrl: feedItem.video.videoUrl!)

// APRÈS
child: feedItem.video.thumbnailUrl != null
    ? CachedNetworkImage(imageUrl: feedItem.video.thumbnailUrl!)
```

**Fichiers Modifiés** :
- `lib/features/feed/presentation/pages/feed_page.dart` (ligne ~510)
- `lib/features/video/data/models/video_model.dart` (doc commentaire type 'poster')

---

### 🗑️ Refactoring : Suppression Feed Entreprises

**Décision Produit** : Les recruteurs ne font plus de vidéos de présentation (type='presentation'), donc le feed "Entreprises" (discover) ne sert plus à rien.

**Changements UI** :
- ❌ Supprimé l'onglet "Entreprises" (discover) de l'AppBar feed
- ❌ Supprimé l'onglet "Offres" (devient le seul affichage par défaut)
- ✅ Titre AppBar simplifié : juste "Offres" pour les seekers, "ETOILE" pour les autres

**Code Nettoyé** :
- Supprimé variable `_selectedTab`
- Supprimé méthode `_switchTab()`
- Simplifié `_buildAppBarTitle()` (plus de Row avec 2 GestureDetector)

**Fichiers Modifiés** :
- `lib/features/feed/presentation/pages/feed_page.dart` (lignes 100, 120-136, 160-228)

**Code FeedBloc** : Conservé le paramètre `feedTab` (valeur par défaut 'offers') mais le feed 'discover' n'est jamais appelé depuis l'UI. Nettoyage complet optionnel (pas critique).

---

### ✅ Résultats

| Test | Statut |
|------|--------|
| **Compilation Flutter** | ✅ 0 errors, 2 warnings (prefer_final_fields) |
| **Analyse statique** | ✅ PASS |
| **Tests unitaires** | ✅ 85/85 passing (inchangé) |
| **Affichage posters** | ✅ FIX appliqué (à tester) |
| **Feed simplifié** | ✅ Onglet Entreprises supprimé |

---

*Sauvegarde mise à jour le 2026-05-02 (Bug posters + Suppression feed Entreprises)*
*Next: Test mobile pour valider affichage posters + Epic 10 Phase 2 (Settings)*
