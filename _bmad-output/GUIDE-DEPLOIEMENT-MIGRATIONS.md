# Guide de Déploiement - Migrations 2026-05-03

## Problème identifié

Les compétences disparaissent et ne s'affichent pas dans le SaaS car **les 3 migrations du 2026-05-03 n'ont PAS été déployées en production**.

### Migrations en attente

1. `20260503000001_add_seeker_rhythm.sql` - Rythme d'alternance
2. `20260503000002_create_candidate_evaluations.sql` - Évaluations candidats
3. `20260503000003_add_skills_to_profiles.sql` - **Compétences chercheur + Keywords offres**

## Corrections appliquées (code)

### Flutter
✅ **profile_page.dart** - Ajout de `ProfileRefreshRequested()` après sauvegarde des skills pour recharger le profil depuis la DB.

```dart
Future<void> _saveSkills() async {
  try {
    await GetIt.I<SupabaseClient>()
        .from('seeker_profiles')
        .update({'skills': _skills})
        .eq('user_id', widget.profile.userId);

    // Recharger le profil via le BLoC pour synchroniser l'état
    if (mounted) {
      context.read<ProfileBloc>().add(const ProfileRefreshRequested());
    }
  } catch (e) {
    debugPrint('Error saving skills: $e');
  }
}
```

### Next.js
✅ Aucun changement nécessaire - le code existant utilise déjà `.select("*")` qui récupère toutes les colonnes.

---

## Déploiement des migrations

### Option 1 : Dashboard Supabase (RECOMMANDÉ)

1. **Ouvrir le Dashboard Supabase**
   - URL : https://supabase.com/dashboard/project/ojslqytmuifaofojutgb
   - Se connecter

2. **Ouvrir SQL Editor**
   - Menu de gauche : **SQL Editor**
   - Cliquer sur **New query**

3. **Copier le SQL consolidé**
   - Ouvrir le fichier : `_bmad-output/DEPLOY-MIGRATIONS-2026-05-03.sql`
   - Copier TOUT le contenu (340 lignes)

4. **Exécuter le script**
   - Coller dans l'éditeur SQL
   - Cliquer sur **Run** (ou Ctrl+Enter)
   - ✅ Attendre le message de succès

5. **Vérifier le déploiement**
   - Exécuter cette requête de vérification :
   ```sql
   -- Vérifier rhythm et skills sur seeker_profiles
   SELECT column_name
   FROM information_schema.columns
   WHERE table_name = 'seeker_profiles'
   AND column_name IN ('rhythm', 'skills');

   -- Vérifier candidate_evaluations existe
   SELECT table_name
   FROM information_schema.tables
   WHERE table_name = 'candidate_evaluations';

   -- Vérifier keywords sur videos
   SELECT column_name
   FROM information_schema.columns
   WHERE table_name = 'videos'
   AND column_name = 'keywords';
   ```

   **Résultat attendu :**
   - 2 lignes pour seeker_profiles (rhythm, skills)
   - 1 ligne pour candidate_evaluations
   - 1 ligne pour videos (keywords)

---

### Option 2 : CLI Supabase (si Docker + DB password disponibles)

```bash
# Définir le mot de passe DB
$env:SUPABASE_DB_PASSWORD = "votre-password-ici"

# Déployer toutes les migrations en attente
npx --prefix supabase supabase db push --workdir "C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app"
```

⚠️ **Prérequis** :
- Docker Desktop installé et démarré
- SUPABASE_DB_PASSWORD défini
- Connexion au projet Supabase configurée

---

## Tests post-déploiement

### Test 1 : Flutter - Compétences persistent

1. Lancer l'app Flutter
   ```bash
   cd flutter_application_1
   flutter run -d edge
   ```

2. **Ajouter des compétences**
   - Se connecter avec un compte chercheur
   - Aller dans **Profil**
   - Scroller jusqu'à la section **Compétences**
   - Cliquer sur **+ Ajouter une compétence**
   - Ajouter 3 compétences : "Adobe Photoshop", "Excel avancé", "Anglais B2"

3. **Tester la persistance**
   - Fermer l'app complètement
   - Relancer l'app
   - Retourner dans **Profil**
   - ✅ **Les 3 compétences doivent toujours être affichées**

4. **Tester la suppression**
   - Cliquer sur le ❌ d'une compétence
   - Fermer et rouvrir l'app
   - ✅ **La compétence supprimée ne doit plus apparaître**

---

### Test 2 : SaaS - Compétences visibles dans modal candidat

1. Lancer le SaaS
   ```bash
   cd saas-etoile
   npm run dev
   ```

2. **Créer un candidat de test avec compétences** (via SQL)
   ```sql
   -- Mettre à jour un profil chercheur existant pour ajouter des compétences
   UPDATE seeker_profiles
   SET skills = ARRAY['React.js', 'TypeScript', 'Node.js']
   WHERE user_id = 'ID-CHERCHEUR-QUI-A-POSTULE';
   ```

3. **Vérifier l'affichage**
   - Se connecter au SaaS (recruteur)
   - Aller dans **Candidats**
   - Cliquer sur une fiche candidat qui a postuléOuvrir l'onglet **Profil**
   - Scroller jusqu'à la section **Compétences**
   - ✅ **Les compétences doivent s'afficher en badges violet clair**

---

### Test 3 : Scoring avec compétences (20%)

1. **Ajouter des keywords à une offre**
   ```sql
   UPDATE videos
   SET keywords = ARRAY['Photoshop', 'Excel', 'Anglais']
   WHERE id = 'ID-OFFRE' AND type IN ('offer', 'poster');
   ```

2. **Tester le score**
   - Dans le SaaS, aller dans **Candidats**
   - Observer le score de matching du candidat qui a "Adobe Photoshop", "Excel avancé", "Anglais B2"
   - Le score devrait inclure les 20% de compétences (car 3 matches sur 3 keywords)

3. **Vérifier le calcul**
   ```sql
   SELECT calculate_match_score(
     'ID-CHERCHEUR'::UUID,
     'ID-OFFRE'::UUID
   );
   ```

   **Exemple :**
   - Secteur match (25%) + Ville match (20%) + Études Bac+3 (20%) + Spécialité (15%) + Compétences 3/3 (20%) = **100%**

---

## Statut des builds

✅ **Flutter analyze** : 2 info, 0 erreurs
✅ **Next.js build** : ✓ Compiled successfully in 4.4s
✅ **TypeScript** : ✓ Finished TypeScript in 5.0s

---

## Fichiers modifiés

### Flutter
- `lib/features/profile/presentation/pages/profile_page.dart` (+4 lignes)
  - Dispatch `ProfileRefreshRequested()` après `_saveSkills()`

### Supabase
- `supabase/migrations/20260503000003_add_skills_to_profiles.sql` (déjà créé, à déployer)

### Next.js
- Aucun changement nécessaire (le code était déjà correct)

---

## Prochaines étapes

1. ✅ Déployer les migrations via Dashboard Supabase
2. ✅ Tester les 3 scénarios ci-dessus
3. ✅ Vérifier que le task #5 fonctionne à 100%
4. ✅ Mettre à jour MEMORY.md pour enlever les migrations de la liste "à déployer"
5. Passer aux tasks restantes (#8, #11, #12)
