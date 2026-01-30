---
name: writing-skills
description: Guide pour creer de nouveaux skills pour le socle Claude Code. Declencher quand l'utilisateur veut creer un skill, ajouter une commande, ou etendre le socle.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# Creer de Nouveaux Skills

## Objectif

Framework pour creer des skills de qualite pour le socle Claude Code, en respectant les conventions et la structure existante.

## Structure d'un skill

```
.claude/skills/<nom-du-skill>/
└── SKILL.md
```

### Format du SKILL.md

```yaml
---
name: mon-skill
description: Description claire du skill. Declencher quand [contexte d'activation].
allowed-tools:
  - Read
  - Write      # Si le skill modifie des fichiers
  - Edit       # Si le skill edite des fichiers existants
  - Bash       # Si le skill execute des commandes
  - Glob       # Recherche de fichiers
  - Grep       # Recherche dans le contenu
context: fork  # Toujours fork pour isolation
---

# Titre du Skill

## Objectif
[Description claire de ce que fait le skill]

## Instructions
[Instructions detaillees, structurees en etapes]

## Output attendu
[Format de sortie attendu]

## Regles
[Regles obligatoires pour le skill]
```

## Champs Frontmatter Disponibles (Claude Code 2.1+)

Tous les champs disponibles dans le frontmatter YAML d'un skill :

| Champ | Requis | Description |
|-------|--------|-------------|
| `name` | Non | Nom du skill (defaut: nom du dossier). Minuscules, chiffres, tirets (max 64 chars) |
| `description` | Recommande | Ce que fait le skill et quand l'utiliser. Claude utilise ceci pour decider quand charger le skill |
| `allowed-tools` | Non | Outils autorises sans demande de permission |
| `context` | Non | `fork` pour execution dans un sub-agent isole |
| `model` | Non | Modele a utiliser: `sonnet`, `opus`, `haiku`, `inherit` (defaut: herite du contexte) |
| `agent` | Non | Type de sub-agent quand `context: fork` (`Explore`, `Plan`, `general-purpose`, ou agent custom) |
| `disable-model-invocation` | Non | `true` = invocation manuelle uniquement (Claude ne peut pas auto-charger). Defaut: `false` |
| `user-invocable` | Non | `false` = invisible dans le menu `/` (skills background). Defaut: `true` |
| `argument-hint` | Non | Hint d'autocompletion affiche dans le menu `/`. Ex: `[issue-number]` ou `[filename] [format]` |
| `hooks` | Non | Hooks scopes au lifecycle du skill (PreToolUse, PostToolUse, Stop) |

### Substitutions de variables

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | Tous les arguments passes au skill |
| `$ARGUMENTS[N]` | Argument par index (0-based) |
| `$N` | Raccourci pour `$ARGUMENTS[N]` |
| `${CLAUDE_SESSION_ID}` | ID de la session courante |

### Injection de contexte dynamique

Utiliser la syntaxe backtick-bang pour injecter des donnees live:
- Exemple: `!` suivi de backtick puis `gh pr diff` puis backtick
- La commande s'execute AVANT que Claude ne voie le contenu
- Le resultat remplace le placeholder

Exemple:
```markdown
## Contexte PR
- Diff: !`gh pr diff`
- Fichiers: !`gh pr diff --name-only`
```

### Bonnes pratiques frontmatter

- SKILL.md < 500 lignes (deporter le detail dans des fichiers de reference via `supporting files`)
- Budget descriptions: 15,000 chars max (variable `SLASH_COMMAND_TOOL_CHAR_BUDGET`)
- Fichiers de support: `examples/`, `scripts/`, `reference.md` dans le dossier du skill
- Utiliser `disable-model-invocation: true` pour les skills qui ne doivent etre lances que manuellement (ex: commit, PR, plan)
- Utiliser `user-invocable: false` pour les skills de contexte/background que Claude charge automatiquement (state-management, api-mocking)
- Utiliser `model: sonnet` pour les skills complexes necessitant un raisonnement approfondi (debug, securite, TDD, perf)
- Utiliser `argument-hint` pour guider l'utilisateur sur les parametres attendus

## Checklist de qualite d'un skill

### Structure

```
[ ] Frontmatter YAML valide (name, description, allowed-tools, context)
[ ] Nom en kebab-case
[ ] Description avec contexte de declenchement
[ ] Tools minimaux necessaires (principe du moindre privilege)
[ ] context: fork (isolation)
```

### Contenu

```
[ ] Objectif clair en 1-2 phrases
[ ] Instructions structurees en etapes numerotees
[ ] Exemples de code pertinents
[ ] Output attendu avec template
[ ] Regles et contraintes explicites
[ ] Diagramme ASCII si workflow complexe
```

### Qualite

```
[ ] Actionnable (pas juste informatif)
[ ] Specifique (pas generique)
[ ] Testable (resultats verifiables)
[ ] Autonome (pas de dependance sur d'autres skills)
[ ] Coherent avec les conventions du socle
```

## Conventions du socle

### Nommage

| Type | Convention | Exemples |
|------|-----------|----------|
| Skills dev | `dev-*` | `dev-tdd`, `dev-debug`, `dev-api` |
| Skills QA | `qa-*` | `qa-review`, `qa-security` |
| Skills ops | `ops-*` | `ops-docker`, `ops-ci` |
| Skills doc | `doc-*` | `doc-generate`, `doc-changelog` |
| Skills growth | `growth-*` | `growth-seo`, `growth-cro` |
| Skills biz | `biz-*` | `biz-model`, `biz-mvp` |
| Skills legal | `legal-*` | `legal-rgpd` |
| Skills data | `data-*` | `data-pipeline` |
| Skills workflow | `work-*` | `work-explore`, `work-plan` |
| Skills meta | Nom descriptif | `parallel-agents`, `session-handoff` |

### Patterns de contenu

```
1. Diagramme ASCII du workflow (si applicable)
2. Etapes numerotees avec sous-sections
3. Tableaux pour les references rapides
4. Blocs de code avec langage specifie
5. Section "Output attendu" avec template
6. Section "Regles" avec IMPORTANT/NEVER/YOU MUST
```

### Outils par type de skill

| Type de skill | Outils recommandes |
|---------------|-------------------|
| Lecture seule (audit, review) | Read, Glob, Grep |
| Developpement | Read, Write, Edit, Bash, Glob, Grep |
| Infrastructure | Read, Write, Edit, Bash, Glob, Grep |
| Documentation | Read, Write, Edit, Glob, Grep |
| Analyse | Read, Glob, Grep |

## Creer aussi les fichiers associes

### Commande (optionnel)

```
.claude/commands/<domaine>/<nom>.md
```

Format : prompt detaille avec `$ARGUMENTS`, workflow, output attendu, agents lies.

### Agent (optionnel)

```
.claude/agents/<nom>.md
```

Format : frontmatter YAML avec model, permissionMode, disallowedTools, skills, hooks.

### Rule (optionnel)

```
.claude/rules/<nom>.md
```

Format : frontmatter avec paths, regles contextuelles par type de fichier.

## Workflow de creation

```
1. IDENTIFIER le besoin (quel probleme ce skill resout ?)
2. NOMMER selon les conventions (domaine-action)
3. DEFINIR les outils necessaires (principe du moindre privilege)
4. ECRIRE le SKILL.md avec le template
5. CREER la commande associee si invocation manuelle necessaire
6. CREER l'agent associe si execution isolee necessaire
7. TESTER le skill (l'invoquer et verifier le resultat)
8. DOCUMENTER dans CLAUDE.md (table des skills)
```

## Regles

- Un skill = une responsabilite unique
- Description avec contexte de declenchement obligatoire
- Outils minimaux (pas de Write si le skill ne modifie rien)
- Toujours utiliser `context: fork` pour l'isolation
- Exemples concrets, pas de theorie abstraite
- Output attendu clairement defini
