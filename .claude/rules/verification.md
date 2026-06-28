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

# Verification Before Completion

## Principle

Any implementation must be verified BEFORE being considered complete.
Never assume a fix works without proving it.

## Mandatory verification checklist

### After a bug fix

```
[ ] The original bug is reproduced
[ ] The fix actually corrects the problem
[ ] Existing tests still pass
[ ] A non-regression test is added
[ ] No side effects detected
```

### After a new feature

```
[ ] The feature works as specified
[ ] Edge cases are handled (null, empty, limits)
[ ] Tests cover the happy path AND errors
[ ] The code compiles/lints without warnings
[ ] The feature has not degraded performance
```

### After a refactoring

```
[ ] Behavior is identical before/after
[ ] Tests pass without modification
[ ] No functional regression
[ ] The code is actually simpler/more readable
```

## Verification method

### 1. Automated verification

```bash
# Run the tests
npm test           # or pytest, go test, flutter test

# Check types
npm run typecheck  # or mypy, go vet

# Run the linter
npm run lint       # or ruff, golangci-lint
```

### 2. Manual verification

- Re-read the full diff (`git diff`)
- Verify that each change is intentional
- Make sure no debug/TODO is left behind
- Confirm that unused imports are removed

### 3. Defense in depth

- Add assertions on critical invariants
- Validate preconditions at function entry
- Log unexpected states without crashing

### 4. Substance check (not just "green")

A passing suite is evidence only if the tests assert something and the code is
implemented — coverage % does not catch hollow tests or stubs. Run the advisory
detector over the changed files and address what it flags (or mark intentional
cases with an inline `substance:ignore`):

```bash
./scripts/substance-check.sh <changed-files>   # flags: no-assertion | always-true | skipped | empty | stub | focused
```

It also runs automatically (advisory) on each Edit/Write via the **substance gate**
hook. Disable: `SKIP_SUBSTANCE_CHECK=1`.

## Gate Function (mandatory before any completion claim)

```
BEFORE declaring a status or expressing satisfaction:

1. IDENTIFY: Which command proves this claim?
2. EXECUTE: Run the FULL command (fresh, not a previous run)
3. READ: Full output, check the return code, count the errors
4. CONFIRM: Does the output confirm the claim?
   - If NO: Give the actual status with evidence
   - If YES: Make the claim WITH the evidence
5. ONLY THEN: Make the claim

Skipping a step = unverified claim
```

## Red Flags — STOP immediately

| Warning signal | Reaction |
|-----------------|----------|
| Using "should", "probably", "seems" | STOP — run the verification |
| Expressing satisfaction before verification ("Great!", "Perfect!", "Done!") | STOP — evidence first |
| About to commit/push/PR without verification | STOP — Gate Function |
| Trusting the success report of a sub-agent | STOP — verify independently |
| Settling for partial verification | STOP — partial proves nothing |
| "Just this once" or "It should work" | STOP — no exception |

## Required evidence table

| Claim | Required evidence | Insufficient |
|-------------|---------------|-------------|
| "Tests pass" | Test output: 0 failures | Previous run, "should pass" |
| "Linter is clean" | Linter output: 0 errors | Partial verification |
| "Build succeeds" | Build command: exit 0 | "Linter passes so it builds" |
| "The bug is fixed" | Test of original symptom: passes | "I changed the code" |
| "Requirements are met" | Line-by-line checklist | "Tests pass" |

## Destructive Operations Gate

Before any operation that deletes or mass-modifies data:

| Operation | Mandatory verification |
|-----------|-------------------------|
| `DELETE FROM` / `TRUNCATE` | Count affected rows with `SELECT COUNT(*)` first |
| `DROP TABLE` / `DROP DATABASE` | Confirm with the user + backup |
| `rm -rf` on uploads/media/storage | List the files first, confirm the count |
| `prisma migrate reset` / `--force` | Backup the DB before execution |
| Data cleanup/purge | Dry-run first (`SELECT` before `DELETE`) |

```
BEFORE a destructive operation:
1. COUNT: How many items will be affected?
2. SAMPLE: Show 5 examples to the user
3. CONFIRM: Wait for explicit validation
4. BACKUP: Create a backup if possible
5. EXECUTE: Run the operation
6. VERIFY: Confirm the expected result
```

IMPORTANT: NEVER execute DELETE/DROP/TRUNCATE/rm on production data without explicit user confirmation.

IMPORTANT: Always do a dry-run (SELECT/ls) before a mass deletion.

## Rules

IMPORTANT: NEVER say "it's fixed" without having run the tests.

IMPORTANT: Always verify the full diff before committing.

NEVER assume a change is safe. Prove it.

NEVER express satisfaction or completion without fresh evidence.
