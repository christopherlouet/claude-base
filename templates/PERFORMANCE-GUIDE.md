# Claude Code Performance Guide

Optimize Claude Code usage for faster responses and reduced token consumption.

## Core principles

```
┌─────────────────────────────────────────────────────────────┐
│              PERFORMANCE OPTIMIZATION                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. MINIMAL CONTEXT     → Fewer tokens = faster            │
│  ═══════════════════                                        │
│                                                             │
│  2. TARGETED AGENTS     → Optimized prompts = better       │
│  ════════════════           results                         │
│                                                             │
│  3. PRECISE REQUESTS    → Fewer back-and-forths            │
│  ═════════════════                                          │
│                                                             │
│  4. SPECIFIC FILES      → Avoid global reads               │
│  ════════════════════                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Context optimization

### What consumes tokens

| Element | Impact | Optimization |
|---------|--------|--------------|
| Files read | Very high | Limit to necessary files |
| Conversation history | High | New sessions for new tasks |
| Agent instructions | Medium | Well-structured agents |
| Arguments | Low | Be concise but precise |

### Best practices

#### Specify files

```bash
# ❌ Avoid - potentially reads everything
/explore

# ✅ Prefer - targets relevant files
/explore src/services/auth.ts
```

#### Use precise paths

```bash
# ❌ Too broad
/review src/

# ✅ More targeted
/review src/services/user-service.ts
```

#### Break down complex tasks

```bash
# ❌ A single massive request
"Analyze the whole project, find the bugs, refactor and optimize"

# ✅ Several targeted requests
/explore src/services/
/review src/services/user-service.ts
/refactor UserService
```

## Choosing the optimal agent

### Selection matrix

| Task | Optimal agent | Why |
|------|---------------|-----|
| Understand code | `/explore` | Optimized for analysis |
| Bug to fix | `/debug` | Debugging workflow |
| New code | `/tdd` | TDD structure |
| PR review | `/review` | Quality checklist |
| Commit | `/commit` | Conventional format |

### Avoid generic agents

```bash
# ❌ Non-specialized agent
"Can you look at this code and tell me if there are any security issues?"

# ✅ Specialized agent
/security src/api/
```

## Reduce back-and-forths

### Provide context all at once

```bash
# ❌ Fragmented conversation
User: "Look at AuthService"
Claude: [analysis]
User: "And also UserService"
Claude: [analysis]
User: "Compare the two"

# ✅ Complete context
/review "Compare AuthService and UserService, identify duplications"
```

### Use structured arguments

```bash
# ✅ Clear and complete arguments
/api POST /api/users {name: string, email: string} -> {id: string, created: Date}
```

## Agent optimization

### High-performance agent structure

```markdown
# HIGH-PERFORMANCE Agent

Concise description.

## Context
$ARGUMENTS

## Instructions

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Output

[Precise and concise format]
```

### Avoid in agents

| Anti-pattern | Impact | Alternative |
|--------------|--------|-------------|
| Long examples | Wasted tokens | Short, relevant examples |
| Repetitive instructions | Confusion | Unique, clear instructions |
| Multiple options | Slow decisions | Default recommendation |

## Metrics and monitoring

### Performance indicators

| Metric | Optimal | Action if exceeded |
|--------|---------|--------------------|
| Response time | < 30s | Reduce context |
| Tokens per request | < 10k | Target files |
| Back-and-forths | < 3 | Complete the initial context |

### Consumption estimation

```
Tokens ≈ (Files read × ~100-500 lines × 4 tokens/line)
        + (Agent instructions × 4 tokens/word)
        + (Arguments × 4 tokens/word)
```

## High-performance patterns

### "Scout then Act" pattern

```bash
# 1. Scout (fast, few tokens)
/explore src/auth/ --quick

# 2. Identify the key files
# -> src/auth/service.ts, src/auth/middleware.ts

# 3. Act (targeted)
/review src/auth/service.ts src/auth/middleware.ts
```

### "Divide and Conquer" pattern

```bash
# Divide a big task
/plan "Refactoring auth module"
# -> List of subtasks

# Run each subtask separately
/refactor src/auth/login.ts
/refactor src/auth/session.ts
/refactor src/auth/token.ts
```

### "Progressive Detail" pattern

```bash
# 1. Overview
/onboard --quick

# 2. Zoom in on a module
/explore src/services/

# 3. Detail of a file
/explain src/services/complex-algorithm.ts
```

## Recommended configuration

### Optimized CLAUDE.md

```markdown
## Essential conventions

- TypeScript strict
- Tests > 80%
- Conventional commits

## Structure
/src - Source code
/tests - Tests
/docs - Documentation

<!-- Avoid overly long instructions -->
```

### Recommended exclusions

In `.gitignore` or instructions:
```
node_modules/
dist/
build/
coverage/
*.log
.env*
```

## Before/after comparison

### Example: Code review

**Before (unoptimized)**
```
Time: ~2 min
Tokens: ~50k
"Can you do a complete review of all the project's code?"
```

**After (optimized)**
```
Time: ~20s
Tokens: ~8k
/review src/services/auth-service.ts
```

### Example: Debug

**Before (unoptimized)**
```
Time: ~3 min
Tokens: ~80k
"There's a bug somewhere in the application, can you find it?"
```

**After (optimized)**
```
Time: ~30s
Tokens: ~10k
/debug "Error: Token invalid" src/auth/
```

## Optimization checklist

### Before each request
- [ ] Have I identified the relevant files?
- [ ] Is the chosen agent the most suitable?
- [ ] Is the provided context sufficient and not excessive?

### Agent design
- [ ] Are the instructions concise?
- [ ] Are there any repetitions to eliminate?
- [ ] Are the examples minimal but clear?

### Workflow
- [ ] Are complex tasks broken down?
- [ ] Is each subtask autonomous?
- [ ] Is the scout-then-act pattern applicable?

---

## Resources

- [FAQ](./FAQ.md) - Frequently asked questions
- [Troubleshooting](./TROUBLESHOOTING.md) - Problem resolution
- [Architecture](./ARCHITECTURE.md) - Project structure
