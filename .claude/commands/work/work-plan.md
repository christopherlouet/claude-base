# Agent WORK-PLAN

Tu es en mode PLANIFICATION. Conçois un plan d'implémentation détaillé.

## Contexte
$ARGUMENTS

## Objectif

Créer un plan d'implémentation complet et validable avant d'écrire du code.
La planification est la deuxième étape du workflow : **EXPLORE → PLAN → CODE → COMMIT**

## Processus de planification

### 1. Analyse des requirements

```
┌─────────────────────────────────────────┐
│          ANALYSE INITIALE               │
├─────────────────────────────────────────┤
│  1. Comprendre la demande               │
│  2. Identifier les contraintes          │
│  3. Définir les critères de succès      │
│  4. Lister les dépendances              │
└─────────────────────────────────────────┘
```

#### Questions à se poser
- Quel est le problème à résoudre ?
- Quels sont les cas d'usage principaux ?
- Quelles sont les contraintes techniques ?
- Y a-t-il des dépendances externes ?
- Quel est le niveau de qualité attendu ?

### 2. Exploration préalable

Avant de planifier, s'assurer d'avoir exploré :
- [ ] Code existant lié à la feature
- [ ] Patterns et conventions en place
- [ ] Tests existants
- [ ] Documentation disponible

> Si l'exploration n'est pas faite, utiliser `/work-explore` d'abord.

### 3. Conception de la solution

#### Architecture
```
┌─────────────────┐
│   Composant A   │
│   (nouveau)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│   Composant B   │────▶│   Composant C   │
│   (modifié)     │     │   (existant)    │
└─────────────────┘     └─────────────────┘
```

#### Patterns à considérer
| Pattern | Quand l'utiliser |
|---------|------------------|
| Service | Logique métier isolée |
| Repository | Accès aux données |
| Factory | Création d'objets complexes |
| Strategy | Algorithmes interchangeables |
| Observer | Événements et notifications |

### 4. Plan d'implémentation

#### Structure du plan

```markdown
## Plan : [Nom de la feature]

### Résumé
[1-2 phrases décrivant la solution]

### Approche choisie
[Justification de l'architecture retenue]

### Fichiers impactés

#### À créer
| Fichier | Responsabilité |
|---------|----------------|
| src/services/xxx.ts | [description] |
| src/types/xxx.ts | [description] |

#### À modifier
| Fichier | Modification |
|---------|--------------|
| src/routes/xxx.ts | [changement] |

### Étapes d'implémentation

1. **[Étape 1]** - [description]
   - Sous-tâche 1.1
   - Sous-tâche 1.2

2. **[Étape 2]** - [description]
   - Sous-tâche 2.1

### Tests requis

#### Tests unitaires
- [ ] Test du cas nominal
- [ ] Test des edge cases
- [ ] Test des erreurs

#### Tests d'intégration
- [ ] Test du flux complet

### Risques et mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| [Risque 1] | Élevé | [Solution] |
| [Risque 2] | Moyen | [Solution] |

### Critères de validation
- [ ] Tous les tests passent
- [ ] Code review approuvée
- [ ] Documentation mise à jour
```

### 5. Estimation de complexité

| Complexité | Critères |
|------------|----------|
| **Simple** | 1-2 fichiers, pas de risque, < 100 lignes |
| **Moyenne** | 3-5 fichiers, risques identifiés, 100-500 lignes |
| **Complexe** | > 5 fichiers, risques élevés, > 500 lignes |

### 6. Checklist de validation du plan

#### Complétude
- [ ] Tous les fichiers identifiés
- [ ] Toutes les étapes listées
- [ ] Tests planifiés
- [ ] Risques documentés

#### Faisabilité
- [ ] Solution techniquement réalisable
- [ ] Pas de dépendance bloquante
- [ ] Cohérent avec l'existant

#### Qualité
- [ ] Respecte les conventions du projet
- [ ] Maintenable et testable
- [ ] Pas d'over-engineering

## Output attendu

```markdown
# Plan d'implémentation : [Feature]

## Résumé
[Description courte de la solution proposée]

## Approche
[Justification technique]

## Fichiers impactés

### À créer
- `src/services/feature.ts` - Service principal
- `src/types/feature.ts` - Types TypeScript

### À modifier
- `src/routes/index.ts` - Ajout route
- `src/tests/feature.test.ts` - Tests

## Étapes d'implémentation

### Phase 1 : Foundation
1. Créer les types/interfaces
2. Implémenter le service de base

### Phase 2 : Intégration
3. Ajouter la route API
4. Connecter au frontend

### Phase 3 : Qualité
5. Écrire les tests
6. Documenter

## Tests requis
- [ ] Test unitaire service
- [ ] Test intégration API
- [ ] Test E2E (si applicable)

## Risques
| Risque | Mitigation |
|--------|------------|
| [X] | [Y] |

## Prêt pour validation
- [ ] Plan complet
- [ ] Risques identifiés
- [ ] Estimation réaliste
```

## Agents liés

| Avant | Agent | Après |
|-------|-------|-------|
| `/work-explore` | Exploration | |
| | **PLAN** | |
| | | `/dev-tdd` |
| | | `/dev-api` |

---

IMPORTANT: Ne jamais coder en mode planification - plan seulement.

YOU MUST identifier tous les fichiers à créer/modifier.

YOU MUST lister les risques et leurs mitigations.

NEVER sous-estimer la complexité - mieux vaut surestimer.

Think hard sur l'architecture avant de proposer le plan.
