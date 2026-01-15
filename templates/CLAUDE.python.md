# Projet Python

## Commandes Essentielles
- `pip install -r requirements.txt` - Installer les dépendances
- `python -m pytest` - Lancer les tests
- `python -m pytest --cov` - Tests avec couverture
- `python -m flake8` - Linter
- `python -m black .` - Formatter
- `python -m mypy .` - Type checking
- `python main.py` - Lancer l'application

## Environnement virtuel
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```

## Structure du Projet
- `/src` ou `/app` - Code source principal
- `/tests` - Tests pytest
- `/scripts` - Scripts utilitaires
- `/config` - Configuration
- `requirements.txt` - Dépendances de production
- `requirements-dev.txt` - Dépendances de développement

## Conventions Python
- IMPORTANT: Suivre PEP 8
- IMPORTANT: Type hints sur toutes les fonctions publiques
- YOU MUST écrire des docstrings (Google style ou NumPy style)
- Snake_case pour fonctions et variables
- PascalCase pour classes

## Type Hints
```python
def process_data(items: list[dict[str, Any]], limit: int = 10) -> list[str]:
    """Process and return filtered items.

    Args:
        items: List of dictionaries to process
        limit: Maximum items to return

    Returns:
        List of processed item names
    """
    ...
```

## Tests
- pytest pour tests unitaires
- pytest-cov pour couverture
- fixtures pour setup/teardown
- Mocks limités (unittest.mock si nécessaire)

## Qualité de code
```bash
# Formatter
black .

# Linter
flake8 .

# Type checker
mypy .

# Tout en un (si configuré)
pre-commit run --all-files
```

## Gestion des erreurs
```python
class CustomError(Exception):
    """Description de l'erreur custom."""
    pass

# Utilisation
try:
    result = risky_operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise CustomError("Friendly message") from e
```

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore

## Hooks Claude Code 2.1+

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Bloque les modifications sur main/master |
| Auto-format | PostToolUse | Black/Prettier sur fichiers Python modifiés |
| Type check | PostToolUse | MyPy après édition |
| Lint check | PostToolUse | Flake8/Ruff après édition |
| Test avant commit | PreToolUse | Exécute `pytest` avant chaque commit |
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
