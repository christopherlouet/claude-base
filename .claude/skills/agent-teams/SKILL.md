---
name: agent-teams
description: Orchestration d'equipes d'agents avec Agent Teams natif. Declencher quand l'utilisateur veut lancer une equipe d'agents, coordonner du travail parallele avec communication inter-agents, ou utiliser le mode swarm.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
context: fork
---

# Agent Teams (Orchestration Multi-Agents)

> Coordonner plusieurs instances Claude Code travaillant ensemble en equipe, avec taches partagees, messagerie inter-agents et gestion centralisee.

## Prerequis

- **Claude Code >= 2.1.19**
- **Feature flag active** : `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`
- **tmux** (optionnel) : pour le mode split-panes

### Activation

Ajouter dans `.claude/settings.local.json` ou `.claude/settings.json` :

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Ou via variable d'environnement :

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

## Quand utiliser Agent Teams vs Sub-Agents

```
┌────────────────────────────────────────────────────────────────────┐
│           AGENT TEAMS vs SUB-AGENTS : GUIDE DE CHOIX               │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  AGENT TEAMS si:                                                   │
│  - Les agents doivent COMMUNIQUER entre eux                       │
│  - Travail COMPLEXE necessitant discussion et collaboration       │
│  - Taches avec coordination (review croisee, debat, consensus)    │
│  - 3+ agents travaillant en parallele sur une longue duree        │
│                                                                    │
│  SUB-AGENTS (Task tool) si:                                        │
│  - Tache FOCALISEE ou seul le resultat compte                     │
│  - Pas besoin de communication inter-agents                       │
│  - 1-2 agents pour des taches courtes                             │
│  - Economie de tokens prioritaire                                 │
│                                                                    │
│  SESSIONS PARALLELES MANUELLES (git worktrees) si:                 │
│  - Controle total sur chaque session                              │
│  - Pas besoin de coordination automatique                         │
│  - Travail sur des branches completement independantes            │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### Tableau comparatif

| | Sub-Agents (Task) | Agent Teams | Sessions manuelles |
|---|---|---|---|
| **Contexte** | Propre, resultat retourne | Propre, independant | Propre, independant |
| **Communication** | Retour au parent uniquement | Messagerie directe entre agents | Aucune (manuelle) |
| **Coordination** | Agent principal gere tout | Liste de taches partagee | Manuelle |
| **Cout tokens** | Faible | Eleve (1 contexte par agent) | Eleve |
| **Ideal pour** | Taches focalisees | Travail collaboratif complexe | Branches independantes |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AGENT TEAM                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────┐                                               │
│   │  TEAM LEAD   │ ←── Vous interagissez avec le lead            │
│   │  (coordonne) │                                               │
│   └──────┬───────┘                                               │
│          │                                                       │
│          ├──── Shared Task List ────┐                             │
│          │                          │                             │
│    ┌─────┴─────┐  ┌──────────┐  ┌──┴───────┐                    │
│    │ Teammate 1 │  │ Teammate 2│  │ Teammate 3│                   │
│    │ (securite) │  │ (perf)   │  │ (a11y)   │                   │
│    └────────────┘  └──────────┘  └──────────┘                    │
│          ↕              ↕              ↕                          │
│       Messagerie directe entre agents                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

| Composant | Role |
|-----------|------|
| **Team Lead** | Session principale, cree l'equipe, coordonne le travail |
| **Teammates** | Instances Claude Code independantes, executent les taches |
| **Task List** | Liste partagee de taches avec statuts et dependances |
| **Mailbox** | Systeme de messagerie pour la communication inter-agents |

## Modes d'affichage

| Mode | Description | Prerequis |
|------|-------------|-----------|
| `in-process` | Tous les teammates dans le terminal principal. Navigation: `Shift+Up/Down` | Aucun |
| `tmux` | Chaque teammate dans son propre pane tmux | tmux installe |
| `auto` (defaut) | Split-panes si deja dans tmux, sinon in-process | - |

Configuration dans `settings.json` :

```json
{
  "teammateMode": "auto"
}
```

Ou en ligne de commande :

```bash
claude --teammate-mode tmux
```

## Raccourcis clavier

| Raccourci | Action |
|-----------|--------|
| `Shift+Up/Down` | Naviguer entre teammates (mode in-process) |
| `Shift+Tab` | Basculer en mode delegate (lead = coordination uniquement) |
| `Ctrl+T` | Afficher/masquer la liste de taches |
| `Enter` | Entrer dans la session d'un teammate |
| `Escape` | Interrompre le turn d'un teammate |

## Cycle de vie d'une equipe

```
1. CREER l'equipe    → Decrire la tache et la structure souhaitee
       │
       ▼
2. SPAWN teammates   → Le lead cree les agents specialises
       │
       ▼
3. COORDONNER        → Taches partagees, messagerie, delegation
       │
       ▼
4. SYNTHETISER       → Le lead combine les resultats
       │
       ▼
5. SHUTDOWN          → Arreter chaque teammate proprement
       │
       ▼
6. CLEANUP           → Nettoyer les ressources de l'equipe
```

### Exemple de lancement

```
Cree une equipe de 3 agents pour auditer ce projet en parallele :
- Un agent securite (focus OWASP Top 10)
- Un agent performance (focus Core Web Vitals)
- Un agent accessibilite (focus WCAG 2.1 AA)
Chacun produit un rapport, puis synthetise les resultats.
```

### Mode Delegate (recommande pour les equipes > 3 agents)

Le mode delegate empeche le lead d'implementer lui-meme, le forcant a rester en coordination :
- Activer avec `Shift+Tab` apres avoir cree l'equipe
- Le lead ne peut que : spawner, envoyer des messages, gerer les taches, shutdown
- Recommande quand vous voulez que le lead se concentre sur l'orchestration

## Bonnes pratiques

- **2-5 teammates** : au-dela, la coordination devient couteuse en tokens
- **5-6 taches par agent** : suffisant pour garder les agents productifs
- **Isolation des fichiers** : chaque agent travaille sur des fichiers differents
- **Contexte explicite** : donner un prompt detaille a chaque teammate au spawn
- **Plan approval** : pour les taches risquees, demander au lead d'approuver le plan avant execution
- **Monitoring regulier** : verifier l'avancement, rediriger si necessaire

## Limitations connues

| Limitation | Contournement |
|------------|--------------|
| Pas de resume des teammates in-process | Le lead re-cree l'equipe apres `/resume` |
| Un seul team par session | Cleanup avant de creer un nouveau team |
| Pas d'equipes imbriquees | Seul le lead peut gerer l'equipe |
| Lead fixe (pas de transfert) | Le createur reste lead pour toute la duree |
| Deux agents sur le meme fichier = ecrasement | Decouper le travail par fichier |
| Split-panes non supporte dans VS Code / Windows Terminal | Utiliser le mode in-process |

## Patterns pre-configures

Voir @patterns.md pour les 4 patterns prets a l'emploi :

| Pattern | Teammates | Cas d'usage |
|---------|-----------|-------------|
| **Audit** | 3-4 agents (securite, perf, a11y, design) | Audit qualite complet |
| **Feature** | 2-3 agents (frontend, backend, tests) | Developpement multi-couches |
| **Debug** | 3-5 agents (hypotheses concurrentes) | Investigation de bugs complexes |
| **Review** | 3 agents (securite, perf, coverage) | Code review parallele |

## Exemple complet : Audit parallele

```
/work:work-team "Audit complet du projet"
```

Le lead va :
1. Creer une equipe "audit-team"
2. Spawner 3 teammates :
   - **security-reviewer** : "Audite le code pour les vulnerabilites OWASP Top 10. Focus sur l'authentification, les injections, et les donnees sensibles."
   - **perf-analyst** : "Analyse les performances. Focus sur les requetes lentes, le bundle size, et les Core Web Vitals."
   - **a11y-checker** : "Verifie l'accessibilite WCAG 2.1 AA. Focus sur le contraste, la navigation clavier, et les lecteurs d'ecran."
3. Chaque agent travaille independamment
4. Le lead synthetise en un rapport consolide
5. Shutdown et cleanup

## Exemple complet : Feature en equipe

```
/work:work-team "Implementer le systeme de notifications"
```

Le lead va :
1. Creer l'equipe et decomposer le travail :
   - **backend-dev** : "Implemente le service de notifications dans `src/services/notification.ts` et les endpoints API."
   - **frontend-dev** : "Cree le composant NotificationCenter dans `src/components/` et les hooks associes."
   - **test-writer** : "Ecris les tests unitaires et d'integration pour le systeme de notifications."
2. Gerer les dependances via la task list (backend avant frontend)
3. Le test-writer peut commencer par les tests (TDD) pendant que les devs planifient
4. Merge une fois tous les agents termines

## Voir aussi

- Skill `parallel-agents` pour l'orchestration via sub-agents Task
- Skill `git-worktrees` pour les sessions paralleles manuelles
- Skill `session-handoff` pour le transfert de contexte entre sessions
- `/work:work-team` pour la commande de lancement direct
