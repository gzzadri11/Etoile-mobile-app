# Résumé — Étoile (Post-pivot E-4)

Dernière mise à jour : 2026-05-02

## En une phrase

Étoile est une plateforme de recrutement en alternance (Île-de-France) basée sur la vidéo courte de 40 secondes, composée d'une app mobile Flutter pour les chercheurs et d'un SaaS web Next.js pour les recruteurs, avec un backend Supabase partagé.

## Le problème résolu

Le CV ne transmet pas la motivation, l'aisance orale ni la personnalité. Étoile permet aux chercheurs de se présenter en 40 secondes et aux recruteurs de pré-sélectionner visuellement en moins de 30 secondes par candidat.

## Deux produits, un backend

**App mobile Flutter (chercheurs)**
- Inscription par OTP email, complétion profil 100% obligatoire
- Username @pseudo unique et recherchable
- Enregistrement vidéo 40s in-app (3 phases guidées), publication par secteur
- Feed vertical des offres recruteurs, candidature en 1 clic
- Messagerie temps réel avec les recruteurs
- Alertes filtrées configurables (push notifications)
- Gratuit pour les chercheurs

**SaaS web Next.js (recruteurs)**
- Inscription avec SIRET (vérification API Sirene + validation admin)
- Publication d'offres (vidéo ou affiche) depuis le web
- Grille candidates avec miniatures vidéo, hover preview, score de matching
- Modal candidat : vidéo + 3 onglets (Profil / Évaluer / Contacter)
- Actions rapides : shortlist / passer / annoter sans ouvrir le modal
- Messagerie synchronisée avec l'app mobile (Supabase Realtime)
- Recherche par @username
- Dashboard : funnel par offre, KPIs, comparaison
- Abonnement 499€/mois via Stripe direct

## Modèle économique

| Public | Accès | Prix |
|--------|-------|------|
| Chercheurs | Complet | Gratuit (beta) |
| Recruteurs gratuit | Grille lecture + 1 offre | 0€ |
| Recruteurs premium | Dashboard complet + 2 offres/semaine | 499€/mois |
| Crédit vidéo | +1 publication | 99€ |
| Crédit affiche | +1 publication | 49€ |

## Métriques cibles

| Métrique | M1 | M3 | M12 |
|----------|-----|-----|-----|
| Chercheurs | 1 000 | 5 000 | 15 000 |
| Recruteurs | 50 | 200 | 1 000 |
| MRR recruteurs | 2 500€ | 20 000€ | 100 000€ |

## Timeline MVP (6-8 semaines, 2 tracks parallèles)

**Track App Mobile** : finition code (nouvelle charte violet appliquée), soumission stores
**Track SaaS Web** : ~~setup Next.js + Supabase Auth + pages core + intégration~~ DONE — beta recruteurs en cours

## Décisions techniques clés

- Cloudflare R2 pour les vidéos (egress gratuit)
- Pas d'IAP — Stripe web uniquement
- Supabase Realtime pour la messagerie synchronisée
- Score matching via PostgreSQL Function (<100ms)
- Charte graphique unifiée violet #635BFF entre mobile et SaaS
- Police Sora (Google Fonts) sur les deux plateformes
