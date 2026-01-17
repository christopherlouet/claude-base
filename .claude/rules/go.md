---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---

# Go Rules

## Naming Conventions

| Type | Convention | Exemple |
|------|------------|---------|
| Packages | lowercase, court | `user`, `http` |
| Exported | PascalCase | `GetUser`, `UserService` |
| Unexported | camelCase | `getUserByID`, `internalHelper` |
| Constantes | PascalCase ou camelCase | `MaxRetryCount`, `defaultTimeout` |
| Interfaces | -er suffix si possible | `Reader`, `Writer`, `UserFetcher` |
| Acronymes | Tout en majuscules | `HTTPClient`, `UserID`, `APIError` |

## Error Handling

- IMPORTANT: Toujours verifier les erreurs retournees
- YOU MUST retourner les erreurs, ne pas les ignorer
- Utiliser `errors.Is()` et `errors.As()` pour comparaison
- Wrapper les erreurs avec contexte: `fmt.Errorf("action: %w", err)`

```go
// Pattern correct
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

- Definir les interfaces cote consommateur, pas implementeur
- Garder les interfaces petites (1-3 methodes)
- Preferer composition d'interfaces

```go
// Petit et compose
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

// Cote consommateur
type UserRepository interface {
    GetByID(ctx context.Context, id int) (*User, error)
}

func NewUserService(repo UserRepository) *UserService {
    return &UserService{repo: repo}
}
```

## Concurrency

- IMPORTANT: Utiliser `context.Context` pour cancellation et timeouts
- Preferer channels pour communication, mutex pour etat partage
- Toujours fermer les channels cote producteur
- Utiliser `sync.WaitGroup` pour attendre les goroutines

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
├── pkg/              # Code reutilisable externe
├── api/              # OpenAPI specs, protos
├── go.mod
└── go.sum
```

## Best Practices

- Utiliser `context.Context` comme premier argument
- Preferer retourner des erreurs aux panics
- Utiliser `defer` pour cleanup (fichiers, locks, etc.)
- Eviter `init()` sauf si vraiment necessaire
- Utiliser les zero values intelligemment

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

- NEVER ignorer les erreurs avec `_`
- NEVER utiliser `panic` pour le flow control normal
- Eviter les goroutines sans possibilite de cancellation
- Eviter les variables globales mutables
- Ne pas utiliser `interface{}` / `any` sans raison valable
