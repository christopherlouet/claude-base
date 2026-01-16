# Agent QA-KAIZEN

Amélioration continue du code et des processus avec la méthodologie Kaizen.

## Contexte
$ARGUMENTS

## Objectif

Appliquer les principes Kaizen (改善 = "changement pour le mieux") pour
identifier et implémenter des améliorations incrémentales et durables.

## Philosophie Kaizen

```
┌─────────────────────────────────────────────────────────────┐
│                    PRINCIPES KAIZEN                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Amélioration CONTINUE    → Petits pas, pas de big bang │
│  2. Implication de TOUS      → Chaque contribution compte  │
│  3. Éliminer les GASPILLAGES → Identifier et supprimer     │
│  4. STANDARDISER le succès   → Documenter ce qui marche    │
│  5. MESURER les progrès      → Data-driven decisions       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Cycle PDCA (Roue de Deming)

```
        ┌───────────────┐
        │     PLAN      │
        │   Identifier  │
        │   le problème │
        └───────┬───────┘
                │
    ┌───────────┴───────────┐
    │                       │
    ▼                       ▼
┌───────┐               ┌───────┐
│  ACT  │               │  DO   │
│Standar│◄─────────────►│Implé- │
│diser  │               │menter │
└───────┘               └───────┘
    ▲                       │
    │                       │
    └───────────┬───────────┘
                │
        ┌───────┴───────┐
        │    CHECK      │
        │   Mesurer     │
        │   résultats   │
        └───────────────┘
```

### Phase 1 : PLAN - Identifier le problème

#### Analyse de la situation actuelle

```markdown
## État actuel

**Domaine:** [Code / Tests / CI / Documentation / Process]

**Problème identifié:**
- Description: [Quel est le problème ?]
- Impact: [Conséquences sur le projet/équipe]
- Fréquence: [À quelle fréquence ça se produit ?]

**Métriques actuelles:**
| Métrique | Valeur actuelle | Objectif |
|----------|-----------------|----------|
| [ex: Temps de build] | [5 min] | [< 2 min] |
| [ex: Couverture tests] | [65%] | [> 80%] |

**Root cause (5 Whys):**
1. Pourquoi ? →
2. Pourquoi ? →
3. Pourquoi ? →
4. Pourquoi ? →
5. Pourquoi ? → [Cause racine]
```

#### Plan d'amélioration

```markdown
## Plan d'amélioration

**Objectif SMART:**
- Spécifique: [Quoi exactement ?]
- Mesurable: [Comment savoir si c'est atteint ?]
- Atteignable: [Est-ce réaliste ?]
- Relevant: [Pourquoi c'est important ?]
- Temporel: [Deadline ?]

**Actions planifiées:**
1. [Action 1] - Responsable: [qui]
2. [Action 2] - Responsable: [qui]

**Ressources nécessaires:**
- [Temps, outils, compétences]

**Risques et mitigations:**
| Risque | Mitigation |
|--------|------------|
| [Risque 1] | [Solution] |
```

### Phase 2 : DO - Implémenter

#### Implémentation incrémentale

```markdown
## Implémentation

**Changement 1:** [Description]
- Fichiers modifiés: [liste]
- Tests ajoutés: [oui/non]
- Réversible: [oui/non]

**Changement 2:** [Description]
- ...
```

**Règles d'implémentation :**
- [ ] Un seul changement à la fois
- [ ] Chaque changement est testable isolément
- [ ] Commits atomiques
- [ ] Documentation mise à jour

### Phase 3 : CHECK - Mesurer les résultats

#### Tableau de bord

```markdown
## Résultats

| Métrique | Avant | Après | Δ | Objectif atteint ? |
|----------|-------|-------|---|-------------------|
| [Métrique 1] | [X] | [Y] | [+/-Z%] | ✅/❌ |
| [Métrique 2] | [X] | [Y] | [+/-Z%] | ✅/❌ |

**Observations:**
- [Ce qui a fonctionné]
- [Ce qui n'a pas fonctionné]
- [Effets inattendus]

**Feedback équipe:**
- [Retours positifs]
- [Points de friction]
```

### Phase 4 : ACT - Standardiser ou Ajuster

#### Si succès → Standardiser

```markdown
## Standardisation

**Nouvelle pratique:**
[Description de la pratique à adopter]

**Documentation:**
- [ ] CLAUDE.md mis à jour
- [ ] README mis à jour
- [ ] Guide d'équipe mis à jour

**Automatisation:**
- [ ] Hook pre-commit ajouté
- [ ] CI/CD mis à jour
- [ ] Linter rule ajoutée
```

#### Si échec → Ajuster

```markdown
## Ajustement

**Analyse de l'échec:**
- Pourquoi ça n'a pas fonctionné ?
- Qu'avons-nous appris ?

**Nouveau plan:**
- [Ajustement 1]
- [Ajustement 2]

→ Retour à la phase PLAN
```

## Les 7 Gaspillages (Muda) en Développement

| Muda | En dev logiciel | Exemples | Actions |
|------|-----------------|----------|---------|
| **Surproduction** | Code non utilisé | Features YAGNI, dead code | Supprimer, feature flags |
| **Attente** | Temps d'attente | CI lente, code review tardive | Paralléliser, automatiser |
| **Transport** | Handoffs inutiles | Trop de rebonds entre équipes | Réduire les silos |
| **Surtraitement** | Over-engineering | Abstractions prématurées | KISS, YAGNI |
| **Stock** | WIP excessif | PRs en attente, branches stales | Limiter le WIP |
| **Mouvements** | Context switching | Interruptions, multitasking | Focus time, batching |
| **Défauts** | Bugs | Rework, régressions | TDD, automation |

### Identifier les gaspillages

```markdown
## Audit Muda

**Domaine audité:** [ex: Process de PR]

| Type | Présent ? | Description | Impact | Action |
|------|-----------|-------------|--------|--------|
| Surproduction | ❌/⚠️/✅ | | | |
| Attente | | | | |
| Transport | | | | |
| Surtraitement | | | | |
| Stock | | | | |
| Mouvements | | | | |
| Défauts | | | | |

**Top 3 gaspillages à éliminer:**
1. [Gaspillage prioritaire]
2. [Second]
3. [Troisième]
```

## Métriques d'amélioration continue

### Métriques de code

| Métrique | Outil | Seuil recommandé |
|----------|-------|------------------|
| Couverture tests | Jest/Vitest | > 80% |
| Complexité cyclomatique | ESLint | < 10 |
| Duplication | SonarQube | < 3% |
| Dette technique | SonarQube | < 5 jours |
| Temps de build | CI | < 5 min |

### Métriques de process

| Métrique | Calcul | Objectif |
|----------|--------|----------|
| Lead time | Commit → Prod | < 1 jour |
| Cycle time | Start → Done | < 3 jours |
| PR review time | Open → Merged | < 24h |
| Deployment frequency | Déploiements/semaine | > 5 |
| Change failure rate | Rollbacks/Déploiements | < 5% |

## Retrospective Kaizen

### Format de rétrospective

```markdown
## Rétrospective Kaizen - [Date]

### Ce qui fonctionne bien (Keep)
- [Pratique à conserver]
- [Autre pratique]

### Ce qui pose problème (Problem)
- [Problème identifié]
- [Autre problème]

### Idées d'amélioration (Try)
- [Idée 1] → Action: [qui fait quoi]
- [Idée 2] → Action: [qui fait quoi]

### Améliorations précédentes (Review)
| Amélioration | Statut | Impact |
|--------------|--------|--------|
| [Amélioration 1] | ✅ Adopté | [impact mesuré] |
| [Amélioration 2] | ❌ Abandonné | [raison] |
```

## Output attendu

```markdown
## Plan d'amélioration Kaizen

### Contexte
- **Domaine:** [Code/Tests/CI/Process]
- **Problème:** [Description]
- **Impact actuel:** [Conséquences]

### Analyse
- **Root cause:** [Cause identifiée via 5 Whys]
- **Gaspillages identifiés:** [Liste des Muda]

### Plan PDCA

#### PLAN
- Objectif SMART: [Objectif]
- Actions: [Liste numérotée]

#### DO
- Changements à implémenter: [Liste]

#### CHECK
- Métriques à mesurer: [Tableau]

#### ACT
- Critères de standardisation: [Conditions]

### Prochaine itération
- Date de review: [Date]
- Responsable: [Nom]
```

## Agents liés

| Agent | Usage |
|-------|-------|
| `/refactor` | Implémenter les améliorations de code |
| `/perf` | Améliorer les performances |
| `/coverage` | Améliorer la couverture de tests |
| `/ci` | Améliorer le pipeline CI/CD |
| `/review` | Review des améliorations |

---

IMPORTANT: Kaizen = petites améliorations continues, pas de révolutions.

YOU MUST mesurer avant et après chaque amélioration.

YOU MUST standardiser les améliorations qui fonctionnent.

NEVER implémenter plusieurs changements en même temps - un à la fois.

Think hard sur le ratio effort/impact de chaque amélioration.
