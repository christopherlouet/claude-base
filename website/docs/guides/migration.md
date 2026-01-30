---
sidebar_position: 8
title: Guide de Migration
description: Migrer un projet existant vers claude-socle
---

# Guide de Migration vers claude-socle

Ce guide vous accompagne pour intégrer claude-socle dans un projet existant.

## Vue d'ensemble

La migration vers claude-socle consiste à :
1. Copier les fichiers de configuration
2. Adapter les rules à votre stack
3. Valider l'installation
4. Commencer à utiliser le workflow

**Durée estimée** : 15-30 minutes

## Prérequis

- Claude Code installé et fonctionnel
- Un projet existant (Web, Mobile, API, etc.)
- Accès en écriture au projet

## Migration Standard

### Étape 1 : Télécharger claude-socle

```bash
# Cloner le repository
git clone https://github.com/christopherlouet/claude-socle.git /tmp/claude-socle
```

### Étape 2 : Copier les fichiers

```bash
# Aller dans votre projet
cd votre-projet

# Copier le dossier .claude
cp -r /tmp/claude-socle/.claude/ .

# Copier CLAUDE.md
cp /tmp/claude-socle/CLAUDE.md .

# Copier .mcp.json (optionnel)
cp /tmp/claude-socle/.mcp.json .
```

### Étape 3 : Vérifier la structure

```bash
ls -la .claude/
```

Vous devriez voir :
```
.claude/
├── commands/      # 119 commandes
├── agents/        # 57 agents
├── skills/        # 41 skills
├── rules/         # 21 rules
├── templates/     # Templates de spec
├── output-styles/ # Styles de sortie
└── settings.json  # Configuration
```

### Étape 4 : Valider l'installation

Ouvrez Claude Code dans votre projet et testez :

```bash
# Doit fonctionner
/work-explore "Analyser ce projet"
```

Si l'exploration fonctionne, la migration est réussie.

---

## Migration par Type de Projet

### Projet Web (React/Next.js/Vue)

**Fichiers importants** :
- `.claude/rules/typescript.md` - Conventions TypeScript
- `.claude/rules/react.md` - Conventions React
- `.claude/rules/testing.md` - Conventions de tests

**Adapter CLAUDE.md** :

```markdown
# Mon Projet Web

## Commandes Essentielles
| Commande | Description |
|----------|-------------|
| `npm install` | Installer les dépendances |
| `npm run dev` | Serveur de développement |
| `npm test` | Lancer les tests |
| `npm run build` | Build de production |

## Structure
```
/src
├── /components   # Composants React
├── /hooks        # Custom hooks
├── /services     # Logique métier
└── /utils        # Fonctions utilitaires
```

## Conventions
- TypeScript strict
- Tailwind CSS pour le style
- Jest + RTL pour les tests
```

**Commandes recommandées** :
- `/dev-component` - Créer des composants
- `/dev-hook` - Créer des hooks
- `/qa-perf` - Audit de performance

### Projet Mobile (Flutter)

**Fichiers importants** :
- `.claude/rules/flutter.md` - Conventions Flutter/Dart

**Adapter CLAUDE.md** :

```markdown
# Mon App Flutter

## Commandes
| Commande | Description |
|----------|-------------|
| `flutter pub get` | Installer les dépendances |
| `flutter run` | Lancer sur device |
| `flutter test` | Lancer les tests |
| `flutter build apk` | Build Android |

## Architecture
- Clean Architecture
- BLoC pour le state management
- get_it pour l'injection de dépendances

## Structure
```
/lib
├── /core         # Code partagé
├── /features     # Features par domaine
│   └── /auth
│       ├── /data
│       ├── /domain
│       └── /presentation
└── /config       # Configuration
```
```

**Commandes recommandées** :
- `/dev-flutter` - Créer des screens/widgets
- `/dev-supabase` - Backend Supabase
- `/qa-mobile` - Audit qualité mobile

### Projet API (Node/Python/Go)

**Fichiers importants** :
- `.claude/rules/api.md` - Conventions API
- `.claude/rules/security.md` - Sécurité
- `.claude/rules/testing.md` - Tests

**Adapter CLAUDE.md** :

```markdown
# Mon API

## Commandes
| Commande | Description |
|----------|-------------|
| `npm start` | Démarrer le serveur |
| `npm test` | Lancer les tests |
| `npm run lint` | Vérifier le code |

## Stack
- Express.js / Fastify
- PostgreSQL avec Prisma
- Jest pour les tests
- Zod pour la validation

## Conventions API
- REST avec versioning (v1, v2)
- Validation stricte des entrées
- Gestion d'erreurs centralisée
- Logs structurés (JSON)
```

**Commandes recommandées** :
- `/dev-api` - Créer des endpoints
- `/dev-tdd` - Développement TDD
- `/qa-security` - Audit sécurité

---

## Migration depuis Claude Code Standard

Si vous utilisez déjà Claude Code sans claude-socle :

### Différences clés

| Aspect | Avant | Après |
|--------|-------|-------|
| Workflow | Ad-hoc | Explore → Plan → Code |
| Commandes | Manuel | `/work-*`, `/dev-*`, etc. |
| Conventions | Répétées | Dans CLAUDE.md et rules |
| Agents | Non | 57 agents spécialisés |

### Étapes de migration

1. **Sauvegarder vos prompts personnalisés**
   ```bash
   # Si vous aviez des fichiers .claude personnalisés
   cp -r .claude/ .claude-backup/
   ```

2. **Installer claude-socle**
   ```bash
   cp -r /tmp/claude-socle/.claude/ .
   cp /tmp/claude-socle/CLAUDE.md .
   ```

3. **Réintégrer vos personnalisations**
   - Copier vos commandes custom dans `.claude/commands/custom/`
   - Adapter CLAUDE.md avec vos conventions

4. **Tester**
   ```bash
   /work-explore "Analyser le projet"
   ```

---

## Personnalisation Post-Migration

### Adapter les rules

Modifiez les rules selon vos conventions :

```bash
# Éditer une rule
nano .claude/rules/typescript.md
```

Exemple de personnalisation :

```markdown
# TypeScript Rules (Personnalisé)

## Conventions Spécifiques à Notre Projet

- Utiliser `type` plutôt que `interface` pour les props
- Préfixer les interfaces avec `I` (IUser, IProduct)
- Suffixer les types avec `Type` (UserType, ProductType)
```

### Ajouter des commandes custom

```bash
# Créer une commande personnalisée
mkdir -p .claude/commands/custom
nano .claude/commands/custom/deploy-staging.md
```

```markdown
# Deploy Staging

## Instructions
Déployer l'application sur l'environnement staging :
1. Vérifier que les tests passent
2. Build l'application
3. Déployer sur staging.example.com
4. Vérifier le déploiement

## Commandes
```bash
npm run test
npm run build
npm run deploy:staging
```
```

### Configurer les hooks

Éditez `.claude/settings.json` :

```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "echo 'Modification en cours...'"
      }
    ],
    "postToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "npm run lint:fix",
        "filePattern": "**/*.{ts,tsx}"
      }
    ]
  }
}
```

---

## Checklist de Validation

Après la migration, vérifiez :

### Configuration

- [ ] Le dossier `.claude/` existe avec toutes les sous-dossiers
- [ ] Le fichier `CLAUDE.md` est présent
- [ ] Le fichier `.mcp.json` est présent (optionnel)

### Commandes

- [ ] `/work-explore` fonctionne
- [ ] `/work-plan` fonctionne
- [ ] `/work-commit` fonctionne

### Personnalisation

- [ ] CLAUDE.md reflète les conventions du projet
- [ ] Les rules correspondent au stack utilisé
- [ ] Les commandes custom sont créées si nécessaire

### Test fonctionnel

```bash
# Test complet
/work-explore "Analyser ce projet et ses conventions"
/work-plan "Ajouter un exemple de feature"
# (Annuler si nécessaire)
```

---

## Dépannage

### La commande ne fonctionne pas

```bash
# Vérifier la structure
ls -la .claude/commands/work/

# Le fichier doit exister
cat .claude/commands/work/work-explore.md
```

### L'agent ne se déclenche pas

```bash
# Vérifier les agents
ls -la .claude/agents/

# Forcer l'utilisation
"Utilise l'agent qa-security pour auditer le projet"
```

### Les rules ne s'appliquent pas

```bash
# Vérifier que les paths correspondent
cat .claude/rules/typescript.md | head -10

# Les paths doivent matcher vos fichiers
# paths: ["**/*.ts", "**/*.tsx"]
```

---

## Ressources

- [Installation complète](/docs/intro/installation)
- [Architecture](/docs/intro/architecture)
- [FAQ](/docs/guides/faq)
- [Troubleshooting](/docs/guides/troubleshooting)

---

:::tip Conseil
Après la migration, passez quelques minutes à explorer avec `/work-explore`. Cela aide Claude à comprendre votre projet et à donner de meilleures recommandations.
:::
