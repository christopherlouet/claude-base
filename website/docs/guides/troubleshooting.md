---
sidebar_position: 7
title: Troubleshooting
description: Guide de dépannage pour les problèmes courants avec claude-socle
---

# Troubleshooting

Ce guide vous aide à diagnostiquer et résoudre les problèmes courants avec claude-socle.

## Erreurs de Configuration

### "Command not found"

**Erreur** : La commande `/xxx` n'est pas reconnue.

**Diagnostic** :
```bash
# Vérifier la structure .claude
ls -la .claude/
ls -la .claude/commands/
```

**Causes et solutions** :

| Cause | Solution |
|-------|----------|
| Dossier `.claude/` manquant | `cp -r chemin/claude-socle/.claude/ .` |
| Fichier commande manquant | Vérifier que le fichier `.md` existe |
| Erreur de syntaxe | Vérifier le format markdown |
| Mauvais chemin | S'assurer d'être à la racine du projet |

### "Agent not triggered"

**Erreur** : L'agent devrait se déclencher mais rien ne se passe.

**Diagnostic** :
```bash
# Vérifier les agents
ls -la .claude/agents/

# Vérifier le contenu d'un agent
cat .claude/agents/qa-security.md
```

**Solutions** :
1. Vérifier que le fichier agent existe
2. Utiliser des mots-clés plus explicites dans la demande
3. Forcer avec : "Utilise l'agent xxx pour..."

### Erreur de permissions

**Erreur** : "Permission denied" lors d'une opération.

**Causes** :
- Mode sandbox activé
- Fichier en lecture seule
- Dossier protégé

**Solutions** :
```bash
# Vérifier les permissions
ls -la fichier

# Corriger les permissions
chmod 644 fichier
chmod 755 dossier

# Vérifier le mode sandbox dans les settings
cat .claude/settings.json | grep sandbox
```

---

## Erreurs de Build

### Build échoue après modification

**Erreur** : `npm run build` ou `flutter build` échoue.

**Diagnostic** :
```bash
# Voir l'erreur complète
npm run build 2>&1 | head -50

# Vérifier les types
npm run typecheck

# Vérifier le lint
npm run lint
```

**Solutions courantes** :

| Erreur | Solution |
|--------|----------|
| Type error | `/dev:dev-debug "Corriger l'erreur de type"` |
| Import manquant | Vérifier les exports/imports |
| Dépendance manquante | `npm install` |
| Version incompatible | Vérifier `package.json` |

### Dépendances en conflit

**Erreur** : "ERESOLVE unable to resolve dependency tree"

**Solutions** :
```bash
# Nettoyer et réinstaller
rm -rf node_modules package-lock.json
npm install

# Forcer la résolution (attention)
npm install --legacy-peer-deps

# Utiliser l'agent deps
/ops:ops-deps
```

---

## Erreurs de Tests

### Tests qui échouent

**Diagnostic** :
```bash
# Lancer les tests en mode verbose
npm test -- --verbose

# Lancer un test spécifique
npm test -- --grep "nom du test"
```

**Solutions courantes** :

| Symptôme | Cause probable | Solution |
|----------|----------------|----------|
| Tous les tests échouent | Setup cassé | Vérifier jest.config |
| Un test échoue | Code ou test incorrect | `/dev:dev-debug` |
| Tests lents | Pas de mock | Mocker les dépendances |
| Timeout | Async non géré | Ajouter async/await |

### Couverture insuffisante

**Diagnostic** :
```bash
npm run test:coverage
```

**Solution** :
```bash
# Analyser la couverture
/qa:qa-coverage

# Générer les tests manquants
/dev:dev-test "Ajouter des tests pour le fichier X"
```

---

## Erreurs de Git

### Commit rejeté par pre-commit

**Erreur** : Le hook pre-commit bloque le commit.

**Diagnostic** :
```bash
# Voir les erreurs
git commit -m "test" 2>&1
```

**Solutions** :

| Hook | Solution |
|------|----------|
| lint-staged | Corriger les erreurs de lint |
| tests | Corriger les tests |
| typecheck | Corriger les types |

```bash
# Corriger automatiquement le lint
npm run lint:fix

# Bypass temporaire (non recommandé)
git commit --no-verify -m "message"
```

### Merge conflict

**Diagnostic** :
```bash
# Voir les conflits
git status
git diff --name-only --diff-filter=U
```

**Solution** :
```bash
# Demander de l'aide
/dev:dev-debug "Résoudre le conflit de merge dans fichier X"
```

---

## Erreurs de Workflow

### workflow interrompu

**Problème** : Le workflow s'est arrêté en cours de route.

**Solutions** :
1. **Reprendre** : "Continue le workflow"
2. **Réexécuter** : Relancer la dernière commande
3. **Recommencer** : `/work:work-explore` puis continuer

### Incohérence dans le code généré

**Problème** : Le code généré ne suit pas les conventions du projet.

**Solutions** :
1. Toujours commencer par `/work:work-explore`
2. Vérifier les rules dans `.claude/rules/`
3. Ajouter des conventions dans `CLAUDE.md`

```bash
# Forcer l'exploration
/work:work-explore "Analyser les conventions de nommage et patterns"
```

---

## Erreurs Spécifiques par Stack

### React/Next.js

| Erreur | Solution |
|--------|----------|
| "Hydration failed" | Vérifier les différences client/serveur |
| "useEffect in server" | Déplacer dans un Client Component |
| "Dynamic import" | Ajouter `{ ssr: false }` |

### Flutter

| Erreur | Solution |
|--------|----------|
| "RenderFlex overflow" | Wrapper avec `Expanded` ou `Flexible` |
| "setState after dispose" | Vérifier le lifecycle |
| "Null check operator" | Ajouter une vérification null |

### Node.js/Express

| Erreur | Solution |
|--------|----------|
| "EADDRINUSE" | Un autre process utilise le port |
| "CORS error" | Configurer le middleware cors |
| "Unhandled rejection" | Ajouter un handler global |

---

## Commandes de Diagnostic

### Vérification rapide

```bash
# Health check du projet
/ops:ops-health

# Vérifier les dépendances
/ops:ops-deps

# Audit de sécurité
/qa:qa-security
```

### Debug approfondi

```bash
# Debug un problème spécifique
/dev:dev-debug "Description du problème"

# Explorer le code lié au problème
/work:work-explore "Comprendre comment X fonctionne"

# Analyser la dette technique
/qa:qa-tech-debt
```

---

## Logs et Diagnostics

### Activer les logs détaillés

```bash
# Claude Code debug mode
CLAUDE_DEBUG=1 claude

# Logs Node.js
DEBUG=* npm start

# Logs Flutter
flutter run -v
```

### Analyser les logs

```bash
# Dernières lignes
tail -100 logs/app.log

# Filtrer les erreurs
grep -i "error" logs/app.log

# Suivre en temps réel
tail -f logs/app.log
```

---

## Obtenir de l'aide

### Auto-diagnostic

1. Relire le message d'erreur complet
2. Chercher dans cette page (Ctrl+F)
3. Consulter la [FAQ](/docs/guides/faq)
4. Utiliser `/dev:dev-debug "votre erreur"`

### Support communautaire

1. **Rechercher** dans les [issues existantes](https://github.com/christopherlouet/claude-socle/issues)
2. **Ouvrir une issue** avec :
   - Description du problème
   - Étapes pour reproduire
   - Logs et messages d'erreur
   - Environnement (OS, versions)

### Template d'issue

```markdown
## Description
[Description claire du problème]

## Étapes pour reproduire
1. Lancer la commande X
2. Observer l'erreur Y

## Comportement attendu
[Ce qui devrait se passer]

## Comportement actuel
[Ce qui se passe réellement]

## Environnement
- OS: [macOS/Linux/Windows]
- Node: [version]
- Claude Code: [version]
- claude-socle: [version]

## Logs
```
[Coller les logs ici]
```
```

---

:::tip Prévention
La meilleure façon d'éviter les problèmes est de **toujours commencer par `/work:work-explore`** et de **commiter fréquemment** avec `/work:work-commit`.
:::
