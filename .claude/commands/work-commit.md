# Agent WORK-COMMIT

Prépare et effectue un commit propre suivant les conventions.

## Contexte
$ARGUMENTS

## Objectif

Créer un commit atomique, bien documenté et conforme aux conventions du projet.
Le commit est la dernière étape du workflow : **EXPLORE → PLAN → CODE → COMMIT**

## Processus de commit

### 1. Vérifications pré-commit

```
┌─────────────────────────────────────────┐
│           VÉRIFICATIONS                 │
├─────────────────────────────────────────┤
│  1. git status    → Fichiers modifiés   │
│  2. git diff      → Changements         │
│  3. npm test      → Tests passent       │
│  4. npm run lint  → Pas d'erreurs       │
│  5. npm run build → Build OK (si req.)  │
└─────────────────────────────────────────┘
```

### 2. Analyse des changements

```bash
# Voir les fichiers modifiés
git status

# Voir le détail des changements
git diff

# Voir les fichiers staged
git diff --staged
```

#### Questions à se poser
- [ ] Les changements sont-ils cohérents (un seul sujet) ?
- [ ] Faut-il découper en plusieurs commits ?
- [ ] Y a-t-il des fichiers à ne pas commiter ?

### 3. Format Conventional Commits

```
type(scope): description courte (<50 chars)

Corps optionnel expliquant le "pourquoi" et le "comment"
- Détail 1
- Détail 2

Footer optionnel (références, breaking changes)
Closes #123
```

### 4. Types de commits

| Type | Usage | Exemple |
|------|-------|---------|
| `feat` | Nouvelle fonctionnalité | `feat(auth): add Google OAuth login` |
| `fix` | Correction de bug | `fix(api): handle null response` |
| `refactor` | Refactoring sans changement fonctionnel | `refactor(user): extract validation` |
| `test` | Ajout ou modification de tests | `test(auth): add login edge cases` |
| `docs` | Documentation | `docs(api): update endpoint docs` |
| `style` | Formatage (pas de changement de code) | `style: apply prettier` |
| `perf` | Amélioration de performance | `perf(db): add index on users` |
| `chore` | Maintenance, dépendances | `chore(deps): update lodash` |
| `ci` | Configuration CI/CD | `ci: add test coverage report` |
| `revert` | Annulation d'un commit | `revert: feat(auth): add OAuth` |

### 5. Règles du scope

Le scope indique la partie du code impactée :
- **Module** : `auth`, `user`, `payment`
- **Couche** : `api`, `ui`, `db`
- **Feature** : `login`, `checkout`, `dashboard`

### 6. Bonnes pratiques

#### Message de commit
- [ ] Première ligne < 50 caractères
- [ ] Verbe à l'impératif ("add" pas "added")
- [ ] Pas de point final
- [ ] Corps explicatif si nécessaire

#### Contenu du commit
- [ ] Un commit = une préoccupation
- [ ] Changements atomiques et cohérents
- [ ] Tests inclus avec le code
- [ ] Pas de fichiers générés (dist/, build/)

### 7. Fichiers à ne jamais commiter

```gitignore
# Secrets
.env
.env.local
*.pem
credentials.json

# Fichiers générés
node_modules/
dist/
build/
coverage/

# IDE
.idea/
.vscode/settings.json

# OS
.DS_Store
Thumbs.db
```

## Checklist pré-commit

### Qualité du code
- [ ] Tests passent (`npm test`)
- [ ] Lint OK (`npm run lint`)
- [ ] Types OK (`npm run typecheck`)
- [ ] Build OK (`npm run build`)

### Contenu du commit
- [ ] Pas de `console.log` de debug
- [ ] Pas de code commenté inutile
- [ ] Pas de fichiers sensibles (.env, credentials)
- [ ] Pas de TODO non résolu (sauf intentionnel)

### Message de commit
- [ ] Type correct (feat/fix/refactor/etc.)
- [ ] Scope pertinent
- [ ] Description claire et concise
- [ ] Référence à l'issue si applicable

## Commandes

```bash
# Ajouter les fichiers
git add <fichiers>
# ou pour tout ajouter
git add .

# Vérifier ce qui sera commité
git status
git diff --staged

# Commiter
git commit -m "type(scope): description"

# Ou avec éditeur pour message long
git commit
```

## Exemples de bons commits

```bash
# Feature simple
git commit -m "feat(auth): add password reset functionality"

# Fix avec détails
git commit -m "fix(api): handle timeout on external service

- Add 30s timeout configuration
- Implement retry logic with exponential backoff
- Add proper error messages

Fixes #234"

# Refactoring
git commit -m "refactor(user): extract validation into separate module

Move validation logic from UserService to dedicated
UserValidator class for better testability and reuse."
```

## Agents liés

| Agent | Usage |
|-------|-------|
| `/work-pr` | Créer une PR après commit |
| `/qa-review` | Review avant commit |
| `/doc-changelog` | Mettre à jour le changelog |

---

IMPORTANT: Toujours vérifier les tests et le lint avant de commiter.

YOU MUST créer des commits atomiques - un commit = une préoccupation.

NEVER commiter de fichiers sensibles (.env, credentials, secrets).

NEVER utiliser `git add .` sans vérifier `git status` d'abord.

Think hard sur le message de commit - il sera lu par d'autres développeurs.
