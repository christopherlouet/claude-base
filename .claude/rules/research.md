---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.dart"
  - "**/*.rs"
---

# Research Before Build

## Principle

Write the **least code that satisfies the requirement**. Before implementing anything custom, walk the decision ladder below and stop at the first rung that works. Over-engineering — building beyond the stated need — is a defect, not thoroughness.

## Minimal-code decision ladder

Apply *after* understanding the problem, top to bottom; the first rung that solves it wins. Safety is never a rung you skip — input validation, output escaping, auth, error handling and accessibility always stay.

| # | Ask | If yes |
|---|-----|--------|
| 1 | Does this need to exist at all? (**YAGNI**) | Don't build it — confirm the requirement first |
| 2 | Already in the codebase? | Reuse / extend the existing pattern, don't re-invent |
| 3 | Covered by the **standard library**? | Use stdlib |
| 4 | A **native** framework/platform feature? | Use native (even if less flexible) |
| 5 | An already-installed dependency? | Use it |
| 6 | A **clear** one-liner? | Write the one line — but NEVER trade readability for fewer characters |
| 7 | None of the above | Minimum viable implementation — readable, with its error handling and edge-case tests; document why |

> **"Minimal" = fewer _things_, NOT denser code.** It means not building what isn't needed (speculative options, premature abstraction, reinvented stdlib) — it does **not** mean cramming logic into clever one-liners, skipping error handling, or dropping edge-case tests. Readability, error handling, input validation and edge-case tests are part of "done", never "extra" to be trimmed. Fewer lines that are unreadable or fragile is a REGRESSION, not a win. When in doubt, the [`testing`](testing.md), [`verification`](verification.md) and [`security`](security.md) rules win over brevity.

## Mandatory checklist before implementation

| Step | Action | Example |
|------|--------|---------|
| 1 | Read the docs of the framework in use | Next.js, Payload CMS, Prisma, Flutter |
| 2 | Search in the existing codebase | `grep -r "feature"`, explore the modules |
| 3 | Check available plugins/extensions | npm packages, pub.dev, crates.io |
| 4 | Evaluate build vs buy | Custom effort vs existing solution |

## Red Flags — STOP and research

| Signal | Reaction |
|--------|----------|
| About to create 5+ files for a common feature | STOP — the framework probably handles it |
| Implementing a standard pattern (auth, i18n, upload, focal point) | STOP — check the framework's docs |
| Writing a wrapper around an existing lib | STOP — the lib may already expose this API |
| Reimplementing a removed feature | STOP — check why it was removed |
| Adding an option/flag/abstraction "for the future" | STOP — YAGNI; add it when a real caller needs it |
| Building an abstraction for a single call site | STOP — inline it; abstract on the 2nd–3rd use |

## Workflow

```
1. IDENTIFY the precise need
2. SEARCH in the framework/CMS/lib in use
   - Official documentation
   - grep/glob in node_modules or packages
   - GitHub issues/discussions of the framework
3. EVALUATE: native vs custom
   - Native exists → use it
   - Native partial → extend rather than replace
   - Nothing exists → implement custom (document why)
4. INFORM the user of the choice and the reasoning
```

## Rules

IMPORTANT: NEVER implement a custom solution without first checking the native capabilities of the framework in use.

IMPORTANT: If a native solution exists, prefer it even if it is less flexible than a custom solution.

IMPORTANT: Prefer the simplest rung that works; do NOT add flexibility, options, or abstraction for hypothetical future needs (YAGNI). Generality is earned by a second real caller, not anticipated.

NEVER create more than 5 files for a standard feature without having confirmed that no native solution exists.
