---
name: ops-ci-fix
description: Diagnostic et reparation autonome des pipelines CI/CD en echec. Scanner les workflows GitHub Actions, identifier les causes de failure, et appliquer des fixes. Declencher quand la CI est cassee, les tests echouent en CI, ou les workflows sont bloques.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
model: sonnet
argument-hint: "[workflow-name] [--dry-run]"
---

# CI Fixer — Diagnostic et Reparation CI/CD

## Objectif

Diagnostiquer les pipelines CI/CD en echec, identifier la cause racine,
et appliquer des corrections automatiques quand c'est safe.

## Phase 1 : Decouverte et etat des workflows

### Scanner les workflows

```bash
# Lister les derniers runs
gh run list --limit 20 --json databaseId,status,conclusion,name,createdAt,headBranch

# Identifier les fichiers de workflow
ls -la .github/workflows/
```

### Classifier l'etat

| Etat | Critere | Urgence |
|------|---------|---------|
| **En echec** | conclusion = failure | Haute |
| **Bloque** | status = in_progress depuis > 30 min | Haute |
| **Annule** | conclusion = cancelled (recurrent) | Moyenne |
| **Stale** | Pas de run reussi depuis 7+ jours | Basse |

### Verifier les runners (si self-hosted)

```bash
# Statut des runners
gh api repos/{owner}/{repo}/actions/runners --jq '.runners[] | {name, status, busy}'
```

## Phase 2 : Diagnostic des echecs

Pour chaque workflow en echec :

### 2.1 Extraire les logs

```bash
# Logs du run en echec
gh run view <run-id> --log-failed
```

### 2.2 Classifier la cause

| Categorie | Patterns dans les logs | Fix typique |
|-----------|----------------------|-------------|
| **Test failure** | `FAIL`, `AssertionError`, `expect(` | Fix le test ou le code |
| **Build error** | `error TS`, `SyntaxError`, `cannot find` | Fix l'erreur de compilation |
| **Dep install** | `npm ERR!`, `ERESOLVE`, `peer dep` | Fix package.json / lockfile |
| **Auth/secrets** | `401`, `403`, `secret not found` | Verifier les secrets configurees |
| **Timeout** | `timed out`, `exceeded deadline` | Augmenter timeout ou optimiser |
| **Disk space** | `no space left`, `ENOSPC` | Nettoyer caches / reduire artefacts |
| **Rate limit** | `rate limit`, `429` | Ajouter retry / espacer les requetes |
| **Runner offline** | `no runner matching`, `offline` | Verifier runners self-hosted |
| **Flaky test** | Passe parfois, echoue parfois | Identifier le test flaky, stabiliser |
| **Config error** | `invalid workflow`, `syntax error` | Fix le YAML du workflow |

### 2.3 Distinguer erreur locale vs CI-only

```bash
# Reproduire localement
npm test          # ou pytest, go test, etc.
npm run build
npm run lint
```

Si ca passe localement mais echoue en CI : probleme d'environnement (versions, secrets, cache).

## Phase 3 : Reparation

### Ordre de priorite des fixes (du plus safe au plus risque)

1. **Re-run** : workflows flaky → `gh run rerun <run-id>`
2. **Fix config** : YAML invalide → editer `.github/workflows/`
3. **Fix deps** : lockfile corrompu → `rm -rf node_modules package-lock.json && npm install`
4. **Fix tests** : test cassant → identifier et corriger
5. **Fix build** : erreur de compilation → corriger le code source
6. **Cancel stuck** : workflows bloques → `gh run cancel <run-id>`

### Garde-fous

IMPORTANT: En mode `--dry-run`, montrer les actions proposees SANS les executer.

| Action | Safe | Confirmation requise |
|--------|------|---------------------|
| Re-run un workflow | Oui | Non |
| Cancel un run bloque | Oui | Non |
| Fix YAML workflow | Moyen | Montrer le diff avant |
| Regenerer lockfile | Moyen | Montrer le diff avant |
| Modifier du code source | Risque | Oui — proposer, ne pas appliquer sans accord |
| Modifier des secrets | Risque | Jamais — guider l'utilisateur |

### Application des fixes

Pour chaque fix applicable :

1. Identifier la cause racine precise (pas le symptome)
2. Proposer le fix minimal
3. Appliquer si safe, sinon montrer et attendre confirmation
4. Verifier le fix : relancer le workflow ou les tests localement

## Phase 4 : Verification

Apres les fixes :

```bash
# Verifier que les tests passent localement
npm test && npm run build && npm run lint

# Si un workflow a ete re-run, verifier son statut
gh run view <run-id> --json status,conclusion
```

### Boucle de validation (max 2 iterations)

1. Appliquer le fix
2. Verifier (tests locaux + re-run CI si possible)
3. Si encore en echec : re-diagnostiquer avec les nouveaux logs
4. Si 2 iterations echouent : escalader avec un rapport detaille

## Phase 5 : Rapport

```markdown
# CI Fix Report — YYYY-MM-DD

## Workflows analyses
| Workflow | Branche | Statut avant | Cause | Action | Statut apres |
|----------|---------|-------------|-------|--------|-------------|
| ci.yml | main | Echec | Test failure | Fix test | Passe |
| deploy.yml | main | Bloque | Timeout | Cancel + re-run | En cours |

## Fixes appliques
1. [Fix 1] : description, fichier modifie, raison
2. [Fix 2] : ...

## Actions manuelles requises
- [ ] Configurer le secret `DEPLOY_TOKEN` (expire)
- [ ] Mettre a jour le runner self-hosted v2.x → v3.x

## Recommandations
- Ajouter un cache pour npm ci (reduirait le temps de 3 min)
- Le test `auth.spec.ts` est flaky (3 echecs sur 10 runs)
```

## Regles

- TOUJOURS diagnostiquer avant de corriger (Phase 2 avant Phase 3)
- NE JAMAIS modifier des secrets — guider l'utilisateur
- NE JAMAIS force-push ou modifier l'historique git
- TOUJOURS montrer le diff des modifications de workflow avant d'appliquer
- En cas de doute, proposer le fix sans l'appliquer
- Respecter la regle des 3 echecs : apres 2 iterations de fix echouees, escalader
