# Troubleshooting Guide

Guide de résolution des problèmes courants avec Claude Code et les agents claude-socle.

## Table des matières

- [Problèmes avec les agents](#problèmes-avec-les-agents)
- [Problèmes Claude Code](#problèmes-claude-code)
- [Problèmes de performance](#problèmes-de-performance)
- [Erreurs courantes](#erreurs-courantes)

---

## Problèmes avec les agents

### L'agent ne se lance pas

**Symptôme**: `/agent-name` ne fait rien ou retourne une erreur.

**Causes possibles**:

1. **Fichier non trouvé**
   ```bash
   # Vérifier que le fichier existe
   ls .claude/commands/agent-name.md
   ```

2. **Syntaxe incorrecte du fichier**
   ```bash
   # Vérifier que le fichier est un Markdown valide
   # Le fichier doit commencer par "# Agent NAME"
   head -5 .claude/commands/agent-name.md
   ```

3. **Dossier .claude mal placé**
   ```bash
   # Le dossier .claude doit être à la racine du projet
   ls -la .claude/
   ```

**Solution**:
- Vérifier la structure du dossier `.claude/commands/`
- S'assurer que le fichier a l'extension `.md`
- Vérifier que le contenu commence par un titre `# Agent`

---

### L'agent ne reçoit pas les arguments

**Symptôme**: Les arguments passés à l'agent ne sont pas pris en compte.

**Cause**: Le placeholder `$ARGUMENTS` manque ou mal placé.

**Solution**:
```markdown
# Agent MON-AGENT

Description de l'agent.

## Contexte
$ARGUMENTS    <!-- Ce placeholder est OBLIGATOIRE -->

## Instructions
...
```

---

### L'agent produit des résultats incohérents

**Symptôme**: Les réponses varient trop ou ne suivent pas les instructions.

**Causes possibles**:

1. **Instructions trop vagues**
   - Ajouter des exemples concrets
   - Utiliser des checklists

2. **Conflits d'instructions**
   - Vérifier qu'il n'y a pas de contradictions
   - Prioriser clairement les règles

3. **Contexte insuffisant**
   - Ajouter plus de contexte dans `$ARGUMENTS`
   - Référencer des fichiers spécifiques

**Solution**:
```markdown
## Instructions

IMPORTANT: [Instruction critique]

YOU MUST [Action obligatoire]

NEVER [Action interdite]

Think hard sur [aspect à considérer]
```

---

## Problèmes Claude Code

### Claude Code ne démarre pas

**Symptôme**: La commande `claude` ne fonctionne pas.

**Solutions**:

1. **Vérifier l'installation**
   ```bash
   which claude
   claude --version
   ```

2. **Réinstaller si nécessaire**
   ```bash
   npm uninstall -g @anthropic-ai/claude-code
   npm install -g @anthropic-ai/claude-code
   ```

3. **Vérifier les permissions**
   ```bash
   # Sur macOS/Linux
   sudo npm install -g @anthropic-ai/claude-code
   ```

---

### Erreur d'authentification

**Symptôme**: "Invalid API key" ou erreur d'authentification.

**Solutions**:

1. **Vérifier la clé API**
   ```bash
   echo $ANTHROPIC_API_KEY
   ```

2. **Configurer la clé**
   ```bash
   export ANTHROPIC_API_KEY="sk-ant-..."
   ```

3. **Ajouter au profil shell**
   ```bash
   # .bashrc ou .zshrc
   export ANTHROPIC_API_KEY="sk-ant-..."
   ```

---

### Timeout ou connexion interrompue

**Symptôme**: Les requêtes échouent après un certain temps.

**Causes**:
- Connexion réseau instable
- Requête trop longue
- Rate limiting

**Solutions**:

1. **Vérifier la connexion**
   ```bash
   ping api.anthropic.com
   ```

2. **Réduire la taille des requêtes**
   - Diviser les tâches complexes
   - Utiliser des agents spécialisés

3. **Attendre et réessayer**
   - Les rate limits se réinitialisent après quelques minutes

---

## Problèmes de performance

### Réponses lentes

**Symptôme**: Claude met longtemps à répondre.

**Solutions**:

1. **Réduire le contexte**
   - Limiter les fichiers lus simultanément
   - Utiliser des agents ciblés

2. **Optimiser les prompts**
   ```markdown
   <!-- Éviter -->
   Analyse tout le projet et donne-moi un rapport complet...

   <!-- Préférer -->
   Analyse le fichier src/auth.ts et identifie les problèmes de sécurité.
   ```

3. **Utiliser le bon agent**
   - `/explore` pour la découverte rapide
   - Agents spécialisés pour les tâches ciblées

---

### Consommation de tokens élevée

**Symptôme**: Les crédits API sont consommés rapidement.

**Solutions**:

1. **Éviter les fichiers volumineux**
   ```markdown
   <!-- Éviter -->
   Lis tous les fichiers du projet

   <!-- Préférer -->
   Lis src/services/auth.ts
   ```

2. **Utiliser des agents ciblés**
   - Un agent spécialisé consomme moins qu'un agent générique

3. **Pré-filtrer le contexte**
   - Spécifier les fichiers pertinents
   - Exclure node_modules, dist, etc.

---

## Erreurs courantes

### "File not found"

**Cause**: Chemin de fichier incorrect.

**Solution**:
```bash
# Vérifier le chemin
ls -la chemin/vers/fichier

# Utiliser des chemins relatifs à la racine
./src/fichier.ts  # ✅
src/fichier.ts    # ✅
/chemin/absolu    # ⚠️ Éviter si possible
```

---

### "Permission denied"

**Cause**: Droits insuffisants sur le fichier ou dossier.

**Solution**:
```bash
# Vérifier les permissions
ls -la fichier

# Corriger si nécessaire
chmod 644 fichier.md
chmod 755 dossier/
```

---

### "Invalid markdown"

**Cause**: Syntaxe Markdown incorrecte dans l'agent.

**Vérifications**:
```markdown
# ✅ Correct
## Titre de niveau 2

# ❌ Incorrect
##Titre sans espace
```

**Points à vérifier**:
- Espaces après les `#` des titres
- Fermeture des blocs de code (```)
- Syntaxe des tableaux

---

### "Agent not recognized"

**Cause**: Le nom de l'agent ne correspond pas au fichier.

**Solution**:
```bash
# Le nom de commande est basé sur le nom du fichier
.claude/commands/mon-agent.md  →  /mon-agent
.claude/commands/MonAgent.md   →  /MonAgent
```

---

## Diagnostic général

### Checklist de diagnostic

```bash
# 1. Vérifier Claude Code
claude --version

# 2. Vérifier la structure
ls -la .claude/
ls -la .claude/commands/

# 3. Vérifier un agent spécifique
cat .claude/commands/agent-name.md | head -20

# 4. Vérifier les logs (si disponibles)
cat ~/.claude/logs/latest.log
```

### Réinitialisation complète

Si rien ne fonctionne:

```bash
# 1. Sauvegarder la configuration
cp -r .claude .claude.backup

# 2. Réinstaller Claude Code
npm uninstall -g @anthropic-ai/claude-code
npm cache clean --force
npm install -g @anthropic-ai/claude-code

# 3. Restaurer la configuration
mv .claude.backup .claude
```

---

## Obtenir de l'aide

Si le problème persiste:

1. **Documentation officielle**: https://docs.anthropic.com/claude-code
2. **GitHub Issues**: https://github.com/anthropics/claude-code/issues
3. **Community Discord**: [lien vers discord si applicable]

Avant de reporter un bug, préparez:
- Version de Claude Code (`claude --version`)
- OS et version
- Message d'erreur complet
- Étapes pour reproduire
