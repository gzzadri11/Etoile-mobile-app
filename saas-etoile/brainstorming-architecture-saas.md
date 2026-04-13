# Brainstorming — Architecture SaaS Etoile Recruteurs

**Date :** 2026-03-30
**Participants :** Developer + BMad Master
**Approche :** Flow Progressif (4 phases)
**Sujet :** Architecture d'un SaaS web pour les recruteurs Etoile

---

## Contexte du Pivot

### Ancien modele
- App mobile unique pour chercheurs ET recruteurs

### Nouveau modele
- **App mobile** = chercheurs d'alternance uniquement (finir + tester)
- **SaaS web** = recruteurs (dashboard, stats, acces videos, pre-selection)
- **Positionnement** = complement au CV, pas un remplacement. Permet la pre-selection et la visibilite des soft skills

### Objectifs du brainstorming
- Definir l'architecture technique du SaaS (stack, infra, APIs)
- Concevoir le dashboard recruteur (stats offres, candidatures, videos)
- Architecturer le lien App Mobile <-> SaaS (videos, profils, conversations)
- Designer le systeme de username recruteur (acces direct profil)

---

## Phase 1 : Exploration Expansive (What If Scenarios)

### Technique : What If Scenarios — Questionner toutes les contraintes

### Idees Generees

**[Feed #1]** : Feed Video Recruteur Augmente
_Concept_ : Le meme feed vertical TikTok-style que l'app chercheur, mais avec une couche d'outils pro en overlay — boutons d'annotation rapide, tags, shortlist, rejet, notes vocales
_Nouveaute_ : Pas un ATS classique avec des listes — le recruteur vit les candidatures en video

**[Dashboard #2]** : Hub RH de Gestion Recrutement
_Concept_ : Dashboard complet pour les RH — pipeline de recrutement, stats par offre, suivi des candidatures, historique des echanges, KPIs
_Nouveaute_ : Le dashboard n'est pas l'experience principale mais le centre de controle — le feed est pour decouvrir, le dashboard pour gerer

**[Search #3]** : Recherche Directe par Username
_Concept_ : Barre de recherche username — le recruteur tape le pseudo du chercheur et tombe directement sur son profil complet + video, ideal en entretien physique
_Nouveaute_ : Supprime la friction "retrouver un candidat dans une liste" — acces instantane comme un @ sur les reseaux sociaux

**[Matching #4]** : Score de Matching Automatique
_Concept_ : Chaque video candidat affichee au recruteur porte un badge de compatibilite (ex: 87%) calcule sur secteur, localisation IdF, niveau d'etudes, specialite
_Nouveaute_ : Pas un filtre binaire oui/non mais un score gradue — le recruteur peut decouvrir des profils "80% match" auxquels il n'aurait jamais pense

**[QR #5]** : QR Code Profil Chercheur
_Concept_ : Chaque chercheur a un QR code unique (genere depuis l'app) qu'il peut imprimer sur son CV, sa carte de visite, ou montrer en entretien — le recruteur scanne -> profil + video en 1 seconde
_Nouveaute_ : Le pont physique-numerique — la video Etoile devient une extension tangible du CV papier

**[Collab #6]** : Partage de Profil Inter-Collegues
_Concept_ : Le recruteur partage un profil chercheur (video + infos + ses annotations) avec ses collegues RH de la meme entreprise
_Nouveaute_ : Decision de recrutement collaborative — le manager technique voit les soft skills en video, le RH voit le matching, le DG valide

**[UX-Feed #7]** : Feed Augmente Desktop — Layout a 3 Zones
_Concept_ : L'ecran desktop divise en 3 zones : video au centre (60%), panneau d'actions/infos a droite (25%), sidebar navigation/filtres a gauche (15%)
_Nouveaute_ : On exploite le grand ecran desktop — le recruteur voit la video ET les infos du candidat en meme temps

**[Nav #8]** : Sidebar Contextuelle par Offre
_Concept_ : La sidebar liste les offres actives du recruteur. Clic sur une offre -> le feed se filtre automatiquement sur les candidats qui ont postule. Compteurs en temps reel
_Nouveaute_ : Le recruteur ne "cherche" jamais — il selectionne une offre et les candidats viennent a lui

**[Filter #9]** : Filtres Rapides Empilables
_Concept_ : Chips de filtres cliquables : par score de matching (>80%, >60%), par specialite, par ville IdF, par niveau d'etudes. Les filtres s'empilent et le feed se met a jour en temps reel
_Nouveaute_ : Filtrage sans formulaire — clic-clic-clic, le feed se raffine instantanement

**[Video #10]** : Overlay Intelligent sur la Video
_Concept_ : Pendant la lecture, overlay semi-transparent en bas : prenom, specialite, ville, score de matching. Disparait apres 3 secondes, hover pour reapparaitre
_Nouveaute_ : Les infos cles sont la des la premiere seconde

**[Video #11]** : Controles Video Pro
_Concept_ : Barre de progression cliquable + raccourcis clavier : Espace = pause, fleche droite = suivant, fleche gauche = precedent, R = replay, S = shortlist, X = passer
_Nouveaute_ : Le power user traite les candidatures au clavier — 5 secondes par decision

**[Video #12]** : Timestamp Bookmarks
_Concept_ : Le recruteur pose un "bookmark" a un moment precis de la video (ex: "bonne reponse a 0:22") avec une note. Bookmarks partageables avec les collegues
_Nouveaute_ : Les collegues sautent direct au moment cle sans revoir les 40 secondes

**[Panel #13]** : Panneau de Decision Rapide
_Concept_ : En haut : gros boutons Shortlist (vert) / Passer (rouge) / Annoter (bleu). Au milieu : fiche resume candidat. En bas : notes + historique annotations
_Nouveaute_ : Tout pour decider visible d'un coup d'oeil

**[Panel #14]** : Tags Personnalisables
_Concept_ : Le recruteur cree ses propres tags (ex: "a recontacter", "bon communicant", "bilingue", "junior prometteur"). Un clic pour taguer, filtrables ensuite
_Nouveaute_ : Chaque equipe RH a son propre vocabulaire — le systeme s'adapte a eux

**[Panel #15]** : Actions Contextuelles Intelligentes
_Concept_ : Le panneau s'adapte au statut du candidat. Nouveau -> "Shortlist / Passer". Shortliste -> "Contacter / Partager / Planifier entretien". Contacte -> "Notes d'entretien / Decision finale"
_Nouveaute_ : Le panneau guide le recruteur dans le pipeline sans menu supplementaire

**[UX-Grille #16]** : Mode Grille Intelligente — Desktop-First
_Concept_ : Grille de 4 a 6 miniatures video par ecran. Chaque carte : thumbnail, prenom, specialite, ville, badge score matching. Vue d'ensemble immediate
_Nouveaute_ : Tri visuel comme un directeur de casting — balaye du regard, repere les interessants, puis plonge

**[UX-Grille #17]** : Hover = Preview Video Instantanee
_Concept_ : Survol d'une carte -> video joue automatiquement (mute par defaut, unmute au clic). Pre-filtre visuel en 3-5 secondes
_Nouveaute_ : Imite YouTube/Netflix — le recruteur "goute" sans cliquer

**[UX-Grille #18]** : Clic = Vue Expansee (Modal, Pas Nouvelle Page)
_Concept_ : Clic sur carte -> modal plein ecran : video a gauche (60%), panneau decision a droite (40%). Fermer = retour a la grille exactement ou on etait
_Nouveaute_ : Zero navigation, zero perte de contexte

**[Layout #19]** : Architecture 2 Zones Desktop
_Concept_ : Sidebar gauche (20%) : offres + filtres + recherche username. Zone principale (80%) : grille miniatures. Clic -> modal overlay avec raccourcis clavier
_Nouveaute_ : Deux niveaux d'interaction — grille pour scanner, modal pour decider

**[Layout #20]** : Actions Rapides en Grille (Sans Ouvrir le Modal)
_Concept_ : Au hover, 3 micro-boutons en overlay : coeur (shortlist), X (passer), tag. Decision en 2 secondes pour les candidats evidents
_Nouveaute_ : Pour les profils evidents (score 95%), pas besoin d'ouvrir le modal

**[Layout #21]** : Vue Hybride — Toggle Grille / Feed
_Concept_ : Bouton toggle grille <-> feed. Memes filtres et sidebar, seule la zone principale change. Grille = tri rapide en masse, feed = evaluation approfondie
_Nouveaute_ : Le recruteur choisit son rythme

---

## Phase 2 : Reconnaissance de Patterns (Analyse Morphologique)

### Matrice Morphologique — 8 Parametres

| Parametre | Option A | Option B | Option C | Choix Optimal |
|-----------|----------|----------|----------|---------------|
| **Navigation** | Hub accueil + sections | Sidebar permanente | Top tabs | **A+B** : Hub accueil + sidebar permanente |
| **Decouverte candidats** | Grille + Modal | Feed vertical | Hybride toggle | **C** : Hybride (grille par defaut) |
| **Evaluation / Decision** | Modal 3 onglets | Actions rapides grille + modal | Panneau lateral persistant | **B** : Actions rapides + modal approfondi |
| **Dashboard** | Funnel + KPIs | Funnel + Intelligence | Full analytics | **B** : Funnel + Intelligence (V2 full analytics) |
| **Communication** | Chat integre modal | Messages separes | Hybride | **C** : Chat modal + section complete |
| **Collaboration** | Partage simple | Espace equipe | Multi-role | **B** : Espace equipe (roles en V2) |
| **Acces profil** | Username seul | Username + QR | Username + QR + lien public | **C** : Username + QR + URL publique |
| **Scoring** | Score simple | Score detaille | Score + recommandation | **B** : Score detaille (recommandations V2) |

### 4 Patterns Emergents

**Pattern 1 : "Le SaaS a Deux Vitesses"**
- Grille = vitesse rapide (scanner, trier, shortlister en masse)
- Modal = vitesse lente (evaluer, annoter, contacter avec reflexion)

**Pattern 2 : "Le SaaS Proactif"**
- Le SaaS montre des actions a faire, pas des donnees
- Morning briefing, alertes, candidats qui stagnent, nouveaux matchs

**Pattern 3 : "Le Pipeline Visible"**
- Tout le processus est visuel et mesurable
- Funnel, Kanban, temps par etape, taux de conversion

**Pattern 4 : "Le Pont Mobile <-> Web"**
- La video du chercheur (app mobile) est l'element central du SaaS
- Username, QR code, profil accessible — les deux mondes communiquent

---

## Phase 3 : Developpement des Idees (First Principles Thinking)

### Verites Fondamentales

**Verite 1 : L'infrastructure existe deja**
- Supabase (Auth, PostgreSQL, Realtime, Edge Functions) -> en prod
- Cloudflare R2 (videos, thumbnails, Worker streaming) -> en prod
- Tables existantes (users, seeker_profiles, recruiter_profiles, videos, conversations, messages) -> en place
- Consequence : le SaaS n'a PAS besoin d'un backend separe

**Verite 2 : La video est accessible par URL**
- Worker `etoile-video-worker` sert les videos via `/stream/:key`
- Un simple `<video src>` suffit cote web
- Consequence : zero infra supplementaire pour les videos

**Verite 3 : Le recruteur est deja un utilisateur Supabase**
- Auth via Supabase (email + OTP), profil dans `recruiter_profiles`
- Conversations et messages dans les tables existantes
- Consequence : meme compte app mobile et SaaS

**Verite 4 : Le positionnement est "complement au CV"**
- La video ne remplace pas le CV, elle le complete
- Pre-selection par soft skills, presentation, motivation
- Consequence : le SaaS ne doit PAS devenir un ATS complet. C'est un outil de pre-selection video avec pilotage leger

### Idees Architecture

**[Archi #39]** : Stack Web — Next.js + Supabase + Tailwind + Shadcn/ui
_Concept_ : Next.js pour SSR (profils publics), Supabase JS client (meme backend), Tailwind + Shadcn/ui (UI rapide), Recharts (graphiques), deploiement Vercel
_Nouveaute_ : Zero backend a construire — le SaaS parle directement a Supabase comme l'app Flutter

**[Archi #40]** : Alternative — Nuxt.js ou SvelteKit
_Concept_ : Alternatives si preference Vue/Svelte, meme logique d'integration Supabase

**[DB #41]** : Nouvelles Tables (~5 tables)
_Concept_ : `candidate_evaluations`, `candidate_tags`, `evaluation_tags`, `team_shares`, `recruiter_activity_log`. Tables existantes reutilisees telles quelles
_Nouveaute_ : ~5 nouvelles tables seulement, tout le reste existe

**[DB #42]** : Username Chercheur — 1 Colonne
_Concept_ : Colonne `username` (UNIQUE, @lowercase) dans `seeker_profiles`. Choisi dans l'app mobile, recherchable dans le SaaS

**[DB #43]** : Scoring via Edge Function
_Concept_ : Supabase Edge Function calcule le matching : offre (secteur, ville, niveau) + profil chercheur -> pourcentage. Pre-calcul possible dans `match_scores`

**[Archi #44]** : Architecture Partagee App + SaaS
```
App Mobile (Flutter)     SaaS Web (Next.js)
    Chercheur               Recruteur
         \                   /
          \   Supabase SDK  /
           \               /
        Supabase (Auth + DB + Realtime + Edge Functions)
                  |
         Cloudflare R2 + Worker
         (Videos + Thumbnails)
```
_Nouveaute_ : Un seul backend pour deux clients — coherence garantie

**[Archi #45]** : RLS — Separation des Acces
_Concept_ : Politiques RLS existantes + nouvelles RLS sur tables ajoutees, limitees a l'entreprise du recruteur
_Nouveaute_ : Securite dans la base, pas dans le code client

**[Archi #46]** : Realtime pour la Messagerie
_Concept_ : Supabase Realtime deja utilise dans l'app Flutter. Le SaaS souscrit aux memes channels -> messages synchronises en temps reel app <-> SaaS

**[Scope #47]** : Perimetre MVP vs V2
- **MVP** : Auth, page accueil briefing, grille candidats + modal, messagerie, recherche username, dashboard funnel + KPIs
- **V2** : QR code, tags personnalisables, comparaison cote a cote, Kanban, heatmap, rapports PDF, toggle grille/feed, roles multi-utilisateurs, score recommandation, timestamp bookmarks

---

## Phase 4 : Plan d'Action (Decision Tree Mapping)

### Arbres de Decisions

#### Decision 1 : Stack Frontend -> Next.js + Tailwind + Shadcn/ui
- Ecosysteme React massif
- SSR pour profils publics (@username = SEO)
- Supabase SDK JS natif
- Vercel = deploiement zero-config
- Shadcn/ui fournit grille, modals, sidebar, dropdowns, badges

#### Decision 2 : Backend -> Supabase partage (meme projet)
- Zero infra supplementaire
- Meme auth, meme data, meme realtime
- RLS separe deja les acces
- Cout supplementaire : 0 EUR

#### Decision 3 : Auth -> Meme Supabase Auth
- Le recruteur a deja un compte
- OTP email deja configure
- Session JWT identique
- SSO entreprise en V2

#### Decision 4 : Username -> Colonne `seeker_profiles.username`
- 1 migration SQL, contrainte UNIQUE + index
- Le chercheur le choisit dans l'app mobile
- Format @lowercase-alphanum

#### Decision 5 : Scoring -> Edge Function + table `match_scores`
- Logique centralisee, reutilisable app + SaaS
- Criteres : secteur (30%) + ville IdF (25%) + niveau etudes (25%) + specialite (20%)
- Modifiable sans deploiement client

#### Decision 6 : Deploiement -> Vercel
- Deploy automatique depuis GitHub
- Preview par PR
- Gratuit MVP (hobby plan)
- Domaine custom : app.etoile-recrutement.fr

### Tableau des Decisions Finales

| Decision | Choix | Justification |
|----------|-------|---------------|
| **Frontend** | Next.js + Tailwind + Shadcn/ui | Ecosysteme riche, SSR, Vercel |
| **Backend** | Supabase partage (meme projet) | Zero infra, RLS, realtime gratuit |
| **Auth** | Supabase Auth (meme systeme) | Comptes existants, zero migration |
| **Username** | Colonne `seeker_profiles.username` | Simple, 1 migration |
| **Scoring** | Edge Function + `match_scores` | Centralisee, partagee app/SaaS |
| **Deploiement** | Vercel + domaine custom | Gratuit MVP, auto-deploy |
| **Messagerie** | Supabase Realtime (existant) | Sync app <-> SaaS native |

### Cout Supplementaire MVP

| Poste | Cout |
|-------|------|
| Vercel Hobby | 0 EUR |
| Supabase (deja Pro) | 0 EUR supplementaire |
| Domaine custom | ~10 EUR/an |
| **Total** | **~10 EUR/an** |

---

## Roadmap d'Implementation

### Etape 0 : Finir l'App Mobile Chercheur (en cours)
- Deployer migration `seeker_photo_url`
- Ajouter champ username dans le profil chercheur (app mobile)
- Tests beta chercheur -> store listing

### Etape 1 : Setup Projet SaaS (1 semaine)
- Init Next.js + Tailwind + Shadcn/ui
- Configurer Supabase JS client (meme projet)
- Auth recruteur (login email/OTP)
- Deployer sur Vercel (domaine custom)
- CI/CD GitHub -> Vercel

### Etape 2 : Migrations DB (2-3 jours)
- `ALTER TABLE seeker_profiles ADD COLUMN username VARCHAR UNIQUE`
- `CREATE TABLE candidate_evaluations`
- `CREATE TABLE candidate_tags` + `evaluation_tags`
- `CREATE TABLE team_shares`
- `CREATE TABLE recruiter_activity_log`
- Policies RLS sur les nouvelles tables
- Edge Function `calculate-match-score`

### Etape 3 : Pages Core SaaS MVP (2-3 semaines)
1. Page Login — Auth Supabase, redirection post-login
2. Page Accueil / Briefing — Nouvelles candidatures, messages non lus, alertes
3. Page Grille Candidats — Sidebar offres + filtres, grille miniatures, hover preview, score badge
4. Modal Candidat — Video + profil + onglets (Profil / Evaluer / Agir) + messagerie inline
5. Page Dashboard — Funnel par offre + KPIs + comparaison offres
6. Recherche Username — Barre de recherche @username dans la sidebar
7. Page Messages — Historique conversations complet

### Etape 4 : Integration & Tests (1 semaine)
- Tests E2E (Playwright) : login -> grille -> modal -> contact -> dashboard
- Test realtime : message SaaS -> recu dans app mobile
- Test scoring : verification calculs matching
- Test RLS : isolation entre recruteurs

### Etape 5 : Beta Recruteurs (1 semaine)
- Inviter 5-10 recruteurs beta
- Feedback UX grille/modal/dashboard
- Ajustements
- Monitoring Vercel + Supabase

### V2 (Post-lancement)
- QR code profil chercheur
- Vue Kanban drag & drop
- Comparaison cote a cote
- Heatmap temporelle candidatures
- Rapports PDF exportables
- Toggle grille/feed
- Roles et permissions multi-utilisateurs
- Score recommandation proactive
- Timestamp bookmarks sur video
- Navigation inter-candidats clavier dans le modal
- SSO entreprise (SAML/OIDC)
- Profil public SSR /profile/[username]

---

## Bilan de la Session

- **47 idees** generees a travers 4 phases progressives
- **Phase 1** (What If) : 21 idees — exploration UX et fonctionnalites
- **Phase 2** (Morphological) : Matrice 8 parametres x 3 options — combinaison optimale
- **Phase 3** (First Principles) : 9 idees architecture — reconstruction depuis les fondations
- **Phase 4** (Decision Tree) : 6 arbres de decision + roadmap 8 semaines
- **Decisions cles** : Next.js + Supabase partage + Vercel, cout ~10 EUR/an
- **Le SaaS partage 100% du backend existant** — zero infra supplementaire
