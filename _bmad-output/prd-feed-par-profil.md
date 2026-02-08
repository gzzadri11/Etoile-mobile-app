---
status: validated
date: 2026-02-07
author: John (PM)
projectName: Etoile Mobile App
feature: Flux Video Specifique par Profil
priority: haute
---

# PRD : Flux Video Specifique par Profil

## Probleme

Le feed actuel (`getMixedFeed()`) affiche un flux identique pour tous les utilisateurs, qu'ils soient chercheurs d'emploi ou recruteurs. Cela reduit la pertinence du contenu et l'engagement utilisateur.

**Comportement actuel :** Un seul flux melange les videos de tous les types d'utilisateurs.
**Comportement souhaite :** Chaque role voit un flux adapte a ses besoins.

---

## Solution

### 1. Feed Chercheur d'emploi (Seeker)

| Aspect | Detail |
|--------|--------|
| **Contenu** | Uniquement les videos de type `offer` publiees par des recruteurs verifies |
| **Action principale** | Bouton **"Postuler"** → ouvre une conversation directe avec le recruteur |
| **Filtres disponibles** | Secteur d'activite, Localisation (region/ville), Type de contrat (CDI, CDD, Freelance...) |

### 2. Feed Recruteur (Recruiter)

| Aspect | Detail |
|--------|--------|
| **Contenu** | Uniquement les videos de type `presentation` publiees par des chercheurs |
| **Action principale** | Bouton **"Contacter"** → ouvre une conversation directe avec le candidat |
| **Filtres disponibles** | Competences/categories, Niveau d'experience, Disponibilite, Pretention salariale |

---

## Specifications Fonctionnelles

### Detection du role
- Le role est extrait de `user.userMetadata['role']` (deja en place)
- Le `FeedBloc` utilise le role pour determiner quel type de feed charger
- Valeurs possibles : `seeker`, `recruiter`

### Repository Feed
- **Scinder** `getMixedFeed()` en deux methodes :
  - `getSeekerFeed()` : requete sur videos ou `type = 'offer'` et createur est recruteur verifie
  - `getRecruiterFeed()` : requete sur videos ou `type = 'presentation'` et createur est chercheur
- Les filtres sont passes en parametres et appliques cote requete

### Interface Feed
- Le bouton d'action a droite change selon le role :
  - Chercheur : icone "Postuler" (enveloppe/candidature) → navigation vers `/messages/:conversationId`
  - Recruteur : icone "Contacter" (message) → navigation vers `/messages/:conversationId`
- Le panneau de filtres affiche les options adaptees au role
- Les badges visuels existants sont conserves (Entreprise, Verifie)

### Filtres Chercheur
| Filtre | Source | Type |
|--------|--------|------|
| Secteur d'activite | `recruiter_profiles.sector` | Selection liste |
| Localisation | `recruiter_profiles.locations` | Region/Ville |
| Type de contrat | `videos.metadata` ou tag associe | Multi-selection (CDI, CDD, Freelance, Stage, Alternance) |

### Filtres Recruteur
| Filtre | Source | Type |
|--------|--------|------|
| Competences/Categories | `seeker_profiles.categories` | Multi-selection |
| Niveau d'experience | `seeker_profiles.experienceLevel` | Selection liste |
| Disponibilite | `seeker_profiles.availability` | Selection liste |
| Pretention salariale | `seeker_profiles.salaryExpectation` | Fourchette |

---

## Hors Scope (v1)

- Algorithme de matching intelligent (recommandation basee sur IA)
- Systeme de favoris / candidats sauvegardes
- Propositions d'entretien structurees
- Notifications push pour nouveaux contenus pertinents

---

## Metriques de Succes

| Metrique | Objectif |
|----------|----------|
| Taux d'engagement feed | +30% vs feed generique |
| Taux d'utilisation "Postuler"/"Contacter" | >15% des sessions |
| Temps passe sur le feed | +20% |
| Taux d'utilisation des filtres | >25% des utilisateurs actifs |

---

## Fichiers concernes (estimation)

| Fichier | Modification |
|---------|-------------|
| `lib/features/feed/data/repositories/feed_repository.dart` | Ajouter `getSeekerFeed()` et `getRecruiterFeed()` |
| `lib/features/feed/presentation/bloc/feed_bloc.dart` | Detecter le role et appeler le bon repository |
| `lib/features/feed/presentation/bloc/feed_event.dart` | Ajouter le role dans `FeedLoadRequested` |
| `lib/features/feed/presentation/pages/feed_page.dart` | Boutons d'action et filtres dynamiques par role |
| `lib/features/feed/data/models/feed_filters_model.dart` | Filtres specifiques par role |
