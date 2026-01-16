# Agent DEPS (Dépendances)

Audit, analyse et mise à jour des dépendances du projet.

## Cible
$ARGUMENTS

## Workflow d'Audit

### 1. État actuel des dépendances

#### Node.js / npm
```bash
# Voir les dépendances outdated
npm outdated

# Audit de sécurité
npm audit

# Arbre des dépendances
npm ls --depth=0
```

#### Python / pip
```bash
# Voir les outdated
pip list --outdated

# Audit de sécurité
pip-audit

# Ou avec safety
safety check
```

#### Go
```bash
# Voir les dépendances
go list -m all

# Vérifier les mises à jour
go list -m -u all

# Vulnérabilités
govulncheck ./...
```

#### Rust / Cargo
```bash
# Voir les outdated
cargo outdated

# Audit de sécurité
cargo audit
```

### 2. Catégorisation des mises à jour

| Catégorie | Risque | Action |
|-----------|--------|--------|
| Patch (x.x.X) | Faible | Mise à jour directe |
| Minor (x.X.0) | Moyen | Vérifier changelog |
| Major (X.0.0) | Élevé | Planifier migration |
| Security | Critique | Mise à jour immédiate |

### 3. Analyse des risques

Pour chaque dépendance majeure, vérifier :
- [ ] Changelog / Release notes
- [ ] Breaking changes documentés
- [ ] Issues ouvertes sur le repo
- [ ] Dernière activité du mainteneur
- [ ] Nombre de téléchargements / popularité

## Processus de Mise à Jour

### Mise à jour sécurisée

```bash
# 1. Créer une branche
git checkout -b deps/update-[date]

# 2. Mettre à jour une dépendance
npm update [package]  # ou
npm install [package]@latest

# 3. Lancer les tests
npm test

# 4. Vérifier le build
npm run build

# 5. Si OK, commit
git commit -m "chore(deps): update [package] to vX.Y.Z"
```

### Mise à jour par lots (patches)

```bash
# Mettre à jour tous les patches
npm update

# Vérifier
npm test && npm run build

# Commit
git commit -m "chore(deps): update patch versions"
```

### Migration majeure

1. Lire le guide de migration
2. Créer une branche dédiée
3. Appliquer les changements breaking
4. Mettre à jour les tests
5. Tester manuellement
6. Documenter les changements

## Bonnes Pratiques

### Dépendances à surveiller
- [ ] Framework principal (React, Vue, Express, etc.)
- [ ] ORM / Database driver
- [ ] Authentification / Sécurité
- [ ] Build tools (webpack, vite, etc.)

### Dépendances à éviter
- Packages non maintenus (>1 an sans commit)
- Packages avec vulnérabilités non corrigées
- Packages avec trop de dépendances transitives
- Packages sans tests ou documentation

### Lockfile
- IMPORTANT: Toujours commiter le lockfile (package-lock.json, yarn.lock, etc.)
- IMPORTANT: Utiliser `npm ci` en CI (pas `npm install`)

## Automatisation

### Dependabot (GitHub)
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      dev-dependencies:
        dependency-type: "development"
      prod-dependencies:
        dependency-type: "production"
    commit-message:
      prefix: "chore(deps)"
```

### Renovate
```json
// renovate.json
{
  "extends": ["config:base"],
  "packageRules": [
    {
      "matchUpdateTypes": ["patch"],
      "automerge": true
    }
  ],
  "schedule": ["every weekend"]
}
```

## Output attendu

### Rapport d'audit
```
## Audit des dépendances - [date]

### Résumé
- Total: X dépendances
- À jour: X
- Outdated: X
- Vulnérabilités: X

### Vulnérabilités critiques
| Package | Sévérité | Version actuelle | Version fixée |
|---------|----------|------------------|---------------|
| lodash  | High     | 4.17.19          | 4.17.21       |

### Mises à jour recommandées

#### Priorité haute (sécurité)
- [ ] package1: 1.0.0 → 1.0.5 (security fix)

#### Priorité moyenne (minor)
- [ ] package2: 2.1.0 → 2.3.0 (new features)

#### Priorité basse (major - planifier)
- [ ] package3: 3.0.0 → 4.0.0 (breaking changes)

### Actions recommandées
1. Mettre à jour immédiatement: [liste]
2. Planifier migration: [liste]
3. Surveiller: [liste]
```

### Commandes suggérées
```bash
# Corrections de sécurité
npm audit fix

# Mises à jour mineures
npm update package1 package2

# Migration majeure (à planifier)
npm install package3@latest
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/security` | Audit vulnérabilités |
| `/test` | Tester après mise à jour |
| `/migrate` | Migration majeure |
| `/ci` | Automatiser les updates |
| `/audit` | Audit qualité complet |

---

IMPORTANT: Toujours lancer les tests après une mise à jour.

IMPORTANT: Ne jamais mettre à jour en production sans tests.

YOU MUST vérifier le changelog avant une mise à jour majeure.

NEVER ignorer les vulnérabilités de sécurité - elles sont prioritaires.
