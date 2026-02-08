---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9]
status: validated
lastStep: "Étape 9 - Validation Finale"
date: 2026-02-01
validatedAt: 2026-02-01
author: John (PM)
projectName: Etoile Mobile App
---

# PRD Draft: Etoile Mobile App

## Classification Projet

| Critère | Valeur |
|---------|--------|
| **Type** | Mobile App Flutter (iOS + Android) |
| **Domaine** | HR Tech / Recrutement |
| **Complexité** | Moyenne-Haute |
| **Contexte** | Greenfield (nouveau produit) |

---

## Décisions Techniques

| Aspect | Décision |
|--------|----------|
| **Hébergement vidéo** | Cloudflare R2 (recommandé - egress gratuit) |
| **Paiements** | Stripe (CB direct, hors Apple/Google Pay) |
| **Vérification recruteurs** | SIRET + document (manuel MVP, auto V2) |

---

## Critères de Succès

### Succès Utilisateur

**Chercheurs d'emploi :**
| Critère | Mesure | Objectif |
|---------|--------|----------|
| Succès ultime | Obtention d'un emploi via Etoile | Premiers cas documentés à M3 |
| Qualité des contacts | Messages de recruteurs vérifiés uniquement | 100% des contacts = recruteurs authentifiés |
| Expérience de publication | Temps pour publier sa première vidéo | < 5 minutes après inscription |

**Recruteurs :**
| Critère | Mesure | Objectif |
|---------|--------|----------|
| ROI perçu | Vues sur les offres + choix de candidats | Croissance visible mois après mois |
| Gain de temps | Élimination du tri CV | Accès direct aux vidéos = décision plus rapide |

### Succès Business

| Métrique | M1 | M3 | M12 |
|----------|-----|-----|-----|
| Utilisateurs totaux | 1 000 | 5 000 | 15 000 |
| MAU | - | 2 500 | 7 000 |
| Ratio Chercheurs/Recruteurs | 70/30 (MVP) | 60/40 | 50/50 (cible) |
| Premier paiement | M1 | - | - |

### Succès Technique

| Critère | Objectif MVP | Objectif Excellence |
|---------|--------------|---------------------|
| Temps chargement vidéo | < 2 secondes | < 1 seconde |
| Disponibilité (uptime) | 99.5% | 99.9% (stable 24/7) |

---

## Modèle Économique

### Chercheurs

| Mode | Fonctionnalités | Prix |
|------|-----------------|------|
| **Gratuit** | Publier 1 vidéo/catégorie, parcourir offres, recevoir messages | 0€ |
| **Premium** | Voir qui a vu sa vidéo, statistiques | ~5€/mois |

### Recruteurs

| Mode | Vidéo | Affiche | Prix |
|------|-------|---------|------|
| **Gratuit** | 1 vidéo (40s, importable) | 1 affiche | 0€ |
| **Premium** | 2 vidéos + 2 affiches /semaine + stats | Voir qui a vu | ~500€/mois |
| **À l'unité** | +1 vidéo | +1 affiche | ~100€ / ~50€ |

**Note importante :**
- Chercheurs = enregistrement via app UNIQUEMENT (authenticité)
- Recruteurs = peuvent IMPORTER leurs vidéos (flexibilité pro)

---

## Périmètre MVP

### Modules essentiels
- Authentification (email/mot de passe, choix rôle)
- Profils (chercheur avec critères, recruteur avec SIRET)
- Vidéo (enregistrement 40s in-app pour chercheurs, import pour recruteurs)
- Feed (scroll vertical, filtres basiques)
- Contact direct (accès coordonnées, messagerie texte)
- Paiements (Stripe, abonnements premium)
- Back-office (vérification manuelle recruteurs)

### Non inclus MVP
- Messages vocaux, appels in-app
- Likes, favoris
- Vérification automatique SIRET
- Version web
- Multi-langue

---

## Exigences Non-Fonctionnelles

> **Réponses utilisateur collectées :** Les paramètres ci-dessous ont été définis suite aux questions NF1-NF4 posées au product owner.

### NF1 - Performance et Charge

**Réponse utilisateur :** 500 utilisateurs simultanés au début, pics à 2000

| Paramètre | Valeur |
|-----------|--------|
| **Utilisateurs simultanés (nominal)** | 500 |
| **Utilisateurs simultanés (pic)** | 2 000 |
| **Temps de réponse API** | < 500ms (P95) |
| **Temps de chargement vidéo** | < 2s (démarrage lecture) |

**Implications techniques :**
- Architecture backend scalable (serverless ou auto-scaling recommandé)
- CDN Cloudflare pour la distribution vidéo (R2 + Workers)
- Cache agressif côté client (métadonnées, thumbnails)
- Pagination et lazy loading obligatoires sur les feeds
- Base de données dimensionnée pour 10x la charge nominale (marge de croissance)

### NF2 - Disponibilité

**Réponse utilisateur :** 24/7 dès le MVP

| Paramètre | Valeur |
|-----------|--------|
| **Disponibilité cible** | 24/7 dès le MVP |
| **SLA interne** | 99.5% uptime (MVP), 99.9% (post-MVP) |
| **Maintenance planifiée** | Fenêtres nocturnes uniquement (2h-5h CET) |

**Implications techniques :**
- Monitoring et alerting dès le jour 1 (ex: Sentry, Uptime Robot)
- Pas de single point of failure critique
- Procédure de rollback documentée
- Backup automatique des données (quotidien minimum)
- Architecture multi-AZ ou serverless pour haute disponibilité

### NF3 - Données Personnelles et Conformité

**Réponse utilisateur :** Rien de spécial requis (conformité RGPD standard)

| Paramètre | Valeur |
|-----------|--------|
| **Hébergement EU obligatoire** | Non requis |
| **DPO dédié** | Non requis |
| **Conformité RGPD** | Standard (mentions légales, consentement, droit à l'oubli) |

**Implications techniques :**
- Politique de confidentialité standard
- Mécanisme de suppression de compte (hard delete ou anonymisation)
- Export des données utilisateur sur demande (RGPD Art. 20)
- Pas de transfert de données vers pays tiers sans garanties
- Conservation des vidéos supprimées : 30 jours max avant purge définitive

### NF4 - Support Utilisateur

**Réponse utilisateur :** FAQ/Centre d'aide

| Paramètre | Valeur |
|-----------|--------|
| **Canal principal** | FAQ / Centre d'aide in-app |
| **Support humain** | Email uniquement (MVP) |
| **Temps de réponse cible** | 48h ouvrées |

**Implications techniques :**
- Page FAQ/Aide accessible depuis le menu principal de l'app
- Contenu FAQ : webview ou page native avec recherche
- Formulaire de contact avec email de support
- Pas de chat live ni hotline au MVP
- Documentation des cas d'usage courants (vidéo rejetée, paiement échoué, etc.)
- Base de connaissance extensible pour V2

---

## User Stories

### Epic 1 : Inscription et Profil

**US-1.1 : Inscription Chercheur**
> En tant que chercheur d'emploi, je veux créer un compte avec mon email pour accéder à l'application.

Critères d'acceptation :
- [ ] Formulaire : email, mot de passe, confirmation mot de passe
- [ ] Validation email (format + unicité)
- [ ] Mot de passe : 8 caractères minimum
- [ ] Choix du rôle "Chercheur" à l'inscription
- [ ] Email de confirmation envoyé

**US-1.2 : Inscription Recruteur**
> En tant que recruteur, je veux créer un compte professionnel pour publier des offres.

Critères d'acceptation :
- [ ] Formulaire : email pro, mot de passe, nom entreprise, SIRET
- [ ] Upload document justificatif (Kbis, carte pro)
- [ ] Statut "En attente de vérification" après inscription
- [ ] Notification par email quand compte validé/refusé

**US-1.3 : Compléter profil Chercheur**
> En tant que chercheur, je veux renseigner mes critères de recherche pour être visible des bons recruteurs.

Critères d'acceptation :
- [ ] Secteur d'activité recherché (liste déroulante)
- [ ] Type de contrat (CDI, CDD, alternance, stage)
- [ ] Zone géographique souhaitée
- [ ] Disponibilité (immédiate, 1 mois, 3 mois)
- [ ] Profil modifiable à tout moment

**US-1.4 : Compléter profil Recruteur**
> En tant que recruteur vérifié, je veux personnaliser mon profil entreprise.

Critères d'acceptation :
- [ ] Logo entreprise (upload image)
- [ ] Description entreprise (500 caractères max)
- [ ] Secteur d'activité
- [ ] Localisation(s) des postes

---

### Epic 2 : Vidéo Chercheur

**US-2.1 : Enregistrer ma vidéo de présentation**
> En tant que chercheur, je veux enregistrer une vidéo de 40 secondes pour me présenter aux recruteurs.

Critères d'acceptation :
- [ ] Accès caméra frontale
- [ ] Chronomètre visible (décompte 40s)
- [ ] Arrêt automatique à 40s
- [ ] Prévisualisation avant validation
- [ ] Option "Recommencer" illimitée
- [ ] Pas d'import externe (enregistrement in-app uniquement)

**US-2.2 : Publier ma vidéo dans une catégorie**
> En tant que chercheur, je veux associer ma vidéo à une catégorie métier pour être trouvé.

Critères d'acceptation :
- [ ] Choix d'une catégorie parmi la liste prédéfinie
- [ ] 1 seule vidéo par catégorie (remplacement si nouvelle)
- [ ] Vidéo visible dans le feed après upload réussi
- [ ] Notification de confirmation

**US-2.3 : Modifier/Supprimer ma vidéo**
> En tant que chercheur, je veux pouvoir remplacer ou supprimer ma vidéo.

Critères d'acceptation :
- [ ] Bouton "Remplacer" = nouvel enregistrement
- [ ] Bouton "Supprimer" avec confirmation
- [ ] Suppression effective sous 24h (RGPD)

---

### Epic 3 : Vidéo et Affiche Recruteur

**US-3.1 : Publier une offre vidéo**
> En tant que recruteur, je veux publier une vidéo de présentation de mon offre d'emploi.

Critères d'acceptation :
- [ ] Import vidéo depuis galerie OU enregistrement in-app
- [ ] Durée max : 40 secondes (découpage automatique si > 40s)
- [ ] Ajout titre du poste + catégorie
- [ ] Compte gratuit : 1 vidéo max
- [ ] Compte premium : 2 vidéos/semaine

**US-3.2 : Publier une affiche**
> En tant que recruteur, je veux publier une affiche (image) pour une offre.

Critères d'acceptation :
- [ ] Upload image (JPG, PNG)
- [ ] Format recommandé affiché (9:16)
- [ ] Ajout titre du poste + catégorie
- [ ] Compte gratuit : 1 affiche max
- [ ] Compte premium : 2 affiches/semaine

**US-3.3 : Gérer mes publications**
> En tant que recruteur, je veux voir et gérer toutes mes publications actives.

Critères d'acceptation :
- [ ] Liste de mes vidéos et affiches
- [ ] Statut (active, expirée, supprimée)
- [ ] Actions : modifier, supprimer, renouveler
- [ ] Compteur de vues (premium)

---

### Epic 4 : Feed et Découverte

**US-4.1 : Parcourir les vidéos candidats (Recruteur)**
> En tant que recruteur, je veux parcourir les vidéos de candidats pour trouver des profils.

Critères d'acceptation :
- [ ] Feed vertical scrollable (style TikTok)
- [ ] Lecture automatique avec son désactivé par défaut
- [ ] Tap pour activer/désactiver le son
- [ ] Informations affichées : prénom, catégorie, localisation
- [ ] Swipe haut = vidéo suivante

**US-4.2 : Filtrer les candidats (Recruteur)**
> En tant que recruteur, je veux filtrer les candidats par critères.

Critères d'acceptation :
- [ ] Filtre par catégorie métier
- [ ] Filtre par zone géographique
- [ ] Filtre par disponibilité
- [ ] Filtres cumulables
- [ ] Bouton "Réinitialiser filtres"

**US-4.3 : Parcourir les offres (Chercheur)**
> En tant que chercheur, je veux parcourir les offres des recruteurs.

Critères d'acceptation :
- [ ] Feed vertical (vidéos + affiches mélangées)
- [ ] Badge "Entreprise vérifiée" visible
- [ ] Informations : nom entreprise, titre poste, localisation
- [ ] Accès au profil entreprise en tapant

**US-4.4 : Filtrer les offres (Chercheur)**
> En tant que chercheur, je veux filtrer les offres par critères.

Critères d'acceptation :
- [ ] Filtre par catégorie métier
- [ ] Filtre par type de contrat
- [ ] Filtre par zone géographique
- [ ] Sauvegarde des filtres préférés

---

### Epic 5 : Contact et Messagerie

**US-5.1 : Contacter un candidat (Recruteur)**
> En tant que recruteur, je veux contacter un candidat qui m'intéresse.

Critères d'acceptation :
- [ ] Bouton "Contacter" sur la vidéo du candidat
- [ ] Accès aux coordonnées (email, téléphone si fourni)
- [ ] Ouverture messagerie in-app
- [ ] Notification au candidat

**US-5.2 : Recevoir et répondre aux messages (Chercheur)**
> En tant que chercheur, je veux voir et répondre aux messages des recruteurs.

Critères d'acceptation :
- [ ] Liste des conversations
- [ ] Badge "Non lu" sur les nouveaux messages
- [ ] Réponse en texte libre
- [ ] Info recruteur visible (entreprise, poste concerné)

**US-5.3 : Bloquer un recruteur (Chercheur)**
> En tant que chercheur, je veux pouvoir bloquer un recruteur indésirable.

Critères d'acceptation :
- [ ] Option "Bloquer" dans la conversation
- [ ] Confirmation requise
- [ ] Plus de messages possibles après blocage
- [ ] Ma vidéo invisible pour ce recruteur

---

### Epic 6 : Paiements et Abonnements

**US-6.1 : Souscrire à Premium (Chercheur)**
> En tant que chercheur, je veux souscrire à l'offre Premium pour voir mes statistiques.

Critères d'acceptation :
- [ ] Page détaillant les avantages Premium
- [ ] Prix affiché : ~5€/mois
- [ ] Paiement par carte via Stripe
- [ ] Activation immédiate après paiement
- [ ] Reçu par email

**US-6.2 : Souscrire à Premium (Recruteur)**
> En tant que recruteur, je veux souscrire à l'offre Premium pour plus de publications.

Critères d'acceptation :
- [ ] Page détaillant les avantages Premium
- [ ] Prix affiché : ~500€/mois
- [ ] Paiement par carte via Stripe
- [ ] Possibilité de facture entreprise
- [ ] Activation immédiate

**US-6.3 : Acheter à l'unité (Recruteur)**
> En tant que recruteur, je veux acheter des publications supplémentaires à l'unité.

Critères d'acceptation :
- [ ] +1 vidéo : ~100€
- [ ] +1 affiche : ~50€
- [ ] Paiement Stripe
- [ ] Crédit ajouté immédiatement au compte

**US-6.4 : Gérer mon abonnement**
> En tant qu'utilisateur premium, je veux gérer mon abonnement.

Critères d'acceptation :
- [ ] Voir date de renouvellement
- [ ] Voir historique des paiements
- [ ] Annuler l'abonnement (effet à la fin de la période)
- [ ] Modifier moyen de paiement

---

### Epic 7 : Administration (Back-office)

**US-7.1 : Valider les recruteurs**
> En tant qu'admin, je veux valider manuellement les inscriptions recruteurs.

Critères d'acceptation :
- [ ] Liste des recruteurs en attente
- [ ] Visualisation SIRET + document uploadé
- [ ] Actions : Approuver / Rejeter (avec motif)
- [ ] Email automatique au recruteur

**US-7.2 : Modérer les contenus**
> En tant qu'admin, je veux pouvoir supprimer des contenus inappropriés.

Critères d'acceptation :
- [ ] Liste des signalements utilisateurs
- [ ] Visualisation du contenu signalé
- [ ] Actions : Ignorer / Supprimer / Bannir utilisateur
- [ ] Notification à l'utilisateur concerné

**US-7.3 : Voir les statistiques globales**
> En tant qu'admin, je veux voir les métriques clés de la plateforme.

Critères d'acceptation :
- [ ] Nombre d'utilisateurs (total, par rôle)
- [ ] Nombre de vidéos/affiches publiées
- [ ] Nombre de messages échangés
- [ ] Revenus (abonnements + achats)
- [ ] Graphiques d'évolution

---

### Epic 8 : Support et Aide

**US-8.1 : Accéder à la FAQ**
> En tant qu'utilisateur, je veux accéder à une FAQ pour résoudre mes problèmes courants.

Critères d'acceptation :
- [ ] Section "Aide" accessible depuis le menu
- [ ] Questions organisées par thème
- [ ] Recherche dans la FAQ
- [ ] Lien vers formulaire de contact si non résolu

**US-8.2 : Contacter le support**
> En tant qu'utilisateur, je veux contacter le support si la FAQ ne suffit pas.

Critères d'acceptation :
- [ ] Formulaire : sujet, description, captures d'écran optionnelles
- [ ] Email de confirmation d'envoi
- [ ] Réponse sous 48h ouvrées

---

## Risques et Dépendances

### Risques Identifiés

| ID | Risque | Probabilité | Impact | Mitigation |
|----|--------|-------------|--------|------------|
| R1 | **Rejet Apple/Google Store** (politique vidéo ou paiements) | Moyenne | Critique | Revue des guidelines avant dev, prévoir ajustements UI |
| R2 | **Fraude recruteurs** (faux SIRET, arnaques) | Haute | Haute | Vérification manuelle stricte MVP, signalement utilisateurs |
| R3 | **Contenus inappropriés** (vidéos offensantes) | Moyenne | Haute | Modération réactive, bouton signaler, suspension automatique après X signalements |
| R4 | **Faible adoption initiale** (poule et l'oeuf) | Haute | Haute | Stratégie d'acquisition ciblée, contenu "seed" au lancement |
| R5 | **Coûts Cloudflare R2 sous-estimés** | Basse | Moyenne | Monitoring consommation, compression vidéo agressive |
| R6 | **Problèmes Stripe hors Apple/Google Pay** | Moyenne | Moyenne | Bien communiquer le choix, UX de paiement irréprochable |
| R7 | **RGPD - Demandes de suppression** | Certaine | Basse | Processus automatisé de suppression, documentation |
| R8 | **Indisponibilité service tiers** (Stripe, Cloudflare) | Basse | Haute | Choix de providers fiables, fallback messages d'erreur clairs |

### Dépendances Externes

| ID | Dépendance | Type | Criticité | Contact/Lien |
|----|------------|------|-----------|--------------|
| D1 | **Cloudflare R2** | Infrastructure vidéo | Critique | cloudflare.com |
| D2 | **Stripe** | Paiements | Critique | stripe.com |
| D3 | **Apple App Store** | Distribution iOS | Critique | App Store Connect |
| D4 | **Google Play Store** | Distribution Android | Critique | Google Play Console |
| D5 | **Service email transactionnel** | Notifications | Haute | (à définir: SendGrid, Resend, etc.) |
| D6 | **Service de vérification SIRET** (V2) | Automatisation | Moyenne | (API INSEE ou partenaire) |

### Dépendances Internes

| ID | Dépendance | Équipe/Ressource | Criticité | Statut |
|----|------------|------------------|-----------|--------|
| DI1 | **Design UI/UX** | Designer | Haute | À recruter/externaliser |
| DI2 | **Backend API** | Développeur backend | Critique | À définir |
| DI3 | **App Flutter** | Développeur mobile | Critique | À définir |
| DI4 | **DevOps/Infra** | DevOps ou backend | Haute | À définir |
| DI5 | **Modérateur contenu** | Opérations | Moyenne | Manuel par fondateur au MVP |
| DI6 | **Support utilisateur** | Opérations | Moyenne | Manuel par fondateur au MVP |

---

## Spécifications Techniques

### Architecture Globale

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            CLIENTS                                       │
│  ┌─────────────────┐                    ┌─────────────────┐             │
│  │  iOS App        │                    │  Android App    │             │
│  │  (Flutter/Dart) │                    │  (Flutter/Dart) │             │
│  └────────┬────────┘                    └────────┬────────┘             │
└───────────┼──────────────────────────────────────┼──────────────────────┘
            │                                      │
            └──────────────┬───────────────────────┘
                           │ HTTPS
                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         CLOUDFLARE                                       │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐     │
│  │      CDN        │    │    Workers      │    │       R2        │     │
│  │  (Cache global) │    │  (Edge compute) │    │ (Stockage vidéo)│     │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘     │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           BACKEND                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    API REST (Node.js/Express)                    │   │
│  │              OU Supabase (Backend-as-a-Service)                  │   │
│  │              OU Firebase (Alternative)                           │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                  │                                       │
│         ┌────────────────────────┼────────────────────────┐             │
│         ▼                        ▼                        ▼             │
│  ┌─────────────┐         ┌─────────────┐         ┌─────────────┐       │
│  │ PostgreSQL  │         │   Redis     │         │   Stripe    │       │
│  │ (Database)  │         │  (Cache)    │         │ (Paiements) │       │
│  └─────────────┘         └─────────────┘         └─────────────┘       │
└─────────────────────────────────────────────────────────────────────────┘
```

### Stack Technique

| Couche | Technologie | Justification |
|--------|-------------|---------------|
| **Frontend** | Flutter 3.x / Dart | Cross-platform iOS + Android, une seule codebase |
| **Backend** | Supabase (recommandé) | Auth intégrée, PostgreSQL, temps réel, open-source |
| | *Alternative 1* : Firebase | Écosystème Google, rapide à setup |
| | *Alternative 2* : Node.js + Express | Contrôle total, plus de flexibilité |
| **Base de données** | PostgreSQL | Robuste, scalable, support JSON natif |
| **Stockage vidéo** | Cloudflare R2 | Egress gratuit, compatible S3, CDN intégré |
| **CDN** | Cloudflare | Performance globale, protection DDoS |
| **Paiements** | Stripe | Fiabilité, API moderne, conformité PCI |
| **Email transactionnel** | Resend ou SendGrid | Délivrabilité, templates |
| **Monitoring** | Sentry + Uptime Robot | Erreurs temps réel, alertes uptime |

### API Endpoints Principaux

#### Authentification (`/api/v1/auth`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/auth/register` | Inscription (email, password, role) |
| POST | `/auth/login` | Connexion (retourne JWT) |
| POST | `/auth/refresh` | Renouvellement du token |
| POST | `/auth/forgot-password` | Demande de réinitialisation |
| POST | `/auth/reset-password` | Réinitialisation avec token |
| POST | `/auth/logout` | Déconnexion (invalidation token) |

#### Utilisateurs (`/api/v1/users`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/users/profile` | Récupérer mon profil |
| PUT | `/users/profile` | Mettre à jour mon profil |
| GET | `/users/preferences` | Récupérer mes préférences |
| PUT | `/users/preferences` | Mettre à jour mes préférences |
| DELETE | `/users/account` | Supprimer mon compte (RGPD) |
| GET | `/users/:id/public` | Profil public d'un utilisateur |

#### Vidéos (`/api/v1/videos`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/videos/upload` | Upload vidéo (retourne presigned URL R2) |
| GET | `/videos/stream/:id` | URL de streaming vidéo |
| GET | `/videos/my` | Mes vidéos publiées |
| PUT | `/videos/:id` | Modifier métadonnées vidéo |
| DELETE | `/videos/:id` | Supprimer une vidéo |
| POST | `/videos/:id/report` | Signaler une vidéo |

#### Feed (`/api/v1/feed`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/feed/seekers` | Feed candidats (pour recruteurs) |
| GET | `/feed/recruiters` | Feed offres (pour chercheurs) |
| GET | `/feed/filters` | Options de filtres disponibles |
| POST | `/feed/filters/save` | Sauvegarder filtres préférés |

#### Messages (`/api/v1/messages`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/messages/conversations` | Liste des conversations |
| GET | `/messages/conversations/:id` | Messages d'une conversation |
| POST | `/messages/send` | Envoyer un message |
| PUT | `/messages/:id/read` | Marquer comme lu |
| POST | `/messages/block/:userId` | Bloquer un utilisateur |

#### Paiements (`/api/v1/payments`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/payments/subscribe` | Créer un abonnement |
| POST | `/payments/one-time` | Achat à l'unité |
| GET | `/payments/subscription` | Statut de mon abonnement |
| POST | `/payments/cancel` | Annuler l'abonnement |
| GET | `/payments/history` | Historique des paiements |
| POST | `/payments/webhook` | Webhook Stripe (événements) |

#### Administration (`/api/v1/admin`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/admin/recruiters/pending` | Recruteurs en attente |
| POST | `/admin/recruiters/:id/approve` | Approuver un recruteur |
| POST | `/admin/recruiters/:id/reject` | Rejeter un recruteur |
| GET | `/admin/reports` | Signalements en attente |
| POST | `/admin/reports/:id/action` | Traiter un signalement |
| GET | `/admin/stats` | Statistiques globales |

### Modèle de Données Simplifié

```sql
-- Table Utilisateurs
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    role            VARCHAR(20) NOT NULL CHECK (role IN ('seeker', 'recruiter', 'admin')),
    email_verified  BOOLEAN DEFAULT FALSE,
    is_premium      BOOLEAN DEFAULT FALSE,
    status          VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'pending', 'suspended', 'deleted')),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Profils Chercheurs
CREATE TABLE seeker_profiles (
    user_id         UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    phone           VARCHAR(20),
    region          VARCHAR(100),
    city            VARCHAR(100),
    category        VARCHAR(100),           -- Secteur recherché
    contract_type   VARCHAR(50),            -- CDI, CDD, alternance, stage
    experience      VARCHAR(50),            -- junior, confirmé, senior
    availability    VARCHAR(50),            -- immediate, 1_month, 3_months
    bio             TEXT,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Profils Recruteurs
CREATE TABLE recruiter_profiles (
    user_id         UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    company_name    VARCHAR(255) NOT NULL,
    siret           VARCHAR(14) NOT NULL,
    document_url    VARCHAR(500),           -- URL du justificatif (Kbis, etc.)
    logo_url        VARCHAR(500),
    description     TEXT,
    sector          VARCHAR(100),
    locations       TEXT[],                 -- Zones géographiques
    verified        BOOLEAN DEFAULT FALSE,
    verified_at     TIMESTAMP WITH TIME ZONE,
    verified_by     UUID REFERENCES users(id),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Vidéos
CREATE TABLE videos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            VARCHAR(20) NOT NULL CHECK (type IN ('presentation', 'offer', 'poster')),
    category        VARCHAR(100),
    title           VARCHAR(255),
    url             VARCHAR(500) NOT NULL,  -- URL Cloudflare R2
    thumbnail_url   VARCHAR(500),
    duration        INTEGER,                -- Durée en secondes
    status          VARCHAR(20) DEFAULT 'active' CHECK (status IN ('processing', 'active', 'suspended', 'deleted')),
    views_count     INTEGER DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at      TIMESTAMP WITH TIME ZONE
);

-- Table Messages
CREATE TABLE messages (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    sender_id       UUID NOT NULL REFERENCES users(id),
    receiver_id     UUID NOT NULL REFERENCES users(id),
    content         TEXT NOT NULL,
    is_read         BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Conversations
CREATE TABLE conversations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participant_1   UUID NOT NULL REFERENCES users(id),
    participant_2   UUID NOT NULL REFERENCES users(id),
    video_id        UUID REFERENCES videos(id),    -- Vidéo à l'origine du contact
    last_message_at TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(participant_1, participant_2)
);

-- Table Abonnements
CREATE TABLE subscriptions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan            VARCHAR(50) NOT NULL CHECK (plan IN ('seeker_premium', 'recruiter_premium')),
    stripe_subscription_id VARCHAR(255),
    stripe_customer_id     VARCHAR(255),
    status          VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'canceled', 'past_due', 'expired')),
    current_period_start   TIMESTAMP WITH TIME ZONE,
    current_period_end     TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Achats unitaires
CREATE TABLE purchases (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    product_type    VARCHAR(50) NOT NULL CHECK (product_type IN ('video_credit', 'poster_credit')),
    quantity        INTEGER DEFAULT 1,
    amount_cents    INTEGER NOT NULL,
    stripe_payment_id VARCHAR(255),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Blocages
CREATE TABLE blocks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id      UUID NOT NULL REFERENCES users(id),
    blocked_id      UUID NOT NULL REFERENCES users(id),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(blocker_id, blocked_id)
);

-- Table Signalements
CREATE TABLE reports (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id     UUID NOT NULL REFERENCES users(id),
    reported_user_id UUID REFERENCES users(id),
    reported_video_id UUID REFERENCES videos(id),
    reason          VARCHAR(100) NOT NULL,
    description     TEXT,
    status          VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'actioned', 'dismissed')),
    reviewed_by     UUID REFERENCES users(id),
    reviewed_at     TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour performances
CREATE INDEX idx_videos_user_id ON videos(user_id);
CREATE INDEX idx_videos_category ON videos(category);
CREATE INDEX idx_videos_status ON videos(status);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_receiver ON messages(receiver_id, is_read);
CREATE INDEX idx_seeker_profiles_category ON seeker_profiles(category);
CREATE INDEX idx_seeker_profiles_region ON seeker_profiles(region);
```

### Sécurité

| Aspect | Implémentation |
|--------|----------------|
| **Authentification** | JWT (JSON Web Tokens) avec refresh tokens |
| **Durée de vie tokens** | Access: 15 min, Refresh: 7 jours |
| **Transport** | HTTPS obligatoire (TLS 1.2+) |
| **Stockage mot de passe** | bcrypt (cost factor 12) |
| **Rate Limiting** | 100 req/min par IP, 1000 req/min par user authentifié |
| **Validation SIRET** | Manuelle (MVP), API INSEE (V2) |
| **Protection CSRF** | Token CSRF sur mutations sensibles |
| **Validation input** | Sanitization et validation côté serveur systématique |
| **Upload vidéo** | Presigned URLs (pas d'upload direct vers API) |
| **CORS** | Domaines autorisés uniquement |

### Intégrations Tierces

| Service | Usage | Documentation |
|---------|-------|---------------|
| **Cloudflare R2** | Stockage et streaming vidéos | developers.cloudflare.com/r2 |
| **Cloudflare Workers** | Edge functions pour URLs signées | developers.cloudflare.com/workers |
| **Stripe** | Paiements et abonnements | stripe.com/docs |
| **Resend** | Emails transactionnels | resend.com/docs |
| **Sentry** | Monitoring erreurs | docs.sentry.io |
| **Uptime Robot** | Monitoring disponibilité | uptimerobot.com |

---

## Timeline MVP

### Vue d'ensemble

| Phase | Durée | Dates estimées | Objectif |
|-------|-------|----------------|----------|
| **Phase 0** | 2 semaines | S1-S2 | Setup & Design |
| **Phase 1** | 4 semaines | S3-S6 | Core Features |
| **Phase 2** | 3 semaines | S7-S9 | Features Avancées |
| **Phase 3** | 2 semaines | S10-S11 | Tests & Polish |
| **Phase 4** | 1 semaine | S12 | Lancement |

**Durée totale estimée : 12 semaines (3 mois)**

---

### Phase 0 : Setup & Design (Semaines 1-2)

**Objectif :** Poser les fondations techniques et finaliser le design.

| Tâche | Responsable | Livrable |
|-------|-------------|----------|
| Setup projet Flutter | Dev Mobile | Repo Git, structure projet |
| Setup backend (Supabase/custom) | Dev Backend | Instance configurée |
| Setup Cloudflare R2 + Workers | DevOps | Bucket créé, Workers déployés |
| Setup Stripe (test mode) | Dev Backend | Compte configuré, clés API |
| Design UI/UX complet | Designer | Maquettes Figma haute fidélité |
| Design system (composants) | Designer | Kit UI Flutter |

**Jalon Phase 0 :** Environnement de développement opérationnel + Design validé

---

### Phase 1 : Core Features (Semaines 3-6)

**Objectif :** Implémenter les fonctionnalités essentielles.

#### Semaine 3-4 : Auth & Profils

| Tâche | Epic | User Stories |
|-------|------|--------------|
| Inscription/Connexion | Epic 1 | US-1.1, US-1.2 |
| Profil chercheur | Epic 1 | US-1.3 |
| Profil recruteur | Epic 1 | US-1.4 |
| Vérification email | Epic 1 | - |

#### Semaine 5-6 : Vidéo & Feed

| Tâche | Epic | User Stories |
|-------|------|--------------|
| Enregistrement vidéo (chercheur) | Epic 2 | US-2.1, US-2.2 |
| Upload/Import vidéo (recruteur) | Epic 3 | US-3.1 |
| Feed vertical basique | Epic 4 | US-4.1, US-4.3 |
| Filtres basiques | Epic 4 | US-4.2, US-4.4 |

**Jalon Phase 1 :** Application fonctionnelle avec inscription, vidéos et feed

---

### Phase 2 : Features Avancées (Semaines 7-9)

**Objectif :** Compléter les fonctionnalités métier.

#### Semaine 7 : Messagerie

| Tâche | Epic | User Stories |
|-------|------|--------------|
| Système de messagerie | Epic 5 | US-5.1, US-5.2 |
| Notifications push | Epic 5 | - |
| Blocage utilisateur | Epic 5 | US-5.3 |

#### Semaine 8 : Paiements

| Tâche | Epic | User Stories |
|-------|------|--------------|
| Intégration Stripe | Epic 6 | US-6.1, US-6.2 |
| Abonnements | Epic 6 | US-6.4 |
| Achats à l'unité | Epic 6 | US-6.3 |
| Webhooks Stripe | Epic 6 | - |

#### Semaine 9 : Admin & Support

| Tâche | Epic | User Stories |
|-------|------|--------------|
| Back-office admin | Epic 7 | US-7.1, US-7.2, US-7.3 |
| FAQ in-app | Epic 8 | US-8.1 |
| Formulaire contact | Epic 8 | US-8.2 |

**Jalon Phase 2 :** Application complète avec toutes les features MVP

---

### Phase 3 : Tests & Polish (Semaines 10-11)

**Objectif :** Stabiliser et optimiser l'application.

| Tâche | Description |
|-------|-------------|
| Tests end-to-end | Parcours critiques (inscription, vidéo, paiement) |
| Tests de charge | Simuler 500 users simultanés |
| Beta testing | 50-100 beta testeurs (chercheurs + recruteurs) |
| Fix bugs critiques | Correction des bugs remontés |
| Optimisation performance | Temps de chargement, taille app |
| Revue sécurité | Audit basique, correction failles |
| Mentions légales & CGU | Documents juridiques |

**Jalon Phase 3 :** Application stable, prête pour soumission stores

---

### Phase 4 : Lancement (Semaine 12)

**Objectif :** Déployer l'application sur les stores.

| Tâche | Description |
|-------|-------------|
| Soumission App Store | Review Apple (prévoir 3-7 jours) |
| Soumission Play Store | Review Google (prévoir 1-3 jours) |
| Configuration production | Variables d'env, monitoring |
| Seed content | Vidéos de démonstration, FAQ complète |
| Communication lancement | Réseaux sociaux, early adopters |

**Jalon Phase 4 :** Application live sur iOS et Android

---

### Tableau Récapitulatif des Jalons

| Jalon | Date (estimée) | Critères de validation |
|-------|----------------|------------------------|
| **M0 - Setup Complete** | Fin S2 | Env dev OK, Design validé |
| **M1 - Core Features** | Fin S6 | Auth + Vidéo + Feed fonctionnels |
| **M2 - Feature Complete** | Fin S9 | Toutes features MVP implémentées |
| **M3 - Release Candidate** | Fin S11 | Tests passés, bugs critiques résolus |
| **M4 - Launch** | Fin S12 | App live sur stores |

---

### Ressources Nécessaires

| Rôle | Nombre | Engagement |
|------|--------|------------|
| Product Manager | 1 | 50% (stratégie, priorisation) |
| Designer UI/UX | 1 | 100% (S1-S4), puis 25% |
| Dev Flutter | 1-2 | 100% |
| Dev Backend | 1 | 100% |
| DevOps (optionnel) | 1 | 25% (setup, déploiement) |
| QA (optionnel) | 1 | 50% (S10-S12) |

---

## Prochaines Étapes

| Étape | Contenu | Statut |
|-------|---------|--------|
| 1 | Classification du projet | Fait |
| 2 | Clarifications techniques | Fait |
| 3 | Critères de succès | Fait |
| 4 | Parcours utilisateurs (partiel) | Fait |
| 5 | Exigences non-fonctionnelles | Fait |
| 6 | User Stories | Fait |
| 7 | Risques et Dépendances | Fait |
| 8 | Spécifications techniques et Timeline | Fait |
| 9 | **Validation finale PRD** | ✅ Fait |

> **Note :** Le PRD est maintenant **VALIDÉ** et prêt pour le développement.

---

## Questions Résolues

Les questions de l'étape 4 ont été intégrées via les User Stories :
- Admin Back-Office : US-7.1, US-7.2, US-7.3
- Cas d'échec : US-7.2 (modération), US-3.3 (gestion publications)
- Parcours découverte : US-4.1 à US-4.4 (feed + filtres)
- Premier contact : US-5.1 à US-5.3 (messagerie + blocage)

---

*Document généré par John (PM) - Dernière mise à jour : 2026-02-01*
