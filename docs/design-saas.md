# Design System — Étoile SaaS Web

## Identité visuelle

Style de référence : Stripe + Notion (minimal, professionnel, spacieux)
Police : Sora (Google Fonts) — à importer dans layout.tsx
Couleur accent : #635BFF (violet sobre, jamais de dégradés criards)

## Tokens CSS (globals.css)

```css
:root {
  --accent: #635BFF;
  --accent-light: #7B74FF;
  --accent-dark: #4F46E5;
  --accent-bg: #F0EFFF;
  --text-primary: #0A0A0B;
  --text-secondary: #6B7280;
  --text-tertiary: #9CA3AF;
  --bg: #FFFFFF;
  --bg-subtle: #F9FAFB;
  --bg-muted: #F3F4F6;
  --border: #E5E7EB;
  --border-light: #F3F4F6;
  --success: #10B981;
  --warning: #F59E0B;
  --danger: #EF4444;
  --sidebar-w: 220px;
  --radius: 10px;
  --radius-lg: 16px;
}
```

## Composants clés

**Sidebar** : 220px fixe, toujours visible, seul le contenu de droite change
**Page Header** : 56px sticky, fond blanc, border-bottom
**Cards** : fond blanc, border 1px #E5E7EB, border-radius 10px
**Bouton primary** : fond #635BFF, hover #4F46E5, border-radius 8px
**Inputs** : border 1.5px, focus border #635BFF + box-shadow violet 8%
**Badges score** : vert (#10B981) si >80%, orange (#F59E0B) si 60-79%

## Pages

1. Landing (public) — vitrine style Stripe
2. Auth — split 2 colonnes (violet gauche, formulaire droite)
3. Dashboard — KPIs + onboarding banner + activité récente
4. Candidats — grille + hover actions + modal 3 onglets
5. Offres — liste avec slider taille
6. Messagerie — style WhatsApp (liste conversations + chat)
7. Recherche — barre @username
8. Paramètres — nav catégorisée + toggles

## Règles design

- Pas de dégradés sur les backgrounds
- Animations : Framer Motion, subtiles (fadeIn, slideUp, scale)
- Desktop-first (min-width 1024px)
- Sidebar TOUJOURS visible — navigation par contenu uniquement
- Typographie : h1 24px/700, h2 18px/600, body 14px/400, caption 12px/500
- Espacement : base 8px (xs=4, sm=8, md=12, lg=16, xl=24, xl2=32, xl3=48)
- Rayons : tag=4px, btn=8px, card=12px, modal=16px

## Shadcn/ui v4 — Notes techniques

- Utilise `@base-ui/react` — PAS de prop `asChild`
- Button : utiliser `buttonVariants()` sur Link ou className directement
- Select : `onValueChange` passe `(value: string | null)` — wrapper avec `(v) => setter(v ?? "")`
- Hooks order : TOUS les hooks AVANT tout return conditionnel
- Dialog size : default `sm:max-w-sm` très petit — forcer avec `!max-w-[96vw] !h-[92vh]`
