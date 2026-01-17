# Git Rules

## Conventional Commits

```
type(scope): description courte (< 50 caracteres)

[corps optionnel - details sur le "quoi" et "pourquoi"]

[footer optionnel - references issues, breaking changes]
```

### Types autorises

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalite |
| `fix` | Correction de bug |
| `refactor` | Refactoring sans changement fonctionnel |
| `test` | Ajout ou modification de tests |
| `docs` | Documentation |
| `style` | Formatage (pas de changement de code) |
| `chore` | Maintenance, dependances |
| `perf` | Amelioration de performance |

## Branch Naming

| Type | Pattern | Exemple |
|------|---------|---------|
| Production | `main` | `main` |
| Developpement | `develop` | `develop` |
| Feature | `feature/xxx` | `feature/user-auth` |
| Bugfix | `fix/xxx` | `fix/login-error` |
| Refactoring | `refactor/xxx` | `refactor/api-client` |

## Safety Rules

- IMPORTANT: Ne jamais `push --force` sur main
- IMPORTANT: Ne jamais commiter de secrets (.env, credentials)
- Verifier `git diff` avant chaque commit
- Utiliser des branches pour tout changement

## Workflow

- Rebase prefere au merge pour feature branches
- Squash commits avant merge si historique bruyant
- Pull avec rebase (`git pull --rebase`)
- Commits atomiques (1 commit = 1 changement logique)

## Best Practices

- Messages de commit clairs et descriptifs
- Expliquer le POURQUOI, pas le COMMENT
- Referencer les issues si applicable
- Ne pas commiter de fichiers generes (build, dist)
