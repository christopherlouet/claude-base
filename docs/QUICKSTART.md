# Quick Start - claude-socle

> Demarrer en 5 minutes avec claude-socle

## Installation (30 secondes)

```bash
# Depuis le socle
./scripts/install.sh /chemin/vers/votre-projet

# Ou depuis votre projet
/chemin/vers/claude-socle/scripts/install.sh .
```

## Premier usage (2 minutes)

### 1. Explorer le projet

```bash
/work-explore "Comprendre l'architecture"
```

### 2. Specifier la feature

```bash
/work-specify "Ajouter authentification OAuth"
```

### 3. Planifier l'implementation

```bash
/work-plan "Implementer OAuth Google"
```

### 4. Developper

```bash
/dev-tdd "OAuth authentication flow"
```

### 5. Commiter

```bash
/work-commit
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
| `/work-explore` | Comprendre le code existant |
| `/work-specify` | Creer une specification fonctionnelle |
| `/work-plan` | Planifier une implementation |
| `/dev-tdd` | Developper avec tests |
| `/work-commit` | Creer un commit propre |
| `/work-pr` | Creer une Pull Request |
| `/qa-security` | Audit de securite OWASP |
| `/qa-audit` | Audit complet (secu + RGPD + a11y + perf) |

## Workflows raccourcis

| Commande | Description |
|----------|-------------|
| `/work-flow-feature` | Workflow complet pour nouvelle feature |
| `/work-flow-bugfix` | Workflow complet pour correction de bug |
| `/work-flow-release` | Workflow complet pour release |

## Aide

- `/assistant` - Point d'entree intelligent qui guide vers les bonnes commandes (mode guide)
- `/assistant-auto` - Execution automatique du workflow adapte (mode auto)
- Voir [CLAUDE.md](../CLAUDE.md) pour la documentation complete
- Voir [ARCHITECTURE.md](./ARCHITECTURE.md) pour comprendre Commands vs Agents vs Skills

## Ressources

- [Cheatsheet](./CHEATSHEET.md) - Reference rapide
- [Customization](./CUSTOMIZATION.md) - Personnalisation
- [Guide complet](./GUIDE.md) - Documentation detaillee
