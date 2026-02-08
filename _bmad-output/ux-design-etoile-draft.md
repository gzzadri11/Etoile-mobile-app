---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7]
status: complete
lastStep: "Étape 7 - Spécifications d'Écrans Finalisées"
date: 2026-02-01
author: Sally (UX Designer)
projectName: Etoile Mobile App
---

# UX Design Draft: Etoile Mobile App

## Executive Summary UX

Etoile transforme le recrutement en France via une vidéo authentique de 40 secondes. L'expérience utilisateur doit refléter cette mission : interface moderne, chaleureuse et radicalement simple.

---

## Décisions UX Fondamentales

| Aspect | Décision |
|--------|----------|
| **Enregistrement vidéo** | Coaching guidé : 10s présentation → 20s compétences → 10s conclusion |
| **Ré-enregistrement** | Illimité avant publication |
| **Algorithme feed** | Matching (région, métier) + rotation aléatoire pour égalité |
| **Premium chercheur** | Tableau de bord dédié avec stats |
| **Ton de l'app** | Professionnel mais chaleureux |
| **Templates messages** | Disponibles mais optionnels |
| **Mode hors-ligne** | Pas nécessaire pour MVP |
| **Animations** | Subtiles (pas de confettis) |

---

## Décisions Émotionnelles (Étape 4)

Ces décisions reflètent le ton chaleureux du projet :

| Question | Décision | Justification |
|----------|----------|---------------|
| **État vide initial** | C) "Votre vidéo est découverte par les recruteurs" | Encourageant et positif, évite l'angoisse du vide |
| **Stats vues non-premium** | B) "Votre profil a été vu" sans chiffre | Rassure sans frustrer, incite à l'upgrade |
| **Ton messages système** | B) Chaleureux ("Bravo ! Votre vidéo brille...") | Cohérent avec l'identité bienveillante |
| **Ton erreurs** | B) Humain ("Oups, petit souci...") | Dédramatise, garde la confiance |

---

## Les 5 Principes UX d'Etoile

### 1. Authenticité sans Friction
> L'application permet d'être soi-même sans barrière technique.
- Coaching guidé plutôt que instructions complexes
- Pas de montage = pas de pression de perfection
- Ré-enregistrement illimité = liberté d'essayer

### 2. Voir et Agir
> Chaque vidéo vue peut mener à une action immédiate.
- Bouton contact toujours visible
- Zéro étape entre intérêt et message
- Templates pour accélérer sans contraindre

### 3. Chaleur Professionnelle
> Sérieux dans l'intention, bienveillant dans la forme.
- Palette jaune/orange = optimisme
- Ton encourageant dans les messages système
- Animations subtiles et élégantes

### 4. Égalité de Lumière
> Chaque étoile mérite de briller équitablement.
- Une vidéo par catégorie = pas d'effet influenceur
- Rotation aléatoire dans les résultats
- Pas de likes/favoris = pas de hiérarchie sociale

### 5. Confiance par la Transparence
> L'utilisateur sait toujours ce qui se passe.
- Recruteurs vérifiés avec badge visible
- Process de vérification expliqué
- Statistiques accessibles (premium)

---

## Core Experience

### Actions Core

**Chercheur** : Enregistrer et publier sa vidéo de 40 secondes
**Recruteur** : Parcourir le feed et contacter instantanément

### Interactions Effortless

| Interaction | Friction Cible |
|-------------|----------------|
| Démarrer enregistrement | < 3 taps |
| Parcourir feed | 0 apprentissage (style TikTok) |
| Contacter profil | 2 taps |
| Répondre message | < 10 secondes |

### Différence Vidéo Chercheur vs Recruteur

| Utilisateur | Mode vidéo |
|-------------|------------|
| **Chercheur** | Enregistrement via app UNIQUEMENT (authenticité) |
| **Recruteur** | Import autorisé (flexibilité pro) |

---

## Parcours Émotionnel

### Chercheur : De l'Ombre à la Lumière

```
AVANT ETOILE → AVEC ETOILE → APRÈS SUCCÈS
Invisible → Caméra → Publie → Vu → Contacté → Emploi
Désespoir → Stress guidé → Fierté célébrée → Patience sereine → Joie contenue → Gratitude
```

### Recruteur : De la Frustration à l'Efficacité

```
AVANT ETOILE → AVEC ETOILE → APRÈS SUCCÈS
Pile CV → Feed → Découvre → Contacte → Échange → Embauche
Frustration → Surprise positive → Conviction → Satisfaction rapide → Confiance → Fidélité
```

---

## Moments de Succès Critiques

| Moment | Utilisateur | Émotion Cible | Traitement UX |
|--------|-------------|---------------|---------------|
| Première vidéo publiée | Chercheur | Fierté, accomplissement | Animation subtile, message encourageant |
| Premier message reçu | Chercheur | Excitation, validation | Notification spéciale, highlight doux |
| Découverte bon candidat | Recruteur | Satisfaction, urgence d'agir | CTA immédiat, zéro friction |
| Conversation engagée | Les deux | Confiance, progression | Interface claire, facilité RDV |

---

# Design System Etoile

## Couleurs

### Palette Principale

| Nom | Hex | Usage |
|-----|-----|-------|
| **Jaune Etoile** | `#FFB800` | CTA principal, accents, highlights |
| **Orange Etoile** | `#FF8C00` | CTA secondaire, dégradés, hover states |
| **Blanc Pur** | `#FFFFFF` | Arrière-plans, texte sur fond sombre |
| **Noir Profond** | `#1A1A1A` | Texte principal, backgrounds vidéo |
| **Gris Chaud** | `#6B6B6B` | Texte secondaire, placeholders |
| **Gris Clair** | `#F5F5F5` | Séparateurs, backgrounds secondaires |

### Palette Sémantique

| Nom | Hex | Usage |
|-----|-----|-------|
| **Succès** | `#22C55E` | Validations, confirmations |
| **Erreur** | `#EF4444` | Erreurs, alertes critiques |
| **Warning** | `#F59E0B` | Avertissements |
| **Info** | `#3B82F6` | Informations, liens |

### Dégradés

| Nom | Valeur | Usage |
|-----|--------|-------|
| **Gradient Principal** | `linear-gradient(135deg, #FFB800 0%, #FF8C00 100%)` | Boutons CTA, headers |
| **Gradient Subtil** | `linear-gradient(180deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.7) 100%)` | Overlay sur vidéos |

---

## Typographie

### Police

**Famille principale** : Inter (Google Fonts)
- Fallback : `-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`

### Échelle Typographique

| Style | Taille | Poids | Line Height | Usage |
|-------|--------|-------|-------------|-------|
| **H1 / Hero** | 32px | Bold (700) | 1.2 | Titres principaux |
| **H2 / Section** | 24px | SemiBold (600) | 1.3 | Titres de sections |
| **H3 / Card** | 20px | SemiBold (600) | 1.4 | Titres de cartes |
| **Body Large** | 18px | Regular (400) | 1.5 | Texte important |
| **Body** | 16px | Regular (400) | 1.5 | Texte courant |
| **Body Small** | 14px | Regular (400) | 1.5 | Texte secondaire |
| **Caption** | 12px | Medium (500) | 1.4 | Labels, légendes |
| **Overline** | 10px | Bold (700) | 1.2 | Badges, tags |

---

## Espacements

### Grille d'Espacement (Base 4px)

| Token | Valeur | Usage |
|-------|--------|-------|
| `space-xs` | 4px | Espaces internes minimes |
| `space-sm` | 8px | Espaces entre éléments proches |
| `space-md` | 16px | Padding standard des composants |
| `space-lg` | 24px | Espaces entre sections |
| `space-xl` | 32px | Marges de page |
| `space-2xl` | 48px | Grandes séparations |
| `space-3xl` | 64px | Espaces entre blocs majeurs |

### Marges de Page

- **Mobile** : 16px (horizontal)
- **Tablette** : 24px (horizontal)
- **Safe Area** : Respecter les encoches iOS/Android

---

## Rayons de Bordure

| Token | Valeur | Usage |
|-------|--------|-------|
| `radius-sm` | 4px | Tags, badges |
| `radius-md` | 8px | Boutons, inputs |
| `radius-lg` | 16px | Cards, modales |
| `radius-xl` | 24px | Grandes cards |
| `radius-full` | 9999px | Avatars, pills |

---

## Ombres

| Token | Valeur | Usage |
|-------|--------|-------|
| `shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Éléments légers |
| `shadow-md` | `0 4px 6px rgba(0,0,0,0.1)` | Cards, boutons élevés |
| `shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | Modales, popovers |
| `shadow-xl` | `0 20px 25px rgba(0,0,0,0.15)` | Éléments flottants |

---

## Composants UI

### Boutons

#### Bouton Primaire
```
Background: Gradient Principal (#FFB800 → #FF8C00)
Texte: Blanc, Body Bold
Padding: 16px 24px
Border-radius: radius-md (8px)
État Pressed: Opacity 0.9, scale 0.98
État Disabled: Opacity 0.5
```

#### Bouton Secondaire
```
Background: Transparent
Border: 2px solid #FFB800
Texte: #FFB800, Body Bold
Padding: 14px 22px
Border-radius: radius-md (8px)
```

#### Bouton Ghost
```
Background: Transparent
Texte: #6B6B6B
Padding: 8px 16px
```

#### Bouton Icône
```
Taille: 48x48px
Border-radius: radius-full
Background: rgba(255,255,255,0.1) sur fond sombre
```

### Inputs

#### Champ de Texte
```
Background: #F5F5F5
Border: 1px solid transparent
Border Focus: 2px solid #FFB800
Padding: 16px
Border-radius: radius-md (8px)
Texte: Body, #1A1A1A
Placeholder: Body, #6B6B6B
```

#### Zone de Message
```
Background: #FFFFFF
Border: 1px solid #E5E5E5
Min-height: 48px
Max-height: 120px
Border-radius: radius-lg (16px)
```

### Cards

#### Card Profil (sur Feed)
```
Overlay gradient en bas de vidéo
Padding: 16px
Contenu:
- Nom (H3, Blanc)
- Métier (Body Small, Blanc 80%)
- Localisation (Caption, Blanc 60%)
```

#### Card Message
```
Background: #FFFFFF
Padding: 16px
Border-radius: radius-lg
Shadow: shadow-md
```

### Navigation

#### Tab Bar
```
Height: 80px (+ safe area bottom)
Background: #FFFFFF
Shadow: shadow-lg inversée
Icônes: 24x24px
Label: Caption (10px)
Couleur inactive: #6B6B6B
Couleur active: #FFB800
```

**Tabs Chercheur** : Feed | Messages | Profil | Enregistrer
**Tabs Recruteur** : Feed | Messages | Profil

#### Header
```
Height: 56px (+ safe area top)
Background: Transparent sur feed, #FFFFFF ailleurs
Titre: H3, centré
Actions: Boutons icône à droite
```

### Badges

#### Badge Vérifié
```
Icône: Checkmark dans cercle
Couleur: #FFB800
Taille: 16x16px
Position: À droite du nom
```

#### Badge Notification
```
Background: #EF4444
Taille: 18x18px minimum
Texte: Overline, Blanc
Border-radius: radius-full
```

#### Tag Métier
```
Background: rgba(255,184,0,0.15)
Texte: #FF8C00, Caption
Padding: 4px 8px
Border-radius: radius-sm
```

### Modales

#### Modal Standard
```
Background: #FFFFFF
Border-radius: radius-xl (24px) top
Padding: 24px
Max-height: 90vh
Handle: 40x4px, #E5E5E5, centré en haut
```

#### Alert Dialog
```
Background: #FFFFFF
Border-radius: radius-lg
Padding: 24px
Width: 280px
Shadow: shadow-xl
Centré verticalement
```

---

## Animations

### Micro-interactions

| Élément | Animation | Durée | Easing |
|---------|-----------|-------|--------|
| Bouton press | Scale 0.98 | 100ms | ease-out |
| Card hover | Elevation +1 | 200ms | ease-in-out |
| Tab switch | Fade + scale | 200ms | ease-out |
| Modal open | Slide up + fade | 300ms | ease-out |
| Modal close | Slide down + fade | 200ms | ease-in |

### Transitions de Page

| Transition | Animation | Durée |
|------------|-----------|-------|
| Push (navigation) | Slide from right | 300ms |
| Pop (retour) | Slide to right | 250ms |
| Modal present | Slide from bottom | 350ms |

### Animations Spéciales

#### Publication Vidéo Réussie
```
Séquence:
1. Checkmark apparaît (scale 0→1, 300ms)
2. Cercle pulse (2x, 200ms chaque)
3. Message "Bravo !" fade in (200ms)
Durée totale: ~1s
```

#### Premier Message Reçu
```
Séquence:
1. Notification slide down (300ms)
2. Subtle glow pulse sur l'icône Messages (2x)
3. Badge count animate (scale bounce)
```

---

## Iconographie

### Style
- **Type** : Outlined, 2px stroke
- **Taille standard** : 24x24px
- **Taille petite** : 20x20px
- **Taille grande** : 32x32px

### Icônes Principales

| Icône | Usage |
|-------|-------|
| Home | Tab Feed |
| Message Circle | Tab Messages |
| User | Tab Profil |
| Video | Tab Enregistrer |
| Check Circle | Validation, Badge Vérifié |
| X | Fermer, Annuler |
| ChevronLeft | Retour |
| Send | Envoyer message |
| MapPin | Localisation |
| Briefcase | Métier |
| Play | Lecture vidéo |
| Pause | Pause vidéo |
| RefreshCw | Ré-enregistrer |

---

# User Flows Détaillés

## Flow 1 : Onboarding Chercheur d'Emploi

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ONBOARDING CHERCHEUR                        │
└─────────────────────────────────────────────────────────────────────┘

[1. Splash Screen]
    │
    ▼
[2. Welcome Screen]
    "Bienvenue sur Etoile"
    "40 secondes pour briller"
    [Je cherche un emploi] ──────────────────┐
    [Je recrute]                              │
    │                                         │
    ▼                                         │
[3. Création de Compte]                       │
    - Email                                   │
    - Mot de passe                            │
    - Prénom                                  │
    [Continuer]                               │
    │                                         │
    ▼                                         │
[4. Infos Professionnelles]                   │
    - Métier recherché (dropdown)             │
    - Région (dropdown)                       │
    - Disponibilité                           │
    [Continuer]                               │
    │                                         │
    ▼                                         │
[5. Introduction Vidéo]                       │
    "Prêt à briller ?"                        │
    Explication : 40s, 3 parties              │
    [Enregistrer maintenant]                  │
    [Plus tard] ─────────────────────────────┐│
    │                                        ││
    ▼                                        ││
[6. Coaching Vidéo]                          ││
    → Voir Flow Enregistrement               ││
    │                                        ││
    ▼                                        ▼▼
[7. Home / Feed]
    Message : "Bravo ! Votre étoile brille maintenant"
```

### États et Messages

| Étape | Message Principal | Message Secondaire |
|-------|-------------------|-------------------|
| Welcome | "Bienvenue sur Etoile" | "40 secondes pour montrer qui vous êtes vraiment" |
| Création compte | "Créons votre compte" | "C'est rapide, promis !" |
| Infos pro | "Parlez-nous de vous" | "Ces infos aident les recruteurs à vous trouver" |
| Intro vidéo | "Prêt à briller ?" | "Pas de montage, pas de stress. Juste vous." |
| Succès | "Bravo !" | "Votre étoile brille maintenant dans le ciel Etoile" |

---

## Flow 2 : Onboarding Recruteur

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ONBOARDING RECRUTEUR                         │
└─────────────────────────────────────────────────────────────────────┘

[1. Welcome Screen]
    [Je recrute] ────────────────────────────┐
    │                                        │
    ▼                                        │
[2. Création de Compte Pro]                  │
    - Email professionnel                    │
    - Mot de passe                           │
    - Nom complet                            │
    [Continuer]                              │
    │                                        │
    ▼                                        │
[3. Infos Entreprise]                        │
    - Nom de l'entreprise                    │
    - SIRET (optionnel mais recommandé)      │
    - Secteur d'activité                     │
    - Taille entreprise                      │
    [Continuer]                              │
    │                                        │
    ▼                                        │
[4. Vérification]                            │
    - Email de confirmation envoyé           │
    "En attente de vérification"             │
    Note : accès limité en attendant         │
    │                                        │
    ▼                                        │
[5. Vidéo Entreprise (Optionnel)]            │
    "Présentez votre entreprise"             │
    [Importer une vidéo]                     │
    [Enregistrer]                            │
    [Plus tard]                              │
    │                                        │
    ▼                                        │
[6. Préférences Recrutement]                 │
    - Métiers recherchés (multi-select)      │
    - Régions (multi-select)                 │
    [Commencer à recruter]                   │
    │                                        │
    ▼                                        │
[7. Feed avec Filtres Pré-remplis]           │
    Badge "En cours de vérification"         │
    │                                        │
    ▼ (après vérification)                   │
[8. Badge Vérifié Activé]                    │
    Notification : "Félicitations ! Votre    │
    compte est maintenant vérifié"           │
```

### Niveaux de Vérification

| Niveau | Critères | Badge | Accès |
|--------|----------|-------|-------|
| Non vérifié | Email non confirmé | Aucun | Aucun |
| En attente | Email confirmé | "En attente" | Lecture feed uniquement |
| Vérifié | SIRET validé ou validation manuelle | Badge jaune | Complet |

---

## Flow 3 : Enregistrement Vidéo

```
┌─────────────────────────────────────────────────────────────────────┐
│                      ENREGISTREMENT VIDÉO 40s                        │
└─────────────────────────────────────────────────────────────────────┘

[1. Écran Préparation]
    │
    ├── Conseil affiché : "Trouvez un endroit calme et bien éclairé"
    ├── Aperçu caméra (plein écran)
    ├── [X] Fermer
    ├── [?] Aide/Conseils
    │
    [Démarrer l'enregistrement]
    │
    ▼
[2. Phase 1 : Présentation (0-10s)]
    │
    ├── Timer : compte à rebours 10→0
    ├── Prompt affiché : "Présentez-vous en quelques mots"
    ├── Indicateur de phase : ●○○
    ├── Barre de progression segment 1/3
    │
    │ (auto-transition à 10s)
    ▼
[3. Phase 2 : Compétences (10-30s)]
    │
    ├── Timer : compte à rebours 20→0
    ├── Prompt : "Parlez de vos compétences clés"
    ├── Indicateur de phase : ●●○
    ├── Barre de progression segment 2/3
    │
    │ (auto-transition à 30s)
    ▼
[4. Phase 3 : Conclusion (30-40s)]
    │
    ├── Timer : compte à rebours 10→0
    ├── Prompt : "Pourquoi vous choisir ?"
    ├── Indicateur de phase : ●●●
    ├── Barre de progression segment 3/3
    │
    │ (auto-stop à 40s)
    ▼
[5. Écran Prévisualisation]
    │
    ├── Lecture automatique de la vidéo
    ├── Contrôles : Play/Pause, Scrubber
    │
    ├── [Ré-enregistrer] → Retour à [1]
    │
    └── [Publier ma vidéo]
            │
            ▼
[6. Écran Succès]
    │
    ├── Animation de célébration subtile
    ├── Message : "Bravo ! Votre étoile brille maintenant"
    │
    └── [Voir mon profil] ou [Explorer le feed]
```

### Détails UI Phase Enregistrement

```
┌────────────────────────────────────────┐
│  [X]                            [?]    │  ← Header transparent
│                                        │
│                                        │
│                                        │
│          [APERÇU CAMÉRA]               │  ← Plein écran
│                                        │
│                                        │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │ Présentez-vous en quelques mots  │  │  ← Prompt centré
│  └──────────────────────────────────┘  │
│                                        │
│           ●○○  Phase 1/3               │  ← Indicateur
│                                        │
│  ════════════░░░░░░░░░░░░░░░░░░░░░░░  │  ← Barre progression
│  0s                              40s   │
│                                        │
│              [08]                      │  ← Timer grand
│                                        │
└────────────────────────────────────────┘
```

---

## Flow 4 : Navigation Feed

```
┌─────────────────────────────────────────────────────────────────────┐
│                          NAVIGATION FEED                             │
└─────────────────────────────────────────────────────────────────────┘

[Feed Principal]
    │
    ├── Vidéo plein écran
    │   ├── Swipe UP → Vidéo suivante
    │   ├── Swipe DOWN → Vidéo précédente
    │   ├── TAP → Pause/Play
    │   ├── Double TAP → (rien, pas de like)
    │   │
    │   ├── Overlay bas :
    │   │   ├── Nom + Badge Vérifié (si recruteur vérifié)
    │   │   ├── Métier
    │   │   └── Localisation
    │   │
    │   └── Actions droite (pour Recruteur) :
    │       ├── [Message] → Modal Contact
    │       └── [Profil] → Écran Profil Détaillé
    │
    ├── Header :
    │   ├── Logo Etoile (gauche)
    │   ├── [Filtres] (droite) → Modal Filtres
    │   └── [Recherche] (droite) → Écran Recherche
    │
    └── Tab Bar (bas)

[Modal Filtres]
    │
    ├── Métier (liste déroulante multi-select)
    ├── Région (liste déroulante multi-select)
    ├── Disponibilité (toggle : Immédiate / Sous 1 mois / Flexible)
    │
    ├── [Réinitialiser]
    └── [Appliquer]

[Modal Contact Rapide] (Recruteur → Chercheur)
    │
    ├── Mini-profil du candidat
    ├── Templates de messages :
    │   ├── "Votre profil m'intéresse, discutons !"
    │   ├── "J'ai une opportunité qui pourrait vous convenir"
    │   └── [Message personnalisé]
    │
    ├── Zone de texte libre
    │
    └── [Envoyer]
            │
            ▼
        Notification : "Message envoyé !"
        Retour au Feed
```

### États du Feed

| État | Affichage |
|------|-----------|
| Chargement | Skeleton loader + shimmer |
| Vide (pas de résultats) | "Aucun profil ne correspond. Modifiez vos filtres." |
| Erreur connexion | "Oups, petit souci de connexion. Réessayez." |
| Fin de liste | "Vous avez tout vu ! Revenez bientôt." |

---

## Flow 5 : Messagerie

```
┌─────────────────────────────────────────────────────────────────────┐
│                           MESSAGERIE                                 │
└─────────────────────────────────────────────────────────────────────┘

[Liste des Conversations]
    │
    ├── Header : "Messages"
    │
    ├── État vide (Chercheur sans messages) :
    │   "Votre vidéo est découverte par les recruteurs"
    │   "Les opportunités arrivent bientôt !"
    │
    ├── Liste des conversations :
    │   ┌─────────────────────────────────────┐
    │   │ [Avatar] Nom + Badge Vérifié        │
    │   │          Entreprise                 │
    │   │          "Dernier message..."  14:32│
    │   │                              [●]    │ ← Badge non lu
    │   └─────────────────────────────────────┘
    │
    └── TAP sur conversation → Écran Conversation

[Écran Conversation]
    │
    ├── Header :
    │   ├── [←] Retour
    │   ├── Avatar + Nom + Badge
    │   └── [⋮] Menu (Signaler, Bloquer)
    │
    ├── Zone Messages :
    │   │
    │   │   [Message reçu - aligné gauche]
    │   │   ┌─────────────────────────────┐
    │   │   │ Texte du message            │
    │   │   │                        14:30│
    │   │   └─────────────────────────────┘
    │   │
    │   │            [Message envoyé - aligné droite]
    │   │            ┌─────────────────────────────┐
    │   │            │ Texte du message            │
    │   │            │14:32                     ✓✓ │
    │   │            └─────────────────────────────┘
    │   │
    │   └── Scroll infini vers le haut (historique)
    │
    ├── Zone de Saisie :
    │   ┌─────────────────────────────────────┐
    │   │ [+] │ Votre message...     │ [→]   │
    │   └─────────────────────────────────────┘
    │   │
    │   ├── [+] : Joindre (photo, document)
    │   └── [→] : Envoyer
    │
    └── Actions Contextuelles :
        ├── Proposer un RDV
        └── Partager un lien

[Modal Signaler]
    │
    ├── "Pourquoi signalez-vous cette conversation ?"
    ├── ○ Spam
    ├── ○ Comportement inapproprié
    ├── ○ Fausse identité
    ├── ○ Autre
    │
    └── [Signaler] [Annuler]
```

### Indicateurs de Message

| Indicateur | Signification |
|------------|---------------|
| ✓ (gris) | Envoyé |
| ✓✓ (gris) | Délivré |
| ✓✓ (jaune) | Lu |

---

# Spécifications d'Écrans Principaux

## Écran 1 : Feed Vidéo

### Layout

```
┌────────────────────────────────────────┐
│ Safe Area Top                          │
├────────────────────────────────────────┤
│  [Logo]                    [🔍] [⚙]   │  56px - Header
├────────────────────────────────────────┤
│                                        │
│                                        │
│                                        │
│                                        │
│           VIDÉO PLEIN ÉCRAN            │
│           (16:9 ou full bleed)         │
│                                        │
│                                        │
│                                        │
│                                        │
├────────────────────────────────────────┤
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  4px - Progress bar
├────────────────────────────────────────┤
│                                        │
│  Jean Dupont ✓                  [💬]  │
│  Développeur Web               [👤]  │
│  📍 Paris                             │
│                                        │  120px - Info overlay
├────────────────────────────────────────┤
│  [🏠]    [💬]    [👤]    [📹]        │  80px - Tab bar
│  Feed   Messages Profil  Enregistrer  │
├────────────────────────────────────────┤
│ Safe Area Bottom                       │
└────────────────────────────────────────┘
```

### Comportements

| Geste | Action |
|-------|--------|
| Swipe Up | Vidéo suivante (transition slide) |
| Swipe Down | Vidéo précédente |
| Tap centre | Pause/Play |
| Tap bouton message | Ouvre modal contact |
| Tap bouton profil | Ouvre profil détaillé |
| Long press | (rien) |

### États de la Vidéo

| État | Affichage |
|------|-----------|
| Chargement | Placeholder flou + loader |
| Lecture | Vidéo + overlay info |
| Pause | Vidéo gelée + icône pause centrale |
| Erreur | Message + bouton réessayer |
| Muted | Icône son barré en haut à droite |

---

## Écran 2 : Profil Chercheur (vue personnelle)

### Layout

```
┌────────────────────────────────────────┐
│ Safe Area Top                          │
├────────────────────────────────────────┤
│  Profil                        [⚙]    │  56px - Header
├────────────────────────────────────────┤
│                                        │
│         ┌──────────────────┐           │
│         │                  │           │
│         │   VIDÉO PREVIEW  │           │
│         │    (miniature)   │           │
│         │                  │           │
│         └──────────────────┘           │  200px
│            [▶ Voir ma vidéo]           │
│                                        │
│  ─────────────────────────────────────│
│                                        │
│  Jean Dupont                           │
│  Développeur Web Full Stack            │
│  📍 Paris, Île-de-France               │
│  ✓ Disponible immédiatement            │
│                                        │
│  ─────────────────────────────────────│
│                                        │
│  Statistiques                          │
│  ┌─────────────────────────────────┐   │
│  │ Votre profil a été vu           │   │  ← Non-premium
│  │ Passez Premium pour les détails │   │
│  └─────────────────────────────────┘   │
│                                        │
│  ─────────────────────────────────────│
│                                        │
│  [📹 Modifier ma vidéo]               │
│  [✏️ Modifier mon profil]              │
│                                        │
├────────────────────────────────────────┤
│  [🏠]    [💬]    [👤]    [📹]        │
└────────────────────────────────────────┘
```

### États Statistiques

| Utilisateur | Affichage Stats |
|-------------|-----------------|
| Gratuit | "Votre profil a été vu" + CTA Premium |
| Premium | Compteur vues + graphique + recruteurs intéressés |

---

## Écran 3 : Enregistrement Vidéo

### Layout Phase Préparation

```
┌────────────────────────────────────────┐
│ Safe Area Top                          │
├────────────────────────────────────────┤
│  [X]                            [?]    │  56px - Header transparent
├────────────────────────────────────────┤
│                                        │
│                                        │
│                                        │
│         APERÇU CAMÉRA LIVE             │
│         (plein écran, miroir)          │
│                                        │
│                                        │
│                                        │
│                                        │
├────────────────────────────────────────┤
│                                        │
│  💡 Conseil                            │
│  Trouvez un endroit calme et          │
│  bien éclairé                          │
│                                        │  100px
│  ┌─────────────────────────────────┐   │
│  │   🎬 Démarrer l'enregistrement  │   │
│  └─────────────────────────────────┘   │
│                                        │
├────────────────────────────────────────┤
│ Safe Area Bottom                       │
└────────────────────────────────────────┘
```

### Layout Phase Enregistrement

```
┌────────────────────────────────────────┐
│ Safe Area Top                          │
├────────────────────────────────────────┤
│  [X Annuler]                    🔴 REC │  56px
├────────────────────────────────────────┤
│                                        │
│                                        │
│         ENREGISTREMENT EN COURS        │
│         (plein écran)                  │
│                                        │
│                                        │
│                                        │
├────────────────────────────────────────┤
│                                        │
│  ┌─────────────────────────────────┐   │
│  │   Présentez-vous en quelques    │   │
│  │   mots                          │   │  Prompt
│  └─────────────────────────────────┘   │
│                                        │
│            ●○○ Phase 1/3               │  Indicateur
│                                        │
│  ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  Barre (segment coloré)
│  0s                              40s   │
│                                        │
│              [ 07 ]                    │  Timer (grand, centré)
│                                        │
├────────────────────────────────────────┤
│ Safe Area Bottom                       │
└────────────────────────────────────────┘
```

### Prompts par Phase

| Phase | Durée | Prompt | Couleur Segment |
|-------|-------|--------|-----------------|
| 1 | 0-10s | "Présentez-vous en quelques mots" | Jaune #FFB800 |
| 2 | 10-30s | "Parlez de vos compétences clés" | Gradient |
| 3 | 30-40s | "Pourquoi vous choisir ?" | Orange #FF8C00 |

---

## Écran 4 : Liste Messages

### Layout

```
┌────────────────────────────────────────┐
│ Safe Area Top                          │
├────────────────────────────────────────┤
│  Messages                              │  56px
├────────────────────────────────────────┤
│                                        │
│  Aujourd'hui                           │  Section header
│  ─────────────────────────────────────│
│  ┌─────────────────────────────────┐   │
│  │ [👤]  Marie Martin ✓            │   │
│  │       Talent Acquisition        │   │
│  │       "Bonjour, votre pro..." ●│   │  Conversation
│  │                           14:32 │   │
│  └─────────────────────────────────┘   │
│  ─────────────────────────────────────│
│  ┌─────────────────────────────────┐   │
│  │ [👤]  Pierre Dubois ✓           │   │
│  │       RH Senior                 │   │
│  │       "Merci pour votre ré..."  │   │
│  │                           09:15 │   │
│  └─────────────────────────────────┘   │
│  ─────────────────────────────────────│
│                                        │
│  Cette semaine                         │
│  ─────────────────────────────────────│
│  ┌─────────────────────────────────┐   │
│  │ [👤]  Sophie Leroy ✓            │   │
│  │       Directrice RH             │   │
│  │       "Nous avons bien reçu..." │   │
│  │                           Lun.  │   │
│  └─────────────────────────────────┘   │
│                                        │
├────────────────────────────────────────┤
│  [🏠]    [💬●]   [👤]    [📹]        │
└────────────────────────────────────────┘
```

### État Vide (Chercheur)

```
┌────────────────────────────────────────┐
│                                        │
│                                        │
│              ⭐                        │
│                                        │
│    Votre vidéo est découverte         │
│    par les recruteurs                  │
│                                        │
│    Les opportunités arrivent           │
│    bientôt !                           │
│                                        │
│                                        │
└────────────────────────────────────────┘
```

---

## Écran 5 : Conversation

### Layout

```
┌────────────────────────────────────────┐
│ Safe Area Top                          │
├────────────────────────────────────────┤
│  [←] Marie Martin ✓              [⋮]  │  56px
│      Talent Acquisition @ TechCorp     │
├────────────────────────────────────────┤
│                                        │
│  ┌─────────────────────────────────┐   │
│  │ Bonjour Jean,                   │   │
│  │ Votre profil m'intéresse        │   │
│  │ beaucoup. Seriez-vous           │   │
│  │ disponible pour un échange ?    │   │
│  │                           14:30 │   │
│  └─────────────────────────────────┘   │  Message reçu (gauche)
│                                        │
│         ┌─────────────────────────────┐│
│         │ Bonjour Marie,              ││
│         │ Oui, avec plaisir !         ││
│         │ Je suis disponible cette    ││
│         │ semaine.                    ││
│         │ 14:32                    ✓✓ ││
│         └─────────────────────────────┘│  Message envoyé (droite)
│                                        │
│  ┌─────────────────────────────────┐   │
│  │ Parfait ! Que diriez-vous de    │   │
│  │ jeudi 14h ?                     │   │
│  │                           14:35 │   │
│  └─────────────────────────────────┘   │
│                                        │
│                                        │
├────────────────────────────────────────┤
│  ┌─────────────────────────────────┐   │
│  │ [+] │ Votre message...     [→] │   │  Input zone
│  └─────────────────────────────────┘   │
├────────────────────────────────────────┤
│ Safe Area Bottom                       │
└────────────────────────────────────────┘
```

### Styles Messages

| Type | Style |
|------|-------|
| Reçu | Background: #F5F5F5, radius gauche arrondi |
| Envoyé | Background: Gradient jaune→orange, radius droite arrondi, texte blanc |
| Système | Centré, texte gris, italique |

---

## Messages Système (Ton Chaleureux)

### Messages de Succès

| Contexte | Message |
|----------|---------|
| Vidéo publiée | "Bravo ! Votre étoile brille maintenant dans le ciel Etoile." |
| Premier message reçu | "Bonne nouvelle ! Un recruteur s'intéresse à votre profil." |
| Message envoyé | "Message envoyé ! Croisons les doigts." |
| Profil vérifié (recruteur) | "Félicitations ! Votre compte est maintenant vérifié." |

### Messages d'Erreur (Ton Humain)

| Contexte | Message |
|----------|---------|
| Erreur réseau | "Oups, petit souci de connexion. Réessayez dans un instant." |
| Erreur upload | "Aïe, la vidéo n'a pas pu être envoyée. On réessaie ?" |
| Session expirée | "Votre session a expiré. Reconnectez-vous pour continuer." |
| Erreur générique | "Quelque chose s'est mal passé. Notre équipe est sur le coup !" |

### Messages d'Information

| Contexte | Message |
|----------|---------|
| Vérification en cours | "Votre compte est en cours de vérification. Patience !" |
| Stats non-premium | "Votre profil a été vu. Passez Premium pour les détails." |
| Fin du feed | "Vous avez tout vu ! Revenez bientôt pour de nouveaux profils." |
| Pas de résultats | "Aucun profil ne correspond à vos critères. Modifiez vos filtres." |

---

## Accessibilité

### Contrastes Minimums

| Élément | Ratio Minimum | Vérifié |
|---------|---------------|---------|
| Texte sur fond blanc | 4.5:1 | #1A1A1A = 16.1:1 ✓ |
| Texte sur gradient | 4.5:1 | Blanc sur orange = 4.6:1 ✓ |
| Texte secondaire | 3:1 | #6B6B6B sur blanc = 5.9:1 ✓ |

### Tailles Tactiles

| Élément | Taille Minimum |
|---------|----------------|
| Boutons | 48x48px |
| Zones tap | 44x44px |
| Espacement entre cibles | 8px |

### Support VoiceOver/TalkBack

- Labels descriptifs sur tous les boutons
- Ordre de lecture logique
- États annoncés (sélectionné, désactivé)
- Descriptions alternatives pour vidéos

---

## Responsive et Adaptations

### Tablette (iPad)

- Feed : vue split (liste à gauche, vidéo à droite)
- Messages : layout master-detail
- Tab bar : peut devenir sidebar

### Mode Paysage

- Enregistrement : non supporté (forcer portrait)
- Lecture : plein écran paysage autorisé
- Autres écrans : scrollable

---

## Performance UX

### Temps de Chargement Cibles

| Action | Cible | Maximum |
|--------|-------|---------|
| Lancement app | < 2s | 3s |
| Chargement vidéo feed | < 1s | 2s |
| Transition entre vidéos | < 300ms | 500ms |
| Envoi message | < 500ms | 1s |
| Publication vidéo | Feedback immédiat | Upload en background |

### Stratégies

- Préchargement des 2 vidéos suivantes dans le feed
- Skeleton loaders pour tous les états de chargement
- Optimistic UI pour les actions (message envoyé avant confirmation serveur)
- Cache local pour les vidéos déjà vues

---

## Checklist Avant Développement

- [ ] Design System implémenté dans Figma
- [ ] Tous les écrans maquettés
- [ ] Prototypes interactifs validés
- [ ] Tests utilisateurs réalisés (minimum 5)
- [ ] Spécifications exportées pour développeurs
- [ ] Assets (icônes, illustrations) préparés
- [ ] Guidelines animation documentées
- [ ] Flows d'erreur tous mappés

---

*Document UX Design finalisé par Sally, UX Designer*
*Dernière mise à jour : 2026-02-01*
