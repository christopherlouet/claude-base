---
sidebar_position: 23
title: "doc-generate"
description: "Generation de documentation technique. Declencher quand l'utilisateur veut creer README, docs API, ou guides."
tags:
  - "skill"
  - "fork"
---

# Skill: doc-generate

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Generation de documentation technique. Declencher quand l'utilisateur veut creer README, docs API, ou guides.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| **Mots-cles** | `doc`, `generate` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux doc..."_
- _"Je veux generate..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Example: API Documentation

# Example: API Documentation

## Scenario
Generate comprehensive API documentation for a user management service.

## Generated Output

### API Reference: User Management

**Base URL**: `https://api.example.com/v1`
**Authentication**: Bearer token in `Authorization` header

---

#### POST /users

Create a new user account.

**Request**
```json
{
  "email": "jane@example.com",
  "name": "Jane Doe",
  "role": "editor"
}
```

**Response 201**
```json
{
  "data": {
    "id": "usr_k8x2m",
    "email": "jane@example.com",
    "name": "Jane Doe",
    "role": "editor",
    "createdAt": "2024-06-15T10:30:00Z"
  }
}
```

**Errors**

| Status | Code | When |
|--------|------|------|
| 400 | `VALIDATION_ERROR` | Missing required fields or invalid email |
| 409 | `CONFLICT` | Email already registered |
| 401 | `UNAUTHORIZED` | Missing or invalid auth token |

---

#### GET /users/:id

Retrieve a user by ID.

**Parameters**

| Name | In | Type | Required | Description |
|------|-----|------|----------|-------------|
| `id` | path | string | Yes | User ID (format: `usr_xxxxx`) |
| `include` | query | string | No | Comma-separated relations: `teams,projects` |

**Response 200**
```json
{
  "data": {
    "id": "usr_k8x2m",
    "email": "jane@example.com",
    "name": "Jane Doe",
    "role": "editor",
    "teams": [
      { "id": "team_abc", "name": "Engineering" }
    ]
  }
}
```

---

#### PATCH /users/:id

Update user fields. Only provided fields are modified.

**Request** (partial update)
```json
{
  "name": "Jane Smith",
  "role": "admin"
}
```

**Response 200**: Updated user object (same format as GET)

---

### Error Response Format

All errors follow a consistent structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "details": [
      { "field": "email", "message": "Must be a valid email address" }
    ]
  }
}
```

### Rate Limits

| Plan | Limit | Window |
|------|-------|--------|
| Free | 100 req | per minute |
| Pro | 1000 req | per minute |
| Enterprise | Custom | Custom |

Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

---

## Documentation Conventions Used

- **Consistent response envelope**: Always `{ "data": ... }` or `{ "error": ... }`
- **Realistic examples**: Plausible data, not `"string"` or `"test"`
- **Error table per endpoint**: Shows when each error occurs
- **Parameter table**: Clearly marks required vs optional, types, and formats
- **Rate limit section**: Essential for API consumers to handle throttling



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
