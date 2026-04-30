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

Before implementing a custom solution, check whether the framework or tool in place already provides the functionality natively.

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

NEVER create more than 5 files for a standard feature without having confirmed that no native solution exists.
