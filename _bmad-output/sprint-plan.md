---
status: validated
validatedAt: 2026-02-02
author: BMad Master (avec Bob - SM)
projectName: Etoile Mobile App
totalStories: 47
totalSprints: 10
sprintDuration: 1 week
---

# Etoile Mobile App - Sprint Planning

## Vue d'Ensemble

| Métrique | Valeur |
|----------|--------|
| **Total Stories** | 47 |
| **Total Epics** | 9 (Epic 0-8) |
| **Durée Sprint** | 1 semaine |
| **Durée MVP** | 10 sprints |
| **Statut** | Validé |

---

## Sprint 1: Fondation Backend 🏗️ ✅ COMPLETE

**Objectif:** Finaliser l'infrastructure backend
**Statut:** ✅ TERMINE (4/4 complete)

| ID | Story | Epic | Description | Points | Statut |
|----|-------|------|-------------|--------|--------|
| **0.2** | **Configuration Supabase** | E0 | Auth, DB, Realtime | 5 | ✅ **Complete** |
| **0.3** | **Configuration Cloudflare R2** | E0 | Vidéo storage + Workers | 5 | ✅ **Complete** |
| **0.4** | **Configuration Stripe** | E0 | Mode test, produits, webhooks | 3 | ✅ **Complete** |
| **0.5** | **Schéma Base de Données** | E0 | 14 tables + RLS policies | 8 | ✅ **Complete** |

**Total Points:** 21/21 (100%)

**Critères de Done:**
- [x] Supabase connecté depuis l'app Flutter
- [x] Bucket R2 créé avec Worker presigned URLs
- [x] Stripe en mode test avec produits créés
- [x] Toutes les tables créées avec RLS activé

---

## Sprint 2: Authentification Core 🔐

**Objectif:** Inscription et connexion fonctionnelles
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 1.1 | Inscription Chercheur | E1 | Email, password, rôle seeker | 5 |
| 1.2 | Inscription Recruteur | E1 | SIRET, document upload, pending status | 8 |
| 1.3 | Connexion / Déconnexion | E1 | JWT tokens, secure storage | 5 |
| 1.6 | Réinitialisation MDP | E1 | Email reset flow | 3 |

**Total Points:** 21

**Critères de Done:**
- [ ] Chercheur peut s'inscrire et se connecter
- [ ] Recruteur peut s'inscrire (statut pending)
- [ ] Tokens JWT stockés dans secure storage
- [ ] Reset password fonctionnel

---

## Sprint 3: Profils 👤

**Objectif:** Profils complets pour les deux rôles
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 1.4 | Profil Chercheur | E1 | Secteur, contrat, zone, dispo | 5 |
| 1.5 | Profil Recruteur | E1 | Logo, description, secteur | 5 |
| 2.1 | Enregistrement Vidéo (début) | E2 | Camera preview, UI coaching | 8 |

**Total Points:** 18

**Critères de Done:**
- [ ] Profil chercheur complet et modifiable
- [ ] Profil recruteur avec upload logo
- [ ] Écran caméra avec aperçu fonctionnel

---

## Sprint 4: Vidéo Chercheur 🎬

**Objectif:** Flux complet d'enregistrement et publication vidéo
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 2.1 | Enregistrement Vidéo (fin) | E2 | 40s timer, coaching prompts | 8 |
| 2.2 | Prévisualisation | E2 | Replay, recommencer | 5 |
| 2.3 | Publication Catégorie | E2 | Upload R2, thumbnail | 8 |
| 2.4 | Modification Vidéo | E2 | Remplacer existante | 3 |
| 2.5 | Suppression Vidéo | E2 | Soft delete, RGPD | 2 |

**Total Points:** 26

**Critères de Done:**
- [ ] Enregistrement 40s avec coaching visuel
- [ ] Upload vidéo vers R2 fonctionnel
- [ ] Vidéo visible dans le feed après publication
- [ ] Modification et suppression fonctionnelles

---

## Sprint 5: Vidéo Recruteur 📢

**Objectif:** Publications recruteur (vidéo + affiche)
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 3.1 | Import Vidéo Galerie | E3 | Sélection, crop 40s | 5 |
| 3.2 | Enregistrement In-App | E3 | Même flow que chercheur | 3 |
| 3.3 | Publication Affiche | E3 | Image upload, ratio 9:16 | 5 |
| 3.4 | Gestion Publications | E3 | Liste, stats (premium) | 5 |
| 3.5 | Modification/Suppression | E3 | Edit titre/catégorie | 3 |

**Total Points:** 21

**Critères de Done:**
- [ ] Recruteur peut importer ou enregistrer vidéo
- [ ] Recruteur peut publier affiche
- [ ] Liste des publications accessible
- [ ] Crédits décrémentés après publication

---

## Sprint 6: Feed & Découverte 📱

**Objectif:** Navigation TikTok-style fonctionnelle
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 4.1 | Feed Candidats (Recruteur) | E4 | Swipe vertical, autoplay | 8 |
| 4.2 | Feed Offres (Chercheur) | E4 | Vidéos + affiches | 5 |
| 4.3 | Lecture Vidéo | E4 | Play/pause, progress bar | 5 |
| 4.4 | Filtres | E4 | Catégorie, zone, contrat | 5 |
| 4.5 | Préchargement | E4 | Buffer 2 vidéos suivantes | 5 |
| 4.6 | Profil depuis Feed | E4 | Bottom sheet détail | 3 |

**Total Points:** 31

**Critères de Done:**
- [ ] Feed vertical style TikTok fonctionnel
- [ ] Vidéos se chargent < 2s
- [ ] Filtres appliqués correctement
- [ ] Profil accessible depuis le feed

---

## Sprint 7: Messagerie 💬

**Objectif:** Communication temps réel
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 5.1 | Initier Conversation | E5 | Création conversation | 5 |
| 5.2 | Liste Conversations | E5 | Tri par date, badge unread | 5 |
| 5.3 | Chat Temps Réel | E5 | Supabase Realtime, optimistic UI | 8 |
| 5.4 | Notifications Push | E5 | FCM/APNs integration | 8 |
| 5.5 | Bloquer Utilisateur | E5 | Block list, hide content | 3 |
| 5.6 | Signaler Conversation | E5 | Report avec motif | 2 |

**Total Points:** 31

**Critères de Done:**
- [ ] Messages arrivent en temps réel
- [ ] Notifications push fonctionnelles
- [ ] Blocage et signalement opérationnels

---

## Sprint 8: Paiements 💳

**Objectif:** Monétisation complète
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 6.1 | Page Premium Chercheur | E6 | Avantages, CTA | 3 |
| 6.2 | Page Premium Recruteur | E6 | Avantages, pricing | 3 |
| 6.3 | Paiement Stripe | E6 | Checkout, confirmation | 8 |
| 6.4 | Achat Crédits | E6 | Vidéo 100€, Affiche 50€ | 5 |
| 6.5 | Gestion Abonnement | E6 | Annulation, historique | 5 |
| 6.6 | Webhooks Stripe | E6 | Edge function events | 8 |

**Total Points:** 32

**Critères de Done:**
- [ ] Paiement carte fonctionnel
- [ ] Abonnements activés après paiement
- [ ] Webhooks traitent les événements Stripe
- [ ] Crédits à l'unité fonctionnels

---

## Sprint 9: Admin & Support 🛠️

**Objectif:** Outils d'administration et aide utilisateur
**Statut:** À faire

| ID | Story | Epic | Description | Points |
|----|-------|------|-------------|--------|
| 7.1 | Liste Recruteurs Pending | E7 | Back-office admin | 5 |
| 7.2 | Validation/Rejet | E7 | Approve/reject flow | 5 |
| 7.3 | Liste Signalements | E7 | Reports pending | 3 |
| 7.4 | Modération Contenus | E7 | Suspend/ban actions | 5 |
| 7.5 | Dashboard Stats | E7 | KPIs, graphiques | 8 |
| 8.1 | FAQ In-App | E8 | Questions/réponses | 3 |
| 8.2 | Formulaire Contact | E8 | Email support | 2 |
| 8.3 | Mentions Légales | E8 | CGU, confidentialité | 2 |

**Total Points:** 33

**Critères de Done:**
- [ ] Admin peut valider/rejeter recruteurs
- [ ] Modération signalements fonctionnelle
- [ ] Dashboard avec métriques clés
- [ ] FAQ et contact support accessibles

---

## Sprint 10: Polish & Beta ✨

**Objectif:** Tests, corrections, préparation lancement
**Statut:** À faire

**Tâches:**
- [ ] Tests unitaires (coverage > 70%)
- [ ] Tests d'intégration critiques
- [ ] Tests E2E parcours principaux
- [ ] Corrections bugs critiques
- [ ] Optimisations performances (vidéo < 2s)
- [ ] Audit accessibilité (WCAG)
- [ ] Préparation App Store (screenshots, description)
- [ ] Préparation Google Play
- [ ] Beta testeurs internes
- [ ] Documentation déploiement

---

## Résumé par Epic

| Epic | Nom | Stories | Sprints |
|------|-----|---------|---------|
| 0 | Fondation Technique | 5 | Sprint 1 |
| 1 | Authentification & Profils | 6 | Sprint 2-3 |
| 2 | Vidéo Chercheur | 5 | Sprint 3-4 |
| 3 | Vidéo & Affiche Recruteur | 5 | Sprint 5 |
| 4 | Feed & Découverte | 6 | Sprint 6 |
| 5 | Messagerie & Contact | 6 | Sprint 7 |
| 6 | Paiements & Abonnements | 6 | Sprint 8 |
| 7 | Administration | 5 | Sprint 9 |
| 8 | Support & Aide | 3 | Sprint 9 |

---

## Dépendances Critiques

```
Sprint 1 (Backend)
    ↓
Sprint 2 (Auth) ← Requis pour tout le reste
    ↓
Sprint 3 (Profils) → Sprint 4 (Vidéo Chercheur)
                   → Sprint 5 (Vidéo Recruteur)
                        ↓
                   Sprint 6 (Feed) ← Vidéos requises
                        ↓
                   Sprint 7 (Messages)
                        ↓
                   Sprint 8 (Paiements)
                        ↓
                   Sprint 9 (Admin)
                        ↓
                   Sprint 10 (Beta)
```

---

## Velocity Cible

| Sprint | Points | Cumul |
|--------|--------|-------|
| 1 | 21 | 21 |
| 2 | 21 | 42 |
| 3 | 18 | 60 |
| 4 | 26 | 86 |
| 5 | 21 | 107 |
| 6 | 31 | 138 |
| 7 | 31 | 169 |
| 8 | 32 | 201 |
| 9 | 33 | 234 |
| 10 | - | - |

**Total Points:** ~234 (hors Sprint 10 polish)
**Vélocité Moyenne:** ~26 points/sprint

---

## Notes

- Sprint 0.1 (Setup Flutter) déjà complété
- Priorité: fonctionnalités core avant premium
- Tests en continu, pas seulement Sprint 10
- Revue de sprint hebdomadaire recommandée

---

*Document généré par BMad Master le 2026-02-02*
*Validé par: Utilisateur*
