---
sidebar_position: 1
title: Claude Code Concepts
description: Understand the fundamental concepts of Claude Code
---

# Claude Code Concepts

> Understand the Claude Code ecosystem to better use claude-socle

## Overview

Claude Code is a CLI tool from Anthropic that lets you interact with Claude directly in the terminal. It offers several extension and customization mechanisms.

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLAUDE CODE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐   │
│  │ COMMANDS  │  │  AGENTS   │  │  SKILLS   │  │   RULES   │   │
│  │           │  │           │  │           │  │           │   │
│  │  Manual   │  │   Auto    │  │   Auto    │  │  Path-    │   │
│  │ invocation│  │delegation │  │activation │  │  based    │   │
│  │   /xxx    │  │ by Claude │  │ keywords  │  │application│   │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘   │
│                                                                 │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐   │
│  │   HOOKS   │  │    MCP    │  │  OUTPUT   │  │ TEMPLATES │   │
│  │           │  │  SERVERS  │  │  STYLES   │  │           │   │
│  │ Pre/Post  │  │           │  │           │  │ Specs &   │   │
│  │ ToolUse   │  │ Extensions│  │ Formatting│  │ Plans     │   │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## The 10 key concepts

| Concept | Description | Trigger |
|---------|-------------|---------|
| [**Orchestrator**](/docs/concepts/orchestrator) | Single entry point that guides toward the right resources | `/assistant` |
| [**Commands**](/docs/concepts/commands) | Manually invoked instructions | `/command-name` |
| [**Agents**](/docs/concepts/agents) | Autonomous sub-agents with isolated context | Automatic delegation |
| [**Skills**](/docs/concepts/skills) | Behaviors activated by keywords | Automatic detection |
| [**Rules**](/docs/concepts/rules) | Conventions applied by file path | Automatic based on path |
| [**Hooks**](/docs/concepts/hooks) | Actions before/after tool use | PreToolUse / PostToolUse |
| [**MCP Servers**](/docs/concepts/mcp-servers) | Extensions via Model Context Protocol | .mcp.json configuration |
| [**Output Styles**](/docs/concepts/output-styles) | Response formatting styles | `/output-style name` |
| [**Templates**](/docs/concepts/templates) | Models for specs, plans and tasks | `/work:work-specify`, `/work:work-plan` |
| [**Advanced Features**](/docs/concepts/advanced-features) | Opus 4.7, Agent Teams, Plugins, LSP | Advanced configuration |

## Quick comparison

### Commands vs Skills vs Agents

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  COMMAND                    SKILL                   AGENT      │
│  ────────                   ─────                   ─────      │
│                                                                │
│  /work:work-explore              "I want to do        Automatic   │
│  /dev:dev-tdd                    TDD"                delegation  │
│  /qa:qa-security                                      by Claude  │
│                                                                │
│  ┌──────────┐              ┌──────────┐          ┌──────────┐ │
│  │ Trigger: │              │ Trigger: │          │ Trigger: │ │
│  │ MANUAL   │              │ AUTO     │          │ AUTO     │ │
│  └──────────┘              └──────────┘          └──────────┘ │
│                                                                │
│  ┌──────────┐              ┌──────────┐          ┌──────────┐ │
│  │ Context: │              │ Context: │          │ Context: │ │
│  │ SHARED   │              │ FORK     │          │ ISOLATED │ │
│  └──────────┘              └──────────┘          └──────────┘ │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

| Aspect | Command | Skill | Agent |
|--------|---------|-------|-------|
| **Trigger** | Manual (`/xxx`) | Auto (keywords) | Auto (delegation) |
| **Context** | Shared | Fork (isolated) | Isolated |
| **Tools** | All | Restricted | Restricted |
| **File** | `.claude/commands/*.md` | `.claude/skills/*/SKILL.md` | `.claude/agents/*.md` |

## File structure

```
.claude/
├── commands/           # Manual commands
│   ├── work/
│   ├── dev/
│   ├── qa/
│   └── ...
├── agents/             # Autonomous sub-agents
├── skills/             # Auto-triggered skills
│   └── */SKILL.md
├── rules/              # Rules per technology
├── output-styles/      # Output styles
├── templates/          # Spec/plan templates
└── settings.json       # Hooks and configuration
```

## Typical workflow

```
User types: "Run a security audit"
         │
         ▼
    ┌─────────────────────────────────────┐
    │ Claude analyzes the request         │
    │                                     │
    │ 1. Skill "security-audit" detected? │──── No ────┐
    │    (keywords: security, OWASP)      │            │
    └─────────────────────────────────────┘            │
         │ Yes                                         │
         ▼                                             │
    ┌─────────────────────────────────────┐            │
    │ Skill injects security audit        │            │
    │ instructions                        │            │
    └─────────────────────────────────────┘            │
         │                                             │
         ▼                                             ▼
    ┌─────────────────────────────────────┐    ┌──────────────┐
    │ Claude delegates to the             │    │ Claude       │
    │ qa-security agent (isolated context)│    │ responds     │
    └─────────────────────────────────────┘    │ directly     │
         │                                     └──────────────┘
         ▼
    ┌─────────────────────────────────────┐
    │ Agent runs the audit                │
    │ (tools: Read, Grep, Glob)           │
    └─────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────┐
    │ Result returned to the              │
    │ main conversation                   │
    └─────────────────────────────────────┘
```

## Next steps

1. **New to Claude Code?** Start with the [Orchestrator](/docs/concepts/orchestrator) (`/assistant`)
2. **Want to understand commands?** Read [Commands](./commands)
3. **Want to understand automation?** Read [Skills](./skills) and [Agents](./agents)
4. **Customize behavior?** Explore [Hooks](/docs/concepts/hooks) and [Rules](/docs/concepts/rules)
5. **Extend capabilities?** Discover [MCP Servers](/docs/concepts/mcp-servers)
6. **Structure your features?** Use the [Templates](/docs/concepts/templates)

---

## See also

- [Installation](/docs/intro/installation) - Install claude-socle
- [Architecture](/docs/intro/architecture) - claude-socle architecture
- [Quick Start](/docs/intro/quick-start) - Get started quickly
