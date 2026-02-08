# Story 0.3: Configuration Cloudflare R2

---
status: complete
epic: 0 - Fondation Technique
sprint: 1
points: 5
created: 2026-02-02
completed: 2026-02-02
author: John (PM)
developer: Amelia (Dev)
---

## Story

**As a** developpeur,
**I want** Cloudflare R2 configure pour le stockage video,
**So that** les uploads video fonctionnent.

---

## Acceptance Criteria

### AC-1: Configuration Worker Cloudflare
**Given** un compte Cloudflare existe
**When** je configure le Worker
**Then** le code du Worker pour presigned URLs est pret a deployer
**And** la configuration wrangler.toml est creee

### AC-2: Service R2 Flutter
**Given** le Worker est configure
**When** je veux uploader/telecharger des videos
**Then** un R2Service est disponible dans Flutter
**And** il permet de demander des presigned URLs
**And** il permet d'uploader des fichiers directement vers R2

### AC-3: Gestion des Videos
**Given** R2Service est disponible
**When** j'uploade une video
**Then** je peux suivre la progression
**And** je recois l'URL finale de la video

### AC-4: Documentation
**Given** la configuration est complete
**When** un developpeur veut deployer
**Then** un README explique le setup Cloudflare

---

## Tasks/Subtasks

### Task 1: Creer le dossier cloudflare-worker
- [x] 1.1 Creer le dossier cloudflare/ a la racine
- [x] 1.2 Creer wrangler.toml avec la configuration R2
- [x] 1.3 Creer package.json pour le worker

### Task 2: Implementer le Worker
- [x] 2.1 Creer src/index.ts avec les endpoints
- [x] 2.2 Endpoint POST /presigned-url pour upload
- [x] 2.3 Endpoint GET /video/:key pour streaming
- [x] 2.4 Gestion CORS pour l'app mobile
- [x] 2.5 Validation du token JWT Supabase

### Task 3: Creer R2Service Flutter
- [x] 3.1 Creer lib/core/services/r2_service.dart
- [x] 3.2 Methode getPresignedUploadUrl()
- [x] 3.3 Methode uploadVideo() avec progression
- [x] 3.4 Methode getVideoUrl()
- [x] 3.5 Enregistrer dans injection_container.dart

### Task 4: Documentation
- [x] 4.1 Creer cloudflare/README.md
- [x] 4.2 Documenter le deploiement du Worker

---

## Dev Notes

### Architecture R2
- Bucket videos: etoile-videos-prod
- Bucket thumbnails: etoile-thumbnails-prod
- Worker pour presigned URLs (securite)
- Upload direct depuis l'app vers R2

### Flux Upload
1. App demande presigned URL au Worker
2. Worker valide le token JWT
3. Worker genere presigned URL (expire 1h)
4. App uploade directement vers R2
5. App confirme l'upload via Supabase

### Endpoints Worker
- POST /presigned-url - Genere URL d'upload
- GET /video/:key - Streaming video (CDN cache)
- GET /thumbnail/:key - Thumbnails
- DELETE /video/:key - Suppression (auth required)
- GET /health - Health check

---

## Dev Agent Record

### Implementation Plan
1. Structure Cloudflare Worker (wrangler.toml, package.json, tsconfig.json)
2. Worker TypeScript avec tous les endpoints
3. R2Service Flutter pour interface avec le Worker
4. Integration dans injection_container.dart
5. Documentation complete

### Debug Log
- Aucun probleme rencontre
- Code TypeScript et Dart syntaxiquement correct

### Completion Notes
Implementation complete de la configuration Cloudflare R2:

**Worker Cloudflare:**
- Configuration multi-environnement (dev/staging/prod)
- Endpoints pour presigned URLs, upload, streaming, delete
- Validation JWT Supabase
- CORS configure
- Support range requests pour video seeking
- Cache headers optimises

**R2Service Flutter:**
- getPresignedUploadUrl() - Demande URL d'upload
- uploadVideo() - Upload avec progression
- uploadThumbnail() - Upload thumbnails
- uploadBytes() - Upload depuis memoire
- getVideoUrl() / getThumbnailUrl() - URLs publiques
- deleteVideo() / deleteThumbnail() - Suppression
- isHealthy() - Health check

**Documentation:**
- README complet avec setup instructions
- Exemples d'API
- Troubleshooting

---

## File List

### Fichiers Crees
- `cloudflare/wrangler.toml` (NEW)
- `cloudflare/package.json` (NEW)
- `cloudflare/tsconfig.json` (NEW)
- `cloudflare/src/index.ts` (NEW)
- `cloudflare/README.md` (NEW)
- `flutter_application_1/lib/core/services/r2_service.dart` (NEW)

### Fichiers Modifies
- `flutter_application_1/lib/di/injection_container.dart` (+R2Service)

---

## Change Log
| Date | Changement | Auteur |
|------|------------|--------|
| 2026-02-02 | Creation de la story | John (PM) |
| 2026-02-02 | Implementation complete | Amelia (Dev) |

---

## Status
complete
