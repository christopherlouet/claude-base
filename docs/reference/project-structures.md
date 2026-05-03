# Project Structure

## Web (React/Node)
```
/src
├── /components     # Reusable UI components
├── /services       # Business logic and API calls
├── /hooks          # Custom React hooks
├── /utils          # Pure utility functions
├── /types          # TypeScript types and interfaces
├── /config         # Application configuration
└── /tests          # Unit and integration tests
```

## Mobile (Flutter)
```
/lib
├── /core           # Constants, errors, network, utils
├── /features       # Features by domain (Clean Architecture)
│   └── /[feature]
│       ├── /data          # Datasources, models, repositories impl
│       ├── /domain        # Entities, repositories interfaces, usecases
│       └── /presentation  # BLoC, pages, widgets
├── /shared         # Shared widgets and theme
├── /l10n           # Translations (ARB)
└── /config         # Routes (GoRouter), injection (get_it)
/test               # Unit, widget, integration tests
```

## Backend (Python)
```
/src
├── /api            # FastAPI/Flask routes
├── /core           # Config, security, dependencies
├── /models         # SQLAlchemy/Pydantic models
├── /schemas        # Pydantic DTOs
├── /services       # Business logic
├── /repositories   # Data access
└── /utils          # Utility functions
/tests              # pytest tests
pyproject.toml      # Project config (deps, tools)
```

## Backend (Go)
```
/cmd
└── /app            # Entry point (main.go)
/internal
├── /api            # HTTP handlers
├── /domain         # Entities, interfaces
├── /service        # Business logic
├── /repository     # Data access
└── /config         # Configuration
/pkg                # External reusable code
go.mod              # Dependencies
go.sum              # Checksums
```
