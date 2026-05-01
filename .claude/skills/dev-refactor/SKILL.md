---
name: dev-refactor
description: Code refactoring to improve quality. Trigger when the user wants to clean up, restructure, or improve existing code.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
argument-hint: "[file-or-module]"
---

# Code Refactoring

## Principles

1. **Tests pass BEFORE and AFTER**
2. **Small incremental changes**
3. **One type of change at a time**
4. **Commit after each refactoring**

## Common techniques

### Extract Function

```typescript
// Before
function processOrder(order) {
  // 20 lines of validation
  // 30 lines of calculation
  // 10 lines of sending
}

// After
function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order);
  sendConfirmation(order, total);
}
```

### Extract Variable

```typescript
// Before
if (user.age >= 18 && user.country === 'FR' && !user.banned) { }

// After
const isAdult = user.age >= 18;
const isFrench = user.country === 'FR';
const isActive = !user.banned;
if (isAdult && isFrench && isActive) { }
```

### Replace Conditional with Polymorphism

```typescript
// Before
function getPrice(type) {
  switch(type) {
    case 'basic': return 10;
    case 'premium': return 20;
  }
}

// After
interface Plan { getPrice(): number }
class BasicPlan implements Plan { getPrice() { return 10; } }
class PremiumPlan implements Plan { getPrice() { return 20; } }
```

## Code Smells to detect

| Smell | Refactoring |
|-------|-------------|
| Long method | Extract Method |
| Large class | Extract Class |
| Duplicate code | Extract + Reuse |
| Long parameter list | Parameter Object |
| Feature envy | Move Method |
| Primitive obsession | Value Object |

## Reducing Entropy (Complexity reduction)

### Complexity metrics

| Metric | Alert threshold | How to measure |
|--------|----------------|----------------|
| **Cyclomatic complexity** | > 10 per function | Number of branches (if/else/switch) |
| **Nesting depth** | > 3 levels | Nesting of if/for/while |
| **Function length** | > 50 lines | Number of lines |
| **Number of parameters** | > 4 | Function parameters |
| **Afferent/efferent coupling** | Unstable ratio | Incoming/outgoing dependencies |
| **File size** | > 300 lines | Lines of code |

### Reduction techniques

#### Early Return (eliminate nesting)

```typescript
// BEFORE: deep nesting (high entropy)
function process(user) {
  if (user) {
    if (user.isActive) {
      if (user.hasPermission) {
        return doWork(user);
      }
    }
  }
  return null;
}

// AFTER: early returns (low entropy)
function process(user) {
  if (!user) return null;
  if (!user.isActive) return null;
  if (!user.hasPermission) return null;
  return doWork(user);
}
```

#### Break down complex conditions

```typescript
// BEFORE
if (user.age >= 18 && user.country === 'FR' && !user.banned && user.email.includes('@')) { }

// AFTER
const isEligible = user.age >= 18
  && user.country === 'FR'
  && !user.banned
  && isValidEmail(user.email);
if (isEligible) { }
```

#### Eliminate dead code

```bash
# Find unused exports
# Find functions never called
# Remove unused imports
# Remove obsolete comments
# Remove orphan files
```

#### Consolidate duplications

```
Rule of 3: refactor on the 3rd duplication, not before.
- 1st occurrence: write the code
- 2nd occurrence: note the duplication (comment)
- 3rd occurrence: extract into a function/module
```

## Workflow

1. MEASURE current complexity (metrics)
2. Identify the code smell
3. Write/verify tests
4. Apply the refactoring
5. MEASURE complexity after (must decrease)
6. Verify tests
7. Commit
8. Repeat
