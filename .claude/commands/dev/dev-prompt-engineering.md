# Agent PROMPT-ENGINEERING

Optimisation systematique de prompts pour applications LLM.

## Contexte
$ARGUMENTS

## Objectif

Ameliorer les prompts pour obtenir des reponses plus precises, coherentes et utiles des LLMs.

## Framework d'optimisation

### 1. Analyse du prompt actuel

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUDIT DU PROMPT                              │
├─────────────────────────────────────────────────────────────────┤
│ Clarte          [1-5] : Instructions ambigues ?                 │
│ Structure       [1-5] : Organisation logique ?                  │
│ Contexte        [1-5] : Informations suffisantes ?              │
│ Exemples        [1-5] : Few-shot learning ?                     │
│ Contraintes     [1-5] : Limites clairement definies ?           │
│ Format output   [1-5] : Format de sortie specifie ?             │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Techniques d'amelioration

| Technique | Description | Quand utiliser |
|-----------|-------------|----------------|
| **Few-shot** | Exemples de paires input/output | Taches complexes |
| **Chain-of-thought** | Demander le raisonnement etape par etape | Logique, calculs |
| **Role prompting** | Assigner un role d'expert | Taches specialisees |
| **Structured output** | Specifier le format JSON/XML | Integration API |
| **Negative prompting** | Specifier ce qu'il ne faut PAS faire | Eviter erreurs courantes |
| **Delimiter clarity** | Utiliser des delimiteurs clairs | Separations input/instructions |

### 3. Template de prompt optimise

```markdown
# Role
Tu es un [ROLE] expert en [DOMAINE].

# Contexte
[Description du contexte et de la situation]

# Tache
[Description precise de ce que le modele doit faire]

# Instructions
1. [Etape 1]
2. [Etape 2]
3. [Etape 3]

# Contraintes
- [Contrainte 1]
- [Contrainte 2]
- NE PAS [action a eviter]

# Exemples

## Exemple 1
Input: [exemple input]
Output: [exemple output attendu]

## Exemple 2
Input: [exemple input]
Output: [exemple output attendu]

# Format de sortie
[Specifier le format exact: JSON, markdown, liste, etc.]

```json
{
  "field1": "description",
  "field2": "description"
}
```
```

## Patterns avances

### Chain-of-thought prompting

```
Resous ce probleme etape par etape:

1. D'abord, identifie les elements cles
2. Ensuite, analyse les relations
3. Puis, formule une hypothese
4. Enfin, tire une conclusion

Montre ton raisonnement a chaque etape.
```

### Self-consistency

```
Genere 3 reponses differentes a cette question,
puis synthetise la meilleure reponse en combinant
les elements les plus pertinents.
```

### ReAct (Reasoning + Acting)

```
Pour cette tache, alterne entre:
- THOUGHT: Reflechis a ce que tu dois faire
- ACTION: Execute l'action necessaire
- OBSERVATION: Analyse le resultat

Continue jusqu'a avoir resolu le probleme.
```

## Evaluation des prompts

### Metriques

| Metrique | Description | Mesure |
|----------|-------------|--------|
| Precision | Reponse correcte | % bonnes reponses |
| Coherence | Reponses consistantes | Variance entre runs |
| Pertinence | Repond a la question | Score 1-5 |
| Format | Respecte le format demande | % conformite |
| Tokens | Efficacite | Tokens utilises |

### A/B Testing de prompts

```markdown
## Test A/B

### Prompt A (baseline)
[Prompt original]

### Prompt B (variante)
[Prompt modifie]

### Resultats (N=100)
| Metrique | Prompt A | Prompt B | Delta |
|----------|----------|----------|-------|
| Precision | 72% | 85% | +13% |
| Coherence | 3.2 | 4.1 | +0.9 |
```

## Anti-patterns a eviter

| Anti-pattern | Probleme | Solution |
|--------------|----------|----------|
| Prompt vague | Reponses inconsistantes | Etre specifique |
| Trop long | Perte de focus | Simplifier |
| Sans exemples | Mauvaise comprehension | Ajouter few-shot |
| Sans contraintes | Output imprevisible | Definir limites |
| Instructions contradictoires | Confusion | Relire et clarifier |

## Output attendu

### Analyse du prompt fourni

```markdown
## Analyse

**Score global**: [X/30]

### Points forts
- [Point 1]
- [Point 2]

### Points a ameliorer
- [Probleme 1] -> [Solution]
- [Probleme 2] -> [Solution]
```

### Prompt optimise

```markdown
## Prompt optimise

[Nouveau prompt complet avec toutes les ameliorations]

## Changements effectues

| Aspect | Avant | Apres | Impact |
|--------|-------|-------|--------|
| [Aspect] | [Avant] | [Apres] | [Impact] |
```

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev-rag` | Systemes de retrieval |
| `/dev-api` | Integration API LLM |
| `/qa-perf` | Performance des prompts |

---

IMPORTANT: Un bon prompt est reproductible et donne des resultats coherents.

IMPORTANT: Toujours tester avec plusieurs inputs avant de valider.

YOU MUST inclure des exemples (few-shot) pour les taches complexes.

NEVER ecrire de prompts ambigus ou trop generiques.
