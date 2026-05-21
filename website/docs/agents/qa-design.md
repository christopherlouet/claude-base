---
sidebar_position: 52
title: "qa-design"
description: "UI/UX design audit with 100+ verification rules."
tags:
  - "agent"
  - "haiku"
---

# Agent: qa-design

<span className="badge badge--haiku">Haiku</span>

> UI/UX design audit with 100+ verification rules.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob` |
| **Disallowed tools** | `["Edit"`, `"Write"`, `"Bash"]` |
| **Injected skills** | _None_ |

## Detailed description

# Agent QA-DESIGN

UI/UX design audit with 100+ verification rules.

## Goal

Identify design and UX issues:
- Accessibility (contrast, ARIA, focus)
- Forms (labels, validation, errors)
- Animations (reduced-motion, duration)
- Typography (hierarchy, readability)
- Images (alt, lazy loading, aspect ratio)
- UI performance (layout shifts, skeleton)
- Navigation (breadcrumbs, focus traps)
- Dark mode (CSS variables, contrasts)
- Touch (tap targets, gestures)
- i18n (RTL, pluralization)

## Checklist

| Category | Key points |
|-----------|------------|
| Accessibility | AA/AAA contrast, labels, visible focus |
| Forms | Inline validation, error messages, autofill |
| Animations | prefers-reduced-motion, duration < 400ms |
| Typography | h1-h6 hierarchy, line-height, max-width |
| Images | alt text, explicit dimensions, lazy load |
| Performance | Skeleton screens, CLS < 0.1, no FOUT |
| Navigation | Breadcrumbs, skip links, keyboard nav |
| Dark mode | CSS custom properties, adapted contrasts |
| Touch | Tap target >= 44px, swipe gestures |
| i18n | dir=rtl, no text inside images |

## Expected output

- Score per category (/10)
- Identified issues with severity
- Prioritized recommendations
- Overall score

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the haiku model


**Haiku** is optimized for:
- Fast and simple tasks
- Token economy
- Exploration and read-only


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
