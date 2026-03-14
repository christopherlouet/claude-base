# Agent WORK-TEAM

Lance une equipe d'agents coordonnes (Agent Teams) pour paralleliser le travail.

## Contexte
$ARGUMENTS

## Objectif

Decomposer une tache complexe en sous-taches et les distribuer a des agents specialises.
Chaque agent travaille en parallele sur son perimetre, le lead synthetise les resultats.

## Workflow

- Verifier que Agent Teams est active (`$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` = 1)
- Analyser la tache et choisir le pattern adapte (voir ci-dessous)
- Spawner les agents avec des roles clairs et des perimetres distincts
- Coordonner via task list, messagerie directe, mode delegate si > 3 agents
- Synthetiser les resultats en rapport consolide
- Cleanup : shutdown chaque agent + nettoyage ressources

## Patterns disponibles

| Mots-cles | Pattern | Agents |
|-----------|---------|--------|
| audit, qualite, securite | **Audit** | security-reviewer, perf-analyst, a11y-checker |
| feature, implementer | **Feature** | backend-dev, frontend-dev, test-writer |
| bug, investiguer, debug | **Debug** | 3-5 investigators avec hypotheses differentes |
| review, code review | **Review** | security-reviewer, perf-reviewer, quality-reviewer |
| Autre | **Custom** | Decrire la structure |

Patterns detailles dans `.claude/skills/agent-teams/patterns.md`.

## Output attendu

1. **Equipe** : Agents crees avec roles et perimetres
2. **Rapport consolide** : Resultats par agent + synthese + priorites
3. **Cleanup** : Confirmation shutdown de tous les agents

## Agents lies

| Agent | Usage |
|-------|-------|
| `/work:work-explore` | Explorer AVANT de lancer une equipe |
| `/work:work-plan` | Planifier AVANT un pattern Feature |
| `/qa:qa-audit` | Alternative single-agent a l'audit |

---

IMPORTANT: Toujours verifier que Agent Teams est active avant de creer une equipe.

YOU MUST choisir le pattern adapte a la tache.

YOU MUST nettoyer l'equipe apres utilisation (shutdown + cleanup).

NEVER lancer plus de 5 agents sans avertir sur le cout tokens.

NEVER faire travailler 2 agents sur le meme fichier.

Think hard sur la decomposition de la tache avant de spawner les agents.
