# Design System — Étoile App Mobile

## Identité visuelle

Style : moderne, épuré, mobile-first, adapté chercheurs 18-25 ans
Police : Sora (Google Fonts via google_fonts package)
Couleur accent : #635BFF (violet sobre, harmonisé avec le SaaS)
Pas de dégradés criards, pas de jaune/orange (ancienne charte abandonnée)

## Palette de couleurs

### Accent
- `accent` : #635BFF (violet principal)
- `accentLight` : #C4C1FF (hover states)
- `accentDark` : #4F46E5 (boutons pressed)
- `accentBg` : #F0EFFF (backgrounds accent)
- `accentDeep` : #312E81 (texte sur fond accent)

### Sémantique
- `success` : #10B981 (vert validation)
- `successLight` : #6EE7B7
- `successBg` : #ECFDF5
- `warning` : #F59E0B (orange avertissement)
- `warningBg` : #FFFBEB
- `danger` : #EF4444 (rouge erreur)
- `dangerBg` : #FEF2F2

### Neutres
- `textPrimary` : #0A0A0B (noir principal)
- `textSecondary` : #6B7280 (gris texte secondaire)
- `textTertiary` : #9CA3AF (gris placeholders)
- `bgPrimary` : #FFFFFF (blanc pur)
- `bgSubtle` : #F9FAFB (gris très clair)
- `bgMuted` : #F3F4F6 (gris clair)
- `border` : #E5E7EB (bordures)
- `borderLight` : #F3F4F6 (séparateurs subtils)

## Typographie (Sora)

### Styles disponibles
- `display()` : 32px/800, -1.28 letterspacing, height 1.0 — Titres hero
- `h1()` : 24px/700, -0.72 letterspacing — Titres principaux
- `h2()` : 18px/600, -0.36 letterspacing — Sous-titres
- `body()` : 14px/400, height 1.6 — Corps de texte
- `caption()` : 12px/500, +0.12 letterspacing — Labels, métadonnées
- `label()` : 10px/600, +0.8 letterspacing — Tags, badges
- `button()` : 13px/600, -0.13 letterspacing — Textes de boutons
- `buttonSm()` : 12px/600, -0.12 letterspacing — Petits boutons

## Espacement (base 4px)

- `xs` : 4px
- `sm` : 8px
- `md` : 12px
- `lg` : 16px
- `xl` : 24px
- `xl2` : 32px
- `xl3` : 48px

## Rayons de bordure

- `tag` : 4px (chips, badges)
- `btn` : 8px (boutons)
- `card` : 12px (cartes, inputs, bottom sheets)
- `modal` : 16px (dialogs, modals)
- `pill` : 100px (badges ronds, avatars pill)

## Widgets réutilisables

Tous disponibles dans `lib/core/theme/app_widgets.dart` :

- `AppButtonPrimary` : bouton violet pleine largeur, 44px height
- `AppButtonSecondary` : bouton fond violet clair (accentBg), texte accentDark
- `AppChip` : chip customisable (bg + textColor)
- `AppScoreBadge` : badge score (vert si ≥80%, orange sinon)
- `AppProgressBar` : barre de progression 8px height
- `AppAvatar` : avatar circulaire avec initiales
- `AppCard` : carte avec border subtile, padding 14px

## Règles d'application

- Scaffold background : `bgSubtle` (#F9FAFB) pour contraste avec cards blanches
- AppBar : fond blanc, elevation 0, pas de surfaceTintColor
- Bottom nav : fond blanc, selected=accent, unselected=textTertiary
- Inputs : filled blanc, border 1.5px, focus=accent
- Boutons : elevation 0, pas de splash (NoSplash.splashFactory)
- Highlight : transparent
- Cards : border 0.5px pour délimitation subtile

## Migration depuis l'ancienne charte

Aliases legacy dépréciés (à ne plus utiliser) :
- `black` → `textPrimary`
- `white` → `bgPrimary`
- `error` → `danger`
- `greyWarm` → `textSecondary`
- `greyLight` → `bgSubtle`
- `greyMedium` → `border`

Couleurs supprimées (ancienne charte) :
- `primaryYellow` (#FFB800) — SUPPRIMÉ
- `primaryOrange` (#FF8C00) — SUPPRIMÉ
- `primaryGradient` — SUPPRIMÉ

## Notes techniques

- Package `google_fonts` requis dans pubspec.yaml
- ThemeData : `useMaterial3: true` obligatoire
- SystemOverlayStyle : `SystemUiOverlayStyle.dark` (status bar noire)
- Dark theme : disponible mais non prioritaire V1
