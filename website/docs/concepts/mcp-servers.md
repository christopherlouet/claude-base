---
sidebar_position: 7
title: MCP Servers
description: Comprendre les serveurs MCP (Model Context Protocol)
---

# MCP Servers

> Extensions via le Model Context Protocol pour etendre les capacites de Claude

## Qu'est-ce que MCP ?

Le **Model Context Protocol (MCP)** est un protocole ouvert d'Anthropic qui permet d'etendre les capacites de Claude avec des serveurs externes.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  Claude Code                                                   │
│       │                                                        │
│       │  MCP Protocol                                          │
│       ▼                                                        │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                    MCP Servers                          │  │
│  │                                                         │  │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐          │  │
│  │  │filesystem │  │  github   │  │  memory   │          │  │
│  │  │           │  │           │  │           │          │  │
│  │  │ Acces     │  │ API       │  │ Memoire   │          │  │
│  │  │ fichiers  │  │ GitHub    │  │ persistante│          │  │
│  │  └───────────┘  └───────────┘  └───────────┘          │  │
│  │                                                         │  │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐          │  │
│  │  │ postgres  │  │  fetch    │  │ puppeteer │          │  │
│  │  │           │  │           │  │           │          │  │
│  │  │ Base de   │  │ Requetes  │  │ Navigateur│          │  │
│  │  │ donnees   │  │ HTTP      │  │ headless  │          │  │
│  │  └───────────┘  └───────────┘  └───────────┘          │  │
│  │                                                         │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Configuration

Les serveurs MCP sont configures dans `.mcp.json` a la racine du projet:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "/path/to/allowed/dir"],
      "enabled": true
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_xxxx"
      },
      "enabled": true
    }
  }
}
```

## Serveurs disponibles

### Serveurs officiels Anthropic

| Serveur | Description | Package |
|---------|-------------|---------|
| `filesystem` | Acces avance aux fichiers | `@anthropic/mcp-server-filesystem` |
| `github` | Integration GitHub | `@anthropic/mcp-server-github` |
| `memory` | Memoire persistante | `@anthropic/mcp-server-memory` |
| `fetch` | Requetes HTTP | `@anthropic/mcp-server-fetch` |
| `postgres` | Base PostgreSQL | `@anthropic/mcp-server-postgres` |
| `sqlite` | Base SQLite | `@anthropic/mcp-server-sqlite` |
| `puppeteer` | Automatisation navigateur | `@anthropic/mcp-server-puppeteer` |

### Serveurs communautaires

| Serveur | Description | Source |
|---------|-------------|--------|
| `notion` | Integration Notion | Community |
| `slack` | Integration Slack | Community |
| `linear` | Integration Linear | Community |

## Exemples de configuration

### Filesystem

Acces etendu au systeme de fichiers:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic/mcp-server-filesystem",
        "/home/user/projects",
        "/home/user/documents"
      ],
      "enabled": true
    }
  }
}
```

**Capacites:**
- Lire/ecrire des fichiers en dehors du projet
- Naviguer dans l'arborescence
- Rechercher des fichiers

### GitHub

Integration complete avec GitHub:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_xxxxxxxxxxxx"
      },
      "enabled": true
    }
  }
}
```

**Capacites:**
- Creer des issues et PRs
- Lire le contenu des repos
- Gerer les branches
- Voir les workflows

### Memory

Memoire persistante entre sessions:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-memory"],
      "enabled": true
    }
  }
}
```

**Capacites:**
- Sauvegarder des informations
- Retrouver des contextes precedents
- Creer un graphe de connaissances

### PostgreSQL

Connexion a une base PostgreSQL:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/db"
      },
      "enabled": true
    }
  }
}
```

**Capacites:**
- Executer des requetes SQL
- Explorer le schema
- Analyser les donnees

### Fetch

Requetes HTTP externes:

```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-fetch"],
      "enabled": true
    }
  }
}
```

**Capacites:**
- GET/POST/PUT/DELETE
- Headers personnalises
- Gestion des cookies

### Puppeteer

Automatisation navigateur:

```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-puppeteer"],
      "enabled": true
    }
  }
}
```

**Capacites:**
- Naviguer sur des pages web
- Prendre des screenshots
- Executer du JavaScript
- Remplir des formulaires

## Structure de configuration

### Format complet

```json
{
  "mcpServers": {
    "nom-du-serveur": {
      "command": "commande",
      "args": ["arg1", "arg2"],
      "env": {
        "VAR": "valeur"
      },
      "enabled": true
    }
  }
}
```

### Champs

| Champ | Description | Obligatoire |
|-------|-------------|-------------|
| `command` | Commande a executer | Oui |
| `args` | Arguments de la commande | Non |
| `env` | Variables d'environnement | Non |
| `enabled` | Activer/desactiver | Non (defaut: true) |

## Activer/Desactiver

### Via le fichier

```json
{
  "mcpServers": {
    "github": {
      "enabled": false  // Desactive
    }
  }
}
```

### Configuration recommandee pour claude-socle

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "."],
      "enabled": false
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-memory"],
      "enabled": false
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": ""
      },
      "enabled": false
    }
  }
}
```

## Creer un serveur MCP

### Structure de base

```typescript
import { Server } from '@anthropic/mcp-server';

const server = new Server({
  name: 'mon-serveur',
  version: '1.0.0',
});

// Definir des outils
server.tool('mon_outil', {
  description: 'Description de l\'outil',
  parameters: {
    type: 'object',
    properties: {
      param1: { type: 'string' }
    }
  },
  handler: async (params) => {
    // Implementation
    return { result: '...' };
  }
});

server.start();
```

### Documentation officielle

- [MCP Specification](https://github.com/anthropics/mcp)
- [MCP Servers officiels](https://github.com/anthropics/mcp-servers)

## Securite

### Bonnes pratiques

1. **Tokens en variables d'environnement**
   ```json
   {
     "env": {
       "GITHUB_TOKEN": "${GITHUB_TOKEN}"
     }
   }
   ```

2. **Restreindre les chemins filesystem**
   ```json
   {
     "args": ["-y", "@anthropic/mcp-server-filesystem", "/chemin/specifique"]
   }
   ```

3. **Desactiver les serveurs non utilises**
   ```json
   {
     "enabled": false
   }
   ```

4. **Ne pas commiter les secrets**
   ```gitignore
   # .gitignore
   .mcp.json.local
   ```

### Risques

| Serveur | Risque | Mitigation |
|---------|--------|------------|
| `filesystem` | Acces fichiers sensibles | Limiter les chemins |
| `postgres` | Acces base de donnees | Utilisateur read-only |
| `puppeteer` | Execution de code | Sandboxing |

---

## Voir aussi

- [Hooks](./hooks) - Actions pre/post tool
- [Architecture](/docs/intro/architecture) - Vue d'ensemble
- [MCP GitHub](https://github.com/anthropics/mcp) - Documentation officielle
