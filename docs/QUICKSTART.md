# Quick Start - claude-socle

> Demarrer en 5 minutes avec claude-socle

## Installation (30 secondes)

```bash
# Depuis le socle
./scripts/new-project.sh --simple /chemin/vers/votre-projet

# Ou depuis votre projet
/chemin/vers/claude-socle/scripts/new-project.sh --simple .
```

## Premier usage

Le workflow obligatoire du socle, étape par étape :

### 1. Explorer le projet

```bash
/work:work-explore "Comprendre l'architecture"
```

### 2. (optionnel) Brainstormer les alternatives

```bash
/work:work-brainstorm "Pour ajouter OAuth, quelles approches ?"
```

### 3. Specifier la feature

```bash
/work:work-specify "Ajouter authentification OAuth"
```

### 4. Planifier l'implementation

```bash
/work:work-plan "Implementer OAuth Google"
```

### 5. Developper en TDD

```bash
/dev:dev-tdd "OAuth authentication flow"
```

### 6. Auditer (obligatoire avant commit)

```bash
/qa:qa-loop "score 90"   # Audit + fix en boucle jusqu'au score cible
```

### 7. Commiter

```bash
/work:work-commit
```

## Workflow complet

```
┌─────────┐  ┌──────────┐  ┌─────────┐  ┌──────┐  ┌─────┐  ┌───────┐  ┌────────┐
│ EXPLORE │→│BRAINSTORM│→│ SPECIFY │→│ PLAN │→│ TDD │→│ AUDIT │→│ COMMIT │
│         │  │ (option) │  │         │  │      │  │     │  │ ≥ 90  │  │  + PR  │
└─────────┘  └──────────┘  └─────────┘  └──────┘  └─────┘  └───────┘  └────────┘
```

> **Skip pour les changements triviaux** : `/work:work-quick` (< 50 LOC, 1-3 fichiers).

## Commandes les plus utilisees

| Commande | Usage |
|----------|-------|
| `/work:work-explore` | Comprendre le code existant |
| `/work:work-specify` | Creer une specification fonctionnelle |
| `/work:work-plan` | Planifier une implementation |
| `/dev:dev-tdd` | Developper avec tests |
| `/work:work-commit` | Creer un commit propre |
| `/work:work-pr` | Creer une Pull Request |
| `/qa:qa-loop` | **Audit + fix en boucle (score 90 par défaut)** — recommandé avant commit |
| `/qa:qa-security` | Audit de securite OWASP |
| `/qa:qa-audit` | Audit complet (secu + RGPD + a11y + perf) en lecture seule |

## Workflows raccourcis

| Commande | Description |
|----------|-------------|
| `/work:work-flow-feature` | Workflow complet pour nouvelle feature |
| `/work:work-flow-bugfix` | Workflow complet pour correction de bug |
| `/work:work-flow-release` | Workflow complet pour release |
| `/work:work-flow-launch` | Workflow complet pour lancement produit |
| `/work:work-quick` | Changement trivial (< 50 LOC, 1-3 fichiers) — skip cycle complet |

## Aide

- `/assistant` - Point d'entree intelligent qui guide vers les bonnes commandes (mode guide)
- `/assistant-auto` - Execution automatique du workflow adapte (mode auto)
- Voir [CLAUDE.md](../CLAUDE.md) pour la documentation complete
- Voir [ARCHITECTURE.md](./ARCHITECTURE.md) pour comprendre Commands vs Agents vs Skills

## Ressources

- [Cheatsheet](./CHEATSHEET.md) - Reference rapide
- [Customization](./CUSTOMIZATION.md) - Personnalisation
- [Documentation Docusaurus](https://christopherlouet.github.io/claude-socle/) - Documentation complete
