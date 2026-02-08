# Etoile Video Worker

Cloudflare Worker pour la gestion du stockage video via R2.

## Fonctionnalites

- Generation de presigned URLs pour upload securise
- Streaming video avec support des range requests
- Gestion des thumbnails
- Validation JWT Supabase
- CORS configure pour l'app mobile

## Prerequisites

1. Compte Cloudflare avec Workers et R2 actives
2. Node.js 18+
3. Wrangler CLI

## Installation

```bash
# Installer les dependances
npm install

# Se connecter a Cloudflare
npx wrangler login
```

## Configuration

### 1. Creer les buckets R2

Dans le dashboard Cloudflare > R2:

```
etoile-videos-dev       # Development
etoile-thumbnails-dev

etoile-videos-staging   # Staging
etoile-thumbnails-staging

etoile-videos-prod      # Production
etoile-thumbnails-prod
```

### 2. Configurer les secrets

```bash
# JWT secret de Supabase (Settings > API > JWT Secret)
npx wrangler secret put SUPABASE_JWT_SECRET
```

### 3. Configurer wrangler.toml

Mettre a jour `account_id` avec votre ID Cloudflare.

## Deploiement

```bash
# Development
npm run dev

# Staging
npm run deploy:staging

# Production
npm run deploy:production
```

## Endpoints

### POST /presigned-url

Genere une URL presignee pour upload.

**Headers:**
- `Authorization: Bearer <jwt_token>`

**Body:**
```json
{
  "filename": "video.mp4",
  "contentType": "video/mp4",
  "type": "video"
}
```

**Response:**
```json
{
  "uploadUrl": "https://worker.../upload/...",
  "key": "user-id/1234567890.mp4",
  "expiresAt": "2026-02-02T12:00:00Z",
  "method": "PUT"
}
```

### PUT /upload/:token

Upload le fichier vers R2.

**Headers:**
- `Content-Type: video/mp4`

**Body:** Binary file data

**Response:**
```json
{
  "success": true,
  "key": "user-id/1234567890.mp4",
  "url": "https://worker.../video/user-id/1234567890.mp4",
  "size": 15000000
}
```

### GET /video/:key

Stream une video avec support range requests (pour seeking).

**Response:** Video stream avec headers de cache.

### GET /thumbnail/:key

Recupere une thumbnail.

### DELETE /video/:key

Supprime une video (authentification requise, ownership verifie).

### GET /health

Health check.

## Architecture

```
Mobile App
    |
    v
[Cloudflare Worker]  <-- Valide JWT, gere presigned URLs
    |
    v
[Cloudflare R2]  <-- Stockage video (egress gratuit)
    |
    v
[Cloudflare CDN]  <-- Cache edge global
```

## Securite

- JWT Supabase valide pour toutes les operations d'ecriture
- Ownership verifie pour suppression (key prefixee par user ID)
- CORS restreint en production
- Presigned URLs avec expiration (1h par defaut)

## Limites

| Parametre | Valeur |
|-----------|--------|
| Taille max video | 50 MB |
| Duree presigned URL | 1 heure |
| Cache video | 1 an (immutable) |
| Cache thumbnail | 1 semaine |

## Monitoring

```bash
# Voir les logs en temps reel
npm run tail
```

## Troubleshooting

### "Unauthorized" sur presigned-url

- Verifier que le token JWT est valide
- Verifier que SUPABASE_JWT_SECRET est configure

### Upload echoue

- Verifier la taille du fichier (< 50 MB)
- Verifier le Content-Type
- Verifier que le token n'est pas expire

### Video 404

- Verifier que l'upload a reussi
- Verifier le nom du bucket dans wrangler.toml
