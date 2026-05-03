---
sidebar_position: 17
title: "python"
description: "import requests from pydantic import BaseModel"
tags:
  - "rule"
  - "python"
---

# Rules: python

> import requests from pydantic import BaseModel

## Affected files

These rules apply to files matching the following patterns:

- `**/*.py`
- `**/requirements*.txt`
- `**/pyproject.toml`
- `**/setup.py`

## Detailed rules

# Python Rules

## Type Hints

- IMPORTANT: Use type hints for all public functions
- YOU MUST annotate function arguments and return values
- Use the `typing` module for complex types
- Prefer `list[str]` over `List[str]` (Python 3.9+)

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables/Functions | snake_case | `get_user_by_id` |
| Classes | PascalCase | `UserService` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Modules/Packages | snake_case | `user_service.py` |
| Protected | _prefix | `_internal_method` |
| Private | __prefix | `__private_attr` |

## Code Style (PEP 8)

- Indentation: 4 spaces (no tabs)
- Max line length: 88 characters (Black) or 79 (PEP 8)
- Grouped imports: stdlib, third-party, local
- Two blank lines between top-level classes/functions
- One blank line between class methods

## Imports

```python
# Import order
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

# Typed function
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

- Use specific exceptions, not the generic `Exception`
- Create custom exceptions for the domain
- NEVER use `except:` without a type (bare except)
- Use `finally` for cleanup

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

- Use `pathlib.Path` instead of `os.path`
- Prefer `dataclasses` or `pydantic` for DTOs
- Use context managers (`with`) for resources
- Avoid mutables as default values
- Document with docstrings (Google or NumPy style)

## Anti-patterns

- NEVER use `eval()` or `exec()` with user input
- NEVER ignore exceptions silently
- Avoid `*` (wildcard) imports
- Avoid mutable global variables
- Do not mix tabs and spaces

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)
