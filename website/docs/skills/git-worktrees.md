---
sidebar_position: 23
title: "git-worktrees"
description: "Utilisation de git worktrees pour le developpement parallele. Declencher quand l'utilisateur veut travailler sur plusieurs branches simultanement, faire du dev parallele, ou gerer des worktrees."
tags:
  - "skill"
  - "fork"
---

# Skill: git-worktrees

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Utilisation de git worktrees pour le developpement parallele. Declencher quand l'utilisateur veut travailler sur plusieurs branches simultanement, faire du dev parallele, ou gerer des worktrees.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `git`, `worktrees`, `sessions paralleles` |

## Description detaillee

# Git Worktrees

> "The single biggest productivity unlock." — Boris Cherny, createur de Claude Code

## Objectif

Utiliser les git worktrees pour travailler sur plusieurs branches simultanement sans avoir a switcher de branche. Boris utilise 5+ sessions Claude Code en parallele avec cette technique.

## Concept

```
repo/                    # Worktree principal (main)
repo-feature-auth/       # Worktree pour feature/auth
repo-fix-login/          # Worktree pour fix/login
repo-review-pr42/        # Worktree pour reviewer PR #42
repo-analysis/           # Worktree dedie aux analyses (lecture seule)
```

Chaque worktree est un dossier separe avec son propre working directory, mais partage le meme repo git (.git).

## Setup recommande par Boris

### Configuration des alias shell

Ajouter a `~/.bashrc` ou `~/.zshrc` :

```bash
# Navigation rapide entre worktrees
alias wa="cd ~/projects/myapp"           # Worktree principal
alias wb="cd ~/projects/myapp-feature"   # Worktree feature
alias wc="cd ~/projects/myapp-fix"       # Worktree fix
alias wd="cd ~/projects/myapp-review"    # Worktree review
alias we="cd ~/projects/myapp-analysis"  # Worktree analyse

# Creation rapide de worktree
wtnew() {
  local name=$1
  local branch=${2:-$1}
  git worktree add "../$(basename $(pwd))-$name" -b "$branch" 2>/dev/null || \
  git worktree add "../$(basename $(pwd))-$name" "$branch"
  cd "../$(basename $(pwd))-$name"
}

# Suppression de worktree
wtrm() {
  local name=$1
  git worktree remove "../$(basename $(pwd))-$name"
}

# Liste des worktrees
alias wtls="git worktree list"
```

### Organisation des onglets terminal

Numerotez vos onglets de terminal (1-5) pour identifier rapidement chaque session :
- **Tab 1** : Worktree principal (main/develop)
- **Tab 2** : Feature en cours
- **Tab 3** : Fix/bugfix
- **Tab 4** : Code review
- **Tab 5** : Analyse/recherche (lecture seule)

### Worktree d'analyse

Un worktree dedie aux analyses permet de poser des questions a Claude sans risquer de modifier le code :

```bash
# Creer un worktree d'analyse sur main
git worktree add ../myapp-analysis main

# Utiliser pour les requetes de lecture
cd ../myapp-analysis
claude  # Session dediee aux questions/analyses
```

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

## Workflow Boris Cherny (5+ sessions paralleles)

### Setup complet avec sessions nommees (CLI 2.1.76+)

```bash
# 1. Creer les worktrees
git worktree add ../myapp-feature-1 -b feature/user-auth
git worktree add ../myapp-feature-2 -b feature/payment
git worktree add ../myapp-fix -b fix/login-bug
git worktree add ../myapp-review main
git worktree add ../myapp-analysis main

# 2. Lancer Claude dans chaque worktree avec --name
# Tab 1: cd ../myapp && claude -n "main"
# Tab 2: cd ../myapp-feature-1 && claude -n "auth"
# Tab 3: cd ../myapp-feature-2 && claude -n "payment"
# Tab 4: cd ../myapp-fix && claude -n "fix-login"
# Tab 5: cd ../myapp-analysis && claude -n "analysis"
```

Le flag `--name` / `-n` nomme la session pour l'identifier dans les logs et le terminal. Pattern recommande: 1 worktree = 1 branche = 1 session nommee.

### Avantages cles

| Avantage | Description |
|----------|-------------|
| Pas de stash | Chaque worktree a son propre etat |
| Contexte preserve | Chaque session Claude garde son historique |
| Parallelisme reel | Travailler sur 5 taches simultanement |
| Isolation | Un bug dans une session n'affecte pas les autres |
| Analyse separee | Poser des questions sans risquer de modifier |

### Combinaison avec claude.ai/code

Boris utilise aussi 5-10 sessions sur claude.ai/code en parallele :
- Transfert de sessions locales vers web avec `&` (teleport)
- Sessions web pour les taches longues
- Sessions locales pour l'edition rapide

### Notifications

Activer les notifications systeme pour savoir quand Claude a besoin d'input :
```bash
# macOS
osascript -e 'display notification "Claude needs input" with title "Claude Code"'

# Linux (notify-send)
notify-send "Claude Code" "Claude needs input"
```

## Sparse Paths pour Monorepos (CLI 2.1.76+)

Configuration `worktree.sparsePaths` pour limiter les fichiers inclus dans un worktree. Utile pour les monorepos volumineux:

```json
// Dans .claude/settings.json
{
  "worktree": {
    "sparsePaths": [
      "packages/frontend/**",
      "packages/shared/**",
      "package.json",
      "tsconfig.json"
    ]
  }
}
```

Exemples de configurations courantes:

| Contexte | sparsePaths |
|----------|-------------|
| Frontend only | `packages/frontend/**`, `packages/shared/**`, `*.json` |
| Backend only | `packages/api/**`, `packages/shared/**`, `*.json` |
| Full-stack | `packages/frontend/**`, `packages/api/**`, `packages/shared/**` |

Avantages: operations plus rapides, moins de bruit dans l'exploration, contexte Claude Code plus cible.

## Limitations

- Une branche ne peut etre utilisee que dans UN worktree a la fois
- Les hooks sont partages entre tous les worktrees
- Les submodules peuvent necessiter un `git submodule update` dans chaque worktree

## Voir aussi

- Section "Sessions Paralleles" dans CLAUDE.md
- `/work:work-explore` pour l'exploration de code
- `/session-handoff` pour le transfert de contexte entre sessions

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux git..."_
- _"Je veux worktrees..."_
- _"Je veux sessions paralleles..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
