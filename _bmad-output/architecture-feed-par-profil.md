---
status: validated
date: 2026-02-07
author: Winston (Architect)
projectName: Etoile Mobile App
feature: Flux Video Specifique par Profil
relatedPrd: prd-feed-par-profil.md
---

# Architecture Technique - Feed par Profil

## Principe

Minimum de changements, maximum d'impact. Un seul FeedBloc, un seul repository, strategie de chargement basee sur le role. Pas de duplication.

## 1. Couche Data - FeedRepository

### Nouvelles methodes

```dart
/// Feed pour les chercheurs : videos d'offres de recruteurs verifies
Future<List<FeedItem>> getSeekerFeed({
  int limit = 20,
  int offset = 0,
  FeedFilters? filters,
})

/// Feed pour les recruteurs : videos de presentation de chercheurs
Future<List<FeedItem>> getRecruiterFeed({
  int limit = 20,
  int offset = 0,
  FeedFilters? filters,
})
```

### Requetes Supabase

**getSeekerFeed** :
1. Requete `videos` WHERE `status = 'active'` AND `type = 'offer'`
2. Fetch `recruiter_profiles` pour les user_ids des videos
3. Filtrer `verification_status = 'verified'`
4. Appliquer filtres chercheur (sector, region, contractType)

**getRecruiterFeed** :
1. Requete `videos` WHERE `status = 'active'` AND `type = 'presentation'`
2. Fetch `seeker_profiles` pour les user_ids des videos
3. Appliquer filtres recruteur (categories, experienceLevel, availability, salaryExpectation)

### getMixedFeed conserve
- Utilise comme fallback si role inconnu
- Utile pour un eventuel role admin

## 2. Couche BLoC

### FeedEvent - Modifications

```dart
class FeedLoadRequested extends FeedEvent {
  final String userRole; // 'seeker' ou 'recruiter'
  const FeedLoadRequested({required this.userRole});
}
```

### FeedState - Modifications

```dart
class FeedLoaded extends FeedState {
  final String userRole; // Stocke pour loadMore/refresh
  // ... reste identique
}
```

### FeedBloc - Logique de routage

```dart
Future<void> _onLoadRequested(...) async {
  final role = event.userRole;

  final items = switch (role) {
    'seeker' => await _feedRepository.getSeekerFeed(...),
    'recruiter' => await _feedRepository.getRecruiterFeed(...),
    _ => await _feedRepository.getMixedFeed(...),
  };

  emit(FeedLoaded(items: items, userRole: role, ...));
}
```

## 3. Couche Model

### FeedItem - Ajouts

```dart
class FeedItem {
  // Existants conserves
  final Video video;
  final String userName;
  final String? userTitle, userLocation, userAvatarUrl;
  final bool isRecruiter, isVerified;
  final String? region, city, availability;
  final List<String> categories, contractTypes;

  // NOUVEAUX
  final String? experienceLevel;    // Pour filtre recruteur
  final String? salaryExpectation;  // Pour filtre recruteur
  final String? sector;             // Pour filtre chercheur
}
```

### FeedFilters - Modifications

```dart
class FeedFilters {
  // Conserves
  final String? categoryId, categoryName, region, contractType, availability;

  // NOUVEAUX
  final String? sector;           // Filtre chercheur
  final String? experienceLevel;  // Filtre recruteur
  final String? salaryRange;      // Filtre recruteur

  // SUPPRIMES
  // showSeekersOnly, showRecruitersOnly → plus necessaires
}
```

## 4. Couche Presentation - FeedPage

### Boutons d'action dynamiques

```dart
// Dans _VideoCard
Column(
  children: [
    if (userRole == 'seeker')
      _ActionButton(
        icon: Icons.send_outlined,
        label: 'Postuler',
        onTap: () => _startConversation(context),
      )
    else
      _ActionButton(
        icon: Icons.person_add_outlined,
        label: 'Contacter',
        onTap: () => _startConversation(context),
      ),
    _ActionButton(
      icon: Icons.person_outline,
      label: 'Profil',
      onTap: () => _onProfileTap(context),
    ),
  ],
)
```

### Filtres dynamiques

**Chercheur** : Secteur, Localisation, Type de contrat
**Recruteur** : Competences, Niveau d'experience, Disponibilite, Pretention salariale

## 5. Fichiers a modifier

| Fichier | Modification | Complexite |
|---------|-------------|------------|
| `feed_repository.dart` | +getSeekerFeed() +getRecruiterFeed() | Moyenne |
| `feed_event.dart` | +userRole dans FeedLoadRequested | Faible |
| `feed_state.dart` | +userRole dans FeedLoaded | Faible |
| `feed_bloc.dart` | Router selon le role | Faible |
| `feed_item_model.dart` | +champs + modifier FeedFilters | Faible |
| `feed_page.dart` | Boutons dynamiques + filtres par role | Moyenne |

## 6. Ce qu'on ne touche PAS

- Routing (app_router.dart) - route /feed reste unique
- MainScaffold - navigation bottom identique
- Systeme de messagerie - _startConversation() reutilise tel quel
- Badges (Verifie, Entreprise) - conserves
- VideoPreloadManager - inchange
- Modeles de profil (seeker_profile_model, recruiter_profile_model)

## 7. Ordre d'implementation recommande

1. `feed_item_model.dart` (ajout champs + FeedFilters)
2. `feed_repository.dart` (nouvelles methodes)
3. `feed_event.dart` + `feed_state.dart` (ajout userRole)
4. `feed_bloc.dart` (routage)
5. `feed_page.dart` (UI dynamique)
6. Test manuel sur Edge
