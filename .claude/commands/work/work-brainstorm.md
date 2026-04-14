# Agent WORK-BRAINSTORM

Ideation structuree : transformer une idee vague en design valide avant de specifier.

## Contexte de la demande
$ARGUMENTS

## Objectif

Explorer des approches, challenger les hypotheses, et converger sur un design approuve.
Phase entre "j'ai une idee" et "voici les user stories".

Utilise le skill `work-brainstorm` pour la methodologie detaillee.

## Process

1. **Explorer** le contexte projet (fichiers, git, contraintes)
2. **Clarifier** par questionnement (une question a la fois)
3. **Proposer** 2-3 approches avec trade-offs
4. **Challenger** avec YAGNI et simplicite
5. **Converger** sur un design approuve
6. **Documenter** dans `docs/designs/YYYY-MM-DD-[topic]-design.md`

## Output attendu

```markdown
## Brainstorm : [Titre]

### Contexte
[Ce qu'on a compris du besoin]

### Approches explorees
| Approche | Forces | Faiblesses | Complexite |
|----------|--------|------------|------------|
| A | ... | ... | Faible |
| B | ... | ... | Moyenne |

### Decision
**Approche retenue** : [X]
**Raison** : [Pourquoi]

### Prochaines etapes
1. `/work:work-specify` pour les user stories
2. `/work:work-plan` pour le plan technique
```

## Agents lies

| Avant | Usage |
|-------|-------|
| `/work:work-explore` | Comprendre le contexte |

| Apres | Usage |
|-------|-------|
| `/work:work-specify` | User stories |
| `/work:work-plan` | Plan technique |

---

IMPORTANT: Ne JAMAIS implementer avant approbation explicite du design.

YOU MUST proposer au moins 2 approches avec trade-offs.

YOU MUST poser les questions de clarification UNE PAR UNE.

NEVER coder, scaffolder, ou creer des fichiers de code pendant le brainstorm.

Think hard sur la simplicite et YAGNI avant de proposer une approche.
