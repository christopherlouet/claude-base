---
name: session-handoff
description: Transfert de contexte entre sessions IA. Declencher quand l'utilisateur veut sauvegarder le contexte, reprendre une tache, ou transmettre le travail a une autre session.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# Session Handoff

## Objectif

Sauvegarder et transmettre le contexte d'une session de travail pour permettre la reprise efficace dans une session ulterieure ou par un autre agent.

## Quand utiliser

- Fin de session de travail (sauvegarder l'etat)
- Tache trop complexe pour une seule session
- Passage de relais entre developpeurs/agents
- Documentation du travail en cours

## Format de handoff

### Fichier de contexte : `.claude/handoff.md`

```markdown
# Session Handoff

**Date:** [YYYY-MM-DD HH:MM]
**Session:** [ID ou description]
**Auteur:** [Humain ou agent]

## Contexte du projet

**Projet:** [Nom]
**Branche:** [Nom de la branche]
**Commit actuel:** [Hash]

## Etat du travail

### Termine
- [x] [Tache 1] - [Detail]
- [x] [Tache 2] - [Detail]

### En cours
- [ ] [Tache 3] - [Etat actuel, ou ca en est]
  - Fichiers modifies: [liste]
  - Prochaine etape: [description]
  - Blocage eventuel: [description]

### A faire
- [ ] [Tache 4] - [Description]
- [ ] [Tache 5] - [Description]

## Decisions prises

| Decision | Raison | Alternative rejetee |
|----------|--------|---------------------|
| [Choix 1] | [Pourquoi] | [Autre option] |
| [Choix 2] | [Pourquoi] | [Autre option] |

## Fichiers cles

| Fichier | Role | Etat |
|---------|------|------|
| `src/xxx.ts` | [Description] | Modifie / Cree / A modifier |
| `tests/xxx.test.ts` | [Description] | Modifie / Cree / A creer |

## Patterns et conventions decouverts

- [Pattern 1 du codebase]
- [Convention de nommage]
- [Architecture specifique]

## Problemes rencontres

| Probleme | Solution/Workaround | Resolu ? |
|----------|---------------------|----------|
| [Probleme 1] | [Solution] | Oui/Non |
| [Probleme 2] | [Workaround] | Partiel |

## Notes pour la prochaine session

[Instructions specifiques, pieges a eviter, points d'attention]

## Commandes utiles

```bash
# Pour reprendre
git checkout [branche]
npm test  # Verifier que tout passe
# Prochaine etape: [description]
```
```

## Workflow de handoff

### Sauvegarder le contexte (fin de session)

```
1. RESUMER le travail effectue
2. LISTER les fichiers modifies (`git diff --stat`)
3. DOCUMENTER les decisions prises et pourquoi
4. IDENTIFIER les taches restantes et leur priorite
5. NOTER les problemes non resolus
6. ECRIRE le fichier .claude/handoff.md
```

### Reprendre le contexte (debut de session)

```
1. LIRE le fichier .claude/handoff.md
2. VERIFIER l'etat du repo (`git status`, `git log`)
3. LANCER les tests pour confirmer l'etat
4. IDENTIFIER la prochaine tache a effectuer
5. CONTINUER le travail
```

## Bonnes pratiques

- Ecrire le handoff PENDANT le travail, pas apres
- Etre specifique sur les fichiers et lignes de code
- Inclure les commandes pour verifier l'etat
- Documenter les decisions ET les raisons
- Mentionner les pieges et workarounds decouverts

## Regles

- TOUJOURS creer un handoff avant de terminer une session de travail complexe
- TOUJOURS inclure les fichiers modifies et leur etat
- TOUJOURS documenter les decisions architecturales
- NEVER presumer que la prochaine session aura le meme contexte
