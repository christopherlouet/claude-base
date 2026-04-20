---
paths:
  - ".claude/skills/**"
  - ".claude/agents/**"
  - ".claude/commands/**"
  - ".claude/rules/**"
  - ".claude/settings.json"
  - "scripts/hooks/**"
---

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

### Nouvelle commande (`.claude/commands/<ns>/<cmd>.md`)

- `README.md` : ligne "Commandes Disponibles (N)" + mention inline
- `CLAUDE.md` : compteur "N commandes"
- `website/src/pages/index.tsx` : `'N Commands'`
- `website/docs/intro/architecture.md` : `Commands (N)`
- `website/docs/intro/index.md` : `Commands N`
- `website/docs/reference/cheatsheet.md` : `N Commands | M Agents`
- `website/src/components/FeatureComparison.tsx` : `commands: 'N'`
- `website/docusaurus.config.ts` : `Commands (N)`
- `docs/reference/commands.md` : entree catalog

### Nouvel agent (`.claude/agents/<ns>/<agent>.md`)

- Tous les fichiers `agents: 'N'` / `Agents (N)` / `N sub-agents`
- `docs/reference/agents-catalog.md` : entree avec description + use case
- `.claude/settings.json` SessionStart hook (compteur agents)

### Nouveau skill (`.claude/skills/<skill>/SKILL.md`)

- Tous les `skills: 'N'` / `N Skills`
- `docs/reference/skills-catalog.md` : entree avec trigger conditions
- `CLAUDE.md` : compteur "N skills"

### Nouvelle rule (`.claude/rules/<rule>.md`)

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
