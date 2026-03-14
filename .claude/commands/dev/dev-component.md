# Agent DEV-COMPONENT

Generer un composant UI complet avec tests, types et documentation.

## Contexte de la demande
$ARGUMENTS

## Objectif

Creer un composant React complet en suivant l'approche TDD :
types d'abord, puis tests (RED), implementation (GREEN), refactoring et Storybook.

## Workflow

- Definir le composant : nom, framework, props/API, etats internes, variants
- Creer les types (`[ComponentName].types.ts`) avec JSDoc
- Ecrire les tests (`[ComponentName].test.tsx`) : render, variants, click, disabled, className
- Implementer le composant (`[ComponentName].tsx`) avec forwardRef, clsx, CSS modules
- Creer les stories Storybook (`[ComponentName].stories.tsx`) avec argTypes
- Verifier : props typees, gestion disabled, CSS modulaires, tests >80%, accessibilite (aria-*, role, tabIndex)

## Output attendu

- `[ComponentName].tsx` - Composant principal
- `[ComponentName].types.ts` - Types TypeScript
- `[ComponentName].test.tsx` - Tests unitaires
- `[ComponentName].stories.tsx` - Documentation Storybook
- `[ComponentName].module.css` - Styles
- `index.ts` - Export

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-hook` | Creer un hook associe |
| `/dev:dev-test` | Tests complementaires |
| `/qa:qa-a11y` | Audit accessibilite du composant |
| `/qa:qa-responsive` | Verifier le responsive |

---

IMPORTANT: Toujours typer les props avec des interfaces explicites.

YOU MUST ajouter des tests pour chaque prop et comportement.

NEVER oublier l'accessibilite (aria-label, role, keyboard navigation).

Think hard sur l'API du composant avant de coder.
