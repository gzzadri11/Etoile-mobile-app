---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 'e-01', 'e-02', 'e-03']
status: edited
lastStep: "Edit Step E-3"
date: 2026-02-01
validatedAt: 2026-02-01
lastEdited: 2026-02-18
editHistory:
  - date: 2026-02-18
    changes: "Refonte onboarding (mascotte, OTP, CGU), système complétude profil, dossiers candidature messagerie, alertes filtrées chercheur, mascotte & branding, enrichissement UX"
  - date: 2026-02-18
    changes: "Validation PRD round 1 (59→78): +Executive Summary, +User Journeys, +US Suppression compte, +US Signaler, +Conformité RGPD/HR Tech, +Spécificités mobile (IAP/offline/permissions/a11y), Epic 10 fusionnée, prix fixés, terminologie unifiée, specs techniques extraites vers architecture-etoile-draft.md"
  - date: 2026-02-18
    changes: "Validation PRD round 2 (78→85+): prix Executive Summary alignés (4,99€/499€), complétude profil corrigée (40% post-inscription, pas 50%), états vides ajoutés (feed, dossiers, messagerie), RGPD Art.20 portabilité au MVP, noms techniques abstraits dans les US (Stripe→prestataire paiement)"
author: John (PM)
projectName: Etoile Mobile App
---

# PRD: Etoile Mobile App

## Executive Summary

Etoile est une application mobile de recrutement par vidéo courte (40 secondes, style TikTok) destinée au marché français. Elle connecte les chercheurs d'emploi — qui se présentent via des vidéos authentiques enregistrées in-app — avec des recruteurs vérifiés (SIRET) qui publient leurs offres en vidéo ou en affiche.

L'application se distingue par : (1) un onboarding guidé par une mascotte originale, (2) un système de complétude profil à 100% obligatoire avant toute interaction, (3) des dossiers de candidature automatiques par offre, et (4) des alertes filtrées configurables pour les chercheurs.

Le modèle économique repose sur un freemium pour les chercheurs (4,99€/mois premium) et un abonnement professionnel pour les recruteurs (499€/mois), complété par des achats à l'unité. Le MVP cible 1 000 utilisateurs à M1 et 15 000 à M12, avec un lancement prévu en 17 semaines.

**Architecture détaillée** dans `architecture-etoile-draft.md` (stack, schéma de données, sécurité).

---

## Classification Projet

| Critère | Valeur |
|---------|--------|
| **Type** | Mobile App Flutter (iOS + Android) |
| **Domaine** | HR Tech / Recrutement |
| **Complexité** | Haute |
| **Contexte** | Greenfield (nouveau produit) |
| **Marché cible** | France uniquement (V1) |
| **Identité** | Mascotte Etoile — branding fun et attachant dans un marché sérieux |

---

## Décisions Produit & Technique

> Les choix techniques détaillés (stack, schéma de données, sécurité) sont dans `architecture-etoile-draft.md`.

| Aspect | Décision |
|--------|----------|
| **Hébergement vidéo** | Stockage cloud avec egress gratuit (Cloudflare R2) |
| **Paiements** | Stripe direct in-app (Etoile = service de recrutement, pas contenu digital — meme approche que LinkedIn/Indeed). Plan B : RevenueCat (Apple IAP + Google Play) si rejet App Store |
| **Paiements recruteurs** | Stripe via portail web (factures entreprise, B2B, commission reduite) |
| **Vérification recruteurs** | SIRET : saisie manuelle + vérification humaine (V1), API INSEE automatique (V2) |
| **Validation email** | OTP (mot de passe temporaire envoyé par email) |
| **Validation téléphone** | OTP SMS (chercheurs uniquement) |
| **Mascotte** | Personnage original à créer — élément central du branding Etoile |
| **Design** | Enrichissement charte actuelle (noir/jaune doré/blanc) — inspiration HelloWork/Indeed avec identité propre |

---

## Critères de Succès

### Succès Utilisateur

**Chercheurs d'emploi :**
| Critère | Mesure | Objectif |
|---------|--------|----------|
| Succès ultime | Obtention d'un emploi via Etoile | Premiers cas documentés à M3 |
| Qualité des contacts | Messages de recruteurs vérifiés uniquement | 100% des contacts = recruteurs authentifiés |
| Publication première vidéo | Temps pour publier après inscription | < 10 minutes (onboarding + complétude inclus) |
| Complétude profil | % d'utilisateurs atteignant 100% | > 70% dans les 48h après inscription |

**Recruteurs :**
| Critère | Mesure | Objectif |
|---------|--------|----------|
| ROI perçu | Vues sur les offres + candidatures reçues | Croissance visible mois après mois |
| Gain de temps | Organisation via dossiers candidature | Réduction du temps de tri de 50% |
| Taux de vérification SIRET | Recruteurs validés / inscrits | > 90% en 7 jours |

### Succès Business

| Métrique | M1 | M3 | M12 |
|----------|-----|-----|-----|
| Utilisateurs totaux | 1 000 | 5 000 | 15 000 |
| MAU | - | 2 500 | 7 000 |
| Ratio Chercheurs/Recruteurs | 70/30 (MVP) | 60/40 | 50/50 (cible) |
| Taux complétude profil 100% | 50% | 70% | 85% |
| Postulations via dossiers / mois | - | 500 | 5 000 |
| Alertes filtrées créées | - | 200 | 2 000 |
| Premier paiement | M1 | - | - |

### Succès Technique

| Critère | Objectif MVP | Objectif Excellence |
|---------|--------------|---------------------|
| Temps chargement vidéo | < 2 secondes | < 1 seconde |
| Disponibilité (uptime) | 99.5% | 99.9% (stable 24/7) |
| Taux de conversion onboarding | > 60% | > 80% |

---

## Modèle Économique

### Chercheurs

| Mode | Fonctionnalités | Prix |
|------|-----------------|------|
| **Gratuit** | Publier 1 vidéo/catégorie, parcourir offres, postuler, recevoir messages | 0€ |
| **Premium** | Dossiers de candidature (voir recruteurs intéressés), statistiques, voir qui a vu sa vidéo | 4,99€/mois |

### Recruteurs

| Mode | Vidéo | Affiche | Prix |
|------|-------|---------|------|
| **Gratuit** | 1 vidéo (40s, importable) | 1 affiche | 0€ |
| **Premium** | 2 vidéos + 2 affiches /semaine + stats + dossiers détaillés | Voir qui a vu | 499€/mois |
| **À l'unité** | +1 vidéo | +1 affiche | 99€ / 49€ |

**Notes importantes :**
- Chercheurs = enregistrement via app UNIQUEMENT (authenticité)
- Recruteurs = peuvent IMPORTER leurs vidéos (flexibilité pro)
- Complétude profil 100% requise pour publier et postuler
- Profil < 100% = consultation du feed uniquement (pas de publication, pas de postulation)

---

## Périmètre MVP

### Modules essentiels
- **Onboarding** : splash screen mascotte animé, écran d'accueil (connexion/inscription), choix du rôle, formulaire court avec OTP email + OTP SMS (chercheurs), CGU
- **Complétude profil** : système de progression 0-100% par étapes, blocage des fonctions clés sous 100%
- **Authentification** : email OTP + mot de passe compte, reconnexion multi-appareils
- **Profils** : chercheur (infos personnelles + préférences emploi), recruteur (entreprise + SIRET)
- **Vidéo** : enregistrement 40s in-app (chercheurs), import (recruteurs), affiches image
- **Feed** : scroll vertical TikTok-style, filtres par rôle, 2 onglets chercheur (Entreprises/Offres)
- **Dossiers candidature** : dossier auto par publication, postulations organisées, compteur
- **Messagerie** : conversations 1-to-1 temps réel + dossiers candidature
- **Alertes filtrées** : alertes chercheur configurables, push notification digest
- **Mascotte** : splash animé, écran accueil, tuto première publication
- **Paiements** : Stripe, abonnements premium, achats unitaires
- **Back-office** : vérification manuelle recruteurs (SIRET)

### Non inclus MVP
- Messages vocaux, appels in-app
- Likes, favoris
- Vérification automatique SIRET (API INSEE = V2)
- Version web
- Multi-langue (France uniquement V1)
- Salaire dans les profils/offres (se négocie en privé)

---

## User Journeys

### Journey 1 : Chercheur — De l'inscription à la première candidature

1. **Découverte** : Le chercheur télécharge l'app depuis le Store et voit le splash screen de la mascotte Etoile.
2. **Inscription** : Il choisit "Créer un compte" → "Demandeur d'emploi" → saisit prénom, nom, email, téléphone → valide par OTP email + OTP SMS → crée son mot de passe → accepte les CGU.
3. **Complétude profil** : Après inscription (50%), il est redirigé vers son profil avec la barre de progression. Il complète sa photo (70%), ses préférences emploi (90%), sa localisation (100%).
4. **Première vidéo** : Il accède à l'onglet "Publier". La mascotte lui propose un tuto vidéo (skippable). Il enregistre sa vidéo de 40s in-app, choisit une catégorie métier, et publie.
5. **Découverte des offres** : Il parcourt le feed (onglet "Offres") en swipe vertical. Il filtre par catégorie et type de contrat.
6. **Candidature** : Il trouve une offre intéressante, tape "Postuler", ajoute un message court optionnel. Sa candidature est enregistrée dans le dossier du recruteur.
7. **Suivi** : Il reçoit un message du recruteur dans sa messagerie. Il échange par texte.
8. **Alertes** : Il crée une alerte "CDI Dev Paris" avec fréquence quotidienne. Il reçoit une push notification chaque jour avec les nouvelles offres correspondantes.

### Journey 2 : Recruteur — De l'inscription à la gestion des candidatures

1. **Découverte** : Le recruteur télécharge l'app et voit le splash screen de la mascotte.
2. **Inscription** : Il choisit "Créer un compte" → "Recruteur" → saisit le nom de l'entreprise, email professionnel → valide par OTP email → crée son mot de passe → accepte les CGU.
3. **Complétude profil** : Après inscription (40%), il complète le secteur d'activité (60%), le logo + couverture (80%), le SIRET (en attente de vérification manuelle). Après validation admin → 80%. Il ajoute la description + localisation → 100%.
4. **Première publication** : Il accède à l'onglet "Publier" et choisit "Offre vidéo". Il importe une vidéo de 40s, saisit le titre du poste, la catégorie, le type de contrat (CDI). Un dossier de candidature est automatiquement créé.
5. **Découverte des candidats** : Il parcourt le feed (vidéos de chercheurs) et filtre par catégorie, zone géographique, disponibilité.
6. **Gestion des candidatures** : Il ouvre l'onglet messagerie → voit le dossier "Développeur Flutter CDI" → 3 candidatures. Il consulte les profils et vidéos des candidats.
7. **Contact** : Il tape "Contacter" sur un candidat → conversation 1-to-1 ouverte. Il échange par texte.
8. **Premium** : Il souscrit à l'offre Premium pour 2 publications/semaine + statistiques détaillées.

---

## Exigences Non-Fonctionnelles

### NF1 - Performance et Charge

| Paramètre | Valeur |
|-----------|--------|
| **Utilisateurs simultanés (nominal)** | 500 |
| **Utilisateurs simultanés (pic)** | 2 000 |
| **Temps de réponse API** | < 500ms (P95) |
| **Temps de chargement vidéo** | < 2s (démarrage lecture) |
| **Envoi OTP** | < 10s après demande |
| **Push notification alertes** | < 5min après déclenchement |

### NF2 - Disponibilité

| Paramètre | Valeur |
|-----------|--------|
| **Disponibilité cible** | 24/7 dès le MVP |
| **SLA interne** | 99.5% uptime (MVP), 99.9% (post-MVP) |
| **Maintenance planifiée** | Fenêtres nocturnes uniquement (2h-5h CET) |

### NF3 - Données Personnelles, Conformité RGPD et Droit du Travail

#### RGPD (Règlement Général sur la Protection des Données)

| Paramètre | Valeur |
|-----------|--------|
| **Hébergement** | Supabase (AWS eu-west-3 Paris), Cloudflare R2 (EU) — données en UE |
| **Base légale traitement** | Consentement explicite (inscription + CGU) |
| **CGU** | Checkbox obligatoire à l'inscription + lien vers texte complet |
| **Données personnelles** | Visibles uniquement par les recruteurs vérifiés (nom, prénom, photo, vidéo) |
| **Téléphone** | Jamais affiché publiquement. Visible uniquement dans la conversation après premier contact |
| **Droit d'accès (Art. 15)** | L'utilisateur peut consulter toutes ses données depuis son profil |
| **Droit de rectification (Art. 16)** | L'utilisateur peut modifier toutes ses données depuis l'édition de profil |
| **Droit à l'effacement (Art. 17)** | Suppression de compte avec cascade complète (US-1.10), délai max 30 jours |
| **Droit à la portabilité (Art. 20)** | Export des données personnelles au format JSON depuis les paramètres. MVP : envoi par email sur demande (bouton "Exporter mes données"). V2 : téléchargement direct in-app |
| **Consentement éclairé** | Information claire sur l'utilisation des données vidéo avant tout enregistrement |

#### Données biométriques (vidéo = image faciale)

| Paramètre | Valeur |
|-----------|--------|
| **Classification** | La vidéo contient l'image du visage — donnée biométrique potentielle au sens du RGPD Art. 9 |
| **Traitement automatisé** | Aucun traitement biométrique automatisé (pas de reconnaissance faciale, pas d'analyse IA du visage) |
| **Base légale** | Consentement explicite de l'utilisateur avant chaque enregistrement vidéo |
| **Information** | Mention claire : "Votre vidéo sera visible par les recruteurs vérifiés sur la plateforme" |
| **Suppression** | Vidéo supprimable à tout moment par l'utilisateur (R2 + BDD) |

#### Droit du Travail français

| Paramètre | Valeur |
|-----------|--------|
| **Art. L1132-1 Code du Travail** | Interdiction de discrimination à l'embauche. La plateforme ne collecte PAS : âge, sexe, origine, situation familiale, grossesse, religion, opinions politiques, handicap |
| **Risque vidéo** | La vidéo révèle des caractéristiques physiques — avertissement explicite aux recruteurs : "Toute décision basée sur des critères discriminatoires est interdite par la loi" |
| **Mentions recruteurs** | À l'inscription recruteur, information sur les obligations légales en matière de non-discrimination |
| **Modération** | Signalement possible (US-1.11) si un recruteur fait des remarques discriminatoires dans les messages |
| **CNIL recommandations** | Pas de collecte de données sensibles, vidéo = auto-présentation volontaire du candidat |

### NF4 - Support Utilisateur

| Paramètre | Valeur |
|-----------|--------|
| **Canal principal** | FAQ / Centre d'aide in-app |
| **Support humain** | Email uniquement (MVP) |
| **Temps de réponse cible** | 48h ouvrées |

---

## User Stories

### Epic 1 : Onboarding, Inscription et Profil

**US-1.0 : Splash screen mascotte**
> En tant qu'utilisateur, je vois une animation de la mascotte Etoile pendant le chargement de l'app.

Critères d'acceptation :
- [ ] Animation de la mascotte affichée pendant le chargement
- [ ] Disparaît automatiquement quand l'app est prête
- [ ] Durée max : 3 secondes (même si app prête avant)
- [ ] Transition fluide vers l'écran suivant

**US-1.1 : Écran d'accueil mascotte**
> En tant que nouvel utilisateur, je vois la mascotte avec les options "Se connecter" ou "Créer un compte".

Critères d'acceptation :
- [ ] Image de la mascotte Etoile bien visible
- [ ] Bouton "Se connecter" → page de connexion (email + mot de passe)
- [ ] Bouton "Créer un compte" → page de choix du rôle
- [ ] Design engageant, coloré, identité Etoile

**US-1.2 : Connexion (utilisateur existant)**
> En tant qu'utilisateur existant, je veux me connecter avec mon email et mot de passe.

Critères d'acceptation :
- [ ] Formulaire : email, mot de passe
- [ ] Lien "Mot de passe oublié"
- [ ] Redirection vers le feed après connexion réussie
- [ ] Message d'erreur clair si identifiants incorrects

**US-1.3 : Choix du rôle**
> En tant que nouvel utilisateur, je choisis "Demandeur d'emploi" ou "Recruteur" pour orienter mon inscription.

Critères d'acceptation :
- [ ] Question "Vous êtes ?" avec 2 boutons clairs
- [ ] Icônes distinctes pour chaque rôle
- [ ] Redirection vers le formulaire d'inscription correspondant

**US-1.4 : Inscription Chercheur**
> En tant que chercheur, je crée mon compte avec un formulaire court.

Critères d'acceptation :
- [ ] Formulaire : prénom, nom, email, numéro de téléphone
- [ ] Envoi OTP par email → saisie du code pour valider l'adresse
- [ ] Envoi OTP par SMS → saisie du code pour valider le numéro
- [ ] Création d'un mot de passe (8 caractères min) pour le compte
- [ ] Checkbox CGU + politique de données (obligatoire) avec lien pour lire le texte complet
- [ ] Après validation → redirection vers le profil à compléter (40% — catégories Inscription + Identité validées, cf. US-1.7)

**US-1.5 : Inscription Recruteur**
> En tant que recruteur, je crée mon compte professionnel avec un formulaire court.

Critères d'acceptation :
- [ ] Formulaire : nom de l'entreprise, email professionnel
- [ ] Envoi OTP par email → saisie du code pour valider l'adresse
- [ ] Création d'un mot de passe (8 caractères min) pour le compte
- [ ] Checkbox CGU + politique de données (obligatoire) avec lien pour lire le texte complet
- [ ] Après validation → redirection vers le profil à compléter (40% — catégories Inscription + Identité entreprise validées, cf. US-1.8)

**US-1.6 : Système de complétude profil**
> En tant qu'utilisateur, je vois ma progression de profil et sais quoi compléter pour atteindre 100%.

Critères d'acceptation :
- [ ] Barre de progression visible sur la page profil (0% → 100%)
- [ ] 5 catégories de validation, chacune valant 20%
- [ ] L'inscription (email/OTP/mot de passe) + identité (prénom/nom/téléphone ou nom entreprise/secteur) = 40% automatiquement après inscription
- [ ] Indicateur visuel pour chaque catégorie (complétée / à faire)
- [ ] Message explicatif : "Remplissez toutes ces informations pour faciliter les recruteurs à vous contacter"

**US-1.7 : Complétude profil Chercheur**
> En tant que chercheur, je complète mon profil pour atteindre 100%.

5 catégories (20% chacune) :
1. **Inscription** (20%) : email vérifié + OTP + mot de passe
2. **Identité** (20%) : prénom, nom, téléphone vérifié (OTP SMS)
3. **Photo de profil** (20%) : upload photo
4. **Préférences emploi** (20%) : métier recherché, type de contrat, expérience, secteur d'activité, disponibilité
5. **Localisation & situation** (20%) : pays (France), ville de résidence, situation, statut (en activité/sans activité), diplôme

Critères d'acceptation :
- [ ] Tous les champs sont obligatoires pour atteindre 100%
- [ ] Progression mise à jour en temps réel après chaque sauvegarde
- [ ] Sous 100% : consultation du feed autorisée, publication et postulation bloquées
- [ ] Si action bloquée → redirection vers profil + message "Complétez votre profil pour accéder à cette fonctionnalité"

**US-1.8 : Complétude profil Recruteur**
> En tant que recruteur, je complète mon profil pour atteindre 100%.

5 catégories (20% chacune) :
1. **Inscription** (20%) : email vérifié + OTP + mot de passe
2. **Identité entreprise** (20%) : nom entreprise, secteur d'activité
3. **Visuels** (20%) : logo entreprise (photo de profil) + photo de couverture (bannière)
4. **SIRET** (20%) : numéro SIRET saisi + vérifié (manuellement V1, API INSEE V2)
5. **Description** (20%) : description entreprise + localisation(s)

Critères d'acceptation :
- [ ] SIRET invalide → message explicatif, recruteur bloqué tant que SIRET non validé
- [ ] Vérification SIRET manuelle (V1) : recruteur en attente, notification par email à la validation/refus
- [ ] Sous 100% : consultation du feed autorisée, publication et messagerie bloquées
- [ ] Si action bloquée → redirection vers profil + message explicatif

**US-1.9 : Mot de passe oublié**
> En tant qu'utilisateur, je veux réinitialiser mon mot de passe si je l'ai oublié.

Critères d'acceptation :
- [ ] Saisie de l'email
- [ ] Envoi d'un lien de réinitialisation
- [ ] Nouveau mot de passe (8 caractères min)
- [ ] Confirmation de changement

**US-1.10 : Supprimer mon compte**
> En tant qu'utilisateur, je veux pouvoir supprimer définitivement mon compte et toutes mes données (RGPD Art. 17 — droit à l'effacement).

Critères d'acceptation :
- [ ] Option "Supprimer mon compte" accessible depuis les paramètres
- [ ] Confirmation requise avec saisie du mot de passe
- [ ] Message d'avertissement clair : "Cette action est irréversible. Toutes vos données, vidéos, messages et candidatures seront supprimées."
- [ ] Suppression effective sous 30 jours (RGPD)
- [ ] Suppression cascade : profil, vidéos (stockage + base de données), messages, candidatures, alertes, abonnement (annulé auprès du prestataire de paiement)
- [ ] Email de confirmation de suppression envoyé
- [ ] Données anonymisées dans les conversations existantes (messages conservés mais auteur = "Utilisateur supprimé")
- [ ] Possibilité de se réinscrire avec le même email après suppression

**US-1.11 : Signaler un contenu ou un utilisateur**
> En tant qu'utilisateur, je veux pouvoir signaler un contenu inapproprié ou un utilisateur.

Critères d'acceptation :
- [ ] Bouton "Signaler" accessible sur chaque vidéo/affiche dans le feed
- [ ] Bouton "Signaler" accessible dans les conversations
- [ ] Choix du motif : contenu inapproprié, spam, harcèlement, discrimination, faux profil, autre
- [ ] Confirmation : "Votre signalement a été envoyé. Merci."
- [ ] Signalement enregistré en BDD pour traitement par l'admin (US-7.2)
- [ ] Pas de notification à l'utilisateur signalé (éviter les représailles)

---

### Epic 2 : Vidéo Chercheur

**US-2.1 : Tuto mascotte première publication**
> En tant que chercheur publiant pour la première fois, la mascotte me propose un tutoriel vidéo.

Critères d'acceptation :
- [ ] Détection de la première publication (jamais publié avant)
- [ ] Affichage d'une vidéo de la mascotte montrant comment filmer une bonne vidéo
- [ ] Bouton "Skip" visible pour passer le tuto
- [ ] Le tuto ne s'affiche qu'une seule fois (jamais re-proposé)
- [ ] Après le tuto (ou skip), accès direct à la publication

**US-2.2 : Enregistrer ma vidéo de présentation**
> En tant que chercheur, je veux enregistrer une vidéo de 40 secondes pour me présenter aux recruteurs.

Critères d'acceptation :
- [ ] Accès caméra frontale
- [ ] Chronomètre visible (décompte 40s)
- [ ] Arrêt automatique à 40s
- [ ] Prévisualisation avant validation
- [ ] Option "Recommencer" illimitée
- [ ] Pas d'import externe (enregistrement in-app uniquement)
- [ ] Profil à 100% requis pour publier

**US-2.3 : Publier ma vidéo dans une catégorie**
> En tant que chercheur, je veux associer ma vidéo à une catégorie métier pour être trouvé.

Critères d'acceptation :
- [ ] Choix d'une catégorie parmi la liste prédéfinie
- [ ] 1 seule vidéo par catégorie (remplacement si nouvelle)
- [ ] Vidéo visible dans le feed après upload réussi
- [ ] Notification de confirmation
- [ ] **Création automatique d'un dossier dans la messagerie** avec le nom de la catégorie/vidéo

**US-2.4 : Modifier/Supprimer ma vidéo**
> En tant que chercheur, je veux pouvoir remplacer ou supprimer ma vidéo.

Critères d'acceptation :
- [ ] Bouton "Remplacer" = nouvel enregistrement
- [ ] Bouton "Supprimer" avec confirmation
- [ ] Suppression du dossier associé (si vide) ou archivage (si candidatures existantes)
- [ ] Suppression effective sous 24h (RGPD)

---

### Epic 3 : Vidéo et Affiche Recruteur

**US-3.1 : Publier une offre vidéo**
> En tant que recruteur, je veux publier une vidéo de présentation de mon offre d'emploi.

Critères d'acceptation :
- [ ] Import vidéo depuis galerie OU enregistrement in-app
- [ ] Durée max : 40 secondes (découpage automatique si > 40s)
- [ ] Ajout titre du poste + catégorie + type de contrat (CDI/CDD/Intérim/Freelance/Alternance/Stage)
- [ ] **Nom de l'offre obligatoire** → crée un dossier dans la messagerie
- [ ] Compte gratuit : 1 vidéo max
- [ ] Compte premium : 2 vidéos/semaine
- [ ] Profil à 100% + SIRET vérifié requis

**US-3.2 : Publier une affiche**
> En tant que recruteur, je veux publier une affiche (image) pour une offre.

Critères d'acceptation :
- [ ] Upload image (JPG, PNG)
- [ ] Format recommandé affiché (9:16)
- [ ] Ajout titre du poste + catégorie + type de contrat
- [ ] **Nom de l'offre obligatoire** → crée un dossier dans la messagerie
- [ ] Compte gratuit : 1 affiche max
- [ ] Compte premium : 2 affiches/semaine

**US-3.3 : Publier une présentation entreprise**
> En tant que recruteur, je veux publier une vidéo de présentation de mon entreprise (gratuit).

Critères d'acceptation :
- [ ] Import vidéo ou enregistrement in-app
- [ ] Type "présentation" (pas d'offre d'emploi)
- [ ] Gratuit (ne consomme pas de crédit)
- [ ] Visible dans l'onglet "Entreprises" du feed chercheur
- [ ] Pas de dossier créé (pas de candidature sur une présentation)

**US-3.4 : Gérer mes publications**
> En tant que recruteur, je veux voir et gérer toutes mes publications actives.

Critères d'acceptation :
- [ ] Liste de mes vidéos, affiches et présentations
- [ ] Statut (active, expirée, supprimée)
- [ ] Actions : modifier, supprimer, renouveler
- [ ] Compteur de vues (premium)
- [ ] Lien vers le dossier de candidatures associé

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
- [ ] **État vide** : si aucun candidat, afficher un écran encourageant ("Aucun candidat pour le moment. Ajustez vos filtres ou revenez plus tard.")

**US-4.2 : Filtrer les candidats (Recruteur)**
> En tant que recruteur, je veux filtrer les candidats par critères.

Critères d'acceptation :
- [ ] Filtre par catégorie métier
- [ ] Filtre par zone géographique
- [ ] Filtre par disponibilité
- [ ] Filtre par type de contrat
- [ ] Filtres cumulables
- [ ] Bouton "Réinitialiser filtres"

**US-4.3 : Parcourir les offres (Chercheur)**
> En tant que chercheur, je veux parcourir les offres des recruteurs.

Critères d'acceptation :
- [ ] 2 onglets : "Entreprises" (présentations) / "Offres" (vidéos + affiches)
- [ ] Feed vertical (vidéos + affiches mélangées)
- [ ] Badge "Entreprise vérifiée" visible
- [ ] Informations : nom entreprise, titre poste, localisation, type de contrat
- [ ] Accès au profil entreprise en tapant
- [ ] **État vide** : si aucune offre, afficher un écran avec la mascotte ("Pas encore d'offres ici. Revenez bientôt !")

**US-4.4 : Filtrer les offres (Chercheur)**
> En tant que chercheur, je veux filtrer les offres par critères.

Critères d'acceptation :
- [ ] Filtre par catégorie métier
- [ ] Filtre par type de contrat
- [ ] Filtre par zone géographique
- [ ] Sauvegarde des filtres préférés

**US-4.5 : Postuler à une offre (Chercheur)**
> En tant que chercheur, je veux postuler à une offre depuis le feed.

Critères d'acceptation :
- [ ] Bouton "Postuler" visible sur chaque offre dans le feed
- [ ] Profil 100% requis pour postuler (sinon redirection profil + message)
- [ ] Champ de message court (max 300 caractères) optionnel avant envoi
- [ ] Confirmation : "Vous avez bien postulé !"
- [ ] Le profil du chercheur est enregistré dans le dossier du recruteur pour cette offre
- [ ] 1 seule candidature par offre (bouton grisé si déjà postulé)
- [ ] Le chercheur peut aussi envoyer un message direct via "Contacter"

---

### Epic 5 : Messagerie et Dossiers de Candidature

**US-5.1 : Dossiers de candidature (Recruteur)**
> En tant que recruteur, je veux voir les candidatures organisées par offre dans mes messages.

Critères d'acceptation :
- [ ] Onglet messagerie affiche les dossiers (un par offre publiée)
- [ ] Chaque dossier montre : nom de l'offre, compteur de candidatures
- [ ] Ouverture du dossier → liste des candidats (nom, prénom, photo de profil)
- [ ] Clic sur un candidat → voir sa vidéo + bouton "Contacter"
- [ ] "Contacter" ouvre une conversation 1-to-1 classique
- [ ] Compteur incrémenté à chaque nouvelle candidature
- [ ] **État vide** : si aucune candidature dans un dossier, afficher "Aucune candidature pour cette offre pour l'instant."

**US-5.2 : Dossiers de candidature (Chercheur Premium)**
> En tant que chercheur premium, je veux voir les recruteurs intéressés par mes vidéos.

Critères d'acceptation :
- [ ] Onglet messagerie affiche les dossiers (un par vidéo publiée)
- [ ] Chaque dossier montre : nom de la vidéo/catégorie, compteur de recruteurs
- [ ] Ouverture du dossier → liste des recruteurs avec leur message court
- [ ] Clic sur un recruteur → voir son profil + bouton "Contacter"
- [ ] Feature premium uniquement (chercheurs gratuits ne voient pas les dossiers)

**US-5.3 : Conversations 1-to-1**
> En tant qu'utilisateur, je veux envoyer et recevoir des messages texte avec d'autres utilisateurs.

Critères d'acceptation :
- [ ] Liste des conversations actives (hors dossiers)
- [ ] Badge "Non lu" sur les nouveaux messages
- [ ] **État vide** : si aucune conversation, afficher "Aucun message. Commencez par postuler ou contacter un profil !"
- [ ] Réponse en texte libre
- [ ] Info de l'interlocuteur visible (entreprise/poste ou prénom/catégorie)
- [ ] Notifications push pour les nouveaux messages

**US-5.4 : Bloquer un utilisateur**
> En tant qu'utilisateur, je veux pouvoir bloquer un autre utilisateur indésirable.

Critères d'acceptation :
- [ ] Option "Bloquer" dans la conversation
- [ ] Confirmation requise
- [ ] Plus de messages possibles après blocage
- [ ] Contenu de l'utilisateur bloqué invisible dans le feed

---

### Epic 6 : Paiements et Abonnements

**US-6.1 : Souscrire à Premium (Chercheur)**
> En tant que chercheur, je veux souscrire à l'offre Premium pour accéder aux dossiers et statistiques.

Critères d'acceptation :
- [ ] Page détaillant les avantages Premium (dossiers, statistiques, visibilité)
- [ ] Prix affiché : 4,99€/mois
- [ ] **iOS** : Paiement via Apple In-App Purchase (obligatoire pour contenu digital sur iOS)
- [ ] **Android** : Paiement via Google Play Billing (obligatoire pour contenu digital sur Android)
- [ ] Activation immédiate après paiement
- [ ] Reçu par email
- [ ] Restauration des achats sur nouvel appareil

**US-6.2 : Souscrire à Premium (Recruteur)**
> En tant que recruteur, je veux souscrire à l'offre Premium pour plus de publications.

Critères d'acceptation :
- [ ] Page détaillant les avantages Premium
- [ ] Prix affiché : 499€/mois
- [ ] **iOS** : Paiement via Apple In-App Purchase (obligatoire)
- [ ] **Android** : Paiement via Google Play Billing (obligatoire)
- [ ] Alternative web : paiement par carte via le portail web (lien externe, commission réduite)
- [ ] Possibilité de facture entreprise (via portail web)
- [ ] Activation immédiate

**US-6.3 : Acheter à l'unité (Recruteur)**
> En tant que recruteur, je veux acheter des publications supplémentaires à l'unité.

Critères d'acceptation :
- [ ] +1 vidéo : 99€
- [ ] +1 affiche : 49€
- [ ] Paiement via In-App Purchase (iOS/Android) ou carte bancaire (web)
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

**US-7.1 : Valider les recruteurs (SIRET)**
> En tant qu'admin, je veux valider manuellement les inscriptions recruteurs.

Critères d'acceptation :
- [ ] Liste des recruteurs en attente de vérification SIRET
- [ ] Visualisation SIRET + infos entreprise
- [ ] Actions : Approuver / Rejeter (avec motif)
- [ ] Email automatique au recruteur (validation ou refus avec explication)
- [ ] Recruteur refusé → profil bloqué, ne peut pas publier ni contacter

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
- [ ] Nombre d'utilisateurs (total, par rôle, taux complétude 100%)
- [ ] Nombre de vidéos/affiches publiées
- [ ] Nombre de postulations via dossiers
- [ ] Nombre d'alertes filtrées actives
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

### Epic 9 : Alertes Filtrées (Chercheur)

**US-9.1 : Créer une alerte filtrée**
> En tant que chercheur, je veux créer une alerte pour être notifié des nouvelles offres correspondant à mes critères.

Critères d'acceptation :
- [ ] Accessible depuis le profil ou les paramètres
- [ ] Filtres configurables : catégorie métier, type de contrat, zone géographique
- [ ] Choix de la fréquence : quotidien, tous les 2 jours, hebdomadaire
- [ ] Nombre d'alertes illimité
- [ ] Possibilité de nommer chaque alerte (ex: "CDI Dev Paris")
- [ ] Profil 100% requis pour créer une alerte

**US-9.2 : Recevoir les notifications d'alerte**
> En tant que chercheur, je veux recevoir une push notification quand de nouvelles offres correspondent à mes alertes.

Critères d'acceptation :
- [ ] Push notification à la fréquence choisie
- [ ] Message : "Il y a X nouvelles offres qui s'offrent à vous"
- [ ] Tap sur la notification → ouvre le feed filtré avec les offres correspondantes
- [ ] Pas de notification si 0 nouvelles offres sur la période

**US-9.3 : Gérer mes alertes**
> En tant que chercheur, je veux modifier ou supprimer mes alertes.

Critères d'acceptation :
- [ ] Liste de mes alertes actives
- [ ] Modifier les filtres ou la fréquence
- [ ] Activer/désactiver une alerte (sans la supprimer)
- [ ] Supprimer une alerte définitivement

---

---

> **Note : L'Epic 10 "Mascotte et Branding" a été fusionnée dans les Epics 1 et 2.**
> Les user stories mascotte sont intégrées dans : US-1.0 (splash screen), US-1.1 (écran d'accueil mascotte), US-2.1 (tuto mascotte première publication).
> Cela évite les doublons et centralise toute l'expérience onboarding/mascotte dans un parcours linéaire.

---

## Risques et Dépendances

### Risques Identifiés

| ID | Risque | Probabilité | Impact | Mitigation |
|----|--------|-------------|--------|------------|
| R1 | **Rejet Apple/Google Store** (politique vidéo ou paiements) | Moyenne | Critique | Revue des guidelines avant dev, prévoir ajustements UI |
| R2 | **Fraude recruteurs** (faux SIRET, arnaques) | Haute | Haute | Vérification SIRET manuelle V1, API INSEE V2, signalement utilisateurs |
| R3 | **Contenus inappropriés** (vidéos offensantes) | Moyenne | Haute | Modération réactive, bouton signaler, suspension auto après X signalements |
| R4 | **Faible adoption initiale** (poule et l'oeuf) | Haute | Haute | Stratégie d'acquisition ciblée, contenu "seed" au lancement |
| R5 | **Coûts Cloudflare R2 sous-estimés** | Basse | Moyenne | Monitoring consommation, compression vidéo agressive |
| R6 | **Abandon onboarding** (trop d'étapes, complétude 100%) | Moyenne | Haute | Messages motivants, UX progressive, rappels push |
| R7 | **Création mascotte** (design, coûts, délais) | Moyenne | Moyenne | Brief créatif clair, prestataire identifié tôt, mascotte simple mais mémorable |
| R8 | **RGPD - Demandes de suppression** | Certaine | Basse | Processus automatisé de suppression, documentation |
| R9 | **OTP SMS coûts** (envois en volume) | Basse | Basse | Provider SMS compétitif (Twilio/Vonage), rate limiting anti-abus |

### Dépendances Externes

| ID | Dépendance | Type | Criticité | Contact/Lien |
|----|------------|------|-----------|--------------|
| D1 | **Cloudflare R2** | Infrastructure vidéo | Critique | cloudflare.com |
| D2 | **Stripe** | Paiements | Critique | stripe.com |
| D3 | **Apple App Store** | Distribution iOS | Critique | App Store Connect |
| D4 | **Google Play Store** | Distribution Android | Critique | Google Play Console |
| D5 | **Service email transactionnel** | Notifications + OTP email | Haute | Resend / SendGrid |
| D6 | **Service SMS OTP** | Validation téléphone | Haute | Twilio / Vonage |
| D7 | **API INSEE** (V2) | Vérification SIRET automatique | Moyenne | api.insee.fr |
| D8 | **Designer mascotte** | Branding | Haute | Prestataire à identifier |

### Dépendances Internes

| ID | Dépendance | Équipe/Ressource | Criticité | Statut |
|----|------------|------------------|-----------|--------|
| DI1 | **Design UI/UX** | Designer | Haute | À recruter/externaliser |
| DI2 | **Design mascotte** | Illustrateur | Haute | À identifier |
| DI3 | **Backend API** | Développeur backend | Critique | Supabase |
| DI4 | **App Flutter** | Développeur mobile | Critique | En cours |
| DI5 | **Modérateur contenu** | Opérations | Moyenne | Manuel par fondateur au MVP |
| DI6 | **Rédaction CGU** | Juridique | Haute | À faire avant lancement |

---

## Exigences Mobile (iOS + Android)

### Permissions device

| Permission | Usage | Demande |
|------------|-------|---------|
| **Caméra** | Enregistrement vidéo 40s (chercheurs + recruteurs) | Au moment de l'enregistrement uniquement |
| **Microphone** | Audio de la vidéo | Combinée avec la demande caméra |
| **Galerie photos** | Import vidéo/image (recruteurs), upload photo profil | Au moment de l'import |
| **Notifications push** | Messages, alertes filtrées, rappels | À l'inscription (explications claires avant) |
| **Localisation** | Carte OpenStreetMap, filtres géographiques | Optionnelle, au besoin uniquement |

### Paiements in-app (Apple App Store / Google Play)

> **IMPORTANT** : Apple et Google imposent l'utilisation de leur système de paiement pour le contenu digital (abonnements, crédits de publication). L'utilisation de Stripe direct dans l'app pour du contenu digital entraîne un rejet.

| Plateforme | Système | Commission | Mitigation |
|------------|---------|------------|------------|
| **iOS** | StoreKit 2 / Apple In-App Purchase | 15-30% | Prix ajustés pour absorber la commission |
| **Android** | Google Play Billing | 15-30% | Prix ajustés pour absorber la commission |
| **Web** | Stripe (CB direct) | ~3% | Lien web pour les recruteurs souhaitant éviter la commission |

**Stratégie** : Utiliser `in_app_purchase` (Flutter package) pour iOS/Android. Stripe en complément via portail web pour les gros comptes recruteurs (factures entreprise).

### Mode offline

| Situation | Comportement |
|-----------|-------------|
| **Perte de connexion pendant navigation** | Message "Pas de connexion internet", vidéos déjà chargées restent lisibles |
| **Perte de connexion pendant envoi message** | Message mis en file d'attente, envoi automatique au retour de la connexion |
| **Perte de connexion pendant upload vidéo** | Upload annulé avec message d'erreur, reprise manuelle possible |
| **Perte de connexion générale** | Bannière persistante en haut de l'écran, données en cache affichées |

### Accessibilité (a11y)

| Critère | Implémentation |
|---------|----------------|
| **Contraste** | Ratio minimum 4.5:1 (WCAG AA) pour le texte |
| **Taille du texte** | Support du scaling système (Dynamic Type iOS / Font Scale Android) |
| **Screen readers** | Labels sémantiques sur tous les boutons et éléments interactifs |
| **Navigation** | Ordre logique de focus pour le clavier / switch access |

### Terminologie unifiée

> Pour assurer la cohérence dans toute l'application :

| Terme officiel | Alternatives à éviter |
|---------------|----------------------|
| **Chercheur** (ou "Chercheur d'emploi") | Demandeur, candidat, seeker |
| **Recruteur** | Employeur, entreprise (sauf dans "nom de l'entreprise") |
| **Postuler** | Candidater, appliquer |
| **Publication** | Offre (sauf "offre d'emploi" en contexte), post |

> **Note** : Les spécifications techniques (architecture, schéma de données, stack, sécurité) sont dans le document séparé `architecture-etoile-draft.md`.

---

## Timeline MVP

### Vue d'ensemble

| Phase | Durée | Objectif |
|-------|-------|----------|
| **Phase 0** | 2 semaines | Setup, Design, Mascotte brief |
| **Phase 1** | 5 semaines | Onboarding, Auth, Profils, Complétude |
| **Phase 2** | 4 semaines | Vidéo, Feed, Dossiers candidature |
| **Phase 3** | 3 semaines | Messagerie, Alertes, Paiements |
| **Phase 4** | 2 semaines | Admin, Tests, Polish, Mascotte intégrée |
| **Phase 5** | 1 semaine | Lancement |

**Durée totale estimée : 17 semaines (~4 mois)**

---

## Prochaines Étapes

| Étape | Contenu | Statut |
|-------|---------|--------|
| 1 | Classification du projet | Fait |
| 2 | Clarifications techniques | Fait |
| 3 | Critères de succès | Fait (mis à jour) |
| 4 | Modèle économique | Fait (mis à jour) |
| 5 | User Stories (10 Epics) | Fait (mis à jour) |
| 6 | Risques et Dépendances | Fait (mis à jour) |
| 7 | Spécifications techniques | Fait (mis à jour) |
| 8 | Timeline | Fait (mis à jour) |
| 9 | **Architecture détaillée** | À faire |
| 10 | **Epics et Stories de développement** | À faire |

---

*Document édité par John (PM) — Dernière mise à jour : 2026-02-18*
*Modifications : refonte onboarding mascotte, système complétude profil, dossiers candidature, alertes filtrées, enrichissement branding*
