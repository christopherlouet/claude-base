---
title: "Guide Utilisateur claude-socle"
subtitle: "Maîtrisez Claude Code avec un workflow professionnel"
author: "claude-socle"
date: "Janvier 2025"
lang: fr
toc: true
toc-depth: 3
numbersections: true
geometry: margin=2.5cm
fontsize: 11pt
linkcolor: blue
header-includes:
  - \usepackage{fancyhdr}
  - \pagestyle{fancy}
  - \fancyhead[L]{Guide Utilisateur claude-socle}
  - \fancyhead[R]{\thepage}
  - \fancyfoot[C]{}
---

\newpage

# Introduction

## Qu'est-ce que claude-socle ?

**claude-socle** est un template de configuration pour Claude Code qui transforme votre assistant IA en un véritable partenaire de développement. Il fournit :

- **79 agents spécialisés** pour différentes tâches de développement
- **9 skills** pour des comportements automatiques intelligents
- **8 hooks** pour automatiser les vérifications et le formatage
- **8 templates** adaptés à différents langages et frameworks
- **8 scripts utilitaires** pour l'installation et la maintenance

## Pourquoi utiliser claude-socle ?

| Sans claude-socle | Avec claude-socle |
|-------------------|-------------------|
| Prompts répétitifs | Commandes prêtes à l'emploi |
| Workflow inconsistant | Workflow structuré Explore → Plan → Code → Commit |
| Risques de sécurité | Hooks de protection intégrés |
| Configuration manuelle | Installation automatisée |

## Prérequis

Avant d'utiliser claude-socle, assurez-vous d'avoir :

- **Claude Code CLI** installé (`npm install -g @anthropic-ai/claude-code`)
- **Git** version 2.0+
- **Node.js** version 18+ (recommandé)
- **jq** pour la validation JSON (optionnel mais recommandé)

\newpage

# Installation

## Option 1 : Script d'installation (recommandé)

```bash
# Cloner le repository
git clone https://github.com/votre-repo/claude-socle.git

# Installer dans un projet existant
./claude-socle/scripts/install.sh /chemin/vers/votre-projet
```

Le script vous guidera à travers les options :

```
============================================================
  Installation Claude Code Configuration
============================================================

[INFO] Source: /home/user/claude-socle
[INFO] Cible:  /home/user/mon-projet

? Que souhaitez-vous installer?
  1. Configuration complète (recommandé)
  2. Commandes uniquement
  3. Hooks uniquement
  4. Sélection personnalisée
```

## Option 2 : Installation manuelle

```bash
# Copier la configuration
cp -r claude-socle/.claude votre-projet/
cp claude-socle/CLAUDE.md votre-projet/

# Optionnel : MCP et GitHub Actions
cp claude-socle/.mcp.json votre-projet/
cp -r claude-socle/.github votre-projet/
```

## Option 3 : Création d'un nouveau projet

```bash
./scripts/new-project.sh
```

Ce script interactif vous guide pour :

1. Choisir le nom du projet
2. Sélectionner le template adapté (React, Node.js, Python, etc.)
3. Détecter automatiquement les technologies existantes
4. Configurer les hooks appropriés

## Vérification de l'installation

```bash
# Diagnostic complet
./scripts/doctor.sh /chemin/vers/votre-projet

# Validation de la configuration
./scripts/validate.sh /chemin/vers/votre-projet
```

\newpage

# Le Workflow Explore → Plan → Code → Commit

## Vue d'ensemble

Le cœur de claude-socle est un workflow en 4 étapes qui garantit un code de qualité :

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   EXPLORE   │───▶│    PLAN     │───▶│    CODE     │───▶│   COMMIT    │
│             │    │             │    │             │    │             │
│ Comprendre  │    │ Concevoir   │    │ Implémenter │    │ Livrer      │
│ l'existant  │    │ la solution │    │ avec tests  │    │ proprement  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

**Règle d'or** : Ne jamais coder sans avoir exploré et planifié !

## Étape 1 : EXPLORE

### Commande

```
/explore [cible]
```

### Quand l'utiliser ?

- Avant de modifier du code existant
- Pour comprendre une architecture inconnue
- Pour identifier les dépendances et impacts

### Exemple pratique

```
Utilisateur: /explore le système d'authentification

Claude: Je vais explorer le système d'authentification...

## Architecture identifiée

### Fichiers principaux
- `src/auth/AuthService.ts` - Service principal (234 lignes)
- `src/auth/middleware/authMiddleware.ts` - Middleware Express
- `src/auth/strategies/` - Stratégies Passport.js

### Technologies utilisées
- Passport.js pour l'authentification
- JWT pour les tokens
- bcrypt pour le hashing

### Points d'attention
- Le refresh token n'est pas implémenté
- Pas de rate limiting sur /login

### Recommandations
Avant toute modification, considérez :
1. L'impact sur les 12 routes protégées
2. La migration des sessions existantes
```

## Étape 2 : PLAN

### Commande

```
/plan [fonctionnalité]
```

### Quand l'utiliser ?

- Après l'exploration, avant de coder
- Pour des fonctionnalités complexes
- Pour valider une approche avec l'équipe

### Exemple pratique

```
Utilisateur: /plan ajouter l'authentification OAuth2 Google

Claude: Je vais planifier l'implémentation d'OAuth2 Google...

## Plan d'implémentation

### Phase 1 : Configuration (30 min)
1. Ajouter les dépendances
   - `passport-google-oauth20`
   - `@types/passport-google-oauth20`

2. Créer les variables d'environnement
   - `GOOGLE_CLIENT_ID`
   - `GOOGLE_CLIENT_SECRET`
   - `GOOGLE_CALLBACK_URL`

### Phase 2 : Backend (2h)
1. Créer `src/auth/strategies/googleStrategy.ts`
2. Ajouter les routes `/auth/google` et `/auth/google/callback`
3. Modifier `AuthService.ts` pour gérer les comptes liés

### Phase 3 : Frontend (1h)
1. Ajouter le bouton "Se connecter avec Google"
2. Gérer le callback et le stockage du token

### Phase 4 : Tests (1h)
1. Tests unitaires de GoogleStrategy
2. Tests d'intégration du flow complet

### Risques identifiés
- Migration des utilisateurs existants
- Gestion des comptes dupliqués (même email)

Souhaitez-vous que je commence l'implémentation ?
```

## Étape 3 : CODE

### Commandes disponibles

| Commande | Usage |
|----------|-------|
| `/tdd [feature]` | Développement Test-Driven |
| `/api [endpoint]` | Création d'API |
| `/refactor [cible]` | Refactoring guidé |

### Exemple TDD

```
Utilisateur: /tdd GoogleStrategy

Claude: Je démarre le cycle TDD Red-Green-Refactor...

## [RED] RED - Écriture du test

```typescript
// src/auth/strategies/__tests__/googleStrategy.test.ts
describe('GoogleStrategy', () => {
  it('should create user from Google profile', async () => {
    const profile = {
      id: 'google-123',
      emails: [{ value: 'user@gmail.com' }],
      displayName: 'Test User'
    };

    const user = await GoogleStrategy.validateUser(profile);

    expect(user.email).toBe('user@gmail.com');
    expect(user.provider).toBe('google');
  });
});
```

Test lancé... [X] ÉCHEC (GoogleStrategy n'existe pas)

## [GREEN] GREEN - Implémentation minimale

```typescript
// src/auth/strategies/googleStrategy.ts
export class GoogleStrategy {
  static async validateUser(profile: GoogleProfile): Promise<User> {
    return {
      email: profile.emails[0].value,
      provider: 'google',
      providerId: profile.id
    };
  }
}
```

Test lancé... [OK] SUCCÈS

## [REFACTOR] REFACTOR - Amélioration

[Continue avec l'intégration Passport.js...]
```

## Étape 4 : COMMIT

### Commande

```
/commit [contexte]
```

### Ce que fait l'agent

1. Analyse les changements (`git diff`)
2. Génère un message Conventional Commits
3. Vérifie les tests (hook pre-commit)
4. Crée le commit avec co-author

### Exemple

```
Utilisateur: /commit

Claude: J'analyse les changements pour créer le commit...

## Changements détectés

### Fichiers modifiés (4)
- `src/auth/strategies/googleStrategy.ts` (+89 lignes)
- `src/auth/routes/authRoutes.ts` (+24 lignes)
- `src/auth/AuthService.ts` (+12 lignes)
- `.env.example` (+3 lignes)

### Fichiers de test (2)
- `src/auth/strategies/__tests__/googleStrategy.test.ts` (+67 lignes)

## Message de commit proposé

```
feat(auth): add Google OAuth2 authentication

- Implement GoogleStrategy with Passport.js
- Add /auth/google and /auth/google/callback routes
- Support account linking for existing users
- Add comprehensive test coverage

Closes #42

```

Voulez-vous que je crée ce commit ?
```

\newpage

# Les Agents par Catégorie

## Workflow Principal (8 agents)

| Agent | Commande | Description |
|-------|----------|-------------|
| Explore | `/explore` | Explorer le code existant |
| Plan | `/plan` | Planifier une implémentation |
| Commit | `/commit` | Créer un commit propre |
| PR | `/pr` | Créer une Pull Request |
| Flow Feature | `/flow-feature` | Workflow complet feature |
| Flow Bugfix | `/flow-bugfix` | Workflow correction bug |
| Flow Release | `/flow-release` | Workflow release |
| Flow Launch | `/flow-launch` | Workflow lancement |

### Exemple : Flow Feature complet

```
Utilisateur: /flow-feature ajouter le dark mode

Claude: Je lance le workflow complet pour la feature "dark mode"...

## Étape 1/5 : Création de la branche
git checkout -b feature/dark-mode
[OK] Branche créée

## Étape 2/5 : Exploration
[Analyse du système de thèmes existant...]

## Étape 3/5 : Planification
[Plan d'implémentation généré...]

## Étape 4/5 : Implémentation
[En attente de votre validation du plan...]

## Étape 5/5 : PR
[Sera créée après l'implémentation]
```

## Développement (10 agents)

| Agent | Commande | Usage |
|-------|----------|-------|
| TDD | `/tdd` | Test-Driven Development |
| Test | `/test` | Générer des tests |
| Debug | `/debug` | Débogage méthodique |
| Refactor | `/refactor` | Refactoring guidé |
| API | `/api` | Créer/documenter API |
| Component | `/component` | Créer un composant |
| Error Handling | `/error-handling` | Gestion d'erreurs |
| API Versioning | `/api-versioning` | Versioning d'API |
| Feature Flag | `/feature-flag` | Feature flags |
| State | `/state` | Gestion d'état |

### Exemple : Debug

```
Utilisateur: /debug l'erreur "Cannot read property 'user' of undefined"

Claude: Je lance une investigation méthodique...

## 1. Analyse de l'erreur

Type: TypeError
Message: Cannot read property 'user' of undefined
Fichier probable: src/middleware/authMiddleware.ts

## 2. Hypothèses

1. **req.session est undefined**
   - Probabilité: 70%
   - Cause: Session middleware non initialisé

2. **Race condition**
   - Probabilité: 20%
   - Cause: Accès avant chargement de la session

3. **Mauvaise configuration**
   - Probabilité: 10%
   - Cause: Variable d'environnement manquante

## 3. Investigation

Vérifions l'hypothèse 1...

```typescript
// src/middleware/authMiddleware.ts:23
export const requireAuth = (req, res, next) => {
  if (req.session.user) {  // ← Erreur ici
    //...
  }
};
```

## 4. Solution

```typescript
export const requireAuth = (req, res, next) => {
  if (req.session?.user) {  // Optional chaining
    //...
  }
};
```

Voulez-vous que j'applique cette correction ?
```

## Qualité (8 agents)

| Agent | Commande | Usage |
|-------|----------|-------|
| Review | `/review` | Code review détaillée |
| Security | `/security` | Audit sécurité OWASP |
| Performance | `/perf` | Analyse performance |
| A11y | `/a11y` | Audit accessibilité |
| Lint | `/lint` | Analyse statique |
| Coverage | `/coverage` | Couverture de tests |
| Complexity | `/complexity` | Analyse complexité |
| Dependencies | `/deps` | Audit dépendances |

### Exemple : Security Audit

```
Utilisateur: /security src/api/

Claude: Je lance un audit de sécurité OWASP Top 10...

## Rapport de Sécurité

### [RED] Critiques (2)

#### 1. Injection SQL - A03:2021
**Fichier:** `src/api/users/userRepository.ts:45`
```typescript
// [X] Vulnérable
const query = `SELECT * FROM users WHERE id = ${userId}`;

// [OK] Correction
const query = 'SELECT * FROM users WHERE id = $1';
await db.query(query, [userId]);
```

#### 2. Secrets exposés - A02:2021
**Fichier:** `src/api/config.ts:12`
```typescript
// [X] Secret en dur
const JWT_SECRET = 'my-super-secret-key';

// [OK] Correction
const JWT_SECRET = process.env.JWT_SECRET;
```

### [WARN] Moyens (3)

[...]

### [GREEN] Bonnes pratiques détectées (5)

- [OK] HTTPS forcé en production
- [OK] Headers de sécurité configurés
- [OK] Rate limiting sur /api/auth
- [OK] Validation des entrées avec Joi
- [OK] Logs sans données sensibles
```

## Operations (16 agents)

| Agent | Commande | Usage |
|-------|----------|-------|
| Docker | `/docker` | Dockeriser |
| K8s | `/k8s` | Kubernetes |
| CI/CD | `/cicd` | Pipelines |
| Deploy | `/deploy` | Déploiement |
| Monitor | `/monitor` | Monitoring |
| Backup | `/backup` | Sauvegardes |
| Hotfix | `/hotfix` | Fix urgent |
| Release | `/release` | Releases |
| Rollback | `/rollback` | Rollback |
| Scale | `/scale` | Scaling |
| Migrate DB | `/migrate-db` | Migration DB |
| Infra | `/infra` | Infrastructure |
| SSL | `/ssl` | Certificats |
| DNS | `/dns` | Configuration DNS |
| CDN | `/cdn` | Configuration CDN |
| Logs | `/logs` | Analyse logs |

## Documentation (9 agents)

| Agent | Commande | Usage |
|-------|----------|-------|
| Doc | `/doc` | Documentation |
| API Doc | `/api-doc` | Doc API |
| README | `/readme` | README |
| Changelog | `/changelog` | Changelog |
| ADR | `/adr` | Architecture Decision |
| Tutorial | `/tutorial` | Tutoriels |
| Diagram | `/diagram` | Diagrammes |
| Onboard | `/onboard` | Onboarding |
| Explain | `/explain` | Explications |

\newpage

# Les Skills

Les skills sont des comportements automatiques qui se déclenchent selon le contexte.

## Skills disponibles (9)

| Skill | Déclencheur | Action |
|-------|-------------|--------|
| `work-explore` | Exploration de code | Guide l'exploration méthodique |
| `work-plan` | Planification | Structure le plan d'implémentation |
| `work-commit` | Commit | Génère des messages Conventional Commits |
| `work-pr` | PR | Crée des PR complètes |
| `qa-review` | Review | Effectue des reviews approfondies |
| `dev-debug` | Bug | Guide le débogage |
| `dev-tdd` | TDD | Applique le cycle Red-Green-Refactor |
| `dev-api` | API | Guide la création d'API |
| `qa-security` | Sécurité | Applique OWASP Top 10 |

## Comment fonctionnent les skills ?

Les skills sont définis dans `.claude/skills/` et contiennent :

1. **Frontmatter YAML** : Métadonnées et déclencheurs
2. **Instructions** : Guide détaillé pour Claude

### Exemple : Skill TDD

```yaml
---
name: test-driven-development
description: Développement TDD avec cycle Red-Green-Refactor
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# Test-Driven Development

## Cycle obligatoire

### [RED] RED
1. Écrire un test qui échoue
2. Le test doit être minimal et ciblé
3. Exécuter pour confirmer l'échec

### [GREEN] GREEN
1. Écrire le code MINIMUM pour passer le test
2. Pas d'optimisation prématurée
3. Exécuter pour confirmer le succès

### [REFACTOR] REFACTOR
1. Améliorer le code sans changer le comportement
2. Les tests doivent rester verts
3. Appliquer les principes SOLID

[...]
```

\newpage

# Les Hooks

Les hooks automatisent des vérifications et actions à chaque opération.

## Hooks configurés (8)

### PreToolUse (3 hooks)

| Hook | Action | Comportement |
|------|--------|--------------|
| Protection main | Bloque les modifications sur main/master | Bloquant |
| Tests pre-commit | Exécute les tests avant commit | Bloquant |
| Détection secrets | Détecte les secrets dans le code | Bloquant |

### PostToolUse (5 hooks)

| Hook | Action | Comportement |
|------|--------|--------------|
| Auto-format | Prettier sur fichiers modifiés | Non-bloquant |
| Type check | Vérifie les types TypeScript | Non-bloquant |
| ESLint | Vérifie le code | Non-bloquant |
| npm install | Auto-install après package.json | Non-bloquant |
| Coverage | Vérifie la couverture après tests | Non-bloquant |

## Exemple en action

```
Utilisateur: Modifie src/api/users.ts pour ajouter un endpoint

Claude: [Modifie le fichier...]

[>] Hook PostToolUse: Auto-format
   → prettier --write src/api/users.ts [OK]

[>] Hook PostToolUse: Type check
   → tsc --noEmit [OK]

[>] Hook PostToolUse: ESLint
   → eslint src/api/users.ts [OK]
```

## Configuration des hooks

Les hooks sont configurés dans `.claude/settings.json` :

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "description": "Empêcher modifications sur main",
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c '[script de vérification]'",
            "onFailure": "block"
          }
        ]
      }
    ]
  }
}
```

\newpage

# Scripts Utilitaires

## Vue d'ensemble

| Script | Commande | Description |
|--------|----------|-------------|
| `install.sh` | `./scripts/install.sh [projet]` | Installation |
| `update.sh` | `./scripts/update.sh [projet]` | Mise à jour |
| `validate.sh` | `./scripts/validate.sh [projet]` | Validation |
| `new-project.sh` | `./scripts/new-project.sh` | Nouveau projet |
| `uninstall.sh` | `./scripts/uninstall.sh [projet]` | Désinstallation |
| `doctor.sh` | `./scripts/doctor.sh [projet]` | Diagnostic |
| `diff.sh` | `./scripts/diff.sh [projet]` | Comparaison |

## Exemples d'utilisation

### Installation avec options

```bash
# Installation interactive (défaut)
./scripts/install.sh ./mon-projet

# Installation silencieuse pour CI/CD
./scripts/install.sh -y ./mon-projet

# Simulation sans modification
./scripts/install.sh --dry-run ./mon-projet

# Installation complète avec hooks et MCP
./scripts/install.sh --all ./mon-projet
```

### Validation pour CI/CD

```bash
# Validation standard
./scripts/validate.sh ./mon-projet

# Sortie JSON pour parsing
./scripts/validate.sh --json ./mon-projet

# Score uniquement
./scripts/validate.sh --score ./mon-projet
# Output: 22/23 (95%)
```

### Diagnostic complet

```bash
./scripts/doctor.sh ./mon-projet
```

Output :

```
============================================================
  Diagnostic Claude Code
============================================================

1. Environnement système
----------------------------------------
[✓] Système d'exploitation: Linux
[✓] Shell: zsh
[✓] Bash version: 5.2
[✓] Permissions d'écriture: OK

2. Dépendances
----------------------------------------
[✓] git: 2.51.0
[✓] jq: 1.8
[✓] Node.js: 20.19.5

[...]

============================================================
  Résumé du diagnostic
============================================================

  ✓ Réussis:      25
  ! Avertissements: 0
  ✗ Échoués:      0

[✓] Environnement parfait!
```

\newpage

# Personnalisation

## Fichier CLAUDE.md

Le fichier `CLAUDE.md` à la racine de votre projet contient les instructions spécifiques. Personnalisez-le selon vos besoins :

```markdown
# Mon Projet

## Commandes essentielles
| Commande | Description |
|----------|-------------|
| `npm run dev` | Serveur de développement |
| `npm test` | Lancer les tests |

## Conventions de code
- TypeScript strict obligatoire
- Pas de `any`
- Tests pour chaque fonctionnalité

## Architecture
[Décrivez votre architecture...]
```

## Fichier CLAUDE.local.md

Pour les configurations personnelles non versionnées :

```markdown
# Configuration locale

## Mes préférences
- Utiliser des emojis dans les commits
- Commenter en français
- Verbose mode activé

## Contexte
Je travaille sur le module d'authentification cette semaine.
```

## Ajouter un agent personnalisé

Créez un fichier dans `.claude/commands/` :

```markdown
# Agent Mon-Agent

## Description
Description de ce que fait l'agent.

## Déclencheurs
- Quand l'utilisateur demande X
- Après Y

## Instructions
1. Première étape
2. Deuxième étape

## Output attendu
Format de sortie souhaité.
```

\newpage

# Bonnes Pratiques

## Les 10 commandements de claude-socle

### 1. Toujours explorer avant de modifier

```
[X] "Ajoute une fonction de login"
[OK] "/explore le système d'auth" puis "Ajoute..."
```

### 2. Toujours planifier les features complexes

```
[X] "Implémente OAuth2"
[OK] "/plan OAuth2" → validation → implémentation
```

### 3. Utiliser TDD pour le code critique

```
[OK] /tdd pour les services et utilitaires
```

### 4. Commits atomiques et fréquents

```
[OK] Un commit = une modification logique
[X] Un commit géant avec 50 fichiers
```

### 5. Review avant merge

```
[OK] /review avant chaque PR
```

### 6. Security audit sur le code sensible

```
[OK] /security sur auth, payments, user data
```

### 7. Documenter les décisions

```
[OK] /adr pour les choix architecturaux
```

### 8. Utiliser les templates adaptés

```
[OK] CLAUDE.react.md pour un projet React
[OK] CLAUDE.node-api.md pour une API Node.js
```

### 9. Valider régulièrement

```bash
./scripts/validate.sh . && echo "OK"
```

### 10. Mettre à jour le socle

```bash
./scripts/update.sh .
```

\newpage

# Troubleshooting

## Problèmes courants

### "Command not found: claude"

```bash
# Installer Claude Code CLI
npm install -g @anthropic-ai/claude-code

# Vérifier l'installation
claude --version
```

### "Permission denied" sur les scripts

```bash
chmod +x ./scripts/*.sh
```

### Les hooks ne se déclenchent pas

Vérifiez que les hooks sont dans `settings.json` (pas dans un fichier `hooks.json` séparé).

```bash
# Vérifier la configuration
jq '.hooks' .claude/settings.json
```

### Score de validation < 100%

```bash
# Identifier les problèmes
./scripts/validate.sh --verbose .
```

### Conflit avec configuration existante

```bash
# Sauvegarder puis réinstaller
./scripts/uninstall.sh --keep-claude-md .
./scripts/install.sh .
```

## Obtenir de l'aide

```bash
# Aide sur un script
./scripts/install.sh --help

# Diagnostic complet
./scripts/doctor.sh .

# Vérifier les différences avec le socle
./scripts/diff.sh .
```

\newpage

# Référence Rapide

## Commandes les plus utilisées

| Tâche | Commande |
|-------|----------|
| Explorer du code | `/explore [cible]` |
| Planifier une feature | `/plan [feature]` |
| Développer en TDD | `/tdd [feature]` |
| Créer un commit | `/commit` |
| Créer une PR | `/pr` |
| Review de code | `/review [cible]` |
| Audit sécurité | `/security [cible]` |
| Déboguer | `/debug [problème]` |

## Scripts utilitaires

```bash
./scripts/install.sh [projet]     # Installer
./scripts/update.sh [projet]      # Mettre à jour
./scripts/validate.sh [projet]    # Valider
./scripts/doctor.sh [projet]      # Diagnostiquer
./scripts/diff.sh [projet]        # Comparer
./scripts/uninstall.sh [projet]   # Désinstaller
```

## Structure type d'un projet

```
mon-projet/
├── CLAUDE.md              # Instructions (versionné)
├── CLAUDE.local.md        # Perso (gitignored)
├── .claude/
│   ├── settings.json      # Permissions + hooks
│   ├── commands/          # Agents
│   └── skills/            # Skills
└── ...
```

---

*Guide généré pour claude-socle v1.1.0*
