# Story 0.2: Configuration Supabase

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
**I want** Supabase configure et connecte,
**So that** je puisse utiliser l'auth, la DB et le realtime.

---

## Acceptance Criteria

### AC-1: Variables d'environnement externalisees
**Given** le projet Flutter existe
**When** je configure les variables d'environnement
**Then** les credentials Supabase sont dans un fichier .env
**And** un fichier .env.example documente les variables requises
**And** .env est dans .gitignore

### AC-2: Client Supabase initialise
**Given** les variables d'environnement sont configurees
**When** l'app demarre
**Then** le client Supabase est initialise avec les bonnes credentials
**And** une erreur claire s'affiche si les credentials manquent

### AC-3: Service Supabase accessible
**Given** Supabase est initialise
**When** je veux acceder a Supabase
**Then** un SupabaseService est disponible via GetIt
**And** il expose auth, database, storage, et realtime

### AC-4: Verification de connexion
**Given** Supabase est initialise
**When** je teste la connexion
**Then** je peux verifier que la connexion au backend fonctionne
**And** les erreurs de connexion sont logguees

---

## Tasks/Subtasks

### Task 1: Ajouter flutter_dotenv
- [x] 1.1 Ajouter flutter_dotenv dans pubspec.yaml
- [x] 1.2 Creer le fichier .env.example avec les variables requises
- [x] 1.3 Creer le fichier .env avec valeurs placeholder
- [x] 1.4 Ajouter .env au .gitignore

### Task 2: Mettre a jour AppConfig
- [x] 2.1 Modifier AppConfig pour charger depuis dotenv
- [x] 2.2 Ajouter validation des variables requises
- [x] 2.3 Gerer les valeurs par defaut pour dev/staging/prod

### Task 3: Creer SupabaseService
- [x] 3.1 Creer lib/core/services/supabase_service.dart
- [x] 3.2 Exposer auth, database (from), storage, realtime
- [x] 3.3 Ajouter methode de verification de connexion
- [x] 3.4 Enregistrer dans injection_container.dart

### Task 4: Mettre a jour main.dart
- [x] 4.1 Charger dotenv avant Supabase
- [x] 4.2 Ajouter gestion d'erreur si init echoue
- [x] 4.3 Logger la configuration en mode debug

### Task 5: Documentation
- [x] 5.1 Mettre a jour le README du projet Flutter
- [x] 5.2 Documenter le setup Supabase requis

---

## Dev Notes

### Packages ajoutes
- flutter_dotenv: ^5.1.0

### Variables d'environnement requises
- SUPABASE_URL
- SUPABASE_ANON_KEY

### Structure fichiers
```
flutter_application_1/
├── .env                    # Credentials reelles (gitignored)
├── .env.example            # Template pour les devs
├── lib/
│   └── core/
│       ├── config/
│       │   └── app_config.dart     # Charge depuis dotenv
│       └── services/
│           └── supabase_service.dart  # Nouveau service
```

---

## Dev Agent Record

### Implementation Plan
1. Ajouter flutter_dotenv au projet
2. Creer .env et .env.example
3. Refactoriser AppConfig pour charger depuis dotenv
4. Creer SupabaseService avec accesseurs pratiques
5. Mettre a jour main.dart avec gestion d'erreurs
6. Mettre a jour injection_container.dart
7. Documenter dans README

### Debug Log
- Aucun probleme rencontre
- Toutes les modifications syntaxiquement correctes

### Completion Notes
Implementation complete de la configuration Supabase:

**Configuration:**
- Variables d'environnement via flutter_dotenv
- .env.example avec toutes les variables documentees
- .env ajoute au .gitignore
- Validation des variables requises au demarrage

**SupabaseService:**
- Accesseurs pour auth, database, storage, realtime, functions
- Methodes utilitaires (currentUser, isAuthenticated, userId)
- Verification de connexion avec latence
- Gestion de session (signOut, refreshSession)

**Gestion d'erreurs:**
- ConfigurationErrorApp si .env invalide
- InitializationErrorApp si erreur inattendue
- Logging en mode debug

**Documentation:**
- README complet avec setup instructions
- Structure de projet documentee

---

## File List

### Fichiers Crees
- `flutter_application_1/.env.example` (NEW)
- `flutter_application_1/.env` (NEW)
- `flutter_application_1/lib/core/services/supabase_service.dart` (NEW)

### Fichiers Modifies
- `flutter_application_1/pubspec.yaml` (+flutter_dotenv, +.env asset)
- `flutter_application_1/.gitignore` (+.env)
- `flutter_application_1/lib/core/config/app_config.dart` (refactored)
- `flutter_application_1/lib/main.dart` (refactored)
- `flutter_application_1/lib/di/injection_container.dart` (+SupabaseService)
- `flutter_application_1/README.md` (rewritten)

---

## Change Log
| Date | Changement | Auteur |
|------|------------|--------|
| 2026-02-02 | Creation de la story | John (PM) |
| 2026-02-02 | Implementation complete | Amelia (Dev) |

---

## Status
complete
