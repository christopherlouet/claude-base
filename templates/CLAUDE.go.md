# Projet Go

## Commandes Essentielles
- `go mod download` - Télécharger les dépendances
- `go build ./...` - Compiler le projet
- `go test ./...` - Lancer les tests
- `go test -cover ./...` - Tests avec couverture
- `go test -race ./...` - Tests avec détection de race conditions
- `go run main.go` - Lancer l'application
- `go fmt ./...` - Formatter le code
- `go vet ./...` - Analyse statique
- `golangci-lint run` - Linter complet

## Structure du Projet
```
/
├── cmd/                    # Points d'entrée (main packages)
│   └── app/
│       └── main.go
├── internal/               # Code privé au module
│   ├── handlers/          # HTTP handlers
│   ├── services/          # Business logic
│   ├── repository/        # Data access
│   └── models/            # Domain models
├── pkg/                    # Code public réutilisable
├── api/                    # Specs OpenAPI, protobuf
├── configs/                # Configuration files
├── scripts/                # Scripts utilitaires
├── go.mod
└── go.sum
```

## Conventions Go

### Nommage
- IMPORTANT: Packages en minuscules, un mot (`user`, pas `userService`)
- IMPORTANT: Interfaces avec suffixe `-er` (`Reader`, `Writer`, `Handler`)
- Exporter avec majuscule, garder privé avec minuscule
- Acronymes en majuscules (`HTTPHandler`, pas `HttpHandler`)

### Structures
```go
// Bon: Interface petite et focalisée
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Bon: Struct avec tags appropriés
type User struct {
    ID        int64     `json:"id" db:"id"`
    Email     string    `json:"email" db:"email"`
    CreatedAt time.Time `json:"created_at" db:"created_at"`
}
```

### Gestion des erreurs
- IMPORTANT: Toujours vérifier les erreurs
- IMPORTANT: Wrapper les erreurs avec contexte (`fmt.Errorf("doing X: %w", err)`)
- Utiliser `errors.Is()` et `errors.As()` pour comparer

```go
// Bon
if err != nil {
    return fmt.Errorf("failed to fetch user %d: %w", id, err)
}

// Mauvais
if err != nil {
    return err  // Pas de contexte
}
```

### Concurrence
- IMPORTANT: Pas de goroutine sans contrôle de lifecycle
- Utiliser `context.Context` pour cancellation
- Préférer les channels aux mutex quand possible
- `sync.WaitGroup` pour attendre plusieurs goroutines

```go
// Bon pattern
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
- Utiliser interfaces pour injection de dépendances
- `go generate` avec mockgen si nécessaire
- Préférer les fakes aux mocks quand possible

## Performance
- Pré-allouer les slices quand la taille est connue
- Utiliser `sync.Pool` pour objets fréquemment alloués
- `strings.Builder` pour concaténation de strings
- Profiler avant d'optimiser (`pprof`)

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore

## Hooks Claude Code 2.1+

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Bloque les modifications sur main/master |
| Auto-format | PostToolUse | `go fmt` sur fichiers Go modifiés |
| Vet check | PostToolUse | `go vet` après édition |
| Test avant commit | PreToolUse | Exécute `go test` avant chaque commit |
| Détection secrets | PreToolUse | Bloque les secrets hardcodés |

## Skills disponibles

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyser un codebase existant |
| `planning-implementation` | Définir un plan avant de coder |
| `test-driven-development` | Cycle TDD Red-Green-Refactor |
| `reviewing-code` | Revue de code approfondie |
| `debugging-issues` | Diagnostic méthodique |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | PR complète et documentée |
