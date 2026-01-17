# Agent WORK-CLARIFY

Tu es en mode CLARIFICATION. Pose des questions ciblées pour réduire l'ambiguïté.

## Contexte
$ARGUMENTS

## Objectif

Identifier et résoudre les zones d'ambiguïté dans la spécification actuelle en posant des questions ciblées.
La clarification permet de réduire le risque de retravail en aval.

## Processus de clarification

### 1. Charger la spécification

Localiser et lire le fichier de spécification :
- `specs/[feature]/spec.md`
- Ou le fichier spécifié par l'utilisateur

### 2. Analyse des ambiguïtés

Scanner la spécification selon cette taxonomie et marquer le statut : **Clair** | **Partiel** | **Manquant**

```
┌─────────────────────────────────────────────────────────────────┐
│              CATÉGORIES D'ANALYSE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📋 SCOPE FONCTIONNEL                                           │
│     • Objectifs et critères de succès                           │
│     • Déclarations hors-scope explicites                        │
│     • Différenciation des rôles utilisateurs                    │
│                                                                 │
│  🗂️ MODÈLE DE DONNÉES                                           │
│     • Entités, attributs, relations                             │
│     • Règles d'identité et d'unicité                            │
│     • Transitions d'état / cycle de vie                         │
│     • Hypothèses de volume / échelle                            │
│                                                                 │
│  🎯 FLUX UX / INTERACTIONS                                      │
│     • Parcours utilisateur critiques                            │
│     • États d'erreur / vide / chargement                        │
│     • Accessibilité / localisation                              │
│                                                                 │
│  ⚡ QUALITÉ NON-FONCTIONNELLE                                   │
│     • Performance (latence, débit)                              │
│     • Fiabilité et disponibilité                                │
│     • Sécurité et confidentialité                               │
│                                                                 │
│  🔗 INTÉGRATIONS EXTERNES                                       │
│     • Services/APIs externes                                    │
│     • Formats d'import/export                                   │
│     • Modes de défaillance                                      │
│                                                                 │
│  ⚠️ CAS LIMITES                                                 │
│     • Scénarios négatifs                                        │
│     • Limites et seuils                                         │
│     • Résolution de conflits                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3. Règles de génération des questions

#### Contraintes
- **Maximum 5 questions** par session
- Chaque question doit être répondable par :
  - Un **choix multiple** (2-5 options distinctes), OU
  - Une **réponse courte** (≤ 5 mots)
- Ne poser que des questions dont la réponse impacte :
  - L'architecture
  - Le modèle de données
  - Les tests d'acceptation
  - L'expérience utilisateur
  - La conformité/sécurité

#### Priorisation (Impact × Incertitude)
1. Scope et comportement fonctionnel
2. Sécurité et confidentialité
3. Expérience utilisateur
4. Détails techniques

### 4. Format des questions

#### Question à choix multiple

```markdown
## Question [N] : [Sujet]

**Contexte** : [Citation de la section concernée de la spec]

**Ce qu'on doit savoir** : [Question spécifique]

**Recommandation** : Option [X] - [Justification en 1-2 phrases basée sur les bonnes pratiques]

| Option | Description | Implications |
|--------|-------------|--------------|
| A | [Première option] | [Impact sur la feature] |
| B | [Deuxième option] | [Impact sur la feature] |
| C | [Troisième option] | [Impact sur la feature] |
| Autre | Réponse personnalisée | [Expliquer] |

**Votre choix** : Répondez avec la lettre (ex: "A") ou "oui" pour accepter la recommandation.
```

#### Question à réponse courte

```markdown
## Question [N] : [Sujet]

**Contexte** : [Citation de la section concernée de la spec]

**Ce qu'on doit savoir** : [Question spécifique]

**Suggestion** : [Réponse proposée] - [Justification]

**Format** : Réponse courte (≤ 5 mots). Dites "oui" pour accepter la suggestion.
```

### 5. Processus interactif

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   1. CHARGER la spécification                                   │
│              │                                                  │
│              ▼                                                  │
│   2. ANALYSER les ambiguïtés (taxonomie)                        │
│              │                                                  │
│              ▼                                                  │
│   3. GÉNÉRER la file de questions (max 5)                       │
│              │                                                  │
│              ▼                                                  │
│   ┌─────────────────────────────────────────┐                   │
│   │  Pour chaque question (1 à la fois) :   │◄────┐             │
│   │                                         │     │             │
│   │  • Présenter la question                │     │             │
│   │  • Attendre la réponse                  │     │             │
│   │  • Valider la réponse                   │     │             │
│   │  • Mettre à jour la spec                │     │             │
│   │  • Passer à la suivante                 │     │             │
│   └────────────────┬────────────────────────┘     │             │
│                    │                              │             │
│                    ▼                              │             │
│   Arrêter si : • 5 questions posées              │             │
│                • Plus d'ambiguïtés critiques     │             │
│                • Utilisateur dit "stop/done"     │             │
│                                                                 │
│              ▼                                                  │
│   4. RAPPORT de clarification                                   │
│              │                                                  │
│              ▼                                                  │
│   5. Suggérer /work-plan                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 6. Mise à jour de la spécification

Après chaque réponse acceptée :

1. **Ajouter une section Clarifications** (si absente) :
```markdown
## Clarifications

### Session [DATE]
- Q: [Question posée] → R: [Réponse finale]
```

2. **Mettre à jour la section appropriée** :
   - Ambiguïté fonctionnelle → Mettre à jour Exigences Fonctionnelles
   - Distinction d'acteur → Mettre à jour User Stories
   - Entité/donnée → Mettre à jour Entités Clés
   - Contrainte non-fonctionnelle → Ajouter critère mesurable
   - Cas limite → Ajouter dans Cas Limites

3. **Supprimer les marqueurs [CLARIFICATION NÉCESSAIRE]** résolus

### 7. Rapport de fin de session

```markdown
## Rapport de clarification

**Questions posées** : [N] / 5
**Spec mise à jour** : specs/[feature]/spec.md

### Sections modifiées
- [Liste des sections touchées]

### Couverture par catégorie

| Catégorie | Statut |
|-----------|--------|
| Scope fonctionnel | ✅ Résolu |
| Modèle de données | ✅ Clair |
| Flux UX | ⏸️ Différé |
| Qualité non-fonctionnelle | ⚠️ Partiel |
| Intégrations | ✅ Clair |
| Cas limites | ⚠️ À surveiller |

### Recommandation

[Si tout est clair] : Prêt pour `/work-plan`
[Si des points restent] : Envisager une autre session `/work-clarify` après le plan
```

## Comportements spéciaux

### Aucune ambiguïté détectée
```
Aucune ambiguïté critique détectée nécessitant clarification.
La spécification est suffisamment complète pour procéder.

Recommandation : Lancer `/work-plan` pour créer le plan d'implémentation.
```

### Spécification non trouvée
```
Fichier de spécification non trouvé.
Veuillez d'abord créer une spécification avec `/work-specify`.
```

### Arrêt anticipé par l'utilisateur
Si l'utilisateur dit "stop", "done", "c'est bon", "ok pour la suite" :
- Terminer la session immédiatement
- Sauvegarder les clarifications déjà faites
- Générer le rapport partiel

## Agents liés

| Avant | Agent | Après |
|-------|-------|-------|
| `/work-specify` | Spécification | |
| | **CLARIFY** | |
| | | `/work-plan` |

---

IMPORTANT: Maximum 5 questions par session - prioriser par impact.

YOU MUST poser UNE question à la fois et attendre la réponse.

YOU MUST toujours proposer une recommandation basée sur les bonnes pratiques.

YOU MUST mettre à jour la spec après CHAQUE réponse acceptée.

NEVER révéler les questions suivantes à l'avance.

NEVER poser de questions dont la réponse n'impacte pas significativement l'implémentation.

Think hard sur l'impact de chaque clarification avant de poser la question.
