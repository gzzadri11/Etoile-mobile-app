---
stepsCompleted: [1, 2, 3, 4]
status: complete
lastStep: "Step 4 - Final Validation"
completedAt: 2026-02-01
date: 2026-02-01
author: John (PM)
projectName: Etoile Mobile App
inputDocuments:
  - prd-etoile-draft.md
  - architecture-etoile.md
  - ux-design-etoile-draft.md
---

# Etoile Mobile App - Epic Breakdown

## Overview

Ce document fournit le découpage complet en Epics et Stories pour Etoile Mobile App, décomposant les exigences du PRD, UX Design et Architecture en stories implémentables.

---

## Requirements Inventory

### Functional Requirements

| ID | Epic | Description |
|----|------|-------------|
| FR-1.1 | Inscription & Profil | Inscription chercheur (email, mot de passe, rôle) |
| FR-1.2 | Inscription & Profil | Inscription recruteur (email, SIRET, document) |
| FR-1.3 | Inscription & Profil | Compléter profil chercheur (secteur, contrat, zone, dispo) |
| FR-1.4 | Inscription & Profil | Compléter profil recruteur (logo, description, secteur) |
| FR-2.1 | Vidéo Chercheur | Enregistrer vidéo 40s in-app |
| FR-2.2 | Vidéo Chercheur | Publier vidéo dans une catégorie |
| FR-2.3 | Vidéo Chercheur | Modifier/Supprimer vidéo |
| FR-3.1 | Vidéo Recruteur | Publier offre vidéo (import ou enregistrement) |
| FR-3.2 | Vidéo Recruteur | Publier affiche (image) |
| FR-3.3 | Vidéo Recruteur | Gérer publications |
| FR-4.1 | Feed & Découverte | Parcourir vidéos candidats (recruteur) |
| FR-4.2 | Feed & Découverte | Filtrer candidats |
| FR-4.3 | Feed & Découverte | Parcourir offres (chercheur) |
| FR-4.4 | Feed & Découverte | Filtrer offres |
| FR-5.1 | Messagerie | Contacter un candidat |
| FR-5.2 | Messagerie | Recevoir et répondre aux messages |
| FR-5.3 | Messagerie | Bloquer un recruteur |
| FR-6.1 | Paiements | Souscrire Premium chercheur (~5€/mois) |
| FR-6.2 | Paiements | Souscrire Premium recruteur (~500€/mois) |
| FR-6.3 | Paiements | Acheter crédits à l'unité |
| FR-6.4 | Paiements | Gérer abonnement |
| FR-7.1 | Administration | Valider recruteurs (back-office) |
| FR-7.2 | Administration | Modérer contenus |
| FR-7.3 | Administration | Statistiques globales |
| FR-8.1 | Support | FAQ in-app |
| FR-8.2 | Support | Formulaire de contact |

### Non-Functional Requirements

| ID | Catégorie | Exigence | Valeur |
|----|-----------|----------|--------|
| NFR-1 | Performance | Utilisateurs simultanés (nominal) | 500 |
| NFR-2 | Performance | Utilisateurs simultanés (pic) | 2 000 |
| NFR-3 | Performance | Temps réponse API | < 500ms (P95) |
| NFR-4 | Performance | Temps chargement vidéo | < 2s |
| NFR-5 | Disponibilité | SLA uptime | 99.5% (24/7) |
| NFR-6 | Disponibilité | Maintenance | Fenêtres nocturnes (2h-5h CET) |
| NFR-7 | Sécurité | Transport | TLS 1.3 obligatoire |
| NFR-8 | Sécurité | Auth | JWT RS256, access 15min, refresh 7j |
| NFR-9 | Sécurité | Mots de passe | bcrypt (cost 12), 8 chars min |
| NFR-10 | Sécurité | Rate limiting | 100 req/min par IP |
| NFR-11 | Conformité | RGPD | Mentions légales, suppression compte, export |
| NFR-12 | Support | Temps réponse | 48h ouvrées |

### Additional Requirements

**Architecture:**
- Setup projet Flutter avec Clean Architecture (3 couches: Presentation, Domain, Data)
- State Management: BLoC pattern avec flutter_bloc
- Navigation: GoRouter avec deep linking
- Intégration Supabase (Auth, PostgreSQL, Realtime, Edge Functions)
- Configuration Cloudflare R2 + Workers (presigned URLs pour upload vidéo)
- Intégration Stripe (abonnements, achats, webhooks)
- Row Level Security (RLS) PostgreSQL pour sécurité au niveau données
- Monitoring Sentry + Uptime Robot pour alerting
- Schéma base de données complet (12 tables: users, seeker_profiles, recruiter_profiles, categories, videos, video_views, conversations, messages, subscriptions, purchases, blocks, reports)
- Cache local avec Hive pour mode offline-resilient
- Dependency Injection avec GetIt

**UX Design:**
- Design System complet: palette jaune #FFB800 / orange #FF8C00, fond noir #1A1A1A
- Typography: Inter (ou SF Pro/Roboto natif), 14-32px
- Spacing: base 8px, coins 12px (boutons), 16px (cards)
- Composants spécifiés: boutons (primaire/secondaire/ghost), cards vidéo, inputs, modales, bottom sheet, tab bar
- Accessibilité: contrastes 4.5:1 minimum, zones tactiles 48x48px, support VoiceOver/TalkBack
- Animations subtiles (300ms ease-out)
- Responsive tablette (split view pour feed et messages)
- États vides avec messages encourageants et chaleureux
- Préchargement des 2 vidéos suivantes dans le feed
- Skeleton loaders pour tous les états de chargement
- Optimistic UI pour messages

---

## FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR-1.1 | Epic 1 | Inscription chercheur |
| FR-1.2 | Epic 1 | Inscription recruteur |
| FR-1.3 | Epic 1 | Profil chercheur |
| FR-1.4 | Epic 1 | Profil recruteur |
| FR-2.1 | Epic 2 | Enregistrer vidéo 40s |
| FR-2.2 | Epic 2 | Publier dans catégorie |
| FR-2.3 | Epic 2 | Modifier/Supprimer vidéo |
| FR-3.1 | Epic 3 | Offre vidéo recruteur |
| FR-3.2 | Epic 3 | Affiche recruteur |
| FR-3.3 | Epic 3 | Gérer publications |
| FR-4.1 | Epic 4 | Feed candidats |
| FR-4.2 | Epic 4 | Filtrer candidats |
| FR-4.3 | Epic 4 | Feed offres |
| FR-4.4 | Epic 4 | Filtrer offres |
| FR-5.1 | Epic 5 | Contacter candidat |
| FR-5.2 | Epic 5 | Répondre messages |
| FR-5.3 | Epic 5 | Bloquer utilisateur |
| FR-6.1 | Epic 6 | Premium chercheur |
| FR-6.2 | Epic 6 | Premium recruteur |
| FR-6.3 | Epic 6 | Achats unité |
| FR-6.4 | Epic 6 | Gérer abonnement |
| FR-7.1 | Epic 7 | Valider recruteurs |
| FR-7.2 | Epic 7 | Modérer contenus |
| FR-7.3 | Epic 7 | Stats globales |
| FR-8.1 | Epic 8 | FAQ |
| FR-8.2 | Epic 8 | Contact support |

**Couverture: 26/26 FRs (100%)**

---

## Epic List

### Epic 0: Fondation Technique
Mettre en place l'infrastructure de base pour que l'équipe puisse développer.
- Setup projet Flutter (Clean Architecture, BLoC, GoRouter)
- Configuration Supabase (Auth, Database, Realtime)
- Configuration Cloudflare R2 + Workers
- Setup Stripe (mode test)
- CI/CD basique

**FRs couverts:** Aucun directement (enabler technique)

---

### Epic 1: Authentification & Profils
Les utilisateurs peuvent créer un compte, se connecter et gérer leur profil.

**FRs couverts:** FR-1.1, FR-1.2, FR-1.3, FR-1.4

---

### Epic 2: Vidéo Chercheur
Les chercheurs peuvent enregistrer et publier leur vidéo de présentation de 40 secondes.

**FRs couverts:** FR-2.1, FR-2.2, FR-2.3

---

### Epic 3: Vidéo & Affiche Recruteur
Les recruteurs peuvent créer et gérer leurs offres d'emploi (vidéo ou affiche).

**FRs couverts:** FR-3.1, FR-3.2, FR-3.3

---

### Epic 4: Feed & Découverte
Les utilisateurs peuvent parcourir et filtrer le contenu (candidats ou offres).

**FRs couverts:** FR-4.1, FR-4.2, FR-4.3, FR-4.4

---

### Epic 5: Messagerie & Contact
Les utilisateurs peuvent communiquer entre eux.

**FRs couverts:** FR-5.1, FR-5.2, FR-5.3

---

### Epic 6: Paiements & Abonnements
Les utilisateurs peuvent souscrire aux offres premium et acheter des crédits.

**FRs couverts:** FR-6.1, FR-6.2, FR-6.3, FR-6.4

---

### Epic 7: Administration
Les admins peuvent gérer la plateforme (vérifications, modération, stats).

**FRs couverts:** FR-7.1, FR-7.2, FR-7.3

---

### Epic 8: Support & Aide
Les utilisateurs peuvent obtenir de l'aide.

**FRs couverts:** FR-8.1, FR-8.2

---

# Stories Détaillées

## Epic 0: Fondation Technique

**Objectif:** Mettre en place l'infrastructure de base pour le développement.

### Story 0.1: Setup Projet Flutter

**As a** développeur,
**I want** un projet Flutter configuré avec Clean Architecture,
**So that** l'équipe puisse développer de manière structurée.

**Acceptance Criteria:**

**Given** aucun projet n'existe
**When** je crée le projet Flutter
**Then** la structure suivante est en place:
- `lib/core/` (erreurs, usecases, utils)
- `lib/features/` (modules fonctionnels)
- `lib/di/` (injection de dépendances GetIt)
- `lib/routes/` (GoRouter)
**And** les dépendances de base sont configurées (flutter_bloc, go_router, dio, get_it, equatable)

---

### Story 0.2: Configuration Supabase

**As a** développeur,
**I want** Supabase configuré et connecté,
**So that** je puisse utiliser l'auth, la DB et le realtime.

**Acceptance Criteria:**

**Given** le projet Flutter existe
**When** je configure Supabase
**Then** le client Supabase est initialisé au démarrage de l'app
**And** les variables d'environnement (URL, anon key) sont externalisées
**And** je peux me connecter à Supabase depuis l'app

---

### Story 0.3: Configuration Cloudflare R2

**As a** développeur,
**I want** Cloudflare R2 configuré pour le stockage vidéo,
**So that** les uploads vidéo fonctionnent.

**Acceptance Criteria:**

**Given** un compte Cloudflare existe
**When** je configure R2
**Then** un bucket "etoile-videos" est créé
**And** un Worker pour générer des presigned URLs est déployé
**And** les CORS sont configurés pour l'app mobile

---

### Story 0.4: Configuration Stripe

**As a** développeur,
**I want** Stripe configuré en mode test,
**So that** les paiements puissent être testés.

**Acceptance Criteria:**

**Given** un compte Stripe existe
**When** je configure Stripe
**Then** les clés API test sont dans les variables d'environnement
**And** les produits/prix sont créés (seeker_premium, recruiter_premium, video_credit, poster_credit)
**And** le webhook endpoint est configuré dans Supabase Edge Functions

---

### Story 0.5: Schéma Base de Données Initial

**As a** développeur,
**I want** les tables de base créées dans PostgreSQL,
**So that** les fonctionnalités d'auth puissent être développées.

**Acceptance Criteria:**

**Given** Supabase est configuré
**When** je crée le schéma initial
**Then** les tables suivantes existent: `users`, `categories`
**And** les extensions `uuid-ossp` et `pgcrypto` sont activées
**And** Row Level Security est activé sur toutes les tables

---

## Epic 1: Authentification & Profils

**Objectif:** Les utilisateurs peuvent créer un compte, se connecter et gérer leur profil.
**FRs:** FR-1.1, FR-1.2, FR-1.3, FR-1.4

### Story 1.1: Inscription Chercheur

**As a** chercheur d'emploi,
**I want** créer un compte avec mon email,
**So that** je puisse accéder à l'application.

**Acceptance Criteria:**

**Given** je suis sur l'écran d'inscription
**When** je remplis email, mot de passe (8+ chars), confirmation
**And** je sélectionne le rôle "Chercheur"
**And** je soumets le formulaire
**Then** un compte est créé dans Supabase Auth
**And** une entrée est créée dans la table `users` avec role='seeker'
**And** une entrée est créée dans `seeker_profiles`
**And** un email de confirmation est envoyé
**And** je suis redirigé vers l'écran de complétion de profil

**Given** l'email est déjà utilisé
**When** je soumets le formulaire
**Then** un message d'erreur s'affiche "Cet email est déjà utilisé"

---

### Story 1.2: Inscription Recruteur

**As a** recruteur,
**I want** créer un compte professionnel,
**So that** je puisse publier des offres.

**Acceptance Criteria:**

**Given** je suis sur l'écran d'inscription
**When** je remplis email, mot de passe, nom entreprise, SIRET (14 chiffres)
**And** j'uploade un document justificatif (Kbis, carte pro)
**And** je soumets le formulaire
**Then** un compte est créé avec role='recruiter' et status='pending'
**And** une entrée est créée dans `recruiter_profiles` avec verification_status='pending'
**And** le document est uploadé dans Supabase Storage (privé)
**And** je vois un message "Votre compte est en cours de vérification"

**Given** le SIRET n'a pas 14 chiffres
**When** je soumets
**Then** un message d'erreur s'affiche "SIRET invalide (14 chiffres requis)"

---

### Story 1.3: Connexion / Déconnexion

**As a** utilisateur inscrit,
**I want** me connecter et me déconnecter,
**So that** je puisse accéder à mon compte de manière sécurisée.

**Acceptance Criteria:**

**Given** j'ai un compte confirmé
**When** je saisis email et mot de passe corrects
**Then** je suis authentifié et redirigé vers le feed
**And** les tokens JWT sont stockés dans flutter_secure_storage

**Given** le mot de passe est incorrect
**When** je soumets
**Then** un message d'erreur s'affiche "Email ou mot de passe incorrect"

**Given** je suis connecté
**When** je clique sur "Déconnexion"
**Then** les tokens sont supprimés
**And** je suis redirigé vers l'écran de connexion

---

### Story 1.4: Profil Chercheur

**As a** chercheur,
**I want** compléter mon profil,
**So that** les recruteurs puissent me trouver.

**Acceptance Criteria:**

**Given** je suis connecté en tant que chercheur
**When** je remplis: prénom, nom, secteur recherché, type contrat, zone géographique, disponibilité
**And** je sauvegarde
**Then** mon `seeker_profile` est mis à jour
**And** `profile_complete` passe à true
**And** je vois un message de confirmation

**Given** je modifie mon profil plus tard
**When** je change mes critères
**Then** les modifications sont sauvegardées

---

### Story 1.5: Profil Recruteur

**As a** recruteur vérifié,
**I want** personnaliser mon profil entreprise,
**So that** les chercheurs voient mon entreprise.

**Acceptance Criteria:**

**Given** je suis connecté en tant que recruteur vérifié
**When** j'uploade un logo, une description (500 chars max), mon secteur, mes localisations
**And** je sauvegarde
**Then** mon `recruiter_profile` est mis à jour
**And** le logo est uploadé dans Supabase Storage (public)

**Given** je ne suis pas encore vérifié
**When** j'accède à mon profil
**Then** je vois uniquement "Votre compte est en cours de vérification"

---

### Story 1.6: Réinitialisation Mot de Passe

**As a** utilisateur,
**I want** réinitialiser mon mot de passe,
**So that** je puisse récupérer l'accès à mon compte.

**Acceptance Criteria:**

**Given** je suis sur l'écran de connexion
**When** je clique sur "Mot de passe oublié"
**And** je saisis mon email
**Then** un email avec un lien de réinitialisation est envoyé

**Given** j'ai reçu l'email
**When** je clique sur le lien et saisis un nouveau mot de passe
**Then** mon mot de passe est mis à jour
**And** je peux me connecter avec le nouveau mot de passe

---

## Epic 2: Vidéo Chercheur

**Objectif:** Les chercheurs peuvent enregistrer et publier leur vidéo de présentation de 40 secondes.
**FRs:** FR-2.1, FR-2.2, FR-2.3

### Story 2.1: Enregistrement Vidéo 40s

**As a** chercheur,
**I want** enregistrer une vidéo de 40 secondes,
**So that** je puisse me présenter aux recruteurs.

**Acceptance Criteria:**

**Given** je suis connecté en tant que chercheur avec profil complet
**When** j'accède à l'écran d'enregistrement
**Then** je vois l'aperçu caméra frontale en miroir
**And** je vois des conseils de préparation (éclairage, calme)

**Given** je démarre l'enregistrement
**When** j'enregistre
**Then** un chronomètre décompte de 0 à 40s
**And** des prompts de coaching s'affichent (0-10s: "Présentez-vous", 10-30s: "Vos compétences", 30-40s: "Conclusion")
**And** l'enregistrement s'arrête automatiquement à 40s

**Given** l'enregistrement est terminé
**When** je vois la prévisualisation
**Then** je peux relire ma vidéo
**And** je vois les boutons "Recommencer" et "Valider"

---

### Story 2.2: Prévisualisation et Ré-enregistrement

**As a** chercheur,
**I want** revoir et recommencer ma vidéo,
**So that** je puisse publier la meilleure version.

**Acceptance Criteria:**

**Given** j'ai terminé un enregistrement
**When** je clique sur "Recommencer"
**Then** la vidéo précédente est supprimée localement
**And** je retourne à l'écran de préparation
**And** je peux recommencer autant de fois que souhaité

**Given** je suis satisfait de ma vidéo
**When** je clique sur "Valider"
**Then** je passe à l'écran de sélection de catégorie

---

### Story 2.3: Publication dans une Catégorie

**As a** chercheur,
**I want** publier ma vidéo dans une catégorie métier,
**So that** les recruteurs du secteur me trouvent.

**Acceptance Criteria:**

**Given** j'ai validé ma vidéo
**When** je sélectionne une catégorie parmi la liste
**And** je confirme la publication
**Then** la vidéo est uploadée vers Cloudflare R2 (presigned URL)
**And** une entrée est créée dans `videos` avec type='presentation', status='processing'
**And** une thumbnail est générée
**And** le statut passe à 'active' après traitement
**And** je vois "Bravo ! Votre vidéo brille maintenant sur Etoile"

**Given** j'ai déjà une vidéo active dans cette catégorie
**When** je publie une nouvelle vidéo
**Then** l'ancienne vidéo est remplacée (status='deleted')

---

### Story 2.4: Modification / Remplacement Vidéo

**As a** chercheur,
**I want** remplacer ma vidéo existante,
**So that** je puisse mettre à jour ma présentation.

**Acceptance Criteria:**

**Given** j'ai une vidéo publiée
**When** je vais sur mon profil et clique "Modifier ma vidéo"
**Then** je suis redirigé vers l'écran d'enregistrement
**And** après publication, l'ancienne vidéo est remplacée

---

### Story 2.5: Suppression Vidéo

**As a** chercheur,
**I want** supprimer ma vidéo,
**So that** je ne sois plus visible si je le souhaite.

**Acceptance Criteria:**

**Given** j'ai une vidéo publiée
**When** je clique "Supprimer ma vidéo"
**Then** une confirmation est demandée "Êtes-vous sûr ?"

**Given** je confirme la suppression
**When** je valide
**Then** le statut de la vidéo passe à 'deleted'
**And** la vidéo n'apparaît plus dans le feed
**And** le fichier sera purgé sous 30 jours (RGPD)

---

## Epic 3: Vidéo & Affiche Recruteur

**Objectif:** Les recruteurs peuvent créer et gérer leurs offres d'emploi.
**FRs:** FR-3.1, FR-3.2, FR-3.3

### Story 3.1: Import Vidéo depuis Galerie

**As a** recruteur vérifié,
**I want** importer une vidéo depuis ma galerie,
**So that** je puisse publier une offre professionnelle.

**Acceptance Criteria:**

**Given** je suis recruteur vérifié avec crédits vidéo disponibles
**When** je clique "Nouvelle offre vidéo" puis "Importer"
**Then** le sélecteur de fichiers s'ouvre (filtré sur vidéos)

**Given** je sélectionne une vidéo
**When** la vidéo dure > 40s
**Then** elle est automatiquement coupée à 40s
**And** je vois une prévisualisation

**Given** la vidéo est prête
**When** j'ajoute un titre de poste et une catégorie
**And** je publie
**Then** la vidéo est uploadée vers R2
**And** une entrée `videos` est créée avec type='offer'
**And** mon `video_credits` est décrémenté de 1

---

### Story 3.2: Enregistrement Vidéo In-App (Recruteur)

**As a** recruteur,
**I want** enregistrer une vidéo directement dans l'app,
**So that** je puisse créer une offre rapidement.

**Acceptance Criteria:**

**Given** je suis recruteur vérifié
**When** je clique "Nouvelle offre vidéo" puis "Enregistrer"
**Then** j'accède à l'écran d'enregistrement (similaire chercheur)
**And** la durée max est 40s avec arrêt automatique

**Given** l'enregistrement est terminé
**When** je valide
**Then** je peux ajouter titre et catégorie puis publier

---

### Story 3.3: Publication Affiche (Image)

**As a** recruteur vérifié,
**I want** publier une affiche pour une offre,
**So that** je puisse proposer une alternative à la vidéo.

**Acceptance Criteria:**

**Given** je suis recruteur vérifié avec crédits affiche disponibles
**When** je clique "Nouvelle affiche"
**Then** le sélecteur d'images s'ouvre (JPG, PNG)

**Given** je sélectionne une image
**When** l'image n'est pas au format 9:16
**Then** un guide de recadrage s'affiche

**Given** l'image est prête
**When** j'ajoute titre et catégorie et publie
**Then** l'image est uploadée vers R2
**And** une entrée `videos` est créée avec type='poster'
**And** mon `poster_credits` est décrémenté de 1

---

### Story 3.4: Gestion des Publications

**As a** recruteur,
**I want** voir toutes mes publications,
**So that** je puisse les gérer.

**Acceptance Criteria:**

**Given** je suis recruteur connecté
**When** j'accède à "Mes publications"
**Then** je vois la liste de mes vidéos et affiches
**And** chaque item affiche: thumbnail, titre, catégorie, statut, date, vues (si premium)

**Given** une publication est active
**When** je la sélectionne
**Then** je vois les options: Modifier, Supprimer

---

### Story 3.5: Modification / Suppression Publication

**As a** recruteur,
**I want** modifier ou supprimer une publication,
**So that** je puisse maintenir mes offres à jour.

**Acceptance Criteria:**

**Given** j'ai une publication active
**When** je clique "Modifier"
**Then** je peux changer le titre et la catégorie (pas la vidéo/image)

**Given** je clique "Supprimer"
**When** je confirme
**Then** le statut passe à 'deleted'
**And** la publication n'apparaît plus dans le feed
**And** mes crédits ne sont PAS restaurés

---

## Epic 4: Feed & Découverte

**Objectif:** Les utilisateurs peuvent parcourir et filtrer le contenu.
**FRs:** FR-4.1, FR-4.2, FR-4.3, FR-4.4

### Story 4.1: Feed Vertical Candidats (Recruteur)

**As a** recruteur vérifié,
**I want** parcourir les vidéos de candidats,
**So that** je puisse trouver des profils intéressants.

**Acceptance Criteria:**

**Given** je suis recruteur vérifié connecté
**When** j'accède au feed
**Then** je vois des vidéos de chercheurs en plein écran (style TikTok)
**And** la première vidéo se lance automatiquement (son muté)
**And** je vois: prénom, catégorie, localisation, badge disponibilité

**Given** je swipe vers le haut
**When** la transition se fait
**Then** la vidéo suivante apparaît et se lance
**And** la vidéo précédente se met en pause

**Given** je tape au centre de l'écran
**When** la vidéo est en lecture
**Then** elle se met en pause (et vice versa)

**Given** je tape sur l'icône son
**When** le son est muté
**Then** le son s'active (et vice versa)

---

### Story 4.2: Feed Vertical Offres (Chercheur)

**As a** chercheur,
**I want** parcourir les offres des recruteurs,
**So that** je puisse trouver des opportunités.

**Acceptance Criteria:**

**Given** je suis chercheur connecté
**When** j'accède au feed
**Then** je vois des vidéos ET affiches de recruteurs
**And** chaque item affiche: nom entreprise, titre poste, localisation
**And** un badge "Entreprise vérifiée ✓" est visible

**Given** c'est une affiche (pas une vidéo)
**When** elle s'affiche
**Then** l'image est affichée en plein écran
**And** je peux swiper pour passer à la suivante

---

### Story 4.3: Lecture Vidéo (Contrôles)

**As a** utilisateur,
**I want** contrôler la lecture vidéo,
**So that** je puisse regarder à mon rythme.

**Acceptance Criteria:**

**Given** une vidéo est en lecture
**When** je regarde
**Then** une barre de progression s'affiche (40s total)
**And** je peux voir le temps écoulé

**Given** la vidéo se termine
**When** les 40s sont écoulées
**Then** la vidéo passe automatiquement à la suivante (autoplay)

**Given** je veux revoir
**When** je swipe vers le bas
**Then** je reviens à la vidéo précédente

---

### Story 4.4: Filtres

**As a** utilisateur,
**I want** filtrer le contenu par critères,
**So that** je trouve des profils/offres pertinents.

**Acceptance Criteria:**

**Given** je suis sur le feed
**When** je clique sur l'icône filtre
**Then** une bottom sheet s'ouvre avec les options:
- Catégorie métier (liste)
- Zone géographique (région/ville)
- Type de contrat (chercheur uniquement)
- Disponibilité (recruteur uniquement)

**Given** j'applique des filtres
**When** je ferme la bottom sheet
**Then** le feed est rechargé avec uniquement les résultats correspondants
**And** un badge indique le nombre de filtres actifs

**Given** je clique "Réinitialiser"
**When** les filtres sont effacés
**Then** le feed revient à l'affichage par défaut

---

### Story 4.5: Préchargement Vidéos (Performance)

**As a** utilisateur,
**I want** que les vidéos se chargent instantanément,
**So that** l'expérience soit fluide.

**Acceptance Criteria:**

**Given** je regarde une vidéo
**When** elle est en lecture
**Then** les 2 vidéos suivantes sont préchargées en arrière-plan

**Given** je suis en connexion lente (3G)
**When** le chargement prend du temps
**Then** un skeleton loader s'affiche
**And** la vidéo démarre dès que suffisamment de données sont chargées

---

### Story 4.6: Profil Détaillé depuis Feed

**As a** utilisateur,
**I want** voir le profil complet depuis le feed,
**So that** j'en sache plus avant de contacter.

**Acceptance Criteria:**

**Given** je vois une vidéo dans le feed
**When** je tape sur l'icône profil ou le nom
**Then** une bottom sheet s'ouvre avec le profil détaillé:
- Photo/Logo
- Bio/Description
- Tous les critères (secteur, localisation, etc.)
- Bouton "Contacter"

---

## Epic 5: Messagerie & Contact

**Objectif:** Les utilisateurs peuvent communiquer entre eux.
**FRs:** FR-5.1, FR-5.2, FR-5.3

### Story 5.1: Initier une Conversation

**As a** recruteur vérifié,
**I want** contacter un candidat,
**So that** je puisse lui proposer une opportunité.

**Acceptance Criteria:**

**Given** je vois un candidat intéressant dans le feed
**When** je clique sur "Contacter"
**Then** une conversation est créée dans `conversations`
**And** l'écran de chat s'ouvre
**And** je peux écrire mon premier message

**Given** une conversation existe déjà avec ce candidat
**When** je clique "Contacter"
**Then** je suis redirigé vers la conversation existante

---

### Story 5.2: Liste des Conversations

**As a** utilisateur,
**I want** voir toutes mes conversations,
**So that** je puisse suivre mes échanges.

**Acceptance Criteria:**

**Given** je suis connecté
**When** j'accède à l'onglet Messages
**Then** je vois la liste de mes conversations triées par date du dernier message
**And** chaque conversation affiche: photo, nom, aperçu dernier message, date

**Given** j'ai des messages non lus
**When** je vois la liste
**Then** un badge indique le nombre de non lus
**And** les conversations non lues sont en gras

---

### Story 5.3: Chat Temps Réel

**As a** utilisateur,
**I want** échanger des messages en temps réel,
**So that** la conversation soit fluide.

**Acceptance Criteria:**

**Given** je suis dans une conversation
**When** je tape un message et envoie
**Then** le message apparaît immédiatement (optimistic UI)
**And** il est sauvegardé dans `messages`
**And** l'autre participant le reçoit en temps réel (Supabase Realtime)

**Given** l'autre participant envoie un message
**When** je suis dans la conversation
**Then** le message apparaît instantanément
**And** un son discret est joué (si non muté)

**Given** je suis dans la liste des conversations
**When** un nouveau message arrive
**Then** la conversation remonte en haut
**And** l'aperçu est mis à jour

---

### Story 5.4: Notifications Push Nouveaux Messages

**As a** utilisateur,
**I want** recevoir des notifications pour les nouveaux messages,
**So that** je ne rate aucun échange.

**Acceptance Criteria:**

**Given** je ne suis pas dans l'app
**When** je reçois un nouveau message
**Then** une notification push s'affiche avec: nom expéditeur, aperçu message

**Given** je tape sur la notification
**When** l'app s'ouvre
**Then** je suis redirigé vers la conversation concernée

---

### Story 5.5: Bloquer un Utilisateur

**As a** chercheur,
**I want** bloquer un recruteur indésirable,
**So that** je ne reçoive plus ses messages.

**Acceptance Criteria:**

**Given** je suis dans une conversation
**When** je clique sur "..." puis "Bloquer"
**Then** une confirmation est demandée

**Given** je confirme le blocage
**When** je valide
**Then** une entrée est créée dans `blocks`
**And** la conversation est archivée
**And** le recruteur ne peut plus m'envoyer de messages
**And** ma vidéo n'apparaît plus dans son feed

---

### Story 5.6: Signaler une Conversation

**As a** utilisateur,
**I want** signaler un comportement inapproprié,
**So that** la plateforme reste sûre.

**Acceptance Criteria:**

**Given** je suis dans une conversation
**When** je clique "..." puis "Signaler"
**Then** je choisis un motif: Spam, Comportement inapproprié, Fausse identité, Autre

**Given** je sélectionne un motif
**When** je valide
**Then** une entrée est créée dans `reports`
**And** je vois "Merci pour votre signalement"

---

## Epic 6: Paiements & Abonnements

**Objectif:** Les utilisateurs peuvent souscrire aux offres premium.
**FRs:** FR-6.1, FR-6.2, FR-6.3, FR-6.4

### Story 6.1: Page Premium Chercheur

**As a** chercheur gratuit,
**I want** voir les avantages Premium,
**So that** je puisse décider de m'abonner.

**Acceptance Criteria:**

**Given** je suis chercheur gratuit
**When** j'accède à la page Premium (via profil ou CTA)
**Then** je vois les avantages:
- Voir qui a vu ma vidéo
- Statistiques détaillées
- Badge Premium
**And** le prix: ~5€/mois
**And** un bouton "S'abonner"

---

### Story 6.2: Page Premium Recruteur

**As a** recruteur gratuit,
**I want** voir les avantages Premium,
**So that** je puisse décider de m'abonner.

**Acceptance Criteria:**

**Given** je suis recruteur vérifié gratuit
**When** j'accède à la page Premium
**Then** je vois les avantages:
- 2 vidéos + 2 affiches par semaine
- Statistiques détaillées (vues, qui a vu)
- Badge Premium
**And** le prix: ~500€/mois
**And** un bouton "S'abonner"

---

### Story 6.3: Paiement Stripe (Checkout)

**As a** utilisateur,
**I want** payer par carte bancaire,
**So that** mon abonnement soit activé.

**Acceptance Criteria:**

**Given** je clique "S'abonner"
**When** l'écran de paiement Stripe s'ouvre
**Then** je peux saisir mes informations de carte
**And** le montant est clairement affiché

**Given** le paiement est validé
**When** Stripe confirme
**Then** une entrée est créée dans `subscriptions`
**And** mon `is_premium` passe à true
**And** je vois "Bienvenue dans Premium !"
**And** un reçu est envoyé par email

**Given** le paiement échoue
**When** Stripe refuse
**Then** je vois un message d'erreur clair
**And** je peux réessayer

---

### Story 6.4: Achat Crédits à l'Unité

**As a** recruteur,
**I want** acheter des crédits supplémentaires,
**So that** je puisse publier plus d'offres.

**Acceptance Criteria:**

**Given** je suis recruteur (gratuit ou premium)
**When** j'accède à "Acheter des crédits"
**Then** je vois les options:
- +1 vidéo: ~100€
- +1 affiche: ~50€

**Given** je sélectionne un achat
**When** le paiement Stripe est validé
**Then** une entrée est créée dans `purchases`
**And** mes `video_credits` ou `poster_credits` sont incrémentés
**And** je vois confirmation

---

### Story 6.5: Gestion Abonnement

**As a** utilisateur premium,
**I want** gérer mon abonnement,
**So that** je puisse l'annuler si besoin.

**Acceptance Criteria:**

**Given** je suis premium
**When** j'accède à "Mon abonnement"
**Then** je vois:
- Type d'abonnement
- Date de renouvellement
- Historique des paiements
- Bouton "Annuler"

**Given** je clique "Annuler"
**When** je confirme
**Then** le statut passe à 'canceled'
**And** l'abonnement reste actif jusqu'à la fin de la période
**And** un email de confirmation est envoyé

---

### Story 6.6: Webhooks Stripe

**As a** système,
**I want** traiter les événements Stripe,
**So that** les statuts soient à jour.

**Acceptance Criteria:**

**Given** un abonnement se renouvelle
**When** Stripe envoie `invoice.paid`
**Then** `current_period_end` est mis à jour dans `subscriptions`

**Given** un paiement échoue
**When** Stripe envoie `invoice.payment_failed`
**Then** le statut passe à 'past_due'
**And** un email d'alerte est envoyé à l'utilisateur

**Given** un abonnement expire
**When** Stripe envoie `customer.subscription.deleted`
**Then** le statut passe à 'expired'
**And** `is_premium` repasse à false

---

## Epic 7: Administration

**Objectif:** Les admins peuvent gérer la plateforme.
**FRs:** FR-7.1, FR-7.2, FR-7.3

### Story 7.1: Back-Office: Liste Recruteurs en Attente

**As a** admin,
**I want** voir les recruteurs en attente de vérification,
**So that** je puisse les valider.

**Acceptance Criteria:**

**Given** je suis connecté en tant qu'admin
**When** j'accède au back-office (web ou in-app)
**Then** je vois la liste des recruteurs avec `verification_status='pending'`
**And** chaque entrée affiche: nom entreprise, SIRET, date inscription

---

### Story 7.2: Validation / Rejet Recruteur

**As a** admin,
**I want** valider ou rejeter un recruteur,
**So that** seules les vraies entreprises accèdent à la plateforme.

**Acceptance Criteria:**

**Given** je sélectionne un recruteur en attente
**When** je consulte sa fiche
**Then** je vois: SIRET, document uploadé, infos entreprise

**Given** je clique "Approuver"
**When** je valide
**Then** `verification_status` passe à 'verified'
**And** `verified_at` et `verified_by` sont renseignés
**And** un email "Votre compte est validé" est envoyé

**Given** je clique "Rejeter"
**When** je saisis un motif et valide
**Then** `verification_status` passe à 'rejected'
**And** `rejection_reason` est enregistré
**And** un email avec le motif est envoyé

---

### Story 7.3: Liste Signalements

**As a** admin,
**I want** voir les signalements,
**So that** je puisse modérer le contenu.

**Acceptance Criteria:**

**Given** je suis admin
**When** j'accède aux signalements
**Then** je vois la liste des `reports` avec status='pending'
**And** chaque signalement affiche: type, motif, date, utilisateur signalé

---

### Story 7.4: Modération Contenus

**As a** admin,
**I want** agir sur les signalements,
**So that** la plateforme reste sûre.

**Acceptance Criteria:**

**Given** je consulte un signalement
**When** je vois le contenu signalé (vidéo ou conversation)
**Then** j'ai les options: Ignorer, Supprimer contenu, Bannir utilisateur

**Given** je choisis "Supprimer contenu"
**When** je valide
**Then** le contenu passe en status='suspended'
**And** le signalement passe en status='actioned'
**And** un email est envoyé à l'utilisateur concerné

**Given** je choisis "Bannir utilisateur"
**When** je valide
**Then** le compte passe en status='suspended'
**And** l'utilisateur est déconnecté

---

### Story 7.5: Dashboard Statistiques

**As a** admin,
**I want** voir les métriques clés,
**So that** je puisse suivre la santé de la plateforme.

**Acceptance Criteria:**

**Given** je suis admin
**When** j'accède au dashboard
**Then** je vois:
- Nombre total d'utilisateurs (chercheurs, recruteurs)
- Nombre de vidéos/affiches publiées
- Nombre de messages échangés
- Revenus (abonnements + achats)
- Graphique d'évolution (7j, 30j)

---

## Epic 8: Support & Aide

**Objectif:** Les utilisateurs peuvent obtenir de l'aide.
**FRs:** FR-8.1, FR-8.2

### Story 8.1: FAQ In-App

**As a** utilisateur,
**I want** accéder à une FAQ,
**So that** je puisse résoudre mes problèmes courants.

**Acceptance Criteria:**

**Given** je suis connecté
**When** j'accède à "Aide" depuis le menu
**Then** je vois une liste de questions organisées par thème:
- Compte & Profil
- Vidéo
- Messages
- Paiements
- Technique

**Given** je tape sur une question
**When** elle s'ouvre
**Then** je vois la réponse détaillée

**Given** je cherche un mot-clé
**When** je tape dans la barre de recherche
**Then** les questions correspondantes s'affichent

---

### Story 8.2: Formulaire de Contact

**As a** utilisateur,
**I want** contacter le support,
**So that** je puisse résoudre un problème non couvert par la FAQ.

**Acceptance Criteria:**

**Given** je suis dans la FAQ
**When** je clique "Contacter le support"
**Then** un formulaire s'ouvre avec: Sujet, Description, pièce jointe (optionnelle)

**Given** je remplis et soumets le formulaire
**When** je valide
**Then** un email est envoyé à support@etoile-app.fr
**And** je vois "Votre message a été envoyé. Réponse sous 48h."

---

### Story 8.3: Mentions Légales, CGU, Confidentialité

**As a** utilisateur,
**I want** accéder aux documents légaux,
**So that** je connaisse mes droits.

**Acceptance Criteria:**

**Given** je suis dans les paramètres
**When** je clique sur "Mentions légales", "CGU" ou "Politique de confidentialité"
**Then** le document correspondant s'affiche (webview)

---

# Résumé

| Epic | Nom | Stories |
|------|-----|---------|
| 0 | Fondation Technique | 5 |
| 1 | Authentification & Profils | 6 |
| 2 | Vidéo Chercheur | 5 |
| 3 | Vidéo & Affiche Recruteur | 5 |
| 4 | Feed & Découverte | 6 |
| 5 | Messagerie & Contact | 6 |
| 6 | Paiements & Abonnements | 6 |
| 7 | Administration | 5 |
| 8 | Support & Aide | 3 |
| **Total** | | **47** |

