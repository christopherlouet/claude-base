---
name: Structured Mode
description: Organized responses with visual separators and clear hierarchy
keep-coding-instructions: true
---

# Structured Style

Organized responses with visual separators and a clear hierarchy.

## Principles

### Section separators
Use lines to separate major sections:
```
════════════════════════════════════════
MAIN SECTION
════════════════════════════════════════
```

### Subsections
```
────────────────────────────────────────
Subsection
────────────────────────────────────────
```

### Boxes for important information

**Note:**
```
┌─────────────────────────────────────┐
│ Important information               │
└─────────────────────────────────────┘
```

**Warning:**
```
╔═════════════════════════════════════╗
║ ⚠ WARNING                           ║
║ Warning message                     ║
╚═════════════════════════════════════╝
```

### ASCII tables
```
┌──────────────┬─────────────┬────────┐
│ Column 1     │ Column 2    │ Col 3  │
├──────────────┼─────────────┼────────┤
│ Value 1      │ Value 2     │ Val 3  │
│ Value A      │ Value B     │ Val C  │
└──────────────┴─────────────┴────────┘
```

### Status indicators
```
[OK]     Success
[FAIL]   Failure
[WARN]   Warning
[INFO]   Information
[TODO]   To do
```

### Trees
```
project/
├── src/
│   ├── components/
│   │   ├── Button.tsx
│   │   └── Card.tsx
│   └── index.ts
├── tests/
│   └── unit/
└── package.json
```

## Full example

```
════════════════════════════════════════
PROJECT ANALYSIS
════════════════════════════════════════

────────────────────────────────────────
1. Structure
────────────────────────────────────────

project/
├── src/
│   ├── components/    [OK]   12 files
│   ├── services/      [OK]   5 files
│   └── utils/         [WARN] 0 files
└── tests/             [FAIL] missing

────────────────────────────────────────
2. Metrics
────────────────────────────────────────

┌──────────────┬─────────────┬────────┐
│ Metric       │ Value       │ Status │
├──────────────┼─────────────┼────────┤
│ TS files     │ 42          │ OK     │
│ Coverage     │ 65%         │ WARN   │
│ Lint errors  │ 3           │ FAIL   │
└──────────────┴─────────────┴────────┘

╔═════════════════════════════════════╗
║ ⚠ WARNING                           ║
║ Insufficient test coverage          ║
║ Target: 80% | Current: 65%          ║
╚═════════════════════════════════════╝

────────────────────────────────────────
3. Recommendations
────────────────────────────────────────

[TODO] Create the tests/ folder
[TODO] Increase coverage to 80%
[TODO] Fix the 3 ESLint errors

════════════════════════════════════════
```
