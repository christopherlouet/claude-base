---
name: dev-shadcn
description: Integration and customization of shadcn/ui (copy-paste React components, Radix + Tailwind). Trigger when the user wants to install shadcn, add components, customize the theme, or when shadcn/ui usage is detected in the project.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
background: false
---

# shadcn/ui (pointer)

The canonical shadcn skill ships **inside the library repository itself** at [`shadcn-ui/ui/skills/shadcn`](https://github.com/shadcn-ui/ui/tree/main/skills/shadcn). Because it lives next to the source, it stays in sync with the CLI v4 release flow — registry workflows, Radix + Base UI primitives, theming, and component patterns are updated the moment they ship, substantially deeper and fresher than the prior foundation skill (258 lines) could maintain.

## Delegate to the vendor skill

```bash
# shadcn's own CLI exposes the skill (verify on https://ui.shadcn.com/docs/skills):
npx shadcn skill add shadcn

# Fallback — clone the canonical repo and symlink:
git clone --depth 1 https://github.com/shadcn-ui/ui ~/dev/vendor-skills/shadcn-ui
ln -s ~/dev/vendor-skills/shadcn-ui/skills/shadcn ./.claude/skills/shadcn
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"shadcn/ui — canonical skill in main repo". Reduction rationale: [`specs/foundation-positioning-review/spec.md`](../../../specs/foundation-positioning-review/spec.md) Wave 1.

## Foundation-unique angle preserved: art direction

If the project declares a `Style:` direction in `CLAUDE.md` (`.claude/rules/design-style.md`), adapt the shadcn CSS tokens accordingly — the vendor skill stays direction-neutral, this mapping is foundation-specific:

| Direction | shadcn adaptation |
|-----------|-------------------|
| terminal | `--radius: 0px`, dark palette + neon accent, mono font everywhere |
| cockpit | `--radius: 4px`, functional colors (OK/warn/alert), dense layout |
| vitality | `--radius: 14px`, vivid palette, spring animations |
| editorial | `--radius: 2px`, black/white + one accent, serif for titles |
| glass | `--radius: 14px`, backdrop-blur on cards and dialogs |
| signal | `--radius: 4px`, gray only, compact sizes |

## Foundation rules preserved

- shadcn components are **copy-pasted into your codebase, not installed as a dependency** — treat them as first-class application code subject to TDD, security review, and `/qa:wcag-audit` for accessibility regressions when customised.
- NEVER override component styles via `!important` — modify the CSS variables instead.
- NEVER copy shadcn components into `node_modules/` or a libs-internal folder.
