---
paths:
  - "**/*.py"
  - "**/requirements*.txt"
  - "**/pyproject.toml"
  - "**/setup.py"
---

# Python Rules

## Type Hints

- IMPORTANT: Utiliser les type hints pour toutes les fonctions publiques
- YOU MUST annoter les arguments et retours de fonction
- Utiliser `typing` module pour types complexes
- Preferer `list[str]` a `List[str]` (Python 3.9+)

## Naming Conventions

| Type | Convention | Exemple |
|------|------------|---------|
| Variables/Fonctions | snake_case | `get_user_by_id` |
| Classes | PascalCase | `UserService` |
| Constantes | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Modules/Packages | snake_case | `user_service.py` |
| Protected | _prefixe | `_internal_method` |
| Private | __prefixe | `__private_attr` |

## Code Style (PEP 8)

- Indentation: 4 espaces (pas de tabs)
- Ligne max: 88 caracteres (Black) ou 79 (PEP 8)
- Imports groupes: stdlib, third-party, local
- Deux lignes vides entre classes/fonctions top-level
- Une ligne vide entre methodes de classe

## Imports

```python
# Ordre des imports
import os
import sys
from pathlib import Path

import requests
from pydantic import BaseModel

from app.models import User
from app.services import UserService
```

## Type Hints Patterns

```python
from typing import Optional, TypeVar, Generic

# Fonction typee
def get_user(user_id: int) -> Optional[User]:
    ...

# Generic
T = TypeVar('T')

class Repository(Generic[T]):
    def get(self, id: int) -> T | None:
        ...

# Callable
from collections.abc import Callable

def process(callback: Callable[[int], str]) -> None:
    ...
```

## Async Patterns

```python
import asyncio
from typing import AsyncIterator

async def fetch_data(url: str) -> dict:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.json()

async def stream_data() -> AsyncIterator[str]:
    for item in items:
        yield item
        await asyncio.sleep(0)
```

## Error Handling

- Utiliser des exceptions specifiques, pas `Exception` generique
- Creer des exceptions custom pour le domaine
- NEVER utiliser `except:` sans type (bare except)
- Utiliser `finally` pour le cleanup

```python
class UserNotFoundError(Exception):
    """Raised when user is not found."""
    pass

try:
    user = get_user(user_id)
except UserNotFoundError:
    logger.warning(f"User {user_id} not found")
    raise
except DatabaseError as e:
    logger.error(f"Database error: {e}")
    raise
```

## Best Practices

- Utiliser `pathlib.Path` au lieu de `os.path`
- Preferer `dataclasses` ou `pydantic` pour les DTOs
- Utiliser context managers (`with`) pour les ressources
- Eviter les mutables comme valeurs par defaut
- Documenter avec docstrings (Google ou NumPy style)

## Anti-patterns

- NEVER utiliser `eval()` ou `exec()` avec input utilisateur
- NEVER ignorer les exceptions silencieusement
- Eviter les imports `*` (wildcard)
- Eviter les variables globales mutables
- Ne pas melanger tabs et espaces
