---
sidebar_position: 3
title: "/assistant-auto"
description: "Orchestrateur en mode automatique. Choisis le workflow adapte semantiquement a partir de la demande + du contexte repo injecte, puis execute immediate"
tags:
  - "other"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--other">Autres</span>


# Agent ASSISTANT-AUTO (Routing Semantique)

Orchestrateur en mode automatique. Choisis le workflow adapte
semantiquement a partir de la demande + du contexte repo injecte,
puis execute immediatement via Skill.

## Contexte de la demande
`&lt;arguments&gt;`

## Principe

Tu recois :
1. La demande utilisateur (ci-dessus)
2. Le contexte repo (injecte par le hook UserPromptSubmit : branche,
   fichiers modifies, LOC diff, memoire perso)

Tu choisis UN workflow adapte, en tenant compte a la fois de l'intention
et de la **taille/complexite** detectable dans le contexte.

## Heuristique de taille (pondere le choix)

| Signal | Workflow par defaut |
|--------|---------------------|
| Diff &lt; 50 LOC et 1-3 fichiers, intention triviale | `work:work-quick` |
| Feature/bugfix standard | `work:work-flow-feature` / `work:work-flow-bugfix` |
| Release, tag de version | `work:work-flow-release` |
| Audit securite/qualite avant prod | `qa:qa-audit` ou `qa:qa-security` |
| Audit + correction en boucle jusqu'au score | `qa:qa-loop` |
| Backlog multi-stories (PRD) | `work:work-batch` |
| Equipe d'agents paralleles | `work:work-team` |
| Question pure (comprendre, expliquer) | Reponse directe, pas de workflow |

Ne te limite PAS a ce tableau. Tu connais la liste complete des skills
disponibles dans la session (commandes `work:`, `dev:`, `qa:`, `ops:`,
`doc:`, `biz:`, `growth:`, `legal:`, `data:`). Choisis le plus specifique
qui correspond (ex: `dev:dev-prisma` si schema Prisma mentionne,
`ops:ops-proxmox` si infra Proxmox, `dev:dev-shadcn` si shadcn/ui).

## Regle de priorite (conflits)

1. **Securite** avant tout : mot-cle "secret", "leak", "CVE" → `qa:qa-security`
2. **Memoire perso** : si le contexte injecte rappelle une preference
   utilisateur (ex: "review manuelle PRs infra"), respecte-la avant de
   router vers un workflow automatise.
3. **Taille** : un "corriger typo X" reste `work:work-quick` meme si le
   fichier touche de l'auth.
4. **Specifique &gt; generique** : `dev:dev-flutter` &gt; `dev:dev-component`
   si projet Flutter detecte dans le contexte.

## Output attendu

Afficher un resume bref (3 lignes max) puis invoquer Skill immediatement :

```
Demande : <1 ligne>
Contexte : <signal determinant — LOC, fichiers, branche>
Workflow : <nom qualifie>
```

Puis : `Skill(skill: "xxx", args: "demande originale")`

---

CRITICAL: Tu DOIS utiliser l'outil Skill apres l'analyse (pas de confirmation).

CRITICAL: Si aucun argument fourni, demander ce que l'utilisateur veut faire.

CRITICAL: Raisonne **semantiquement**, pas par mots-cles. "ajouter du
cache Redis" → `dev:dev-api` ou `qa:qa-perf` selon intention, pas un
match lexical sur "cache".

YOU MUST utiliser le nom qualifie complet du skill (ex: `work:work-flow-feature`).

YOU MUST passer la demande originale en argument au workflow.

YOU MUST integrer les signaux du contexte injecte (LOC, fichiers, memoire)
dans ta decision — c'est ce qui distingue un routing semantique d'un
simple mapping de mots-cles.


---

## Voir aussi

- [Retour aux commandes Autres](/docs/commands/other)
- [Toutes les commandes](/docs/commands)
