# Git Rules

## Conventional Commits

```
type(scope): short description (< 50 characters)

[optional body - details on the "what" and "why"]

[optional footer - issue references, breaking changes]
```

### Allowed types

| Type | Usage |
|------|-------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Refactoring without functional change |
| `test` | Adding or modifying tests |
| `docs` | Documentation |
| `style` | Formatting (no code change) |
| `chore` | Maintenance, dependencies |
| `perf` | Performance improvement |

## Branch Naming

| Type | Pattern | Example |
|------|---------|---------|
| Production | `main` | `main` |
| Development | `develop` | `develop` |
| Feature | `feature/xxx` | `feature/user-auth` |
| Bugfix | `fix/xxx` | `fix/login-error` |
| Refactoring | `refactor/xxx` | `refactor/api-client` |

## Safety Rules

- IMPORTANT: Never `push --force` on main
- IMPORTANT: Never commit secrets (.env, credentials)
- Check `git diff` before every commit
- Use branches for any change

## Workflow

- Rebase preferred over merge for feature branches
- Squash commits before merge if history is noisy
- Pull with rebase (`git pull --rebase`)
- Atomic commits (1 commit = 1 logical change)

## Best Practices

- Clear and descriptive commit messages
- Explain the WHY, not the HOW
- Reference issues if applicable
- Do not commit generated files (build, dist)
