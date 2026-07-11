# Python Project

## Essential Commands
- `pip install -r requirements.txt` - Install dependencies
- `python -m pytest` - Run tests
- `python -m pytest --cov` - Tests with coverage
- `python -m flake8` - Linter
- `python -m black .` - Formatter
- `python -m mypy .` - Type checking
- `python main.py` - Run the application

## Virtual environment
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```

## Project Structure
- `/src` or `/app` - Main source code
- `/tests` - pytest tests
- `/scripts` - Utility scripts
- `/config` - Configuration
- `requirements.txt` - Production dependencies
- `requirements-dev.txt` - Development dependencies

## Python Conventions
- IMPORTANT: Follow PEP 8
- IMPORTANT: Type hints on all public functions
- YOU MUST write docstrings (Google style or NumPy style)
- snake_case for functions and variables
- PascalCase for classes

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
- pytest for unit tests
- pytest-cov for coverage
- fixtures for setup/teardown
- Limited mocks (unittest.mock if necessary)

## Code quality
```bash
# Formatter
black .

# Linter
flake8 .

# Type checker
mypy .

# All in one (if configured)
pre-commit run --all-files
```

## Error handling
```python
class CustomError(Exception):
    """Description of the custom error."""
    pass

# Usage
try:
    result = risky_operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise CustomError("Friendly message") from e
```

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore

## Claude Code 2.1+ Hooks

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Blocks modifications on main/master |
| Auto-format | PostToolUse | Black/Prettier on modified Python files |
| Type check | PostToolUse | MyPy after edit |
| Lint check | PostToolUse | Flake8/Ruff after edit |
| Test before commit | PreToolUse | Runs `pytest` before each commit |
| Secret detection | PreToolUse | Blocks hardcoded secrets |

## Available skills

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyze an existing codebase |
| `planning-implementation` | Define a plan before coding |
| `test-driven-development` | TDD Red-Green-Refactor cycle |
| `qa-review` | In-depth code review |
| `debugging-issues` | Methodical diagnosis |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | Complete and documented PR |
