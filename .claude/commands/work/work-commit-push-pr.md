# Agent WORK-COMMIT-PUSH-PR

Workflow complet: commit + push + PR en une seule commande. Inspire par le workflow de Boris Cherny (createur de Claude Code).

## Contexte
$ARGUMENTS

## Objectif

Executer le cycle complet de livraison en une seule commande:
1. Verifier les tests et le lint
2. Creer un commit propre (Conventional Commits)
3. Push sur la branche distante
4. Creer une Pull Request documentee

> "This is the command I run dozens of times every day." - Boris Cherny

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMMIT → PUSH → PR                           │
├─────────────────────────────────────────────────────────────────┤
│  1. VERIFY     →  2. COMMIT    →  3. PUSH    →  4. PR          │
│  Tests + Lint     Conventional    Remote        Documentation   │
│                   Commits                                       │
└─────────────────────────────────────────────────────────────────┘
```

## Phase 1: Verification

```bash
# Etat du repo
git status
git diff --stat

# Verifications qualite
npm test 2>&1 | tail -20 || echo "[WARN] Tests failed"
npm run lint 2>&1 | tail -10 || echo "[WARN] Lint failed"
npm run typecheck 2>&1 | tail -10 || echo "[WARN] Types failed"
```

### Checklist automatique
- [ ] Branche n'est pas main/master
- [ ] Pas de fichiers sensibles (.env, credentials)
- [ ] Tests passent
- [ ] Lint OK
- [ ] Pas de console.log de debug

## Phase 2: Commit

### Analyse des changements
```bash
# Commits recents pour le style
git log --oneline -5

# Fichiers modifies
git diff --name-status

# Contenu des changements
git diff --stat
```

### Format Conventional Commits

```
type(scope): description (<50 chars)

Corps optionnel (pourquoi, pas comment)

Refs #issue
```

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalite |
| `fix` | Correction de bug |
| `refactor` | Refactoring |
| `test` | Tests |
| `docs` | Documentation |
| `chore` | Maintenance |
| `perf` | Performance |

### Execution
```bash
git add <fichiers pertinents>
git commit -m "type(scope): description"
```

## Phase 3: Push

```bash
# Verifier la branche tracking
git branch -vv

# Push avec upstream si necessaire
git push -u origin $(git branch --show-current)
```

## Phase 4: Pull Request

### Template PR
```markdown
## Summary
- [Point cle 1]
- [Point cle 2]
- [Point cle 3]

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Refactoring

## Test plan
- [ ] Tests unitaires passes
- [ ] Tests d'integration passes
- [ ] Test manuel effectue

## Notes for reviewers
[Points d'attention pour la review]
```

### Creation avec gh CLI
```bash
gh pr create \
  --title "type(scope): description" \
  --body "$(cat <<'EOF'
## Summary
- ...

## Test plan
- [ ] ...
EOF
)"
```

## Commandes combinees

### Workflow standard
```bash
# Tout en une fois
git add . && \
git commit -m "feat(scope): description" && \
git push -u origin $(git branch --show-current) && \
gh pr create --title "feat(scope): description" --body "..."
```

### Avec verification
```bash
# Verifier d'abord
npm test && npm run lint && \
git add . && \
git commit -m "feat(scope): description" && \
git push && \
gh pr create --fill
```

## Options avancees

### Draft PR (WIP)
```bash
gh pr create --draft --title "WIP: feature in progress"
```

### Auto-assignation
```bash
gh pr create --assignee @me --reviewer team-lead
```

### Labels automatiques
```bash
gh pr create --label "feature,needs-review"
```

## Integration avec Plan Mode

Si vous avez utilise `/work:work-plan` avant:
1. Le plan documente les changements attendus
2. Verifier que l'implementation correspond au plan
3. Inclure le lien vers le plan dans la PR si pertinent

## Verification post-PR

Apres creation de la PR:
```bash
# Verifier le statut CI
gh pr checks

# Voir la PR creee
gh pr view --web
```

## Erreurs courantes

| Erreur | Solution |
|--------|----------|
| "No commits between main and X" | Verifier que vous avez bien commit |
| "Permission denied" | Configurer le GITHUB_TOKEN |
| "Branch already exists" | Push avec `--force` si necessaire |
| "PR already exists" | Utiliser `gh pr edit` |

## Agents lies

| Agent | Usage |
|-------|-------|
| `/work:work-explore` | Comprendre avant de commiter |
| `/work:work-plan` | Planifier avant d'implementer |
| `/qa:qa-review` | Self-review avant PR |
| `/qa:qa-security` | Verifier la securite |

---

IMPORTANT: Toujours verifier les tests avant de commit-push-pr.

YOU MUST utiliser Conventional Commits pour le message.

NEVER commiter sur main/master directement.

NEVER inclure de fichiers sensibles (.env, secrets).

Think hard sur le message de commit et le titre de la PR - ils seront lus par d'autres.
