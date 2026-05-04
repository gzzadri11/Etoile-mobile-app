# Story 10.7: Preview format mobile lors publication

Status: done

## Story

En tant que recruteur,
je veux voir exactement comment mon offre (vidéo ou affiche) apparaîtra dans l'app mobile chercheur avant de publier,
so that je peux valider le rendu visuel avant diffusion aux candidats.

## Acceptance Criteria

1. **Preview 9:16** — Lors de l'upload vidéo/affiche, preview redimensionné format mobile (aspect ratio 9:16)
2. **Cadre stylisé** — Cadre "iPhone" ou "Android" stylisé autour du preview pour simulation mobile
3. **Métadonnées affichées** — Titre du poste + nom entreprise + secteur visibles comme dans feed mobile
4. **Toggle Desktop/Mobile** — Bouton toggle pour basculer entre preview desktop (16:9) et mobile (9:16)
5. **Preview temps réel** — Modifications du titre ou secteur se reflètent instantanément dans preview
6. **Validation publish** — Bouton "Publier" désactivé si vidéo > 40s ou affiche ratio incorrect

## Tasks / Subtasks

- [x] **Task 1: Constantes preview mobile** (AC: #1)
  - [x] Créer `saas-etoile/lib/constants/mobile-preview.ts`
  - [x] Export MOBILE_PREVIEW constants (ASPECT: 9/16, WIDTH: 375, HEIGHT: 667, FRAME_PADDING: 20)
  - [x] Export DESKTOP_PREVIEW constants pour comparaison

- [x] **Task 2: Component MobilePreview** (AC: #1, #2, #3, #4)
  - [x] Créer `saas-etoile/components/offers/MobilePreview.tsx`
  - [x] Props: videoUrl (string | null), posterUrl (string | null), title (string), companyName (string), sector (string)
  - [x] State: previewMode ('mobile' | 'desktop'), default 'mobile'
  - [x] Toggle button Desktop/Mobile avec icons
  - [x] Mobile mode: 375x667 container avec border radius + shadow (iPhone frame style)
  - [x] Display video/poster en 9:16 aspect-contain
  - [x] Overlay metadata: titre + entreprise + secteur (position bottom, style feed mobile)
  - [x] Desktop mode: 16:9 aspect ratio pour comparaison

- [x] **Task 3: Intégration dans /offers/new** (AC: #5, #6)
  - [x] Modifier `saas-etoile/app/(dashboard)/offers/new/page.tsx`
  - [x] Import MobilePreview + helpers
  - [x] State sync: title, sector, companyName, videoUrl/posterUrl → MobilePreview props
  - [x] Layout: 2 colonnes (form à gauche, preview à droite) responsive avec grid lg:grid-cols-2
  - [x] Preview temps réel: React automatique via props (pas de useEffect nécessaire)
  - [x] Validation: video.duration > 40s déjà implémentée (existant)
  - [x] Validation: poster aspect ratio 9:16 (±5% tolerance) ajoutée dans handlePosterFile
  - [x] Max-width dynamique: max-w-2xl par défaut, max-w-6xl sur step "details"

- [x] **Task 4: Video metadata extraction** (AC: #6)
  - [x] Créer helper `saas-etoile/lib/utils/video-metadata.ts`
  - [x] Function getVideoDuration(file: File): Promise<number> via HTMLVideoElement
  - [x] Function getImageDimensions(file: File): Promise<{width: number, height: number}>
  - [x] Function validateAspectRatio(width: number, height: number, target: number, tolerance: number): boolean
  - [x] Integration: validation implémentée dans handlePosterFile (async avec try/catch)

## Dev Notes

### Architecture Requirements

**Stack:**
- Next.js 16 + React 19
- Tailwind CSS v4
- Components: MobilePreview (client component)

**Critical Decisions (from architecture-epic-10-phase-2.md):**

1. **Decision 2.5 — Preview constants hard-codées**
   Format 9:16, dimensions 375x667 (iPhone standard)
   Pas de resize dynamique — miroir manuel du feed Flutter
   [Source: architecture-epic-10-phase-2.md #Decision 2.5]

2. **Pattern 4.1 — Toggle Desktop/Mobile**
   State local React (useState)
   Transition CSS smooth entre les 2 modes
   Icons lucide-react (Smartphone, Monitor)

3. **Pattern 4.2 — Preview temps réel**
   useEffect dependencies: [title, sector, videoUrl]
   Pas de debounce — update instantané

### File Structure

**Fichiers à créer (3):**
1. `saas-etoile/lib/constants/mobile-preview.ts` — Constants
2. `saas-etoile/components/offers/MobilePreview.tsx` — Preview component
3. `saas-etoile/lib/utils/video-metadata.ts` — Helpers validation

**Fichiers à modifier (1):**
1. `saas-etoile/app/(dashboard)/offers/new/page.tsx` — Intégrer preview

### Testing Requirements

**Manual Testing:**
- Upload video < 40s → preview mobile + desktop toggle
- Upload video > 40s → bouton "Publier" désactivé
- Upload affiche 9:16 → preview OK
- Upload affiche 16:9 → bouton "Publier" désactivé
- Modifier titre → preview updated temps réel
- Toggle Desktop/Mobile → transition smooth

### Code Quality Standards

**React:**
- Client component ('use client')
- Hooks order: ALL before conditional returns
- useEffect cleanup si nécessaire

**Tailwind:**
- aspect-[9/16] pour mobile
- aspect-video (16/9) pour desktop
- Responsive: stack vertical sur mobile, 2 cols sur desktop

### Known Patterns

**Epic 11 (Offers Upload):**
- Page `/offers/new` existe déjà
- Upload video/poster pattern établi
- Form state management déjà en place

**Mobile Feed (Flutter):**
- Format vertical 9:16
- Metadata overlay bottom: titre + entreprise + secteur
- Background gradient on text for readability

### Security Considerations

- Validation côté client (UX) + serveur (security)
- Video duration check avant upload (économie bande passante)
- Aspect ratio validation image avant upload

### Performance Considerations

- Video metadata extraction via HTMLVideoElement (async)
- Image dimensions via Image.onload (async)
- Preview rendering: object-contain pour éviter distorsion

### References

- [Architecture Epic 10 Phase 2](architecture-epic-10-phase-2.md)
- [PRD US-10.7](prd-etoile-draft.md#us-10-7)
- [Epic 11 Offers Upload](app/(dashboard)/offers/new/page.tsx)

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.5 (2026-05-01)

### Debug Log References

None yet — story just created.

### Completion Notes List

Story created for Epic 10 Phase 2 implementation.
Architecture decisions referenced from architecture-epic-10-phase-2.md.
Preview pattern: hard-coded constants 9:16, toggle desktop/mobile, real-time updates.

**Implementation completed (2026-05-01):**
- Task 1: Created mobile-preview.ts with MOBILE_PREVIEW (9/16, 375x667) and DESKTOP_PREVIEW (16/9, 640x360) constants
- Task 4: Created video-metadata.ts with getVideoDuration, getImageDimensions, and validateAspectRatio helpers
- Task 2: Created MobilePreview.tsx component with mobile/desktop toggle, iPhone frame styling, and metadata overlay
- Task 3: Integrated MobilePreview into /offers/new page with 2-column responsive layout, real-time preview sync, and aspect ratio validation for posters

**Key implementation details:**
- Preview updates in real-time as user types (React automatic re-render via props)
- Poster validation: rejects images not in 9:16 aspect ratio (±5% tolerance)
- Video validation: existing 40s max duration check preserved
- Layout: form left column, preview right column (sticky on desktop)
- Dynamic max-width: 2xl for steps 1-2, 6xl for details step
- Company name fetched from recruiter_profiles in mount useEffect

### File List

**Files created (3):**
1. `saas-etoile/lib/constants/mobile-preview.ts` — Preview dimension constants
2. `saas-etoile/lib/utils/video-metadata.ts` — Video/image metadata extraction helpers
3. `saas-etoile/components/offers/MobilePreview.tsx` — Mobile preview component

**Files modified (1):**
1. `saas-etoile/app/(dashboard)/offers/new/page.tsx` — Integrated preview with 2-column layout + validation
