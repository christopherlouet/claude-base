# Quick Start - claude-socle

> Demarrer en 5 minutes avec claude-socle

## Installation (30 secondes)

```bash
# Depuis le socle
./scripts/new-project.sh --simple /chemin/vers/votre-projet

# Ou depuis votre projet
/chemin/vers/claude-socle/scripts/new-project.sh --simple .
```

## Premier usage (2 minutes)

### 1. Explorer le projet

```bash
/work:work-explore "Comprendre l'architecture"
```

### 2. Specifier la feature

```bash
/work:work-specify "Ajouter authentification OAuth"
```

### 3. Planifier l'implementation

```bash
/work:work-plan "Implementer OAuth Google"
```

### 4. Developper

```bash
/dev:dev-tdd "OAuth authentication flow"
```

### 5. Commiter

```bash
/work:work-commit
```

## Workflow complet

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ EXPLORE │───▶│ SPECIFY │───▶│  PLAN   │───▶│  CODE   │───▶│ COMMIT  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

## Commandes les plus utilisees

| Commande | Usage |
|----------|-------|
| `/work:work-explore` | Comprendre le code existant |
| `/work:work-specify` | Creer une specification fonctionnelle |
| `/work:work-plan` | Planifier une implementation |
| `/dev:dev-tdd` | Developper avec tests |
| `/work:work-commit` | Creer un commit propre |
| `/work:work-pr` | Creer une Pull Request |
| `/qa:qa-security` | Audit de securite OWASP |
| `/qa:qa-audit` | Audit complet (secu + RGPD + a11y + perf) |

## Workflows raccourcis

| Commande | Description |
|----------|-------------|
| `/work:work-flow-feature` | Workflow complet pour nouvelle feature |
| `/work:work-flow-bugfix` | Workflow complet pour correction de bug |
| `/work:work-flow-release` | Workflow complet pour release |

## Aide

- `/assistant` - Point d'entree intelligent qui guide vers les bonnes commandes (mode guide)
- `/assistant-auto` - Execution automatique du workflow adapte (mode auto)
- Voir [CLAUDE.md](../CLAUDE.md) pour la documentation complete
- Voir [ARCHITECTURE.md](./ARCHITECTURE.md) pour comprendre Commands vs Agents vs Skills

## Ressources

- [Cheatsheet](./CHEATSHEET.md) - Reference rapide
- [Customization](./CUSTOMIZATION.md) - Personnalisation
- [Documentation Docusaurus](https://christopherlouet.github.io/claude-socle/) - Documentation complete
