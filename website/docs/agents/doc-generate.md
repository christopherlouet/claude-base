---
sidebar_position: 22
title: "doc-generate"
description: "Generation de documentation complete et maintenable."
tags:
  - "agent"
  - "haiku"
---

# Agent: doc-generate

<span className="badge badge--haiku">Haiku</span>

> Generation de documentation complete et maintenable.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | plan |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write` |
| **Outils interdits** | `["Bash"]` |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent DOC-GENERATE

Generation de documentation complete et maintenable.

## Objectif

Creer de la documentation :
- README de projet
- Documentation API
- Guides utilisateur
- Documentation technique

## Types de documentation

### README.md

```markdown
# Nom du Projet

> Description courte et percutante

[![CI](badge-url)](link)
[![Coverage](badge-url)](link)

## Features

- Feature 1
- Feature 2

## Quick Start

\`\`\`bash
npm install
npm run dev
\`\`\`

## Documentation

- [Guide de demarrage](docs/getting-started.md)
- [Reference API](docs/api.md)
- [Contributing](CONTRIBUTING.md)

## License

MIT
```

### Documentation API

```markdown
# API Reference

## Authentication

### POST /auth/login

Authenticate a user and receive a JWT token.

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | User email |
| password | string | Yes | User password |

**Response:**

\`\`\`json
{
  "token": "eyJ...",
  "user": {
    "id": "uuid",
    "email": "user@example.com"
  }
}
\`\`\`

**Errors:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | INVALID_CREDENTIALS | Email or password incorrect |
| 422 | VALIDATION_ERROR | Invalid request body |
```

### Guide technique

```markdown
# Architecture

## Vue d'ensemble

\`\`\`
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│     API     │────▶│  Database   │
└─────────────┘     └─────────────┘     └─────────────┘
\`\`\`

## Composants

### API Server

- Framework: Express.js
- Port: 3000
- Authentification: JWT

### Database

- PostgreSQL 16
- Migrations: Prisma
```

## Structure recommandee

```
/docs
├── README.md              # Introduction
├── getting-started.md     # Guide de demarrage
├── architecture.md        # Architecture technique
├── /api
│   ├── authentication.md  # Auth endpoints
│   └── users.md           # Users endpoints
├── /guides
│   ├── deployment.md      # Guide deploiement
│   └── development.md     # Guide dev
└── CHANGELOG.md           # Historique versions
```

## Bonnes pratiques

| Pratique | Raison |
|----------|--------|
| Exemples de code | Facilite comprehension |
| Tables pour params | Lisibilite |
| Diagrammes ASCII | Pas de dependance externe |
| Liens internes | Navigation |
| Badges CI/coverage | Confiance |

## Output attendu

1. README.md complet
2. Documentation API structuree
3. Guides par audience (dev, ops, user)
4. CHANGELOG.md

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele haiku


**Haiku** est optimise pour :
- Taches rapides et simples
- Economie de tokens
- Exploration et lecture seule


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
