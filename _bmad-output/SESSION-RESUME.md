# Session BMAD - Etoile Mobile App

**Date de mise a jour** : 2026-02-08
**Statut** : Feed par Profil implemente et teste - Pret pour prochaine feature

---

## Pour reprendre

```bash
# 1. Ouvrir le terminal dans le projet
cd C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app\flutter_application_1

# 2. Lancer l'app sur Edge
flutter run -d edge
```

Puis tape `/bmad` et dis : **"reprend la ou on s'est arrete"**

---

## Historique des changements

### 2026-02-07 - Flutter SDK deplace
- **Ancien emplacement** : D:\src\flutter (corrompu, supprime)
- **Nouveau emplacement** : `C:\Users\gzzad\flutter`
- **PATH** mis a jour automatiquement (variable utilisateur)
- **Version** : Flutter 3.38.9 (channel stable)
- **Developer Mode** Windows active (necessaire pour les symlinks)

### 2026-02-07/08 - Feed par Profil (TERMINE)
Implementation complete de la fonctionnalite Feed par Profil :

**Agents BMAD utilises** :
- PM (John) : PRD cree → `_bmad-output/prd-feed-par-profil.md`
- Architect (Winston) : Architecture technique → `_bmad-output/architecture-feed-par-profil.md`
- Dev (Amelia) : Implementation des 6 fichiers

**6 fichiers modifies** :
1. `feed_item_model.dart` - Champs `experienceLevel`, `salaryExpectation`, `sector` + filtres par role
2. `feed_repository.dart` - Methodes `getSeekerFeed()`, `getRecruiterFeed()`, `getSectors()`, filtres specifiques
3. `feed_event.dart` - `FeedLoadRequested` avec `userRole` requis
4. `feed_state.dart` - `FeedLoaded` avec `userRole`, getters `isSeeker`/`isRecruiter`
5. `feed_bloc.dart` - Routing `_getFeedByRole()` (seeker/recruiter/mixed)
6. `feed_page.dart` - Boutons "Postuler"/"Contacter", filtres adaptes par role

**Bug fix** : `Navigator.of(context, rootNavigator: true)` dans `_startConversation()` - corrige l'assertion error lors du clic sur Postuler/Contacter (dialog pop sur mauvais navigator avec GoRouter)

**Tests** : Compile sans erreur, app fonctionne sur Edge, feed charge correctement

---

## Resume complet du projet

### Ce qui fonctionne

| Fonctionnalite | Statut | Sprint |
|----------------|--------|--------|
| Connexion Supabase | OK | 1 |
| Cloudflare R2 (2 buckets) | OK | 1 |
| Base de donnees (12 tables + RLS) | OK | 1 |
| Trigger creation profil | OK | 1 |
| Inscription (chercheur/recruteur) | OK | 2 |
| Connexion / Deconnexion | OK | 2 |
| Mot de passe oublie | OK | 2 |
| Navigation GoRouter | OK | 2 |
| Affichage profil (donnees reelles) | OK | 3 |
| Edition profil chercheur | OK | 3 |
| Structure video (model, bloc, repo) | OK | 4 |
| Feed vertical TikTok-style | OK | 5 |
| Prechargement 2 videos suivantes | OK | 5 |
| Bouton Profil (bottom sheet) | OK | 5 |
| Bouton Message (creation conversation) | OK | 6 |
| **Feed par Profil (chercheur vs recruteur)** | **OK** | **7** |
| **Filtres specifiques par role** | **OK** | **7** |
| **Boutons Postuler / Contacter** | **OK** | **7** |

### Ce qui reste a faire

| # | Tache | Priorite | Prerequis |
|---|-------|----------|-----------|
| 1 | Edition profil recruteur | Moyenne | Aucun |
| 2 | Test camera + upload R2 | Moyenne | Mobile Android |
| 3 | Configuration Stripe | Basse | Compte Stripe |

---

## Sprints completes

### Sprint 1 - Infrastructure
- Supabase : projet `etoile-app` (West EU Paris)
- Cloudflare R2 : buckets `etoile-videos` et `etoile-thumbnails`
- 12 tables creees avec Row Level Security
- Trigger `on_auth_user_created` pour creation auto du profil

### Sprint 2 - Authentification
- Page Welcome avec choix chercheur/recruteur
- Inscription avec validation
- Connexion avec Supabase Auth
- Reinitialisation mot de passe
- Redirection automatique selon etat auth

### Sprint 3 - Profils
- Modeles `SeekerProfile` et `RecruiterProfile`
- `ProfileRepository` pour acces Supabase
- `ProfileBloc` pour gestion d'etat
- Page edition profil chercheur complete

### Sprint 4 - Videos (structure prete)
- Modele `Video`
- `VideoRepository` pour CRUD
- `VideoBloc` pour enregistrement/upload
- Interface UI des 3 phases (10s + 20s + 10s)
- Camera a tester sur mobile

### Sprint 5-6 - Feed + Messagerie
- Feed vertical TikTok-style avec PageView
- Prechargement videos (2 ahead/behind)
- Filtres (metier, localisation, disponibilite)
- Boutons Profil (bottom sheet) et Message
- Creation de conversation Supabase

### Sprint 7 - Feed par Profil (NEW)
- Feed specifique par role (seeker voit offres, recruiter voit presentations)
- Boutons d'action contextualises (Postuler vs Contacter)
- Filtres chercheur : Secteur, Localisation, Type de contrat
- Filtres recruteur : Competences, Experience, Disponibilite, Pretention salariale
- Fix navigation dialog avec rootNavigator

---

## Fichiers cles

```
flutter_application_1/
├── lib/
│   ├── app.dart                    # Widget principal + GoRouter
│   ├── main.dart                   # Init Supabase
│   ├── di/injection_container.dart # Injection dependances
│   ├── core/
│   │   ├── config/app_config.dart  # Variables .env
│   │   └── router/app_router.dart  # Routes
│   └── features/
│       ├── auth/presentation/bloc/auth_bloc.dart
│       ├── profile/
│       │   ├── data/models/seeker_profile_model.dart
│       │   ├── data/models/recruiter_profile_model.dart
│       │   ├── data/repositories/profile_repository.dart
│       │   └── presentation/bloc/profile_bloc.dart
│       ├── feed/
│       │   ├── data/models/feed_item_model.dart       # Feed par Profil
│       │   ├── data/repositories/feed_repository.dart  # Feed par Profil
│       │   ├── presentation/bloc/feed_bloc.dart        # Feed par Profil
│       │   ├── presentation/bloc/feed_event.dart       # Feed par Profil
│       │   ├── presentation/bloc/feed_state.dart       # Feed par Profil
│       │   └── presentation/pages/feed_page.dart       # Feed par Profil
│       ├── messages/
│       │   └── data/repositories/conversation_repository.dart
│       └── video/
│           ├── data/models/video_model.dart
│           └── data/repositories/video_repository.dart
├── .env                            # Cles Supabase + R2
└── pubspec.yaml
```

---

## Identifiants

### Supabase
- **Dashboard** : https://supabase.com/dashboard
- **Projet** : etoile-app
- **Region** : West EU (Paris)
- **Credentials** : dans `.env`

### Cloudflare R2
- **Dashboard** : https://dash.cloudflare.com → R2
- **Buckets** : etoile-videos, etoile-thumbnails
- **API Keys** : dans `.env`

### Flutter SDK
- **Emplacement** : `C:\Users\gzzad\flutter`
- **Version** : 3.38.9 (stable)

---

## Commandes utiles

```bash
# Lancer l'app sur Edge (rapide, pas besoin d'emulateur)
cd C:\Users\gzzad\Documents\IDEES\ETOILE\Etoile-mobile-app\flutter_application_1
flutter run -d edge

# Lancer l'emulateur Android
flutter emulators --launch Medium_Phone_API_36.1
flutter run -d emulator-5554

# Verifier les erreurs
flutter analyze

# Voir les appareils
flutter devices

# Regenerer les dependances
flutter clean && flutter pub get
```

---

*Sauvegarde mise a jour le 2026-02-08*
*Prochaine etape : Edition profil recruteur ou autre feature au choix*
