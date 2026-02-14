---
status: draft
date: 2026-02-14
author: John (PM)
projectName: Etoile Mobile App
feature: Notifications Push (FCM/APNs)
priority: haute
sprint: 9
---

# PRD : Notifications Push

## Contexte

L'app Etoile dispose d'une messagerie temps reel fonctionnelle (Supabase Realtime). Cependant, les utilisateurs ne sont pas notifies quand ils ne sont pas dans l'app ou quand ils sont sur un autre ecran. Cela entraine des messages rates et un engagement reduit.

## Probleme

1. Un chercheur postule via le feed → le recruteur ne le sait pas s'il n'est pas dans l'app
2. Un recruteur envoie un message → le chercheur ne le voit que s'il ouvre manuellement l'onglet Messages
3. Les profils incomplets restent incomplets faute de rappel

## Objectifs

- Augmenter le taux de reponse aux messages (cible : < 2h de delai moyen)
- Reduire le taux de profils incomplets
- Zero message rate quand l'app est fermee

---

## Notifications supportees

| # | Event | Destinataire | Titre | Corps (exemple) |
|---|-------|-------------|-------|-----------------|
| 1 | **Nouveau message** | Expediteur oppose | Nouveau message | "Emma (UDI) : Bonjour, votre profil..." |
| 2 | **Nouvelle candidature** | Recruteur | Nouvelle candidature | "Lucas Martin a postule a votre offre" |
| 3 | **Nouveau contact** | Chercheur | Un recruteur vous contacte | "UDI (BTP) souhaite vous contacter" |
| 4 | **Rappel profil incomplet** | Chercheur ou Recruteur | Completez votre profil | "Votre profil est a 60%. Completez-le pour plus de visibilite" |

---

## Comportement

### En background (app fermee ou en arriere-plan)
- Notification systeme native (barre de notifications Android/iOS)
- Son + vibration (parametres par defaut du systeme)
- Tap sur la notification → ouvre l'app sur l'ecran concerne (chat, profil...)

### In-app (app ouverte, autre ecran)
- Bandeau/snackbar en haut de l'ecran pendant 4 secondes
- Affiche l'icone, le nom de l'expediteur et un apercu du message
- Bouton "Voir" pour naviguer directement vers le chat/profil
- **Exception** : pas de notification si l'utilisateur est deja sur le chat concerne

### Regles de deduplication
- Pas de notification pour ses propres messages
- Maximum 1 notification par conversation par minute (eviter le spam)
- Rappel profil incomplet : 1 fois par jour maximum, apres 24h d'inactivite

---

## Plateformes

| Plateforme | Technologie | Priorite |
|------------|-------------|----------|
| Android | Firebase Cloud Messaging (FCM) | P0 |
| iOS | Apple Push Notification Service (APNs) via FCM | P0 |
| Web | Hors scope v1 | - |

---

## Architecture technique (haut niveau)

### Cote client (Flutter)
1. **Package** : `firebase_messaging` + `flutter_local_notifications`
2. **Enregistrement** : au login, enregistrer le token FCM dans une table `device_tokens`
3. **Foreground handler** : afficher le snackbar in-app
4. **Background handler** : notification systeme native
5. **Deep linking** : navigation vers le bon ecran au tap

### Cote serveur (Supabase)
1. **Table `device_tokens`** : `user_id`, `token`, `platform`, `created_at`
2. **Database Webhook ou Edge Function** : trigger sur INSERT dans `messages` et `conversations`
3. **Edge Function `send-push`** : recoit l'event, recupere le token FCM du destinataire, envoie via FCM HTTP v1 API
4. **Rappel profil** : Supabase CRON job quotidien (pg_cron) ou Edge Function scheduled

### Firebase
1. Creer un projet Firebase (ou utiliser un existant)
2. Configurer Android : `google-services.json`
3. Configurer iOS : certificat APNs + `GoogleService-Info.plist`
4. Service account key pour l'Edge Function (FCM HTTP v1)

---

## Criteres d'acceptation

### Nouveau message
- [ ] L'utilisateur recoit une notification push quand il recoit un message et n'est pas sur le chat concerne
- [ ] Le tap sur la notification ouvre le chat correspondant
- [ ] In-app : un snackbar s'affiche avec apercu du message
- [ ] Pas de notification si l'utilisateur est sur le chat concerne

### Nouvelle candidature / contact
- [ ] Le recruteur recoit une notification quand un chercheur postule
- [ ] Le chercheur recoit une notification quand un recruteur le contacte
- [ ] Le tap ouvre la conversation creee

### Rappel profil incomplet
- [ ] Notification envoyee si le profil est < 80% complete et inactif > 24h
- [ ] Maximum 1 rappel par jour
- [ ] Le tap ouvre la page d'edition du profil

### General
- [ ] Les notifications fonctionnent sur Android et iOS
- [ ] Les tokens FCM sont enregistres au login et supprimes au logout
- [ ] Les tokens expires/invalides sont nettoyes automatiquement

---

## Hors scope (v1)

- Notifications web (push browser)
- Preferences de notification (activer/desactiver par type)
- Notifications par email
- Notifications pour "profil vu" ou "video vue X fois"
- Badge de compteur sur l'icone de l'app

---

## Estimation

| Tache | Effort |
|-------|--------|
| Setup Firebase + config Android/iOS | 1h |
| Table `device_tokens` + migration SQL | 15 min |
| Enregistrement token cote Flutter | 30 min |
| Edge Function `send-push` (FCM) | 1h |
| Database webhook trigger | 30 min |
| Foreground handler (snackbar in-app) | 1h |
| Background handler + deep linking | 1h |
| Rappel profil incomplet (cron) | 45 min |
| Tests E2E (2 devices) | 1h |

**Total estime : ~7h**

---

## Fichiers concernes

| Fichier | Action |
|---------|--------|
| `pubspec.yaml` | Ajouter firebase_messaging, flutter_local_notifications |
| `android/app/google-services.json` | Config Firebase Android |
| `ios/Runner/GoogleService-Info.plist` | Config Firebase iOS |
| `lib/core/services/push_notification_service.dart` | Nouveau - service notifications |
| `lib/di/injection_container.dart` | Enregistrer le service |
| `lib/main.dart` | Initialiser Firebase + notifications |
| `supabase/migrations/new_device_tokens.sql` | Table device_tokens |
| `supabase/functions/send-push/index.ts` | Edge Function FCM |

---

*PRD cree par John (PM) le 2026-02-14*
