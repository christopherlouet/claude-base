---
sidebar_position: 24
title: "socle-maintenance"
description: "Toute addition, suppression ou renommage dans `.claude/` casse silencieusement la doc et les tests si les compteurs ne sont pas synchronises. Le hook "
tags:
  - "rule"
  - "socle-maintenance"
---

# Regles: socle-maintenance

> Toute addition, suppression ou renommage dans `.claude/` casse silencieusement la doc et les tests si les compteurs ne sont pas synchronises. Le hook PostToolUse `socle-integrity-check` warn, mais ne 

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

- `.claude/skills/**`
- `.claude/agents/**`
- `.claude/commands/**`
- `.claude/rules/**`
- `.claude/settings.json`
- `scripts/hooks/**`

## Regles detaillees

# Socle Maintenance

## Principe

Toute addition, suppression ou renommage dans `.claude/` casse silencieusement la doc et les tests si les compteurs ne sont pas synchronises. Le hook PostToolUse `socle-integrity-check` warn, mais ne bloque pas — la discipline reste a la charge de celui qui modifie.

## Checklist obligatoire avant commit

| Verification | Commande | Bloquant |
|--------------|----------|----------|
| Compteurs doc coherents | `./scripts/validate-counts.sh` | Oui |
| Message SessionStart a jour | Inspecter `.claude/settings.json` (commandes / agents hardcodes) | Oui si ajout/suppression |
| Catalog a jour | Verifier `docs/reference/agents-catalog.md` et `docs/reference/skills-catalog.md` | Oui |
| Rules README a jour | `.claude/rules/README.md` : ligne + compteur en-tete | Oui si nouvelle rule |
| Audit structurel | `./scripts/audit-socle.sh` | Recommande |
| Shellcheck sur nouveaux hooks | `shellcheck scripts/hooks/*.sh` | Oui |

## Fichiers a mettre a jour quand on ajoute / supprime

### Nouvelle commande (`.claude/commands/&lt;ns&gt;/&lt;cmd&gt;.md`)

- `README.md` : ligne "Commandes Disponibles (N)" + mention inline
- `CLAUDE.md` : compteur "N commandes"
- `website/src/pages/index.tsx` : `'N Commands'`
- `website/docs/intro/architecture.md` : `Commands (N)`
- `website/docs/intro/index.md` : `Commands N`
- `website/docs/reference/cheatsheet.md` : `N Commands | M Agents`
- `website/src/components/FeatureComparison.tsx` : `commands: 'N'`
- `website/docusaurus.config.ts` : `Commands (N)`
- `docs/reference/commands.md` : entree catalog

### Nouvel agent (`.claude/agents/&lt;ns&gt;/&lt;agent&gt;.md`)

- Tous les fichiers `agents: 'N'` / `Agents (N)` / `N sub-agents`
- `docs/reference/agents-catalog.md` : entree avec description + use case
- `.claude/settings.json` SessionStart hook (compteur agents)

### Nouveau skill (`.claude/skills/&lt;skill&gt;/SKILL.md`)

- Tous les `skills: 'N'` / `N Skills`
- `docs/reference/skills-catalog.md` : entree avec trigger conditions
- `CLAUDE.md` : compteur "N skills"

### Nouvelle rule (`.claude/rules/&lt;rule&gt;.md`)

- `.claude/rules/README.md` : ligne dans le tableau + compteur "Regles disponibles (N)"
- `website/docs/reference/rules.md` si present
- Section "Ordre de priorite" si la rule a un niveau de priorite specifique

## Red Flags — STOP immediat

| Signal | Reaction |
|--------|----------|
| Ajout d'un fichier `.claude/*.md` sans MAJ des compteurs | STOP — lancer `./scripts/validate-counts.sh` |
| Rename d'une rule / agent / skill | STOP — chercher toutes les references avec Grep avant commit |
| Modification de `.claude/settings.json` sans test local | STOP — demarrer une session Claude et verifier le SessionStart hook |
| Hook qui depasse son timeout | STOP — profiler avant push, un hook lent bloque chaque prompt |
| Nouveau hook sans `|| true` ou bail-out | STOP — un hook qui fail casse la session pour tout le monde |

## Regles absolues

IMPORTANT: Ne JAMAIS pousser un commit qui ajoute/supprime dans `.claude/` sans avoir lance `./scripts/validate-counts.sh`.

IMPORTANT: Un hook `UserPromptSubmit` ou `PostToolUse` doit toujours bail-out rapidement (exit 0) si sa dependance est absente (`jq`, `gh`, `git`). Un hook qui error casse l'UX.

IMPORTANT: Les compteurs hardcodes dans le SessionStart hook sont la premiere chose que l'utilisateur voit a l'ouverture de Claude Code — un mauvais chiffre donne l'impression d'un socle mal maintenu.

NEVER committer un script dans `scripts/hooks/` sans shellcheck + test en conditions reelles.

NEVER dupliquer l'information de compteur ailleurs que dans les fichiers listes ci-dessus — centraliser dans `validate-counts.sh` comme source de verite.

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
