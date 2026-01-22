---
name: doc-generate
description: Generation de documentation technique. Declencher quand l'utilisateur veut creer README, docs API, ou guides.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# Documentation Generation

## README Structure

```markdown
# Project Name

> Short description

[![CI](badge)](link) [![Coverage](badge)](link)

## Features

- Feature 1
- Feature 2

## Quick Start

\`\`\`bash
npm install
npm run dev
\`\`\`

## Documentation

- [Getting Started](docs/getting-started.md)
- [API Reference](docs/api.md)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT
```

## API Documentation

```markdown
## POST /api/users

Create a new user.

**Request:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | User email |
| name | string | Yes | User name |

**Response:**

\`\`\`json
{
  "id": "uuid",
  "email": "user@example.com",
  "name": "John"
}
\`\`\`

**Errors:**

| Status | Description |
|--------|-------------|
| 400 | Validation error |
| 409 | Email already exists |
```

## Principes

- Exemples de code fonctionnels
- Tableaux pour les parametres
- Schemas de requete/reponse
- Liste des erreurs possibles
- Liens internes pour navigation
