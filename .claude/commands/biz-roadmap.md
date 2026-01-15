# Agent ROADMAP

Planifier et visualiser la roadmap produit.

## Contexte
$ARGUMENTS

## Processus de planification

### 1. Comprendre le contexte

#### Explorer le projet
```bash
# Documentation existante
cat README.md 2>/dev/null

# Issues/TODO existants
find . -name "TODO*" -o -name "ROADMAP*" 2>/dev/null
grep -rn "TODO\|FIXME" --include="*.ts" --include="*.tsx" | head -20
```

#### Questions clés
- Quelle est la vision à long terme ?
- Quels sont les objectifs business ?
- Quelles contraintes (ressources, temps, tech) ?
- Qui sont les parties prenantes ?

### 2. Collecter les initiatives

#### Sources d'input
- [ ] Feedback utilisateurs
- [ ] Demandes clients
- [ ] Dette technique
- [ ] Opportunités marché
- [ ] Objectifs business
- [ ] Initiatives internes

#### Template d'initiative
```markdown
## [Nom de l'initiative]

**Description**: [Ce qu'on veut faire]
**Objectif**: [Pourquoi c'est important]
**Bénéficiaire**: [Qui en profite]
**Métrique de succès**: [Comment on mesure]
**Effort estimé**: [T-shirt size: XS/S/M/L/XL]
**Dépendances**: [Ce qui doit être fait avant]
```

### 3. Priorisation

#### Framework RICE
| Critère | Description | Score |
|---------|-------------|-------|
| **R**each | Combien d'utilisateurs impactés | 1-10 |
| **I**mpact | Quel impact par utilisateur | 0.25, 0.5, 1, 2, 3 |
| **C**onfidence | Niveau de certitude | 50%, 80%, 100% |
| **E**ffort | Effort en personne-mois | 0.5, 1, 2, 3, 6+ |

```
Score RICE = (Reach × Impact × Confidence) / Effort
```

#### Matrice Impact/Effort
```
        Impact élevé
             │
    Quick    │    Big
    Wins  ←──┼──→ Bets
             │
  ───────────┼───────────
             │
    Fill     │    Money
    Ins   ←──┼──→ Pits
             │
        Impact faible

    Effort faible ←→ Effort élevé
```

#### Framework ICE (alternative simple)
| Critère | Description | Score (1-10) |
|---------|-------------|--------------|
| **I**mpact | Impact potentiel | |
| **C**onfidence | Certitude du résultat | |
| **E**ase | Facilité d'implémentation | |

```
Score ICE = Impact × Confidence × Ease
```

### 4. Définir les horizons

#### Structure temporelle
```
NOW (0-4 semaines)
├── [Initiative 1] - En cours
├── [Initiative 2] - Planifiée
└── [Initiative 3] - Planifiée

NEXT (1-3 mois)
├── [Initiative 4]
├── [Initiative 5]
└── [Initiative 6]

LATER (3-6 mois)
├── [Initiative 7]
├── [Initiative 8]
└── [Initiative 9]

FUTURE (6+ mois / Vision)
├── [Grande initiative 1]
└── [Grande initiative 2]
```

#### Roadmap par thème
```
┌─────────────┬──────────────┬──────────────┬──────────────┐
│   Thème     │     NOW      │     NEXT     │    LATER     │
├─────────────┼──────────────┼──────────────┼──────────────┤
│ Acquisition │ [Feature A]  │ [Feature D]  │ [Feature G]  │
│             │ [Feature B]  │              │              │
├─────────────┼──────────────┼──────────────┼──────────────┤
│ Rétention   │ [Feature C]  │ [Feature E]  │ [Feature H]  │
├─────────────┼──────────────┼──────────────┼──────────────┤
│ Revenus     │              │ [Feature F]  │ [Feature I]  │
├─────────────┼──────────────┼──────────────┼──────────────┤
│ Tech/Infra  │ [Fix X]      │ [Migration]  │              │
└─────────────┴──────────────┴──────────────┴──────────────┘
```

### 5. Formats de roadmap

#### Roadmap Kanban (Now/Next/Later)
```
┌────────────────┬────────────────┬────────────────┐
│      NOW       │      NEXT      │     LATER      │
│   (Current)    │   (1-3 mois)   │   (3-6 mois)   │
├────────────────┼────────────────┼────────────────┤
│ ┌────────────┐ │ ┌────────────┐ │ ┌────────────┐ │
│ │ Feature A  │ │ │ Feature D  │ │ │ Feature G  │ │
│ │ ███████░░░ │ │ │            │ │ │            │ │
│ └────────────┘ │ └────────────┘ │ └────────────┘ │
│ ┌────────────┐ │ ┌────────────┐ │ ┌────────────┐ │
│ │ Feature B  │ │ │ Feature E  │ │ │ Feature H  │ │
│ │ ████░░░░░░ │ │ │            │ │ │            │ │
│ └────────────┘ │ └────────────┘ │ └────────────┘ │
│ ┌────────────┐ │ ┌────────────┐ │                │
│ │ Feature C  │ │ │ Feature F  │ │                │
│ │ ░░░░░░░░░░ │ │ │            │ │                │
│ └────────────┘ │ └────────────┘ │                │
└────────────────┴────────────────┴────────────────┘
```

#### Roadmap Timeline (Gantt simplifié)
```
                    Q1           Q2           Q3           Q4
                ─────────────────────────────────────────────────
Feature A       ████████████
Feature B                    ████████████
Feature C       ██████████████████████████
Feature D                                 ████████████
Feature E                                              ████████
```

#### Roadmap par objectif
```
🎯 Objectif 1: Améliorer l'acquisition
├── ✅ Landing page refonte
├── 🔄 SEO optimisation
├── ⏳ Referral program
└── 📋 Content marketing

🎯 Objectif 2: Augmenter la rétention
├── 🔄 Onboarding amélioré
├── ⏳ Notifications push
└── 📋 Programme fidélité

🎯 Objectif 3: Augmenter le revenu
├── 📋 Nouveau plan Enterprise
└── 📋 Add-ons payants
```

Légende : ✅ Terminé | 🔄 En cours | ⏳ Planifié | 📋 Backlog

### 6. Milestones

#### Définir les jalons clés
| Milestone | Date cible | Critères de succès |
|-----------|------------|-------------------|
| MVP | [Date] | [Critères] |
| Beta publique | [Date] | [Critères] |
| V1.0 | [Date] | [Critères] |
| [Milestone N] | [Date] | [Critères] |

#### Template de milestone
```markdown
## Milestone: [Nom]

**Date cible**: [Date]
**Objectif**: [Ce qu'on veut atteindre]

### Critères de succès
- [ ] [Critère 1]
- [ ] [Critère 2]
- [ ] [Critère 3]

### Fonctionnalités incluses
- [Feature 1]
- [Feature 2]
- [Feature 3]

### Risques
- [Risque 1] → [Mitigation]
- [Risque 2] → [Mitigation]
```

### 7. Communication

#### Roadmap publique (clients)
Ce qu'on montre :
- [ ] Grandes initiatives (pas le détail)
- [ ] Thèmes/objectifs
- [ ] Horizon général (sans dates précises)

Ce qu'on ne montre PAS :
- [ ] Dates exactes (risque de déception)
- [ ] Détails d'implémentation
- [ ] Features pas encore validées

#### Roadmap interne (équipe)
- Plus de détails
- Dates/sprints
- Assignations
- Dépendances

### 8. Outils recommandés

| Besoin | Options gratuites | Options payantes |
|--------|-------------------|------------------|
| Roadmap simple | Notion, GitHub Projects | Linear, Productboard |
| Kanban | Trello, GitHub Projects | Jira, Asana |
| Timeline | Notion | Monday, Roadmunk |
| Feedback | Canny (free tier) | Productboard, Canny |

### 9. Maintenance de la roadmap

#### Rituels recommandés
| Fréquence | Action |
|-----------|--------|
| Hebdo | Review du "Now", update du statut |
| Mensuel | Re-priorisation du "Next" |
| Trimestriel | Review complète, ajustement stratégique |

#### Questions à se poser régulièrement
- Les priorités ont-elles changé ?
- Y a-t-il de nouvelles informations marché ?
- Le feedback utilisateur confirme-t-il nos hypothèses ?
- Les estimations étaient-elles correctes ?

## Output attendu

### Vision produit
```
Vision à 1 an: [Description]
North Star Metric: [Métrique]
```

### Initiatives priorisées

| # | Initiative | Impact | Effort | Score | Horizon |
|---|------------|--------|--------|-------|---------|
| 1 | | | | | NOW |
| 2 | | | | | NOW |
| 3 | | | | | NEXT |
| ... | | | | | |

### Roadmap visuelle
[Format choisi : Kanban / Timeline / Par objectif]

### Milestones
| Milestone | Date | Initiatives incluses |
|-----------|------|---------------------|
| | | |

### Dépendances et risques
| Initiative | Dépend de | Risque |
|------------|-----------|--------|
| | | |

### Prochaines actions
1. [Action 1]
2. [Action 2]
3. [Action 3]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/plan` | Planifier une initiative |
| `/okr` | Définir les OKRs liés |
| `/mvp` | Définir le scope MVP |
| `/release` | Créer une release |
| `/changelog` | Documenter les releases |

---

IMPORTANT: Une roadmap est un outil de communication, pas un engagement ferme - elle évoluera.

YOU MUST lier chaque initiative à un objectif business - pas de feature "parce que c'est cool".

NEVER mettre de dates précises sur une roadmap publique - utiliser des horizons (Now/Next/Later).

Think hard sur les dépendances entre initiatives et les risques avant de finaliser.
