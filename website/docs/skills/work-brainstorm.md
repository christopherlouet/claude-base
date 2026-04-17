---
sidebar_position: 46
title: "work-brainstorm"
description: "Ideation structuree avant specification. Transformer une idee vague en design valide via questionnement et exploration d'alternatives. Declencher quand l'utilisateur a une idee floue, veut explorer des approches, ou hesite entre plusieurs directions."
tags:
  - "skill"
  - "fork"
---

# Skill: work-brainstorm

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Ideation structuree avant specification. Transformer une idee vague en design valide via questionnement et exploration d'alternatives. Declencher quand l'utilisateur a une idee floue, veut explorer des approches, ou hesite entre plusieurs directions.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Glob`, `Grep` |
| **Mots-cles** | `work`, `brainstorm`, `j'ai une idee vague`, `voici les user stories`, `pourquoi`, `tbd`, `a definir` |

## Description detaillee

# Brainstorming Structure

## Objectif

Transformer une idee brute en design approuve AVANT de specifier ou d'implementer.
Phase d'ideation entre "j'ai une idee vague" et "voici les user stories".

```
Idee vague → BRAINSTORM → Design valide → /work:work-specify → /work:work-plan → /dev:dev-tdd
```

## Iron Rule

IMPORTANT: Ne PAS invoquer de skill d'implementation, ecrire du code, scaffolder un projet, ou prendre toute action d'implementation tant que le design n'a pas ete presente ET approuve par l'utilisateur.

## Process

### 1. Explorer le contexte

Avant de proposer quoi que ce soit :

- Lire les fichiers du projet pertinents (architecture, code existant, CLAUDE.md)
- Verifier les changements recents (`git log --oneline -10`)
- Identifier les contraintes techniques existantes
- Comprendre le "pourquoi" derriere l'idee

### 2. Clarifier par questionnement

Poser des questions de clarification **une par une** (pas un bloc de 10 questions).

| Type de question | Exemple |
|------------------|---------|
| **Objectif** | "Quel probleme ca resout pour l'utilisateur ?" |
| **Scope** | "Ca doit fonctionner avec X ou c'est independant ?" |
| **Contraintes** | "Y a-t-il des limites de temps, budget, ou tech ?" |
| **Utilisateurs** | "Qui va utiliser ca ? Dans quel contexte ?" |
| **Succes** | "Comment on saura que ca marche bien ?" |

Arreter de questionner quand on a assez de contexte pour proposer des alternatives.

### 3. Proposer 2-3 approches

Pour chaque approche, presenter :

```markdown
### Approche A : [Nom descriptif]

**Principe** : [1-2 phrases]

**Avantages** :
- [Avantage 1]
- [Avantage 2]

**Inconvenients** :
- [Inconvenient 1]
- [Inconvenient 2]

**Complexite** : [Faible / Moyenne / Elevee]

**Risques** :
- [Risque 1]
```

### 4. Challenger les approches

Apres avoir presente les alternatives :

- Appliquer YAGNI : "Est-ce qu'on a vraiment besoin de X ?"
- Chercher la solution la plus simple qui fonctionne
- Identifier les pieces qui peuvent etre reportees (P2/P3)
- Verifier qu'il n'existe pas deja une solution dans le codebase ou les dependances

### 5. Converger sur un design

Une fois que l'utilisateur a choisi une direction :

- Decomposer le systeme en unites avec un seul objectif clair
- Definir les interfaces entre les unites
- S'assurer que chaque unite peut etre testee independamment
- Presenter section par section, en demandant validation a chaque etape

### 6. Documenter le design

Ecrire le design dans un fichier :

```
docs/designs/YYYY-MM-DD-[topic]-design.md
```

Format :

```markdown
# Design : [Titre]

**Date** : YYYY-MM-DD
**Statut** : Approuve / En discussion

## Contexte
[Pourquoi ce design est necessaire]

## Decision
[Approche choisie et pourquoi]

## Alternatives considerees
[Approches rejetees et pourquoi]

## Design detaille
[Decomposition en composants, interfaces, flux]

## Risques identifies
[Risques et mitigations]

## Hors scope
[Ce qui n'est PAS inclus dans ce design]
```

### 7. Self-review

Avant de presenter le design final, verifier :

- [ ] Pas de placeholders ("TBD", "a definir", "TODO")
- [ ] Pas de contradictions entre sections
- [ ] Pas d'ambiguites (chaque terme a une seule interpretation)
- [ ] YAGNI applique (pas de features speculatives)
- [ ] Chaque composant est testable independamment
- [ ] Les interfaces entre composants sont explicites

### 8. Handoff

Une fois le design approuve, proposer :

```
Design approuve. Prochaines etapes :
1. `/work:work-specify` — Transformer ce design en user stories testables
2. `/work:work-plan` — Planifier l'implementation technique
```

## Principes de design

- **Decomposer** en unites qui ont chacune un objectif clair
- **Interfaces explicites** entre les unites
- **Testable independamment** : chaque unite peut etre testee seule
- **YAGNI** : pas de features speculatives, pas de generalisation prematuree
- **Simplicite** : la solution la plus simple qui fonctionne est la meilleure
- **Reversibilite** : preferer les decisions faciles a changer

## Output attendu

```markdown
## Brainstorm : [Titre]

### Contexte
[Ce qu'on a compris du besoin]

### Approches explorees
| Approche | Forces | Faiblesses | Complexite |
|----------|--------|------------|------------|
| A : [...] | [...] | [...] | Faible |
| B : [...] | [...] | [...] | Moyenne |
| C : [...] | [...] | [...] | Elevee |

### Decision
**Approche retenue** : [X]
**Raison** : [Pourquoi cette approche]

### Design
[Decomposition, interfaces, flux]

### Prochaines etapes
1. `/work:work-specify` pour les user stories
2. `/work:work-plan` pour le plan technique
```

## Agents lies

| Avant | Usage |
|-------|-------|
| `/work:work-explore` | Comprendre le contexte technique |

| Apres | Usage |
|-------|-------|
| `/work:work-specify` | User stories et criteres d'acceptation |
| `/work:work-plan` | Plan d'implementation technique |

## Regles

- TOUJOURS explorer le contexte avant de proposer
- TOUJOURS proposer au moins 2 approches avec trade-offs
- NE JAMAIS implementer avant approbation explicite du design
- Poser les questions de clarification UNE PAR UNE
- Appliquer YAGNI systematiquement
- Documenter les alternatives rejetees (pas seulement la choisie)

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux work..."_
- _"Je veux brainstorm..."_
- _"Je veux j'ai une idee vague..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
