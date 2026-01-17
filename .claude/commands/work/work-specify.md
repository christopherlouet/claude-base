# Agent WORK-SPECIFY

Tu es en mode SPÉCIFICATION. Crée une spécification fonctionnelle structurée.

## Contexte de la demande
$ARGUMENTS

## Objectif

Créer une spécification fonctionnelle complète et testable AVANT de planifier l'implémentation.
La spécification est l'étape entre l'exploration et la planification : **EXPLORE → SPECIFY → PLAN → CODE → COMMIT**

## Processus de spécification

### 1. Comprendre la demande

```
┌─────────────────────────────────────────────────────────────────┐
│                    ANALYSE DE LA DEMANDE                         │
├─────────────────────────────────────────────────────────────────┤
│  1. Identifier le QUOI (fonctionnalité)                          │
│  2. Identifier le POURQUOI (valeur utilisateur)                  │
│  3. NE PAS définir le COMMENT (implémentation technique)         │
│  4. Extraire les acteurs, actions, données, contraintes          │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Structure de la spécification

Utiliser le template suivant pour créer la spécification :

```markdown
# Spécification : [NOM DE LA FEATURE]

**Branche**: `feature/[nom-court]`
**Date**: [DATE]
**Statut**: Draft | En review | Validé

## Résumé

[1-3 phrases décrivant ce que la feature apporte à l'utilisateur]

## User Stories (prioritisées)

### US1 - [Titre court] (Priorité: P1) 🎯 MVP

**En tant que** [type d'utilisateur]
**Je veux** [action/fonctionnalité]
**Afin de** [bénéfice/valeur]

**Pourquoi P1**: [Explication de la valeur et pourquoi cette priorité]

**Test indépendant**: [Comment tester cette story de façon isolée]

**Critères d'acceptation**:

1. **Étant donné** [état initial], **Quand** [action], **Alors** [résultat attendu]
2. **Étant donné** [état initial], **Quand** [action], **Alors** [résultat attendu]

---

### US2 - [Titre court] (Priorité: P2)

[Même structure...]

---

### US3 - [Titre court] (Priorité: P3)

[Même structure...]

## Exigences Fonctionnelles

- **EF-001**: Le système DOIT [capacité spécifique]
- **EF-002**: Le système DOIT [capacité spécifique]
- **EF-003**: L'utilisateur DOIT pouvoir [interaction clé]

## Cas Limites (Edge Cases)

- Que se passe-t-il quand [condition limite] ?
- Comment le système gère-t-il [scénario d'erreur] ?
- Comportement avec [données vides/invalides] ?

## Entités Clés (si données impliquées)

| Entité | Description | Attributs clés |
|--------|-------------|----------------|
| [Entité 1] | [Ce qu'elle représente] | id, nom, ... |
| [Entité 2] | [Relations avec autres] | ... |

## Critères de Succès (mesurables)

- **CS-001**: [Métrique mesurable, ex: "Temps de complétion < 2 minutes"]
- **CS-002**: [Métrique mesurable, ex: "Taux de succès > 95%"]
- **CS-003**: [Métrique utilisateur, ex: "Satisfaction NPS > 8"]

## Hors Scope (explicitement exclus)

- [Fonctionnalité X] - sera traitée dans une future itération
- [Cas d'usage Y] - hors périmètre de cette feature

## Hypothèses et Dépendances

### Hypothèses
- [Hypothèse 1 sur le contexte]
- [Hypothèse 2 sur les utilisateurs]

### Dépendances
- [Dépendance externe ou interne]

## Points de Clarification

> Si des zones d'ombre subsistent, les lister ici pour `/work-clarify`

- [CLARIFICATION NÉCESSAIRE: question spécifique 1]
- [CLARIFICATION NÉCESSAIRE: question spécifique 2]
```

### 3. Règles de rédaction

#### Focus sur le QUOI, pas le COMMENT

| ✅ Correct (QUOI) | ❌ Incorrect (COMMENT) |
|-------------------|------------------------|
| "L'utilisateur peut créer un compte" | "Endpoint POST /api/users" |
| "Les données sont persistées" | "Utiliser PostgreSQL avec Prisma" |
| "Réponse en moins de 2 secondes" | "Cache Redis avec TTL 5 minutes" |
| "Authentification sécurisée" | "JWT avec refresh token" |

#### Critères de succès mesurables

| ✅ Mesurable | ❌ Vague |
|--------------|----------|
| "Temps de réponse < 1 seconde" | "Réponse rapide" |
| "99.9% de disponibilité" | "Système fiable" |
| "Support de 10 000 utilisateurs simultanés" | "Scalable" |
| "Taux d'erreur < 0.1%" | "Peu d'erreurs" |

#### User Stories indépendantes

Chaque User Story DOIT être :
- **I**ndépendante - Peut être développée seule
- **N**égociable - Détails peuvent évoluer
- **V**alorisable - Apporte de la valeur
- **E**stimable - Complexité évaluable
- **S**mall - Assez petite pour une itération
- **T**estable - Critères d'acceptation vérifiables

### 4. Checklist de validation

#### Complétude
- [ ] Toutes les user stories ont des critères d'acceptation
- [ ] Les exigences fonctionnelles sont listées
- [ ] Les cas limites sont identifiés
- [ ] Les critères de succès sont mesurables

#### Qualité
- [ ] Pas de détails d'implémentation technique
- [ ] Compréhensible par un non-développeur
- [ ] Pas de jargon technique inutile
- [ ] Scope clairement délimité

#### Testabilité
- [ ] Chaque exigence est vérifiable
- [ ] Critères d'acceptation sont précis (Given/When/Then)
- [ ] Métriques de succès quantifiables

## Output attendu

Générer un fichier de spécification dans `specs/[nom-feature]/spec.md` avec :

1. **Résumé** - Description concise de la valeur
2. **User Stories** - Prioritisées P1 > P2 > P3
3. **Exigences Fonctionnelles** - Liste des EF-XXX
4. **Cas Limites** - Scénarios edge cases
5. **Entités** - Si données impliquées
6. **Critères de Succès** - Métriques mesurables
7. **Hors Scope** - Ce qui est explicitement exclu
8. **Points de Clarification** - Questions ouvertes

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   /work-explore                                                 │
│         │                                                       │
│         ▼                                                       │
│   ┌─────────────────┐                                           │
│   │ /work-specify   │  ← VOUS ÊTES ICI                          │
│   └────────┬────────┘                                           │
│            │                                                    │
│            ▼                                                    │
│   ┌─────────────────┐     ┌─────────────────┐                   │
│   │ Points de       │────▶│ /work-clarify   │                   │
│   │ clarification?  │     │ (si nécessaire) │                   │
│   └────────┬────────┘     └────────┬────────┘                   │
│            │                       │                            │
│            └───────────┬───────────┘                            │
│                        │                                        │
│                        ▼                                        │
│              ┌─────────────────┐                                │
│              │   /work-plan    │                                │
│              └─────────────────┘                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Agents liés

| Avant | Agent | Après |
|-------|-------|-------|
| `/work-explore` | Exploration | |
| | **SPECIFY** | |
| | | `/work-clarify` (si ambiguïtés) |
| | | `/work-plan` |

---

IMPORTANT: Ne JAMAIS inclure de détails d'implémentation technique.

YOU MUST écrire pour des stakeholders non-techniques.

YOU MUST prioriser les User Stories (P1 = MVP, P2 = Important, P3 = Nice-to-have).

YOU MUST rendre chaque exigence testable et mesurable.

NEVER utiliser de jargon technique (API, database, framework...) dans la spec.

Maximum 3 points de [CLARIFICATION NÉCESSAIRE] - faire des choix éclairés pour le reste.

Think hard sur la VALEUR UTILISATEUR avant de rédiger.
