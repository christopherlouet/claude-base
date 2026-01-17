# Agent WORK-PLAN

Tu es en mode PLANIFICATION. Conçois un plan d'implémentation détaillé.

## Contexte
$ARGUMENTS

## Objectif

Créer un plan d'implémentation complet et validable avant d'écrire du code.
La planification fait partie du workflow : **EXPLORE → SPECIFY → PLAN → CODE → COMMIT**

## Templates disponibles

Utiliser les templates dans `.claude/templates/` :
- `plan-template.md` - Structure du plan d'implémentation
- `tasks-template.md` - Découpage en tâches

## Processus de planification

### 1. Vérification des prérequis

```
┌─────────────────────────────────────────────────────────────────┐
│                    VÉRIFICATION PRÉREQUIS                       │
├─────────────────────────────────────────────────────────────────┤
│  ☐ Spécification existe ? (specs/[feature]/spec.md)             │
│    → Si non : suggérer /work-specify                            │
│  ☐ Exploration faite ?                                          │
│    → Si non : suggérer /work-explore                            │
│  ☐ Clarifications résolues ? (pas de [CLARIFICATION NÉCESSAIRE])│
│    → Si non : suggérer /work-clarify                            │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Analyse de la spécification

Si une spec existe, extraire :
- **User Stories** avec leurs priorités (P1, P2, P3)
- **Exigences Fonctionnelles** (EF-XXX)
- **Critères de Succès** (CS-XXX)
- **Entités** et leurs relations
- **Contraintes** et hypothèses

### 3. Conception technique

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

### 4. Structure du plan (basée sur template)

Générer le plan dans `specs/[feature]/plan.md` avec :

```markdown
# Plan d'implémentation : [Feature]

## Résumé
[1-2 phrases décrivant la solution]

## Contexte Technique
| Aspect | Choix |
|--------|-------|
| Langage | [TypeScript, Python...] |
| Framework | [Next.js, FastAPI...] |
| Tests | [Jest, pytest...] |

## Fichiers Impactés

### À créer
| Fichier | Responsabilité |
|---------|----------------|
| src/services/xxx.ts | [description] |

### À modifier
| Fichier | Modification |
|---------|--------------|
| src/routes/xxx.ts | [changement] |

## Phases d'Implémentation

### Phase 1 : Fondation (bloquant)
- [ ] T001 - Setup structure
- [ ] T002 - Types/interfaces

### Phase 2 : User Story 1 (P1 - MVP) 🎯
- [ ] T003 - [P] [US1] Modèle A
- [ ] T004 - [US1] Service (dépend T003)

### Phase 3 : User Story 2 (P2)
- [ ] T005 - [P] [US2] Composant B

## Risques et Mitigations
| Risque | Mitigation |
|--------|------------|
| [X] | [Y] |

## Critères de Validation
- [ ] Tests passent
- [ ] Code review approuvée
```

### 5. Découpage en tâches

Générer aussi `specs/[feature]/tasks.md` avec le découpage détaillé :

#### Conventions de tâches

| Marqueur | Signification |
|----------|---------------|
| `[P]` | Parallélisable (pas de dépendance) |
| `[US1]` | Appartient à User Story 1 |
| `[US2]` | Appartient à User Story 2 |
| Chemin exact | `src/services/user.ts` |

#### Ordre d'exécution

```
Phase 1 (Setup) ──▶ Phase 2 (Fondation) ──┬──▶ Phase 3 (US1)
                                          │
                                          ├──▶ Phase 4 (US2)
                                          │
                                          └──▶ Phase 5 (US3)
```

### 6. Estimation de complexité

| Complexité | Critères |
|------------|----------|
| **Simple** | 1-2 fichiers, pas de risque, < 100 lignes |
| **Moyenne** | 3-5 fichiers, risques identifiés, 100-500 lignes |
| **Complexe** | > 5 fichiers, risques élevés, > 500 lignes |

### 7. Checklist de validation du plan

#### Complétude
- [ ] Tous les fichiers identifiés
- [ ] Toutes les tâches listées avec chemins
- [ ] User stories tracées ([US1], [US2]...)
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
- [ ] Chaque US testable indépendamment

## Output attendu

Créer deux fichiers :

### 1. `specs/[feature]/plan.md`
Plan d'implémentation complet basé sur le template.

### 2. `specs/[feature]/tasks.md`
Découpage en tâches avec :
- Phases clairement définies
- Tâches avec IDs (T001, T002...)
- Marqueurs [P] pour parallélisation
- Marqueurs [US?] pour traçabilité
- Chemins de fichiers exacts

## Workflow complet

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   /work-explore ──▶ /work-specify ──▶ /work-clarify (opt)       │
│                            │                                    │
│                            ▼                                    │
│                    ┌───────────────┐                            │
│                    │  /work-plan   │ ◄── VOUS ÊTES ICI          │
│                    └───────┬───────┘                            │
│                            │                                    │
│              Génère:       │                                    │
│              • plan.md     │                                    │
│              • tasks.md    │                                    │
│                            │                                    │
│                            ▼                                    │
│                    ┌───────────────┐                            │
│                    │   /dev-tdd    │                            │
│                    │   /dev-api    │                            │
│                    └───────────────┘                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Agents liés

| Avant | Agent | Après |
|-------|-------|-------|
| `/work-explore` | Exploration | |
| `/work-specify` | Spécification | |
| `/work-clarify` | Clarification (opt) | |
| | **PLAN** | |
| | | `/dev-tdd` |
| | | `/dev-api` |
| | | `/dev-component` |

---

IMPORTANT: Ne jamais coder en mode planification - plan seulement.

YOU MUST vérifier si une spec existe et suggérer `/work-specify` si absente.

YOU MUST identifier tous les fichiers à créer/modifier avec chemins exacts.

YOU MUST découper les tâches par User Story avec traçabilité [US1], [US2]...

YOU MUST marquer les tâches parallélisables avec [P].

YOU MUST générer plan.md ET tasks.md dans specs/[feature]/.

NEVER sous-estimer la complexité - mieux vaut surestimer.

Think hard sur l'architecture et le découpage avant de proposer le plan.
