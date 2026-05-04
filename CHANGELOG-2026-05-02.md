# Changelog - 2026-05-02

## 🐛 Bug Fixes

### Affichage des Posters dans le Feed Mobile

**Problème** : Les posters (images statiques d'offres) ne s'affichaient pas dans le feed mobile.

**Cause** : Le widget `_VideoCard` dans `feed_page.dart` utilisait `feedItem.video.videoUrl` pour afficher les posters, alors que les posters stockent leur URL dans `thumbnailUrl`.

**Solution** :
- Modifié `feed_page.dart` ligne ~510 : changé `videoUrl` en `thumbnailUrl` pour les posters
- Mis à jour la documentation du modèle `Video` pour inclure le type 'poster'

**Fichiers modifiés** :
- `flutter_application_1/lib/features/feed/presentation/pages/feed_page.dart`
- `flutter_application_1/lib/features/video/data/models/video_model.dart`

---

## 🗑️ Refactoring

### Suppression du Feed "Entreprises"

**Raison** : Décision produit — les recruteurs ne font plus de vidéos de présentation (type='presentation'), rendant l'onglet "Entreprises" (discover) obsolète.

**Changements** :
- Supprimé l'onglet "Entreprises" de l'interface feed
- Supprimé l'onglet "Offres" (devient l'affichage par défaut unique)
- Simplifié le titre AppBar : "Offres" pour les chercheurs, "ETOILE" pour les autres
- Supprimé la variable `_selectedTab` et la méthode `_switchTab()`

**Note technique** : Le paramètre `feedTab` est conservé dans `FeedBloc` avec la valeur par défaut 'offers', mais le feed 'discover' n'est jamais appelé depuis l'UI.

**Fichiers modifiés** :
- `flutter_application_1/lib/features/feed/presentation/pages/feed_page.dart`

---

## ✨ Nouvelles Fonctionnalités

### Epic 10 Phase 2 : Profil Recruteur Complet (SaaS)

**Objectif** : Finaliser l'expérience profil recruteur avec photo, page Settings complète, et preview mobile pour validation des offres.

#### Story 10.6 : Photo de profil recruteur ✅

- Ajout colonne `recruiter_profiles.photo_url` (migration `20260501000001`)
- Composant `PhotoUploadSection` avec crop circulaire (react-easy-crop)
- Composant `RecruiterAvatar` (3 tailles : sm/md/lg)
- Upload R2 bucket `etoile-photos` (max 5 Mo)
- Server Action `updateRecruiterPhoto` avec RLS

**Fichiers créés** :
- `saas-etoile/components/settings/PhotoUploadSection.tsx`
- `saas-etoile/components/settings/RecruiterAvatar.tsx`
- `supabase/migrations/20260501000001_add_recruiter_photo.sql`

---

#### Story 10.7 : Preview format mobile ✅

- Composant `MobilePreview` avec toggle 9:16 / 16:9
- Validation aspect ratio automatique (badge vert/warning)
- Constantes hard-codées miroir Flutter (iPhone SE 2020)
- Intégration layout 2 colonnes dans `/offers/new`
- Preview temps réel des offres avant publication

**Fichiers créés** :
- `saas-etoile/components/offers/MobilePreview.tsx`
- `saas-etoile/lib/constants/mobile-preview.ts`

**Fichiers modifiés** :
- `saas-etoile/app/(dashboard)/offers/new/page.tsx`

---

#### Story 10.8 : Page Settings complète ✅

- Page Settings avec 7 sections dans Cards séparées
- **Progress bar** : calcul complétude temps réel (5 catégories × 20%)
- **Photo** : réutilisation PhotoUploadSection
- **Entreprise** : nom + secteur (15 secteurs)
- **Description** : Textarea min 50 caractères
- **Adresse** : Autocomplete API Adresse gouvernement (debounce 400ms)
- **SIRET** : Affichage read-only + badge statut vérification
- **Documents** : Upload PDF/JPG/PNG (max 5 Mo) + re-upload si rejeté
- React Hook Form + Zod validation (client + serveur)
- Server Action `updateRecruiterProfile` avec RLS

**Corrections utilisateur appliquées** (4) :
1. ❌ Localisation multi-villes inutile → ✅ Adresse complète unique
2. ❌ Progress bar mal intégrée → ✅ Card dédiée (Option A)
3. ❌ Documents non uploadables → ✅ DocumentUploadSection complet
4. 🆕 Autocomplete manquante → ✅ API Adresse gouvernement

**Fichiers créés** :
- `saas-etoile/lib/validations/recruiter-settings.ts`
- `saas-etoile/lib/utils/profile-completion.ts`
- `saas-etoile/components/settings/ProfileProgressBar.tsx`
- `saas-etoile/components/settings/DocumentUploadSection.tsx`
- `saas-etoile/components/ui/address-autocomplete.tsx`
- `saas-etoile/lib/uploadFile.ts` (générique 3 buckets)
- `saas-etoile/components/ui/form.tsx` (manual)
- `saas-etoile/hooks/use-toast.ts` (MVP console.log)
- `supabase/migrations/20260502000002_add_recruiter_address.sql`

**Fichiers modifiés** :
- `saas-etoile/app/(dashboard)/settings/page.tsx` (rewrite complet 400+ lignes)
- `saas-etoile/app/(dashboard)/settings/actions.ts` (+updateRecruiterProfile)
- `saas-etoile/lib/types/database.ts` (+photo_url, +address)

---

### Récapitulatif Epic 10 Phase 2

**3 stories complétées** : 10.6 (photo), 10.7 (preview), 10.8 (settings)

**Total** : 15 nouveaux fichiers, 4 modifiés, 2 migrations SQL

**Build** : Next.js successful (0 erreurs TypeScript)

---

## ✅ Résultats

### Flutter Mobile
- **Compilation** : 0 erreurs, 2 warnings (prefer_final_fields)
- **Analyse statique** : PASS
- **Tests** : 85/85 passing (inchangé)
- **État** : Prêt pour test sur mobile/émulateur

### SaaS Next.js
- **Build** : Successful (0 erreurs TypeScript)
- **Migrations** : 28/28 déployées
- **État** : Prêt pour test manuel (`npm run dev`)

---

## 📝 Documentation mise à jour

- `_bmad-output/SESSION-RESUME.md` : Nouvelle section Epic 10 Phase 2 complète
- `_bmad-output/10-8-page-settings.md` : Status done + changelog corrections user
- `_bmad-output/sprint-status.yaml` : 10-8 done, Epic 10 Phase 2 done
- `.claude/projects/.../memory/MEMORY.md` : Mise à jour complète (Epic 10 Phase 2, leçons)
- `CLAUDE.md` : Déjà à jour
- `CHANGELOG-2026-05-02.md` : Ce fichier (bugfixes + Epic 10 Phase 2)
