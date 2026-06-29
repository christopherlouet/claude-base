---
sidebar_position: 3
title: Agents Matrix
description: Breakdown of all claude-base agents by model
---

# Agents Matrix

> **<!-- count:agents -->45<!-- /count --> sub-agents** grouped by model
>
> For the exhaustive list with per-agent tools and full descriptions, see the [Agents catalog](/docs/reference/agents-catalog) (auto-generated from `.claude/agents/`).

## By model

Breakdown: **13 Haiku** (fast/economical), **27 Sonnet** (analysis, default), **5 Opus** (critical reasoning).

### Haiku — fast / economical (13)

| Agent | Usage |
|-------|-------|
| `work-explore` | Explore and understand a codebase (read-only) |
| `doc-onboard` | Discover a codebase / new-developer onboarding |
| `doc-changelog` | Maintain the changelog (Keep a Changelog) |
| `doc-explain` | Explain complex code |
| `biz-model` | Business model / Lean Canvas |
| `growth-cro` | Conversion rate optimization + funnel |
| `growth-localization` | Multi-market localization strategy |
| `legal-privacy-policy` | GDPR privacy policy |
| `legal-terms-of-service` | Terms of Service |
| `ops-cost` | Claude Code token costs + cloud FinOps |
| `ops-deps` | Dependency audit, vulnerabilities |
| `ops-health` | Quick project health check |
| `wcag-audit` | WCAG 2.1/2.2 accessibility audit |

### Sonnet — analysis / default (27)

| Agent | Usage |
|-------|-------|
| `doc-generate` | Generate technical documentation |
| `dev-document` | Office document generation (PDF, DOCX, XLSX, PPTX) |
| `dev-flutter` | Flutter widgets and screens |
| `work-quick` | Quick workflow for trivial changes |
| `work-batch` | Sequential execution of stories from a PRD |
| `biz-competitor` | Market study + competitive analysis |
| `biz-mvp` | MVP definition |
| `biz-personas` | User personas |
| `growth-analytics` | Analytics and tracking setup |
| `growth-landing` | Optimized landing pages |
| `growth-seo` | Technical SEO audit |
| `data-pipeline` | ETL/ELT pipelines |
| `legal-payment` | Payment integration |
| `legal-rgpd` | GDPR compliance |
| `qa-perf` | Performance audit, Core Web Vitals |
| `qa-chrome` | Chrome visual tests and debugging |
| `qa-e2e` | End-to-End tests (Playwright, Cypress) |
| `qa-claudemd` | CLAUDE.md / repo-convention compliance audit |
| `ops-ci` | CI/CD configuration |
| `ops-database` | DB schema and migrations |
| `ops-deploy` | Secure deployment with pre-deploy checklist |
| `ops-docker` | Docker containerization |
| `ops-infra-code` | Infrastructure as Code (Terraform) |
| `ops-migration` | Framework and version migration |
| `ops-monitoring` | Instrumentation + observability stack |
| `ops-opnsense` | OPNsense configuration via Terraform |
| `ops-proxmox` | Proxmox VE infrastructure |

### Opus — critical reasoning (5)

| Agent | Usage |
|-------|-------|
| `qa-security` | OWASP Top 10 security audit |
| `qa-audit` | Full audit (security + GDPR + a11y + perf) |
| `qa-loop` | Autonomous audit-fix loop |
| `dev-tdd` | TDD development (Red-Green-Refactor) |
| `dev-debug` | Bug investigation and diagnosis |

---

## See also

- [Commands Matrix](/docs/reference/commands-matrix)
- [Cheatsheet](/docs/reference/commands)
- [Architecture](/docs/intro/architecture)
