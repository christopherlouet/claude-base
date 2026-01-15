# FAQ - Questions Fréquentes

Réponses aux questions les plus courantes sur claude-socle et les agents Claude Code.

---

## Général

### Qu'est-ce que claude-socle ?

claude-socle est un template de configuration pour Claude Code qui fournit un ensemble d'agents (slash commands) prêts à l'emploi pour optimiser votre workflow de développement.

---

### Quelle est la différence entre Claude Code et les agents ?

- **Claude Code** : L'outil CLI officiel d'Anthropic pour interagir avec Claude
- **Agents** : Des prompts pré-configurés (fichiers `.md`) qui spécialisent Claude pour des tâches spécifiques

---

### Comment installer claude-socle ?

```bash
# 1. Installer Claude Code
npm install -g @anthropic-ai/claude-code

# 2. Copier le dossier .claude dans votre projet
cp -r chemin/vers/claude-socle/.claude votre-projet/

# 3. C'est prêt !
cd votre-projet
claude
/explore
```

---

### Les agents fonctionnent-ils avec d'autres LLMs ?

Non, les agents claude-socle sont conçus spécifiquement pour Claude Code et l'API Anthropic. Cependant, les templates et structures peuvent être adaptés pour d'autres systèmes.

---

## Agents

### Comment créer mon propre agent ?

1. Créer un fichier `.md` dans `.claude/commands/`
2. Suivre la structure standard :

```markdown
# Agent MON-AGENT

Description courte de l'agent.

## Contexte
$ARGUMENTS

## Objectif
[Objectif de l'agent]

## Instructions
[Instructions détaillées]

## Output attendu
[Format de sortie]

---

IMPORTANT: [Instructions critiques]
```

---

### Comment nommer mes agents ?

| Convention | Exemple | Usage |
|------------|---------|-------|
| `dev-*` | `dev-tdd.md` | Développement |
| `qa-*` | `qa-review.md` | Qualité |
| `ops-*` | `ops-ci.md` | Opérations |
| `doc-*` | `doc-api.md` | Documentation |
| `biz-*` | `biz-mvp.md` | Business |
| `work-*` | `work-commit.md` | Workflow |

---

### Puis-je modifier les agents existants ?

Oui ! Les agents sont de simples fichiers Markdown. Vous pouvez :
- Les modifier pour les adapter à vos besoins
- Les dupliquer pour créer des variantes
- Les étendre avec vos propres instructions

---

### Comment passer des arguments à un agent ?

```bash
# Syntaxe
/agent-name argument1 argument2

# Exemples
/explore src/services/
/review AuthService
/commit "feat: add login"
```

Les arguments sont injectés via le placeholder `$ARGUMENTS` dans l'agent.

---

### Pourquoi mon agent ignore-t-il certaines instructions ?

Quelques raisons possibles :

1. **Instructions contradictoires** : Vérifiez qu'il n'y a pas de conflits
2. **Instructions trop nombreuses** : Priorisez les plus importantes
3. **Format** : Utilisez `IMPORTANT:`, `YOU MUST`, `NEVER` pour les règles critiques

---

## Workflow

### Quel est le workflow recommandé ?

```
1. /explore  → Comprendre le code existant
2. /plan     → Planifier les modifications
3. /tdd      → Développer avec tests
4. /review   → Vérifier la qualité
5. /commit   → Commiter les changements
6. /pr       → Créer la Pull Request
```

---

### Dois-je toujours suivre ce workflow ?

Non, c'est une recommandation. Adaptez selon vos besoins :

| Tâche | Workflow suggéré |
|-------|------------------|
| Bug fix simple | `explore → fix → commit` |
| Nouvelle feature | `explore → plan → tdd → review → commit → pr` |
| Refactoring | `explore → plan → refactor → review → commit` |
| Documentation | `doc → commit` |

---

### Quand utiliser `/explore` vs `/onboard` ?

| Agent | Usage |
|-------|-------|
| `/explore` | Exploration ciblée d'une partie du code |
| `/onboard` | Découverte complète d'un nouveau codebase |

---

## Performance et coûts

### Comment réduire la consommation de tokens ?

1. **Utilisez des agents ciblés** plutôt que des agents génériques
2. **Spécifiez les fichiers** à analyser
3. **Évitez les requêtes vagues** comme "analyse tout le projet"
4. **Utilisez `explore`** pour identifier d'abord les fichiers pertinents

---

### Quelle est la taille maximale de contexte ?

Claude a une fenêtre de contexte de 200k tokens. Pour les projets volumineux :
- Utilisez des agents ciblés
- Analysez par module/dossier
- Excluez les fichiers non pertinents

---

### Les agents augmentent-ils les coûts ?

Les agents sont des prompts pré-configurés. Ils n'ajoutent pas de coût par eux-mêmes, mais des instructions plus détaillées peuvent légèrement augmenter la consommation de tokens par requête.

---

## Personnalisation

### Comment ajouter mes conventions de code ?

Modifiez le fichier `CLAUDE.md` à la racine de votre projet :

```markdown
## Conventions de Code

### Nommage
- Variables: camelCase
- Constantes: SCREAMING_SNAKE
- Fichiers: kebab-case

### Règles spécifiques
- [Vos règles ici]
```

---

### Comment partager mes agents avec mon équipe ?

Les agents sont dans le dossier `.claude/commands/`. Options :

1. **Commit dans le repo** : Les agents seront partagés avec le code
2. **Repo séparé** : Créez un repo dédié aux agents d'équipe
3. **Submodule** : Utilisez un submodule git pour les agents partagés

---

### Puis-je avoir des agents privés et partagés ?

Oui, utilisez deux sources :

```
projet/
├── .claude/
│   └── commands/           # Agents du projet (partagés)
│       └── ...
└── ~/.claude/
    └── commands/           # Agents personnels (privés)
        └── ...
```

---

## Dépannage

### Où trouver de l'aide ?

1. **TROUBLESHOOTING.md** : Guide de résolution des problèmes
2. **Documentation Claude Code** : https://docs.anthropic.com/claude-code
3. **GitHub Issues** : https://github.com/anthropics/claude-code/issues

---

### Comment reporter un bug ?

Avant de reporter :
1. Vérifiez dans TROUBLESHOOTING.md
2. Cherchez dans les issues existantes
3. Préparez : version, OS, étapes de reproduction, logs

---

### L'agent X ne fonctionne pas comme attendu

1. Relisez les instructions de l'agent
2. Vérifiez que vous passez les bons arguments
3. Essayez avec un exemple simple
4. Consultez TROUBLESHOOTING.md

---

## Mises à jour

### Comment mettre à jour les agents ?

```bash
# Si vous utilisez un repo git
git pull origin main

# Si copie manuelle
# Téléchargez la nouvelle version et remplacez .claude/commands/
```

---

### Les mises à jour écrasent-elles mes modifications ?

Si vous avez modifié les agents :
1. **Sauvegardez** vos modifications avant la mise à jour
2. **Utilisez des fichiers séparés** pour vos agents personnalisés
3. **Versionnez** avec git pour suivre les changements

---

## Questions techniques

### Les agents peuvent-ils appeler d'autres agents ?

Les agents peuvent **référencer** d'autres agents dans leurs instructions, mais pas les appeler automatiquement. L'utilisateur doit invoquer chaque agent manuellement.

---

### Quelle est la syntaxe supportée dans les agents ?

- **Markdown standard** : Titres, listes, tableaux, code blocks
- **Placeholders** : `$ARGUMENTS` pour les arguments
- **Instructions spéciales** : `IMPORTANT:`, `YOU MUST`, `NEVER`, `Think hard`

---

### Puis-je utiliser des variables d'environnement ?

Les agents n'ont pas accès direct aux variables d'environnement. Passez les valeurs via `$ARGUMENTS` :

```bash
/deploy production $MY_API_KEY
```

---

## Contribution

### Comment contribuer à claude-socle ?

1. Fork le repo
2. Créez une branche pour vos modifications
3. Suivez les conventions existantes
4. Testez vos agents
5. Créez une Pull Request

Voir CONTRIBUTING.md pour plus de détails.

---

### Puis-je proposer de nouveaux agents ?

Absolument ! Les contributions sont bienvenues :
- Nouveaux agents pour des cas d'usage manquants
- Améliorations des agents existants
- Corrections de bugs
- Amélioration de la documentation
