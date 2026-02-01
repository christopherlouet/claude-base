# Structure du Projet

## Web (React/Node)
```
/src
├── /components     # Composants UI réutilisables
├── /services       # Logique métier et appels API
├── /hooks          # Custom hooks React
├── /utils          # Fonctions utilitaires pures
├── /types          # Types et interfaces TypeScript
├── /config         # Configuration de l'application
└── /tests          # Tests unitaires et d'intégration
```

## Mobile (Flutter)
```
/lib
├── /core           # Constantes, erreurs, réseau, utils
├── /features       # Features par domaine (Clean Architecture)
│   └── /[feature]
│       ├── /data          # Datasources, models, repositories impl
│       ├── /domain        # Entities, repositories interfaces, usecases
│       └── /presentation  # BLoC, pages, widgets
├── /shared         # Widgets et thème partagés
├── /l10n           # Traductions (ARB)
└── /config         # Routes (GoRouter), injection (get_it)
/test               # Tests unitaires, widget, integration
```

## Backend (Python)
```
/src
├── /api            # Routes FastAPI/Flask
├── /core           # Config, security, dependencies
├── /models         # SQLAlchemy/Pydantic models
├── /schemas        # Pydantic DTOs
├── /services       # Logique métier
├── /repositories   # Accès données
└── /utils          # Fonctions utilitaires
/tests              # Tests pytest
pyproject.toml      # Config projet (deps, tools)
```

## Backend (Go)
```
/cmd
└── /app            # Point d'entrée (main.go)
/internal
├── /api            # Handlers HTTP
├── /domain         # Entities, interfaces
├── /service        # Logique métier
├── /repository     # Accès données
└── /config         # Configuration
/pkg                # Code réutilisable externe
go.mod              # Dépendances
go.sum              # Checksums
```
