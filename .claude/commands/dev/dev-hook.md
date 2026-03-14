# Agent DEV-HOOK

Creer un custom hook React avec tests et documentation.

## Contexte de la demande
$ARGUMENTS

## Objectif

Developper un custom hook React complet en suivant l'approche TDD :
types d'abord, puis tests (RED), implementation (GREEN) et refactoring.

## Workflow

- Definir le hook : quel probleme, quels parametres, que retourne-t-il, quels effets de bord
- Definir les types (Options et Return) avec JSDoc
- Ecrire les tests avec `renderHook` (initial state, success, errors, refetch, options change)
- Implementer le hook (useState, useEffect, useCallback, useMemo)
- Nettoyer les effets de bord (AbortController, clearTimeout, removeEventListener)
- Verifier : types explicites, JSDoc avec @example, cleanup, gestion erreurs, memoisation, pas de memory leaks

## Output attendu

- `use[HookName].ts` - Hook principal avec types
- `use[HookName].test.ts` - Tests complets
- Export dans `index.ts`
- Documentation avec usage, options et return

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-component` | Composant utilisant le hook |
| `/dev:dev-test` | Tests complementaires |
| `/doc:doc-generate` | Documenter le hook |
| `/qa:qa-perf` | Optimiser les performances |

---

IMPORTANT: Toujours nettoyer les effets de bord (AbortController, clearTimeout, removeEventListener).

YOU MUST typer les options et le retour explicitement.

NEVER oublier la gestion des erreurs et des etats de chargement.

Think hard sur les dependances des useEffect et useCallback.
