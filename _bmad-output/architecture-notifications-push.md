---
version: 1.0
date: 2026-02-14
author: Winston (Architecte)
status: draft
sprint: 9
prd: prd-notifications-push.md
---

# Architecture : Notifications Push (FCM/APNs)

## 1. Vue d'ensemble

### Flux principal

```
[INSERT messages/conversations]
        |
        v
[Database Webhook (Supabase)]
        |
        v
[Edge Function: send-push]
        |
        ├── Recupere device_tokens du destinataire
        ├── Verifie regles de deduplication
        └── Envoie via FCM HTTP v1 API
                |
                v
        [FCM / APNs]
                |
                v
        [Device mobile]
                |
                ├── App fermee → Notification systeme
                └── App ouverte → Snackbar in-app
```

### Decisions d'architecture

| Decision | Choix | Justification |
|----------|-------|---------------|
| Service push | Firebase Cloud Messaging (FCM) | Couvre Android + iOS, gratuit, fiable |
| Trigger serveur | Database Webhook → Edge Function | Simple, pas de polling, reactif |
| Token storage | Table `device_tokens` dans Supabase | Colocalise avec les donnees, RLS natif |
| Notifications in-app | `flutter_local_notifications` + overlay | Standard Flutter, mature, cross-platform |
| Deep linking | GoRouter existant | Deja en place, pas de nouvelle dependance |

---

## 2. Schema de donnees

### Table `device_tokens`

```sql
CREATE TABLE device_tokens (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token       TEXT NOT NULL,
    platform    VARCHAR(10) NOT NULL CHECK (platform IN ('android', 'ios')),
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, token)
);

CREATE INDEX idx_device_tokens_user ON device_tokens(user_id);

-- RLS
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- Un utilisateur ne peut gerer que ses propres tokens
CREATE POLICY "Users manage own tokens" ON device_tokens
    FOR ALL USING (auth.uid() = user_id);

-- Les Edge Functions (service_role) peuvent lire tous les tokens
CREATE POLICY "Service role read all" ON device_tokens
    FOR SELECT USING (auth.role() = 'service_role');
```

### Table `notification_log` (deduplication)

```sql
CREATE TABLE notification_log (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type            VARCHAR(30) NOT NULL,
    reference_id    UUID,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notif_log_user_type ON notification_log(user_id, type, created_at DESC);

-- Nettoyage auto : supprimer les logs > 7 jours
-- (via pg_cron ou manuellement)
```

---

## 3. Cote serveur (Supabase)

### 3.1 Edge Function `send-push`

**Fichier** : `supabase/functions/send-push/index.ts`

**Responsabilites :**
1. Recevoir l'event webhook (INSERT sur `messages` ou `conversations`)
2. Determiner le type de notification et le destinataire
3. Verifier la deduplication (pas 2 notifs pour la meme conversation < 1 min)
4. Recuperer les `device_tokens` du destinataire
5. Construire le payload FCM
6. Envoyer via FCM HTTP v1 API
7. Nettoyer les tokens invalides (erreur 404/410 de FCM)

**Payload FCM (structure) :**

```typescript
// Nouveau message
{
  message: {
    token: "<FCM_TOKEN>",
    notification: {
      title: "Nouveau message",
      body: "Emma (UDI) : Bonjour, votre profil..."
    },
    data: {
      type: "new_message",
      conversation_id: "<UUID>",
      click_action: "OPEN_CHAT"
    },
    android: {
      priority: "high",
      notification: { channel_id: "messages" }
    },
    apns: {
      payload: {
        aps: { sound: "default", badge: 1 }
      }
    }
  }
}
```

**Authentification FCM :**
- Utiliser un Service Account Google (JSON key)
- Stocker la cle comme secret Supabase : `FIREBASE_SERVICE_ACCOUNT_KEY`
- Generer un access token OAuth2 a la volee pour FCM HTTP v1

### 3.2 Database Webhooks

**Trigger 1 : Nouveau message**
- Table : `messages`
- Event : `INSERT`
- URL : Edge Function `send-push`
- Payload : `{ type: "new_message", record: {...} }`

**Trigger 2 : Nouvelle conversation** (candidature / contact)
- Table : `conversations`
- Event : `INSERT`
- URL : Edge Function `send-push`
- Payload : `{ type: "new_conversation", record: {...} }`

> **Note** : Les webhooks Supabase se configurent dans le Dashboard > Database > Webhooks. Alternative : utiliser un trigger PL/pgSQL + `pg_net` pour appeler la fonction directement.

### 3.3 Rappel profil incomplet (CRON)

**Option choisie** : Edge Function schedulee via `pg_cron`

```sql
-- Executer chaque jour a 10h UTC
SELECT cron.schedule(
    'profile-reminder',
    '0 10 * * *',
    $$
    SELECT net.http_post(
        url := 'https://<PROJECT_REF>.supabase.co/functions/v1/send-push',
        headers := '{"Authorization": "Bearer <SERVICE_ROLE_KEY>", "Content-Type": "application/json"}'::jsonb,
        body := '{"type": "profile_reminder"}'::jsonb
    );
    $$
);
```

La Edge Function `send-push` gere ce type en :
1. Requetant les profils incomplets (< 80% complete) inactifs > 24h
2. Verifiant qu'aucun rappel n'a ete envoye dans les dernieres 24h (`notification_log`)
3. Envoyant la notification FCM

---

## 4. Cote client (Flutter)

### 4.1 Nouveaux packages

```yaml
# pubspec.yaml - ajouter
dependencies:
  firebase_core: ^3.12.1
  firebase_messaging: ^15.2.4
  flutter_local_notifications: ^18.0.1
```

### 4.2 Service de notifications

**Fichier** : `lib/core/services/push_notification_service.dart`

```
PushNotificationService (singleton via GetIt)
├── initialize()           → Config Firebase + permissions
├── _registerToken()       → Sauvegarde token dans device_tokens
├── _onTokenRefresh()      → Met a jour le token si renouvele
├── _onForegroundMessage() → Affiche snackbar in-app
├── _onMessageOpenedApp()  → Navigation deep link
├── removeToken()          → Supprime token au logout
└── _shouldShowNotif()     → Verifie si on est deja sur le chat
```

**Integration dans le flux existant :**

```
main.dart
  └── await Firebase.initializeApp()   ← NOUVEAU
  └── await di.init()
      └── PushNotificationService registered as singleton
  └── runApp()
      └── PushNotificationService.initialize() au premier build

auth_bloc.dart
  └── _onLoginRequested() → PushNotificationService._registerToken()
  └── _onLogoutRequested() → PushNotificationService.removeToken()
```

### 4.3 Foreground handler (snackbar in-app)

Quand l'app est ouverte et recoit un message FCM :

1. `FirebaseMessaging.onMessage` declenche le callback
2. Verifier si l'utilisateur est deja sur le chat concerne :
   - Comparer `data.conversation_id` avec le `conversationId` actif
   - Si meme chat → ignorer (les messages arrivent deja via Realtime)
3. Si different ecran → afficher un `SnackBar` / `MaterialBanner` :
   - Icone + nom expediteur + apercu message
   - Bouton "Voir" → `GoRouter.push(AppRoutes.chatWith(conversationId))`
   - Auto-dismiss apres 4 secondes

**Implementation** : utiliser un `NavigatorObserver` ou un `GlobalKey<NavigatorState>` pour connaitre la route actuelle.

### 4.4 Background handler

```dart
// main.dart (top-level function, hors de toute classe)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // flutter_local_notifications affiche la notification systeme
  // Android : notification automatique via FCM (notification key)
  // iOS : notification automatique via APNs
}
```

### 4.5 Deep linking (tap sur notification)

| Type | Route | Donnees |
|------|-------|---------|
| `new_message` | `AppRoutes.chatWith(conversation_id)` | `conversation_id` |
| `new_conversation` | `AppRoutes.chatWith(conversation_id)` | `conversation_id` |
| `profile_reminder` | `AppRoutes.editProfile` ou `AppRoutes.editRecruiterProfile` | `user_role` |

**Implementation** dans `PushNotificationService` :

```dart
void _handleNotificationTap(RemoteMessage message) {
  final type = message.data['type'];
  final router = GetIt.I<GoRouter>(); // ou navigatorKey

  switch (type) {
    case 'new_message':
    case 'new_conversation':
      final convId = message.data['conversation_id'];
      router.push(AppRoutes.chatWith(convId));
      break;
    case 'profile_reminder':
      final role = message.data['user_role'];
      router.push(role == 'recruiter'
          ? AppRoutes.editRecruiterProfile
          : AppRoutes.editProfile);
      break;
  }
}
```

---

## 5. Configuration Firebase

### 5.1 Fichiers de configuration

| Fichier | Emplacement | Source |
|---------|-------------|--------|
| `google-services.json` | `android/app/` | Firebase Console > Project Settings > Android |
| `GoogleService-Info.plist` | `ios/Runner/` | Firebase Console > Project Settings > iOS |
| Service Account JSON | Secret Supabase | Firebase Console > Service Accounts > Generate Key |

### 5.2 Configuration Android

```
android/app/build.gradle:
  - Plugin: com.google.gms.google-services
  - MinSDK: 21 (deja ok)
  - Notification channel "messages" dans AndroidManifest.xml

android/build.gradle:
  - Classpath: com.google.gms:google-services
```

### 5.3 Configuration iOS

```
ios/Runner/Info.plist:
  - UIBackgroundModes: remote-notification
  - FirebaseAppDelegateProxyEnabled: YES

Xcode:
  - Push Notifications capability
  - Background Modes > Remote notifications
```

---

## 6. Securite

| Aspect | Mesure |
|--------|--------|
| Tokens FCM | Stockes cote serveur uniquement, RLS actif |
| Edge Function | Appelee via webhook interne (service_role) |
| FCM API | Authentification OAuth2 via Service Account |
| Deduplication | `notification_log` empeche le spam |
| Tokens expires | Nettoyage auto sur erreur FCM 404/410 |
| Donnees sensibles | Le contenu du message dans la notif est tronque (max 100 chars) |

---

## 7. Fichiers a creer / modifier

### Nouveaux fichiers

| Fichier | Description |
|---------|-------------|
| `lib/core/services/push_notification_service.dart` | Service principal notifications |
| `supabase/functions/send-push/index.ts` | Edge Function envoi FCM |
| `supabase/migrations/20260214000000_device_tokens.sql` | Migration table device_tokens |
| `android/app/google-services.json` | Config Firebase Android |
| `ios/Runner/GoogleService-Info.plist` | Config Firebase iOS |

### Fichiers a modifier

| Fichier | Modification |
|---------|-------------|
| `pubspec.yaml` | Ajouter firebase_core, firebase_messaging, flutter_local_notifications |
| `lib/main.dart` | Ajouter `Firebase.initializeApp()` + background handler |
| `lib/di/injection_container.dart` | Enregistrer `PushNotificationService` |
| `lib/features/auth/presentation/bloc/auth_bloc.dart` | Appeler registerToken/removeToken |
| `android/app/build.gradle` | Plugin google-services |
| `android/build.gradle` | Classpath google-services |

---

## 8. Diagramme de sequence : Nouveau message

```
Sender          Supabase DB      Webhook       Edge Function     FCM         Receiver
  |                 |                |               |             |              |
  |-- INSERT msg -->|                |               |             |              |
  |                 |-- trigger ---->|               |             |              |
  |                 |                |-- POST ------>|             |              |
  |                 |                |               |-- query --->|              |
  |                 |                |               |  tokens     |              |
  |                 |                |               |<------------|              |
  |                 |                |               |-- check --->|              |
  |                 |                |               |  dedup log  |              |
  |                 |                |               |-- POST ---->|              |
  |                 |                |               |  FCM v1 API |              |
  |                 |                |               |             |-- push ----->|
  |                 |                |               |             |  (native)    |
```

---

*Architecture creee par Winston le 2026-02-14*
*Base sur PRD : prd-notifications-push.md*
