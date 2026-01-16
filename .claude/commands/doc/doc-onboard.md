# Agent ONBOARD

Onboarding rapide sur un codebase inconnu.

## Projet ou zone à explorer
$ARGUMENTS

## Processus d'onboarding

### 1. Vue d'ensemble (5 min)
```bash
# Structure du projet
ls -la
tree -L 2 -I 'node_modules|.git|dist|build'

# Fichiers de configuration
cat package.json  # ou requirements.txt, Cargo.toml, etc.
cat README.md
```

#### Questions à répondre :
- Quel type de projet ? (frontend, backend, fullstack, lib)
- Quel(s) langage(s) / framework(s) ?
- Comment lancer le projet ?
- Comment lancer les tests ?

### 2. Architecture (10 min)

#### Identifier les couches
- [ ] Entry points (main, index, app)
- [ ] Routes / Controllers
- [ ] Services / Business logic
- [ ] Data access / Models
- [ ] Utilitaires / Helpers

#### Identifier les patterns
- [ ] Architecture (MVC, Clean, Hexagonal, etc.)
- [ ] State management
- [ ] Error handling
- [ ] Logging
- [ ] Configuration

### 3. Flux de données (10 min)

#### Tracer un flux complet
1. Entrée utilisateur / Requête API
2. Validation
3. Traitement métier
4. Accès données
5. Réponse

#### Identifier les dépendances
- Services externes (APIs, DBs)
- Librairies clés
- Configuration requise

### 4. Conventions du projet (5 min)

- [ ] Style de code (linter config)
- [ ] Conventions de nommage
- [ ] Structure des tests
- [ ] Format des commits
- [ ] Process de review

### 5. Points d'attention

#### Dette technique potentielle
- Code dupliqué
- Tests manquants
- TODO/FIXME dans le code
- Dépendances obsolètes

#### Zones sensibles
- Authentification / Autorisation
- Paiements / Transactions
- Données personnelles

## Output attendu

### Résumé du projet
```
Nom: [nom]
Type: [frontend/backend/fullstack/lib]
Stack: [langages et frameworks]
Architecture: [pattern principal]
```

### Comment démarrer
```bash
# Installation
[commandes]

# Lancement
[commandes]

# Tests
[commandes]
```

### Structure clé
```
/src
├── [dossier1]  # [description]
├── [dossier2]  # [description]
└── [dossier3]  # [description]
```

### Points d'entrée importants
- `[fichier1]` - [rôle]
- `[fichier2]` - [rôle]

### Dépendances critiques
- `[dep1]` - [usage]
- `[dep2]` - [usage]

### Prochaines étapes recommandées
1. [Suggestion 1]
2. [Suggestion 2]
3. [Suggestion 3]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/explore` | Explorer en profondeur |
| `/explain` | Comprendre du code spécifique |
| `/health` | Évaluer la santé du projet |
| `/readme` | Consulter/créer le README |

---

IMPORTANT: Commencer par le README et les fichiers de config avant de plonger dans le code.

YOU MUST comprendre l'architecture avant de modifier du code.

NEVER modifier du code sans avoir compris le contexte.

Think hard sur l'architecture globale avant de plonger dans les détails.
