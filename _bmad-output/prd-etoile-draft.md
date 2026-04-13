---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 'e-01', 'e-02', 'e-03', 'e-04']
status: edited
lastStep: "Edit Step E-4"
date: 2026-02-01
validatedAt: 2026-02-01
lastEdited: 2026-04-03
editHistory:
  - date: 2026-04-03
    changes: "PIVOT MAJEUR : modele deux plateformes — App mobile (Flutter) = chercheurs only, SaaS web (Next.js) = recruteurs only, backend Supabase partage. Suppression IAP, ajout username/scoring, nouvelles Epics SaaS (10-15), recriture User Journeys et Modele Economique"
  - date: 2026-02-18
    changes: "Refonte onboarding (mascotte, OTP, CGU), systeme completude profil, dossiers candidature messagerie, alertes filtrees chercheur, mascotte & branding, enrichissement UX"
  - date: 2026-02-18
    changes: "Validation PRD round 1 (59→78): +Executive Summary, +User Journeys, +US Suppression compte, +US Signaler, +Conformite RGPD/HR Tech, +Specificites mobile (IAP/offline/permissions/a11y), Epic 10 fusionnee, prix fixes, terminologie unifiee, specs techniques extraites vers architecture-etoile-draft.md"
  - date: 2026-02-18
    changes: "Validation PRD round 2 (78→85+): prix Executive Summary alignes (4,99€/499€), completude profil corrigee (40% post-inscription, pas 50%), etats vides ajoutes (feed, dossiers, messagerie), RGPD Art.20 portabilite au MVP, noms techniques abstraits dans les US (Stripe→prestataire paiement)"
author: John (PM)
projectName: Etoile
---

# PRD: Etoile — Plateforme de Recrutement Video

## Executive Summary

Etoile est une **plateforme de recrutement par video courte** (40 secondes, style TikTok) destinee au marche francais de l'alternance en Ile-de-France. Elle se compose de **deux produits distincts** partageant le meme backend :

- **App mobile (Flutter)** — pour les **chercheurs d'alternance**, qui se presentent via des videos authentiques enregistrees in-app et postulent aux offres
- **SaaS web (Next.js)** — pour les **recruteurs verifies** (SIRET), qui publient leurs offres, decouvrent les candidats via une grille video interactive, et gerent leur pipeline de pre-selection

**Positionnement** : Etoile est un **complement au CV**, pas un remplacement. La video de 40 secondes permet la pre-selection et la visibilite des soft skills — presentation, motivation, aisance orale — que le CV ne peut pas transmettre.

L'application se distingue par : (1) un onboarding guide par une mascotte originale, (2) un systeme de completude profil a 100% obligatoire, (3) un username unique (@pseudo) pour chaque chercheur permettant l'acces direct a son profil, (4) un score de matching automatique (secteur, ville, niveau, specialite), et (5) une experience recruteur desktop-first avec grille video, hover preview, et modal de decision rapide.

Le modele economique repose sur un **acces gratuit pour les chercheurs** et un **abonnement SaaS pour les recruteurs** (499€/mois via Stripe direct), complete par des achats a l'unite. Le MVP cible 1 000 chercheurs et 50 recruteurs a M1, avec un lancement prevu en 2 tracks paralleles.

**Architecture technique** : Backend Supabase partage (Auth, PostgreSQL, Realtime, Edge Functions) + Cloudflare R2 (videos). Cout supplementaire SaaS : ~10 EUR/an (Vercel + domaine).

**Architecture detaillee** dans `architecture-etoile-draft.md` et `saas-etoile/` (brainstorming SaaS).

---

## Classification Projet

| Critere | Valeur |
|---------|--------|
| **Type** | Plateforme deux produits : App Mobile Flutter (iOS + Android) + SaaS Web Next.js |
| **Domaine** | HR Tech / Recrutement Alternance |
| **Complexite** | Haute |
| **Contexte** | Greenfield (nouveau produit) |
| **Marche cible** | France — Ile-de-France (beta), alternance uniquement |
| **Identite** | Mascotte Etoile — branding fun et attachant dans un marche serieux |
| **Public chercheur** | Etudiants et jeunes diplomes en recherche d'alternance |
| **Public recruteur** | Entreprises verifiees SIRET recrutant en alternance en IdF |

---

## Architecture Deux Plateformes

```
App Mobile (Flutter)          SaaS Web (Next.js + Tailwind + Shadcn/ui)
    Chercheur                       Recruteur
         \                           /
          \     Supabase SDK        /
           \                       /
        Supabase (Auth + PostgreSQL + Realtime + Edge Functions)
                      |
             Cloudflare R2 + Worker
             (Videos + Thumbnails)
```

| Composant | App Mobile | SaaS Web |
|-----------|-----------|----------|
| **Frontend** | Flutter 3.x (iOS + Android) | Next.js + Tailwind + Shadcn/ui |
| **State** | BLoC (flutter_bloc) | React state + Supabase Realtime |
| **Auth** | Supabase Auth (email + OTP) | Supabase Auth (meme systeme) |
| **Backend** | Supabase (partage) | Supabase (partage) |
| **Video** | Cloudflare R2 Worker | Cloudflare R2 Worker (meme URL) |
| **Paiements** | Aucun (chercheur gratuit) | Stripe direct (web) |
| **Deploiement** | App Store + Google Play | Vercel + domaine custom |
| **Messagerie** | Supabase Realtime | Supabase Realtime (sync native) |

---

## Decisions Produit & Technique

> Les choix techniques detailles (stack, schema de donnees, securite) sont dans `architecture-etoile-draft.md`.

| Aspect | Decision |
|--------|----------|
| **Hebergement video** | Cloudflare R2 (egress gratuit) via Workers |
| **Paiements recruteurs** | Stripe direct sur le SaaS web (service reel = pas de commission Apple/Google). Pas d'IAP |
| **Paiements chercheurs** | Gratuit pour la beta. Premium chercheur reporte post-lancement |
| **Verification recruteurs** | SIRET : saisie + verification API Sirene (V1), verification humaine admin |
| **Validation email** | OTP email 6 chiffres (Supabase Auth) |
| **Username chercheur** | @pseudo unique, choisi dans l'app mobile, recherchable dans le SaaS |
| **Score de matching** | Edge Function : secteur (30%) + ville IdF (25%) + niveau etudes (25%) + specialite (20%) |
| **Mascotte** | Personnage original — element central du branding Etoile |
| **Design mobile** | Enrichissement charte actuelle (noir/jaune dore/blanc) |
| **Design SaaS** | Desktop-first, grille + modal, Shadcn/ui |
| **Stack SaaS** | Next.js + Tailwind + Shadcn/ui + Recharts, deploiement Vercel |
| **Backend partage** | Meme projet Supabase pour les deux plateformes (zero infra supplementaire) |
| **Profil public SSR** | Next.js SSR pour `/profile/@username` (SEO, partage social) |

---

## Criteres de Succes

### Succes Chercheurs (App Mobile)

| Critere | Mesure | Objectif |
|---------|--------|----------|
| Succes ultime | Obtention d'une alternance via Etoile | Premiers cas documentes a M3 |
| Qualite des contacts | Messages de recruteurs verifies uniquement | 100% contacts = recruteurs authentifies |
| Publication premiere video | Temps pour publier apres inscription | < 10 minutes (onboarding + completude inclus) |
| Completude profil | % d'utilisateurs atteignant 100% | > 70% dans les 48h |
| Username choisi | % d'utilisateurs ayant un @username | > 90% a J7 |

### Succes Recruteurs (SaaS Web)

| Critere | Mesure | Objectif |
|---------|--------|----------|
| Temps de pre-selection | Temps moyen par candidat (grille → decision) | < 30 secondes |
| Taux de shortlist | Candidats shortlistes / candidats vus | 10-20% |
| Adoption grille vs feed | % utilisant la vue grille | > 60% |
| Taux de contact | Candidats contactes / shortlistes | > 40% |
| ROI percu | Vues offres + candidatures recues | Croissance visible mois apres mois |
| Verification SIRET | Recruteurs valides / inscrits | > 90% en 7 jours |

### Succes Business

| Metrique | M1 | M3 | M12 |
|----------|-----|-----|-----|
| Chercheurs inscrits | 1 000 | 5 000 | 15 000 |
| Recruteurs inscrits | 50 | 200 | 1 000 |
| MAU chercheurs | - | 2 500 | 7 000 |
| MAU recruteurs | - | 150 | 700 |
| Taux completude profil 100% | 50% | 70% | 85% |
| Candidatures / mois | - | 500 | 5 000 |
| Premier paiement recruteur | M1 | - | - |
| MRR recruteurs | 2 500€ | 20 000€ | 100 000€ |

### Succes Technique

| Critere | Objectif MVP | Objectif Excellence |
|---------|--------------|---------------------|
| Temps chargement video | < 2 secondes | < 1 seconde |
| Disponibilite (uptime) | 99.5% | 99.9% |
| Taux conversion onboarding | > 60% | > 80% |
| Score matching < 500ms | > 95% | > 99% |

---

## Modele Economique

### Chercheurs (App Mobile)

| Mode | Fonctionnalites | Prix |
|------|-----------------|------|
| **Gratuit** | Publier videos, parcourir offres, postuler, recevoir messages, alertes | 0€ |
| **Premium** (post-lancement) | Statistiques avancees, visibilite boostee, voir qui a vu sa video | 4,99€/mois (Stripe web) |

> **Note beta** : Les chercheurs sont **100% gratuits** pendant la beta. Le premium chercheur sera active post-lancement via un lien de paiement web (pas d'IAP).

### Recruteurs (SaaS Web)

| Mode | Acces | Publications | Prix |
|------|-------|-------------|------|
| **Gratuit** | Grille candidats (lecture), 1 offre active, messagerie limitee | 1 video + 1 affiche | 0€ |
| **Premium** | Dashboard complet, grille + modal, stats, annotations, alertes | 2 videos + 2 affiches /semaine | 499€/mois |
| **Credit video** | +1 publication video | — | 99€ |
| **Credit affiche** | +1 publication affiche | — | 49€ |

**Paiement** : Stripe direct sur le SaaS web (carte bancaire, facture entreprise). Aucun intermediaire Apple/Google.

**Notes importantes :**
- Chercheurs = enregistrement video via app mobile UNIQUEMENT (authenticite)
- Recruteurs = publient leurs offres depuis le SaaS web (import video ou affiche)
- Completude profil 100% requise pour publier et postuler (chercheur)
- Username @pseudo obligatoire pour les chercheurs

---

## Perimetre MVP

### MVP App Mobile — Chercheur

- **Onboarding** : splash screen mascotte, ecran accueil, choix role (chercheur uniquement sur mobile), OTP email, CGU
- **Completude profil** : progression 0-100% par etapes, blocage sous 100%
- **Username** : choix @pseudo unique lors de la completion du profil
- **Video** : enregistrement 40s in-app (3 phases guidees), publication par secteur
- **Feed** : scroll vertical des offres recruteurs (videos + affiches), filtres secteur/ville/specialite
- **Candidatures** : postuler en 1 clic, page "Mes candidatures" avec suivi statut
- **Messagerie** : conversations 1-to-1 temps reel avec recruteurs
- **Alertes filtrees** : alertes configurables, push notifications digest
- **Parametres** : FAQ, contact, mentions legales, suppression compte, export donnees

### MVP SaaS Web — Recruteur

- **Auth** : login email/OTP (meme compte Supabase), inscription avec SIRET
- **Page Accueil / Briefing** : nouvelles candidatures, messages non lus, alertes
- **Publication offres** : import video ou affiche depuis le web, titre, secteur, type contrat
- **Grille candidats** : miniatures video (4-6/ecran), hover = preview auto, score matching badge
- **Modal candidat** : video a gauche + panneau decision a droite (Profil / Evaluer / Contacter)
- **Actions rapides** : shortlist/passer/annoter sans ouvrir le modal (hover buttons)
- **Dashboard** : funnel par offre + KPIs + comparaison offres
- **Recherche username** : barre @username dans la sidebar
- **Messagerie** : conversations synchronisees avec l'app mobile (Supabase Realtime)
- **Paiement** : Stripe Checkout (abonnement + credits a l'unite)

### Non inclus MVP

- Messages vocaux, appels in-app
- Likes, favoris
- Version web pour les chercheurs
- Multi-langue (France uniquement V1)
- Salaire dans les profils/offres (se negocie en prive)
- QR code profil chercheur (V2)
- Tags personnalisables recruteur (V2)
- Comparaison cote a cote candidats (V2)
- Vue Kanban drag & drop (V2)
- Roles et permissions multi-utilisateurs (V2)
- SSO entreprise SAML/OIDC (V2)
- Premium chercheur (post-lancement)

---

## User Journeys

### Journey 1 : Chercheur — De l'inscription a la premiere candidature (App Mobile)

1. **Decouverte** : Le chercheur telecharge l'app depuis le Store et voit le splash screen anime de la mascotte Etoile.
2. **Inscription** : Il choisit "Creer un compte" → saisit prenom, nom, email → valide par OTP email 6 chiffres → cree son mot de passe → accepte les CGU.
3. **Completude profil** : Apres inscription (20%), il est redirige vers son profil. Il complete sa photo (40%), son identite — prenom, nom, age (60%), ses etudes — ecole, niveau (80%), sa localisation — ville IdF (90%), son domaine + specialite (100%). Il choisit son **username @pseudo** unique.
4. **Premiere video** : Il accede a l'onglet "Enregistrer". La mascotte lui propose un tuto (skippable). Il enregistre sa video de 40s in-app (3 phases guidees), choisit un secteur, et publie.
5. **Decouverte des offres** : Il parcourt le feed vertical (offres video + affiches). Il filtre par secteur et specialite.
6. **Candidature** : Il trouve une offre interessante, tape "Postuler" → candidature envoyee en 1 clic avec animation de succes. Son profil + video sont visibles dans le SaaS du recruteur.
7. **Suivi** : Il consulte "Mes candidatures" — statut : en attente / contacte / retire. Le recruteur le contacte via messagerie. Il recoit une push notification.
8. **Alertes** : Il cree une alerte "Alternance Commerce Paris" avec frequence quotidienne. Il recoit une push notification chaque jour avec les nouvelles offres correspondantes.

### Journey 2 : Recruteur — De l'inscription a la pre-selection (SaaS Web)

1. **Decouverte** : Le recruteur accede au SaaS web (app.etoile-recrutement.fr) et voit la page d'accueil avec presentation du service.
2. **Inscription** : Il clique "Creer un compte recruteur" → saisit nom entreprise, email pro, SIRET → verification SIRET via API Sirene → OTP email → mot de passe → CGU. Son compte est en attente de verification admin.
3. **Completude profil** : Apres validation admin, il complete son profil : secteur d'activite, description entreprise (>50 chars), localisation IdF, document justificatif.
4. **Premiere publication** : Il accede a "Mes offres" → "Nouvelle offre". Il importe une video de 40s ou une affiche, saisit le titre du poste, le secteur, le type de contrat (Alternance). L'offre est publiee et visible dans le feed mobile des chercheurs.
5. **Decouverte candidats (Grille)** : Il ouvre la grille candidats. La sidebar gauche liste ses offres avec compteurs de candidatures. Il selectionne une offre → la grille affiche les miniatures des candidats avec score de matching (ex: 87%). Au survol, la video joue automatiquement en mute.
6. **Evaluation (Modal)** : Il clique sur un candidat → modal plein ecran : video a gauche (60%), panneau decision a droite (40%) avec 3 onglets (Profil / Evaluer / Contacter). Il shortliste le candidat en 1 clic.
7. **Contact** : Depuis le modal, il clique "Contacter" → conversation 1-to-1. Le chercheur recoit une push notification sur son mobile. Les messages sont synchronises en temps reel.
8. **Dashboard** : Il consulte son dashboard : funnel de recrutement par offre (candidatures → shortlist → contactes → embauches), KPIs, comparaison entre offres.
9. **Recherche directe** : Un candidat lui donne son @username en entretien physique. Il tape @pseudo dans la barre de recherche → acces direct au profil + video.

---

## Exigences Non-Fonctionnelles

### NF1 - Performance et Charge

| Parametre | Valeur |
|-----------|--------|
| **Utilisateurs simultanees (nominal)** | 500 (mobile) + 200 (SaaS) |
| **Utilisateurs simultanees (pic)** | 2 000 (mobile) + 500 (SaaS) |
| **Temps de reponse API** | < 500ms (P95) |
| **Temps de chargement video** | < 2s (demarrage lecture) |
| **Envoi OTP** | < 10s apres demande |
| **Calcul score matching** | < 500ms |
| **Push notification alertes** | < 5min apres declenchement |

### NF2 - Disponibilite

| Parametre | Valeur |
|-----------|--------|
| **Disponibilite cible** | 24/7 des le MVP |
| **SLA interne** | 99.5% uptime (MVP), 99.9% (post-MVP) |
| **Maintenance planifiee** | Fenetres nocturnes uniquement (2h-5h CET) |

### NF3 - Donnees Personnelles, Conformite RGPD et Droit du Travail

#### RGPD (Reglement General sur la Protection des Donnees)

| Parametre | Valeur |
|-----------|--------|
| **Hebergement** | Supabase (AWS eu-west-3 Paris), Cloudflare R2 (EU) — donnees en UE |
| **Base legale traitement** | Consentement explicite (inscription + CGU) |
| **CGU** | Checkbox obligatoire a l'inscription + lien vers texte complet |
| **Donnees personnelles** | Visibles uniquement par les recruteurs verifies (nom, prenom, photo, video) |
| **Username** | Publique (@pseudo), ne revele pas le nom reel |
| **Droit d'acces (Art. 15)** | L'utilisateur peut consulter toutes ses donnees depuis son profil |
| **Droit de rectification (Art. 16)** | L'utilisateur peut modifier toutes ses donnees depuis l'edition de profil |
| **Droit a l'effacement (Art. 17)** | Suppression de compte avec cascade complete, delai max 30 jours |
| **Droit a la portabilite (Art. 20)** | Export des donnees personnelles au format JSON depuis les parametres |
| **Consentement eclaire** | Information claire sur l'utilisation des donnees video avant tout enregistrement |

#### Donnees biometriques (video = image faciale)

| Parametre | Valeur |
|-----------|--------|
| **Classification** | La video contient l'image du visage — donnee biometrique potentielle au sens du RGPD Art. 9 |
| **Traitement automatise** | Aucun traitement biometrique automatise (pas de reconnaissance faciale, pas d'analyse IA du visage) |
| **Base legale** | Consentement explicite de l'utilisateur avant chaque enregistrement video |
| **Information** | Mention claire : "Votre video sera visible par les recruteurs verifies sur la plateforme" |
| **Suppression** | Video supprimable a tout moment par l'utilisateur |

#### Droit du Travail francais

| Parametre | Valeur |
|-----------|--------|
| **Art. L1132-1 Code du Travail** | Interdiction de discrimination a l'embauche. La plateforme ne collecte PAS : sexe, origine, situation familiale, grossesse, religion, opinions politiques, handicap |
| **Risque video** | La video revele des caracteristiques physiques — avertissement explicite aux recruteurs : "Toute decision basee sur des criteres discriminatoires est interdite par la loi" |
| **Mentions recruteurs** | A l'inscription recruteur, information sur les obligations legales en matiere de non-discrimination |
| **Moderation** | Signalement possible si un recruteur fait des remarques discriminatoires dans les messages |

### NF4 - Support Utilisateur

| Parametre | Valeur |
|-----------|--------|
| **Canal principal** | FAQ / Centre d'aide in-app (mobile) et in-SaaS (web) |
| **Support humain** | Email uniquement (MVP) |
| **Temps de reponse cible** | 48h ouvrees |

---

## User Stories — App Mobile (Chercheur)

### Epic 1 : Onboarding, Inscription et Profil Chercheur

**US-1.0 : Splash screen mascotte**
> En tant que chercheur, je vois une animation de la mascotte Etoile pendant le chargement de l'app.

Criteres d'acceptation :
- [ ] Animation de la mascotte affichee pendant le chargement
- [ ] Disparait automatiquement quand l'app est prete
- [ ] Duree max : 3 secondes
- [ ] Transition fluide vers l'ecran suivant

**US-1.1 : Ecran d'accueil mascotte**
> En tant que nouveau chercheur, je vois la mascotte avec les options "Se connecter" ou "Creer un compte".

Criteres d'acceptation :
- [ ] Image de la mascotte Etoile bien visible
- [ ] Bouton "Se connecter" → page de connexion
- [ ] Bouton "Creer un compte" → formulaire inscription chercheur
- [ ] Design engageant, identite Etoile

**US-1.2 : Connexion (utilisateur existant)**
> En tant que chercheur existant, je veux me connecter avec mon email et mot de passe.

Criteres d'acceptation :
- [ ] Formulaire : email, mot de passe
- [ ] Lien "Mot de passe oublie"
- [ ] Redirection vers le feed apres connexion reussie
- [ ] Message d'erreur clair si identifiants incorrects

**US-1.3 : Inscription Chercheur**
> En tant que chercheur, je cree mon compte avec un formulaire court.

Criteres d'acceptation :
- [ ] Formulaire : prenom, nom, email
- [ ] Envoi OTP par email → saisie du code 6 chiffres pour valider l'adresse
- [ ] Creation d'un mot de passe (8 caracteres min)
- [ ] Checkbox CGU + politique de donnees (obligatoire)
- [ ] Apres validation → redirection vers le profil a completer (20% — categorie Inscription validee)

**US-1.4 : Systeme de completude profil Chercheur**
> En tant que chercheur, je vois ma progression de profil et sais quoi completer pour atteindre 100%.

5 categories (20% chacune) :
1. **Inscription** (20%) : email verifie + OTP + mot de passe
2. **Identite** (20%) : prenom, nom, age
3. **Etudes** (20%) : ecole, niveau d'etudes
4. **Localisation** (20%) : ville (autocomplete IdF)
5. **Domaine** (20%) : secteur d'activite + specialite

Criteres d'acceptation :
- [ ] Barre de progression visible sur la page profil (0% → 100%)
- [ ] 5 categories de validation, chacune valant 20%
- [ ] Indicateur visuel pour chaque categorie (completee / a faire)
- [ ] Sous 100% : consultation du feed autorisee, publication et postulation bloquees
- [ ] Si action bloquee → redirection vers profil + message explicatif
- [ ] Message mascotte aux paliers (40%, 60%, 80%, 100%)

**US-1.5 : Photo de profil Chercheur**
> En tant que chercheur, je veux ajouter une photo de profil.

Criteres d'acceptation :
- [ ] Picker image depuis galerie
- [ ] Crop circulaire
- [ ] Upload vers Supabase Storage (bucket `seeker-photos`)
- [ ] Preview instantanee apres selection
- [ ] Fait partie de la completude profil

**US-1.6 : Username Chercheur (@pseudo)**
> En tant que chercheur, je veux choisir un username unique pour etre trouvable directement par les recruteurs.

Criteres d'acceptation :
- [ ] Champ username dans le formulaire de profil
- [ ] Format : @lowercase-alphanum (3-20 caracteres)
- [ ] Verification unicite en temps reel (debounce 500ms)
- [ ] Contrainte UNIQUE en base de donnees
- [ ] Affiche sur le profil public et dans le SaaS recruteur
- [ ] Modifiable (avec verification unicite du nouveau)
- [ ] Le username peut etre communique verbalement (ex: en entretien) ou imprime (CV, carte)

**US-1.7 : Mot de passe oublie**
> En tant que chercheur, je veux reinitialiser mon mot de passe si je l'ai oublie.

Criteres d'acceptation :
- [ ] Saisie de l'email
- [ ] Envoi d'un lien de reinitialisation
- [ ] Nouveau mot de passe (8 caracteres min)
- [ ] Confirmation de changement

**US-1.8 : Supprimer mon compte**
> En tant que chercheur, je veux pouvoir supprimer definitivement mon compte et toutes mes donnees (RGPD Art. 17).

Criteres d'acceptation :
- [ ] Option "Supprimer mon compte" accessible depuis les parametres
- [ ] Confirmation requise avec saisie du mot de passe
- [ ] Message d'avertissement clair : "Cette action est irreversible."
- [ ] Suppression effective sous 30 jours (RGPD)
- [ ] Suppression cascade : profil, videos, messages, candidatures, alertes
- [ ] Donnees anonymisees dans les conversations existantes (auteur = "Utilisateur supprime")
- [ ] Possibilite de se reinscrire avec le meme email apres suppression

**US-1.9 : Signaler un contenu ou un utilisateur**
> En tant que chercheur, je veux pouvoir signaler un contenu inapproprie ou un utilisateur.

Criteres d'acceptation :
- [ ] Bouton "Signaler" accessible sur chaque video/affiche dans le feed
- [ ] Bouton "Signaler" accessible dans les conversations
- [ ] Choix du motif : contenu inapproprie, spam, harcelement, discrimination, faux profil, autre
- [ ] Confirmation : "Votre signalement a ete envoye. Merci."
- [ ] Signalement enregistre en BDD pour traitement par l'admin
- [ ] Pas de notification a l'utilisateur signale

---

### Epic 2 : Video Chercheur

**US-2.1 : Tuto mascotte premiere publication**
> En tant que chercheur publiant pour la premiere fois, la mascotte me propose un tutoriel.

Criteres d'acceptation :
- [ ] Detection de la premiere publication (jamais publie avant)
- [ ] Affichage overlay avec la mascotte + conseils pour bien filmer
- [ ] Bouton "Skip" visible pour passer le tuto
- [ ] Ne s'affiche qu'une seule fois (flag SharedPreferences)
- [ ] Apres le tuto (ou skip), acces direct a l'enregistrement

**US-2.2 : Enregistrer ma video de presentation**
> En tant que chercheur, je veux enregistrer une video de 40 secondes pour me presenter aux recruteurs.

Criteres d'acceptation :
- [ ] Acces camera frontale
- [ ] Enregistrement guide en 3 phases (10s preparation, 20s competences, 10s conclusion)
- [ ] Chronometre visible (decompte 40s)
- [ ] Arret automatique a 40s
- [ ] Previsualisation avant validation
- [ ] Option "Recommencer" illimitee
- [ ] Pas d'import externe (enregistrement in-app uniquement = authenticite)
- [ ] Profil a 100% requis pour publier
- [ ] Upload vers Cloudflare R2 via Worker

**US-2.3 : Publier ma video dans un secteur**
> En tant que chercheur, je veux associer ma video a un secteur pour etre trouve.

Criteres d'acceptation :
- [ ] Choix d'un secteur parmi la liste (commerce_vente, restauration_hotellerie)
- [ ] Choix d'une specialite (sous-secteur)
- [ ] Video visible dans le feed offres et dans le SaaS recruteur apres upload
- [ ] Thumbnail generee automatiquement

**US-2.4 : Modifier/Supprimer ma video**
> En tant que chercheur, je veux pouvoir remplacer ou supprimer ma video.

Criteres d'acceptation :
- [ ] Bouton "Remplacer" = nouvel enregistrement
- [ ] Bouton "Supprimer" avec confirmation
- [ ] Suppression effective sous 24h (RGPD)

---

### Epic 3 : Feed & Decouverte Offres (Chercheur)

**US-3.1 : Parcourir les offres (Chercheur)**
> En tant que chercheur, je veux parcourir les offres des recruteurs.

Criteres d'acceptation :
- [ ] Feed vertical scrollable (style TikTok)
- [ ] Videos + affiches melangees
- [ ] Lecture automatique avec son desactive par defaut
- [ ] Tap pour activer/desactiver le son
- [ ] Badge "Entreprise verifiee" visible
- [ ] Informations : nom entreprise, titre poste, localisation, type de contrat
- [ ] Acces au profil entreprise en tapant sur le nom
- [ ] Etat vide : mascotte + "Pas encore d'offres ici. Revenez bientot !"

**US-3.2 : Filtrer les offres (Chercheur)**
> En tant que chercheur, je veux filtrer les offres par criteres.

Criteres d'acceptation :
- [ ] Filtre par secteur (commerce_vente, restauration_hotellerie)
- [ ] Filtre par specialite
- [ ] Filtre par ville IdF
- [ ] Filtres cumulables
- [ ] Bouton "Reinitialiser filtres"

**US-3.3 : Postuler a une offre (Chercheur)**
> En tant que chercheur, je veux postuler a une offre depuis le feed.

Criteres d'acceptation :
- [ ] Bouton "Postuler" visible sur chaque offre
- [ ] Profil 100% requis pour postuler (sinon redirection profil)
- [ ] Candidature en 1 clic (animation de succes "Candidature envoyee !")
- [ ] Profil + video du chercheur enregistres dans le SaaS du recruteur
- [ ] 1 seule candidature par offre (bouton grise si deja postule)

**US-3.4 : Page de recherche**
> En tant que chercheur, je veux chercher des offres par criteres depuis une page dediee.

Criteres d'acceptation :
- [ ] Page landing avec secteur dropdown + badge IdF + mascotte
- [ ] Bouton "Rechercher" → feed filtre
- [ ] Bouton "Parcourir tout le feed"

---

### Epic 4 : Candidatures Chercheur

**US-4.1 : Mes candidatures**
> En tant que chercheur, je veux voir l'etat de mes candidatures.

Criteres d'acceptation :
- [ ] Page "Mes candidatures" accessible depuis le profil
- [ ] Liste : titre offre, nom entreprise, type contrat, statut, date
- [ ] Statuts : "En attente" (orange), "Contacte" (vert), "Retire" (gris)
- [ ] Bouton "Retirer" avec confirmation (statut pending uniquement)
- [ ] Pull-to-refresh + etat vide mascotte

---

### Epic 5 : Messagerie Chercheur

**US-5.1 : Conversations 1-to-1**
> En tant que chercheur, je veux envoyer et recevoir des messages texte avec les recruteurs.

Criteres d'acceptation :
- [ ] Liste des conversations actives
- [ ] Badge "Non lu" sur les nouveaux messages
- [ ] Etat vide : "Aucun message. Commencez par postuler a une offre !"
- [ ] Reponse en texte libre, temps reel (Supabase Realtime)
- [ ] Info du recruteur visible (nom entreprise, poste)
- [ ] Push notifications pour les nouveaux messages
- [ ] Badge offre dans la conversation

**US-5.2 : Bloquer un utilisateur**
> En tant que chercheur, je veux pouvoir bloquer un recruteur indesirable.

Criteres d'acceptation :
- [ ] Option "Bloquer" dans la conversation
- [ ] Confirmation requise
- [ ] Plus de messages possibles apres blocage
- [ ] Contenu de l'utilisateur bloque invisible dans le feed
- [ ] Page "Utilisateurs bloques" dans les parametres

---

### Epic 6 : Alertes Filtrees (Chercheur)

**US-6.1 : Creer une alerte filtree**
> En tant que chercheur, je veux creer une alerte pour etre notifie des nouvelles offres correspondant a mes criteres.

Criteres d'acceptation :
- [ ] Accessible depuis le profil ou les parametres
- [ ] Filtres configurables : secteur, specialite, ville IdF
- [ ] Choix de la frequence : quotidien, tous les 2 jours, hebdomadaire
- [ ] Nombre d'alertes illimite
- [ ] Possibilite de nommer chaque alerte (ex: "Alternance Commerce Paris")
- [ ] Profil 100% requis pour creer une alerte

**US-6.2 : Recevoir les notifications d'alerte**
> En tant que chercheur, je veux recevoir une push notification quand de nouvelles offres correspondent a mes alertes.

Criteres d'acceptation :
- [ ] Push notification a la frequence choisie
- [ ] Message : "Il y a X nouvelles offres qui s'offrent a vous"
- [ ] Tap sur la notification → ouvre le feed filtre avec les offres correspondantes
- [ ] Pas de notification si 0 nouvelles offres sur la periode

**US-6.3 : Gerer mes alertes**
> En tant que chercheur, je veux modifier ou supprimer mes alertes.

Criteres d'acceptation :
- [ ] Liste de mes alertes actives
- [ ] Modifier les filtres ou la frequence
- [ ] Activer/desactiver une alerte (sans la supprimer)
- [ ] Supprimer une alerte definitivement

---

### Epic 7 : Support & Parametres (App Mobile)

**US-7.1 : FAQ in-app**
> En tant que chercheur, je veux acceder a une FAQ pour resoudre mes problemes courants.

Criteres d'acceptation :
- [ ] Section "Aide" accessible depuis le menu parametres
- [ ] Questions organisees par theme
- [ ] Recherche dans la FAQ
- [ ] Lien vers formulaire de contact si non resolu

**US-7.2 : Contacter le support**
> En tant que chercheur, je veux contacter le support si la FAQ ne suffit pas.

Criteres d'acceptation :
- [ ] Formulaire : sujet, description
- [ ] Email de confirmation d'envoi
- [ ] Reponse sous 48h ouvrees

**US-7.3 : Mentions legales**
> En tant que chercheur, je veux acceder aux CGU et politique de confidentialite.

Criteres d'acceptation :
- [ ] Pages CGU, Politique de confidentialite, Mentions legales
- [ ] Accessibles depuis les parametres

---

## User Stories — SaaS Web (Recruteur)

### Epic 10 : Auth & Profil Recruteur (SaaS)

**US-10.1 : Page d'accueil SaaS**
> En tant que visiteur, je vois une page de presentation du service Etoile Recruteurs.

Criteres d'acceptation :
- [ ] Presentation du service : pre-selection video, complement au CV
- [ ] Boutons "Se connecter" et "Creer un compte"
- [ ] Design desktop-first, responsive

**US-10.2 : Inscription Recruteur**
> En tant que recruteur, je cree mon compte professionnel.

Criteres d'acceptation :
- [ ] Formulaire : nom entreprise, email professionnel, SIRET (14 chiffres)
- [ ] Verification SIRET via API Sirene (validation automatique)
- [ ] Envoi OTP email → saisie du code 6 chiffres
- [ ] Creation mot de passe (8 caracteres min)
- [ ] Checkbox CGU + mention non-discrimination (Code du Travail Art. L1132-1)
- [ ] Apres validation → compte en attente de verification admin

**US-10.3 : Connexion Recruteur**
> En tant que recruteur existant, je me connecte au SaaS.

Criteres d'acceptation :
- [ ] Formulaire email + mot de passe
- [ ] Lien "Mot de passe oublie"
- [ ] Redirection vers le dashboard apres connexion
- [ ] Meme compte que s'il avait utilise l'ancienne app mobile

**US-10.4 : Completude profil Recruteur**
> En tant que recruteur, je complete mon profil pour atteindre 100%.

5 categories (20% chacune) :
1. **Inscription** (20%) : email verifie + OTP + mot de passe
2. **Entreprise + secteur** (20%) : nom entreprise, secteur d'activite
3. **Description** (20%) : description entreprise (>50 caracteres)
4. **Localisation** (20%) : ville IdF
5. **SIRET + document** (20%) : SIRET verifie + document justificatif uploade

Criteres d'acceptation :
- [ ] Barre de progression visible
- [ ] Sous 100% : consultation grille autorisee, publication et messagerie bloquees
- [ ] SIRET invalide → message explicatif

**US-10.5 : Upload document justificatif**
> En tant que recruteur, je veux uploader un document prouvant mon identite professionnelle.

Criteres d'acceptation :
- [ ] Choix type document (Kbis, carte pro, etc.)
- [ ] Upload image (Supabase Storage bucket `verification-docs`)
- [ ] 4 etats : pas de document / en attente / verifie / rejete (motif + re-upload)

---

### Epic 11 : Publication Offres (SaaS)

**US-11.1 : Publier une offre video**
> En tant que recruteur, je veux publier une video de presentation de mon offre d'emploi depuis le SaaS.

Criteres d'acceptation :
- [ ] Import video depuis l'ordinateur (drag & drop ou file picker)
- [ ] Duree max : 40 secondes
- [ ] Ajout titre du poste + secteur + type de contrat (Alternance/Stage/CDD/CDI)
- [ ] Compte gratuit : 1 video max active
- [ ] Compte premium : 2 videos/semaine
- [ ] Profil a 100% + SIRET verifie requis

**US-11.2 : Publier une affiche**
> En tant que recruteur, je veux publier une affiche (image) pour une offre.

Criteres d'acceptation :
- [ ] Upload image (JPG, PNG, drag & drop)
- [ ] Format recommande affiche (9:16)
- [ ] Ajout titre du poste + secteur + type de contrat
- [ ] Compte gratuit : 1 affiche max active
- [ ] Compte premium : 2 affiches/semaine

**US-11.3 : Gerer mes publications**
> En tant que recruteur, je veux voir et gerer toutes mes publications actives.

Criteres d'acceptation :
- [ ] Liste de mes videos et affiches avec statut (active, expiree, supprimee)
- [ ] Actions : modifier titre/secteur, supprimer
- [ ] Compteur de candidatures par offre
- [ ] Lien vers le dossier de candidatures

---

### Epic 12 : Grille & Modal Candidats (SaaS)

**US-12.1 : Grille miniatures candidats**
> En tant que recruteur, je veux voir les candidats sous forme de grille de miniatures video.

Criteres d'acceptation :
- [ ] Grille 4-6 miniatures par ecran (responsive)
- [ ] Chaque carte : thumbnail video, prenom, specialite, ville, badge score matching
- [ ] Sidebar gauche (20%) : liste offres + compteurs, filtres, recherche username
- [ ] Zone principale (80%) : grille miniatures
- [ ] Tri par score de matching (descendant par defaut)

**US-12.2 : Hover preview video**
> En tant que recruteur, je veux pre-visualiser une video candidat au survol.

Criteres d'acceptation :
- [ ] Survol d'une carte → video joue automatiquement (mute par defaut)
- [ ] Unmute au clic
- [ ] Pre-filtre visuel en 3-5 secondes
- [ ] Smooth transition (pas de saccade)

**US-12.3 : Actions rapides en grille (sans ouvrir le modal)**
> En tant que recruteur, je veux prendre des decisions rapides sans ouvrir chaque profil.

Criteres d'acceptation :
- [ ] Au hover, 3 micro-boutons en overlay : shortlist (vert), passer (rouge), annoter (bleu)
- [ ] Decision en 2 secondes pour les candidats evidents
- [ ] Feedback visuel (carte grisee si passee, bordure verte si shortlistee)

**US-12.4 : Modal candidat**
> En tant que recruteur, je veux voir le detail d'un candidat dans un modal plein ecran.

Criteres d'acceptation :
- [ ] Clic sur carte → modal plein ecran (pas nouvelle page)
- [ ] Video a gauche (60%), panneau decision a droite (40%)
- [ ] 3 onglets dans le panneau : Profil / Evaluer / Contacter
- [ ] Onglet Profil : prenom, age, ecole, niveau, ville, domaine, specialite, username
- [ ] Onglet Evaluer : boutons Shortlist/Passer + notes texte
- [ ] Onglet Contacter : ouvrir conversation + historique messages
- [ ] Fermer modal = retour a la grille exactement ou on etait

**US-12.5 : Raccourcis clavier**
> En tant que recruteur power user, je veux utiliser des raccourcis clavier pour traiter les candidatures rapidement.

Criteres d'acceptation :
- [ ] Espace = pause/play video
- [ ] Fleche droite = candidat suivant
- [ ] Fleche gauche = candidat precedent
- [ ] R = replay video
- [ ] S = shortlist
- [ ] X = passer
- [ ] Echap = fermer modal

**US-12.6 : Filtres rapides empilables**
> En tant que recruteur, je veux filtrer les candidats avec des chips cliquables.

Criteres d'acceptation :
- [ ] Chips de filtres : par score (>80%, >60%), par specialite, par ville, par niveau etudes
- [ ] Filtres empilables (cumulatifs)
- [ ] Feed/grille se met a jour en temps reel
- [ ] Bouton "Reinitialiser"

**US-12.7 : Sidebar contextuelle par offre**
> En tant que recruteur, je veux selectionner une offre dans la sidebar pour voir ses candidats.

Criteres d'acceptation :
- [ ] Sidebar liste les offres actives avec compteurs de candidatures
- [ ] Clic sur une offre → grille se filtre sur les candidats qui ont postule
- [ ] Compteurs mis a jour en temps reel
- [ ] Option "Tous les candidats" pour voir la base complete

---

### Epic 13 : Dashboard Recruteur (SaaS)

**US-13.1 : Page Accueil / Briefing**
> En tant que recruteur, je veux voir un resume de mon activite a chaque connexion.

Criteres d'acceptation :
- [ ] Nouvelles candidatures depuis la derniere connexion (nombre + liste)
- [ ] Messages non lus
- [ ] Offres expirant bientot
- [ ] "Candidats a traiter" (non evalues depuis X jours)

**US-13.2 : Funnel de recrutement par offre**
> En tant que recruteur, je veux voir le pipeline de chaque offre.

Criteres d'acceptation :
- [ ] Funnel visuel : Candidatures → Shortlist → Contactes → Embauches
- [ ] Chiffres et pourcentages a chaque etape
- [ ] Selectionnable par offre

**US-13.3 : KPIs recruteur**
> En tant que recruteur, je veux voir mes indicateurs de performance.

Criteres d'acceptation :
- [ ] Nombre total de candidatures recues
- [ ] Temps moyen de reponse aux candidats
- [ ] Taux de shortlist
- [ ] Nombre de contacts inities
- [ ] Comparaison entre offres (quelle offre attire le plus)

---

### Epic 14 : Scoring & Matching (SaaS)

**US-14.1 : Score de matching automatique**
> En tant que recruteur, je veux voir un score de compatibilite sur chaque candidat.

Criteres d'acceptation :
- [ ] Badge pourcentage sur chaque miniature (ex: "87%")
- [ ] Calcul : secteur (30%) + ville IdF (25%) + niveau etudes (25%) + specialite (20%)
- [ ] Edge Function Supabase pour le calcul (< 500ms)
- [ ] Pre-calcul possible dans table `match_scores`
- [ ] Score affiche dans la grille ET dans le modal

**US-14.2 : Recherche par username**
> En tant que recruteur, je veux rechercher un chercheur par son @username.

Criteres d'acceptation :
- [ ] Barre de recherche dans la sidebar (@pseudo)
- [ ] Recherche instantanee (debounce 300ms)
- [ ] Resultat : fiche candidat complete (profil + video)
- [ ] Cas ou le username n'existe pas : message clair

---

### Epic 15 : Messagerie Recruteur (SaaS)

**US-15.1 : Conversations synchronisees**
> En tant que recruteur, je veux envoyer et recevoir des messages avec les chercheurs depuis le SaaS.

Criteres d'acceptation :
- [ ] Liste des conversations actives
- [ ] Badge "Non lu" sur les nouveaux messages
- [ ] Reponse en texte libre, temps reel (Supabase Realtime)
- [ ] Messages synchronises avec l'app mobile du chercheur (meme tables, meme channels)
- [ ] Info du chercheur visible (prenom, username, specialite)

**US-15.2 : Contacter depuis le modal**
> En tant que recruteur, je veux contacter un candidat directement depuis sa fiche.

Criteres d'acceptation :
- [ ] Onglet "Contacter" dans le modal candidat
- [ ] Si conversation existante : afficher historique
- [ ] Si nouvelle conversation : champ de premier message
- [ ] Le candidat recoit une push notification sur son mobile
- [ ] Le statut de la candidature passe a "Contacte"

---

### Epic 16 : Paiements Recruteur (SaaS)

**US-16.1 : Souscrire a Premium Recruteur**
> En tant que recruteur, je veux souscrire a l'offre Premium pour plus de fonctionnalites.

Criteres d'acceptation :
- [ ] Page detaillant les avantages Premium
- [ ] Prix affiche : 499€/mois
- [ ] Paiement par carte via Stripe Checkout (web direct)
- [ ] Possibilite de facture entreprise
- [ ] Activation immediate apres paiement
- [ ] Recu par email

**US-16.2 : Acheter a l'unite**
> En tant que recruteur, je veux acheter des publications supplementaires a l'unite.

Criteres d'acceptation :
- [ ] +1 video : 99€
- [ ] +1 affiche : 49€
- [ ] Paiement Stripe direct
- [ ] Credit ajoute immediatement au compte

**US-16.3 : Gerer mon abonnement**
> En tant que recruteur premium, je veux gerer mon abonnement.

Criteres d'acceptation :
- [ ] Voir date de renouvellement
- [ ] Voir historique des paiements
- [ ] Annuler l'abonnement (effet a la fin de la periode)
- [ ] Modifier moyen de paiement (Stripe Customer Portal)

---

### Epic 17 : Administration

**US-17.1 : Valider les recruteurs (SIRET)**
> En tant qu'admin, je veux valider manuellement les inscriptions recruteurs.

Criteres d'acceptation :
- [ ] Liste des recruteurs en attente de verification
- [ ] Visualisation SIRET + infos entreprise + document justificatif
- [ ] Actions : Approuver / Rejeter (avec motif)
- [ ] Email automatique au recruteur (validation ou refus)
- [ ] Recruteur refuse → profil bloque

**US-17.2 : Moderer les contenus**
> En tant qu'admin, je veux pouvoir gerer les signalements.

Criteres d'acceptation :
- [ ] Liste des signalements utilisateurs
- [ ] Visualisation du contenu signale
- [ ] Actions : Ignorer / Supprimer video / Suspendre utilisateur
- [ ] Audit logging de chaque action admin

**US-17.3 : Statistiques globales**
> En tant qu'admin, je veux voir les metriques cles de la plateforme.

Criteres d'acceptation :
- [ ] Nombre d'utilisateurs (total, par role, taux completude 100%)
- [ ] Nombre de videos/affiches publiees
- [ ] Nombre de candidatures
- [ ] Nombre d'alertes filtrees actives
- [ ] Revenus (abonnements + achats)

> **Note** : L'admin panel existe dans l'app Flutter (Sprint 14/21). Il peut etre migre vers le SaaS ou reste dans l'app mobile. A decider en fonction de l'usage.

---

## Risques et Dependances

### Risques Identifies

| ID | Risque | Probabilite | Impact | Mitigation |
|----|--------|-------------|--------|------------|
| R1 | **Rejet App Store** (contenu video UGC, moderation) | Moyenne | Haute | Review guidelines avant soumission, moderation reactive, bouton signaler |
| R2 | **Fraude recruteurs** (faux SIRET, arnaques) | Haute | Haute | Verification SIRET API Sirene + verification humaine admin |
| R3 | **Contenus inappropries** (videos offensantes) | Moyenne | Haute | Moderation reactive, signalement, suspension auto |
| R4 | **Faible adoption initiale** (poule et l'oeuf) | Haute | Haute | Strategie d'acquisition ciblee, contenu seed |
| R5 | **Couts Cloudflare R2 sous-estimes** | Basse | Moyenne | Monitoring consommation, compression video |
| R6 | **Abandon onboarding** (completude 100%) | Moyenne | Haute | Messages mascotte, UX progressive, rappels push |
| R7 | **Adoption SaaS recruteurs** (habitudes ATS existants) | Moyenne | Haute | UX superieure (grille video vs listes texte), onboarding guide, support proactif |
| R8 | **RGPD — Demandes de suppression** | Certaine | Basse | Processus automatise, Edge Function delete-account |
| R9 | **Synchronisation app/SaaS** (messages, candidatures) | Basse | Moyenne | Supabase Realtime partage, memes tables |

### Dependances Externes

| ID | Dependance | Type | Criticite | Contact/Lien |
|----|------------|------|-----------|--------------|
| D1 | **Cloudflare R2** | Infrastructure video | Critique | cloudflare.com |
| D2 | **Stripe** | Paiements recruteurs (web) | Critique | stripe.com |
| D3 | **Apple App Store** | Distribution app chercheur iOS | Haute | App Store Connect |
| D4 | **Google Play Store** | Distribution app chercheur Android | Haute | Google Play Console |
| D5 | **Service email transactionnel** | Notifications + OTP | Haute | Supabase (integre) |
| D6 | **Vercel** | Hebergement SaaS web | Haute | vercel.com |
| D7 | **API Sirene** | Verification SIRET | Moyenne | recherche-entreprises.api.gouv.fr |
| D8 | **Domaine custom** | app.etoile-recrutement.fr | Basse | Registrar |

### Dependances Internes

| ID | Dependance | Equipe/Ressource | Criticite | Statut |
|----|------------|------------------|-----------|--------|
| DI1 | **Design mascotte** | Illustrateur | Haute | A identifier |
| DI2 | **Redaction CGU** | Juridique | Haute | A faire avant lancement |
| DI3 | **Moderateur contenu** | Operations | Moyenne | Manuel par fondateur au MVP |
| DI4 | **Design SaaS** | UX/UI | Haute | Shadcn/ui + custom |

---

## Exigences Mobile (App Chercheur)

### Permissions device

| Permission | Usage | Demande |
|------------|-------|---------|
| **Camera** | Enregistrement video 40s | Au moment de l'enregistrement |
| **Microphone** | Audio de la video | Combinee avec la demande camera |
| **Galerie photos** | Upload photo profil | Au moment de l'upload |
| **Notifications push** | Messages, alertes filtrees | A l'inscription |
| **Localisation** | Carte, filtres geographiques | Optionnelle |

### Mode offline

| Situation | Comportement |
|-----------|-------------|
| **Perte de connexion pendant navigation** | Message "Pas de connexion", videos chargees restent lisibles |
| **Perte de connexion pendant envoi message** | Message en file d'attente, envoi auto au retour |
| **Perte de connexion pendant upload video** | Upload annule, reprise manuelle |
| **Perte de connexion generale** | Banniere persistante, donnees en cache affichees |

### Accessibilite (a11y)

| Critere | Implementation |
|---------|----------------|
| **Contraste** | Ratio minimum 4.5:1 (WCAG AA) pour le texte |
| **Taille du texte** | Support du scaling systeme (Dynamic Type iOS / Font Scale Android) |
| **Screen readers** | Labels semantiques sur tous les boutons et elements interactifs |
| **Navigation** | Ordre logique de focus pour le clavier / switch access |

---

## Terminologie unifiee

| Terme officiel | Alternatives a eviter |
|---------------|----------------------|
| **Chercheur** (ou "Chercheur d'alternance") | Demandeur, candidat, seeker |
| **Recruteur** | Employeur, entreprise (sauf dans "nom de l'entreprise") |
| **Postuler** | Candidater, appliquer |
| **Publication** | Offre (sauf "offre d'emploi" en contexte), post |
| **Shortlister** | Mettre en favori, liker |
| **Username** | Pseudo, identifiant, handle |

> **Note** : Les specifications techniques (architecture, schema de donnees, stack, securite) sont dans les documents separes `architecture-etoile-draft.md` et `saas-etoile/`.

---

## Timeline MVP

### Vue d'ensemble — Deux Tracks Paralleles

| Track | Phase | Duree | Objectif |
|-------|-------|-------|----------|
| **App Mobile** | Finition | 1-2 semaines | Nettoyer code recruteur, ajouter username, tester camera, deployer migration |
| **App Mobile** | Store | 1 semaine | Screenshots, description, soumission TestFlight + Play Console |
| **SaaS Web** | Setup | 1 semaine | Init Next.js + Supabase + Vercel + Auth recruteur |
| **SaaS Web** | Migrations DB | 2-3 jours | Tables evaluations, tags, match_scores, username |
| **SaaS Web** | Pages Core | 2-3 semaines | Login, briefing, grille, modal, dashboard, messages, recherche |
| **SaaS Web** | Integration & Tests | 1 semaine | E2E Playwright, realtime sync, RLS |
| **SaaS Web** | Beta Recruteurs | 1 semaine | 5-10 recruteurs beta, feedback, ajustements |

**Duree totale estimee : 6-8 semaines (les deux tracks en parallele)**

### V2 (Post-lancement)

- QR code profil chercheur
- Vue Kanban drag & drop
- Comparaison cote a cote candidats
- Heatmap temporelle candidatures
- Rapports PDF exportables
- Toggle grille/feed
- Roles et permissions multi-utilisateurs (equipe RH)
- Score recommandation proactive
- Timestamp bookmarks sur video
- Navigation inter-candidats clavier dans le modal
- SSO entreprise (SAML/OIDC)
- Profil public SSR /profile/@username (SEO)
- Premium chercheur (stats, visibilite boostee)

---

## Nouvelles Tables DB (SaaS)

> ~5 nouvelles tables. Toutes les tables existantes (users, seeker_profiles, recruiter_profiles, videos, conversations, messages, applications, etc.) sont reutilisees telles quelles.

| Table | Description |
|-------|-------------|
| `candidate_evaluations` | Evaluations recruteur sur candidats (shortlist, passer, notes) |
| `candidate_tags` | Tags personnalisables par recruteur |
| `evaluation_tags` | Relation N-N evaluations ↔ tags |
| `team_shares` | Partage de profils entre collegues (V2) |
| `recruiter_activity_log` | Journal d'activite recruteur |
| `match_scores` | Scores de matching pre-calcules (offre ↔ chercheur) |

Colonne a ajouter : `seeker_profiles.username` (VARCHAR UNIQUE, index)

---

## Prochaines Etapes

| Etape | Contenu | Statut |
|-------|---------|--------|
| 1 | Classification du projet | Fait |
| 2 | Clarifications techniques | Fait |
| 3 | Criteres de succes | Fait (mis a jour pivot) |
| 4 | Modele economique | Fait (mis a jour pivot) |
| 5 | User Stories (17 Epics) | Fait (mis a jour pivot) |
| 6 | Risques et Dependances | Fait (mis a jour pivot) |
| 7 | Timeline | Fait (mis a jour pivot) |
| 8 | **Brainstorming SaaS** | Fait (saas-etoile/) |
| 9 | **Architecture SaaS** | A faire |
| 10 | **Sprint planning (deux tracks)** | A faire |

---

*Document edite par John (PM) — Derniere mise a jour : 2026-04-03*
*PIVOT E-4 : Modele deux plateformes — App mobile (Flutter) = chercheurs only + SaaS web (Next.js) = recruteurs only + Backend Supabase partage. Suppression IAP, ajout username/scoring, nouvelles Epics SaaS (10-17).*
