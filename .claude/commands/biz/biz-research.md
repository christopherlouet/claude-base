# Agent RESEARCH

Conduit une recherche utilisateur structurée pour informer les décisions produit.

## Sujet de recherche
$ARGUMENTS

## Objectif

Mener une recherche utilisateur méthodique qui génère des insights actionnables
pour améliorer le produit et répondre aux vrais besoins des utilisateurs.

## Méthodologie de recherche

```
┌─────────────────────────────────────────────────────────────┐
│                    USER RESEARCH PROCESS                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. CADRER        → Définir questions et objectifs         │
│  ══════════                                                 │
│                                                             │
│  2. PLANIFIER     → Choisir méthodes et recruter           │
│  ═══════════                                                │
│                                                             │
│  3. COLLECTER     → Interviews, tests, enquêtes            │
│  ════════════                                               │
│                                                             │
│  4. ANALYSER      → Synthétiser et identifier patterns     │
│  ══════════                                                 │
│                                                             │
│  5. RESTITUER     → Partager insights et recommandations   │
│  ═══════════                                                │
│                                                             │
│  6. ACTIONNER     → Intégrer dans la roadmap               │
│  ═══════════                                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Cadrage de la recherche

### Research Brief Template

```markdown
## Research Brief

### Contexte
[Pourquoi cette recherche ? Quel est le déclencheur ?]

### Questions de recherche
1. [Question principale]
2. [Question secondaire]
3. [Question tertiaire]

### Hypothèses à valider/invalider
| Hypothèse | Confiance actuelle | Source |
|-----------|-------------------|--------|
| [H1] | Faible/Moyenne/Haute | [D'où vient cette hypothèse] |
| [H2] | Faible/Moyenne/Haute | [Source] |

### Ce qu'on sait déjà
- [Insight existant 1]
- [Insight existant 2]

### Ce qu'on ne sait pas
- [Gap de connaissance 1]
- [Gap de connaissance 2]

### Critères de succès
La recherche sera réussie si nous pouvons :
- [ ] Répondre à [question 1]
- [ ] Valider/invalider [hypothèse]
- [ ] Recommander [type de décision]

### Timeline
- Cadrage : [Date]
- Collecte : [Date] - [Date]
- Analyse : [Date] - [Date]
- Restitution : [Date]

### Stakeholders
| Personne | Rôle | Implication |
|----------|------|-------------|
| [Nom] | Sponsor | Valide le brief |
| [Nom] | Contributeur | Aide au recrutement |
| [Nom] | Consommateur | Utilise les insights |
```

### Types de questions de recherche

```
┌─────────────────────────────────────────────────────────────┐
│                    TYPES DE QUESTIONS                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  EXPLORATOIRE      "Que se passe-t-il ?"                   │
│  ═════════════     → Comprendre comportements et contextes │
│                    → Méthodes : Interviews, observation     │
│                                                             │
│  DESCRIPTIVE       "Comment ça se passe ?"                 │
│  ════════════      → Quantifier et caractériser            │
│                    → Méthodes : Enquêtes, analytics        │
│                                                             │
│  ÉVALUATIVE        "Est-ce que ça marche ?"                │
│  ════════════      → Tester solutions et concepts          │
│                    → Méthodes : Tests utilisateur, A/B     │
│                                                             │
│  CAUSALE           "Pourquoi ça se passe ?"                │
│  ═════════         → Comprendre les motivations profondes  │
│                    → Méthodes : Interviews approfondies    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 2 : Choix des méthodes

### Matrice des méthodes

| Méthode | Type | Quand l'utiliser | Effort |
|---------|------|------------------|--------|
| **Interviews** | Quali | Explorer, comprendre le "pourquoi" | Moyen |
| **Tests utilisateur** | Quali | Évaluer une solution | Moyen |
| **Enquêtes** | Quanti | Valider à grande échelle | Faible |
| **Analytics** | Quanti | Comprendre comportements | Faible |
| **Card sorting** | Quali | Organiser l'information | Faible |
| **Diary studies** | Quali | Capturer usage sur la durée | Élevé |
| **A/B tests** | Quanti | Mesurer impact d'un changement | Moyen |
| **Tree testing** | Quali | Valider navigation | Faible |

### Guide de sélection

```markdown
## Quelle méthode choisir ?

### Je veux comprendre les besoins et motivations
→ **Interviews utilisateur** (5-8 participants)

### Je veux tester une maquette ou prototype
→ **Tests utilisateur** (5-8 participants)

### Je veux valider une hypothèse à grande échelle
→ **Enquête quantitative** (100+ répondants)

### Je veux comprendre le comportement actuel
→ **Analyse des données** + **Observation**

### Je veux prioriser des fonctionnalités
→ **Enquête de priorisation** (Max Diff, Kano)

### Je veux tester l'organisation de l'information
→ **Card sorting** (ouvert ou fermé)
```

## Étape 3 : Recrutement des participants

### Critères de recrutement

```markdown
## Screener de recrutement

### Critères d'inclusion
- [ ] [Critère 1 - ex: Utilise le produit depuis > 1 mois]
- [ ] [Critère 2 - ex: Rôle = Product Manager]
- [ ] [Critère 3 - ex: Entreprise 10-500 employés]

### Critères d'exclusion
- [ ] [Critère - ex: Travaille pour un concurrent]
- [ ] [Critère - ex: A participé à une étude < 6 mois]

### Quotas
| Segment | Nombre cible |
|---------|--------------|
| [Segment 1] | [X] |
| [Segment 2] | [X] |

### Questions de screening
1. [Question pour valider critère 1]
   - [ ] Réponse valide
   - [ ] Réponse invalide

2. [Question pour valider critère 2]
   - [ ] Réponse valide
   - [ ] Réponse invalide
```

### Canaux de recrutement

| Canal | Pour qui | Coût | Qualité |
|-------|----------|------|---------|
| **Base utilisateurs** | Utilisateurs actuels | Gratuit | Haute |
| **Panel (UserTesting, etc.)** | Grand public | $$$ | Variable |
| **Réseaux sociaux** | Communauté ciblée | Faible | Variable |
| **Recrutement pro** | Profils rares | $$$$ | Haute |

### Incentives recommandées

| Type de participant | Durée | Incentive suggérée |
|--------------------|-------|-------------------|
| B2C Grand public | 30 min | 30-50€ |
| B2C Grand public | 60 min | 60-100€ |
| B2B Manager | 30 min | 75-100€ |
| B2B Manager | 60 min | 150-200€ |
| B2B C-Level | 30 min | 200-300€ |

## Étape 4 : Guides d'entretien

### Structure d'interview (60 min)

```markdown
## Guide d'entretien

### Introduction (5 min)
- Présentation et remerciements
- Expliquer le déroulement et la durée
- Demander permission d'enregistrer
- Rappeler qu'il n'y a pas de mauvaise réponse

### Échauffement (5 min)
- "Pouvez-vous vous présenter brièvement ?"
- "Décrivez une journée type dans votre travail"

### Exploration du contexte (15 min)
- "Comment [faites-vous X actuellement] ?"
- "Qu'est-ce qui fonctionne bien dans ce process ?"
- "Qu'est-ce qui est frustrant ou difficile ?"
- "Pouvez-vous me donner un exemple récent ?"

### Deep dive sur le problème (20 min)
- "Vous avez mentionné [X], pouvez-vous m'en dire plus ?"
- "Qu'avez-vous essayé pour résoudre ce problème ?"
- "Qu'est-ce qui se passerait si ce problème était résolu ?"
- "À quelle fréquence rencontrez-vous ce problème ?"

### [Test de concept si applicable] (10 min)
- Montrer le prototype/concept
- "Qu'est-ce que vous comprenez de ceci ?"
- "Comment l'utiliseriez-vous ?"
- "Qu'est-ce qui manque ?"

### Clôture (5 min)
- "Y a-t-il autre chose que vous aimeriez ajouter ?"
- "Avez-vous des questions pour moi ?"
- Remercier et expliquer les prochaines étapes
```

### Techniques d'interview

```markdown
## Techniques d'interview

### Questions à utiliser
- "Pouvez-vous m'en dire plus ?" (approfondir)
- "Qu'entendez-vous par [X] ?" (clarifier)
- "Pouvez-vous me donner un exemple ?" (concrétiser)
- "Comment vous êtes-vous senti ?" (émotion)
- "Qu'avez-vous fait ensuite ?" (séquence)

### Questions à éviter
❌ Questions fermées : "Est-ce que vous aimez X ?"
❌ Questions orientées : "N'est-ce pas frustrant quand X ?"
❌ Questions hypothétiques : "Utiliseriez-vous X si on le créait ?"
❌ Questions doubles : "Que pensez-vous de X et de Y ?"

### Gérer le silence
- Attendre 5-10 secondes avant de relancer
- Le silence encourage des réponses plus profondes
- "Prenez votre temps..."

### Gérer les réponses courtes
- "C'est intéressant, pouvez-vous développer ?"
- "Qu'est-ce qui vous fait dire ça ?"
- Reformuler pour inviter à préciser
```

## Étape 5 : Analyse des données

### Analyse qualitative

```markdown
## Process d'analyse qualitative

### 1. Transcription
- Transcrire les interviews (outil : Otter.ai, Grain)
- Noter les timestamps des moments clés

### 2. Codage
- Identifier les thèmes récurrents
- Créer un codebook avec définitions
- Coder chaque verbatim

### 3. Synthèse par thème

| Thème | Occurrences | Verbatims clés | Insight |
|-------|-------------|----------------|---------|
| [Thème 1] | 6/8 | "..." | [Insight] |
| [Thème 2] | 4/8 | "..." | [Insight] |

### 4. Affinity mapping
- Regrouper les insights par affinité
- Identifier les patterns transversaux
- Prioriser par impact et fréquence
```

### Framework d'analyse

```markdown
## Frameworks utiles

### Jobs-to-be-done
| Quand je [situation], je veux [motivation], pour pouvoir [résultat] |

### Pain points vs Gains
| Pain Points | Gains potentiels |
|-------------|-----------------|
| [Frustration] | [Bénéfice si résolu] |

### Forces analysis
| Forces facilitatrices | Forces bloquantes |
|----------------------|-------------------|
| [Ce qui pousse à adopter] | [Ce qui freine] |
```

## Étape 6 : Restitution

### Template de rapport

```markdown
# Rapport de Recherche : [Titre]

**Date :** [Date]
**Chercheur :** [Nom]
**Méthode :** [Type] | **Participants :** [N]

---

## Executive Summary

### Question de recherche
[Question principale]

### Key findings
1. **[Finding 1]** : [Description courte]
2. **[Finding 2]** : [Description courte]
3. **[Finding 3]** : [Description courte]

### Recommandations prioritaires
1. [Action recommandée 1]
2. [Action recommandée 2]

---

## Méthodologie

### Approche
[Description de la méthode utilisée]

### Participants
| Caractéristique | Distribution |
|-----------------|--------------|
| [Critère 1] | [Répartition] |
| [Critère 2] | [Répartition] |

### Limites
- [Limite 1 de l'étude]
- [Limite 2]

---

## Findings détaillés

### Finding 1 : [Titre]

**Résumé :** [1-2 phrases]

**Evidence :**
> "[Verbatim participant 1]" - P1

> "[Verbatim participant 2]" - P3

**Quantification :** [X/Y] participants ont mentionné ce point

**Implication produit :** [Ce que ça signifie pour le produit]

### Finding 2 : [Titre]
[Même structure]

---

## Recommandations

### Court terme (0-3 mois)
| Recommandation | Impact | Effort | Owner suggéré |
|----------------|--------|--------|---------------|
| [Reco 1] | Élevé | Faible | [Équipe] |
| [Reco 2] | Moyen | Moyen | [Équipe] |

### Moyen terme (3-6 mois)
| Recommandation | Impact | Effort | Owner suggéré |
|----------------|--------|--------|---------------|
| [Reco 3] | Élevé | Élevé | [Équipe] |

---

## Questions ouvertes

- [Question qui nécessite plus de recherche]
- [Question pour une prochaine étude]

---

## Annexes

- [Lien vers guide d'entretien]
- [Lien vers données brutes]
- [Lien vers enregistrements]
```

### Formats de restitution

| Format | Audience | Durée | Usage |
|--------|----------|-------|-------|
| **Executive summary** | Leadership | 1 page | Décision rapide |
| **Présentation** | Équipe | 30 min | Partage insights |
| **Rapport complet** | Référence | 10+ pages | Documentation |
| **Video highlights** | Tous | 5 min | Empathie |
| **Atomic insights** | Tous | - | Base de connaissances |

## Repository d'insights

### Structure de la base

```markdown
## Insight Repository

### Format d'un insight atomique
| Champ | Valeur |
|-------|--------|
| **ID** | INS-2024-042 |
| **Titre** | [Titre court et actionnable] |
| **Insight** | [Description complète] |
| **Evidence** | [Source et méthode] |
| **Participants** | [X/Y] |
| **Confiance** | Haute/Moyenne/Faible |
| **Tags** | [persona], [feature], [theme] |
| **Date** | [Date de création] |
| **Owner** | [Chercheur] |
| **Status** | Nouveau/En cours/Actionné/Archivé |

### Recherche
- Par persona
- Par feature/thème
- Par date
- Par niveau de confiance
```

## Checklist qualité

```markdown
## Checklist Research Quality

### Avant la recherche
- [ ] Brief validé par stakeholders
- [ ] Questions de recherche claires
- [ ] Méthode appropriée aux questions
- [ ] Participants bien recrutés
- [ ] Guide d'entretien testé

### Pendant la recherche
- [ ] Consentement obtenu
- [ ] Questions ouvertes utilisées
- [ ] Pas de biais de confirmation
- [ ] Notes prises systématiquement

### Après la recherche
- [ ] Analyse rigoureuse
- [ ] Findings supportés par evidence
- [ ] Recommandations actionnables
- [ ] Rapport partagé aux stakeholders
- [ ] Insights documentés dans le repository
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/personas` | Créer/mettre à jour personas |
| `/analytics` | Compléter avec données quanti |
| `/ab-test` | Valider des hypothèses |
| `/plan` | Intégrer insights en roadmap |
| `/onboarding` | Améliorer parcours utilisateur |

---

IMPORTANT: La recherche doit répondre à des questions précises, pas juste "mieux comprendre".

YOU MUST recruter des participants représentatifs de vos utilisateurs cibles.

YOU MUST documenter et partager les insights pour qu'ils soient actionnés.

NEVER mener une recherche sans plan d'action pour les résultats.

Think hard sur les biais potentiels dans le recrutement et les questions.
