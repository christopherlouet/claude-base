---
name: git-worktrees
description: Utilisation de git worktrees pour le developpement parallele. Declencher quand l'utilisateur veut travailler sur plusieurs branches simultanement, faire du dev parallele, ou gerer des worktrees.
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
context: fork
---

# Git Worktrees

## Objectif

Utiliser les git worktrees pour travailler sur plusieurs branches simultanement sans avoir a switcher de branche.

## Concept

```
repo/                    # Worktree principal (main)
repo-feature-auth/       # Worktree pour feature/auth
repo-fix-login/          # Worktree pour fix/login
repo-review-pr42/        # Worktree pour reviewer PR #42
```

Chaque worktree est un dossier separe avec son propre working directory, mais partage le meme repo git (.git).

## Commandes essentielles

### Creer un worktree

```bash
# Nouvelle branche + worktree
git worktree add ../repo-feature-auth -b feature/auth

# Branche existante
git worktree add ../repo-fix-login fix/login

# Depuis un commit specifique
git worktree add ../repo-review HEAD~5
```

### Lister les worktrees

```bash
git worktree list
# /home/user/repo                  abc1234 [main]
# /home/user/repo-feature-auth     def5678 [feature/auth]
# /home/user/repo-fix-login        ghi9012 [fix/login]
```

### Supprimer un worktree

```bash
# Supprimer apres merge
git worktree remove ../repo-feature-auth

# Force remove (modifications non commitees)
git worktree remove --force ../repo-feature-auth

# Nettoyer les references obsoletes
git worktree prune
```

## Workflows avec worktrees

### Developper + Reviewer en parallele

```bash
# Travailler sur une feature
git worktree add ../myapp-feature -b feature/new-thing
cd ../myapp-feature
# ... developper ...

# En parallele, reviewer une PR dans un autre terminal
git worktree add ../myapp-review pr/42
cd ../myapp-review
# ... reviewer le code ...
```

### Hotfix pendant une feature

```bash
# Situation: en plein dev sur feature/auth
# Bug urgent en production

# Creer un worktree pour le hotfix (pas besoin de stash)
git worktree add ../myapp-hotfix -b hotfix/critical-bug main
cd ../myapp-hotfix
# ... corriger le bug, commiter, pusher ...

# Retourner a la feature (rien n'a change)
cd ../myapp
# ... continuer le dev feature/auth ...

# Nettoyer
git worktree remove ../myapp-hotfix
```

### Tests sur plusieurs versions

```bash
# Tester sur la version actuelle ET la precedente
git worktree add ../myapp-v1 v1.0.0
git worktree add ../myapp-v2 v2.0.0

# Lancer les tests en parallele
cd ../myapp-v1 && npm test &
cd ../myapp-v2 && npm test &
wait
```

## Convention de nommage des worktrees

```
<repo>-<type>-<nom>

Exemples:
  myapp-feature-auth      # Feature branch
  myapp-fix-login         # Bug fix
  myapp-review-pr42       # Code review
  myapp-hotfix-critical   # Hotfix
  myapp-test-v2           # Test sur une version
```

## Bonnes pratiques

- Un worktree par tache/branche active
- Supprimer les worktrees termines (`git worktree remove`)
- Executer `git worktree prune` regulierement
- Utiliser des noms de dossier descriptifs
- Ne pas imbriquer les worktrees dans le repo principal

## Limitations

- Une branche ne peut etre utilisee que dans UN worktree a la fois
- Les hooks sont partages entre tous les worktrees
- Les submodules peuvent necessiter un `git submodule update` dans chaque worktree
