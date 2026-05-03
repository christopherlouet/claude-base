---
sidebar_position: 7
title: "dev-debug"
description: "Debug and resolve problems. Use when the user has a bug, an error, an unexpected behavior, or wants to understand why something is not working."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-debug

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Debug and resolve problems. Use when the user has a bug, an error, an unexpected behavior, or wants to understand why something is not working.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Glob`, `Grep`, `Bash` |
| **Keywords** | `dev`, `debug`, `quick fix for now`, `let's just try changing x` |

## Detailed description

# Debug a Problem

## Goal

Identify the root cause of a bug methodically via a systematic 4-phase approach.

## Systematic Methodology (4 Phases)

```
┌──────────────────────────────────────────────────────────────────┐
│                   SYSTEMATIC DEBUGGING                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PHASE 1: OBSERVATION          Collect without interpreting       │
│  ═══════════════════                                              │
│  - Reproduce the exact symptom                                    │
│  - Document the environment                                       │
│  - Capture logs, stack traces, states                             │
│  - DO NOT jump to conclusions                                     │
│                                                                   │
│  PHASE 2: HYPOTHESES           Reason systematically              │
│  ════════════════════                                             │
│  - List ALL possible causes                                       │
│  - Rank by probability (high/medium/low)                          │
│  - Define a validation test for each hypothesis                   │
│  - Use the 5 Whys technique                                       │
│                                                                   │
│  PHASE 3: INVESTIGATION        Prove, do not assume               │
│  ══════════════════════                                           │
│  - Test ONE hypothesis at a time                                  │
│  - Use strategic tracing and logging                              │
│  - Isolate with binary search (code or git bisect)                │
│  - Document each tested hypothesis (confirmed/refuted)            │
│                                                                   │
│  PHASE 4: VERIFICATION         Confirm the fix is real            │
│  ════════════════════                                             │
│  - Reproduce the original bug (must fail without the fix)         │
│  - Apply the minimal fix                                          │
│  - Prove the bug is fixed                                         │
│  - Verify the absence of side effects                             │
│  - Add a non-regression test                                      │
│  - Defense in depth: assertions on invariants                     │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## Phase 1: Observation

**Key questions:**
- What is happening exactly?
- What should happen?
- When did it start?
- Is it 100% reproducible?
- What are the aggravating/mitigating factors?

```bash
# Recent logs
tail -100 logs/app.log 2>/dev/null

# Latest commits
git log --oneline -10

# Recent changes in the suspect area
git log --oneline -5 -- src/path/suspect/
```

## Phase 2: Hypotheses

### Hypothesis matrix

| # | Hypothesis | Probability | Validation test |
|---|------------|-------------|-----------------|
| 1 | [Most likely] | High | [How to verify] |
| 2 | [Secondary] | Medium | [How to verify] |
| 3 | [Less likely] | Low | [How to verify] |

### 5 Whys technique

```
Problem: The application crashes at login

1. Why? -> The JWT token is invalid
2. Why? -> The token has expired
3. Why? -> The refresh token was not called
4. Why? -> The interceptor did not detect the expiration
5. Why? -> Timezone bug in the comparison

Root cause: Timezone bug in the refresh logic
```

### Common causes by type

| Bug type | Frequent causes |
|----------|-----------------|
| **Null/Undefined** | Missing data, race condition, API changed |
| **Type error** | Wrong type, JSON parsing, implicit conversion |
| **Off-by-one** | Array index, loop, `<` vs `<=` comparison |
| **Race condition** | Async without await, shared state, timing |
| **Memory leak** | Event listeners, closures, circular references |
| **Regression** | Recent change, side effect, dependency update |

## Phase 3: Investigation

### Tracing techniques

```typescript
// Strategic tracing (not console.log everywhere)
function trace(label: string, data: unknown) {
  console.log(`[TRACE:${label}]`, JSON.stringify(data, null, 2));
}

// Trace points at boundaries
trace('INPUT', { args });       // Function entry
trace('STATE', { variables });  // Intermediate state
trace('OUTPUT', { result });    // Function exit
trace('BRANCH', { condition }); // Decision taken
```

### Binary search in the code

```
1. Comment out half of the suspect code
2. Does the bug persist?
   - Yes -> The bug is in the remaining half
   - No  -> The bug is in the commented half
3. Repeat until isolating the exact line
```

### Git bisect (find the faulty commit)

```bash
git bisect start
git bisect bad                 # Current version broken
git bisect good <commit>       # Last known good version
# Test and mark good/bad until finding the commit
git bisect reset
```

## Phase 4: Verification (MANDATORY)

### Prove the fix works

```
1. WITHOUT the fix: reproduce the bug -> failure confirmed
2. WITH the fix: same scenario        -> success confirmed
3. Existing tests                     -> all pass
4. Non-regression test                -> written and passes
5. Side effects                       -> verified absent
```

### Defense in depth

```typescript
// Add assertions on critical invariants
function processPayment(amount: number, userId: string) {
  assert(amount > 0, 'Payment amount must be positive');
  assert(userId, 'User ID is required');
  // ...business code...
}
```

### Completion checklist

```
[ ] Bug reproduced reliably
[ ] Root cause identified (not just the symptom)
[ ] Minimal fix applied (no opportunistic refactoring)
[ ] Non-regression test added
[ ] Existing tests pass
[ ] No side effects
[ ] Fix documentation (descriptive commit message)
```

## Expected output

```markdown
## Diagnosis: [Bug description]

### Phase 1 - Observation
**Symptom:** [What happens]
**Expected behavior:** [What should happen]
**Reproduction:** [Steps 1, 2, 3...]

### Phase 2 - Hypotheses
| # | Hypothesis | Probability | Result |
|---|------------|-------------|--------|
| 1 | [...] | High | Confirmed/Refuted |

### Phase 3 - Investigation
**Root cause:** `src/xxx.ts:42` - [Technical explanation]
**5 Whys:** [Causal chain]

### Phase 4 - Verification
- [x] Bug reproduced
- [x] Fix applied
- [x] Non-regression test added
- [x] All tests pass
- [x] No side effects
```

## Rules

- Do not assume - verify (Phase 4 mandatory)
- One bug at a time
- Understand BEFORE fixing
- Always add a non-regression test
- Document every tested hypothesis, even refuted ones
- The fix must be MINIMAL - no opportunistic refactoring

## Iron Law: No fix without root cause

IMPORTANT: NEVER propose a fix before identifying the root cause. Symptom fixes mask the real problem and create new bugs.

### Red flags (rationalizations to avoid)

| Phrase | Problem |
|--------|---------|
| "Quick fix for now" | Avoids the root cause |
| "Let's just try changing X" | Guess-and-check, not systematic |
| "I don't really understand but it should work" | Blind fix |
| "It's urgent, no time to investigate" | Systematic investigation is FASTER |

### Rule of 3 failures

After 3 failed fix attempts: STOP. Do not attempt a 4th fix.

1. Question the basic assumptions
2. Broaden the search perimeter
3. Check whether the problem is architectural (not just a local bug)
4. Consider `git bisect` to find the faulty commit

### Metrics

| Approach | Average time | 1st-attempt fix rate |
|----------|--------------|----------------------|
| Systematic (4 phases) | 15-30 min | ~95% |
| Random fixing (guess-and-check) | 2-3h | ~40% |

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to dev..."_
- _"I want to debug..."_
- _"I want to quick fix for now..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Debugging example

# Debugging example

## Reported issue
"Users can no longer log in since this morning. 500 error on /api/login"

## Diagnostic

### 1. Reproduction
```bash
curl -X POST https://api.example.com/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

**Result:**
```json
{
  "error": "Internal Server Error",
  "statusCode": 500
}
```

Bug reproduced 100%.

### 2. Information gathering

```bash
# Recent logs
tail -100 /var/log/app/error.log
```

**Logs found:**
```
2024-01-15 09:23:45 ERROR [AuthService] Connection refused: Redis
2024-01-15 09:23:45 ERROR [AuthService] Failed to get session: ECONNREFUSED
2024-01-15 09:23:46 ERROR [AuthController] Login failed: Redis connection error
```

```bash
# Latest commits
git log --oneline -5
```

**Result:**
```
a1b2c3d (HEAD) chore: update dependencies
f4e5d6c feat: add rate limiting
9g8h7i6 fix: typo in README
```

### 3. Hypothesis

The commit `f4e5d6c feat: add rate limiting` likely added a Redis dependency that is not configured in production.

### 4. Verification

```bash
# Check the suspect commit
git show f4e5d6c --stat
```

**Modified files:**
```
src/middleware/rate-limit.ts | 45 +++++
src/config/redis.ts          | 12 ++
package.json                 |  1 +
```

```bash
# Check Redis config in prod
echo $REDIS_URL
# (empty)
```

**Cause confirmed**: `REDIS_URL` variable not defined in production.

### 5. Root cause identified

| Element | Value |
|---------|--------|
| **File** | `src/config/redis.ts:8` |
| **Problem** | Redis connection without configured URL |
| **Why** | Deployment without the environment variable |
| **Faulty commit** | `f4e5d6c` |

```typescript
// src/config/redis.ts:8
const redis = new Redis(process.env.REDIS_URL); // REDIS_URL is undefined
```

## Solution

### Option 1: Configure Redis (recommended)
```bash
# Add the variable in production
heroku config:set REDIS_URL=redis://...
```

### Option 2: Graceful fallback (temporary)
```typescript
// src/config/redis.ts
const redis = process.env.REDIS_URL
  ? new Redis(process.env.REDIS_URL)
  : null;

// src/middleware/rate-limit.ts
if (!redis) {
  console.warn('Rate limiting disabled: Redis not configured');
  return next();
}
```

## Applied resolution

```bash
# 1. Configure Redis in prod
heroku config:set REDIS_URL="redis://..."

# 2. Restart the application
heroku restart

# 3. Verify the fix
curl -X POST https://api.example.com/api/login ...
# ✅ 200 OK
```

## Post-mortem

### Impact
- **Duration**: 2h15 (09:00 - 11:15)
- **Affected users**: ~500
- **Severity**: P1 (major feature broken)

### Preventive actions
1. [ ] Add environment variable checks at startup
2. [ ] Add integration test for rate limiting
3. [ ] Document required variables in the README

### Non-regression test added
```typescript
describe('Rate Limiting', () => {
  it('should work without Redis configured', () => {
    delete process.env.REDIS_URL;
    // The middleware must not crash
    expect(() => rateLimitMiddleware(req, res, next)).not.toThrow();
  });
});
```



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
