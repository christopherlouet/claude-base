# Agent GITFLOW-INIT

Initialiser GitFlow sur le repository.

## Contexte
$ARGUMENTS

## Objectif

Configurer le repository pour utiliser GitFlow avec les branches et conventions appropriées.

## Structure GitFlow

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   main (production)                                             │
│     │                                                           │
│     ├──────────────────────────────────────────────────────────▶│
│     │                         ▲              ▲                  │
│     │                         │              │                  │
│     │                    merge│         merge│                  │
│     │                         │              │                  │
│   develop ◀───────────────────┼──────────────┤                  │
│     │                         │              │                  │
│     ├──▶ feature/xxx ─────────┘              │                  │
│     │                                        │                  │
│     ├──▶ release/vX.X.X ─────────────────────┤                  │
│     │                         │              │                  │
│   main ◀──────────────────────┴── hotfix/xxx─┘                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Branches GitFlow

| Branche | Rôle | Durée de vie |
|---------|------|--------------|
| `main` | Production stable, tags de release | Permanente |
| `develop` | Intégration des features | Permanente |
| `feature/*` | Nouvelles fonctionnalités | Temporaire |
| `release/*` | Préparation d'une release | Temporaire |
| `hotfix/*` | Corrections urgentes production | Temporaire |

## Processus d'initialisation

### 1. Vérification des prérequis

```bash
# Vérifier qu'on est dans un repo git
git rev-parse --git-dir

# Vérifier la branche actuelle
git branch --show-current

# Vérifier s'il y a des modifications non commitées
git status --porcelain
```

### 2. Création de la branche develop

```bash
# Si develop n'existe pas, la créer depuis main
git checkout main
git pull origin main
git checkout -b develop
git push -u origin develop
```

### 3. Configuration Git (optionnel)

```bash
# Configurer les préfixes de branches (convention)
git config gitflow.branch.master main
git config gitflow.branch.develop develop
git config gitflow.prefix.feature feature/
git config gitflow.prefix.release release/
git config gitflow.prefix.hotfix hotfix/
git config gitflow.prefix.support support/
git config gitflow.prefix.versiontag v
```

### 4. Protection des branches (recommandé)

Recommander la configuration sur GitHub/GitLab :

- **main** : Protection totale, merge uniquement via PR avec review
- **develop** : Protection, merge via PR

## Output attendu

### 1. Exécuter les commandes d'initialisation

```bash
# Créer develop si elle n'existe pas
git checkout main
git pull origin main 2>/dev/null || true
git checkout -b develop 2>/dev/null || git checkout develop
git push -u origin develop 2>/dev/null || true
```

### 2. Afficher le résumé

```markdown
## GitFlow initialisé

### Branches configurées
- `main` - Production (existante)
- `develop` - Développement (créée/existante)

### Préfixes de branches
| Type | Préfixe | Exemple |
|------|---------|---------|
| Feature | `feature/` | `feature/user-auth` |
| Release | `release/` | `release/v1.2.0` |
| Hotfix | `hotfix/` | `hotfix/critical-bug` |

### Commandes disponibles
| Action | Commande |
|--------|----------|
| Nouvelle feature | `/ops-gitflow-feature start "nom"` |
| Terminer feature | `/ops-gitflow-feature finish "nom"` |
| Nouvelle release | `/ops-gitflow-release start "v1.2.0"` |
| Terminer release | `/ops-gitflow-release finish "v1.2.0"` |
| Hotfix urgent | `/ops-gitflow-hotfix start "nom"` |
| Terminer hotfix | `/ops-gitflow-hotfix finish "nom"` |

### Workflow recommandé
1. Développer sur `feature/*` depuis `develop`
2. Merger les features dans `develop` via PR
3. Créer `release/*` depuis `develop` pour préparer une version
4. Merger `release/*` dans `main` ET `develop`
5. Tagger la release sur `main`
6. Hotfixes depuis `main`, merger dans `main` ET `develop`
```

## Vérifications de sécurité

- IMPORTANT: Ne jamais forcer le push sur `main` ou `develop`
- IMPORTANT: Toujours vérifier qu'il n'y a pas de modifications non commitées
- IMPORTANT: Synchroniser avec le remote avant toute opération

## Commandes liées

| Commande | Usage |
|----------|-------|
| `/ops-gitflow-feature` | Gérer les branches feature |
| `/ops-gitflow-release` | Gérer les branches release |
| `/ops-gitflow-hotfix` | Gérer les hotfixes |

---

IMPORTANT: Vérifier que le repo est propre avant d'initialiser.

YOU MUST créer la branche develop si elle n'existe pas.

YOU MUST afficher un résumé clair des branches et commandes disponibles.

NEVER forcer le push ou supprimer des branches sans confirmation.
