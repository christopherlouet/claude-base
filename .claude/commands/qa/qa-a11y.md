# Agent A11Y (Accessibilite)

Audit d'accessibilite base sur WCAG 2.1/2.2 et referentiel axe-core.

## Cible de l'audit
$ARGUMENTS

## Objectif

Identifier les violations d'accessibilite dans le code et proposer des corrections concretes pour atteindre le niveau AA WCAG 2.1/2.2.

## Workflow

- Scanner les fichiers UI (composants, pages, layouts, CSS)
- Auditer les 11 categories : images, formulaires, clavier, boutons/liens, couleurs, ARIA, structure, tables, frames, deprecies, WCAG 2.2
- Classifier chaque probleme par impact (Critical/Serious/Moderate/Minor)
- Distinguer violations (auto-detectables) et needs-review (verification manuelle)
- Identifier les corrections prioritaires avec fichier:ligne

## Niveaux d'impact

| Niveau | Definition | Action |
|--------|-----------|--------|
| **Critical** | Bloque completement l'acces | Corriger immediatement |
| **Serious** | Impact significatif sur l'utilisabilite | Corriger avant release |
| **Moderate** | Gene l'experience utilisateur | Planifier correction |
| **Minor** | Amelioration souhaitable | Backlog |

## Categories d'audit

| # | Categorie | Regles cles | WCAG |
|---|-----------|------------|------|
| 1 | Images/medias | alt, SVG, object, video, autoplay | 1.1.1, 1.2.2, 1.4.2 |
| 2 | Formulaires | labels, select, erreurs, autocomplete | 4.1.2, 3.3.1, 1.3.5 |
| 3 | Clavier | focus, traps, skip-link, scrollable, nested | 2.1.1, 2.1.2, 2.4.1 |
| 4 | Boutons/liens | noms accessibles, liens descriptifs | 4.1.2, 2.4.4 |
| 5 | Couleurs | ratios AA, couleur seule, elements UI | 1.4.3, 1.4.1, 1.4.11 |
| 6 | ARIA | attrs, roles, relations, aria-hidden | 4.1.2, 1.3.1 |
| 7 | Structure | lang, title, headings, landmarks, regions | 3.1.1, 2.4.2, 1.3.1 |
| 8 | Tables | th, scope, headers, caption | 1.3.1 |
| 9 | Frames | title, unicite, focus | 4.1.2, 2.1.1 |
| 10 | Deprecies | blink, marquee, meta-refresh, autoplay | 2.2.1, 2.2.2 |
| 11 | WCAG 2.2 | target-size 44x44px, focus-not-obscured | 2.5.8, 2.4.11 |

## Output attendu

### Resume
- **Score global**: [X/100]
- **Niveau WCAG atteint**: [A/AA/AAA]
- **Violations**: [N] (Critical: X, Serious: X, Moderate: X, Minor: X)
- **Needs Review**: [N]

### Violations
| Impact | Categorie | WCAG | Element | Fichier:ligne | Correction |
|--------|-----------|------|---------|---------------|------------|

### Needs Review
| Categorie | Element | Fichier:ligne | Verification requise |
|-----------|---------|---------------|---------------------|

### Recommandations prioritaires
1. [Critical] ...
2. [Serious] ...
3. [Moderate] ...

### Outils complementaires
Pour un audit runtime complet, utiliser en complement :
- **axe-core** : `npx @axe-core/cli http://localhost:3000` (audit automatise)
- **Playwright + axe** : `@axe-core/playwright` (tests E2E accessibilite)
- **Pa11y** : `npx pa11y http://localhost:3000` (audit CLI)
- **Lighthouse** : onglet Accessibility dans Chrome DevTools

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa:qa-responsive` | Design responsive mobile |
| `/qa:qa-audit` | Audit complet (inclut a11y) |
| `/qa:qa-design` | Audit UI/UX complet |
| `/qa:qa-chrome` | Tests visuels navigateur |
| `/growth:growth-seo` | SEO (impact indirect de l'a11y) |

---

IMPORTANT: L'accessibilite n'est pas optionnelle - auditer les 11 categories systematiquement.

IMPORTANT: Classifier chaque probleme par niveau d'impact (Critical/Serious/Moderate/Minor).

YOU MUST atteindre au minimum le niveau AA WCAG 2.1.

YOU MUST distinguer violations et needs-review.

NEVER ignorer les erreurs Critical d'accessibilite.

Think hard sur l'experience des utilisateurs avec handicaps.
