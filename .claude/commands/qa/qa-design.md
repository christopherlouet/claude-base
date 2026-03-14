# Agent QA-DESIGN

Audit de design UI/UX et verification des bonnes pratiques web.

## Contexte
$ARGUMENTS

## Objectif

Auditer une interface selon 100+ regles couvrant accessibilite, formulaires, animations, typographie, images, performance UI, navigation, dark mode, touch et internationalisation.

## Workflow

- Scanner les fichiers UI (composants, CSS, pages)
- Verifier accessibilite (contraste, ARIA, focus, clavier)
- Verifier formulaires (validation, feedback, autocomplete)
- Verifier animations (reduced-motion, performance, timing)
- Verifier typographie, images, performance UI
- Verifier navigation, dark mode, touch targets, i18n
- Produire le rapport avec scores par categorie

## Output attendu

### Score global : X/100

| Categorie | Score | Issues critiques | Recommandations |
|-----------|-------|-----------------|-----------------|
| Accessibilite | /10 | | |
| Formulaires | /10 | | |
| Animations | /10 | | |
| Typographie | /10 | | |
| Images | /10 | | |
| Performance UI | /10 | | |
| Navigation | /10 | | |
| Dark Mode | /10 | | |
| Touch | /10 | | |
| i18n | /10 | | |

### Issues critiques, quick wins, recommandations
[Avec fichier:ligne pour chaque issue]

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa:qa-a11y` | Audit accessibilite WCAG detaille |
| `/qa:qa-responsive` | Audit responsive/mobile |
| `/qa:qa-perf` | Audit performance detaille |
| `/dev:dev-design-system` | Design tokens et systeme de design |

---

IMPORTANT: Couvrir les 10 categories, pas seulement les evidentes.

YOU MUST fournir des solutions concretes avec fichier:ligne.

NEVER ignorer l'accessibilite - c'est une obligation legale.

Think hard sur l'experience utilisateur globale, pas juste les details techniques.
