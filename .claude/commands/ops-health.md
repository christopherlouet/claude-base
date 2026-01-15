# Agent HEALTH-CHECK

Vérification rapide de la santé d'un projet. Diagnostic express en 5 minutes.

## Contexte
$ARGUMENTS

## Diagnostic Express

Cet agent effectue une vérification rapide de :
1. État du projet
2. Dépendances
3. Tests
4. Sécurité de base
5. Dette technique

---

## 1. État du Projet

### 1.1 Structure

```bash
# Vue d'ensemble
ls -la
tree -L 2 -I 'node_modules|.git|dist|build|coverage' 2>/dev/null | head -30

# Git status
git status --short 2>/dev/null
git log --oneline -5 2>/dev/null
```

### 1.2 Checklist Structure

| Élément | Présent | État |
|---------|---------|------|
| README.md | ⬜ | |
| package.json / requirements.txt | ⬜ | |
| .gitignore | ⬜ | |
| Tests configurés | ⬜ | |
| Linting configuré | ⬜ | |
| CI/CD configuré | ⬜ | |

---

## 2. Dépendances

### 2.1 Audit rapide

```bash
# Audit npm
npm audit --audit-level=high 2>/dev/null | head -20

# Outdated
npm outdated 2>/dev/null | head -15
```

### 2.2 Résultat Dépendances

| Catégorie | Nombre |
|-----------|--------|
| Vulnérabilités critiques | |
| Vulnérabilités hautes | |
| Packages obsolètes (major) | |
| Packages obsolètes (minor) | |

### 2.3 Actions requises

- [ ] Vulnérabilités critiques à corriger immédiatement
- [ ] Mises à jour majeures à planifier

---

## 3. Tests

### 3.1 Exécution

```bash
# Lancer les tests
npm test 2>/dev/null || echo "Tests non configurés ou en échec"

# Couverture si disponible
npm run test:coverage 2>/dev/null | tail -20 || echo "Couverture non configurée"
```

### 3.2 Résultat Tests

| Métrique | Valeur |
|----------|--------|
| Tests passés | |
| Tests échoués | |
| Tests skippés | |
| Couverture globale | |

### 3.3 Santé des tests

- [ ] Tous les tests passent
- [ ] Couverture > 80%
- [ ] Pas de tests flaky

---

## 4. Sécurité de Base

### 4.1 Vérifications rapides

```bash
# Secrets dans le code
grep -rn "password\s*=\|secret\s*=\|api_key\s*=" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | grep -v node_modules | head -5

# Fichiers sensibles
ls -la .env* 2>/dev/null
cat .gitignore 2>/dev/null | grep -E "\.env|secret|credentials"
```

### 4.2 Checklist Sécurité

| Vérification | OK |
|--------------|---|
| Pas de secrets dans le code | ⬜ |
| .env dans .gitignore | ⬜ |
| HTTPS configuré | ⬜ |
| Dépendances sans vulnérabilités critiques | ⬜ |

---

## 5. Dette Technique

### 5.1 Indicateurs

```bash
# TODO/FIXME dans le code
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.js" --include="*.tsx" 2>/dev/null | wc -l

# Fichiers volumineux (>500 lignes)
find . -name "*.ts" -o -name "*.js" -o -name "*.tsx" 2>/dev/null | xargs wc -l 2>/dev/null | sort -n | tail -10
```

### 5.2 Résultat Dette

| Indicateur | Valeur | Seuil |
|------------|--------|-------|
| TODO/FIXME | | < 20 |
| Fichiers > 500 lignes | | 0 |
| Warnings lint | | 0 |
| Warnings TypeScript | | 0 |

---

## 6. Build & Lint

### 6.1 Vérifications

```bash
# Lint
npm run lint 2>/dev/null | tail -10 || echo "Lint non configuré"

# TypeScript
npm run typecheck 2>/dev/null || npx tsc --noEmit 2>/dev/null | tail -10 || echo "TypeScript non configuré"

# Build
npm run build 2>/dev/null | tail -5 || echo "Build non configuré"
```

### 6.2 Résultat Build

| Commande | Statut |
|----------|--------|
| Lint | ⬜ Pass / ❌ Fail / ⚠️ Warnings |
| TypeScript | ⬜ Pass / ❌ Fail / ⚠️ Warnings |
| Build | ⬜ Pass / ❌ Fail |

---

## Rapport Health-Check

### Score Santé Global

```
┌─────────────────────────────────────────────────┐
│              HEALTH CHECK                       │
├─────────────────────────────────────────────────┤
│                                                 │
│  Structure       [██████████] ✓                │
│  Dépendances     [████████░░] ⚠                │
│  Tests           [██████░░░░] ⚠                │
│  Sécurité        [█████████░] ✓                │
│  Dette Tech      [███████░░░] ⚠                │
│  Build           [██████████] ✓                │
│                                                 │
│  SANTÉ GLOBALE   [████████░░] BON              │
│                                                 │
│  ✓ OK  ⚠ Attention  ❌ Critique                │
└─────────────────────────────────────────────────┘
```

### Statut par Catégorie

| Catégorie | Statut | Note |
|-----------|--------|------|
| Structure | ✓ / ⚠ / ❌ | |
| Dépendances | ✓ / ⚠ / ❌ | |
| Tests | ✓ / ⚠ / ❌ | |
| Sécurité | ✓ / ⚠ / ❌ | |
| Dette Tech | ✓ / ⚠ / ❌ | |
| Build | ✓ / ⚠ / ❌ | |

### Problèmes Détectés

#### Critiques (❌)
| Problème | Action immédiate |
|----------|------------------|
| | |

#### Attention (⚠️)
| Problème | Action recommandée |
|----------|-------------------|
| | |

### Actions Immédiates

1. [ ] [Action prioritaire 1]
2. [ ] [Action prioritaire 2]
3. [ ] [Action prioritaire 3]

### Recommandations

| Priorité | Action | Impact |
|----------|--------|--------|
| Haute | | |
| Moyenne | | |
| Basse | | |

### Prochaines Étapes

Pour un diagnostic plus approfondi :
- `/security` - Audit sécurité complet
- `/perf` - Analyse performance détaillée
- `/deps` - Audit dépendances complet
- `/audit-full` - Audit qualité complet

---

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/audit` | Audit complet |
| `/monitoring` | Monitoring continu |
| `/security` | Audit sécurité |
| `/deps` | Mise à jour dépendances |
| `/perf` | Analyse performance |

---

IMPORTANT: Ce health-check est un diagnostic rapide. Pour un audit complet, utiliser `/audit`.

YOU MUST signaler immédiatement tout problème de sécurité critique (secrets exposés, vulnérabilités critiques).

NEVER ignorer les tests qui échouent - c'est un signal d'alerte important.

Think hard sur les priorités et fournir des actions concrètes.
