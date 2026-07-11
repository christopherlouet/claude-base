# Go Project

## Essential Commands
- `go mod download` - Download dependencies
- `go build ./...` - Compile the project
- `go test ./...` - Run tests
- `go test -cover ./...` - Tests with coverage
- `go test -race ./...` - Tests with race condition detection
- `go run main.go` - Run the application
- `go fmt ./...` - Format the code
- `go vet ./...` - Static analysis
- `golangci-lint run` - Full linter

## Project Structure
```
/
├── cmd/                    # Entry points (main packages)
│   └── app/
│       └── main.go
├── internal/               # Module-private code
│   ├── handlers/          # HTTP handlers
│   ├── services/          # Business logic
│   ├── repository/        # Data access
│   └── models/            # Domain models
├── pkg/                    # Public reusable code
├── api/                    # OpenAPI, protobuf specs
├── configs/                # Configuration files
├── scripts/                # Utility scripts
├── go.mod
└── go.sum
```

## Go Conventions

### Naming
- IMPORTANT: Packages in lowercase, one word (`user`, not `userService`)
- IMPORTANT: Interfaces with `-er` suffix (`Reader`, `Writer`, `Handler`)
- Export with uppercase, keep private with lowercase
- Acronyms in uppercase (`HTTPHandler`, not `HttpHandler`)

### Structures
```go
// Good: Small and focused interface
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Good: Struct with appropriate tags
type User struct {
    ID        int64     `json:"id" db:"id"`
    Email     string    `json:"email" db:"email"`
    CreatedAt time.Time `json:"created_at" db:"created_at"`
}
```

### Error handling
- IMPORTANT: Always check errors
- IMPORTANT: Wrap errors with context (`fmt.Errorf("doing X: %w", err)`)
- Use `errors.Is()` and `errors.As()` to compare

```go
// Good
if err != nil {
    return fmt.Errorf("failed to fetch user %d: %w", id, err)
}

// Bad
if err != nil {
    return err  // No context
}
```

### Concurrency
- IMPORTANT: No goroutine without lifecycle control
- Use `context.Context` for cancellation
- Prefer channels over mutexes when possible
- `sync.WaitGroup` to wait for multiple goroutines

```go
// Good pattern
func process(ctx context.Context) error {
    g, ctx := errgroup.WithContext(ctx)

    g.Go(func() error {
        return doTask1(ctx)
    })

    g.Go(func() error {
        return doTask2(ctx)
    })

    return g.Wait()
}
```

## Tests

### Structure
```go
func TestUserService_Create(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserInput
        want    *User
        wantErr bool
    }{
        {
            name:  "valid user",
            input: CreateUserInput{Email: "test@example.com"},
            want:  &User{Email: "test@example.com"},
        },
        {
            name:    "invalid email",
            input:   CreateUserInput{Email: "invalid"},
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := svc.Create(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("Create() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("Create() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

### Mocks
- Use interfaces for dependency injection
- `go generate` with mockgen if needed
- Prefer fakes over mocks when possible

## Performance
- Pre-allocate slices when size is known
- Use `sync.Pool` for frequently allocated objects
- `strings.Builder` for string concatenation
- Profile before optimizing (`pprof`)

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore

## Claude Code 2.1+ Hooks

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Blocks modifications on main/master |
| Auto-format | PostToolUse | `go fmt` on modified Go files |
| Vet check | PostToolUse | `go vet` after edit |
| Test before commit | PreToolUse | Runs `go test` before each commit |
| Secret detection | PreToolUse | Blocks hardcoded secrets |

## Available Skills

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyze an existing codebase |
| `planning-implementation` | Define a plan before coding |
| `test-driven-development` | TDD Red-Green-Refactor cycle |
| `qa-review` | Thorough code review |
| `debugging-issues` | Methodical diagnosis |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | Complete and documented PR |
