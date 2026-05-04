# Changelog - 2026-05-03 - Task #5 : Compétences Chercheur ✅

## Résumé
Implémentation complète de la section "Compétences" pour les chercheurs d'alternance, incluant :
- Interface Flutter interactive (ajout/suppression de tags)
- Affichage SaaS dans le modal candidat
- Intégration au scoring de matching (20% du score total)
- Persistance en base PostgreSQL (TEXT[])

## Migrations déployées (3)

### 1. `20260503000001_add_seeker_rhythm.sql`
- Ajout colonne `rhythm VARCHAR` à `seeker_profiles`
- Support des 11 rythmes d'alternance officiels

### 2. `20260503000002_create_candidate_evaluations.sql`
- Table `candidate_evaluations` (rating 3 états + notes privées)
- RLS policies complètes
- Index sur recruiter_id et application_id

### 3. `20260503000003_add_skills_to_profiles.sql` ⭐
- Colonne `skills TEXT[]` à `seeker_profiles` (DEFAULT '{}')
- Colonne `keywords TEXT[]` à `videos` (DEFAULT '{}')
- Index GIN pour recherche rapide
- Fonction `calculate_match_score()` mise à jour (+20% skills)
- Trigger `trigger_update_match_scores()` mis à jour

## Code modifié

### Flutter

**`lib/features/profile/data/models/seeker_profile_model.dart`**
- Ajout property `skills` (List<String>)
- fromJson/toJson/copyWith/props mis à jour

**`lib/features/profile/presentation/pages/profile_page.dart`** (+250 lignes)
- Widget `_SkillsSection` : affichage + gestion state local
- Widget `_SkillTag` : badge supprimable
- Bottom sheet ajout compétence (TextField + validation)
- **Fix critique** : dispatch `ProfileRefreshRequested()` après sauvegarde

### SaaS

**`saas-etoile/lib/types/database.ts`**
- Interface `SeekerProfile.skills: string[]`
- Interface `Video.keywords: string[]`

**`saas-etoile/components/candidates/candidate-modal.tsx`**
- Section "Compétences" avec badges violet clair
- Rendu conditionnel `seeker.skills && seeker.skills.length > 0`
- Debug console temporaire (à retirer en prod)

## Tests

### Flutter
```bash
flutter analyze
# Résultat : 2 info (prefer_final_fields), 0 erreurs
```

### SaaS
```bash
npm run build
# Résultat : ✓ Compiled successfully in 4.4s
```

### Tests manuels validés ✅
1. ✅ Ajout de 3 compétences via Flutter
2. ✅ Fermeture et réouverture de l'app → compétences toujours présentes
3. ✅ Affichage des compétences dans le modal SaaS
4. ✅ Suppression d'une compétence → persistence OK

## Problèmes résolus

### Problème 1 : Compétences disparaissaient après fermeture
**Cause** : Migrations non déployées + manque de refresh du BLoC
**Solution** : Déploiement migrations + ajout `ProfileRefreshRequested()`

### Problème 2 : Section invisible dans SaaS
**Cause** : Colonne `skills` inexistante en base (migration non déployée)
**Solution** : Déploiement via Dashboard Supabase SQL Editor

## Scoring compétences (20%)

**Algorithme** :
```
IF offre.keywords IS NOT NULL AND length > 0 THEN
  IF chercheur.skills IS NOT NULL AND length > 0 THEN
    matches = count fuzzy matches (case insensitive)
    score = (matches / keywords_count) * 20  [plafonné à 20]
  ELSE
    score = 0  (chercheur sans compétences)
  END IF
ELSE
  score = 10  (offre sans keywords → score neutre 50%)
END IF
```

**Exemple** :
- Offre keywords : ["Photoshop", "Excel", "Anglais"]
- Chercheur skills : ["Adobe Photoshop", "Excel avancé", "Anglais B2"]
- Matches : 3/3 → **score compétences = 20/20** ✅

## Score total mis à jour

**Nouvelle répartition** :
- Secteur : 25%
- Ville : 20%
- Études : 20%
- Compétences : 20% ⭐ **NOUVEAU**
- Spécialité : 15%

**Total** : 100%

## Fichiers de référence créés

- `_bmad-output/DEPLOY-MIGRATIONS-2026-05-03.sql` - Script consolidé 3 migrations
- `_bmad-output/GUIDE-DEPLOIEMENT-MIGRATIONS.md` - Guide détaillé (si besoin)
- `_bmad-output/VERIFY-MIGRATIONS.sql` - Vérifications post-déploiement
- `_bmad-output/TEST-ADD-SKILLS.sql` - Script ajout compétences test
- `_bmad-output/DIAGNOSTIC-SKILLS-SAAS.md` - Troubleshooting complet

## État final

- **Migrations** : 30/30 déployées ✅
- **Tests Flutter** : 85/85 passing ✅
- **Build SaaS** : OK ✅
- **Task #5** : ✅ VALIDÉ

## Prochaines étapes

Tasks restantes :
- #8 : Offre - support format vidéo
- #11 : Formulaire offre - bouton Retour
- #12 : Favoris - sauvegarder offres
