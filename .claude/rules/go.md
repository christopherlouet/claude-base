---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---

# Go Rules

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Packages | lowercase, short | `user`, `http` |
| Exported | PascalCase | `GetUser`, `UserService` |
| Unexported | camelCase | `getUserByID`, `internalHelper` |
| Constants | PascalCase or camelCase | `MaxRetryCount`, `defaultTimeout` |
| Interfaces | -er suffix when possible | `Reader`, `Writer`, `UserFetcher` |
| Acronyms | All uppercase | `HTTPClient`, `UserID`, `APIError` |

## Error Handling

- IMPORTANT: Always check returned errors
- YOU MUST return errors, do not ignore them
- Use `errors.Is()` and `errors.As()` for comparison
- Wrap errors with context: `fmt.Errorf("action: %w", err)`

```go
// Correct pattern
result, err := doSomething()
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}

// Custom errors
var ErrUserNotFound = errors.New("user not found")

func GetUser(id int) (*User, error) {
    user, err := db.Find(id)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrUserNotFound
        }
        return nil, fmt.Errorf("get user %d: %w", id, err)
    }
    return user, nil
}
```

## Interfaces

- Define interfaces on the consumer side, not the implementer side
- Keep interfaces small (1-3 methods)
- Prefer interface composition

```go
// Small and composed
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type ReadWriter interface {
    Reader
    Writer
}

// Consumer side
type UserRepository interface {
    GetByID(ctx context.Context, id int) (*User, error)
}

func NewUserService(repo UserRepository) *UserService {
    return &UserService{repo: repo}
}
```

## Concurrency

- IMPORTANT: Use `context.Context` for cancellation and timeouts
- Prefer channels for communication, mutexes for shared state
- Always close channels on the producer side
- Use `sync.WaitGroup` to wait for goroutines

```go
func processItems(ctx context.Context, items []Item) error {
    g, ctx := errgroup.WithContext(ctx)

    for _, item := range items {
        item := item // capture loop variable
        g.Go(func() error {
            return processItem(ctx, item)
        })
    }

    return g.Wait()
}
```

## Project Structure

```
project/
├── cmd/
│   └── app/
│       └── main.go
├── internal/
│   ├── domain/
│   ├── service/
│   └── repository/
├── pkg/              # External reusable code
├── api/              # OpenAPI specs, protos
├── go.mod
└── go.sum
```

## Best Practices

- Use `context.Context` as the first argument
- Prefer returning errors over panics
- Use `defer` for cleanup (files, locks, etc.)
- Avoid `init()` unless truly necessary
- Use zero values intelligently

## Testing

```go
func TestGetUser(t *testing.T) {
    tests := []struct {
        name    string
        userID  int
        want    *User
        wantErr error
    }{
        {
            name:   "existing user",
            userID: 1,
            want:   &User{ID: 1, Name: "John"},
        },
        {
            name:    "non-existing user",
            userID:  999,
            wantErr: ErrUserNotFound,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := GetUser(tt.userID)
            if !errors.Is(err, tt.wantErr) {
                t.Errorf("GetUser() error = %v, wantErr %v", err, tt.wantErr)
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("GetUser() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

## Anti-patterns

- NEVER ignore errors with `_`
- NEVER use `panic` for normal flow control
- Avoid goroutines with no way to be cancelled
- Avoid mutable global variables
- Do not use `interface{}` / `any` without a valid reason
