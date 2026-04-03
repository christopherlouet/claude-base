---
sidebar_position: 12
title: "11 - API Python FastAPI"
description: "Developpez une API REST FastAPI avec TDD, validation Pydantic et documentation OpenAPI"
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# API Python avec FastAPI

<DifficultyBadge level="intermediate" /> **Duree estimee : 45 minutes**

Ce tutoriel vous montre comment developper une API REST professionnelle en Python avec FastAPI, en suivant le workflow TDD du socle Claude.

## Objectifs

A la fin de ce tutoriel, vous saurez :
- Utiliser `/dev:dev-api` pour creer des endpoints FastAPI
- Utiliser `/dev:dev-tdd` pour le cycle Red-Green-Refactor avec pytest
- Utiliser `/doc:doc-api-spec` pour exploiter la documentation OpenAPI generee automatiquement
- Utiliser `/qa:qa-security` pour auditer la securite de votre API

## Prerequis

- Claude Code installe et socle configure
- Python 3.11+ installe
- `uv` (recommande) ou `pip` pour la gestion des dependances
- Connaissances de base Python et REST

## Contexte

Nous allons creer une API de gestion de **taches (todos)** avec :
- CRUD complet (Create, Read, Update, Delete)
- Validation des donnees avec Pydantic
- Documentation OpenAPI generee automatiquement par FastAPI
- Tests d'integration avec httpx

---

## Phase 1 : Initialisation du projet

Creez le projet Python et configurez la structure initiale.

```bash
# Initialiser avec uv
uv init api-todos
cd api-todos

# Ajouter les dependances
uv add fastapi uvicorn[standard] pydantic
uv add --dev pytest pytest-asyncio httpx
```

Structure cible apres initialisation :

```
api-todos/
├── src/
│   ├── __init__.py
│   ├── main.py          # Application FastAPI
│   ├── models/          # Modeles SQLAlchemy (si base de donnees)
│   ├── schemas/         # Schemas Pydantic
│   ├── routers/         # Endpoints par domaine
│   └── services/        # Logique metier
├── tests/
│   ├── __init__.py
│   └── conftest.py      # Fixtures pytest
├── pyproject.toml
└── CLAUDE.md
```

Creez un `CLAUDE.md` minimal pour guider Claude sur ce projet :

```markdown
# api-todos

API REST de gestion de taches avec FastAPI.

## Stack
- Python 3.11+, FastAPI, Pydantic v2
- Tests : pytest + httpx (AsyncClient)
- Style : PEP 8, type hints obligatoires

## Conventions
- Schemas dans src/schemas/
- Logique metier dans src/services/
- Routes dans src/routers/
```

---

## Phase 2 : Exploration et planification

Avant d'ecrire une seule ligne de code, explorez et planifiez.

### Explorer la structure

```bash
/work:work-explore "Analyser la structure du projet FastAPI et identifier les patterns a suivre"
```

Claude va examiner :
- Le `pyproject.toml` et les dependances disponibles
- Les conventions de nommage en place
- Les fichiers de configuration existants
- L'organisation des modules

### Planifier l'API

```bash
/work:work-plan "API CRUD taches avec FastAPI, schemas Pydantic, et tests httpx"
```

**Plan attendu :**

```
## Plan : API Todos

### Endpoints a creer
- GET    /api/todos       - Liste des taches (avec filtres optionnels)
- GET    /api/todos/{id}  - Detail d'une tache
- POST   /api/todos       - Creer une tache
- PUT    /api/todos/{id}  - Modifier une tache
- DELETE /api/todos/{id}  - Supprimer une tache

### Fichiers a creer
- src/schemas/todo.py     - Schemas Pydantic (request/response)
- src/services/todo.py    - Logique metier (stockage en memoire)
- src/routers/todo.py     - Routes FastAPI
- src/main.py             - Application et configuration
- tests/test_todos.py     - Tests d'integration

### Risques identifies
- Gestion des IDs (uuid vs int sequentiel)
- Thread-safety du stockage en memoire
- Validation Pydantic v2 (syntax differente de v1)
```

Validez le plan avant de continuer.

---

## Phase 3 : TDD - Modeles et schemas Pydantic

Commencez par les schemas : ils definissent le contrat de l'API.

```bash
/dev:dev-tdd "schemas Pydantic pour les taches : TodoCreate, TodoUpdate, TodoResponse"
```

### Cycle Red-Green-Refactor

**1. Red - Le test qui echoue**

```python
# tests/test_schemas.py
import pytest
from pydantic import ValidationError
from src.schemas.todo import TodoCreate, TodoUpdate, TodoResponse


class TestTodoCreate:
    def test_valid_todo(self):
        todo = TodoCreate(title="Apprendre FastAPI")
        assert todo.title == "Apprendre FastAPI"
        assert todo.description is None
        assert todo.completed is False

    def test_title_required(self):
        with pytest.raises(ValidationError) as exc_info:
            TodoCreate()
        errors = exc_info.value.errors()
        assert any(e["loc"] == ("title",) for e in errors)

    def test_title_cannot_be_empty(self):
        with pytest.raises(ValidationError):
            TodoCreate(title="")

    def test_title_max_length(self):
        with pytest.raises(ValidationError):
            TodoCreate(title="x" * 201)
```

```
$ pytest tests/test_schemas.py
FAILED - ModuleNotFoundError: No module named 'src.schemas.todo'
```

**2. Green - Implementation minimale**

```python
# src/schemas/todo.py
from pydantic import BaseModel, Field
from datetime import datetime
from uuid import UUID


class TodoCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: str | None = None
    completed: bool = False


class TodoUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=200)
    description: str | None = None
    completed: bool | None = None


class TodoResponse(BaseModel):
    id: UUID
    title: str
    description: str | None
    completed: bool
    created_at: datetime
```

```
$ pytest tests/test_schemas.py
4 passed in 0.12s
```

**3. Refactor - Ameliorations**

Claude propose d'ajouter un validateur metier et un exemple OpenAPI :

```python
class TodoCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: str | None = Field(None, max_length=1000)
    completed: bool = False

    model_config = {
        "json_schema_extra": {
            "example": {
                "title": "Lire la documentation FastAPI",
                "description": "Chapitres sur les dependances et la securite",
                "completed": False,
            }
        }
    }
```

Commitez cette etape :

```bash
/work:work-commit
```

```
test(schemas): add Pydantic schema tests for TodoCreate/Update/Response
feat(schemas): implement Pydantic v2 schemas with validation rules
```

---

## Phase 4 : TDD - Endpoints CRUD

Passez maintenant aux routes FastAPI, testees via `httpx.AsyncClient`.

```bash
/dev:dev-tdd "endpoints CRUD FastAPI pour les taches avec tests httpx"
```

### Fixture de test

```python
# tests/conftest.py
import pytest
from httpx import AsyncClient, ASGITransport
from src.main import app


@pytest.fixture
async def client():
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac
```

### Tests - Creation et validation

**1. Red**

```python
# tests/test_todos.py
import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
class TestCreateTodo:
    async def test_create_todo_returns_201(self, client: AsyncClient):
        response = await client.post(
            "/api/todos",
            json={"title": "Apprendre TDD", "description": "Avec pytest et httpx"},
        )
        assert response.status_code == 201
        body = response.json()
        assert body["title"] == "Apprendre TDD"
        assert body["completed"] is False
        assert "id" in body
        assert "created_at" in body

    async def test_create_todo_missing_title_returns_422(self, client: AsyncClient):
        response = await client.post(
            "/api/todos",
            json={"description": "Sans titre"},
        )
        assert response.status_code == 422
        detail = response.json()["detail"]
        assert any("title" in str(e) for e in detail)
```

```
$ pytest tests/test_todos.py
FAILED - 404 Not Found (routes non encore creees)
```

**2. Green - Routes et service**

Claude cree le service en memoire puis les routes :

```python
# src/services/todo.py
from uuid import uuid4, UUID
from datetime import datetime, timezone
from src.schemas.todo import TodoCreate, TodoUpdate, TodoResponse


class TodoService:
    def __init__(self):
        self._store: dict[UUID, TodoResponse] = {}

    def create(self, data: TodoCreate) -> TodoResponse:
        todo = TodoResponse(
            id=uuid4(),
            title=data.title,
            description=data.description,
            completed=data.completed,
            created_at=datetime.now(timezone.utc),
        )
        self._store[todo.id] = todo
        return todo

    def get(self, todo_id: UUID) -> TodoResponse | None:
        return self._store.get(todo_id)

    def list_all(self, completed: bool | None = None) -> list[TodoResponse]:
        todos = list(self._store.values())
        if completed is not None:
            todos = [t for t in todos if t.completed == completed]
        return todos

    def update(self, todo_id: UUID, data: TodoUpdate) -> TodoResponse | None:
        todo = self._store.get(todo_id)
        if not todo:
            return None
        updated = todo.model_copy(
            update={k: v for k, v in data.model_dump().items() if v is not None}
        )
        self._store[todo_id] = updated
        return updated

    def delete(self, todo_id: UUID) -> bool:
        return self._store.pop(todo_id, None) is not None


todo_service = TodoService()
```

```python
# src/routers/todo.py
from uuid import UUID
from fastapi import APIRouter, HTTPException, Query
from src.schemas.todo import TodoCreate, TodoUpdate, TodoResponse
from src.services.todo import todo_service

router = APIRouter(prefix="/api/todos", tags=["todos"])


@router.post("", response_model=TodoResponse, status_code=201)
async def create_todo(data: TodoCreate) -> TodoResponse:
    return todo_service.create(data)


@router.get("", response_model=list[TodoResponse])
async def list_todos(
    completed: bool | None = Query(None, description="Filtrer par statut")
) -> list[TodoResponse]:
    return todo_service.list_all(completed=completed)


@router.get("/{todo_id}", response_model=TodoResponse)
async def get_todo(todo_id: UUID) -> TodoResponse:
    todo = todo_service.get(todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Tache introuvable")
    return todo


@router.put("/{todo_id}", response_model=TodoResponse)
async def update_todo(todo_id: UUID, data: TodoUpdate) -> TodoResponse:
    todo = todo_service.update(todo_id, data)
    if not todo:
        raise HTTPException(status_code=404, detail="Tache introuvable")
    return todo


@router.delete("/{todo_id}", status_code=204)
async def delete_todo(todo_id: UUID) -> None:
    if not todo_service.delete(todo_id):
        raise HTTPException(status_code=404, detail="Tache introuvable")
```

```
$ pytest tests/test_todos.py
2 passed in 0.31s
```

### Tests - Cas d'erreur (404)

```bash
/dev:dev-tdd "tester les cas d'erreur 404 sur GET, PUT et DELETE"
```

**Red**

```python
@pytest.mark.asyncio
class TestTodoNotFound:
    async def test_get_unknown_id_returns_404(self, client: AsyncClient):
        fake_id = "00000000-0000-0000-0000-000000000000"
        response = await client.get(f"/api/todos/{fake_id}")
        assert response.status_code == 404
        assert "introuvable" in response.json()["detail"].lower()

    async def test_update_unknown_id_returns_404(self, client: AsyncClient):
        fake_id = "00000000-0000-0000-0000-000000000000"
        response = await client.put(
            f"/api/todos/{fake_id}", json={"title": "Nouveau titre"}
        )
        assert response.status_code == 404

    async def test_delete_unknown_id_returns_404(self, client: AsyncClient):
        fake_id = "00000000-0000-0000-0000-000000000000"
        response = await client.delete(f"/api/todos/{fake_id}")
        assert response.status_code == 404
```

Les routes existantes gerent deja ces cas. Les tests passent immediatement.

```
$ pytest tests/
8 passed in 0.45s
```

Commitez cette etape :

```bash
/work:work-commit
```

```
test(api): add CRUD endpoint tests with httpx AsyncClient
feat(api): implement CRUD routes and in-memory TodoService
```

---

## Phase 5 : Documentation et qualite

### Documentation OpenAPI

FastAPI genere la documentation OpenAPI automatiquement. Utilisez l'agent pour la completer et l'exporter.

```bash
/doc:doc-api-spec
```

Claude va :
- Verifier que chaque endpoint a un `summary` et une `description`
- S'assurer que les codes de reponse sont documentes (`responses`)
- Ajouter des exemples dans les schemas Pydantic si manquants
- Exporter la specification en `openapi.json` si demande

**Sortie abregee :**

```
doc-api-spec - Analyse de l'API FastAPI

Endpoints documentes : 5/5
- POST   /api/todos       [OK] summary, requestBody, 201/422
- GET    /api/todos        [OK] summary, query params, 200
- GET    /api/todos/{id}  [OK] summary, path param, 200/404
- PUT    /api/todos/{id}  [WARN] description manquante - ajout automatique
- DELETE /api/todos/{id}  [OK] summary, 204/404

Actions : description ajoutee sur PUT /api/todos/{id}
Documentation disponible sur http://localhost:8000/docs (Swagger UI)
                              http://localhost:8000/redoc (ReDoc)
```

L'un des avantages de FastAPI : la documentation interactive est disponible sans configuration supplementaire sur `/docs`.

### Audit de securite

```bash
/qa:qa-security
```

**Sortie abregee :**

```
qa-security - Audit securite API FastAPI

[INFO]  Validation entrees : Pydantic v2 active sur tous les endpoints
[INFO]  Gestion erreurs : HTTPException utilisee correctement
[WARN]  Rate limiting : aucun middleware detecte
         -> Recommande : slowapi ou middleware Starlette custom
[WARN]  Authentification : aucune protection sur les endpoints
         -> Pour une API de production, ajouter OAuth2 ou API key
[INFO]  Headers securite : ajouter CORSMiddleware si exposition publique
[INFO]  Pas d'injection SQL detectee (stockage en memoire)

Score : 72/100 (acceptable pour un prototype, revoir avant production)
Points P1 : rate limiting, authentification
Points P2 : CORS, headers de securite
```

Claude propose les correctifs P1 si vous souhaitez les appliquer :

```bash
/qa:qa-loop "score 80"
```

---

## Phase 6 : Commit et Pull Request

Verifiez l'etat final des tests avant de commiter.

```bash
pytest --tb=short
```

```
tests/test_schemas.py ...     4 passed
tests/test_todos.py .......   7 passed
--------------------------------------
11 passed in 0.52s
```

Commitez les ajouts de documentation et d'audit :

```bash
/work:work-commit
```

```
docs(api): add OpenAPI descriptions and response examples
feat(security): add rate limiting middleware (slowapi)
```

Creez la Pull Request :

```bash
/work:work-pr
```

**Description generee :**

```
## API Todos - FastAPI + TDD

### Changements
- Schemas Pydantic v2 (TodoCreate, TodoUpdate, TodoResponse)
- Service en memoire avec CRUD complet
- 5 endpoints REST : POST/GET/GET/:id/PUT/:id/DELETE/:id
- 11 tests d'integration via httpx.AsyncClient
- Documentation OpenAPI enrichie (Swagger UI sur /docs)
- Rate limiting via slowapi

### Tests
11 passed, couverture 87%

### Securite
Score qa-security : 82/100
```

---

## Recapitulatif

Vous avez developpe une API REST FastAPI complete en suivant le workflow TDD du socle.

### Structure finale

```
api-todos/
├── src/
│   ├── main.py              # Application FastAPI, inclusion du router
│   ├── schemas/
│   │   └── todo.py          # Pydantic : TodoCreate, TodoUpdate, TodoResponse
│   ├── services/
│   │   └── todo.py          # Logique metier, stockage en memoire
│   └── routers/
│       └── todo.py          # 5 endpoints CRUD
├── tests/
│   ├── conftest.py          # Fixture httpx.AsyncClient
│   ├── test_schemas.py      # Tests validation Pydantic
│   └── test_todos.py        # Tests integration endpoints
└── pyproject.toml
```

### Commandes utilisees

| Commande | Phase | Resultat |
|----------|-------|---------|
| `/work:work-explore` | Exploration | Comprehension de la structure et des conventions |
| `/work:work-plan` | Planification | Plan valide avec endpoints, fichiers et risques |
| `/dev:dev-tdd` | Schemas | Tests Pydantic + implementation schemas v2 |
| `/dev:dev-tdd` | Endpoints | Tests httpx + routes CRUD + service en memoire |
| `/doc:doc-api-spec` | Documentation | OpenAPI enrichie, Swagger UI operationnel |
| `/qa:qa-security` | Audit | Score securite, recommandations rate limiting et auth |
| `/work:work-commit` | Commit | Commits atomiques par phase |
| `/work:work-pr` | PR | Pull Request avec description generee |

### Ce que FastAPI apporte par rapport a Node.js

| Aspect | FastAPI (Python) | Express (Node.js) |
|--------|-----------------|-------------------|
| Validation | Pydantic (natif) | Zod (dependance externe) |
| Documentation | OpenAPI auto-generee | Plugin swagger-jsdoc |
| Types | Type hints Python | TypeScript |
| Tests async | pytest-asyncio + httpx | supertest |
| Performance | Comparable (ASGI) | Comparable (event loop) |

---

## Pour aller plus loin

- [Guide Python](/docs/guides/python-guide) - Conventions, async, packaging
- [Guide API](/docs/guides/api-guide) - Bonnes pratiques REST, versioning, pagination
- [Guide Auth](/docs/guides/auth-guide) - OAuth2, JWT, API keys avec FastAPI
- [Guide Base de donnees](/docs/guides/database-guide) - SQLAlchemy, Alembic, migrations
- [Tutoriel 10 : Projet complet](/docs/tutorials/projet-complet) - Capstone integrant tous les guides

---

:::tip Pydantic v2 et FastAPI
Pydantic v2 est significativement plus rapide que v1 et la syntaxe a evolue. Si vous reprenez un projet existant, verifiez la version avec `uv pip show pydantic`. Les schemas `Config` internes sont remplaces par `model_config` en v2.
:::

:::info Documentation interactive gratuite
L'un des atouts majeurs de FastAPI est la generation automatique de Swagger UI (`/docs`) et ReDoc (`/redoc`) sans configuration supplementaire. Utilisez `/doc:doc-api-spec` pour enrichir les descriptions, pas pour generer la spec de zero.
:::
