---
name: qa-chrome
description: Visual tests and browser debugging via Chrome. Use to test web pages, verify visual rendering, debug with the console, or automate browser actions. Trigger when the user mentions "visual test", "Chrome", "browser", "browser console", "DOM", "screenshot", "GIF".
disable-model-invocation: true
argument-hint: "[url-or-page]"
---

# Visual Tests and Chrome Debugging (pointer)

DevTools features (network inspection, profiling, accessibility tree, console replay) are canonical at the Chrome team's [`ChromeDevTools/chrome-devtools-mcp`](https://github.com/ChromeDevTools/chrome-devtools-mcp) (Apache-2.0). Since 2026 it ships **seven skills** next to its MCP server: `chrome-devtools`, `chrome-devtools-cli`, `a11y-debugging`, `debug-optimize-lcp`, `memory-leak-debugging`, `cookie-debugging`, `troubleshooting`.

```bash
# The plugin bundles the skills and the MCP server, pinned (chrome-devtools-mcp@1.10.1 in v1.10.1)
/plugin marketplace add ChromeDevTools/chrome-devtools-mcp
/plugin install chrome-devtools-mcp@chrome-devtools-plugins
# MCP server only, pinned (the vendor's docs show @latest)
claude mcp add chrome-devtools --scope user npx chrome-devtools-mcp@1.10.1
```

This skill scopes to the **manual-review checklist** when using Claude Code's `--chrome` flag — *what to look for*, not *how the API works*.

## Prerequisites

- Claude Code launched with `--chrome`
- "Claude in Chrome" extension v1.0.36+
- Google Chrome open (not Brave/Arc/Firefox; no headless mode; WSL unsupported)

## Manual-review checklist

When asked to visually validate a page or flow:

- [ ] Page loads with no console error
- [ ] Layout correct (no overflow, no overlap, no z-index bug)
- [ ] Text readable (contrast meets WCAG AA — see `wcag-audit`)
- [ ] Images loaded (no broken sources, lazy-load completes)
- [ ] Links functional (no 404 in network panel)
- [ ] Forms submittable (validation triggers on bad input)
- [ ] Responsive OK across mobile/tablet/desktop breakpoints — see `qa-design` (responsive category)
- [ ] No network error (no 4xx/5xx unless intentional)

## Expected output

Structured report:
- Screenshots/GIFs of issues
- List of console + network errors with source location
- Recommendations sorted by severity
- Overall verdict: `OK` / `Warnings` / `Errors`

## See also

- `chrome-devtools-mcp` (vendor MCP server, programmatic layer) — `docs/recipes/recommended-vendor-skills.md`
- `qa-design` skill — UI/UX heuristics + responsive/breakpoint testing complement
- `wcag-audit` — accessibility gate when contrast/readability issues surface
- Audit pilot trace: `specs/marketplace-audit/qa-skills-pilot-2026-05-06.md`
