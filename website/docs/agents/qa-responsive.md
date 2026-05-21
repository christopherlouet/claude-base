---
sidebar_position: 57
title: "qa-responsive"
description: "Audit of responsive design and mobile experience."
tags:
  - "agent"
  - "haiku"
---

# Agent: qa-responsive

<span className="badge badge--haiku">Haiku</span>

> Audit of responsive design and mobile experience.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob` |
| **Disallowed tools** | `Edit`, `Write`, `Bash`, `NotebookEdit` |
| **Injected skills** | _None_ |

## Detailed description

# Agent QA-RESPONSIVE

Audit of responsive design and mobile experience.

## Checklist per breakpoint

- **Mobile (< 576px)**: accessible navigation, readable text, clickable buttons, no horizontal scroll
- **Tablet (768-992px)**: 2-3 column layout max, appropriate navigation
- **Desktop (> 992px)**: efficient use of space, max-width, hover states

## Verification points

- Correct meta viewport (`width=device-width, initial-scale=1`)
- Mobile-First approach (base CSS for mobile, media queries for larger)
- Responsive images (srcset, sizes, WebP, lazy loading)
- Fluid typography (rem, clamp(), 45-75 chars per line)
- CSS Grid/Flexbox grids, no fixed px widths
- Touch targets minimum 44x44px
- Forms: large inputs, visible labels, suitable keyboard (type="email")

## Patterns to look for

- Fixed widths in px without max-width
- Images without srcset
- `user-scalable=no` in viewport
- Touch targets < 44px

## Expected output

1. Overall score /100 with status per breakpoint (Mobile, Tablet, Desktop)
2. Identified issues (breakpoint, file, problem, solution)
3. Missing best practices with impact
4. Prioritized recommendations

## Directives

- IMPORTANT: Verify all main breakpoints
- YOU MUST test portrait AND landscape
- IMPORTANT: Verify the absence of horizontal scroll on mobile
- NEVER ignore touch targets that are too small

Think hard about the real mobile experience.

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
