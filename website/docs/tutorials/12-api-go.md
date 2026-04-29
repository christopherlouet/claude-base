---
sidebar_position: 13
title: "12 - API Go"
description: "Developpez une API REST Go avec Chi, TDD table-driven et documentation OpenAPI"
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# API Go avec Chi

<DifficultyBadge level="intermediate" /> **Duree estimee : 45 minutes**

Ce tutoriel vous montre comment developper une API REST en Go en suivant le workflow **Explore → Plan → TDD → Audit → Commit** du socle.

## Objectifs

A la fin de ce tutoriel, vous saurez :
- Utiliser `/dev:dev-api` pour creer des handlers Go
- Utiliser `/dev:dev-tdd` pour le cycle Red-Green-Refactor avec testify
- Ecrire des tests table-driven idiomatiques en Go
- Utiliser `/qa:qa-security` pour l'audit securite

## Prerequis

- Claude Code installe et socle configure
- Go 1.22+ installe (`go version` pour verifier)
- Connaissances de base en Go (structs, interfaces, error handling)

## Contexte

Nous allons creer une API de gestion de **taches (todos)** avec :
- CRUD complet (Create, Read, Update, Delete)
- Router Chi
- Tests table-driven avec testify
- Validation des entrees
- Architecture `cmd/internal/`

---

## Phase 1 : Setup du projet

### Initialiser le module Go

```bash
mkdir todo-api && cd todo-api
go mod init github.com/votre-org/todo-api
```

### Installer les dependances

```bash
go get github.com/go-chi/chi/v5
go get github.com/google/uuid
go get github.com/stretchr/testify
```

### Creer la structure

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

### Makefile minimal

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

### Fichier `.golangci.yml`

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
    local-prefixes: github.com/votre-org/todo-api
```

### Configurer CLAUDE.md pour Go

```bash
/work:work-explore "Lire la structure du projet et configurer CLAUDE.md"
```

Claude va detecter Go, Chi et testify, puis configurer les conventions dans `CLAUDE.md` :
- Style de gestion des erreurs (`if err != nil`)
- Pattern de tests table-driven
- Conventions de nommage Go

---

## Phase 2 : Exploration et planification

### Explorer la structure

```bash
/work:work-explore "Analyser la structure du projet Go et les patterns en place"
```

Claude va identifier :
- La version Go et les dependances dans `go.mod`
- L'architecture `cmd/internal/` en place
- Les interfaces de repository a definir
- Les conventions de test existantes

### Planifier l'API

```bash
/work:work-plan "API CRUD taches avec Go et Chi"
```

**Plan attendu :**

```
## Plan : API Todos en Go

### Endpoints
- GET    /api/todos      - Liste des taches
- GET    /api/todos/{id} - Detail d'une tache
- POST   /api/todos      - Creer une tache
- PUT    /api/todos/{id} - Modifier une tache
- DELETE /api/todos/{id} - Supprimer une tache

### Fichiers a creer
1. internal/domain/todo.go          - Entite + interface repository
2. internal/repository/memory.go    - Implementation en memoire
3. internal/api/handler/todo.go     - Handlers HTTP
4. internal/api/router.go           - Configuration Chi
5. cmd/app/main.go                  - Point d'entree

### Fichiers de tests
1. internal/domain/todo_test.go
2. internal/repository/memory_test.go
3. internal/api/handler/todo_test.go

### Risques
- Gestion des IDs : utiliser uuid pour eviter les collisions
- Concurrence : proteger le repository en memoire avec sync.RWMutex
```

Validez ce plan avant de passer au TDD.

---

## Phase 3 : TDD - Domaine et repository

### Lancer le cycle TDD sur le domaine

```bash
/dev:dev-tdd "domain entities et repository interface pour les taches"
```

Claude va suivre le cycle **Red → Green → Refactor**.

**1. Red - Tests table-driven qui echouent**

```go
// internal/domain/todo_test.go
package domain_test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/votre-org/todo-api/internal/domain"
)

func TestNewTodo(t *testing.T) {
    tests := []struct {
        name    string
        title   string
        wantErr bool
    }{
        {"titre valide", "Apprendre TDD Go", false},
        {"titre vide", "", true},
        {"titre trop long", string(make([]byte, 201)), true},
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

**2. Green - Implementation minimale**

Claude implemente `internal/domain/todo.go` avec la struct `Todo`, le constructeur `NewTodo` et l'interface `Repository` pour passer les tests.

**3. Refactor**

Apres que les tests passent, Claude propose :
- Ajouter la methode `Complete()` sur l'entite
- Verifier que l'interface `Repository` couvre tous les cas d'usage

### Continuer avec le repository

```bash
/dev:dev-tdd "implementation repository en memoire avec sync.RWMutex"
```

Claude ecrit d'abord les tests du repository (`FindAll`, `FindByID`, `Save`, `Delete`), puis implemente `internal/repository/memory.go` avec la protection en concurrence.

### Commit atomique

```bash
/work:work-commit
```

**Message suggere :**

```
feat(domain): add Todo entity and in-memory repository

- Add Todo struct with validation (title 1-200 chars)
- Add Repository interface
- Add thread-safe in-memory implementation
- Add table-driven tests with testify
```

---

## Phase 4 : TDD - Handlers HTTP

### Lancer le TDD sur les handlers

```bash
/dev:dev-tdd "handlers HTTP CRUD avec chi et httptest"
```

**1. Red - Tests avec `net/http/httptest`**

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
    "github.com/votre-org/todo-api/internal/api/handler"
    "github.com/votre-org/todo-api/internal/domain"
    "github.com/votre-org/todo-api/internal/repository"
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
            name:       "creation valide",
            body:       `{"title":"Apprendre Chi"}`,
            wantStatus: http.StatusCreated,
        },
        {
            name:       "titre manquant",
            body:       `{}`,
            wantStatus: http.StatusBadRequest,
        },
        {
            name:       "json invalide",
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

**2. Green - Implementation du handler**

Claude implemente `internal/api/handler/todo.go` avec la methode `Create` qui decode le JSON, appelle le domaine et repond avec le statut correct.

**3. Red - Test d'erreur 404**

```go
func TestGetTodoNotFound(t *testing.T) {
    h := setupHandler(t)
    req := httptest.NewRequest(http.MethodGet, "/api/todos/inexistant", nil)
    // Chi injecte les params d'URL via le contexte
    req = withURLParam(req, "id", "inexistant")
    w := httptest.NewRecorder()

    h.GetByID(w, req)

    assert.Equal(t, http.StatusNotFound, w.Code)

    var body map[string]string
    require.NoError(t, json.NewDecoder(w.Body).Decode(&body))
    assert.Contains(t, body["error"], "not found")
}
```

**4. Green - Gestion du 404**

Claude ajoute la gestion du cas `domain.ErrNotFound` dans le handler `GetByID`.

**5. Refactor**

Apres que tous les tests passent, Claude propose :
- Extraire un helper `respondJSON` pour centraliser l'ecriture des reponses
- Extraire un helper `respondError` pour les erreurs

### Creer les autres handlers

```bash
/dev:dev-api "GET /api/todos - Liste de toutes les taches"
```

```bash
/dev:dev-api "PUT /api/todos/{id} - Mettre a jour une tache"
```

```bash
/dev:dev-api "DELETE /api/todos/{id} - Supprimer une tache"
```

### Configurer le router Chi

```bash
/dev:dev-api "router Chi avec middleware logging et recover"
```

Claude cree `internal/api/router.go` avec les routes montees sur Chi, le middleware `chi.Logger` et `chi.Recoverer`.

### Commit atomique

```bash
/work:work-commit
```

**Message suggere :**

```
feat(api): add CRUD handlers with Chi router

- Add TodoHandler with Create, GetByID, List, Update, Delete
- Add Chi router with Logger and Recoverer middleware
- Add httptest-based table-driven tests
- Handle 404 and 400 error cases
```

---

## Phase 5 : Qualite

### Verification statique

```bash
make vet
```

Resultat attendu :

```
# Aucune sortie = aucun probleme
```

```bash
make lint
```

Claude corrige les avertissements signales par golangci-lint (imports non utilises, erreurs non verifiees, etc.).

### Audit securite

```bash
/qa:qa-security
```

**Sortie abregee typique :**

```
## Audit Securite - API Go

### P0 - Critique
  (aucun)

### P1 - Important
- [VALIDATION] Ajouter une limite de taille sur le body de la requete
  → Ajouter http.MaxBytesReader dans le handler ou en middleware

### P2 - Moyen
- [HEADERS] Ajouter les headers de securite (X-Content-Type-Options, etc.)
  → Ajouter un middleware de securite apres chi.Logger

### Recommendations
- Configurer un timeout sur le serveur HTTP (ReadTimeout, WriteTimeout)
- Ajouter un rate limiter pour les endpoints publics

Score : 82/100
```

Claude applique les corrections P0 et P1 :
- Ajout de `http.MaxBytesReader` pour limiter la taille du body
- Ajout d'un middleware de headers de securite
- Configuration des timeouts sur `http.Server`

### Relancer les tests

```bash
make test
```

Verifiez que tous les tests passent apres les corrections.

---

## Phase 6 : Commit et PR

### Commit des corrections qualite

```bash
/work:work-commit
```

**Message suggere :**

```
fix(security): add request body limit and security headers

- Limit request body to 1MB with MaxBytesReader
- Add security headers middleware (X-Content-Type-Options, etc.)
- Configure ReadTimeout and WriteTimeout on http.Server
```

### Creer la PR

```bash
/work:work-pr
```

Claude genere une PR avec :
- Description des endpoints implementes
- Resultats des tests (`make test`)
- Points corriges par l'audit securite

---

## Recapitulatif

Vous avez developpe une API REST Go complete en suivant le workflow du socle :

```
todo-api/
├── cmd/app/main.go                      # Point d'entree et wiring
├── internal/
│   ├── domain/
│   │   ├── todo.go                      # Entite + interface Repository
│   │   └── todo_test.go                 # Tests table-driven domaine
│   ├── repository/
│   │   ├── memory.go                    # Implementation thread-safe
│   │   └── memory_test.go
│   └── api/
│       ├── router.go                    # Chi router + middleware
│       └── handler/
│           ├── todo.go                  # Handlers HTTP
│           └── todo_test.go             # Tests httptest table-driven
├── Makefile
└── .golangci.yml
```

| Commande | Ce qu'elle fait |
|----------|-----------------|
| `/work:work-explore` | Analyse le projet et configure CLAUDE.md |
| `/work:work-plan` | Planifie l'architecture avant de coder |
| `/dev:dev-tdd` | Cycle Red-Green-Refactor avec testify |
| `/dev:dev-api` | Cree un endpoint avec handler et tests |
| `/qa:qa-security` | Audit securite et corrections |
| `/work:work-commit` | Commit conventionnel atomique |
| `/work:work-pr` | Cree la PR avec description complete |

### Points cles Go appris

| Concept | Application dans ce tutoriel |
|---------|------------------------------|
| Tests table-driven | Couverture de tous les cas en une boucle `for _, tt := range tests` |
| `net/http/httptest` | Tests de handlers sans demarrer de serveur reel |
| `sync.RWMutex` | Protection du repository en memoire pour la concurrence |
| Interfaces Go | `Repository` definie dans le domaine, implementee dans le package repository |
| Gestion des erreurs | Erreurs typees (`domain.ErrNotFound`) pour distinguer les cas HTTP |

---

## Pour aller plus loin

- [Guide Go](/docs/concepts/stack-recipes) - Patterns avances, gestion des erreurs, concurrence
- [Guide Auth](/docs/concepts/stack-recipes) - Ajouter JWT a votre API Go
- [Guide Database](/docs/concepts/stack-recipes) - Remplacer le repository memoire par PostgreSQL avec pgx
- [Tutoriel 10 : Projet complet TaskFlow](/docs/tutorials/projet-complet) - Integrer ce backend dans un projet full-stack

---

:::tip Tests table-driven en Go
Les tests table-driven sont le pattern idiomatique Go pour couvrir de multiples cas sans dupliquer le code. Utilisez `/dev:dev-tdd` : Claude genere automatiquement ce pattern et l'etend a chaque nouveau cas d'usage.
:::

:::info Architecture cmd/internal/
Le dossier `internal/` garantit que votre code metier n'est pas importe par des projets externes. C'est une convention Go forte que le socle respecte dans tous les projets Go generes.
:::
