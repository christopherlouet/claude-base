# Guide Developpement Python

> Workflow complet pour backends Python avec FastAPI, Django, Flask et l'ecosysteme moderne

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Frameworks | FastAPI, Django, Flask |
| ORM | SQLAlchemy, Django ORM |
| Validation | Pydantic v2 |
| Migrations | Alembic, Django Migrations |
| Tests | pytest, pytest-asyncio, httpx |
| Linting/Format | ruff |
| Type checking | mypy |
| Securite | bandit |
| Gestionnaires de paquets | uv, pip |
| Tasks asynchrones | Celery, Redis |

## Architecture Recommandee

```
src/
├── api/            # Routes FastAPI/Flask
├── core/           # Config, security, dependencies
├── models/         # SQLAlchemy/Pydantic models
├── schemas/        # Pydantic DTOs
├── services/       # Business logic
├── repositories/   # Data access
└── utils/          # Helpers
tests/
├── conftest.py     # Fixtures partagees
├── unit/           # Tests unitaires
└── integration/    # Tests d'integration
pyproject.toml
```

## Workflow Recommande

```
/work:work-explore → /work:work-plan → /dev:dev-api → /dev:dev-tdd → /qa:qa-security → /work:work-pr
```

## Phase 1: Exploration

### Comprendre le projet Python existant

```bash
/work:work-explore
```

### Questions a clarifier

- Framework cible (FastAPI, Django, Flask)?
- Gestionnaire de paquets (uv ou pip)?
- Base de donnees (PostgreSQL, SQLite, MySQL)?
- Authentification (JWT, session, OAuth)?
- Taches asynchrones (Celery, arq, dramatiq)?

### Lire le contexte technique

```bash
cat pyproject.toml && cat .env.example   # dependances et config
uv run ruff check . && uv run mypy src/ && uv run pytest --tb=short  # baseline CI
```

## Phase 2: Setup

### Initialiser avec uv (recommande)

```bash
uv init mon-projet && cd mon-projet
uv add fastapi uvicorn sqlalchemy pydantic-settings alembic
uv add --dev pytest pytest-asyncio httpx ruff mypy bandit
```

### Configuration pyproject.toml

```toml
[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "S", "B", "A"]
ignore = ["S101"]  # assert autorise dans les tests

[tool.mypy]
strict = true
python_version = "3.12"

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]

[tool.coverage.report]
fail_under = 80
```

## Phase 3: Developpement API

### Creer un endpoint FastAPI

```bash
/dev:dev-api "endpoint CRUD pour les produits avec pagination et filtres"
```

### Exemple endpoint FastAPI avec validation Pydantic

```python
# src/schemas/product.py
from pydantic import BaseModel, Field, PositiveFloat
from uuid import UUID

class ProductCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    price: PositiveFloat
    category_id: UUID

class ProductResponse(BaseModel):
    id: UUID
    name: str
    price: float
    category_id: UUID
    model_config = {"from_attributes": True}

# src/api/products.py
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from src.core.dependencies import get_db
from src.schemas.product import ProductCreate, ProductResponse
from src.services.product_service import ProductService

router = APIRouter(prefix="/products", tags=["products"])

@router.get("/", response_model=list[ProductResponse])
async def list_products(
    page: int = Query(1, ge=1), limit: int = Query(10, ge=1, le=100),
    category_id: UUID | None = None, db: AsyncSession = Depends(get_db),
) -> list[ProductResponse]:
    return await ProductService(db).list(page=page, limit=limit, category_id=category_id)

@router.post("/", response_model=ProductResponse, status_code=201)
async def create_product(payload: ProductCreate, db: AsyncSession = Depends(get_db)) -> ProductResponse:
    return await ProductService(db).create(payload)

@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(product_id: UUID, db: AsyncSession = Depends(get_db)) -> ProductResponse:
    product = await ProductService(db).get(product_id)
    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")
    return product
```

### Pattern Repository avec SQLAlchemy

```python
# src/repositories/product_repository.py
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from src.models.product import Product
from src.schemas.product import ProductCreate

class ProductRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_id(self, product_id: UUID) -> Product | None:
        result = await self.db.execute(select(Product).where(Product.id == product_id))
        return result.scalar_one_or_none()

    async def list(self, offset: int = 0, limit: int = 10, category_id: UUID | None = None) -> list[Product]:
        query = select(Product)
        if category_id is not None:
            query = query.where(Product.category_id == category_id)
        result = await self.db.execute(query.offset(offset).limit(limit))
        return list(result.scalars().all())

    async def create(self, payload: ProductCreate) -> Product:
        product = Product(**payload.model_dump())
        self.db.add(product)
        await self.db.flush()
        await self.db.refresh(product)
        return product
```

## Phase 4: TDD avec pytest

### Fixture base de donnees (conftest.py)

```python
# tests/conftest.py
import pytest
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from src.main import app
from src.core.dependencies import get_db
from src.models.base import Base

TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

@pytest.fixture(autouse=True)
async def setup_db():
    engine = create_async_engine(TEST_DATABASE_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    AsyncTestSession = async_sessionmaker(engine, expire_on_commit=False)
    async with AsyncTestSession() as session:
        async def override_get_db():
            yield session
        app.dependency_overrides[get_db] = override_get_db
        yield session
    app.dependency_overrides.clear()

@pytest.fixture
async def client(setup_db) -> AsyncClient:
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac
```

### Test async avec httpx et parametrize

```python
# tests/integration/test_products.py
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_product(client: AsyncClient) -> None:
    response = await client.post("/products/", json={"name": "Widget", "price": 9.99, "category_id": "..."})
    assert response.status_code == 201
    assert response.json()["name"] == "Widget"

@pytest.mark.asyncio
async def test_create_product_invalid_price(client: AsyncClient) -> None:
    response = await client.post("/products/", json={"name": "Widget", "price": -1.0, "category_id": "..."})
    assert response.status_code == 422

@pytest.mark.asyncio
@pytest.mark.parametrize("limit,expected_count", [(1, 1), (5, 3), (10, 3)])
async def test_list_products_pagination(client: AsyncClient, limit: int, expected_count: int) -> None:
    for i in range(3):
        await client.post("/products/", json={"name": f"P{i}", "price": 1.0, "category_id": "..."})
    response = await client.get(f"/products/?limit={limit}")
    assert len(response.json()) == expected_count
```

### Lancer les tests

```bash
uv run pytest --cov=src --cov-report=term-missing   # couverture complete
uv run pytest --watch                               # watch mode TDD
uv run pytest tests/integration/ -v                # integration seulement
```

## Phase 5: Qualite et Securite

### Audit qualite

```bash
/qa:qa-security
```

### Commandes qualite

```bash
uv run ruff check . --fix && uv run ruff format .   # lint + format (remplace black + isort + flake8)
uv run mypy src/                                    # type checking strict
uv run bandit -r src/ -ll                           # audit securite OWASP
```

### Cibles qualite

| Metrique | Cible |
|----------|-------|
| Couverture lignes | > 80% |
| Couverture branches | > 70% |
| Score mypy (strict) | 0 erreur |
| Score bandit | 0 HIGH |
| Services critiques | 100% couverts |

### Checklist securite Python

- [ ] Variables d'environnement via `pydantic-settings` (pas de secrets dans le code)
- [ ] Validation stricte des inputs avec Pydantic
- [ ] Requetes SQL parametrees (jamais de f-string SQL)
- [ ] CORS configure explicitement
- [ ] Rate limiting en place (slowapi, nginx)
- [ ] Dependances auditees (`uv run pip-audit`)

## Phase 6: Specifiques Django

### Nouveau projet Django

```bash
/work:work-plan "API Django REST Framework pour gestion des utilisateurs"
```

### Structure Django recommandee

```
myapp/
├── models.py       # ORM Django
├── serializers.py  # DRF serializers (equivalent Pydantic)
├── views.py        # ViewSets ou APIViews
├── urls.py         # Routing
├── admin.py        # Interface admin
└── management/
    └── commands/   # Management commands custom
```

### Migrations Django

```bash
# Creer et appliquer une migration
python manage.py makemigrations
python manage.py migrate

# Inspecter le SQL genere
python manage.py sqlmigrate myapp 0001

# Management command custom
python manage.py seed_products --count 50
```

## Phase 7: Taches de Fond avec Celery

### Pattern de tache avec retry

```python
# src/tasks/email.py
from celery import shared_task
from celery.utils.log import get_task_logger

logger = get_task_logger(__name__)

@shared_task(bind=True, autoretry_for=(ConnectionError, TimeoutError),
             retry_backoff=True, retry_kwargs={"max_retries": 3})
def send_welcome_email(self, user_id: int) -> dict:
    user = get_user(user_id)
    result = email_client.send(to=user.email, template="welcome")
    return {"status": "sent", "message_id": result.id}
```

```bash
celery -A src.core.celery worker --loglevel=info      # lancer le worker
celery -A src.core.celery flower --port=5555           # monitoring
```

## Phase 8: Deploy

### Dockerfile multi-stage Python

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN pip install uv && uv sync --frozen --no-dev

FROM python:3.12-slim AS runtime
WORKDIR /app
COPY --from=builder /app/.venv .venv
COPY src/ ./src/
ENV PATH="/app/.venv/bin:$PATH" PYTHONUNBUFFERED=1
EXPOSE 8000
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Serveur de production

```bash
# Gunicorn + workers Uvicorn (multi-process, recommande)
gunicorn src.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000

# Uvicorn seul (derriere un reverse proxy nginx)
uvicorn src.main:app --host 0.0.0.0 --port 8000
```

## Commandes par Use Case

### Nouveau projet FastAPI

```bash
1. /work:work-plan          # Architecture et endpoints
2. /dev:dev-api             # Generer routes + schemas + services
3. /dev:dev-tdd             # Tests avec pytest + httpx
4. /qa:qa-security          # Audit bandit + OWASP
5. /ops:ops-ci              # CI GitHub Actions
```

### Nouveau projet Django

```bash
1. /work:work-plan          # Modeles, vues, serializers
2. /dev:dev-api             # ViewSets DRF
3. /dev:dev-tdd             # Tests pytest-django
4. /qa:qa-security          # CSRF, permissions, audit
5. /work:work-pr            # Pull Request
```

### Ajouter un endpoint ou une tache de fond

```bash
1. /work:work-explore       # Comprendre l'existant
2. /dev:dev-api             # Creer le schema + la route (ou la tache Celery)
3. /dev:dev-tdd             # Tests unitaires + integration
4. /work:work-pr            # Pull Request
```

### Migration de base de donnees

```bash
# FastAPI/SQLAlchemy (Alembic)
uv run alembic revision --autogenerate -m "add product table"
uv run alembic upgrade head
# Django
python manage.py makemigrations && python manage.py migrate
```

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Cree un endpoint FastAPI" | dev-api | Routes + schemas Pydantic |
| "Ajoute un modele SQLAlchemy" | dev-api | Model + migration Alembic |
| "Audit securite Python" | qa-security | bandit + OWASP + CVE |
| "Tests pytest manquants" | dev-tdd | Fixtures + parametrize |
| "Optimise les requetes N+1" | qa-perf | select_related, joinedload |
| "Dockerise l'API Python" | ops-docker | Multi-stage Dockerfile |

## Anti-patterns a Eviter

- Pas de type hints → mypy aveugle, IDE sans autocompletion
- Mutable default args (`def f(items=[])`) → bug partage entre appels
- Code synchrone dans async (`time.sleep`, `requests`) → bloque le thread uvicorn
- Requetes N+1 sans `selectinload`/`select_related` → performance degradee
- Pas de virtual env → conflits de dependances entre projets
- `requirements.txt` sans lock file → builds non reproductibles
- `except Exception: pass` → exceptions silencieuses, debug impossible
- Secrets dans le code source → fuite de credentials

## Ressources

- [FastAPI Documentation](https://fastapi.tiangolo.com)
- [SQLAlchemy Async](https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html)
- [Pydantic v2](https://docs.pydantic.dev/latest/)
- [pytest Documentation](https://docs.pytest.org)
- [ruff Linter](https://docs.astral.sh/ruff/)
- [uv Package Manager](https://docs.astral.sh/uv/)
- [Celery Documentation](https://docs.celeryq.dev)
