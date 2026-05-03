---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/components/**"
  - "**/pages/**"
  - "**/app/**"
---

# Design Style Rules

## Art Direction

The project's design direction is defined in CLAUDE.md:

```markdown
## Design Direction
Style: <direction>
```

If no direction is specified, apply `modern` (equivalent of the former glass).

## Available directions

### terminal — The interface that codes

| Aspect | Direction |
|--------|-----------|
| Palette | Black/very dark background, single neon accent (green, cyan, or amber), light high-readability text |
| Typography | Monospace (JetBrains Mono, Fira Code, IBM Plex Mono), hierarchy by weight and size |
| Radius | Sharp: 0-4px, crisp edges |
| Spacing | Compact, dense, tight padding (8-12px), aligned grids |
| Animations | Scan lines, glow pulse, caret blink, fast fade-in (100-150ms). No bounce or spring |
| Components | Bordered cards (1px solid), prompt-style inputs, outlined buttons, monochrome badges |
| Anti-patterns | Rounded corners > 8px, colored gradients, cartoon illustrations, diffuse shadows, pastels |

### cockpit — The pilot's dashboard

| Aspect | Direction |
|--------|-----------|
| Palette | Dark-first, functional colors (red alert, green OK, amber warning, blue info), layered dark background |
| Typography | Condensed sans-serif (Inter, DM Sans), monospace for numerical data, hierarchy by density |
| Radius | Low: 4-6px, functional |
| Spacing | Dense, multi-column grids, little whitespace, juxtaposed panels |
| Animations | Fast transitions (100-200ms), pulse on real-time indicators, fade for data updates |
| Components | Modular widgets, inline mini-charts, status badges, KPI cards, dense tables, sparklines |
| Anti-patterns | Large illustrations, excessive whitespace, very rounded corners, slow animations, single-column layouts |

### vitality — Positive energy

| Aspect | Direction |
|--------|-----------|
| Palette | Vivid and harmonious, 3-4 well-distinct category colors, light or cream background, energetic accents |
| Typography | Rounded and friendly sans-serif (Nunito, Plus Jakarta Sans, DM Sans), bold and engaging headings |
| Radius | Generous: 12-16px, soft shapes |
| Spacing | Airy, comfortable padding (16-24px), breathing space between sections |
| Animations | Progression micro-animations (bars, counters), subtle spring/bounce (200-300ms), celebratory feedback |
| Components | Colored cards with icons, progress bars, streaks, reward badges, full and rounded buttons |
| Anti-patterns | Default dark mode, monospace, technical/austere aesthetic, lack of color, dense layouts |

### editorial — The digital magazine

| Aspect | Direction |
|--------|-----------|
| Palette | Neutral and sober, dominant black/white, 1 editorial accent color, white or paper-cream background |
| Typography | Serif for headings (Playfair Display, Lora, Merriweather), sans-serif for body, very pronounced hierarchy |
| Radius | Minimal: 0-4px, straight lines |
| Spacing | Very airy, large whitespace, generous margins, max-width 65-75ch for text |
| Animations | Subtle, fade-in on scroll (200-400ms), soft page transitions. No decorative animation |
| Components | Full-format image cards, stylized quotes, thin separators, discreet navigation, clean lists |
| Anti-patterns | Visual overload, multiple bright colors, emojis, gamified badges, complex grids, pronounced shadows |

### glass — Modern transparency

| Aspect | Direction |
|--------|-----------|
| Palette | Background with depth (subtle gradient or image), semi-transparent surfaces, single luminous accent |
| Typography | Geometric sans-serif (Geist, Inter, SF Pro), light to medium weights, hierarchy by opacity |
| Radius | Medium-generous: 12-16px, fluid shapes |
| Spacing | Balanced, medium padding (16-20px), layering with spacing between surfaces |
| Animations | Blur transitions, fade with depth (200-300ms), hover with elevation, subtle parallax |
| Components | Glassmorphism cards (backdrop-blur + bg opacity), overlays, floating panels, translucent buttons |
| Anti-patterns | Hard edges, flat opaque backgrounds, hard shadows, raw high contrast, technical/terminal aesthetic |

### signal — Raw efficiency

| Aspect | Direction |
|--------|-----------|
| Palette | Neutral (gray/white), colors limited to strict signal (action, error, success), no decoration |
| Typography | Sans-serif system-ui or geometric (Inter, system-ui), tight sizes, no frills |
| Radius | Low: 4-6px, utilitarian |
| Spacing | Tight but readable, minimal padding (8-12px), maximum density without sacrificing readability |
| Animations | Near-absent, instant transitions (50-100ms), immediate feedback, no decorative animation |
| Components | Inline inputs, contextual actions, command palette, keyboard shortcuts, compact tables, flat menus |
| Anti-patterns | Illustrations, gradients, decorative shadows, long animations, large margins, visual frills |

## Applying directions

IMPORTANT: The direction applies to ALL of the project's themes. A theme (light, dark, sepia) only changes the color palette, not the visual personality.

IMPORTANT: Do not mix directions. If the project is `terminal`, a light theme stays monospace, compact, with crisp edges.

YOU MUST read the `Style:` directive in CLAUDE.md before generating UI code.

YOU MUST adapt components, spacing, animations, and typography to the chosen direction.

NEVER generate generic/default UI code when a direction is specified.

NEVER change direction mid-project without explicit instruction.
