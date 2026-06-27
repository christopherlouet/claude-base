---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.dart"
  - "**/*.py"
  - "**/*.go"
  - "**/*.rs"
  - "**/*.java"
  - "**/*.cs"
  - "**/*.rb"
  - "**/*.php"
---

# TDD Enforcement Rules

## Proactive TDD Triggering

IMPORTANT: When the user asks to implement, add, create, fix or correct code, Claude MUST propose the TDD approach BEFORE starting to code.

### Trigger keywords

Propose TDD automatically when the user mentions:
- "implementer", "implement"
- "ajouter", "add"
- "creer", "create"
- "fixer", "fix"
- "corriger", "correct"
- "nouvelle feature", "new feature"
- "bug", "bugfix"
- "fonctionnalite"
- "developper", "develop"
- "coder", "code"

### Expected behavior

1. **BEFORE any source code modification**:
   - Propose: "I recommend using the TDD approach. Would you like me to start by writing the tests?"
   - Or directly use `/dev:dev-tdd` if the context is clear

2. **If the user refuses TDD**:
   - Respect their choice but remind them of the risks
   - Document in the commit that TDD was not used

3. **TDD exceptions** (no proposal):
   - Configuration files (*.json, *.yaml, *.toml)
   - Documentation (*.md)
   - Build/deploy scripts
   - Minor refactoring (renaming, formatting)
   - Typo fixes

### Systematic reminders

YOU MUST remind the TDD cycle when you modify code:

```
TDD cycle:
1. RED   - Write a failing test
2. GREEN - Write the minimal code to pass
3. REFACTOR - Improve without breaking the tests
```

### Integration with commands

When a development command is used (`/dev:dev-component`, `/dev:dev-api`, `/dev:dev-component`, etc.), Claude MUST:
1. Check whether tests exist for the code concerned
2. If not, propose to start with the tests
3. If yes, ensure the tests pass before modification

### Pre-commit validation

BEFORE proposing a commit:
- Check that tests exist for the new code
- Check that the tests pass
- Minimum 80% coverage on the new code

### Anti-patterns to block

NEVER:
- Write implementation code before the tests
- Propose to "test later"
- Ignore tests to "go faster"
- Modify the tests to make them pass (instead of fixing the code)
- Ship a hollow test (no real assertion / always-true / skipped / empty) or a
  stub implementation to make the suite green — coverage % does not catch these.
  The advisory **substance gate** (`scripts/substance-check.sh`, auto-run on
  Edit/Write) flags them; a green suite over hollow tests is not "done".
