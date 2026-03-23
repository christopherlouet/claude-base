---
name: work-batch
description: Execution sequentielle de user stories depuis un fichier PRD. Mode autonome qui implemente et commit chaque story une par une. Declencher quand l'utilisateur veut traiter un backlog, executer plusieurs stories, ou lancer un mode autonome.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
model: sonnet
argument-hint: "[chemin-vers-prd.json ou prd.md]"
---

# Batch Execution Mode

Execution autonome et sequentielle de user stories depuis un fichier PRD.

## Format du fichier PRD

### JSON (`prd.json`)

```json
{
  "project": "nom-du-projet",
  "stories": [
    {
      "id": "US-001",
      "title": "Titre de la story",
      "description": "Description detaillee",
      "priority": "P1",
      "acceptance_criteria": [
        "Given X, When Y, Then Z"
      ],
      "files": ["src/module.ts", "src/module.test.ts"]
    }
  ]
}
```

### Markdown (`prd.md`)

```markdown
## US-001: Titre de la story
**Priority**: P1
**Description**: Description detaillee
**Acceptance criteria**:
- Given X, When Y, Then Z
**Files**: src/module.ts, src/module.test.ts
```

## Workflow par story

Pour chaque story dans l'ordre de priorite (P1 → P2 → P3) :

### 1. LOAD - Charger la story

- Lire la story depuis le fichier PRD
- Afficher le titre et la description
- Verifier les pre-requis (fichiers, dependances)

### 2. IMPLEMENT - Cycle TDD

- Ecrire les tests d'abord (RED)
- Implementer le code minimal (GREEN)
- Refactorer si necessaire (REFACTOR)
- Verifier les criteres d'acceptation

### 3. COMMIT - Sauvegarder

- Lancer les tests : `npm test` / `pytest` / `go test`
- Si tests OK : commit avec `feat(scope): US-XXX description`
- Si tests KO : STOP et signaler le blocage

### 4. REPORT - Mettre a jour l'etat

- Marquer la story comme terminee dans `.claude/output/batch/progress.json`
- Logger le temps et les fichiers modifies
- Passer a la story suivante

## Fichier de progression

Sauvegarde automatique dans `.claude/output/batch/progress.json` :

```json
{
  "started_at": "2026-03-23T10:00:00Z",
  "stories": {
    "US-001": { "status": "done", "commit": "abc1234", "files": ["..."] },
    "US-002": { "status": "in_progress" },
    "US-003": { "status": "pending" }
  }
}
```

## Resume apres interruption

Si `progress.json` existe, reprendre a la derniere story `in_progress` ou `pending`.

## Garde-fous

- Maximum 10 stories par batch (au-dela, decouper)
- STOP si 2 stories consecutives echouent
- Chaque story doit passer les tests avant de continuer
- Commit apres chaque story (pas de commit geant)

---

IMPORTANT: Chaque story est un commit atomique. Ne pas accumuler les changements.

NEVER continuer si les tests echouent sur une story.

YOU MUST sauvegarder la progression dans `.claude/output/batch/progress.json`.
