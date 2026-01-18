---
sidebar_position: 1
title: Concepts Claude Code
description: Comprendre les concepts fondamentaux de Claude Code
---

# Concepts Claude Code

> Comprendre l'ecosysteme Claude Code pour mieux utiliser claude-socle

## Vue d'ensemble

Claude Code est un outil CLI d'Anthropic qui permet d'interagir avec Claude directement dans le terminal. Il offre plusieurs mecanismes d'extension et de personnalisation.

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLAUDE CODE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐   │
│  │ COMMANDS  │  │  AGENTS   │  │  SKILLS   │  │   RULES   │   │
│  │           │  │           │  │           │  │           │   │
│  │ Invocation│  │ Delegation│  │ Activation│  │Application│   │
│  │ manuelle  │  │   auto    │  │   auto    │  │ par path  │   │
│  │   /xxx    │  │ par Claude│  │ mots-cles │  │           │   │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘   │
│                                                                 │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐   │
│  │   HOOKS   │  │    MCP    │  │  OUTPUT   │  │ TEMPLATES │   │
│  │           │  │  SERVERS  │  │  STYLES   │  │           │   │
│  │ Pre/Post  │  │           │  │           │  │ Specs &   │   │
│  │ ToolUse   │  │ Extensions│  │ Formatage │  │ Plans     │   │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Les 8 concepts cles

| Concept | Description | Declenchement |
|---------|-------------|---------------|
| [**Commands**](/docs/concepts/commands) | Instructions invoquees manuellement | `/nom-commande` |
| [**Agents**](/docs/concepts/agents) | Sub-agents autonomes avec contexte isole | Delegation automatique |
| [**Skills**](/docs/concepts/skills) | Comportements actives par mots-cles | Detection automatique |
| [**Rules**](/docs/concepts/rules) | Conventions appliquees par chemin de fichier | Automatique selon path |
| [**Hooks**](/docs/concepts/hooks) | Actions avant/apres utilisation d'outils | PreToolUse / PostToolUse |
| [**MCP Servers**](/docs/concepts/mcp-servers) | Extensions via Model Context Protocol | Configuration .mcp.json |
| [**Output Styles**](/docs/concepts/output-styles) | Styles de formatage des reponses | `/output-style nom` |
| [**Templates**](/docs/concepts/templates) | Modeles pour specs, plans et taches | `/work-specify`, `/work-plan` |

## Comparaison rapide

### Commands vs Skills vs Agents

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  COMMAND                    SKILL                   AGENT      │
│  ────────                   ─────                   ─────      │
│                                                                │
│  /work-explore              "Je veux faire         Delegation  │
│  /dev-tdd                    du TDD"               automatique │
│  /qa-security                                      par Claude  │
│                                                                │
│  ┌──────────┐              ┌──────────┐          ┌──────────┐ │
│  │ Declench.│              │ Declench.│          │ Declench.│ │
│  │ MANUEL   │              │ AUTO     │          │ AUTO     │ │
│  └──────────┘              └──────────┘          └──────────┘ │
│                                                                │
│  ┌──────────┐              ┌──────────┐          ┌──────────┐ │
│  │ Contexte │              │ Contexte │          │ Contexte │ │
│  │ PARTAGE  │              │ FORK     │          │ ISOLE    │ │
│  └──────────┘              └──────────┘          └──────────┘ │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

| Aspect | Command | Skill | Agent |
|--------|---------|-------|-------|
| **Declenchement** | Manuel (`/xxx`) | Auto (mots-cles) | Auto (delegation) |
| **Contexte** | Partage | Fork (isole) | Isole |
| **Outils** | Tous | Restreints | Restreints |
| **Fichier** | `.claude/commands/*.md` | `.claude/skills/*/SKILL.md` | `.claude/agents/*.md` |

## Structure des fichiers

```
.claude/
├── commands/           # Commands manuelles
│   ├── work/
│   ├── dev/
│   ├── qa/
│   └── ...
├── agents/             # Sub-agents autonomes
├── skills/             # Skills auto-declenches
│   └── */SKILL.md
├── rules/              # Rules par technologie
├── output-styles/      # Styles de sortie
├── templates/          # Templates de specs/plans
└── settings.json       # Hooks et configuration
```

## Flux de travail typique

```
Utilisateur tape: "Fais un audit de securite"
         │
         ▼
    ┌─────────────────────────────────────┐
    │ Claude analyse la demande           │
    │                                     │
    │ 1. Skill "security-audit" detecte?  │──── Non ───┐
    │    (mots-cles: securite, OWASP)     │            │
    └─────────────────────────────────────┘            │
         │ Oui                                         │
         ▼                                             │
    ┌─────────────────────────────────────┐            │
    │ Skill injecte les instructions      │            │
    │ d'audit securite                    │            │
    └─────────────────────────────────────┘            │
         │                                             │
         ▼                                             ▼
    ┌─────────────────────────────────────┐    ┌──────────────┐
    │ Claude delegue a l'agent            │    │ Claude       │
    │ qa-security (contexte isole)        │    │ repond       │
    └─────────────────────────────────────┘    │ directement  │
         │                                     └──────────────┘
         ▼
    ┌─────────────────────────────────────┐
    │ Agent execute l'audit               │
    │ (outils: Read, Grep, Glob)          │
    └─────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────┐
    │ Resultat retourne a la              │
    │ conversation principale             │
    └─────────────────────────────────────┘
```

## Prochaines etapes

1. **Nouveau sur Claude Code?** Commencez par [Commands](./commands)
2. **Comprendre l'automatisation?** Lisez [Skills](./skills) et [Agents](./agents)
3. **Personnaliser le comportement?** Explorez [Hooks](/docs/concepts/hooks) et [Rules](/docs/concepts/rules)
4. **Etendre les capacites?** Decouvrez [MCP Servers](/docs/concepts/mcp-servers)
5. **Structurer vos features?** Utilisez les [Templates](/docs/concepts/templates)

---

## Voir aussi

- [Installation](/docs/intro/installation) - Installer claude-socle
- [Architecture](/docs/intro/architecture) - Architecture de claude-socle
- [Quick Start](/docs/intro/quick-start) - Demarrer rapidement
