---
sidebar_position: 13
title: "12 - Go API"
description: "Develop a Go REST API with Chi, table-driven TDD and OpenAPI documentation"
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Go API with Chi

<DifficultyBadge level="intermediate" /> **Estimated duration: 45 minutes**

This tutorial shows you how to develop a REST API in Go by following the **Explore → Specify → Plan → TDD → Audit → Commit** workflow of the foundation.

## Objectives

By the end of this tutorial, you will know how to:
- Use `/dev:dev-api` to create Go handlers
- Use `/dev:dev-tdd` for the Red-Green-Refactor cycle with testify
- Write idiomatic table-driven tests in Go
- Use `/qa:qa-security` for the security audit

## Prerequisites

- Claude Code installed and foundation configured
- Go 1.22+ installed (`go version` to check)
- Basic knowledge of Go (structs, interfaces, error handling)

## Context

We are going to create a **tasks (todos)** management API with:
- Full CRUD (Create, Read, Update, Delete)
- Chi router
- Table-driven tests with testify
- Input validation
- `cmd/internal/` architecture

---

## Phase 1: Project setup

### Initialize the Go module

```bash
mkdir todo-api && cd todo-api
go mod init github.com/your-org/todo-api
```

### Install the dependencies

```bash
go get github.com/go-chi/chi/v5
go get github.com/google/uuid
go get github.com/stretchr/testify
```

### Create the structure

```
todo-api/
├── cmd/
│   └── app/
│       └── main.go
├── internal/
│   ├── api/
│   │   ├── handler/
│   │   └── router.go
│   ├── domain/
│   └── repository/
├── Makefile
├── .golangci.yml
└── CLAUDE.md
```

### Minimal Makefile

```makefile
.PHONY: run test lint vet

run:
	go run ./cmd/app/...

test:
	go test ./... -v -race

lint:
	golangci-lint run ./...

vet:
	go vet ./...
```

### `.golangci.yml` file

```yaml
linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gofmt
    - goimports

linters-settings:
  goimports:
    local-prefixes: github.com/your-org/todo-api
```

### Configure CLAUDE.md for Go

```bash
/work:work-explore "Read the project structure and configure CLAUDE.md"
```

Claude will detect Go, Chi and testify, then configure the conventions in `CLAUDE.md`:
- Error handling style (`if err != nil`)
- Table-driven test pattern
- Go naming conventions

---

## Phase 2: Exploration and planning

### Explore the structure

```bash
/work:work-explore "Analyze the Go project structure and the patterns in place"
```

Claude will identify:
- The Go version and the dependencies in `go.mod`
- The `cmd/internal/` architecture in place
- The repository interfaces to define
- The existing test conventions

### Plan the API

```bash
/work:work-plan "Tasks CRUD API with Go and Chi"
```

**Expected plan:**

```
## Plan: Todos API in Go

### Endpoints
- GET    /api/todos      - List of tasks
- GET    /api/todos/{id} - Detail of a task
- POST   /api/todos      - Create a task
- PUT    /api/todos/{id} - Update a task
- DELETE /api/todos/{id} - Delete a task

### Files to create
1. internal/domain/todo.go          - Entity + repository interface
2. internal/repository/memory.go    - In-memory implementation
3. internal/api/handler/todo.go     - HTTP handlers
4. internal/api/router.go           - Chi configuration
5. cmd/app/main.go                  - Entry point

### Test files
1. internal/domain/todo_test.go
2. internal/repository/memory_test.go
3. internal/api/handler/todo_test.go

### Risks
- ID management: use uuid to avoid collisions
- Concurrency: protect the in-memory repository with sync.RWMutex
```

Validate this plan before moving on to TDD.

---

## Phase 3: TDD - Domain and repository

### Run the TDD cycle on the domain

```bash
/dev:dev-tdd "domain entities and repository interface for tasks"
```

Claude will follow the **Red → Green → Refactor** cycle.

**1. Red - Failing table-driven tests**

```go
// internal/domain/todo_test.go
package domain_test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/your-org/todo-api/internal/domain"
)

func TestNewTodo(t *testing.T) {
    tests := []struct {
        name    string
        title   string
        wantErr bool
    }{
        {"valid title", "Learn Go TDD", false},
        {"empty title", "", true},
        {"title too long", string(make([]byte, 201)), true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            todo, err := domain.NewTodo(tt.title)
            if tt.wantErr {
                assert.Error(t, err)
                assert.Nil(t, todo)
            } else {
                assert.NoError(t, err)
                assert.NotEmpty(t, todo.ID)
                assert.Equal(t, tt.title, todo.Title)
                assert.False(t, todo.Completed)
            }
        })
    }
}
```

**2. Green - Minimal implementation**

Claude implements `internal/domain/todo.go` with the `Todo` struct, the `NewTodo` constructor and the `Repository` interface to make the tests pass.

**3. Refactor**

After the tests pass, Claude proposes:
- Add the `Complete()` method on the entity
- Verify that the `Repository` interface covers all use cases

### Continue with the repository

```bash
/dev:dev-tdd "in-memory repository implementation with sync.RWMutex"
```

Claude first writes the repository tests (`FindAll`, `FindByID`, `Save`, `Delete`), then implements `internal/repository/memory.go` with concurrency protection.

### Atomic commit

```bash
/work:work-commit
```

**Suggested message:**

```
feat(domain): add Todo entity and in-memory repository

- Add Todo struct with validation (title 1-200 chars)
- Add Repository interface
- Add thread-safe in-memory implementation
- Add table-driven tests with testify
```

---

## Phase 4: TDD - HTTP handlers

### Run TDD on the handlers

```bash
/dev:dev-tdd "CRUD HTTP handlers with chi and httptest"
```

**1. Red - Tests with `net/http/httptest`**

```go
// internal/api/handler/todo_test.go
package handler_test

import (
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "strings"
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
    "github.com/your-org/todo-api/internal/api/handler"
    "github.com/your-org/todo-api/internal/domain"
    "github.com/your-org/todo-api/internal/repository"
)

func setupHandler(t *testing.T) *handler.TodoHandler {
    t.Helper()
    repo := repository.NewMemoryRepository()
    return handler.NewTodoHandler(repo)
}

func TestCreateTodo(t *testing.T) {
    tests := []struct {
        name       string
        body       string
        wantStatus int
    }{
        {
            name:       "valid creation",
            body:       `{"title":"Learn Chi"}`,
            wantStatus: http.StatusCreated,
        },
        {
            name:       "missing title",
            body:       `{}`,
            wantStatus: http.StatusBadRequest,
        },
        {
            name:       "invalid json",
            body:       `{invalid}`,
            wantStatus: http.StatusBadRequest,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            h := setupHandler(t)
            req := httptest.NewRequest(http.MethodPost, "/api/todos",
                strings.NewReader(tt.body))
            req.Header.Set("Content-Type", "application/json")
            w := httptest.NewRecorder()

            h.Create(w, req)

            assert.Equal(t, tt.wantStatus, w.Code)
        })
    }
}
```

**2. Green - Handler implementation**

Claude implements `internal/api/handler/todo.go` with the `Create` method that decodes the JSON, calls the domain and responds with the correct status.

**3. Red - 404 error test**

```go
func TestGetTodoNotFound(t *testing.T) {
    h := setupHandler(t)
    req := httptest.NewRequest(http.MethodGet, "/api/todos/nonexistent", nil)
    // Chi injects URL params via the context
    req = withURLParam(req, "id", "nonexistent")
    w := httptest.NewRecorder()

    h.GetByID(w, req)

    assert.Equal(t, http.StatusNotFound, w.Code)

    var body map[string]string
    require.NoError(t, json.NewDecoder(w.Body).Decode(&body))
    assert.Contains(t, body["error"], "not found")
}
```

**4. Green - 404 handling**

Claude adds handling for the `domain.ErrNotFound` case in the `GetByID` handler.

**5. Refactor**

After all the tests pass, Claude proposes:
- Extract a `respondJSON` helper to centralize response writing
- Extract a `respondError` helper for errors

### Create the other handlers

```bash
/dev:dev-api "GET /api/todos - List all tasks"
```

```bash
/dev:dev-api "PUT /api/todos/{id} - Update a task"
```

```bash
/dev:dev-api "DELETE /api/todos/{id} - Delete a task"
```

### Configure the Chi router

```bash
/dev:dev-api "Chi router with logging and recover middleware"
```

Claude creates `internal/api/router.go` with the routes mounted on Chi, the `chi.Logger` and `chi.Recoverer` middleware.

### Atomic commit

```bash
/work:work-commit
```

**Suggested message:**

```
feat(api): add CRUD handlers with Chi router

- Add TodoHandler with Create, GetByID, List, Update, Delete
- Add Chi router with Logger and Recoverer middleware
- Add httptest-based table-driven tests
- Handle 404 and 400 error cases
```

---

## Phase 5: Quality

### Static checking

```bash
make vet
```

Expected result:

```
# No output = no problem
```

```bash
make lint
```

Claude fixes the warnings reported by golangci-lint (unused imports, unchecked errors, etc.).

### Security audit

```bash
/qa:qa-security
```

**Typical abridged output:**

```
## Security Audit - Go API

### P0 - Critical
  (none)

### P1 - Important
- [VALIDATION] Add a size limit on the request body
  → Add http.MaxBytesReader in the handler or as middleware

### P2 - Medium
- [HEADERS] Add security headers (X-Content-Type-Options, etc.)
  → Add a security middleware after chi.Logger

### Recommendations
- Configure a timeout on the HTTP server (ReadTimeout, WriteTimeout)
- Add a rate limiter for public endpoints

Score: 82/100
```

Claude applies the P0 and P1 fixes:
- Add `http.MaxBytesReader` to limit the body size
- Add a security headers middleware
- Configure timeouts on `http.Server`

### Re-run the tests

```bash
make test
```

Check that all tests pass after the fixes.

---

## Phase 6: Commit and PR

### Commit the quality fixes

```bash
/work:work-commit
```

**Suggested message:**

```
fix(security): add request body limit and security headers

- Limit request body to 1MB with MaxBytesReader
- Add security headers middleware (X-Content-Type-Options, etc.)
- Configure ReadTimeout and WriteTimeout on http.Server
```

### Create the PR

```bash
/work:work-pr
```

Claude generates a PR with:
- Description of the implemented endpoints
- Test results (`make test`)
- Items fixed by the security audit

---

## Recap

You have developed a complete Go REST API by following the foundation's workflow:

```
todo-api/
├── cmd/app/main.go                      # Entry point and wiring
├── internal/
│   ├── domain/
│   │   ├── todo.go                      # Entity + Repository interface
│   │   └── todo_test.go                 # Domain table-driven tests
│   ├── repository/
│   │   ├── memory.go                    # Thread-safe implementation
│   │   └── memory_test.go
│   └── api/
│       ├── router.go                    # Chi router + middleware
│       └── handler/
│           ├── todo.go                  # HTTP handlers
│           └── todo_test.go             # httptest table-driven tests
├── Makefile
└── .golangci.yml
```

| Command | What it does |
|----------|-----------------|
| `/work:work-explore` | Analyzes the project and configures CLAUDE.md |
| `/work:work-plan` | Plans the architecture before coding |
| `/dev:dev-tdd` | Red-Green-Refactor cycle with testify |
| `/dev:dev-api` | Creates an endpoint with handler and tests |
| `/qa:qa-security` | Security audit and fixes |
| `/work:work-commit` | Atomic conventional commit |
| `/work:work-pr` | Creates the PR with full description |

### Key Go points learned

| Concept | Application in this tutorial |
|---------|------------------------------|
| Table-driven tests | Coverage of all cases in a single `for _, tt := range tests` loop |
| `net/http/httptest` | Handler tests without starting a real server |
| `sync.RWMutex` | In-memory repository protection for concurrency |
| Go interfaces | `Repository` defined in the domain, implemented in the repository package |
| Error handling | Typed errors (`domain.ErrNotFound`) to distinguish HTTP cases |

---

## Going further

- [Go Guide](/docs/concepts/stack-recipes) - Advanced patterns, error handling, concurrency
- [Auth Guide](/docs/concepts/stack-recipes) - Add JWT to your Go API
- [Database Guide](/docs/concepts/stack-recipes) - Replace the in-memory repository with PostgreSQL via pgx
- [Tutorial 10: Complete TaskFlow project](/docs/tutorials/complete-project) - Integrate this backend into a full-stack project

---

:::tip Table-driven tests in Go
Table-driven tests are the idiomatic Go pattern to cover multiple cases without duplicating code. Use `/dev:dev-tdd`: Claude automatically generates this pattern and extends it to each new use case.
:::

:::info cmd/internal/ architecture
The `internal/` folder ensures that your business code is not imported by external projects. It is a strong Go convention that the foundation respects in all generated Go projects.
:::
