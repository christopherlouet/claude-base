# Agent WORK-FLOW-FEATURE

Workflow complet pour développer une nouvelle fonctionnalité, de l'exploration au merge.

## Contexte
$ARGUMENTS

## Workflow automatisé

Ce workflow enchaîne les étapes suivantes :

```
┌─────────────────────────────────────────────────────────────┐
│                    WORKFLOW FEATURE                          │
├─────────────────────────────────────────────────────────────┤
│  1. EXPLORE    → Comprendre le code existant                │
│  2. PLAN       → Définir l'architecture                     │
│  3. TDD        → Développer avec tests                      │
│  4. REVIEW     → Auto-review du code                        │
│  5. COMMIT     → Commit propre                              │
│  6. PR         → Créer la Pull Request                      │
└─────────────────────────────────────────────────────────────┘
```

---

## ÉTAPE 1/6 : EXPLORATION

### Objectif
Comprendre le contexte avant de coder.

### Actions
1. Identifier les fichiers concernés
2. Comprendre les patterns existants
3. Repérer les dépendances
4. Noter les conventions en place

### Checklist exploration
- [ ] Code existant analysé
- [ ] Patterns identifiés
- [ ] Dépendances listées
- [ ] Points d'attention notés

---

## ÉTAPE 2/6 : PLANIFICATION

### Objectif
Définir clairement ce qui va être fait.

### Plan à produire

```markdown
## Feature: [Nom]

### Fichiers à créer
- [ ] [fichier 1] - [description]
- [ ] [fichier 2] - [description]

### Fichiers à modifier
- [ ] [fichier existant] - [modifications]

### Tests à écrire
- [ ] [test 1]
- [ ] [test 2]

### Risques identifiés
- [Risque 1] → [Mitigation]
```

### Checklist plan
- [ ] Scope défini clairement
- [ ] Fichiers listés
- [ ] Tests planifiés
- [ ] Risques identifiés

---

## ÉTAPE 3/6 : DÉVELOPPEMENT TDD

### Objectif
Implémenter avec une approche test-first.

### Cycle TDD
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│  RED    │ → │  GREEN  │ → │ REFACTOR│
│  Test   │    │  Code   │    │ Clean   │
│  fail   │    │  pass   │    │  up     │
└─────────┘    └─────────┘    └─────────┘
      ↑                              │
      └──────────────────────────────┘
```

### Checklist TDD
- [ ] Tests écrits avant le code
- [ ] Tests passent au vert
- [ ] Code refactoré
- [ ] Couverture suffisante (80%+)

---

## ÉTAPE 4/6 : AUTO-REVIEW

### Objectif
Vérifier la qualité avant de commiter.

### Points de vérification

| Catégorie | Check |
|-----------|-------|
| Code | Lisible, DRY, SOLID |
| Types | Pas de any, types stricts |
| Tests | Coverage OK, edge cases |
| Sécurité | Pas de vulnérabilités |
| Perf | Pas de problèmes évidents |

### Checklist review
- [ ] Code propre
- [ ] Tests complets
- [ ] Pas de console.log
- [ ] Imports optimisés
- [ ] Lint passé

---

## ÉTAPE 5/6 : COMMIT

### Objectif
Créer un commit atomique et descriptif.

### Format
```
feat(scope): description courte

- Détail 1
- Détail 2

Refs: #123
```

### Checklist commit
- [ ] Message clair
- [ ] Scope précis
- [ ] Changements atomiques
- [ ] Pas de fichiers oubliés

---

## ÉTAPE 6/6 : PULL REQUEST

### Objectif
Créer une PR complète pour review.

### Template PR
```markdown
## Description
[Ce que fait cette PR]

## Type de changement
- [x] Nouvelle fonctionnalité

## Comment tester
1. [Étape 1]
2. [Étape 2]

## Checklist
- [x] Tests passent
- [x] Code reviewé
- [x] Documentation à jour
```

### Checklist PR
- [ ] Description complète
- [ ] Reviewers assignés
- [ ] Labels ajoutés
- [ ] CI verte

---

## Output final attendu

À la fin du workflow :

### Résumé
```
✅ WORKFLOW FEATURE TERMINÉ

Feature: [Nom]
Branch: feature/[nom]
PR: #[numero]

Fichiers créés: [N]
Fichiers modifiés: [N]
Tests ajoutés: [N]
Couverture: [X%]

Status: Ready for review
```

### Prochaines actions
- [ ] Attendre review
- [ ] Répondre aux commentaires
- [ ] Merger après approbation

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/explore` | Étape 1 - Exploration |
| `/plan` | Étape 2 - Planification |
| `/tdd` | Étape 3 - Développement |
| `/review` | Étape 4 - Auto-review |
| `/commit` | Étape 5 - Commit |
| `/pr` | Étape 6 - Pull Request |

---

IMPORTANT: Chaque étape doit être validée avant de passer à la suivante.

YOU MUST suivre l'ordre des étapes - ne pas sauter l'exploration ou la planification.

NEVER commiter du code sans tests.

Think hard à chaque étape sur la qualité du livrable.
