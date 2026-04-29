# Guide Equipe Claude Code

> Mettre en place Claude Code et le socle pour une equipe de developpement

## Pourquoi une configuration partagee

Travailler en equipe sans configuration commune produit trois problemes concrets : chaque developpeur invente ses propres conventions, l'onboarding d'un nouveau membre prend des semaines au lieu de quelques heures, et les audits de qualite donnent des resultats incoherents d'un poste a l'autre.

Une configuration partagee via le socle resout ces trois problemes en une seule demarche :

| Benefice | Sans socle | Avec socle |
|----------|-----------|------------|
| Conventions de code | Chaque dev decide | Regles `.claude/rules/` commitees |
| Onboarding | 1 a 2 semaines | Moins de 2 heures |
| Qualite code | Variable | Score audit uniforme |
| Workflow | Improvise | Explore → Specify → Plan → TDD → Audit → Commit |
| Secrets | Risque de commit accidentel | Hook gitleaks bloquant |

---

## 1. CLAUDE.md partage

### CLAUDE.md au niveau projet (commite dans git)

Le fichier `CLAUDE.md` a la racine du projet est le point d'entree de toute session Claude Code. Il est charge automatiquement et s'applique a tous les membres de l'equipe.

Ce fichier doit contenir :

- Le **workflow obligatoire** de l'equipe (Explore → Specify → Plan → TDD → Audit → Commit)
- Les **conventions de code** specifiques au projet (nommage, structure, stack)
- Les **references** vers la documentation interne
- Les **`@imports`** vers des fichiers modulaires pour ne pas surcharger le contexte

Exemple de CLAUDE.md projet :

```markdown
# Projet mon-api

> API REST Node.js/TypeScript avec PostgreSQL

@docs/conventions.md
@docs/architecture.md

## Workflow Obligatoire

Explore → Specify → Plan → TDD → Audit → Commit

1. EXPLORE    : /work:work-explore avant toute modification
2. SPECIFY    : User Stories P1 (MVP) avec criteres Given/When/Then
3. PLAN       : Architecture et liste de fichiers avant de coder
4. TDD        : Tests AVANT le code, cycle Red-Green-Refactor
5. AUDIT      : /qa:qa-loop "score 90" avant tout commit
6. COMMIT     : Conventional Commits, reference issues

## Conventions

- TypeScript strict, pas de `any`, interfaces pour objets complexes
- camelCase (vars), PascalCase (classes), kebab-case (fichiers)
- Couverture tests 80%+
- Branches : feature/xxx, fix/xxx

## Stack

Node.js 20, TypeScript 5, Express, Prisma, PostgreSQL 16
```

### CLAUDE.md personnel (~/.claude/CLAUDE.md)

Chaque developpeur peut avoir son propre CLAUDE.md dans `~/.claude/` pour ses preferences personnelles. Ce fichier n'est pas commite dans git et ne s'applique qu'a sa machine.

Exemples de preferences personnelles :

```markdown
# Preferences personnelles

- Langue de reponse preferee : francais
- Modele prefere : claude-opus-4-6 pour les taches complexes
- Format de reponse : concis, sans repetition
- Mes raccourcis : /w = work, /q = qa
```

### Ce qui va ou

| Element | CLAUDE.md projet | CLAUDE.md personnel | `.claude/rules/` | Memory |
|---------|-----------------|---------------------|-----------------|--------|
| Conventions de code equipe | Oui | Non | Oui (par langage) | Non |
| Workflow obligatoire | Oui | Non | `workflow.md` | Non |
| References documentation | Oui | Non | Non | Non |
| Preferences de reponse | Non | Oui | Non | Oui |
| Modele prefere | Non | Oui | Non | Oui |
| Decisions d'architecture | Non | Non | Non | Oui (auto) |
| Regles TypeScript | Lien `@import` | Non | `typescript.md` | Non |

---

## 2. Configuration equipe

### `.claude/settings.json` (commite) vs `.claude/settings.local.json` (gitignore)

Le fichier `.claude/settings.json` est commite dans git. Il contient la configuration partagee de l'equipe : permissions, hooks, variables d'environnement communes.

Le fichier `.claude/settings.local.json` est dans `.gitignore`. Chaque developpeur peut y surcharger les parametres personnels sans impacter le reste de l'equipe.

| Parametre | `settings.json` (partage) | `settings.local.json` (personnel) |
|-----------|--------------------------|-----------------------------------|
| Permissions (allow/deny) | Oui - regles securite equipe | Non |
| Hooks format/lint/tests | Oui | Surcharge possible |
| Variables d'env communes | Oui (`INSIDE_CLAUDE_CODE`) | Oui (tokens, chemins locaux) |
| `includeCoAuthoredBy` | Oui (false recommande) | Non |
| `ENABLE_RTK` | Non | Oui (choix individuel) |
| Modele par defaut | Non | Oui |

### Hooks partages

Le socle fournit des hooks pre-configures dans `settings.json` qui s'appliquent a toute l'equipe :

```
PostToolUse  : Auto-format (prettier, ruff, gofmt, dart format)
              Type-check TypeScript apres modification
              ESLint verification apres modification
PreToolUse   : Tests avant git commit (bloquant)
              CI locale avant git push (bloquant)
              Gitleaks sur Write/Edit (bloquant si secret detecte)
              Protection branche main (cree automatiquement une feature branch)
SessionStart : Verification .env dans .gitignore
              Detection node_modules manquant
```

Pour desactiver un hook ponctuellement sans modifier la config partagee :

```bash
# Sauter les tests pre-commit une fois
SKIP_PRE_COMMIT_TESTS=1 git commit -m "fix: correction typo"

# Permettre une modification directe sur main (cas exceptionnel)
ALLOW_MAIN_EDIT=1 claude
```

### Serveurs MCP : `.mcp.json` partage

Le fichier `.mcp.json` est commite dans git avec tous les serveurs **desactives par defaut** (`"enabled": false`). Chaque developpeur active les serveurs dont il a besoin dans son `.claude/settings.local.json` ou directement dans `.mcp.json` sur sa branche.

```json
// .mcp.json (commite, desactive par defaut)
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" },
      "enabled": false
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "DATABASE_URL": "${DATABASE_URL}" },
      "enabled": false
    }
  }
}
```

Pour activer un serveur MCP en local sans modifier le fichier commite, utiliser la surcharge dans `settings.local.json`.

### Variables d'environnement : pattern `.env.example`

```bash
# .env.example (commite - ne contient QUE des placeholders)
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
GITHUB_TOKEN=ghp_votre_token_ici
SENTRY_AUTH_TOKEN=votre_token_sentry
API_SECRET_KEY=votre_cle_secrete_32_caracteres

# .env (gitignore - contient les vraies valeurs)
# JAMAIS commite
```

---

## 3. Conventions de code

### Rules partagees (`.claude/rules/`)

Les fichiers dans `.claude/rules/` sont commites dans git et s'activent automatiquement selon les fichiers modifies. C'est le mecanisme le plus efficace pour partager des conventions de code sans les mettre dans CLAUDE.md.

Le socle inclut 30 rules pre-configurees. Pour une equipe, les plus importantes a commiter sont :

| Rule | Activation automatique | Utilite equipe |
|------|----------------------|----------------|
| `workflow.md` | Globale | Cycle obligatoire pour tous |
| `git.md` | Globale | Conventional Commits, branches |
| `typescript.md` | `**/*.ts`, `**/*.tsx` | Strict mode, pas de `any` |
| `security.md` | `**/auth/**`, `**/api/**` | OWASP, XSS, injection |
| `tdd-enforcement.md` | Tous les langages | TDD proactif obligatoire |
| `verification.md` | Tous les langages | 4 phases de verification |
| `deploy-safety.md` | `Dockerfile`, `.env*` | Checklist pre-deploy |

### Creer une rule specifique a l'equipe

Pour des conventions non couvertes par les rules standard, creer `.claude/rules/team-conventions.md` :

```markdown
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/services/**"
---
# Conventions Equipe Mon-API

## Naming Services
- Un service par domaine metier : `UserService`, `OrderService`
- Methodes en verbe + nom : `createUser()`, `findOrderById()`
- PAS de `Manager`, `Handler`, `Helper` dans les noms

## Gestion Erreurs
- Toujours utiliser `AppError` (jamais `new Error()` directement)
- Codes d'erreur en SCREAMING_SNAKE : `USER_NOT_FOUND`
- Logger les erreurs avec le contexte : userId, requestId

## Imports
- Imports absolus uniquement (pas de `../../`)
- Ordre : node_modules / types / services / utils / local
```

### Niveaux d'effort recommandes par phase

| Phase workflow | Effort | Justification |
|---------------|--------|---------------|
| Explore (lecture code) | `low` | Pas de raisonnement profond necessaire |
| Specify (user stories) | `medium` | Clarification des besoins |
| Plan (architecture) | `high` | Decisions structurantes |
| TDD (implementation) | `medium` | Implementation guidee par les tests |
| Audit (qualite) | `high` | Detection de problemes subtils |
| Debug complexe | `max` | Raisonnement maximum |

### Modeles recommandes par usage

| Usage | Modele | Pourquoi |
|-------|--------|---------|
| Architecture, conception | Opus 4.7 | Raisonnement le plus avance, 1M contexte, effort `xhigh` |
| Implementation features | Sonnet | Equilibre vitesse/qualite |
| Exploration, lecture | Haiku | Rapide pour operations simples |
| Audits securite | Sonnet ou Opus 4.7 | Detection de failles subtiles |
| Reviews PR en CI | Haiku | Cout faible, volume eleve |
| Review cloud (grosses PRs) | `/ultrareview` | Agents paralleles en cloud |

---

## 4. Onboarding d'un nouveau membre

Checklist complete pour un nouveau developpeur rejoignant l'equipe :

### Etape 1 : Cloner le repo

```bash
git clone https://github.com/org/mon-projet.git
cd mon-projet
```

### Etape 2 : Installer Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

Configurer la cle API :

```bash
export ANTHROPIC_API_KEY=sk-ant-votre-cle
# Ou ajouter dans ~/.bashrc / ~/.zshrc
```

### Etape 3 : Initialiser le socle

```bash
./scripts/new-project.sh --simple .
```

Ce script configure les hooks, les permissions, et verifie la structure `.claude/`.

### Etape 4 : Copier les variables d'environnement

```bash
cp .env.example .env
# Editer .env avec les vraies valeurs (fournies par le lead)
```

### Etape 5 : Premiere session - decouverte du codebase

```bash
claude
/work:work-explore
```

L'agent `work-explore` lit le codebase, identifie les patterns en place, et produit un resume structuree. Laisser tourner 10 a 15 minutes pour un projet de taille moyenne.

Complement : `/team-onboarding` (built-in CLI 2.1.101+) genere automatiquement un guide d'onboarding a partir de l'usage local de Claude Code. Utile pour le lead qui prepare le terrain avant l'arrivee du nouveau membre.

### Etape 6 : Premiere tache - "good first issue"

Le lead assigne une issue labellisee `good first issue` sur GitHub. Workflow attendu :

```bash
/work:work-explore          # Comprendre le contexte de la tache
/work:work-specify          # Clarifier les criteres d'acceptation
/work:work-plan             # Proposer une solution
/dev:dev-tdd                # Implementer en TDD
/qa:qa-loop "score 90"      # Valider la qualite
/work:work-pr               # Creer la Pull Request
```

### Etape 7 : Valider la comprehension du workflow

Avant de travailler en autonomie, verifier que le nouveau membre :

- [ ] Comprend la difference entre `commands/` et `agents/`
- [ ] Sait lire un audit de qualite (`/qa:qa-audit`)
- [ ] A commit son premier changement avec Conventional Commits
- [ ] A cree sa premiere PR avec description complete
- [ ] Connait les hooks actifs (et comment les desactiver si besoin)

---

## 5. Git workflow en equipe

### Strategie de branches

```
main          # Production - protege, merge via PR uniquement
develop       # Integration (optionnel, equipes >5 personnes)
feature/xxx   # Nouvelles fonctionnalites
fix/xxx       # Corrections de bugs
refactor/xxx  # Refactoring sans changement fonctionnel
```

Le hook `PreToolUse` du socle empeche les modifications directes sur `main` et cree automatiquement une branche `feature/auto-YYYYMMDD-HHMMSS`. Renommer ensuite avec :

```bash
git branch -m feature/nom-descriptif
```

### Hooks partages pour la protection du code

| Hook | Declencheur | Action |
|------|------------|--------|
| Protection main | Edit/Write sur main | Cree automatiquement une feature branch |
| Tests pre-commit | `git commit` | Lance la suite de tests, bloque si echec |
| CI locale pre-push | `git push` | Lint + type-check + tests, bloque si echec |
| Gitleaks | Write/Edit | Detecte les secrets, bloque si trouve |
| Destructive check | Commandes SQL DROP/DELETE | Demande confirmation |

### Code review : humain vs Claude

| Type de review | Revieweur | Commande |
|---------------|-----------|---------|
| Logique metier, UX | Humain obligatoire | PR GitHub standard |
| Securite, auth, paiement | Humain + Claude | `/qa:qa-security` avant PR |
| Qualite code, conventions | Claude | `/qa:qa-loop "score 90"` |
| Tests, couverture | Claude | `/qa:qa-coverage` |
| Accessibilite | Claude | `/qa:wcag-audit` |
| Performance | Claude | `/qa:qa-perf` |

Recommendation : configurer `claude-code-action` sur GitHub pour que Claude review automatiquement chaque PR. Les templates de PR sont dans `.claude/templates/`.

### Resolution de conflits

```bash
# Mettre a jour sa branche avant de push
git fetch origin
git rebase origin/main

# En cas de conflit difficile
/work:work-explore    # Comprendre les deux versions
# Resoudre manuellement, puis :
git add .
git rebase --continue
```

---

## 6. Sessions paralleles

### Git worktrees pour travail parallele

La technique la plus efficace pour plusieurs taches simultanees :

```bash
# Creer un worktree pour une feature en parallele
git worktree add ../mon-projet-feature-auth feature/auth

# Lancer Claude Code dans le worktree
cd ../mon-projet-feature-auth
claude

# Nettoyer apres merge
git worktree remove ../mon-projet-feature-auth
```

### Sessions nommees

Pour gerer plusieurs sessions sans worktrees :

```bash
# Session dediee a une feature
claude --session "feature-auth"

# Session dediee aux tests
claude --session "test-coverage"
```

### Equipes d'agents pour travail coordonne

Pour les taches complexes necessitant coordination :

```bash
/work:work-team "implementer l'authentification OAuth2 avec tests et documentation"
```

L'agent `work-team` orchestre plusieurs sous-agents specialises (dev, test, doc) en parallele.

### Quand utiliser quelle approche

| Contexte | Approche | Commande |
|---------|----------|---------|
| Tache unique simple | Session standard | `claude` |
| Deux features en parallele | Git worktrees | `git worktree add` |
| Feature complexe multi-domaine | Agent team | `/work:work-team` |
| 5+ taches independantes | Worktrees + sessions nommees | `claude --session "nom"` |
| Exploration + implementation | `/compact` entre phases | `/compact` |

---

## 7. Securite equipe

### Gestion des secrets

Principes non negociables :

- `.env` toujours dans `.gitignore` - verifier avant chaque nouveau projet
- `.env.example` commite avec des placeholders, jamais de vraies valeurs
- Rotation des secrets si un commit contenant un secret passe malgre tout

Le hook `SessionStart` du socle verifie automatiquement que `.env` est dans `.gitignore` et alerte si ce n'est pas le cas.

### Gitleaks : detection automatique

Le hook `PreToolUse` du socle execute `gitleaks` avant chaque Write/Edit si l'outil est installe et qu'un fichier `.gitleaks.toml` existe :

```bash
# Installer gitleaks
brew install gitleaks  # macOS
# ou
curl -sSL https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks_linux_x64.tar.gz | tar xz

# Tester manuellement
gitleaks detect --no-git --source .
```

### Modes de permission recommandes pour l'equipe

| Mode | Cas d'usage | Risque |
|------|------------|--------|
| `default` | Developpement standard | Demande confirmation pour actions risquees |
| `acceptEdits` | Pipeline CI, revues automatisees | Accepte les modifications sans confirmation |
| Deny list explicite | Tous les projets equipe | Bloque les commandes destructives definies |

La deny list du socle bloque par defaut : `git push --force`, `git reset --hard`, `rm -rf`, `sudo`, `chmod 777`, `curl | bash`, et les operations de shutdown.

### Checklist securite pour les repos equipe

- [ ] `.env` dans `.gitignore` (verifie par hook SessionStart)
- [ ] `.env.example` avec placeholders commits
- [ ] Gitleaks installe sur tous les postes developpeurs
- [ ] `.gitleaks.toml` configure et commite
- [ ] Branche `main` protegee sur GitHub (branch protection rules)
- [ ] PRs obligatoires pour merger sur main (1 reviewer minimum)
- [ ] Secrets dans un vault equipe (1Password, Vault, AWS Secrets Manager)
- [ ] Rotation des secrets documentee dans le runbook ops
- [ ] `/qa:qa-security` execute avant chaque release

---

## 8. Mesurer la productivite

### Suivi des couts tokens

```bash
/ops:ops-cost
```

Cet agent produit un rapport des tokens consommes par session, par modele, et par type de tache. Utile pour optimiser les couts d'equipe.

### Niveaux d'effort pour optimiser les couts

Utiliser le bon niveau d'effort evite de consommer des tokens inutilement :

```bash
/effort low      # Lecture, exploration
/effort medium   # Implementation standard
/effort high     # Architecture, refactoring
/effort max      # Debug critique (Opus 4.7 uniquement)
```

### RTK : reduction de tokens 60-90%

RTK reecrit automatiquement les commandes pour reduire la consommation. Active par developpeur dans `settings.local.json` :

```json
{
  "env": {
    "ENABLE_RTK": "1"
  }
}
```

Puis installer : `brew install rtk`. Voir les economies avec `rtk gain`.

### Consommation typique par phase de workflow

| Phase | Volume tokens (approximatif) | Modele recommande |
|-------|------------------------------|-------------------|
| Explore (codebase moyen) | 50k - 150k input | Haiku |
| Specify (user stories) | 5k - 20k | Sonnet |
| Plan (feature complexe) | 10k - 40k | Opus 4.7 |
| TDD (implementation) | 30k - 100k | Sonnet |
| Audit qualite | 20k - 60k | Sonnet |
| Review PR | 5k - 15k | Haiku |

---

## Commandes utiles pour le lead

| Situation | Commande | Usage |
|-----------|----------|-------|
| Onboarding nouveau membre | `/work:work-explore` | Produire un guide de decouverte du codebase |
| Coordination features paralleles | `/work:work-team "description"` | Orchestrer plusieurs agents sur une grosse feature |
| Suivi des couts equipe | `/ops:ops-cost` | Rapport tokens et optimisations |
| Gate qualite avant release | `/qa:qa-audit` | Audit complet securite + RGPD + A11y + Perf |
| Audit + correction en boucle | `/qa:qa-loop "score 90"` | Correction automatique jusqu'au score cible |
| Release complete | `/work:work-flow-release "v2.0.0"` | Workflow release avec changelog et tag |
| Batch de stories | `/work:work-batch "prd.json"` | Traiter un backlog en lot |

---

## Anti-patterns equipe

- Pas de `CLAUDE.md` partage : chaque developpeur invente ses conventions, le codebase diverge
- Chaque dev a une configuration differente : impossible de reproduire les audits
- Pas de rules commites : les conventions restent dans les tetes, pas dans le code
- Pas de process de code review : la qualite depend de la bonne volonte individuelle
- Secrets dans git : un historique git ne s'efface pas facilement, rotation obligatoire
- Pas de document d'onboarding : le knowledge est dans les Slack et les emails
- Sessions trop longues sans `/compact` : contexte degrade, qualite de generation en baisse
- Sauter la phase Audit avant commit : la dette technique s'accumule silencieusement
- Modifier `settings.json` partage pour des preferences personnelles : utiliser `settings.local.json`
