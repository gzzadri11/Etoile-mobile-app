---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-05-01'
inputDocuments:
  - prd-etoile-draft.md (Epic 10 Phase 2)
  - architecture.md (Architecture générale)
  - architecture-epic-13-dashboard.md (Référence patterns SaaS)
  - architecture-epic-14-scoring.md (Référence patterns SaaS)
  - architecture-epic-15-messaging.md (Référence patterns SaaS)
  - brainstorming-architecture-saas.md (Décisions stack technique)
workflowType: 'architecture'
project_name: 'Etoile Mobile App'
user_name: 'Developer'
date: '2026-05-01'
epic: 'Epic 10 Phase 2 - Profil Recruteur Complet'
scope: 'Photo profil + Preview format mobile + Page Settings'
---

# Architecture Decision Document — Epic 10 Phase 2

**Epic :** Profil Recruteur Complet (Post-MVP)
**Scope :** Photo de profil recruteur + Preview format mobile lors publication + Page Settings complète
**User Stories :** US-10.6, US-10.7, US-10.8

_Ce document se construit collaborativement par étapes. Les sections sont ajoutées au fur et à mesure des décisions architecturales._

---

## Project Context Analysis

### Requirements Overview

**Functional Requirements (3 User Stories) :**

| US | Titre | Complexité Archi |
|----|-------|-----------------|
| US-10.6 | Photo de profil recruteur | Moyenne — Upload + Crop + Stockage R2 + Affichage multi-plateforme |
| US-10.7 | Preview format mobile lors publication | Moyenne — Redimensionnement 9:16 + Toggle + Validation temps réel |
| US-10.8 | Page Settings complète | Moyenne — CRUD 7 sections + Validation + Progression temps réel |

**Non-Functional Requirements :**

| NFR | Implication architecturale |
|-----|---------------------------|
| Sécurité (RLS) | Policies UPDATE recruiter_profiles WHERE user_id = auth.uid() |
| Performance upload | Optimisation taille image, compression client, presigned URLs R2 |
| Validation double | Client (Next.js) + Serveur (RLS + constraints SQL) |
| Cohérence UX | Affichage photo identique mobile (48px) vs SaaS (80px) |
| Preview temps réel | Redimensionnement instantané lors modifications (React state) |
| Crop obligatoire | UX interactive (sélection + aperçu), ratio 1:1, min 200x200px |

**Scale & Complexity :**

- **Domaine principal :** SaaS web full-stack (Next.js + Supabase)
- **Niveau de complexité :** Moyen (3 US, patterns CRUD établis, upload image classique)
- **Composants architecturaux estimés :** 6-8

### Technical Constraints & Dependencies

| Contrainte | Impact |
|------------|--------|
| Stack Next.js + Tailwind + Shadcn/ui | Composants UI déjà établis (Epics 11-15) |
| Cloudflare R2 bucket `etoile-photos` | Même infrastructure que videos, Worker existant |
| Supabase RLS | Policies nécessaires pour sécuriser UPDATE recruiter_profiles |
| Nouvelle colonne DB | `recruiter_profiles.photo_url` (TEXT nullable) — migration SQL |
| App mobile Flutter | Preview format mobile doit miroir exactement le feed (9:16, styles) |
| Cohérence profil | Photo affichée dans app mobile (profil recruteur) + SaaS (sidebar + settings) |

### Cross-Cutting Concerns

1. **Upload/stockage fichiers R2** — Pattern réutilisable (videos → photos → documents justificatifs)
2. **Crop d'image** — UX standard, librairie React (react-easy-crop ou react-image-crop)
3. **Validation formulaire** — Pattern déjà établi (Epic 13, 14, 15) — Zod + Server Actions
4. **RLS policies** — Sécurité transversale, toutes tables recruiter_profiles
5. **Preview format mobile** — Nécessite constantes partagées (dimensions, styles) miroir Flutter
6. **Barre progression complétude** — Calcul temps réel côté client (déjà existant Epic 10 Phase 1)
7. **Affichage multi-plateforme** — Photo ronde dans 3 contextes (app mobile, sidebar SaaS, settings SaaS)

---
## Starter Template Evaluation

### Primary Technology Domain

**SaaS web full-stack** (Next.js + Supabase) — Projet existant

### Situation

Epic 10 Phase 2 s'intègre dans un SaaS **déjà opérationnel** avec 5 Epics implémentés (11-15).

**Stack technique établi :**

| Couche | Technologie | Version | Statut |
|--------|-------------|---------|--------|
| **Frontend** | Next.js | 16 (App Router) | ✅ En production |
| **Styling** | Tailwind CSS | v4 | ✅ Configuré |
| **UI Components** | Shadcn/ui | v4 (@base-ui/react) | ✅ ~15 composants installés |
| **Backend** | Supabase | Latest (SSR) | ✅ Browser + Server clients |
| **Database** | PostgreSQL (Supabase) | 15+ | ✅ 27/27 migrations déployées |
| **Validation** | Zod | Latest | ✅ Utilisé dans Epics 13-15 |
| **Charts** | Recharts | Latest | ✅ Epic 13 (Dashboard) |
| **Stockage** | Cloudflare R2 | - | ✅ Videos + thumbnails |
| **Déploiement** | Vercel | Hobby plan | ✅ Auto-deploy main branch |

**Patterns architecturaux existants :**

1. **Server Actions** — Toutes mutations (Epic 11, 14, 15)
2. **RLS Policies** — Sécurité DB (UPDATE recruiter_profiles WHERE user_id = auth.uid())
3. **Zod validation** — Formulaires + Server Actions
4. **Supabase SSR** — Browser client (client components) + Server client (server components/actions)
5. **Shadcn/ui patterns** — Form + Dialog + Select + Tabs + Dropdown déjà utilisés
6. **React hooks order** — ALL hooks BEFORE conditional returns (leçon Epic 12)
7. **Modal overlay** — Dialog plein écran (!max-w-[96vw] !h-[92vh]) pour UX immersive

**Architecture components existants réutilisables :**

- `lib/upload.ts` — Upload R2 presigned URLs (Epic 11, vidéos)
- `lib/supabase/server.ts` — Server client Supabase
- `components/ui/*` — ~15 composants Shadcn/ui
- Patterns de validation Zod existants (Epics 11, 13, 14, 15)

### Selected Approach: Extension de l'Architecture Existante

**Rationale :**

✅ **Cohérence technique** — Mêmes patterns que Epics 11-15  
✅ **Réutilisation code** — Upload service, validation, RLS, UI components  
✅ **Maintenance simplifiée** — Une seule stack à maintenir  
✅ **Patterns éprouvés** — 5 Epics implémentés avec succès  
✅ **Zero setup** — Projet déjà configuré, testé, déployé

**Pas de nouvelle initialisation requise** — Extension incrémentale du SaaS existant.

**Prochaines décisions architecturales :** Spécifiques à Epic 10 Phase 2 (upload photo, crop, preview mobile, settings form).

---

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Bloquent l'implémentation) :**
1. ✅ Librairie crop d'image : react-easy-crop
2. ✅ Stratégie upload fichiers : Généralisation lib/upload.ts → lib/uploadFile.ts
3. ✅ Migration DB : Colonne recruiter_profiles.photo_url (TEXT nullable)
4. ✅ RLS Policy : UPDATE recruiter_profiles WHERE user_id = auth.uid()

**Important Decisions (Structurent l'architecture) :**
1. ✅ Formulaire Settings : Single scroll (7 sections visibles)
2. ✅ Validation : Zod schema (pattern établi Epics 13-15)
3. ✅ Preview format mobile : Hard-coded 9:16 (miroir manuel Flutter)
4. ✅ Composant Avatar : Réutilisable 3 tailles (sm/md/lg)

**Deferred Decisions (Post-MVP) :**
- Compression d'image côté client (si besoin optimisation)
- Cache photo profil (CDN R2 suffit pour MVP)

---

### Cat. 1 — Data Architecture

#### 1.1 Migration Base de Données

**Décision : Nouvelle colonne `recruiter_profiles.photo_url`**

Migration SQL :
```sql
-- Epic 10 Phase 2 : Photo profil recruteur
ALTER TABLE recruiter_profiles
ADD COLUMN photo_url TEXT;

-- RLS Policy pour sécuriser UPDATE
CREATE POLICY "recruiters_update_own_profile"
ON recruiter_profiles
FOR UPDATE
USING (user_id = auth.uid());
```

**Rationale :**
- Colonne nullable (photo optionnelle, pas dans complétude 100%)
- RLS garantit que seul le propriétaire modifie son profil
- Pattern établi (Epics 13, 14, 15)

**Affecte :** US-10.6, US-10.8

---

#### 1.2 Validation Données

**Décision : Zod schema pour formulaire Settings**

```typescript
// lib/validations/recruiter-settings.ts
import { z } from 'zod';

export const recruiterSettingsSchema = z.object({
  photo_url: z.string().url().nullable(),
  company_name: z.string().min(2).max(100),
  sector: z.enum([/* 15 secteurs */]),
  description: z.string().min(50),
  locations: z.array(z.string()).min(1),
  siret: z.string().length(14).regex(/^\d{14}$/),
  verification_document_url: z.string().url().nullable()
});
```

**Rationale :**
- Pattern Zod déjà utilisé (Epics 13, 14, 15)
- Validation client + serveur (Server Actions)
- Messages d'erreur en français (helper translateZodError)

**Affecte :** US-10.8

---

### Cat. 2 — Frontend Architecture

#### 2.1 Librairie Crop d'Image

**Décision : react-easy-crop**

Installation :
```bash
npm install react-easy-crop
```

**Rationale :**
- ✅ Lightweight (~10KB gzipped)
- ✅ UX moderne (pinch-to-zoom, drag fluide)
- ✅ Contrôle programmatique du crop area
- ✅ Bien maintenu (dernière MAJ : 2024)
- ✅ API simple : `onCropComplete(croppedArea, croppedAreaPixels)`

**Trade-offs :**
- (+) Meilleure UX que react-image-crop
- (-) Calcul manuel des coordonnées crop (négligeable, ~10 lignes)

**Affecte :** US-10.6

---

#### 2.2 Stratégie Upload Fichiers

**Décision : Généraliser lib/upload.ts → lib/uploadFile.ts**

**Architecture :**
- Une fonction générique `uploadFile(file, bucket, userId)`
- Helpers spécialisés : `uploadVideo()`, `uploadPhoto()`, `uploadDocument()`
- Validation type/taille spécifique par bucket
- Presigned URLs R2 (pattern existant Epic 11)

**Rationale :**
- ✅ DRY principle (une seule logique upload)
- ✅ Réutilisable (photos, vidéos, documents justificatifs)
- ✅ Validation spécifique par type (JPG/PNG pour photos, MP4 pour vidéos)
- ✅ Évite dette technique (Epic 11 déjà en place, facile à refactorer)

**Affecte :** US-10.6, US-10.5 (document justificatif)

---

#### 2.3 Composant Avatar Réutilisable

**Décision : Composant <RecruiterAvatar> avec 3 tailles**

**Tailles :**
- `sm` = 48px (miroir app mobile)
- `md` = 80px (sidebar)
- `lg` = 120px (settings)

**Rationale :**
- Cohérence affichage (3 contextes)
- Fallback initiale si pas de photo
- Réutilisable dans tout le SaaS

**Affecte :** US-10.6

---

#### 2.4 Formulaire Settings — Structure

**Décision : Single scroll form (7 sections visibles)**

**Rationale :**
- ✅ Simple, tout visible
- ✅ Barre progression complétude en sticky top
- ✅ Mobile-friendly (scroll natif)
- ✅ Pattern cohérent avec Epic 10 Phase 1

**Alternative rejetée :**
- Tabs (7 onglets = trop sur mobile)
- Accordéons (sections "cachées", moins visible)

**Affecte :** US-10.8

---

#### 2.5 Preview Format Mobile

**Décision : Hard-coded 9:16, miroir manuel Flutter**

**Constantes :**
- Aspect ratio : 9/16 (0.5625)
- Width : 375px (iPhone standard)
- Height : 667px

**Rationale :**
- Format 9:16 = standard stable (TikTok, Instagram, Reels)
- Pas besoin de synchronisation dynamique Flutter ↔ Next.js
- Constantes documentées dans les deux codebases

**Affecte :** US-10.7

---

### Decision Impact Analysis

**Séquence d'implémentation recommandée :**

1. **Migration DB** (photo_url + RLS) — Bloquant pour toute feature
2. **Généralisation lib/uploadFile.ts** — Réutilisable US-10.6 + US-10.5
3. **Composant RecruiterAvatar** — Base affichage photo
4. **US-10.6 : Upload + Crop photo** — react-easy-crop + uploadPhoto
5. **US-10.8 : Page Settings** — Formulaire 7 sections + Zod
6. **US-10.7 : Preview mobile** — Composant MobilePreview 9:16

**Dépendances croisées :**

- US-10.8 (Settings) dépend de US-10.6 (upload photo) → Composant PhotoUpload réutilisé
- US-10.7 (Preview) indépendant → Peut être développé en parallèle
- Migration DB + RLS → Prérequis pour tout
- lib/uploadFile.ts → Prérequis US-10.6 + US-10.5

---

## Implementation Patterns & Consistency Rules

### Patterns Existants (Référence)

Epic 10 Phase 2 **réutilise les patterns établis** par Epics 11-15 et documentés dans `architecture.md` (975 lignes).

**Patterns globaux à suivre** :
- **Naming** : snake_case (DB), camelCase (TypeScript)
- **Structure** : App Router Next.js (`app/` directory)
- **Validation** : Zod schemas + Server Actions
- **Sécurité** : RLS policies (auth.uid())
- **UI** : Shadcn/ui v4 components
- **Forms** : react-hook-form + Zod
- **Errors** : try/catch + toast notifications

---

### Patterns Spécifiques Epic 10 Phase 2

#### Pattern 1 : Upload + Crop Photo

**Flux implémentation :**
1. Validation client (JPG/PNG, max 5MB)
2. Preview + react-easy-crop (ratio 1:1)
3. onCropComplete → Canvas API → Blob croppé
4. uploadPhoto(blob, userId) → R2
5. Server Action updateProfile({ photo_url })

**Anti-patterns à éviter :**
- ❌ Upload AVANT crop (gaspillage bande passante)
- ❌ Hardcoder bucket name (utiliser helper uploadPhoto)
- ❌ UPDATE direct Supabase client (bypasse RLS)

---

#### Pattern 2 : Preview Format Mobile

**Constantes (components/offers/constants.ts) :**
```typescript
export const MOBILE_PREVIEW = {
  ASPECT: 9 / 16,
  WIDTH: 375,
  HEIGHT: 667
} as const;
```

**Usage :**
```tsx
import { MOBILE_PREVIEW } from './constants';

<div style={{
  width: MOBILE_PREVIEW.WIDTH,
  height: MOBILE_PREVIEW.HEIGHT
}}>
  {/* Preview content */}
</div>
```

**Anti-patterns à éviter :**
- ❌ Hardcoder 375/667 dans le composant
- ❌ Utiliser Tailwind w-[375px] (pas responsive)

---

#### Pattern 3 : Formulaire Settings Multi-Sections

**Structure obligatoire :**
```tsx
<form onSubmit={handleSubmit(onSubmit)}>
  {/* Sticky progress bar */}
  <div className="sticky top-0 z-10 bg-background">
    <ProgressBar value={completionPercentage} />
  </div>

  {/* 7 sections */}
  <section id="photo" className="space-y-4">
    <h2>Photo de profil</h2>
    {/* fields */}
  </section>

  {/* ... autres sections */}

  {/* Single submit button */}
  <Button type="submit">Enregistrer</Button>
</form>
```

**Règles :**
- ✅ UN SEUL formulaire (pas un par section)
- ✅ UN SEUL bouton submit en bas
- ✅ Validation Zod globale (recruiterSettingsSchema)
- ✅ Progress bar sticky top
- ✅ Sections avec id (navigation possible)

**Anti-patterns à éviter :**
- ❌ Un formulaire par section (perd state global)
- ❌ Bouton "Sauvegarder" par section (UX confuse)
- ❌ Validation manuelle (utiliser Zod)

---

### Enforcement Guidelines

**Tout agent IA implémentant Epic 10 Phase 2 DOIT :**

1. **Lire architecture.md** — Patterns globaux (naming, structure, etc.)
2. **Suivre patterns Epics 11-15** — Server Actions, Zod, RLS
3. **Utiliser helpers définis** — uploadPhoto(), RecruiterAvatar
4. **Respecter constantes** — MOBILE_PREVIEW (pas hardcode)
5. **Validation Zod obligatoire** — recruiterSettingsSchema
6. **RLS policies** — Toujours via Server Actions (pas direct client)
7. **Composants Shadcn/ui** — Réutiliser existants (Form, Input, Select, Button)

**Points de vérification avant PR :**
- [ ] Aucun hardcode dimensions/constantes
- [ ] Upload passe par uploadPhoto() helper
- [ ] Formulaire Settings = UN SEUL form
- [ ] Validation Zod sur toutes mutations
- [ ] RLS policy testée (user ne peut modifier que son profil)
- [ ] Composants Shadcn/ui réutilisés (pas de custom)

---

## Project Structure & Boundaries

### Epic → Fichiers Mapping

Epic 10 Phase 2 ajoute **~8 nouveaux fichiers** au SaaS existant `saas-etoile/`.

#### US-10.6 : Photo de profil recruteur

**Fichiers à créer :**

```
saas-etoile/
├── components/
│   ├── RecruiterAvatar.tsx         [CRÉER] Composant avatar 3 tailles (sm/md/lg)
│   └── settings/
│       └── PhotoUpload.tsx         [CRÉER] Upload + Crop (react-easy-crop)
├── lib/
│   └── uploadFile.ts               [REFACTOR] Généraliser depuis upload.ts
├── app/(dashboard)/settings/
│   └── actions.ts                  [CRÉER] Server Action updateRecruiterProfile
└── supabase/migrations/
    └── YYYYMMDD000000_photo_url.sql [CRÉER] ALTER TABLE + RLS policy
```

**Composants réutilisés :**
- `components/ui/Button.tsx` (Shadcn/ui existant)
- `components/ui/Input.tsx` (Shadcn/ui existant)
- `lib/supabase/server.ts` (Server client existant)

---

#### US-10.7 : Preview format mobile

**Fichiers à créer :**

```
saas-etoile/
└── components/offers/
    ├── MobilePreview.tsx            [CRÉER] Container 9:16 stylisé "iPhone"
    └── constants.ts                 [CRÉER] MOBILE_PREVIEW constantes
```

**Intégration :**
- Utilisé dans `app/(dashboard)/offers/new/page.tsx` (existant Epic 11)
- Toggle Desktop/Mobile (state local React)

---

#### US-10.8 : Page Settings complète

**Fichiers à créer :**

```
saas-etoile/
├── app/(dashboard)/settings/
│   ├── page.tsx                     [CRÉER] Formulaire 7 sections + Progress bar
│   └── actions.ts                   [ÉTENDRE] Ajouter updateRecruiterProfile
└── lib/validations/
    └── recruiter-settings.ts        [CRÉER] Zod schema (7 champs)
```

**Composants réutilisés :**
- `components/ui/Form.tsx` (Shadcn/ui + react-hook-form)
- `components/ui/Select.tsx` (dropdown secteurs)
- `components/ui/Textarea.tsx` (description)
- `components/ui/Progress.tsx` (barre complétude)
- `components/settings/PhotoUpload.tsx` (US-10.6)

---

### Architectural Boundaries

#### Component Boundaries

**RecruiterAvatar (réutilisable) :**
- Utilisé dans 3 contextes : Sidebar, Settings, (Future) App mobile
- Props: photoUrl, companyName, size

**PhotoUpload (isolé) :**
- Responsabilités : Validation, Preview, Crop, Upload R2
- Retourne photo_url

**MobilePreview (isolé) :**
- Responsabilités : Container 9:16, Toggle Desktop/Mobile
- Props: type, url, title, companyName, sector

---

#### Data Flow Boundaries

**Upload Photo Flow :**
```
PhotoUpload → uploadPhoto() → Cloudflare Worker → R2
  → photo_url → setValue() → handleSubmit()
  → Server Action → Supabase UPDATE (RLS) → toast
```

**Settings Form Flow :**
```
SettingsForm → react-hook-form + Zod
  → onSubmit() → Server Action (Zod validation)
  → Supabase UPDATE (RLS) → revalidatePath() → toast
```

---

#### Integration Points

**Avec Epics existants :**

| Epic | Integration | Fichier |
|------|-------------|---------|
| Epic 11 | MobilePreview dans upload offre | `offers/new/page.tsx` |
| Epic 13 | Progress bar complétude | Réutiliser composant existant |
| Epic 15 | Photo dans messagerie | RecruiterAvatar dans conversations |

**Avec App Mobile Flutter :**
- Photo profil : Fetch `recruiter_profiles.photo_url`
- Preview mobile : Constantes 9:16 documentées

---

### File Organization Summary

**Nouveaux fichiers (8) :**
- `components/RecruiterAvatar.tsx`
- `components/settings/PhotoUpload.tsx`
- `components/offers/MobilePreview.tsx`
- `components/offers/constants.ts`
- `app/(dashboard)/settings/page.tsx`
- `app/(dashboard)/settings/actions.ts`
- `lib/uploadFile.ts` (refactor)
- `lib/validations/recruiter-settings.ts`
- `supabase/migrations/YYYYMMDD000000_photo_url.sql`

**Fichiers modifiés (2) :**
- `app/(dashboard)/offers/new/page.tsx` (intégrer MobilePreview)
- `components/layout/Sidebar.tsx` (utiliser RecruiterAvatar)

**Total :** 10 fichiers (8 nouveaux, 2 modifiés)

---

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility :** Toutes les décisions sont compatibles. react-easy-crop fonctionne avec Next.js 16, lib/uploadFile.ts étend le pattern Epic 11, Zod + Server Actions suit Epics 13-15, RLS + Supabase SSR est établi.

**Pattern Consistency :** Tous les patterns s'alignent avec l'architecture existante. Upload → Crop → R2 suit Epic 11, Validation Zod suit Epics 13-15, RLS suit pattern global, Composants réutilisent Shadcn/ui.

**Structure Alignment :** La structure s'intègre parfaitement. 10 fichiers (8 nouveaux, 2 modifiés) suivent l'organisation App Router Next.js existante. Aucun conflit de structure détecté.

---

### Requirements Coverage ✅

**Epics :** Epic 10 Phase 2 (3 User Stories)

| US | Critères | Couverture | Statut |
|----|----------|------------|--------|
| US-10.6 | 6 critères | 6/6 couverts | ✅ 100% |
| US-10.7 | 6 critères | 6/6 couverts | ✅ 100% |
| US-10.8 | 8 critères | 8/8 couverts | ✅ 100% |

**Total :** 20/20 critères d'acceptation couverts architecturalement (100%).

**Non-Functional Requirements :**
- ✅ Sécurité (RLS policies)
- ✅ Performance (presigned URLs R2, validation client)
- ✅ Validation (double : client Zod + serveur RLS)
- ✅ Cohérence UX (RecruiterAvatar 3 tailles, MOBILE_PREVIEW constantes)

---

### Implementation Readiness ✅

**Decision Completeness :**
- 7 décisions critiques documentées avec rationale
- Versions vérifiées (react-easy-crop, Next.js 16)
- Patterns complets avec exemples code
- 6 anti-patterns documentés

**Structure Completeness :**
- 10 fichiers mappés (8 CRÉER, 2 MODIFIER)
- Tous chemins définis (components/, app/, lib/, supabase/)
- Integration points spécifiés (Epics 11, 13, 15)
- Component boundaries clairs

**Pattern Completeness :**
- 3 patterns spécifiques Epic 10 Phase 2
- Patterns globaux référencés (architecture.md)
- Anti-patterns documentés
- Enforcement guidelines définies

---

### Gap Analysis

**Critical Gaps : 0**
Toutes les décisions critiques sont prises. Implémentation peut commencer immédiatement.

**Important Gaps : 0**
Architecture complète. Aucune zone grise identifiée.

**Nice-to-Have (Post-MVP) :**
1. Compression d'image côté client (déféré)
2. Tests E2E Playwright upload photo (déféré)

---

### Architecture Completeness Checklist

- [x] Contexte projet analysé (3 US, NFRs, complexité)
- [x] Stack technique confirmé (Next.js + Supabase + R2 existant)
- [x] 7 décisions architecturales documentées
- [x] 3 patterns spécifiques Epic 10 Phase 2
- [x] 10 fichiers mappés (structure complète)
- [x] 20/20 critères acceptation couverts
- [x] 0 gap critique
- [x] Patterns cohérents avec Epics 11-15

---

### Architecture Readiness Assessment

**Statut : ✅ PRÊT POUR L'IMPLÉMENTATION**
**Confiance : Haute**

**Forces :**
- Architecture incrémentale (95% existe déjà)
- Patterns éprouvés (Epics 11-15 opérationnels)
- Décisions simples et pragmatiques
- Stack stable (Next.js 16 + Supabase + R2)
- Zero setup (SaaS déjà configuré)

**Risques :** Aucun identifié

**Prochaines étapes :**
1. Migration DB (photo_url + RLS)
2. Refactor lib/uploadFile.ts
3. Implémenter US-10.6 (Photo)
4. Implémenter US-10.8 (Settings)
5. Implémenter US-10.7 (Preview mobile)

---

### Implementation Handoff

**Tout agent IA implémentant Epic 10 Phase 2 doit :**

1. **Lire ce document AVANT toute implémentation**
2. **Suivre les décisions architecturales** (section Core Architectural Decisions)
3. **Respecter les patterns** (section Implementation Patterns)
4. **Utiliser la structure définie** (section Project Structure)
5. **Vérifier les anti-patterns** avant chaque PR

**Première priorité d'implémentation :**
1. Migration SQL (photo_url + RLS) — Bloquant
2. Refactor lib/uploadFile.ts — Foundation
3. Composant RecruiterAvatar — Réutilisable
4. US-10.6 → US-10.8 → US-10.7 (séquence recommandée)

---
