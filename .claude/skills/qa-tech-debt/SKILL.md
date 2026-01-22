---
name: qa-tech-debt
description: Gestion et priorisation de la dette technique. Declencher quand l'utilisateur veut identifier, prioriser ou planifier le remboursement de la dette technique.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
context: fork
---

# Tech Debt Management

## Declencheurs

- "dette technique"
- "tech debt"
- "refactoring priorite"
- "code legacy"
- "qualite du code"

## Identification

### Code Smells a Detecter

```bash
# TODOs et FIXMEs
grep -r "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" src/

# Fichiers volumineux
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -n | tail -20

# Complexite (nesting)
grep -r "if.*if.*if" --include="*.ts" src/

# any en TypeScript
grep -r ": any" --include="*.ts" --include="*.tsx" src/
```

### Metriques

| Metrique | Seuil | Commande |
|----------|-------|----------|
| LOC/fichier | < 500 | `wc -l` |
| Fonctions/fichier | < 15 | grep |
| Depth nesting | < 4 | analyse |
| Test coverage | > 70% | `npm test -- --coverage` |

## Categorisation

### Impact

| Niveau | Description | Exemples |
|--------|-------------|----------|
| Critique | Bloque le developpement | Couplage circulaire |
| Eleve | Ralentit significativement | Duplication massive |
| Moyen | Gene la maintenance | Nommage confus |
| Faible | Cosmetique | Style inconsistant |

### Effort

| Niveau | Temps | Exemples |
|--------|-------|----------|
| Trivial | < 1h | Renommer variable |
| Faible | < 1 jour | Extraire fonction |
| Moyen | 1-5 jours | Restructurer module |
| Eleve | > 1 semaine | Rewrite composant |

## Priorisation

### Matrice Impact/Effort

```
Impact
  ^
  |  Quick Wins  |  Strategic
  |     (P1)     |    (P2)
  +--------------+-------------
  |   Fill-in    |   Avoid
  |     (P3)     |    (P4)
  +-------------------------> Effort
```

## Plan de Remediation

### Template

```markdown
## Item: [Nom]

**Priorite**: P[1-4]
**Impact**: [Critique/Eleve/Moyen/Faible]
**Effort**: [Trivial/Faible/Moyen/Eleve]

### Description
[Description du probleme]

### Fichiers concernes
- path/to/file.ts:L42

### Solution proposee
[Approche de refactoring]

### Criteres de succes
- [ ] Tests passent
- [ ] Pas de regression
- [ ] Metriques ameliorees
```

## Workflow

1. **Identifier** - Scanner le codebase
2. **Categoriser** - Impact et effort
3. **Prioriser** - Matrice de decision
4. **Planifier** - Integrer au backlog
5. **Executer** - Refactoring incremental
6. **Valider** - Tests et metriques
