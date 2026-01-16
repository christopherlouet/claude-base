# Agent BIZ-OKR

Définir les OKRs (Objectives and Key Results) pour une période donnée.

## Contexte
$ARGUMENTS

## Processus de définition

### 1. Comprendre les OKRs

```
OKR = Objective + Key Results

Objective: Qualitatif, inspirant, ambitieux
├── Key Result 1: Quantitatif, mesurable
├── Key Result 2: Quantitatif, mesurable
└── Key Result 3: Quantitatif, mesurable
```

#### Caractéristiques d'un bon Objective
- [ ] Inspirant et motivant
- [ ] Ambitieux mais atteignable
- [ ] Aligné avec la vision
- [ ] Limité dans le temps (trimestre)
- [ ] Qualitatif (pas de chiffres)

#### Caractéristiques d'un bon Key Result
- [ ] Mesurable (chiffre précis)
- [ ] Vérifiable objectivement
- [ ] Atteignable à 70-80%
- [ ] Sous notre contrôle
- [ ] Limité (2-5 par Objective)

### 2. Framework de définition

#### Niveaux d'OKRs
```
OKRs Entreprise (Vision)
├── OKRs Équipe 1
│   ├── OKRs Individuels
│   └── OKRs Individuels
└── OKRs Équipe 2
    ├── OKRs Individuels
    └── OKRs Individuels
```

#### Cadence recommandée
- **Annuel** : 1-3 Objectives stratégiques
- **Trimestriel** : 3-5 Objectives tactiques
- **Check-in** : Hebdomadaire

### 3. Template OKR

```markdown
## Objective 1: [Titre inspirant]

**Pourquoi c'est important:** [Contexte]

| Key Result | Baseline | Target | Current | Score |
|------------|----------|--------|---------|-------|
| KR1: [Métrique 1] | [Actuel] | [Cible] | | /1.0 |
| KR2: [Métrique 2] | [Actuel] | [Cible] | | /1.0 |
| KR3: [Métrique 3] | [Actuel] | [Cible] | | /1.0 |

**Initiatives clés:**
- [ ] [Action 1]
- [ ] [Action 2]
- [ ] [Action 3]

**Score Objective:** [Moyenne KRs] /1.0
```

### 4. Exemples par domaine

#### Produit
```markdown
**Objective:** Offrir une expérience utilisateur exceptionnelle

- KR1: Augmenter le NPS de 30 à 50
- KR2: Réduire le temps de première valeur de 10min à 3min
- KR3: Atteindre 90% de complétion de l'onboarding
```

#### Croissance
```markdown
**Objective:** Accélérer notre croissance organique

- KR1: Passer de 1000 à 5000 utilisateurs actifs mensuels
- KR2: Atteindre 100 signups organiques par semaine
- KR3: Améliorer le taux de conversion landing→signup de 2% à 5%
```

#### Revenu
```markdown
**Objective:** Construire un business rentable et durable

- KR1: Atteindre 50K€ de MRR
- KR2: Améliorer le ratio LTV/CAC de 2x à 4x
- KR3: Réduire le churn mensuel de 5% à 2%
```

#### Technique
```markdown
**Objective:** Avoir une plateforme fiable et performante

- KR1: Maintenir un uptime de 99.9%
- KR2: Réduire le temps de chargement P95 de 3s à 1s
- KR3: Atteindre 80% de couverture de tests
```

#### Équipe
```markdown
**Objective:** Construire une équipe performante et épanouie

- KR1: Atteindre un eNPS de 40+
- KR2: 100% des membres ont un plan de développement
- KR3: 0 départ non souhaité sur le trimestre
```

### 5. Processus de scoring

| Score | Signification |
|-------|---------------|
| 0.0 - 0.3 | Échec - pas de progrès |
| 0.4 - 0.6 | Progrès insuffisant |
| 0.7 - 0.8 | Succès (sweet spot) |
| 0.9 - 1.0 | Objectif trop facile |

#### Calcul du score
```
Score KR = (Actuel - Baseline) / (Target - Baseline)

Exemple:
- Baseline: 1000 users
- Target: 5000 users
- Actuel: 3500 users
- Score: (3500-1000)/(5000-1000) = 0.625
```

### 6. Alignement

```
Vision Entreprise
       │
       ▼
┌─────────────────────────────────────────┐
│ OKR Entreprise Q1                        │
│ O: Devenir le leader du marché français  │
│ KR1: 10K utilisateurs                    │
│ KR2: 50K€ MRR                            │
└─────────────────────────────────────────┘
       │
       ├──────────────────┬────────────────┐
       ▼                  ▼                ▼
┌─────────────┐    ┌─────────────┐   ┌─────────────┐
│ OKR Produit │    │ OKR Growth  │   │ OKR Sales   │
│ O: UX top   │    │ O: Acquis.  │   │ O: Convert  │
│ KR: NPS 50  │    │ KR: 5K/mois │   │ KR: 20%     │
└─────────────┘    └─────────────┘   └─────────────┘
```

### 7. Réunions OKR

#### Planning (Début de trimestre)
- Durée : 2-4h
- Participants : Leadership + Équipes
- Output : OKRs validés pour le trimestre

#### Check-in hebdomadaire
- Durée : 15-30min
- Format : Standup autour des OKRs
- Questions : Confiance ? Blocages ? Aide nécessaire ?

#### Retrospective (Fin de trimestre)
- Durée : 1-2h
- Review des scores
- Learnings
- Préparation du trimestre suivant

### 8. Pièges à éviter

| ❌ Piège | ✅ Solution |
|----------|-------------|
| Trop d'OKRs | Max 3-5 Objectives |
| KRs = tâches | KRs = résultats mesurables |
| Objectifs trop faciles | Viser 70% d'atteinte |
| Pas de suivi | Check-in hebdomadaire |
| OKRs en silo | Alignement vertical + horizontal |
| Lier aux bonus | OKRs ≠ évaluation de performance |

## Output attendu

### OKRs du trimestre

```markdown
# OKRs Q[X] 2024

## Entreprise

### Objective 1: [Titre]
| KR | Baseline | Target | Owner |
|----|----------|--------|-------|
| [KR1] | | | |
| [KR2] | | | |
| [KR3] | | | |

### Objective 2: [Titre]
...

## Par équipe

### [Équipe 1]
#### Objective: [Titre]
...
```

### Dashboard de suivi

```
Q1 2024 - Semaine [X]
═══════════════════════════════════════

O1: [Titre]                    [███████░░░] 70%
├── KR1: [Métrique]            [████████░░] 80%
├── KR2: [Métrique]            [██████░░░░] 60%
└── KR3: [Métrique]            [███████░░░] 70%

O2: [Titre]                    [████░░░░░░] 40%
├── KR1: [Métrique]            [███░░░░░░░] 30%
├── KR2: [Métrique]            [█████░░░░░] 50%
└── KR3: [Métrique]            [████░░░░░░] 40%
```

### Checklist

- [ ] OKRs alignés avec la vision
- [ ] 3-5 Objectives max
- [ ] 2-5 KRs par Objective
- [ ] KRs mesurables et vérifiables
- [ ] Owners assignés
- [ ] Rituel de check-in planifié
- [ ] Outils de suivi en place

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/roadmap` | Roadmap alignée sur les OKRs |
| `/analytics` | Mesurer les Key Results |
| `/plan` | Planifier les initiatives |
| `/model` | Business model de référence |
| `/funnel` | Métriques de conversion |

---

IMPORTANT: Les OKRs ne sont pas des tâches mais des résultats à atteindre.

YOU MUST définir des KRs mesurables objectivement (pas "améliorer" mais "+20%").

NEVER lier les OKRs aux évaluations de performance - ça tue l'ambition.

Think hard sur ce qui compte vraiment pour le succès de l'entreprise.
