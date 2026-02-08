# Supabase - Etoile Mobile App

## Structure

```
supabase/
├── migrations/
│   └── 20260202000000_initial_schema.sql   # Schema initial complet
├── functions/
│   ├── stripe-webhook/                      # Webhook Stripe
│   ├── create-payment-intent/               # Achats unitaires
│   └── create-subscription-intent/          # Abonnements
├── config.toml                              # Configuration (a creer)
└── README.md                                # Ce fichier
```

## Tables (14)

| Table | Description |
|-------|-------------|
| `users` | Utilisateurs (chercheurs, recruteurs, admins) |
| `seeker_profiles` | Profils des chercheurs d'emploi |
| `recruiter_profiles` | Profils des recruteurs/entreprises |
| `categories` | Categories de metiers |
| `videos` | Videos (presentations et offres) |
| `video_views` | Tracking des vues videos |
| `conversations` | Conversations entre utilisateurs |
| `messages` | Messages individuels |
| `subscriptions` | Abonnements premium |
| `purchases` | Achats unitaires (credits) |
| `blocks` | Blocages entre utilisateurs |
| `reports` | Signalements de contenus |
| `push_tokens` | Tokens notifications push |
| `audit_logs` | Journal d'audit |

## Deploiement

### Prerequis

1. Installer Supabase CLI:
```bash
npm install -g supabase
```

2. Se connecter:
```bash
supabase login
```

3. Lier au projet:
```bash
supabase link --project-ref <project-id>
```

### Appliquer les migrations

```bash
# En local (pour dev)
supabase db reset

# En production
supabase db push
```

### Verifier le schema

```bash
supabase db diff
```

## Edge Functions

### Deploiement des fonctions

```bash
# Deployer toutes les fonctions
supabase functions deploy

# Deployer une fonction specifique
supabase functions deploy stripe-webhook
```

### Configuration des secrets

```bash
# Stripe (obligatoire pour les paiements)
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_xxx
```

### Fonctions disponibles

| Fonction | Description | Methode |
|----------|-------------|---------|
| `stripe-webhook` | Webhooks Stripe | POST |
| `create-payment-intent` | Achats unitaires | POST |
| `create-subscription-intent` | Abonnements | POST |

### stripe-webhook

Recoit et traite les evenements Stripe:
- `invoice.paid` - Met a jour l'abonnement en DB
- `invoice.payment_failed` - Marque comme past_due
- `customer.subscription.updated` - Synchro statut
- `customer.subscription.deleted` - Expire l'abonnement
- `checkout.session.completed` - Credite les achats

**Configuration Stripe Dashboard:**
1. Developers > Webhooks > Add endpoint
2. URL: `https://<project>.supabase.co/functions/v1/stripe-webhook`
3. Events: invoice.paid, invoice.payment_failed, customer.subscription.*

### create-payment-intent

Cree un PaymentIntent pour les achats unitaires (credits video/affiche).

**Request:**
```json
{
  "priceId": "price_xxx",
  "quantity": 1,
  "userId": "uuid"
}
```

**Response:**
```json
{
  "clientSecret": "pi_xxx_secret_xxx",
  "paymentIntentId": "pi_xxx",
  "customerId": "cus_xxx",
  "ephemeralKey": "ek_xxx"
}
```

### create-subscription-intent

Cree une subscription avec Payment Sheet.

**Request:**
```json
{
  "priceId": "price_xxx",
  "userId": "uuid"
}
```

**Response:**
```json
{
  "clientSecret": "pi_xxx_secret_xxx",
  "subscriptionId": "sub_xxx",
  "customerId": "cus_xxx",
  "ephemeralKey": "ek_xxx"
}
```

## Produits Stripe

A creer dans le Dashboard Stripe:

| Product ID | Nom | Prix | Type |
|------------|-----|------|------|
| `seeker_premium` | Premium Chercheur | 5€/mois | Subscription |
| `recruiter_premium` | Premium Recruteur | 500€/mois | Subscription |
| `video_credit` | Credit Video | 100€ | One-time |
| `poster_credit` | Credit Affiche | 50€ | One-time |

## Row Level Security (RLS)

RLS est active sur toutes les tables sensibles. Policies implementees:

- **users**: Lecture/modification de ses propres donnees uniquement
- **profiles**: Lecture publique, modification par proprietaire
- **videos**: Lecture des videos actives, gestion par proprietaire
- **messages**: Lecture uniquement par participants de la conversation
- **subscriptions/purchases**: Lecture de ses propres abonnements/achats
- **blocks/reports**: Gestion par l'utilisateur qui bloque/signale

## Extensions

- `uuid-ossp`: Generation d'UUIDs
- `pgcrypto`: Fonctions cryptographiques

## Triggers

`update_updated_at_column()` est applique sur:
- users
- seeker_profiles
- recruiter_profiles
- videos
- subscriptions
- push_tokens

## Categories Initiales

15 categories sont pre-inserees lors de la migration:
- Informatique & Tech
- Commerce & Vente
- Marketing & Communication
- Finance & Comptabilite
- Ressources Humaines
- Sante & Medical
- BTP & Construction
- Industrie & Production
- Hotellerie & Restauration
- Education & Formation
- Juridique & Droit
- Art & Design
- Services a la personne
- Transport & Logistique
- Autre

## Conventions

- **Primary Keys**: UUIDs avec `uuid_generate_v4()`
- **Timestamps**: `TIMESTAMP WITH TIME ZONE`
- **Soft Delete**: Via `status = 'deleted'`
- **Indexes**: Sur toutes les FK et colonnes filtrees frequemment
