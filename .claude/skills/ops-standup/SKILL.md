---
name: ops-standup
description: Briefing matinal cross-repo. Agregation des commits recents, PRs, CI, blockers et priorites du jour. Declencher quand l'utilisateur veut un standup, un resume d'activite, ou savoir ce qui s'est passe.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
context: fork
model: sonnet
argument-hint: "[repo-paths] [--since 24h] [--summary-only]"
---

# Daily Standup — Briefing Matinal

## Objectif

Scanner un ou plusieurs repos git pour generer un briefing structure :
commits recents, PRs ouvertes, etat CI, blockers et priorites du jour.

Mode lecture seule — aucune modification de code.

## Phase 1 : Detection des repos

### Determiner les repos a scanner

1. Si des chemins sont fournis en arguments : les utiliser
2. Si un repertoire parent est fourni : scanner 1 niveau pour les `.git/`
3. Sinon : utiliser le repertoire courant

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `--since <duree>` | `24h` | Fenetre temporelle (24h, 48h, 7d) |
| `--summary-only` | non | Version courte sans details par repo |

## Phase 2 : Collecte des donnees

Pour chaque repo, collecter :

### 2.1 Commits recents

```bash
# Commits des dernieres 24h groupes par auteur
git log --since="24 hours ago" --format="%h %an: %s" --no-merges
```

Grouper par auteur, compter les commits, identifier les types (feat/fix/refactor/docs).

### 2.2 Pull Requests et CI

Si `gh` est disponible :

```bash
# PRs ouvertes
gh pr list --state open --json number,title,author,reviewDecision,statusCheckRollup

# PRs mergees recemment
gh pr list --state merged --json number,title,mergedAt --limit 10
```

Classifier les PRs :
- **A reviewer** : reviewDecision = REVIEW_REQUIRED
- **Approuvees** : reviewDecision = APPROVED (prete a merger)
- **En echec CI** : statusCheckRollup contient FAILURE
- **En attente** : statusCheckRollup contient PENDING

### 2.3 Etat CI

Si `gh` est disponible :

```bash
# Derniers runs de workflows
gh run list --limit 10 --json status,conclusion,name,createdAt
```

Identifier :
- Workflows en echec (conclusion = failure)
- Workflows bloques (status = in_progress depuis > 30 min)
- Workflows annules recemment

### 2.4 Branches stales

```bash
# Branches sans commit depuis 7+ jours (hors main/develop/release)
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:relative)' refs/heads/ | grep -E "(weeks|months) ago"
```

### 2.5 Changements non commites

```bash
git status --porcelain
```

Categoriser : staged, unstaged, untracked.

## Phase 3 : Synthese

Agreger les donnees en 4 categories :

### Ce qui a ete fait
- Features livrees (commits feat)
- Bugs corriges (commits fix)
- PRs mergees

### Ce qui est en cours
- PRs ouvertes et leur etat
- Branches actives avec commits recents

### Ce qui est bloque
- PRs en echec CI
- Workflows bloques ou en echec
- PRs en attente de review depuis > 48h

### Priorites suggerees
- PRs approuvees a merger
- Echecs CI a corriger
- Reviews en attente
- Branches stales a nettoyer

## Phase 4 : Output

### Vue technique (par defaut)

```markdown
# Standup — YYYY-MM-DD

## [repo-name]

### Activite (dernieres 24h)
- X commits par Y auteurs
- Z PRs mergees, W ouvertes

### Commits recents
| Auteur | Commits | Resume |
|--------|---------|--------|
| [nom] | N | feat: ..., fix: ... |

### Pull Requests
| # | Titre | Statut | CI |
|---|-------|--------|-----|
| #123 | ... | A reviewer | Passe |

### CI Health
| Workflow | Dernier run | Statut |
|----------|------------|--------|
| ci.yml | il y a 2h | Passe |

### Alertes
- [!] PR #456 en echec CI depuis 12h
- [!] Branch feature/old inactive depuis 3 semaines

---

## Synthese Cross-Repo

### A faire aujourd'hui
1. [Priorite haute] ...
2. [Priorite moyenne] ...

### Metriques
- Features livrees : X
- PRs a traiter : Y
- Echecs CI : Z
- Branches stales : W
```

### Vue resumee (`--summary-only`)

```markdown
# Standup Resume — YYYY-MM-DD

Hier : X features livrees, Y bugs corriges, Z PRs mergees.
Aujourd'hui : W PRs a reviewer, V echecs CI a corriger.
Blockers : [liste ou "aucun"].
```

## Degradation gracieuse

| Outil manquant | Impact | Fallback |
|----------------|--------|----------|
| `gh` non installe | Pas de PRs ni CI | Signaler, ne montrer que les commits |
| Repo distant inaccessible | Pas de status remote | Utiliser les donnees locales |
| Pas de commits recents | Section vide | Indiquer "Aucune activite" |

## Regles

- TOUJOURS utiliser des commandes en lecture seule (git log, git status, gh pr list)
- NE JAMAIS modifier de fichiers, branches, ou PRs
- NE JAMAIS inventer de donnees — si une source est indisponible, le signaler
- Indiquer clairement les lacunes de donnees
- Si `gh` n'est pas disponible, le mentionner et montrer ce qui est disponible
