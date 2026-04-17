# Guide de Depannage

> Resoudre les problemes courants avec Claude Code et le socle claude-socle

## Sections

- [Problemes courants Claude Code](#1-problemes-courants-claude-code)
- [Problemes du socle](#2-problemes-du-socle)
- [Diagnostic rapide](#3-diagnostic-rapide)
- [Commandes de diagnostic](#4-commandes-de-diagnostic)
- [Recuperation d'urgence](#5-recuperation-durgence)
- [Optimisation performance](#6-optimisation-performance)

---

## 1. Problemes courants Claude Code

| Symptome | Cause probable | Solution |
|----------|---------------|----------|
| "Context window full" ou compaction automatique | Trop de fichiers lus, session longue, logs verbeux inclus | `/compact` pour resumer, eviter de lire `/tmp/` ou `node_modules/` |
| Session tres lente, tokens elevees | Lecture repetee de gros fichiers, contexte non compacte | `/compact` entre phases, utiliser `effort low` pour l'exploration |
| Hook silencieux qui ne se declenche pas | Script non executable, chemin errone, timeout depasse | Verifier les logs dans `/tmp/claude-sessions.log`, tester le script manuellement |
| MCP server absent ou deconnecte | Server desactive dans `.mcp.json`, dependance manquante | Verifier `"disabled": true` dans `.mcp.json`, relancer avec `/mcp` |
| Agent ou skill qui ne se declenche pas | Mauvais namespace, description trop vague, fichier manquant | Verifier le nom exact avec `/help`, lire la description du fichier `.md` |
| Boucle de permission refusee | Commande dans la liste `deny` de `settings.json`, mode auto strict | `/less-permission-prompts` pour optimiser les allowlists, ou `SKIP_COMMAND_VALIDATOR=1` |
| Trop de prompts de permission | Permissions trop restrictives pour le workflow | `/less-permission-prompts` scanne les transcripts et propose des allowlists optimisees |
| Conflit git pendant le cycle TDD | Branche desynchronisee, commit intermediaire manquant | `git stash`, `git pull --rebase`, puis `git stash pop` |

### Context window full

La compaction automatique se declenche quand le contexte approche la limite. Si elle echoue ou est mal timee :

```bash
# Compacter manuellement entre deux phases
/compact

# Si le contexte est corrompu ou trop fragmenté
/clear
```

A eviter pour reduire la pression sur le contexte : lire des repertoires entiers (`node_modules/`, `.git/`, `dist/`), inclure des fichiers de log volumineux, relire des fichiers deja connus.

### MCP servers

Les MCP servers sont desactives par defaut dans `.mcp.json`. Pour diagnostiquer :

```bash
# Verifier l'etat des servers MCP
cat .mcp.json | grep -A3 "disabled"

# Lire les evenements MCP
cat /tmp/claude-mcp.log
```

Pour activer un server, retirer `"disabled": true` ou passer a `"disabled": false` dans `.mcp.json`.

---

## 2. Problemes du socle

### Tests pre-commit qui bloquent un commit

Le hook `PreToolUse` intercepte `git commit` et lance les tests. Si les tests echouent, le commit est bloque.

**Diagnostic :**

```bash
# Lancer les tests manuellement pour voir les erreurs
npm test

# Ou selon le projet
pytest
go test ./...
flutter test
```

**Si les tests echouent legitimement** (dette technique connue, travail en cours) :

```bash
# Desactiver les tests pre-commit pour ce commit uniquement
SKIP_PRE_COMMIT_TESTS=1 git commit -m "wip: ..."
```

**Si le hook est defaillant** (Husky manquant, script introuvable) :

Claude Code detecte et repare automatiquement Husky si necessaire. En cas d'echec persistant, verifier :

```bash
ls -la .husky/
cat /tmp/claude-sessions.log | tail -20
```

### Protection de la branche main

Le hook `PreToolUse` bloque toute modification directe sur `main` ou `master`. C'est un garde-fou intentionnel.

**Solution normale :** travailler sur une branche de feature.

```bash
git checkout -b feature/ma-modification
```

**Si une modification directe sur main est absolument necessaire** (hotfix critique, repository personnel) :

```bash
ALLOW_MAIN_EDIT=1 git commit -m "fix: hotfix critique"
```

### Gitleaks : faux positifs

Le hook de detection de secrets analyse le contenu avant chaque ecriture. Il peut signaler des faux positifs sur des tokens de test, des exemples de configuration ou des placeholders.

**Identifier le pattern detecte :**

```bash
# Tester gitleaks directement sur le fichier concerne
gitleaks detect --source . --verbose 2>&1 | grep -A5 "leak"
```

**Ajouter une exception dans `.gitleaks.toml`** (a la racine du projet, creer si absent) :

```toml
[allowlist]
  description = "Faux positifs connus"
  regexes = [
    '''EXAMPLE_TOKEN_FOR_TESTS''',
    '''placeholder_api_key'''
  ]
  paths = [
    '''tests/fixtures/.*''',
    '''docs/.*'''
  ]
```

### Hooks de formatage qui cassent le code

Les hooks `PostToolUse` lancent Prettier, Ruff, gofmt etc. apres chaque ecriture. Si le formateur est absent ou mal configure, il peut produire une sortie vide ou une erreur silencieuse.

**Verifier que le formateur est installe :**

```bash
# TypeScript/JavaScript
npx prettier --version

# Python
ruff --version || black --version

# Go
gofmt --version

# Dart
dart format --help
```

**Si le formateur modifie trop agressivement le code :**

Verifier la configuration locale (`.prettierrc`, `pyproject.toml`, `.editorconfig`). Le formateur utilise la configuration du projet si elle existe.

### Command validator qui bloque une commande legitime

Le hook `Command validator` analyse 8 categories de risque. Certaines commandes valides peuvent correspondre a un pattern dangereux.

**Identifier pourquoi la commande est bloquee :**

```bash
# Lire les logs de session pour voir le motif de blocage
cat /tmp/claude-sessions.log | grep -i "block\|validator" | tail -10
```

**Contourner pour une commande specifique :**

```bash
SKIP_COMMAND_VALIDATOR=1 <commande>
```

**Contourner de facon permanente pour une session :**

Ajouter dans `.claude/settings.local.json` (non commite) :

```json
{
  "env": {
    "SKIP_COMMAND_VALIDATOR": "1"
  }
}
```

---

## 3. Diagnostic rapide

Utiliser cet arbre de decision pour identifier rapidement la source d'un probleme.

```
MON COMMIT EST BLOQUE
│
├── Message "tests failed" ?
│   ├── Oui → npm test (ou equivalent) pour voir les erreurs
│   │         Corriger les tests OU SKIP_PRE_COMMIT_TESTS=1
│   └── Non
│       ├── Message "branch main protected" ?
│       │   └── Oui → Creer une branche OU ALLOW_MAIN_EDIT=1
│       ├── Message "secret detected" ?
│       │   └── Oui → Supprimer le secret OU ajouter exception .gitleaks.toml
│       └── Autre → cat /tmp/claude-sessions.log | tail -30


CLAUDE NE REPOND PLUS / TRES LENT
│
├── Session longue (>1h, beaucoup de fichiers lus) ?
│   └── Oui → /compact (preserve le contexte essentiel)
├── Changement de sujet complet ?
│   └── Oui → /clear (repart a zero)
├── Meme apres /compact toujours lent ?
│   └── Oui → /clear + redemarrer avec un prompt concis
└── Claude semble bloque sur une tache ?
    └── Ctrl+C pour interrompre, puis reformuler la demande


L'AGENT / LA COMMANDE NE FAIT RIEN
│
├── Le nom est-il correct ?
│   └── Non → /help pour lister les commandes disponibles
├── L'agent attend-il des parametres ?
│   └── Possible → lire la description : /work:work-plan "description"
├── Le fichier agent existe-t-il ?
│   └── Verifier : ls .claude/commands/
├── Modele insuffisant pour la tache ?
│   └── Opus pour les taches complexes, Sonnet pour les audits
└── Sub-agent qui ne demarre pas ?
    └── cat /tmp/claude-agents.log | tail -20


LE HOOK NE SE DECLENCHE PAS
│
├── Verifier que le script est executable
│   └── ls -la .claude/hooks/
├── Tester le script manuellement
│   └── bash .claude/hooks/mon-script.sh
├── Verifier les logs
│   └── cat /tmp/claude-sessions.log | tail -30
└── Timeout trop court ?
    └── Verifier la propriete "timeout" dans settings.json
```

---

## 4. Commandes de diagnostic

| Commande | Usage | Quand l'utiliser |
|----------|-------|-----------------|
| `/compact` | Resume le contexte en preservant l'essentiel | Session longue, entre deux phases du workflow |
| `/clear` | Efface tout le contexte | Changement de sujet total, context corrompu |
| `/rewind` | Revient au dernier etat stable avant une modification | Refactoring qui a tout casse |
| `/help` | Liste toutes les commandes et agents disponibles | Agent introuvable, nom incertain |
| `claude --version` | Affiche la version installee | Probleme de compatibilite, feature absente |
| `cat /tmp/claude-sessions.log` | Logs de session (demarrage, compaction, hooks) | Hook silencieux, probleme de demarrage |
| `cat /tmp/claude-agents.log` | Logs des sub-agents | Agent qui ne demarre pas ou se termine prematurement |
| `cat /tmp/claude-notifications.log` | Logs des permissions et attentes | Permission refusee, Claude attend l'utilisateur |
| `cat /tmp/claude-mcp.log` | Logs MCP Elicitation | MCP server deconnecte, elicitation echouee |

### Verifier la version et l'installation

```bash
# Version de Claude Code CLI
claude --version

# Verifier que les hooks sont bien charges au demarrage
cat /tmp/claude-sessions.log | head -20

# Verifier les permissions des scripts de hooks
ls -la .claude/hooks/

# Tester un hook specifique independamment
bash .claude/hooks/pre-commit-tests.sh
```

### Inspecter les logs en temps reel

```bash
# Suivre les logs de session en direct pendant une session Claude
tail -f /tmp/claude-sessions.log

# Suivre les logs d'agents en direct
tail -f /tmp/claude-agents.log
```

---

## 5. Recuperation d'urgence

### /rewind : annuler les dernieres modifications

Claude Code sauvegarde automatiquement un checkpoint avant chaque modification. En cas de refactoring qui casse tout :

```bash
/rewind
```

Cela revient au dernier etat stable, plus rapidement que `git stash` ou `git checkout`. Utiliser avant que la situation ne se degrade davantage.

### git stash + redemarrage propre

Quand les modifications en cours sont trop complexes a demeler :

```bash
# Sauvegarder l'etat actuel
git stash push -m "wip: avant redemarrage propre"

# Revenir au dernier commit propre
git status   # verifier qu'on est propre

# Redemarrer Claude Code dans un nouvel etat
/clear
```

Pour recuperer le travail sauvegarde plus tard :

```bash
git stash pop
```

### Desactiver les hooks temporairement

Si un hook bloque le travail de facon persistante, le desactiver via les variables d'environnement. Plusieurs methodes :

**Pour une seule commande :**

```bash
SKIP_PRE_COMMIT_TESTS=1 git commit -m "..."
SKIP_PRE_PUSH_CI=1 git push
SKIP_COMMAND_VALIDATOR=1 <commande>
SKIP_DESTRUCTIVE_CHECK=1 <commande>
```

**Pour toute une session (dans `.claude/settings.local.json`, non commite) :**

```json
{
  "env": {
    "SKIP_PRE_COMMIT_TESTS": "1",
    "ALLOW_MAIN_EDIT": "1"
  }
}
```

Variables disponibles :

| Variable | Effet |
|----------|-------|
| `ALLOW_MAIN_EDIT=1` | Desactive la protection de branche main |
| `SKIP_PRE_COMMIT_TESTS=1` | Desactive les tests avant commit |
| `SKIP_PRE_PUSH_CI=1` | Desactive le CI local avant push |
| `SKIP_COMMAND_VALIDATOR=1` | Desactive la validation de securite des commandes |
| `SKIP_DESTRUCTIVE_CHECK=1` | Desactive la protection contre les operations destructives |

### Reinitialiser completement les hooks

Si les hooks sont dans un etat incoherent (permissions, scripts modifies) :

```bash
# Reinitialiser les permissions des hooks
chmod +x .claude/hooks/*.sh

# Verifier que le contenu des hooks n'a pas ete altere
git diff .claude/hooks/

# Restaurer depuis git si necessaire
git checkout .claude/hooks/
```

### Conflit git insoluble pendant TDD

Quand un conflit de merge bloque le cycle TDD :

```bash
# Abandonner le merge en cours
git merge --abort
# ou
git rebase --abort

# Revenir a un etat propre
git checkout main
git pull --rebase origin main

# Recreer la branche de travail depuis un etat propre
git checkout -b feature/nouvelle-tentative
```

---

## 6. Optimisation performance

### Quand utiliser /compact vs /clear

| Situation | Commande | Raison |
|-----------|----------|--------|
| Session longue, meme sujet | `/compact` | Preserve les decisions et conventions apprises |
| Entre deux phases du workflow | `/compact` | Garde le contexte du plan et de l'exploration |
| Changement de feature sans rapport | `/clear` | Evite que l'ancien contexte pollue le nouveau |
| Context window > 80% utilisee | `/compact` | Preventif avant saturation |
| Context corrompu ou incohérent | `/clear` | Repartir sur une base saine |

Regle : preferer `/compact` a `/clear`. La compaction preserve l'essentiel (decisions, conventions, structure du projet) alors que `/clear` efface tout et oblige a reexplorer.

### Reduire la consommation de tokens

**Utiliser les niveaux d'effort adaptes :**

| Tache | Effort recommande | Commande |
|-------|------------------|----------|
| Lire et explorer du code | Faible | `/effort low` |
| Implementer une feature standard | Moyen | `/effort medium` |
| Concevoir une architecture | Eleve | `/effort high` |
| Audit critique, debug complexe | Maximum | `/effort max` |

**Eviter les lectures couteux :**

```bash
# Ne pas lire des repertoires entiers
# Mauvais : lire src/ en entier
# Bon : cibler les fichiers pertinents

# Utiliser grep avant de lire
grep -r "nomDeFonction" src/ --include="*.ts" -l
# puis lire uniquement les fichiers pertinents
```

**Activer RTK pour reduire les tokens de 60-90% :**

Dans `.claude/settings.local.json` (non commite) :

```json
{
  "env": {
    "ENABLE_RTK": "1"
  }
}
```

Verifier les economies realisees :

```bash
rtk gain
```

### Eviter les lectures de gros fichiers

Fichiers et repertoires a ne jamais lire entierement :

| A eviter | Alternative |
|----------|-------------|
| `node_modules/` | Lire uniquement `package.json` |
| `dist/`, `build/`, `.next/` | Fichiers generes, inutiles a lire |
| `/tmp/claude-*.log` (entier) | `tail -20 /tmp/claude-sessions.log` |
| `yarn.lock`, `package-lock.json` | Lire uniquement `package.json` |
| `.git/` | Utiliser les commandes git |

### Structurer les sessions pour minimiser le contexte

- Une session = une feature ou un bug. Ne pas melanger les sujets.
- Commiter frequemment : `/compact` est plus efficace sur un contexte recent.
- Utiliser `/compact` entre les phases du workflow (apres Explore, apres Plan).
- Limiter le nombre de fichiers ouverts simultanement a ce qui est strictement necessaire.

---

## Ressources

- [Hooks configures](../reference/hooks-reference.md) - Liste complete des hooks et leurs variables
- [Commandes disponibles](../reference/commands.md) - Catalogue des commandes `/work:`, `/dev:`, `/qa:`, `/ops:`
- [Fonctionnalites avancees](../reference/advanced-features.md) - Workflow Explore → Specify → Plan → TDD → Audit → Commit
- [Bonnes pratiques](../reference/best-practices.md) - Verification, modeles, effort levels
