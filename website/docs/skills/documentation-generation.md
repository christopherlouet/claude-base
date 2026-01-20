---
sidebar_position: 11
title: "documentation-generation"
description: "Generation de documentation technique. Declencher quand l'utilisateur veut creer README, docs API, ou guides."
tags:
  - "skill"
  - "fork"
---

# Skill: documentation-generation

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Generation de documentation technique. Declencher quand l'utilisateur veut creer README, docs API, ou guides.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| **Mots-cles** | `documentation`, `generation`, `uuid`, `email`, `user@example.com`, `name`, `john` |

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

- _"Je veux documentation..."_
- _"Je veux generation..."_
- _"Je veux uuid..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
