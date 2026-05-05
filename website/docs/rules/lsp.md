---
sidebar_position: 13
title: "lsp"
description: "LSP available via `ENABLE_LSP_TOOL=1` or LSP plugins configured in `.lsp.json`. Language servers must be installed locally (npm, pip, go install, etc."
tags:
  - "rule"
  - "lsp"
---

# Rules: lsp

> LSP available via `ENABLE_LSP_TOOL=1` or LSP plugins configured in `.lsp.json`. Language servers must be installed locally (npm, pip, go install, etc.).

## Affected files

These rules apply to files matching the following patterns:

- `**/*.ts`
- `**/*.tsx`
- `**/*.py`
- `**/*.go`
- `**/*.rs`
- `**/*.java`
- `**/*.cs`
- `**/*.rb`
- `**/*.php`
- `**/*.kt`
- `**/*.dart`

## Detailed rules

# LSP Usage Rules

## When to use LSP vs Grep/Glob

### Prefer LSP (semantic precision)

- `goToDefinition`: find the exact definition of a symbol (function, class, variable)
- `findReferences`: all typed references of a symbol in the project
- `hover`: get the type and documentation of a symbol
- `documentSymbol`: list the symbols of a file (functions, classes, exports)
- `getDiagnostics`: compilation errors, missing types, invalid imports

### Prefer Grep/Glob (textual coverage)

- Text search in comments, strings, config files
- Multi-language search or in non-code files (JSON, YAML, MD)
- Search for complex regex patterns
- Search in files not indexed by the LSP

## Best practices

- Combine both: LSP to navigate the code, Grep to search broadly
- Use `getDiagnostics` after modification to check type errors
- Use `findReferences` before a refactoring to measure the impact

## Activation

LSP available via `ENABLE_LSP_TOOL=1` or LSP plugins configured in `.lsp.json`.
Language servers must be installed locally (npm, pip, go install, etc.).

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)
