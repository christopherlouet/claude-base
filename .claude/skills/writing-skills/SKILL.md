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
