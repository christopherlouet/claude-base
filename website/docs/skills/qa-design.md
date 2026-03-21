---
sidebar_position: 31
title: "qa-design"
description: "Audit de design UI/UX et verification des bonnes pratiques web. Declencher quand l'utilisateur veut auditer le design, verifier l'UI/UX, ou ameliorer l'interface utilisateur."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-design

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Audit de design UI/UX et verification des bonnes pratiques web. Declencher quand l'utilisateur veut auditer le design, verifier l'UI/UX, ou ameliorer l'interface utilisateur.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Glob`, `Grep` |
| **Mots-cles** | `design`, `'][^`, ``, `` |

## Description detaillee

# Audit Design UI/UX

## Objectif

Auditer une interface web selon 100+ regles couvrant accessibilite, formulaires, animations, typographie, images, performance, navigation, dark mode et internationalisation.

## Categories d'audit

```
┌──────────────────────────────────────────────────────────────────┐
│                      UI/UX AUDIT                                  │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. ACCESSIBILITE       ARIA, contraste, focus, clavier          │
│  2. FORMULAIRES         Validation, feedback, autofill           │
│  3. ANIMATIONS          Performance, reduced-motion, timing      │
│  4. TYPOGRAPHIE         Hierarchie, lisibilite, responsive       │
│  5. IMAGES              Alt text, lazy loading, formats          │
│  6. PERFORMANCE UI      Layout shift, first paint, bundle        │
│  7. NAVIGATION          Breadcrumbs, mobile menu, deep links     │
│  8. DARK MODE           Variables CSS, images, contraste         │
│  9. INTERACTIONS TOUCH  Taille cibles, swipe, gestures          │
│  10. INTERNATIONALISATION  RTL, dates, pluriels, traductions    │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## 1. Accessibilite

### Regles critiques

| # | Regle | Verification |
|---|-------|-------------|
| A1 | Contraste minimum 4.5:1 (texte normal) | Verifier les couleurs CSS |
| A2 | Contraste minimum 3:1 (grands textes, icones) | Verifier les couleurs CSS |
| A3 | Labels sur tous les champs de formulaire | `<label for="">` ou `aria-label` |
| A4 | Alt text sur toutes les images informatives | `<img alt="">` non vide |
| A5 | Navigation au clavier complete | Tab, Enter, Escape, Arrow keys |
| A6 | Focus visible sur elements interactifs | `:focus-visible` style |
| A7 | Roles ARIA corrects | `role`, `aria-*` attributes |
| A8 | Pas de contenu uniquement visuel | Alternatives textuelles |
| A9 | Structure de headings logique | h1 > h2 > h3, pas de saut |
| A10 | Skip to content link | Premier element focusable |

### Patterns a rechercher

```
# Images sans alt
<img[^>]*(?<!alt=")[^>]*>

# Boutons sans texte accessible
<button[^>]*>(\s*<(svg|img|i)[^>]*>\s*)<\/button>

# Inputs sans label
<input(?![^>]*aria-label)(?![^>]*id=["'][^"']*["'][^>]*)[^>]*>

# Contraste insuffisant (couleurs claires sur fond clair)
color:\s*#[def][def][def]|color:\s*#[cdef]{6}
```

## 2. Formulaires

| # | Regle | Detail |
|---|-------|--------|
| F1 | Validation inline (pas seulement au submit) | Afficher erreur au blur |
| F2 | Messages d'erreur descriptifs | Pas juste "Champ invalide" |
| F3 | Autocomplete attributes | `autocomplete="email"`, `"name"`, etc. |
| F4 | Bouton submit desactive si invalide | Ou feedback clair |
| F5 | Indicateur de champs requis | `*` ou texte explicite |
| F6 | Type d'input correct | `type="email"`, `"tel"`, `"number"` |
| F7 | Taille de police minimum 16px sur mobile | Evite le zoom iOS |
| F8 | Etat de chargement sur le submit | Spinner ou disabled |

## 3. Animations et transitions

| # | Regle | Detail |
|---|-------|--------|
| AN1 | `prefers-reduced-motion` respecte | Desactiver animations si demande |
| AN2 | Duree < 400ms pour micro-interactions | Feedback rapide |
| AN3 | Pas de flash/clignotement > 3Hz | Risque epilepsie |
| AN4 | Transitions CSS preferees a JS | Performance GPU |
| AN5 | `will-change` pour animations lourdes | Optimisation compositeur |

```css
/* Pattern prefers-reduced-motion */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## 4. Typographie

| # | Regle | Detail |
|---|-------|--------|
| T1 | Hierarchie visuelle claire | Tailles, poids, couleurs distinctes |
| T2 | Longueur de ligne 50-75 caracteres | `max-width: 65ch` |
| T3 | Line-height minimum 1.5 pour body text | Lisibilite |
| T4 | Pas plus de 2-3 polices | Coherence visuelle |
| T5 | Taille minimum 16px pour body | Lisibilite mobile |
| T6 | Font fallback systeme defini | `font-family: 'Custom', system-ui, sans-serif` |

## 5. Images

| # | Regle | Detail |
|---|-------|--------|
| I1 | Alt text descriptif | Pas "image", pas vide sauf decoratif |
| I2 | Lazy loading | `loading="lazy"` sauf above-the-fold |
| I3 | Dimensions explicites | `width` et `height` pour eviter CLS |
| I4 | Format moderne (WebP, AVIF) | Avec fallback |
| I5 | Responsive images | `srcset` et `sizes` |
| I6 | Compression optimisee | < 100KB pour images UI |

## 6. Performance UI

| # | Regle | Detail |
|---|-------|--------|
| P1 | CLS < 0.1 | Pas de layout shift |
| P2 | LCP < 2.5s | Largest Contentful Paint |
| P3 | FID < 100ms | First Input Delay |
| P4 | Skeleton/loading states | Pas de page blanche |
| P5 | Code splitting par route | Bundles < 200KB gzip |
| P6 | CSS critique inline | Above-the-fold rapide |

## 7. Navigation

| # | Regle | Detail |
|---|-------|--------|
| N1 | Breadcrumbs sur pages profondes | Orientation utilisateur |
| N2 | Menu mobile accessible | Hamburger + overlay |
| N3 | Retour facile (back button) | Navigation previsible |
| N4 | Indication de page active | Menu highlight |
| N5 | 404 page utile | Liens de navigation |
| N6 | Deep links fonctionnels | URLs partageables |

## 8. Dark Mode

| # | Regle | Detail |
|---|-------|--------|
| D1 | CSS custom properties | `--color-bg`, `--color-text` |
| D2 | Images adaptees | Pas d'images blanches sur fond sombre |
| D3 | Contraste suffisant en dark | Reverifier les ratios |
| D4 | Transition douce | `transition: background-color 0.2s` |
| D5 | Respecter `prefers-color-scheme` | Detection automatique |

## 9. Interactions touch

| # | Regle | Detail |
|---|-------|--------|
| TC1 | Cibles tactiles >= 44x44px | Minimum Apple/Google |
| TC2 | Espacement entre cibles >= 8px | Eviter les erreurs de tap |
| TC3 | Pas de hover-only interactions | Alternatives touch |
| TC4 | Swipe intuitif si utilise | Direction naturelle |

## 10. Internationalisation

| # | Regle | Detail |
|---|-------|--------|
| I18N1 | Textes externalises | Pas de strings hardcodees |
| I18N2 | Support RTL | `direction: rtl` compatible |
| I18N3 | Formats de date locaux | Pas de format US hardcode |
| I18N4 | Pluriels geres | Pas de "1 item(s)" |

## Output attendu

```markdown
## Audit UI/UX : [Nom du projet]

### Score global : X/100

### Resultats par categorie

| Categorie | Score | Issues |
|-----------|-------|--------|
| Accessibilite | X/10 | [N issues] |
| Formulaires | X/10 | [N issues] |
| Animations | X/10 | [N issues] |
| Typographie | X/10 | [N issues] |
| Images | X/10 | [N issues] |
| Performance UI | X/10 | [N issues] |
| Navigation | X/10 | [N issues] |
| Dark Mode | X/10 | [N issues] |
| Touch | X/10 | [N issues] |
| i18n | X/10 | [N issues] |

### Issues critiques
- [CRITICAL] [fichier:ligne] - Description

### Ameliorations recommandees
- [IMPORTANT] [fichier:ligne] - Description

### Suggestions
- [SUGGESTION] - Description
```

## Regles

- Verifier TOUTES les categories, pas seulement les evidentes
- Prioriser les issues par impact utilisateur
- Fournir des solutions concretes, pas juste des constats
- Tester sur mobile ET desktop

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux design..."_
- _"Je veux '][^..."_
- _"Je veux `, `..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Example: UI/UX Audit Checklist

# Example: UI/UX Audit Checklist

## Scenario
Audit a SaaS dashboard application for design consistency, usability, and accessibility.

## Audit Summary

| Category | Score | Issues Found |
|----------|-------|-------------|
| Visual Consistency | 5/10 | 8 issues |
| Typography | 6/10 | 4 issues |
| Spacing & Layout | 4/10 | 6 issues |
| Color & Contrast | 7/10 | 3 issues |
| Interaction Design | 5/10 | 5 issues |
| Accessibility | 4/10 | 7 issues |

## Visual Consistency Issues

| # | Issue | Location | Severity | Fix |
|---|-------|----------|----------|-----|
| 1 | 3 different button styles for same action | Dashboard, Settings, Profile | High | Standardize to design system `Button` component |
| 2 | Inconsistent border-radius (2px, 4px, 8px) | Cards, inputs, modals | Medium | Use `--radius-sm: 4px`, `--radius-md: 8px` tokens |
| 3 | Two different icon libraries (Lucide + HeroIcons) | Sidebar vs content area | Medium | Consolidate to Lucide icons |
| 4 | Shadow depth varies on same-level cards | Dashboard grid | Low | Use `--shadow-card` token consistently |

## Typography Issues

```
Found: 6 different font sizes used without system
Recommended scale (rem):
  --text-xs:  0.75    (12px) - labels, captions
  --text-sm:  0.875   (14px) - body small
  --text-base: 1      (16px) - body
  --text-lg:  1.125   (18px) - subheadings
  --text-xl:  1.25    (20px) - headings
  --text-2xl: 1.5     (24px) - page titles
```

## Spacing Issues

```
Found: Arbitrary margins (7px, 13px, 22px, 33px)
Recommended 4px grid:
  --space-1: 4px    --space-4: 16px    --space-8: 32px
  --space-2: 8px    --space-6: 24px    --space-12: 48px
```

## Accessibility Issues

| # | Issue | WCAG | Fix |
|---|-------|------|-----|
| 1 | Gray text on white: 2.8:1 contrast ratio | 1.4.3 AA (needs 4.5:1) | Darken to `#595959` |
| 2 | No focus indicators on interactive elements | 2.4.7 AA | Add `:focus-visible` outline |
| 3 | Form errors communicated only by color | 1.4.1 A | Add error icon + text message |
| 4 | Missing `aria-label` on icon-only buttons | 4.1.2 A | Add descriptive labels |
| 5 | Data table not navigable by keyboard | 2.1.1 A | Add `tabindex`, arrow key navigation |

## Recommended Actions

### Immediate (1 week)
1. Create CSS custom properties for colors, spacing, typography, shadows
2. Fix contrast ratio issues (WCAG compliance)
3. Add focus indicators globally

### Short-term (2-4 weeks)
4. Build/standardize component library (Button, Card, Input, Modal)
5. Replace arbitrary values with design tokens
6. Consolidate icon library

### Ongoing
7. Add Storybook for component documentation
8. Lint for design token usage (stylelint plugin)

## Key Decisions

- **Design tokens over hardcoded values**: Single source of truth, theme-able
- **4px spacing grid**: Consistent rhythm, easy mental math
- **WCAG AA minimum**: Legal compliance and better UX for all users
- **Component audit before redesign**: Fix consistency first, then iterate on aesthetics



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
