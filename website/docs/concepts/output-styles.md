---
sidebar_position: 8
title: Output Styles
description: Comprendre les styles de sortie Claude Code
---

# Output Styles

> Personnaliser le format et le ton des reponses de Claude

## Qu'est-ce qu'un Output Style ?

Un **output style** definit comment Claude formate ses reponses. Il permet d'adapter le ton, la structure et le niveau de detail selon le contexte.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  Sans style (defaut)              Avec style "concise"         │
│  ─────────────────────            ─────────────────────        │
│                                                                │
│  "Voici une explication          "La fonction calcule         │
│  detaillee de la fonction.       la somme. Retourne int."     │
│  Cette fonction prend deux                                     │
│  parametres et effectue                                        │
│  une operation de calcul..."                                   │
│                                                                │
│  Avec style "teaching"            Avec style "technical"       │
│  ─────────────────────            ──────────────────────       │
│                                                                │
│  "Commencons par comprendre      "Implementation O(n).         │
│  le concept. Une fonction        Complexite spatiale O(1).     │
│  est comme une recette de        Pattern: fold/reduce."        │
│  cuisine..."                                                   │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Structure des fichiers

Les output styles sont dans `.claude/output-styles/`:

```
.claude/output-styles/
├── README.md           # Documentation
├── teaching.md         # Mode pedagogique
├── explanatory.md      # Raisonnement detaille (recommande par Boris)
├── concise.md          # Reponses breves
├── technical.md        # Details techniques
├── review.md           # Revue de code
├── emoji.md            # Avec emojis
├── minimal.md          # Ultra minimal
├── structured.md       # Structure ASCII
├── debug.md            # Diagnostic et investigation
└── metrics.md          # Metriques et tableaux de bord
```

## Utilisation

### Activer un style

```bash
# Dans Claude Code
/output-style teaching
```

### Revenir au style par defaut

```bash
/output-style default
```

## Styles disponibles

### Teaching (Pedagogique)

**Quand l'utiliser:** Apprentissage, explications, onboarding

```markdown
## Caracteristiques

- Explications pas a pas
- Analogies et metaphores
- Questions pour verifier la comprehension
- Exemples progressifs

## Exemple de reponse

"Commencons par comprendre ce qu'est une Promise.

Imagine que tu commandes un cafe. Le serveur te donne un
ticket (la Promise) qui represente ton cafe futur.

Le ticket peut etre:
- En attente (pending) - le cafe est en preparation
- Resolu (fulfilled) - ton cafe est pret
- Rejete (rejected) - plus de cafe disponible

Maintenant, regardons le code..."
```

### Explanatory (Raisonnement detaille)

**Quand l'utiliser:** Comprendre le raisonnement, apprendre, onboarding

> Recommande par Boris Cherny : "Enable 'Explanatory' output style in /config for understanding rationale behind changes."

```markdown
## Caracteristiques

- Explique le POURQUOI avant le COMMENT
- Montre le raisonnement etape par etape
- Compare les alternatives et justifie le choix
- Anticipe les questions "mais pourquoi pas X ?"

## Exemple de reponse

"## Analyse du probleme

Ce composant recalcule filteredItems a chaque render, meme quand
les inputs n'ont pas change.

## Options considerees

### Option A: useMemo
Memoize le resultat. Recalcul uniquement si deps changent.

### Option B: Deplacer dans le parent
Plus simple mais couple le parent a la logique.

## Choix retenu: useMemo

**Raison principale**: Solution la plus simple pour notre cas (1-5k items).

## Points cles a retenir

1. useMemo evite les recalculs couteux, pas les renders
2. Toujours mesurer AVANT d'optimiser
3. La liste de dependances doit etre exhaustive"
```

### Concise (Bref)

**Quand l'utiliser:** Reponses rapides, utilisateurs experimentes

```markdown
## Caracteristiques

- Reponses directes
- Pas d'introduction
- Minimum de mots
- Code sans commentaires verbeux

## Exemple de reponse

"Utilise `useMemo`:

\`\`\`tsx
const value = useMemo(() => compute(data), [data]);
\`\`\`

Deps: array de dependances. Re-calcule si changement."
```

### Technical (Technique)

**Quand l'utiliser:** Discussions architecture, performance, debug avance

```markdown
## Caracteristiques

- Jargon technique
- Complexite algorithmique
- References aux specs
- Metriques et benchmarks

## Exemple de reponse

"Implementation optimale: O(n log n) avec merge sort.

Complexite:
- Temps: O(n log n) worst case
- Espace: O(n) pour le buffer

Alternative: quicksort O(n^2) worst case mais O(n log n)
average avec meilleure localite de cache.

Benchmark sur 10^6 elements:
- Merge sort: 234ms
- Quick sort: 189ms"
```

### Review (Revue de code)

**Quand l'utiliser:** Code reviews, audits, pull requests

```markdown
## Caracteristiques

- Structure par severite
- Suggestions concretes
- Liens vers documentation
- Points positifs inclus

## Exemple de reponse

"## Code Review

### Critical
- **L42**: SQL injection potentielle

### High
- **L23**: Pas de validation d'entree

### Medium
- **L56**: Magic number (utiliser constante)

### Positif
- Bonne separation des concerns
- Tests unitaires presents

### Conclusion
Bloquer jusqu'a fix L42."
```

### Emoji

**Quand l'utiliser:** Communication decontractee, feedback visuel

```markdown
## Caracteristiques

- Emojis pour illustrer
- Ton decontracte
- Listes avec icones
- Feedback visuel

## Exemple de reponse

"## Resume

✅ Tests passent
⚠️ 2 warnings eslint
❌ Type error ligne 42

### A faire
- 🔧 Fixer le type error
- 📝 Ajouter JSDoc
- 🧪 Couvrir edge case

🎉 Sinon c'est bon !"
```

### Minimal

**Quand l'utiliser:** Scripts, logs, output machine-readable

```markdown
## Caracteristiques

- Aucune decoration
- Pas d'intro/conclusion
- Facts only
- Parseable

## Exemple de reponse

"error: L42 type mismatch
fix: cast to string
file: src/utils.ts"
```

### Structured (Structure ASCII)

**Quand l'utiliser:** Documentation, rapports, presentations terminal

```markdown
## Caracteristiques

- Separateurs ASCII
- Sections claires
- Tableaux formates
- Hierarchie visuelle

## Exemple de reponse

"═══════════════════════════════════════
           RAPPORT D'AUDIT
═══════════════════════════════════════

┌─────────────────────────────────────┐
│ Fichiers analyses    │          42 │
│ Problemes critiques  │           2 │
│ Warnings             │          15 │
└─────────────────────────────────────┘

───────────────────────────────────────
Section 1: Securite
───────────────────────────────────────
..."
```

## Anatomie d'un output style

### Structure du fichier

```markdown
# Nom du Style

Description du style et quand l'utiliser.

## Instructions

Instructions detaillees pour Claude sur comment
formater ses reponses.

## Caracteristiques

- Point 1
- Point 2
- Point 3

## Exemple

Exemple de reponse dans ce style.
```

### Exemple complet

```markdown
# Teaching Style

Style pedagogique pour l'apprentissage et les explications.

## Instructions

Quand ce style est actif:

1. Commence par situer le concept dans un contexte familier
2. Utilise des analogies du quotidien
3. Procede par etapes incrementales
4. Pose des questions rhetoriques pour engager
5. Fournis des exemples concrets
6. Resume les points cles a la fin

## Ton

- Patient et encourageant
- Evite le jargon sans l'expliquer
- Celebre les progres

## Structure type

1. Introduction accessible
2. Analogie ou metaphore
3. Explication progressive
4. Exemple pratique
5. Resume / Points cles
6. Question de verification

## Exemple

"Excellente question ! Voyons ca ensemble.

Tu connais les boites de rangement ? Et bien, un array
en programmation, c'est exactement ca..."
```

## Creer un nouveau style

### 1. Creer le fichier

```bash
touch .claude/output-styles/mon-style.md
```

### 2. Definir le style

```markdown
# Mon Style

Description de mon style personnalise.

## Instructions

1. Regle 1
2. Regle 2
3. Regle 3

## Caracteristiques

- Caracteristique 1
- Caracteristique 2

## Exemple

Exemple de reponse avec ce style.
```

### 3. Utiliser

```bash
/output-style mon-style
```

## Bonnes pratiques

1. **Style adapte au contexte**: Teaching pour apprendre, Concise pour produire
2. **Coherence**: Garder le meme style dans une session
3. **Ne pas abuser**: Le style par defaut est souvent suffisant
4. **Documenter**: Expliquer quand utiliser chaque style

## Cas d'usage recommandes

| Situation | Style |
|-----------|-------|
| Onboarding nouveau dev | `teaching` |
| Comprendre un choix technique | `explanatory` |
| Code review PR | `review` |
| Debug rapide | `concise` |
| Discussion architecture | `technical` |
| Rapport d'audit | `structured` |
| Communication equipe | `emoji` |
| Script/automation | `minimal` |

---

## Voir aussi

- [Commands](./commands) - Instructions manuelles
- [Architecture](/docs/intro/architecture) - Vue d'ensemble
