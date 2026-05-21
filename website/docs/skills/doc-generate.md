---
sidebar_position: 22
title: "doc-generate"
description: "Technical documentation generation. Trigger when the user wants to create a README, API docs, or guides."
tags:
  - "skill"
  - "fork"
---

# Skill: doc-generate

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Technical documentation generation. Trigger when the user wants to create a README, API docs, or guides.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| **Keywords** | `doc`, `generate` |

## Detailed description

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

## Principles

- Working code examples
- Tables for parameters
- Request/response schemas
- List of possible errors
- Internal links for navigation

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to doc..."_
- _"I want to generate..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


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

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
