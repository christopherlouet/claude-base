---
name: dev-frontend-design
description: Distinctive UI design with strong art direction. Trigger when the user wants to create an interface, a landing page, a visual component, or when frontend code creation is detected without a defined design direction.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# Frontend Design with Art Direction

## Principle

AI-generated interfaces all look alike. Inter/Roboto typography, blue/purple palette, rounded cards, same visual rhythm. To stand out, you must **commit to an art direction before writing any code**.

## Mandatory workflow

### 1. Check the direction in CLAUDE.md

Read the project's CLAUDE.md to find a `Style:` directive:

```markdown
## Design Direction
Style: terminal    # or cockpit, vitality, editorial, glass, signal
```

If found, strictly apply the direction (see rule `.claude/rules/design-style.md`).

### 2. If no direction is defined — ASK

Before coding, ask the user:

> No art direction is defined in CLAUDE.md. Before coding, choose a direction:
>
> - **terminal**: monospace, black/neon green, sharp edges (for dev tools, web CLI)
> - **cockpit**: dense, multi-panels, real-time indicators (for dashboards, monitoring)
> - **vitality**: colorful, animated, generously rounded (for B2C apps, gamified)
> - **editorial**: serif, airy, paper/ivory (for blogs, long form)
> - **glass**: glassmorphism, gradients, depth (for premium modern apps)
> - **signal**: minimal, gray/white, dense utilitarian (for productivity tools)

## Fonts — what to ban

**Forbidden** (overused by AI):
- Inter, Roboto, Arial, Space Grotesk
- Helvetica (unless explicit editorial direction)

**Prefer** depending on the direction:

| Direction | Recommended fonts |
|-----------|-------------------|
| terminal | JetBrains Mono, Fira Code, IBM Plex Mono, Berkeley Mono |
| cockpit | DM Sans, Geist, IBM Plex Sans + Geist Mono for numbers |
| vitality | Nunito, Plus Jakarta Sans, Bricolage Grotesque, Instrument Serif |
| editorial | Playfair Display, Lora, Merriweather, Fraunces + Inter-like sans-serif |
| glass | Geist, SF Pro, Neue Haas Grotesk |
| signal | Geist Mono, IBM Plex Mono, system-ui |

IMPORTANT: If no direction is chosen and the user refuses to choose one, use **Geist** (modern neutral) but NEVER Inter/Roboto.

## Colors — banish the generic

**Patterns to avoid**:
- AI-stereotype blue/purple palette (#6366f1, #8b5cf6, gradients)
- Soft pastels without contrast
- Tailwind-default neutral grays

**Prefer**:

| Direction | Typical palette |
|-----------|-------------|
| terminal | `#0a0a0a` + a single neon accent (`#00ff9c`, `#00d8ff`, `#ffb000`) |
| cockpit | Layered dark (`#0d1117`, `#161b22`) + functional colors (alert red, OK green) |
| vitality | 3-4 distinct vivid colors (e.g., `#ff6b35`, `#004e89`, `#ffd23f`), light background |
| editorial | Black/white/cream + 1 accent (poppy red, midnight blue, moss green) |
| glass | Gradient or image background + semi-transparent `rgba` surfaces |
| signal | Gray/white only + strictly signaling colors |

## Radius — sign the personality

| Direction | Radius |
|-----------|--------|
| terminal, editorial | 0-4px (sharp) |
| cockpit, signal | 4-6px (subtle) |
| glass | 12-16px (fluid) |
| vitality | 12-16px (generous) |

IMPORTANT: Do NOT use `rounded-xl` / `rounded-2xl` by default "because it looks nice". Radius is a signature.

## Animations — reject the default

**Avoid**:
- Linear transitions `transition-all duration-300`
- Generic `1.05` scale hover

**Prefer**:

| Direction | Animation style |
|-----------|----------------|
| terminal | Caret blink, scanlines, glow pulse (100-150ms, step easing) |
| cockpit | Instant transitions, pulse on indicators, fade for updates |
| vitality | Subtle spring/bounce, fluid progress, celebratory feedback |
| editorial | Fade-in on scroll (300-500ms, ease-out), smooth transitions |
| glass | Blur transitions, fade with depth, subtle parallax |
| signal | Almost absent (50-100ms), instant feedback |

## Layout — break the AI grid

**Patterns to avoid**:
- Centered hero + 3 cards in a grid + CTA + footer
- Identical successive full-width sections
- Uniform padding everywhere

**Prefer**:
- Intentional asymmetry
- Variable density per zone (dense/airy)
- Grids not aligned on uniform columns
- Strategic whitespace (editorial) or maximum density (cockpit, signal)

## Checklist before writing code

- [ ] Art direction identified and validated with the user
- [ ] Fonts chosen (not Inter/Roboto/Arial by default)
- [ ] Palette defined (not AI-stereotype blue/purple)
- [ ] Radius consistent with the direction
- [ ] Animations consistent with the direction
- [ ] Non-stereotype layout (not auto hero/grid/CTA)

## Expected output

1. **Confirmation** of the chosen direction
2. **Design tokens**: fonts, colors, radius, spacing (CSS custom properties or Tailwind theme)
3. **Components** strictly respecting the direction
4. **No generic fallback** — once the direction is chosen, follow it fully

## Rules

IMPORTANT: NEVER code frontend without having confirmed the art direction.

IMPORTANT: NEVER use Inter, Roboto, Arial, Space Grotesk by default.

IMPORTANT: NEVER propose a centered hero + 3-card grid "because it's safe".

YOU MUST read `.claude/rules/design-style.md` for details per direction.

YOU MUST explain to the user the WHY of the design choices (artistic commitment > neutrality).

## See also

Anthropic ships a `frontend-design` plugin in their official Claude Code repository: [`anthropics/claude-code/plugins/frontend-design`](https://github.com/anthropics/claude-code/tree/main/plugins/frontend-design) (also installable from the marketplace at [claude.com/plugins/frontend-design](https://claude.com/plugins/frontend-design); 277K+ installs as of March 2026). It covers similar territory: bold design choices, typography, animations, and avoiding the "Inter font + purple gradient" generic aesthetic.

Users of `claude.com/code` likely already have this plugin installed by default. This skill captures the **art-direction taxonomy** (terminal, cockpit, vitality, editorial, glass, signal) the foundation imposes via `.claude/rules/design-style.md` plus the workflow integration (project's CLAUDE.md `Style:` declaration) — these are claude-base specific. The Anthropic plugin and this skill are complementary rather than duplicates.

Audit pilot trace: `specs/marketplace-audit/dev-skills-pilot-2026-05-05.md`.
