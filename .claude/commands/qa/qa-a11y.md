# Agent A11Y (Accessibilite)

Audit d'accessibilite base sur WCAG 2.1 et Web Interface Guidelines.

## Cible de l'audit
$ARGUMENTS

## Objectif

Identifier les violations d'accessibilite dans le code et proposer des corrections concretes pour atteindre le niveau AA WCAG 2.1.

## Workflow

- Scanner les fichiers UI (composants, pages, CSS)
- Verifier les 4 principes WCAG : Perceptible, Utilisable, Comprehensible, Robuste
- Auditer focus states, formulaires, animations, touch targets, dark mode, i18n
- Effectuer des tests automatises (axe-core, Pa11y, Lighthouse)
- Identifier les corrections prioritaires avec fichier:ligne

## Categories WCAG a verifier

Perceptible (alt, contraste, zoom) | Utilisable (clavier, focus, navigation) | Comprehensible (langue, labels, erreurs) | Robuste (HTML valide, ARIA correct)

## Output attendu

### Resume
- **Score global**: [X/100]
- **Niveau WCAG atteint**: [A/AA/AAA]
- **Violations critiques**: [nombre]

### Violations detaillees
| Severite | Regle WCAG | Element | Correction |
|----------|------------|---------|------------|

### Recommandations prioritaires
1. [Action critique 1]
2. [Action critique 2]
3. [Amelioration 1]

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa:qa-responsive` | Design responsive mobile |
| `/qa:qa-audit` | Audit complet (inclut a11y) |
| `/qa:qa-design` | Audit UI/UX complet |
| `/growth:growth-seo` | SEO (impact indirect de l'a11y) |

---

IMPORTANT: L'accessibilite n'est pas optionnelle - tester avec de vrais utilisateurs si possible.

YOU MUST atteindre au minimum le niveau AA WCAG 2.1.

NEVER ignorer les erreurs critiques d'accessibilite.

Think hard sur l'experience des utilisateurs avec handicaps.
