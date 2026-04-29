# Guide Developpement Go

> Workflow complet pour les backends Go avec Claude Code et le socle

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Langage | Go 1.22+ |
| HTTP | net/http standard, Chi, Gin, Echo |
| ORM / SQL | GORM, sqlx, pgx |
| Injection de dependances | Wire |
| Tests | testify, httptest, testcontainers-go |
| Qualite | golangci-lint, go vet, staticcheck |
| Hot reload | Air |
| RPC | protobuf, gRPC, grpc-gateway |

## Architecture Recommandee

```
cmd/
└── app/
    └── main.go           # Point d'entree, wiring, demarrage serveur
internal/
├── api/                  # Handlers HTTP, middleware, routing
│   ├── handler/
│   ├── middleware/
│   └── router.go
├── domain/               # Entites metier, interfaces repository
├── service/              # Logique metier
├── repository/           # Acces donnees (implementations)
└── config/               # Lecture configuration, structs
pkg/                      # Code reutilisable par d'autres projets
go.mod
go.sum
Makefile
.air.toml
.golangci.yml
```

## Workflow Recommande

```
/work:work-explore → /work:work-plan → /dev:dev-tdd → /qa:qa-loop "score 90" → /work:work-pr
```

## Phase 1: Exploration

### Comprendre le projet existant

```bash
/work:work-explore
```

### Points a verifier

- Version Go dans `go.mod` et compatibilite des dependances
- Framework HTTP utilise (net/http, Chi, Gin, Echo)
- Strategie de gestion des erreurs en place
- Patterns de tests existants (table-driven, helpers)
- Configuration (env vars, fichier YAML/TOML, Viper)
- Presence d'un Makefile et de ses cibles

## Phase 2: Setup

### Initialiser un nouveau projet

```bash
mkdir myservice && cd myservice
go mod init github.com/org/myservice
```

### Fichier `.golangci.yml` minimal

```yaml
linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - staticcheck
    - unused
    - gofmt
    - revive
    - exhaustive

linters-settings:
  revive:
    rules:
      - name: exported
```

### Fichier `.air.toml` (hot reload)

```toml
root = "."
tmp_dir = "tmp"

[build]
  cmd = "go build -o ./tmp/main ./cmd/app"
  bin = "./tmp/main"
  include_ext = ["go"]
  exclude_dir = ["tmp", "vendor"]
  delay = 200
```

### Makefile type

```makefile
.PHONY: run build test lint vet

run:
	air

build:
	go build -o bin/app ./cmd/app

test:
	go test ./... -race -count=1

test-cover:
	go test ./... -race -coverprofile=coverage.out
	go tool cover -html=coverage.out

lint:
	golangci-lint run ./...

vet:
	go vet ./...

generate:
	go generate ./...
```

## Phase 3: Developpement API

### Creer des handlers avec Chi

```bash
/dev:dev-api "endpoints CRUD pour la ressource produits"
```

### Exemple: router Chi avec middleware

```go
// internal/api/router.go
package api

import (
    "net/http"

    "github.com/go-chi/chi/v5"
    "github.com/go-chi/chi/v5/middleware"
)

func NewRouter(productHandler *handler.ProductHandler) http.Handler {
    r := chi.NewRouter()

    // Middleware globaux
    r.Use(middleware.RequestID)
    r.Use(middleware.RealIP)
    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)
    r.Use(middleware.Timeout(30 * time.Second))

    r.Route("/api/v1", func(r chi.Router) {
        r.Use(AuthMiddleware)

        r.Route("/products", func(r chi.Router) {
            r.Get("/", productHandler.List)
            r.Post("/", productHandler.Create)
            r.Route("/{id}", func(r chi.Router) {
                r.Get("/", productHandler.Get)
                r.Patch("/", productHandler.Update)
                r.Delete("/", productHandler.Delete)
            })
        })
    })

    return r
}
```

### Exemple: interface repository et implementation

```go
// internal/domain/product.go
package domain

import "context"

type Product struct {
    ID    int64
    Name  string
    Price float64
}

// Interface definie cote consommateur (service)
type ProductRepository interface {
    GetByID(ctx context.Context, id int64) (*Product, error)
    List(ctx context.Context, page, limit int) ([]*Product, int64, error)
    Create(ctx context.Context, p *Product) error
    Update(ctx context.Context, p *Product) error
    Delete(ctx context.Context, id int64) error
}

// Erreurs sentinelles
var (
    ErrProductNotFound = errors.New("product not found")
    ErrInvalidProduct  = errors.New("invalid product")
)

// internal/repository/product_pg.go
type productRepository struct {
    db *sqlx.DB
}

func NewProductRepository(db *sqlx.DB) domain.ProductRepository {
    return &productRepository{db: db}
}

func (r *productRepository) GetByID(ctx context.Context, id int64) (*domain.Product, error) {
    var p domain.Product
    err := r.db.GetContext(ctx, &p, "SELECT id, name, price FROM products WHERE id = $1", id)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, domain.ErrProductNotFound
        }
        return nil, fmt.Errorf("get product %d: %w", id, err)
    }
    return &p, nil
}
```

### Gestion des erreurs HTTP

| Situation | Pattern | Code HTTP |
|-----------|---------|-----------|
| Erreur sentinelle metier | `errors.Is(err, domain.ErrXxx)` | 404, 409 |
| Erreur de validation input | Type custom `ValidationError` | 400 |
| Erreur interne inattendue | Wrapper avec `%w`, log + 500 | 500 |
| Timeout contexte | `errors.Is(err, context.DeadlineExceeded)` | 503 |

```go
// internal/api/handler/errors.go
func writeError(w http.ResponseWriter, err error) {
    var status int
    var code string

    switch {
    case errors.Is(err, domain.ErrProductNotFound):
        status, code = http.StatusNotFound, "NOT_FOUND"
    case errors.Is(err, domain.ErrInvalidProduct):
        status, code = http.StatusBadRequest, "INVALID_INPUT"
    case errors.Is(err, context.DeadlineExceeded):
        status, code = http.StatusServiceUnavailable, "TIMEOUT"
    default:
        slog.Error("unexpected error", "err", err)
        status, code = http.StatusInternalServerError, "INTERNAL_ERROR"
    }

    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(map[string]any{
        "error": map[string]string{"code": code, "message": err.Error()},
    })
}
```

## Phase 4: TDD

### Demarrer le cycle TDD

```bash
/dev:dev-tdd "service de calcul de prix avec remises et taxes"
```

### Tests table-driven (pattern Go idiomatique)

```go
// internal/service/product_test.go
func TestProductService_Create(t *testing.T) {
    tests := []struct {
        name    string
        input   domain.Product
        wantErr error
    }{
        {
            name:  "produit valide",
            input: domain.Product{Name: "Widget", Price: 9.99},
        },
        {
            name:    "nom vide",
            input:   domain.Product{Name: "", Price: 9.99},
            wantErr: domain.ErrInvalidProduct,
        },
        {
            name:    "prix negatif",
            input:   domain.Product{Name: "Widget", Price: -1},
            wantErr: domain.ErrInvalidProduct,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            repo := &fakeProductRepository{}
            svc := service.NewProductService(repo)

            err := svc.Create(context.Background(), &tt.input)

            assert.ErrorIs(t, err, tt.wantErr)
        })
    }
}
```

### Tests de handlers avec httptest

```go
// internal/api/handler/product_test.go
func TestProductHandler_Get(t *testing.T) {
    product := &domain.Product{ID: 1, Name: "Widget", Price: 9.99}

    repo := &fakeProductRepository{product: product}
    svc := service.NewProductService(repo)
    h := handler.NewProductHandler(svc)

    r := chi.NewRouter()
    r.Get("/products/{id}", h.Get)

    req := httptest.NewRequest(http.MethodGet, "/products/1", nil)
    rec := httptest.NewRecorder()

    r.ServeHTTP(rec, req)

    assert.Equal(t, http.StatusOK, rec.Code)

    var got domain.Product
    require.NoError(t, json.NewDecoder(rec.Body).Decode(&got))
    assert.Equal(t, product.Name, got.Name)
}

func TestProductHandler_Get_NotFound(t *testing.T) {
    repo := &fakeProductRepository{err: domain.ErrProductNotFound}
    svc := service.NewProductService(repo)
    h := handler.NewProductHandler(svc)

    r := chi.NewRouter()
    r.Get("/products/{id}", h.Get)

    req := httptest.NewRequest(http.MethodGet, "/products/999", nil)
    rec := httptest.NewRecorder()

    r.ServeHTTP(rec, req)

    assert.Equal(t, http.StatusNotFound, rec.Code)
}
```

### Tests d'integration avec testcontainers

```go
// internal/repository/product_pg_integration_test.go
//go:build integration

func TestProductRepository_Integration(t *testing.T) {
    ctx := context.Background()

    pgContainer, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
        ContainerRequest: testcontainers.ContainerRequest{
            Image:        "postgres:16-alpine",
            ExposedPorts: []string{"5432/tcp"},
            Env: map[string]string{
                "POSTGRES_PASSWORD": "test",
                "POSTGRES_DB":       "testdb",
            },
            WaitingFor: wait.ForListeningPort("5432/tcp"),
        },
        Started: true,
    })
    require.NoError(t, err)
    t.Cleanup(func() { pgContainer.Terminate(ctx) })

    dsn, _ := pgContainer.ConnectionString(ctx, "sslmode=disable")
    db, err := sqlx.Connect("postgres", dsn)
    require.NoError(t, err)

    repo := repository.NewProductRepository(db)
    // ... tests avec vraie base de donnees
}
```

### Cibles de couverture

| Couche | Cible | Methode |
|--------|-------|---------|
| Service (logique metier) | 90%+ | Tests unitaires, fakes |
| Handler HTTP | 80%+ | httptest |
| Repository | 70%+ | testcontainers (integration) |
| Domain / entites | 100% | Unitaires |

## Phase 5: Concurrence

### Patterns selon le contexte

| Situation | Pattern recommande | Raison |
|-----------|--------------------|--------|
| Taches independantes en parallele | `errgroup.Group` | Propagation d'erreur, annulation |
| Pipeline de traitement | Channels | Communication entre etapes |
| Acces concurrent a une map | `sync.RWMutex` ou `sync.Map` | Etat partage en lecture |
| Cache en memoire | `sync.Map` ou mutex + map | Lecture frequente, ecriture rare |
| Fan-out / fan-in | Goroutines + channel de resultats | Agregation de resultats |
| Worker pool | Channel de jobs + WaitGroup | Limiter la concurrence |

### Exemple: fan-out avec errgroup et context

```go
import "golang.org/x/sync/errgroup"

func fetchAll(ctx context.Context, ids []int64) ([]*Product, error) {
    g, ctx := errgroup.WithContext(ctx)
    results := make([]*Product, len(ids))

    for i, id := range ids {
        i, id := i, id // capture des variables de boucle
        g.Go(func() error {
            p, err := fetchProduct(ctx, id)
            if err != nil {
                return fmt.Errorf("fetch product %d: %w", id, err)
            }
            results[i] = p
            return nil
        })
    }

    if err := g.Wait(); err != nil {
        return nil, err
    }
    return results, nil
}
```

### Regles de base

- Toujours passer `context.Context` comme premier argument pour permettre l'annulation
- Ne jamais demarrer une goroutine sans moyen de l'arreter
- Capturer les variables de boucle avant de les utiliser dans une goroutine
- Utiliser `-race` lors des tests pour detecter les data races

## Phase 6: Qualite

### Lancer l'audit qualite

```bash
/qa:qa-loop "score 90"
```

### Commandes de verification

```bash
# Compilation et vet
go build ./...
go vet ./...

# Lint complet
golangci-lint run ./...

# Tests avec race detector
go test ./... -race -count=1

# Couverture
go test ./... -coverprofile=coverage.out
go tool cover -func=coverage.out | grep total

# Staticcheck
staticcheck ./...
```

### Checklist qualite Go

- [ ] Toutes les erreurs sont verifiees (pas de `_` sur des erreurs)
- [ ] Les goroutines ont un mecanisme d'annulation (context)
- [ ] Les ressources sont liberees avec `defer` (fichiers, connexions, locks)
- [ ] Les interfaces sont petites et definies cote consommateur
- [ ] Pas de variable globale mutable
- [ ] Les logs utilisent `slog` avec des attributs structures
- [ ] La configuration est validee au demarrage

## Phase 7: gRPC et Protobuf

> Le socle n'a pas de commande dédiée gRPC. Utiliser `/work:work-plan` pour cadrer le service puis `/dev:dev-api` (adapté gRPC) ou la génération manuelle ci-dessous.

### Structure type

```proto
// api/proto/user/v1/user.proto
syntax = "proto3";
package user.v1;
option go_package = "github.com/org/myservice/gen/user/v1;userv1";

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
}

message GetUserRequest {
  int64 id = 1;
}

message GetUserResponse {
  User user = 1;
}

message User {
  int64  id    = 1;
  string name  = 2;
  string email = 3;
}
```

### Generation du code

```bash
# Installation des plugins
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Generation
protoc \
  --go_out=gen \
  --go_opt=paths=source_relative \
  --go-grpc_out=gen \
  --go-grpc_opt=paths=source_relative \
  api/proto/user/v1/user.proto
```

### Implementation du serveur gRPC

```go
// internal/api/grpc/user_server.go
type userServer struct {
    userv1.UnimplementedUserServiceServer
    svc domain.UserService
}

func (s *userServer) GetUser(ctx context.Context, req *userv1.GetUserRequest) (*userv1.GetUserResponse, error) {
    user, err := s.svc.GetByID(ctx, req.GetId())
    if err != nil {
        if errors.Is(err, domain.ErrUserNotFound) {
            return nil, status.Errorf(codes.NotFound, "user %d not found", req.GetId())
        }
        return nil, status.Errorf(codes.Internal, "internal error")
    }
    return &userv1.GetUserResponse{
        User: &userv1.User{Id: user.ID, Name: user.Name, Email: user.Email},
    }, nil
}
```

## Phase 8: Deploy

### Docker multi-stage (binaire statique)

```dockerfile
# Build stage
FROM golang:1.22-alpine AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-w -s" \
    -o /bin/app \
    ./cmd/app

# Runtime stage (distroless)
FROM gcr.io/distroless/static-debian12
COPY --from=builder /bin/app /bin/app
EXPOSE 8080
ENTRYPOINT ["/bin/app"]
```

### Points d'attention Docker

| Aspect | Recommandation |
|--------|---------------|
| `CGO_ENABLED` | `0` pour un binaire statique compatible scratch/distroless |
| Image base runtime | `distroless/static` (securite) ou `alpine` (debug) |
| Health check | Implementer `/healthz` et `/readyz` dans le handler |
| Signaux OS | Gerer `SIGTERM` et `SIGINT` pour un arret propre |
| Non-root | Utiliser `USER nonroot` dans l'image distroless |

### Arret propre (graceful shutdown)

```go
// cmd/app/main.go
func main() {
    srv := &http.Server{Addr: ":8080", Handler: router}

    go func() {
        if err := srv.ListenAndServe(); !errors.Is(err, http.ErrServerClosed) {
            slog.Error("server error", "err", err)
            os.Exit(1)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        slog.Error("shutdown error", "err", err)
    }
}
```

## Commandes par Use Case

### Nouveau service Go

```bash
1. /work:work-plan          # Architecture, domaine, interfaces
2. /dev:dev-tdd             # Domaine et services en TDD
3. /dev:dev-api             # Handlers HTTP ou gRPC
4. /qa:qa-loop "score 90"   # Audit qualite + securite
5. /ops:ops-docker          # Dockerfile multi-stage
6. /work:work-pr            # Pull Request
```

### Nouvel endpoint

```bash
1. /work:work-explore       # Comprendre l'existant
2. /dev:dev-tdd             # Test handler + service
3. /dev:dev-api             # Implementation
4. /qa:qa-loop "score 90"   # Verification qualite
5. /work:work-pr            # Pull Request
```

### Refactoring d'un package

```bash
1. /work:work-explore       # Comprendre les dependances
2. /work:work-plan          # Identifier les interfaces a extraire
3. /dev:dev-tdd             # Tests de regression
4. /qa:qa-loop "score 90"   # Aucune regression de qualite
5. /work:work-pr            # Pull Request
```

### Debug d'une regression de performance

```bash
1. /qa:qa-perf              # Identifier les bottlenecks
2. /work:work-plan          # Plan d'optimisation
3. /dev:dev-tdd             # Benchmark avant/apres
4. /work:work-pr            # Pull Request avec mesures
```

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Cree un handler" | dev-api | Handler + routing + test httptest |
| "Ecris les tests" | dev-tdd | Table-driven tests + fakes |
| "Audit qualite" | qa-loop | golangci-lint, vet, race, couverture |
| "Dockerise le service" | ops-docker | Multi-stage, distroless, graceful shutdown |
| "Cree un service gRPC" | work-plan + dev-api | Pas de commande dédiée — cadrer avec `work-plan`, implémenter avec `dev-api` |

## Anti-patterns a Eviter

| Anti-pattern | Consequence | Solution |
|---|---|---|
| Ignorer les erreurs avec `_` | Bugs silencieux en production | Toujours verifier et wrapper avec `%w` |
| Goroutine sans annulation | Goroutine leak, fuite memoire | Toujours passer un `context.Context` |
| Nil pointer sans guard | Panic en production | Verifier les pointeurs, retourner des erreurs |
| Etat global mutable | Race conditions, tests non deterministes | Injection de dependances, zero globals |
| Ne pas utiliser `context` | Timeouts impossibles | Premier argument de toute fonction I/O |
| Interfaces trop larges | Couplage fort, tests difficiles | 1-3 methodes par interface |
| `panic` pour le flux normal | Crash non gere | Retourner des erreurs |
| `init()` avec effets de bord | Ordre d'init impredictible | Initialisation explicite dans `main` |

## Ressources

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [golangci-lint](https://golangci-lint.run)
- [testcontainers-go](https://testcontainers.com/guides/getting-started-with-testcontainers-for-go/)
- [Chi router](https://github.com/go-chi/chi)
- [errgroup](https://pkg.go.dev/golang.org/x/sync/errgroup)
