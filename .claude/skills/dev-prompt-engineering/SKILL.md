---
name: dev-prompt-engineering
description: Optimisation de prompts pour LLMs. Declencher quand l'utilisateur veut ameliorer un prompt, ajouter des exemples, ou structurer des instructions.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# Prompt Engineering Skill

## Declencheurs

Ce skill s'active quand l'utilisateur mentionne:
- "prompt", "instruction", "system message"
- "few-shot", "exemples"
- "ameliorer le prompt", "optimiser"
- "LLM", "GPT", "Claude"

## Methodologie

### 1. Analyser le prompt existant

Evaluer sur 6 criteres (score 1-5):

| Critere | Question |
|---------|----------|
| Clarte | Les instructions sont-elles precises ? |
| Structure | Organisation logique ? |
| Contexte | Informations suffisantes ? |
| Exemples | Few-shot learning present ? |
| Contraintes | Limites definies ? |
| Format | Output specifie ? |

### 2. Appliquer les techniques

| Technique | Quand utiliser |
|-----------|----------------|
| **Few-shot** | Taches complexes, format specifique |
| **Chain-of-thought** | Raisonnement, calculs, logique |
| **Role prompting** | Expertise specifique requise |
| **Structured output** | Integration API, parsing |
| **Negative prompting** | Eviter erreurs courantes |
| **Delimiters** | Separer sections clairement |

### 3. Structure optimale

```markdown
# Role
Tu es un [ROLE] expert en [DOMAINE].

# Contexte
[Description de la situation]

# Tache
[Ce que le modele doit accomplir]

# Instructions
1. [Etape 1]
2. [Etape 2]
3. [Etape 3]

# Contraintes
- [Ce qu'il faut faire]
- NE PAS [Ce qu'il ne faut pas faire]

# Exemples

## Exemple 1
Input: [exemple]
Output: [resultat attendu]

# Format de sortie
[Specifier exactement le format]
```

## Patterns avances

### Chain-of-thought

```
Resous ce probleme etape par etape:
1. Identifie les elements cles
2. Analyse les relations
3. Formule une hypothese
4. Tire une conclusion

Montre ton raisonnement.
```

### Self-consistency

```
Genere 3 approches differentes,
puis synthetise la meilleure reponse.
```

### ReAct

```
Alterne entre:
- THOUGHT: Reflechis
- ACTION: Execute
- OBSERVATION: Analyse
```

## Anti-patterns

| A eviter | Pourquoi | Solution |
|----------|----------|----------|
| Prompts vagues | Resultats inconsistants | Etre specifique |
| Trop long | Perte de focus | Simplifier |
| Sans exemples | Mauvaise comprehension | Few-shot |
| Sans contraintes | Output imprevisible | Definir limites |
| Contradictions | Confusion | Relire |

## Output

Pour chaque optimisation, fournir:

1. **Score avant**: X/30
2. **Points faibles identifies**
3. **Prompt optimise**
4. **Score apres**: Y/30
5. **Changements effectues**

## Regles

IMPORTANT: Un bon prompt donne des resultats coherents sur plusieurs runs.

IMPORTANT: Toujours inclure des exemples pour les taches complexes.

YOU MUST specifier le format de sortie attendu.

NEVER ecrire de prompts ambigus ou trop generiques.
