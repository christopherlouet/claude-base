# Agent WORK-TEAM

Lancer une equipe d'agents coordonnes (Agent Teams) pour paralleliser le travail.

## Contexte
$ARGUMENTS

## Prerequis

Verifier que Agent Teams est active :

```bash
# Doit retourner "1"
echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
```

Si non active, ajouter dans `.claude/settings.local.json` :
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## Processus

```
┌─────────────────────────────────────────────────────────────────┐
│                    WORKFLOW AGENT TEAMS                          │
├─────────────────────────────────────────────────────────────────┤
│  1. ANALYSER   → Comprendre la tache et choisir le pattern     │
│  2. CREER      → Creer l'equipe et spawner les agents          │
│  3. COORDONNER → Gerer les taches et la communication          │
│  4. SYNTHETISER→ Combiner les resultats                        │
│  5. CLEANUP    → Shutdown propre et nettoyage                  │
└─────────────────────────────────────────────────────────────────┘
```

### Etape 1 : Analyser la tache

Identifier le pattern adapte selon la demande :

| Mots-cles detectes | Pattern recommande |
|--------------------|-------------------|
| "audit", "qualite", "securite + perf + a11y" | **Audit** (3-4 agents) |
| "feature", "implementer", "developper", "multi-couches" | **Feature** (2-3 agents) |
| "bug", "investiguer", "debug", "cause racine" | **Debug** (3-5 agents) |
| "review", "code review", "verifier" | **Review** (3 agents) |
| Autre | **Custom** (decrire la structure) |

### Etape 2 : Creer l'equipe

Utiliser les patterns pre-configures dans `.claude/skills/agent-teams/patterns.md` :

#### Pattern Audit
```
Cree une equipe pour auditer ce projet :
- security-reviewer : audit OWASP Top 10, injections, auth, donnees sensibles
- perf-analyst : performance, Core Web Vitals, requetes lentes, bundle size
- a11y-checker : accessibilite WCAG 2.1 AA, contraste, navigation clavier
Chacun produit un rapport avec severite. Synthetise les resultats quand tous ont termine.
```

#### Pattern Feature
```
Cree une equipe pour implementer [description] :
- backend-dev : services et API (ne touche PAS au frontend)
- frontend-dev : composants et hooks (attend les types du backend)
- test-writer : tests unitaires et integration (commence en TDD)
Gere les dependances via la task list. Backend definit les types en premier.
```

#### Pattern Debug
```
Cree une equipe pour investiguer ce bug : [description]
Spawne 3 agents avec des hypotheses differentes :
- investigator-1 : hypothese [A]
- investigator-2 : hypothese [B]
- investigator-3 : hypothese [C]
Mode adversarial : chacun challenge les hypotheses des autres.
Synthetise le consensus.
```

#### Pattern Review
```
Cree une equipe pour reviewer les changements :
- security-reviewer : vulnerabilites et securite
- perf-reviewer : performance et complexite algorithmique
- quality-reviewer : qualite, tests et respect des patterns
Chacun produit une liste de findings. Consolide en un rapport unique.
```

### Etape 3 : Coordonner

- Verifier l'avancement via la **task list** (`Ctrl+T`)
- Rediriger les agents si necessaire via **messagerie directe** (`Shift+Up/Down`)
- Pour les equipes > 3 agents, activer le **mode delegate** (`Shift+Tab`)
- Gerer les **dependances** : une tache bloquee attend ses prerequis

### Etape 4 : Synthetiser

Le lead combine les resultats de tous les agents :

```markdown
## Rapport consolide

### [Agent 1: Role] - Resultats
[Resume des findings]

### [Agent 2: Role] - Resultats
[Resume des findings]

### [Agent 3: Role] - Resultats
[Resume des findings]

### Synthese et priorites
[Vue d'ensemble, actions recommandees par priorite]
```

### Etape 5 : Cleanup

```
Demande a chaque teammate de s'arreter, puis nettoie l'equipe.
```

Le lead :
1. Envoie un shutdown request a chaque teammate
2. Attend la confirmation
3. Execute le cleanup pour supprimer les ressources

## Gestion des erreurs

| Probleme | Solution |
|----------|----------|
| Un agent ne repond plus | Le redemarrer ou redistribuer sa tache |
| Conflit de fichiers | Alerter, le lead arbitre et reassigne |
| Agent Teams non active | Guider vers l'activation (settings.json) |
| tmux non disponible | Utiliser le mode in-process (defaut) |
| Trop d'agents (> 5) | Avertir sur le cout tokens, recommander 3-4 |

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/work:work-explore` | Explorer AVANT de lancer une equipe |
| `/work:work-plan` | Planifier AVANT un pattern Feature |
| `/qa:qa-audit` | Alternative single-agent a l'audit |
| `/dev:dev-tdd` | Pour le TDD au sein d'un pattern Feature |

---

IMPORTANT: Toujours verifier que Agent Teams est active avant de creer une equipe.

YOU MUST choisir le pattern adapte a la tache.

YOU MUST utiliser le mode delegate pour les equipes > 3 agents.

YOU MUST nettoyer l'equipe apres utilisation (shutdown + cleanup).

NEVER lancer plus de 5 agents sans avertir sur le cout tokens.

NEVER faire travailler 2 agents sur le meme fichier.

Think hard sur la decomposition de la tache avant de spawner les agents.
