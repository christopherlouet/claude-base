# Agent GITFLOW-FEATURE

Gérer les branches feature avec GitFlow.

## Contexte
$ARGUMENTS

## Objectif

Créer, développer et finaliser des branches feature selon le workflow GitFlow.

## Workflow Feature

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   develop ────────────────────────────────────────────────────▶ │
│       │                                           ▲             │
│       │ checkout -b                               │ merge       │
│       ▼                                           │             │
│   feature/xxx ────────────────────────────────────┘             │
│       │                                                         │
│       ├── commit 1                                              │
│       ├── commit 2                                              │
│       └── commit N                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Actions disponibles

### START - Créer une nouvelle feature

**Syntaxe**: `/ops-gitflow-feature start "nom-de-la-feature"`

```bash
# 1. S'assurer d'être à jour sur develop
git checkout develop
git pull origin develop

# 2. Créer la branche feature
git checkout -b feature/nom-de-la-feature

# 3. Pousser la branche
git push -u origin feature/nom-de-la-feature
```

**Output attendu**:
```markdown
## Feature créée

**Branche**: `feature/nom-de-la-feature`
**Base**: `develop`

### Prochaines étapes
1. Développer la feature avec des commits atomiques
2. Pousser régulièrement : `git push`
3. Quand terminé : `/ops-gitflow-feature finish "nom-de-la-feature"`

### Commandes utiles
- `/dev-tdd` - Développer en TDD
- `/work-commit` - Créer des commits propres
- `/qa-review` - Vérifier la qualité avant finish
```

### FINISH - Terminer une feature

**Syntaxe**: `/ops-gitflow-feature finish "nom-de-la-feature"`

```bash
# 1. S'assurer que tout est commité
git status --porcelain

# 2. Mettre à jour develop
git checkout develop
git pull origin develop

# 3. Merger la feature dans develop
git merge --no-ff feature/nom-de-la-feature -m "Merge feature/nom-de-la-feature into develop"

# 4. Pousser develop
git push origin develop

# 5. Supprimer la branche feature (locale et remote)
git branch -d feature/nom-de-la-feature
git push origin --delete feature/nom-de-la-feature
```

**Output attendu**:
```markdown
## Feature terminée

**Branche**: `feature/nom-de-la-feature`
**Mergée dans**: `develop`
**Branche supprimée**: Oui

### Résumé des commits mergés
- [hash] commit message 1
- [hash] commit message 2
- [hash] commit message N

### Prochaines étapes
- Continuer le développement sur `develop`
- Ou créer une nouvelle feature : `/ops-gitflow-feature start "autre-feature"`
- Préparer une release : `/ops-gitflow-release start "vX.X.X"`
```

### LIST - Lister les features en cours

**Syntaxe**: `/ops-gitflow-feature list`

```bash
git branch -a | grep feature/
```

### PUBLISH - Publier une feature (pour collaboration)

**Syntaxe**: `/ops-gitflow-feature publish "nom-de-la-feature"`

```bash
git push -u origin feature/nom-de-la-feature
```

### PULL - Récupérer une feature distante

**Syntaxe**: `/ops-gitflow-feature pull "nom-de-la-feature"`

```bash
git fetch origin feature/nom-de-la-feature
git checkout feature/nom-de-la-feature
```

## Détection de l'action

Analyser `$ARGUMENTS` pour déterminer l'action :

| Pattern | Action |
|---------|--------|
| `start "xxx"` ou `start xxx` | Créer feature/xxx |
| `finish "xxx"` ou `finish xxx` | Terminer feature/xxx |
| `list` | Lister les features |
| `publish "xxx"` | Publier feature/xxx |
| `pull "xxx"` | Récupérer feature/xxx |
| (nom seul) | Demander l'action souhaitée |

## Conventions de nommage

| Bon | Mauvais |
|-----|---------|
| `feature/user-authentication` | `feature/UserAuthentication` |
| `feature/add-payment-gateway` | `feature/add payment` |
| `feature/issue-123-fix-login` | `feature/123` |

- Utiliser kebab-case
- Être descriptif mais concis
- Préfixer avec le numéro d'issue si applicable

## Vérifications de sécurité

Avant **start** :
- [ ] Branche develop à jour
- [ ] Pas de modifications non commitées
- [ ] Nom de branche valide (pas d'espaces, caractères spéciaux)

Avant **finish** :
- [ ] Tous les changements commités
- [ ] Tests passent
- [ ] Code review effectuée (recommandé)
- [ ] Pas de conflits avec develop

## Gestion des conflits

Si des conflits surviennent lors du merge :

```bash
# 1. Résoudre les conflits dans les fichiers marqués
# 2. Ajouter les fichiers résolus
git add .
# 3. Terminer le merge
git commit
# 4. Continuer le finish
git push origin develop
```

## Commandes liées

| Avant | Commande | Après |
|-------|----------|-------|
| `/ops-gitflow-init` | | |
| | **FEATURE** | |
| | | `/ops-gitflow-release` |
| | | `/work-commit` |
| | | `/work-pr` |

---

IMPORTANT: Toujours partir de develop pour créer une feature.

YOU MUST vérifier que develop est à jour avant de créer ou finir une feature.

YOU MUST utiliser --no-ff pour le merge afin de préserver l'historique.

NEVER supprimer une branche feature sans avoir mergé les changements.

NEVER forcer le push sur develop.
