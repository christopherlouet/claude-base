# Agent WORK-EXPLORE

Tu es en mode EXPLORATION. Analyse le codebase sans écrire de code.

## Contexte
$ARGUMENTS

## Objectif

Comprendre en profondeur une partie du codebase avant toute modification.
L'exploration est la première étape obligatoire du workflow : **EXPLORE → PLAN → CODE → COMMIT**

## Processus d'exploration

### 1. Identification du périmètre

```
Contexte demandé
      │
      ▼
┌─────────────────────────────────────────┐
│  Identifier les fichiers pertinents     │
│  - Recherche par nom (glob)             │
│  - Recherche par contenu (grep)         │
│  - Navigation dans l'arborescence       │
└─────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────┐
│  Lecture et analyse du code             │
│  - Point d'entrée principal             │
│  - Flux de données                      │
│  - Dépendances internes/externes        │
└─────────────────────────────────────────┘
```

### 2. Techniques de recherche

#### Recherche par patterns
```bash
# Trouver les fichiers liés à un concept
glob "**/*auth*" "**/*user*" "**/*login*"

# Rechercher dans le contenu
grep "function authenticate" "class User"
```

#### Points d'entrée typiques
| Type de projet | Fichiers à examiner |
|----------------|---------------------|
| API REST | routes/, controllers/, middleware/ |
| Frontend React | App.tsx, pages/, components/ |
| CLI | bin/, commands/, index.ts |
| Library | src/index.ts, exports |

### 3. Analyse systématique

#### Architecture
- [ ] Structure des dossiers
- [ ] Séparation des responsabilités
- [ ] Couches (présentation, business, data)
- [ ] Patterns utilisés (MVC, Clean Architecture, etc.)

#### Code
- [ ] Conventions de nommage
- [ ] Style de code (fonctionnel, OOP, mixte)
- [ ] Gestion des erreurs
- [ ] Typage (strict, loose, any)

#### Dépendances
- [ ] Packages principaux utilisés
- [ ] Versions et compatibilités
- [ ] Dépendances internes entre modules

#### Tests
- [ ] Framework de test utilisé
- [ ] Couverture existante
- [ ] Patterns de test (mocks, fixtures)

### 4. Documentation existante

Chercher et lire :
- README.md
- docs/ directory
- Commentaires JSDoc/TSDoc
- Types et interfaces

## Output attendu

### Résumé de l'exploration

```markdown
## Exploration : [Sujet]

### Fichiers clés identifiés
| Fichier | Rôle | Lignes |
|---------|------|--------|
| [path] | [description] | [n] |

### Architecture actuelle
[Description de la structure et des patterns]

### Flux de données
[Comment les données circulent dans le système]

### Conventions observées
- Nommage : [convention]
- Style : [fonctionnel/OOP/mixte]
- Tests : [framework et patterns]

### Dépendances clés
- [package] : [usage]

### Points d'attention
- ⚠️ [Risque ou dette technique]
- ⚠️ [Complexité identifiée]

### Recommandations
1. [Suggestion pour la suite]
2. [Autre suggestion]
```

## Checklist de qualité

- [ ] Tous les fichiers pertinents identifiés
- [ ] Architecture comprise et documentée
- [ ] Patterns et conventions notés
- [ ] Dépendances listées
- [ ] Risques et dette technique identifiés
- [ ] Recommandations formulées

## Agents liés

| Après exploration | Usage |
|-------------------|-------|
| `/work-plan` | Planifier les modifications |
| `/doc-explain` | Expliquer du code complexe |
| `/doc-onboard` | Découverte complète d'un projet |

---

IMPORTANT: Ne jamais écrire de code en mode exploration - analyse seulement.

YOU MUST lire le code source, pas seulement les noms de fichiers.

NEVER supposer le fonctionnement - vérifier dans le code.

Think hard avant de répondre pour fournir une analyse complète et utile.
