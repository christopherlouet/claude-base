# Example: Tech Debt Inventory

## Scenario
Audit a 2-year-old Node.js API to inventory and prioritize technical debt.

## Debt Inventory

### Critical (fix within 1 sprint)

| ID | Category | Description | Impact | Effort |
|----|----------|-------------|--------|--------|
| TD-001 | Security | Express 4.17 has known CVEs, upgrade to 4.21+ | High | S |
| TD-002 | Reliability | No error handling middleware; unhandled rejections crash server | High | S |
| TD-003 | Data | Raw SQL queries with string interpolation (SQL injection risk) | High | M |

### High (fix within 1 month)

| ID | Category | Description | Impact | Effort |
|----|----------|-------------|--------|--------|
| TD-004 | Maintainability | 3 god classes > 800 lines (OrderController, UserService, Utils) | Medium | L |
| TD-005 | Testing | Test coverage at 23%, no integration tests | Medium | L |
| TD-006 | Types | 47 `any` types across codebase, no strict mode | Medium | M |
| TD-007 | Dependencies | 12 packages 2+ major versions behind | Medium | M |

### Medium (plan for next quarter)

| ID | Category | Description | Impact | Effort |
|----|----------|-------------|--------|--------|
| TD-008 | Architecture | Circular dependencies between 5 modules | Low | L |
| TD-009 | DX | No linting or formatting configured | Low | S |
| TD-010 | Observability | Console.log only, no structured logging | Low | M |
| TD-011 | API | Inconsistent error response formats across 15 endpoints | Low | M |

## Metrics Summary

```
Total debt items:        11
Critical:                3   (fix immediately)
High:                    4   (plan this month)
Medium:                  4   (next quarter)

Estimated total effort:  ~45 story points
Test coverage:           23% -> target 80%
TypeScript any count:    47 -> target 0
Outdated dependencies:   12 -> target 0
```

## Recommended Paydown Plan

### Sprint 1: Security & Stability
- TD-001: Upgrade Express (1 point)
- TD-002: Add error middleware (2 points)
- TD-003: Parameterized queries (5 points)
- TD-009: Setup ESLint + Prettier (2 points)

### Sprint 2-3: Testing & Types
- TD-006: Enable strict TypeScript, fix `any` types (8 points)
- TD-005: Add tests for critical paths first (13 points)

### Sprint 4+: Architecture
- TD-004: Extract services from god classes (8 points)
- TD-008: Resolve circular dependencies (5 points)

## Key Decisions

- **Security first**: SQL injection and CVEs before any feature work
- **20% rule**: Allocate 20% of each sprint to debt paydown
- **Metrics tracking**: Re-run audit monthly, track trend in coverage and `any` count
- **Boy Scout rule**: Improve any file you touch, even outside debt sprints
