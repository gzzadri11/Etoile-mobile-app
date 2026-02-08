# Story BUG-001: Fix Auto-Login and Messaging Features

Status: ready-for-dev

## Story

As a **utilisateur Etoile**,
I want **me connecter automatiquement si j'ai deja une session et acceder a mes conversations**,
so that **je n'ai pas besoin de me reconnecter a chaque fois et je peux communiquer avec les recruteurs/candidats**.

## Acceptance Criteria

1. **AC1 - Auto-login**: Si un utilisateur a une session Supabase valide, il doit etre redirige automatiquement vers le feed sans passer par l'ecran de bienvenue
2. **AC2 - Session Persistence**: La session doit persister entre les redemarrages de l'application
3. **AC3 - Conversations Load**: La page des conversations doit charger et afficher toutes les conversations de l'utilisateur
4. **AC4 - Error Handling**: Les erreurs doivent etre affichees clairement a l'utilisateur avec possibilite de reessayer
5. **AC5 - Debug Logging**: Les logs de debug doivent permettre de diagnostiquer les problemes d'authentification et de chargement

## Tasks / Subtasks

- [x] Task 1: Fix Auth State Detection (AC: #1, #2)
  - [x] 1.1: Analyser le flux actuel dans app.dart et identifier le probleme de timing
  - [x] 1.2: Implementer une attente fiable de la restauration de session Supabase
  - [x] 1.3: S'assurer que le router est cree APRES que l'etat d'auth soit determine
  - [ ] 1.4: Tester la persistence de session apres fermeture/reouverture de l'app

- [x] Task 2: Fix Conversations Repository (AC: #3, #4)
  - [x] 2.1: Verifier les requetes Supabase dans MessageRepository.getConversations()
  - [x] 2.2: Ajouter gestion d'erreur complete avec messages utilisateur
  - [ ] 2.3: Verifier que les politiques RLS Supabase permettent l'acces aux conversations
  - [ ] 2.4: Tester le chargement des conversations avec donnees reelles

- [x] Task 3: Improve Debug Logging (AC: #5)
  - [x] 3.1: Ajouter logs detailles dans le flux d'authentification
  - [x] 3.2: Ajouter logs detailles dans le chargement des conversations
  - [x] 3.3: S'assurer que les erreurs Supabase sont loggees avec details (code, message)

- [ ] Task 4: Integration Testing
  - [ ] 4.1: Tester le flux complet: login -> fermer app -> rouvrir -> auto-login
  - [ ] 4.2: Tester le flux: auto-login -> aller dans messages -> voir conversations
  - [x] 4.3: Compiler et verifier absence d'erreurs

## Dev Notes

### Architecture Patterns
- **BLoC Pattern**: AuthBloc gere l'etat d'authentification
- **Repository Pattern**: MessageRepository pour les operations Supabase
- **GoRouter**: Redirection basee sur l'etat AuthBloc

### Files to Modify
- `lib/app.dart` - Widget principal, initialisation auth
- `lib/features/auth/presentation/bloc/auth_bloc.dart` - Gestion etat auth
- `lib/features/messages/data/repositories/message_repository.dart` - Operations conversations
- `lib/features/messages/presentation/pages/conversations_page.dart` - UI conversations

### Known Issues
1. **Timing Issue**: Le router est cree avant que Supabase restaure la session
2. **Silent Failures**: Les erreurs dans getConversations() retournent liste vide sans feedback
3. **Type Conflict**: Conflit entre AuthState de notre bloc et celui de Supabase

### Technical Context
- Supabase Flutter SDK avec PKCE auth flow
- Session stockee localement par Supabase
- onAuthStateChange emet des evenements lors de la restauration de session

### References
- [Source: lib/app.dart] - Initialisation application
- [Source: lib/features/auth/presentation/bloc/auth_bloc.dart] - AuthBloc
- [Source: lib/features/messages/data/repositories/message_repository.dart] - MessageRepository
- [Source: lib/core/router/app_router.dart] - Configuration routes

## Dev Agent Record

### Agent Model Used
Claude Opus 4.5 (Amelia - Dev Agent)

### Debug Log References

- Logs d'authentification: `[App] ========== INITIALIZING AUTH ==========`
- Logs de conversations: `[ConversationsPage]` et `[Messages]`

### Completion Notes List

1. **AuthBloc change de Factory a Singleton** - Corrige le probleme d'instances multiples
2. **app.dart reecrit** - Nouvelle logique d'attente de session avec timeout 2s
3. **Debug logging ameliore** - Logs detailles partout
4. **Error handling** - Erreurs Supabase propagees avec details

### File List

- `lib/app.dart` - Reecrit completement
- `lib/di/injection_container.dart` - AuthBloc LazySingleton
- `lib/features/messages/data/repositories/message_repository.dart` - Logging
- `lib/features/messages/presentation/pages/conversations_page.dart` - Logging

