---
sidebar_position: 0
title: "Formation Claude Code"
description: "Formation complete sur Claude Code, prerequis avant d'utiliser le socle"
tags:
  - "guide"
  - "formation"
---

# Formation Claude Code

Ce guide est le prerequis obligatoire avant d'utiliser claude-socle. Il vous apprend a maitriser Claude Code lui-meme — l'outil CLI d'Anthropic — avant d'ajouter la couche de configuration du socle par-dessus.

| Module | Sujet | Duree |
|--------|-------|-------|
| 1 | Decouverte | 30 min |
| 2 | Interaction de base | 45 min |
| 3 | Permissions et securite | 30 min |
| 4 | Commandes natives | 30 min |
| 5 | Contexte et memoire | 30 min |
| 6 | Raccourcis clavier | 15 min |
| 7 | Configuration avancee | 30 min |
| 8 | Workflows pratiques | 30 min |
| 9 | Depannage | 15 min |

**Duree totale estimee : 3h45**

---

## Module 1 : Decouverte (30 min)

### Qu'est-ce que Claude Code ?

Claude Code n'est pas un chatbot, ni un plugin d'IDE. C'est un agent — un programme qui peut raisonner, planifier, et agir de facon autonome dans votre environnement de developpement.

| Outil | Type | Ce qu'il fait | Ce qu'il ne fait pas |
|-------|------|---------------|----------------------|
| ChatGPT / Claude.ai | Chatbot | Repond a des questions, explique du code | Lire vos fichiers, executer des commandes |
| GitHub Copilot | IDE Copilot | Autocomplete du code dans l'editeur | Agir en dehors de l'editeur, enchainer des taches |
| Claude Code | Agent CLI | Lit vos fichiers, ecrit du code, execute des commandes, enchaine des dizaines d'operations | (rien — il peut tout faire dans votre projet) |

La difference pratique : avec un chatbot, vous copiez-collez votre code dans le chat et vous recopiez la reponse dans votre fichier. Avec Claude Code, il lit directement `src/api/users.ts`, le modifie, lance les tests, et commite — sans que vous touchiez a quoi que ce soit.

### Ou utiliser Claude Code

Claude Code fonctionne dans plusieurs environnements :

| Environnement | Comment | Use case |
|---------------|---------|----------|
| Terminal | `claude` dans n'importe quel shell | Usage principal, acces complet |
| VS Code | Extension officielle ou terminal integre | Developper sans quitter l'editeur |
| JetBrains | Plugin officiel (IntelliJ, WebStorm, etc.) | Meme chose pour l'ecosysteme JetBrains |
| Desktop App | Application native Anthropic | Sessions longues avec interface enrichie |
| Web | claude.ai/code | Acces rapide depuis n'importe ou |

### Plans disponibles

| Plan | Prix | Modeles inclus | Particularites |
|------|------|----------------|----------------|
| Pro | ~20 $/mois | Sonnet, Haiku | Usage personnel |
| Max | ~100 $/mois | Opus, Sonnet, Haiku | 5x plus de tokens, mode `auto` |
| Team | ~25 $/user/mois | Opus, Sonnet, Haiku | Collaboration, mode `auto` |
| Enterprise | Negotie | Tous | SSO, audit logs, data residency |
| API | Pay-per-token | Tous | Integration CI/CD, scripts headless |

Le mode `auto` (qui approuve automatiquement les actions) est disponible a partir du plan Max, Team, et Enterprise. Sur le plan Pro, Claude Code demande une confirmation pour chaque action.

### Installation

**macOS / Linux (curl) :**
```bash
curl -fsSL https://claude.ai/install.sh | sh
```

**macOS (Homebrew) :**
```bash
brew install claude
```

**Windows (winget) :**
```powershell
winget install Anthropic.ClaudeCode
```

**Verification :**
```bash
claude --version
```

### Premier lancement

```bash
# Dans n'importe quel dossier de projet
cd mon-projet
claude
```

Au premier lancement, Claude Code ouvre votre navigateur pour vous authentifier avec votre compte Anthropic. Apres authentification, vous etes ramene au terminal avec le prompt `>` qui indique que Claude Code est pret.

### Interface : comprendre ce que vous voyez

```
> Explain the main entry point of this project        ← votre prompt

  Reading src/index.ts...                              ← tool call (lecture de fichier)
  Reading package.json...                              ← tool call

  Le point d'entree est `src/index.ts`. Il importe     ← reponse de Claude
  Express, configure les middlewares, et lance le
  serveur sur le port defini dans .env.

  [3 tool calls, 1.2k tokens]                          ← couts
>                                                       ← pret pour la prochaine interaction
```

Les "tool calls" (appels d'outils) sont les actions que Claude Code execute : lire un fichier, lancer une commande, ecrire du code. Vous les voyez en temps reel.

---

## Module 2 : Interaction de base (45 min)

### Taper un prompt naturel

Pas besoin de syntaxe speciale. Parlez normalement :

```
> Fix the null pointer error in getUserById
> Add input validation to the registration form
> Write unit tests for the CartService class
> Refactor this function to be more readable
> Explain why the CI is failing
```

Claude Code comprend le contexte de votre projet. Il lit les fichiers pertinents avant de repondre.

### Le prefixe `!` pour le bash direct

Pour executer une commande shell sans passer par Claude :

```bash
!ls -la
!git status
!npm test
!docker ps
```

Utile quand vous voulez voir quelque chose rapidement sans que Claude l'interprete.

### `@` pour mentionner des fichiers

```
> @src/services/auth.ts pourquoi cette fonction peut retourner undefined ?
> compare @src/v1/api.ts et @src/v2/api.ts
> ajoute des tests pour @src/utils/validators.ts
```

L'autocomplete fonctionne : tapez `@src/` et Tab pour naviguer dans l'arborescence.

### Entree multiligne

Quand votre prompt est long ou contient du code :

| Methode | Comment |
|---------|---------|
| `\` + Entree | Continue sur la ligne suivante |
| Option+Entree (macOS) | Nouvelle ligne sans envoyer |
| Ctrl+J | Nouvelle ligne sans envoyer (universel) |

Exemple :
```
> Refactorise cette fonction :\
  function calculate(a, b) { return a + b; }\
  Elle doit gerer les cas null et retourner 0 par defaut
```

### Copier-coller des images

Sur macOS et Linux avec support clipboard : `Ctrl+V` colle une image directement dans le prompt. Utile pour partager des screenshots d'erreurs, des maquettes UI, ou des diagrammes.

```
> [Ctrl+V — screenshot d'une erreur TypeScript]
  Explique cette erreur et corrige-la
```

### Mode vim

Si vous preferez la navigation vim pour editer vos prompts :

```
/vim
```

Tapez `/vim` pour basculer. Les modes `i` (insertion), `Esc` (normal), `dd` (supprimer ligne), `yy`/`p` (copier/coller) sont disponibles.

### Voice input

Sur macOS avec acces au microphone : maintenez `Espace` pour dicter votre prompt. Relacher envoie la transcription.

### Historique des prompts

| Action | Raccourci |
|--------|-----------|
| Prompt precedent | Fleche Haut |
| Prompt suivant | Fleche Bas |
| Recherche dans l'historique | Ctrl+R puis taper |

---

### Les outils de Claude Code (tools)

Claude Code utilise des "tools" pour agir. Vous les voyez s'executer en temps reel pendant une reponse.

| Tool | Role | Exemple d'utilisation |
|------|------|-----------------------|
| `Read` | Lire un fichier | Lire `src/index.ts` |
| `Write` | Creer un fichier | Creer `src/utils/format.ts` |
| `Edit` | Modifier un fichier existant | Corriger une fonction |
| `Bash` | Executer une commande shell | `npm test`, `git status` |
| `Glob` | Trouver des fichiers par pattern | Tous les `*.test.ts` |
| `Grep` | Chercher du contenu dans les fichiers | Toutes les occurrences de `userId` |
| `Agent` | Lancer un sous-agent | Deleguer une analyse complexe |
| `WebFetch` | Telecharger une URL | Lire la doc d'une librairie |
| `WebSearch` | Rechercher sur le web | Trouver la solution a une erreur |
| `NotebookEdit` | Modifier un notebook Jupyter | Ajouter une cellule Python |
| MCP tools | Capacites ajoutees par plugins | GitHub, base de donnees, Slack... |

Les tools MCP (Model Context Protocol) sont des extensions. Le socle en configure plusieurs (GitHub, filesystem, memory). Voir Module 7.

---

## Module 3 : Permissions et securite (30 min)

### Le dialog de permission

Quand Claude Code veut executer une action, il affiche un dialog :

```
Claude wants to run:
  rm -rf dist/

[Allow] [Deny] [Always Allow]
```

| Choix | Effet |
|-------|-------|
| Allow | Autorise cette action une seule fois |
| Deny | Refuse cette action, Claude trouve une autre approche |
| Always Allow | Autorise cette action pour toute la session |

### Les 5 modes de permission

| Mode | Description | Qui peut l'utiliser |
|------|-------------|---------------------|
| `default` | Demande confirmation pour chaque action | Tous |
| `acceptEdits` | Auto-approuve les modifications de fichiers, demande pour le reste | Tous |
| `plan` | Lecture seule, Claude peut lire mais pas modifier ni executer | Tous |
| `auto` | Approuve tout sauf les actions explicitement dangereuses | Max, Team, Enterprise, API |
| `bypassPermissions` | Approuve absolument tout (dangereux, a eviter) | API uniquement |

**`plan` mode** est particulierement utile : Claude lit votre code et vous propose un plan detaille sans rien toucher. Vous validez, puis vous changez de mode pour executer.

### Changer de mode pendant une session

`Shift+Tab` fait cycler entre les modes disponibles pour votre plan. L'indicateur de mode est affiche dans le prompt.

### Configurer les permissions dans settings.json

Pour autoriser ou interdire des tools specifiques de facon permanente :

```json
{
  "allowedTools": ["Read", "Write", "Edit", "Bash"],
  "disallowedTools": ["WebSearch", "WebFetch"]
}
```

Exemple pratique — autoriser tout sauf les commandes destructives :
```json
{
  "disallowedTools": ["Bash(rm *)", "Bash(git push --force)"]
}
```

Vous pouvez restreindre `Bash` a des commandes specifiques avec la syntaxe `Bash(commande)`.

---

## Module 4 : Commandes natives (30 min)

### Les slash commands integrees

Ces commandes sont disponibles dans toute session Claude Code, sans configuration supplementaire.

| Commande | Description | Quand l'utiliser |
|----------|-------------|------------------|
| `/help` | Affiche l'aide et la liste des commandes | N'importe quand |
| `/compact` | Compacte le contexte en conservant l'essentiel | Session longue, avant de changer de phase |
| `/clear` | Efface toute la conversation | Nouveau sujet sans rapport |
| `/config` | Ouvre les settings dans l'editeur | Modifier la configuration |
| `/cost` | Affiche la consommation tokens et couts de la session | Surveiller les couts |
| `/doctor` | Diagnostique les problemes d'installation et de configuration | Quand quelque chose ne marche pas |
| `/effort` | Change le niveau de raisonnement (low / medium / high) | Adapter la profondeur d'analyse |
| `/fast` | Active/desactive le mode rapide (meme modele, sortie acceleree) | Taches simples, gagner du temps |
| `/model` | Change de modele (Opus, Sonnet, Haiku) | Adapter le modele a la tache |
| `/memory` | Affiche toutes les instructions chargees (CLAUDE.md, rules, etc.) | Debugger le contexte |
| `/resume` | Reprend une session nommee precedente | Continuer une session interrompue |
| `/rewind` | Revient au checkpoint precedent (avant la derniere modification) | Annuler une modification qui a tout casse |
| `/theme` | Change le theme visuel (dark, light, etc.) | Preference personnelle |
| `/terminal-setup` | Configure Shift+Enter dans votre terminal | Installation initiale |
| `/vim` | Active/desactive le mode vim pour editer les prompts | Preference vim |
| `/btw` | Pose une question rapide sans polluer le contexte de la session | Questions secondaires |
| `/desktop` | Ouvre la session dans l'application Desktop | Passer au mode desktop |
| `/schedule` | Cree une tache planifiee recurrente | Automatisation |
| `/loop` | Repete un prompt a intervalles reguliers | Monitoring, polling |

### Exemples d'utilisation

```bash
# Voir combien cette session a coute
/cost

# Passer en mode lecture seule avant de laisser Claude analyser
/effort high
# puis demander l'analyse architecturale

# Revenir en arriere apres une modification catastrophique
/rewind

# Changer de modele pour une tache rapide
/model haiku

# Question rapide sur un point de detail sans impacter la session
/btw quelle est la difference entre null et undefined en TypeScript ?
```

---

## Module 5 : Contexte et memoire (30 min)

### La fenetre de contexte

Claude Code utilise une "fenetre de contexte" — la quantite totale d'informations qu'il peut traiter en meme temps (conversation, fichiers lus, resultats de commandes).

| Modele | Contexte | Equivalent approximatif |
|--------|----------|--------------------------|
| Haiku 4.5 | 200k tokens | ~150 000 mots |
| Sonnet 4.6 | 200k tokens | ~150 000 mots |
| Opus 4.6 | 1M tokens | ~750 000 mots (~5 romans) |

Quand le contexte est plein, les reponses deviennent moins precises (Claude "oublie" les debuts de session). `/compact` resout ce probleme.

### CLAUDE.md : le fichier d'instructions projet

`CLAUDE.md` est un fichier Markdown place a la racine de votre projet. Claude Code le lit automatiquement au debut de chaque session. C'est votre moyen de donner des instructions permanentes sans les retaper a chaque fois.

**Trois niveaux de CLAUDE.md :**

| Niveau | Emplacement | Versionne ? | Contenu typique |
|--------|-------------|-------------|-----------------|
| Projet | `/mon-projet/CLAUDE.md` | Oui (git) | Conventions, workflow, references de doc |
| Utilisateur | `~/.claude/CLAUDE.md` | Non (personnel) | Preferences perso, style de code prefere |
| Sous-dossier | `/mon-projet/src/CLAUDE.md` | Oui | Instructions specifiques a ce module |

**Exemple minimal de CLAUDE.md :**
```markdown
# Mon Projet

## Conventions
- TypeScript strict mode, pas de `any`
- Tests avec Vitest, couverture 80% minimum
- Commits en Conventional Commits

## Stack
- Frontend : React + TypeScript
- Backend : Node.js + Express
- Base de donnees : PostgreSQL
```

**@imports pour inclure d'autres fichiers :**

Plutot que de tout mettre dans CLAUDE.md, vous pouvez inclure d'autres fichiers :

```markdown
# Mon Projet

@docs/conventions.md
@docs/architecture.md
```

Ces fichiers sont charges automatiquement. Utile pour ne pas avoir un CLAUDE.md de 500 lignes.

### Auto-memory

Claude Code memorise automatiquement vos preferences et decisions dans `~/.claude/memory/`. Ces informations persistent entre sessions.

```
# Claude le fait automatiquement quand vous dites :
"Remember that I prefer functional components over classes"
"Remember that this project uses yarn, not npm"
```

Pour forcer une memorisation explicite : dites "remember that..." suivi de ce que vous voulez retenir.

### Quand utiliser `/compact` vs `/clear`

| Situation | Action | Pourquoi |
|-----------|--------|----------|
| Session longue, meme sujet | `/compact` | Conserve le contexte essentiel, libere de la place |
| Contexte presque plein | `/compact` | Evite de perdre en qualite |
| Entre deux phases (Explore → Plan) | `/compact` | Repart avec une base propre |
| Nouveau sujet sans rapport | `/clear` | Recommencer a zero |
| Claude semble "perdre le fil" | `/compact` | Recondenser les informations cles |

`/compact` est presque toujours preferable a `/clear` : il conserve les decisions et conventions apprises pendant la session.

### Context compaction automatique

Quand le contexte atteint ~90% de sa capacite, Claude Code compacte automatiquement. Vous verrez un message :

```
Context compacted. Summary preserved.
```

Cela se fait sans intervention de votre part.

### Sessions nommees

```bash
# Demarrer une session avec un nom
claude -n "feature-auth"

# Plus tard, reprendre exactement ou vous etiez
claude -r "feature-auth"

# Ou depuis l'interieur d'une session
/resume feature-auth
```

Utile pour les features longues qui s'etalent sur plusieurs jours.

### Checkpoints et `/rewind`

Claude Code sauvegarde automatiquement un checkpoint avant chaque modification. Si une operation casse tout :

```bash
/rewind
```

Revient a l'etat exact avant la derniere modification. Plus rapide que `git stash` ou `git checkout`.

---

## Module 6 : Raccourcis clavier (15 min)

### Reference complete

| Raccourci | Action |
|-----------|--------|
| `Ctrl+C` | Annuler la generation en cours |
| `Ctrl+D` | Quitter Claude Code |
| `Ctrl+G` | Ouvrir le prompt dans un editeur externe |
| `Ctrl+L` | Redessiner l'affichage (utile si le terminal est corrompu) |
| `Ctrl+O` | Mode verbose (afficher tous les details des tool calls) |
| `Ctrl+R` | Recherche dans l'historique des prompts |
| `Ctrl+T` | Afficher la liste des taches en cours |
| `Ctrl+B` | Passer la tache en arriere-plan |
| `Esc` + `Esc` | Rewind rapide / summarize |
| `Shift+Tab` | Cycler entre les modes de permission |
| `Alt+P` | Changer de modele |
| `Alt+T` | Activer/desactiver le thinking (raisonnement visible) |
| `Alt+O` | Activer/desactiver le fast mode |

### Edition du texte dans le prompt

| Raccourci | Action |
|-----------|--------|
| `Ctrl+K` | Supprimer du curseur a la fin de la ligne |
| `Ctrl+U` | Supprimer du debut de la ligne au curseur |
| `Ctrl+Y` | Coller ce qui a ete supprime avec Ctrl+K ou Ctrl+U |
| `Ctrl+A` | Aller au debut de la ligne |
| `Ctrl+E` | Aller a la fin de la ligne |
| `Alt+F` | Avancer d'un mot |
| `Alt+B` | Reculer d'un mot |

### Configurer Shift+Enter

Par defaut, `Entree` envoie le prompt. Pour configurer `Shift+Entree` comme "nouvelle ligne" dans votre terminal :

```bash
/terminal-setup
```

Cette commande modifie la configuration de votre terminal (iTerm2, Ghostty, etc.) pour que `Shift+Entree` insere une nouvelle ligne.

---

## Module 7 : Configuration avancee (30 min)

### Fichiers de settings

Claude Code charge les settings dans cet ordre (du plus general au plus specifique) :

| Fichier | Portee | Versionne ? | Usage |
|---------|--------|-------------|-------|
| `~/.claude/settings.json` | Tous vos projets | Non | Preferences personnelles globales |
| `.claude/settings.json` | Ce projet (toute l'equipe) | Oui | Configuration projet partagee |
| `.claude/settings.local.json` | Ce projet (vous seulement) | Non (gitignore) | Overrides locaux, API keys |

Les settings plus specifiques ecrasent les settings plus generaux.

**Exemple de `.claude/settings.json` :**
```json
{
  "model": "claude-sonnet-4-6",
  "allowedTools": ["Read", "Write", "Edit", "Bash", "Glob", "Grep"],
  "env": {
    "NODE_ENV": "development"
  }
}
```

### Effort levels

L'effort level controle la profondeur du raisonnement de Claude. Plus l'effort est eleve, plus Claude reflechit — et plus ca prend du temps et consomme des tokens.

| Niveau | Commande | Quand l'utiliser | Exemple |
|--------|----------|------------------|---------|
| low | `/effort low` | Explorer du code, lire des fichiers, questions simples | "Qu'est-ce que ce fichier fait ?" |
| medium | `/effort medium` | Implementer une feature standard, corriger un bug | "Ajoute la validation d'email" |
| high | `/effort high` | Concevoir une architecture, refactoring majeur, audit | "Refactorise le module auth" |
| max | `/effort max` | Debug complexe, securite critique (Opus 4.6 seulement) | "Trouve la fuite memoire" |

### Modeles disponibles

| Modele | Force | Use case | Vitesse |
|--------|-------|----------|---------|
| Opus 4.6 | Meilleur raisonnement, 1M contexte | Architecture, audit, debug complexe | Lent |
| Sonnet 4.6 | Equilibre qualite/vitesse | Developpement quotidien | Moyen |
| Haiku 4.5 | Tres rapide | Taches simples, reformulation, questions | Rapide |

Changer de modele :
```bash
/model opus     # Opus 4.6
/model sonnet   # Sonnet 4.6 (defaut)
/model haiku    # Haiku 4.5
```

Ou en ligne de commande :
```bash
claude --model claude-opus-4-6
```

### Fast mode

`/fast` ou `Alt+O` active un mode ou Claude produit des reponses plus rapidement avec le meme modele. Utile pour les reformulations, les questions de clarification, ou quand la qualite maximale n'est pas necessaire.

### Hooks

Les hooks sont des commandes shell executees automatiquement a des moments precis du cycle de vie de Claude Code.

| Hook | Quand il se declenche | Usage typique |
|------|-----------------------|---------------|
| `SessionStart` | Au debut de chaque session | Charger l'environnement, afficher un message |
| `PreToolUse` | Avant qu'un tool soit execute | Valider, bloquer des commandes dangereuses |
| `PostToolUse` | Apres qu'un tool soit execute | Auto-format, lint, type-check |
| `Notification` | Quand Claude veut vous notifier | Envoyer une notification systeme |

**Exemple : auto-format apres chaque modification de fichier**

Dans `.claude/settings.json` :
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write \"$CLAUDE_TOOL_RESULT_PATH\" 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

Ce hook lance Prettier automatiquement chaque fois que Claude modifie ou cree un fichier.

### MCP (Model Context Protocol)

MCP est un protocole standard qui permet de connecter Claude Code a des services externes. Un "MCP server" est un programme qui expose des tools supplementaires.

**Qu'est-ce qu'un MCP server apporte ?**

| MCP Server | Tools ajoutes | Exemple d'utilisation |
|------------|---------------|-----------------------|
| `@modelcontextprotocol/server-github` | Lire des PRs, creer des issues | "Cree une issue pour ce bug" |
| `@modelcontextprotocol/server-filesystem` | Acces etendu au systeme de fichiers | Lire des fichiers hors du projet |
| `@modelcontextprotocol/server-memory` | Memoire persistante structuree | Stocker des decisions d'architecture |
| `@modelcontextprotocol/server-postgres` | Lire/ecrire en base de donnees | "Combien d'utilisateurs actifs ce mois ?" |

**Configurer dans `.mcp.json` :**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

Les MCP servers sont desactives par defaut dans claude-socle pour des raisons de securite. Activez seulement ceux dont vous avez besoin.

---

## Module 8 : Workflows pratiques (30 min)

### Explorer un projet inconnu

```bash
cd projet-inconnu
claude "explain this project: what does it do, what's the stack, and where should I start?"
```

Claude lit automatiquement `package.json`, `README.md`, les fichiers principaux et vous donne une vue d'ensemble structuree.

### Corriger un bug

La methode la plus efficace : coller le message d'erreur exact.

```bash
# Option 1 : coller l'erreur directement
claude "TypeError: Cannot read properties of undefined (reading 'userId')
  at getUserProfile (src/api/users.ts:42:18)
  Fix this."

# Option 2 : laisser Claude trouver l'erreur
claude "The tests are failing. Investigate and fix."
```

### Creer une feature

```bash
claude "Add email verification to the registration flow:
- Send a verification email after registration
- Add a /verify-email endpoint that validates the token
- Block login until email is verified
Use the existing mailer service in src/services/mailer.ts"
```

Plus vous etes precis, meilleur est le resultat. Indiquez les fichiers existants a reutiliser, les contraintes, les comportements attendus.

### Creer un commit et une PR

```bash
# Commit uniquement
claude "commit my changes with a descriptive conventional commit message"

# Commit + push + PR GitHub
claude "commit, push, and create a PR for these changes. Title: Add email verification"
```

### Code review

```bash
# Review des changements locaux
claude "review the changes I've made. Check for bugs, security issues, and style."

# Review d'une PR GitHub (avec MCP GitHub configure)
claude "review PR #42 and leave inline comments"
```

### Refactoring

```bash
claude "refactor src/services/payment.ts for readability:
- extract helper functions
- add JSDoc comments
- reduce function complexity
Keep the same behavior — all tests must still pass"
```

### Git worktrees : travailler en parallele

Les git worktrees permettent d'avoir plusieurs branches checkoutees en meme temps dans des dossiers differents. Avec Claude Code, vous pouvez lancer plusieurs sessions en parallele sur des features independantes.

```bash
# Creer un worktree pour une feature
git worktree add ../mon-projet-auth feature/auth

# Lancer Claude Code dans ce worktree
cd ../mon-projet-auth
claude -n "feature-auth"

# Pendant ce temps, dans un autre terminal
cd mon-projet
claude -n "feature-dashboard"
```

Les deux sessions Claude Code s'executent en parallele et n'interferent pas. C'est le pattern recommande pour la productivite maximale.

### Piping : envoyer du contenu depuis stdin

```bash
# Analyser un fichier de log
cat server.log | claude -p "summarize the errors in the last hour"

# Analyser la sortie d'une commande
npm test 2>&1 | claude -p "explain which tests failed and why"

# Reformatter du JSON
cat data.json | claude -p "convert this JSON to a markdown table"
```

### Mode headless en CI

```bash
# Dans un pipeline CI, sans interaction
claude -p "run the tests, fix any failures, and report what you changed"

# Avec un modele specifique et une limite de tokens
claude -p "check for security vulnerabilities" --model claude-haiku-4-5
```

Le flag `-p` (print) active le mode non-interactif : Claude execute la tache et se termine. Ideal pour les pipelines automatises.

---

## Module 9 : Depannage (15 min)

### Table symptome / solution

| Symptome | Cause probable | Solution |
|----------|----------------|----------|
| Claude repond a cote de la question | Contexte trop long ou pollue | `/compact` puis reposer la question |
| Claude "oublie" les instructions | CLAUDE.md mal configure | `/memory` pour verifier ce qui est charge |
| Trop de dialogs de permission | Mode `default` actif | `Shift+Tab` pour passer en `acceptEdits` |
| Session tres lente | Modele trop puissant pour la tache | `/model haiku` ou `/fast` |
| Fichier pas trouve par Claude | Chemin relatif ambigu | Utiliser `@chemin/complet.ts` ou un chemin absolu |
| MCP server ne demarre pas | Erreur de configuration | Verifier `.mcp.json`, consulter les logs avec `--debug` |
| Erreur "context too long" | Fenetre de contexte depassee | `/compact` immediatement |
| Claude fait quelque chose d'inattendu | Prompt trop vague | Etre plus specifique, decrire l'etat attendu |
| Modification catastrophique | Bug dans le refactoring | `/rewind` pour revenir avant la modification |
| Claude ne trouve pas de packages | Environnement node_modules absent | `!npm install` pour installer les dependances |

### `/doctor` : diagnostic automatique

```bash
/doctor
```

Verifie : authentification, connectivite, version de Claude Code, configuration MCP, settings. Affiche un rapport avec les problemes detectes et les solutions suggerees.

### Mode debug

Pour obtenir des logs detailles :

```bash
claude --debug
```

Affiche tous les appels API, les configurations chargees, les erreurs MCP. Utile pour diagnostiquer des problemes de configuration avances.

### Mise a jour

```bash
# Verifier la version actuelle
claude --version

# Mettre a jour
npm update -g @anthropic-ai/claude-code
# ou
brew upgrade claude
```

---

## Transition vers le socle

Vous maitrisez maintenant Claude Code. Voici ce que claude-socle ajoute par-dessus :

**Sans le socle**, Claude Code est un agent puissant mais "vierge". A chaque session, vous devez lui expliquer vos conventions, votre workflow, ce que vous attendez de lui.

**Avec le socle**, ces instructions sont pre-configurees et activees automatiquement :

| Ce que le socle ajoute | Description |
|------------------------|-------------|
| 126 commandes (`/work:*`, `/dev:*`, `/qa:*`, `/ops:*`) | Workflows pre-ecrits pour les taches courantes |
| 62 agents specialises | Sous-processus pour l'audit, la securite, les tests, etc. |
| 44 skills | Comportements declenchables par mots-cles |
| 25 rules | Conventions de code activees automatiquement selon les fichiers modifies |
| Workflow structure | Explore → Specify → Plan → TDD → Audit → Commit |

La difference concrète : au lieu de taper "run the tests, check coverage, fix issues, audit security, then commit", vous tapez `/work:work-flow-feature "ma feature"` et le socle orchestre tout.

### Prochaines etapes

- [Quick Start du socle](/docs/intro/quick-start) — Installer et configurer le socle en 5 minutes
- [Parcours d'apprentissage](/docs/guides/learning-path) — De novice a expert en 9h30

---

*Ce guide couvre Claude Code CLI version 2.x. Les commandes et raccourcis peuvent varier selon les mises a jour.*
