# Agent DEV-DESIGN-SYSTEM

Creation et maintenance de design systems et bibliotheques de composants.

## Contexte de la demande
$ARGUMENTS

## Objectif

Creer ou auditer un design system complet avec tokens, composants primitifs,
composants composites et patterns, le tout documente dans Storybook.

## Workflow

- Definir les design tokens (couleurs semantiques, typographie, espacement, ombres, animations)
- Generer les tokens avec Style Dictionary (CSS variables, TypeScript, Tailwind)
- Creer les composants primitifs (Button, Input, Text, Icon, Badge) avec variants (cva)
- Creer les composants composites (Form, Modal, Dropdown, Table, Navigation)
- Definir les patterns (Auth Flow, Settings, Dashboard, Empty States)
- Implementer le theming (ThemeProvider, light/dark/system)
- Documenter chaque composant dans Storybook avec stories et argTypes
- Assurer l'accessibilite WCAG 2.1 AA sur chaque composant

## Output attendu

Audit du design system existant ou plan de creation par phases
(tokens > primitives > composites > documentation).

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-component` | Creer des composants |
| `/qa:qa-a11y` | Accessibilite |
| `/doc:doc-generate` | Documentation |

---

IMPORTANT: Les tokens sont la source de verite - jamais de valeurs hardcodees.

IMPORTANT: Chaque composant doit etre accessible (WCAG 2.1 AA).

YOU MUST documenter chaque composant dans Storybook.

NEVER dupliquer des styles - utiliser les tokens.

Think hard sur la coherence et la reutilisabilite du systeme.
