# Diagnostic - Compétences invisibles dans SaaS

## Étape 1 : Vérifier que les migrations sont déployées

**Dashboard Supabase** → **SQL Editor** → Coller et exécuter :

```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'seeker_profiles'
AND column_name = 'skills';
```

**Résultat attendu :** 1 ligne avec `skills | ARRAY`

❌ **Si 0 lignes** → Les migrations ne sont PAS déployées !
→ Retour à `DEPLOY-MIGRATIONS-2026-05-03.sql`

---

## Étape 2 : Vérifier qu'un candidat a des compétences

**Dashboard Supabase** → **SQL Editor** → Coller et exécuter :

```sql
-- Trouver les candidats qui ont postulé
SELECT
  sp.user_id,
  sp.first_name,
  sp.last_name,
  sp.username,
  sp.skills,
  array_length(sp.skills, 1) as nb_skills,
  a.id as application_id
FROM applications a
INNER JOIN seeker_profiles sp ON sp.user_id = a.seeker_id
WHERE a.status IN ('pending', 'contacted')
ORDER BY a.applied_at DESC
LIMIT 10;
```

**Attendu :** Voir la colonne `skills` et `nb_skills`

❌ **Si skills = NULL ou {} pour tous** → Aucun candidat n'a de compétences !
→ Passer à l'étape 3 pour ajouter des compétences de test

---

## Étape 3 : Ajouter des compétences de test

**Copie un `user_id`** de l'étape 2, puis :

```sql
-- Remplace USER_ID_ICI par un vrai UUID
UPDATE seeker_profiles
SET skills = ARRAY['React.js', 'TypeScript', 'Node.js', 'Figma']
WHERE user_id = 'USER_ID_ICI';

-- Vérifier
SELECT user_id, first_name, skills
FROM seeker_profiles
WHERE user_id = 'USER_ID_ICI';
```

**Attendu :** Voir `{React.js,TypeScript,Node.js,Figma}`

---

## Étape 4 : Tester dans le SaaS avec debug

### 4.1 Lancer le SaaS

```bash
cd saas-etoile
npm run dev
```

### 4.2 Ouvrir la Console DevTools

- Navigateur : Appuyer sur **F12**
- Onglet **Console**

### 4.3 Tester le modal candidat

1. Aller sur **Candidats**
2. Cliquer sur la fiche du candidat qui a des compétences (étape 3)
3. **Regarder la console** → Tu dois voir :

```
🔍 DEBUG Candidate Modal - Full data: {
  userId: "...",
  firstName: "...",
  skills: ["React.js", "TypeScript", "Node.js", "Figma"],
  skillsType: "object",
  skillsIsArray: true,
  skillsLength: 4,
  fullSeeker: {...}
}
```

### 4.4 Diagnostic selon le résultat

#### ✅ CAS 1 : skills = ["React.js", "TypeScript", ...] ET length = 4
→ **Les données sont bien chargées !**
→ Problème = rendu conditionnel dans candidate-modal.tsx
→ Cherche la ligne 319 : `{seeker.skills && seeker.skills.length > 0 && (...)}`
→ Vérifie que la section Compétences s'affiche dans l'onglet **Profil**

#### ❌ CAS 2 : skills = null ou undefined
→ **Les données ne sont PAS chargées depuis la DB**
→ Problème = query dans `app/(dashboard)/candidates/page.tsx` ligne 83
→ Vérifie que `.select("*")` récupère bien toutes les colonnes

#### ❌ CAS 3 : skills = [] (tableau vide)
→ **Les données sont chargées mais vides**
→ Le profil en base n'a pas de compétences
→ Retour à l'étape 3 pour ajouter des compétences

#### ❌ CAS 4 : Erreur "column skills does not exist"
→ **Les migrations ne sont PAS déployées**
→ Retour à `DEPLOY-MIGRATIONS-2026-05-03.sql`

---

## Étape 5 : Solutions selon diagnostic

### Si CAS 1 (données OK mais pas affichées)

Vérifier que le code de rendu est correct dans `candidate-modal.tsx` :

```typescript
{/* Compétences */}
{seeker.skills && seeker.skills.length > 0 && (
  <>
    <div>
      <h3 className="text-base font-semibold mb-3">Compétences</h3>
      <div className="flex flex-wrap gap-2">
        {seeker.skills.map((skill, idx) => (
          <span
            key={idx}
            className="inline-flex items-center px-3 py-1.5 rounded-full text-sm font-medium bg-primary/10 text-primary border border-primary/20"
          >
            {skill}
          </span>
        ))}
      </div>
    </div>
    <Separator />
  </>
)}
```

**Vérifier** :
- Cette section est bien dans l'onglet **Profil** (TabsContent value="profile")
- Elle est placée APRÈS la section Domain et AVANT la section Candidature

---

### Si CAS 2 (données null/undefined)

Le problème est dans le chargement des données. Vérifier `app/(dashboard)/candidates/page.tsx` ligne 81-85 :

```typescript
// Fetch seeker profile
const { data: seekerProfile } = await supabase
  .from("seeker_profiles")
  .select("*")  // ⚠️ Doit inclure skills
  .eq("user_id", app.seeker_id)
  .single();
```

**Solution** : Forcer un rechargement en dur :
1. Fermer le navigateur SaaS
2. Redémarrer le serveur dev : `npm run dev`
3. Recharger la page Candidats (Ctrl+Shift+R pour vider cache)

---

### Si CAS 4 (migrations non déployées)

**URGENT** : Déployer les migrations via Dashboard Supabase

1. Ouvrir `_bmad-output/DEPLOY-MIGRATIONS-2026-05-03.sql`
2. Copier TOUT le contenu
3. Dashboard Supabase → SQL Editor → New query
4. Coller et **Run**
5. Retour à l'étape 1 pour vérifier

---

## Checklist finale

- [ ] Migrations déployées (étape 1 ✅)
- [ ] Candidat avec compétences existe (étape 2-3 ✅)
- [ ] Console debug affiche les skills (étape 4 ✅)
- [ ] Section Compétences visible dans modal (étape 5 ✅)

---

## Si problème persiste

Envoie-moi :
1. **Screenshot de la console debug** (étape 4.3)
2. **Screenshot de l'étape 2** (query SQL candidats)
3. **Message d'erreur exact** si erreur visible
