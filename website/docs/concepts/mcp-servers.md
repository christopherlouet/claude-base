---
sidebar_position: 7
title: MCP Servers
description: Understand MCP (Model Context Protocol) servers
---

# MCP Servers

> Extensions via the Model Context Protocol to extend Claude's capabilities

## What is MCP?

The **Model Context Protocol (MCP)** is an open protocol from Anthropic that allows extending Claude's capabilities with external servers.

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
│  │  │ File      │  │ GitHub    │  │ Persistent│          │  │
│  │  │ access    │  │ API       │  │ memory    │          │  │
│  │  └───────────┘  └───────────┘  └───────────┘          │  │
│  │                                                         │  │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐          │  │
│  │  │ postgres  │  │  fetch    │  │ puppeteer │          │  │
│  │  │           │  │           │  │           │          │  │
│  │  │ Database  │  │ HTTP      │  │ Headless  │          │  │
│  │  │           │  │ requests  │  │ browser   │          │  │
│  │  └───────────┘  └───────────┘  └───────────┘          │  │
│  │                                                         │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Configuration

MCP servers are configured in `.mcp.json` at the root of the project:

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

## Available servers

### Official Anthropic servers

| Server | Description | Package |
|---------|-------------|---------|
| `filesystem` | Advanced file access | `@anthropic/mcp-server-filesystem` |
| `github` | GitHub integration | `@anthropic/mcp-server-github` |
| `memory` | Persistent memory | `@anthropic/mcp-server-memory` |
| `fetch` | HTTP requests | `@anthropic/mcp-server-fetch` |
| `postgres` | PostgreSQL database | `@anthropic/mcp-server-postgres` |
| `sqlite` | SQLite database | `@anthropic/mcp-server-sqlite` |
| `puppeteer` | Browser automation | `@anthropic/mcp-server-puppeteer` |

### Community servers

| Server | Description | Source |
|---------|-------------|--------|
| `notion` | Notion integration | Community |
| `slack` | Slack integration | Community |
| `linear` | Linear integration | Community |

## Configuration examples

### Filesystem

Extended access to the filesystem:

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

**Capabilities:**
- Read/write files outside the project
- Navigate the directory tree
- Search for files

### GitHub

Full integration with GitHub:

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

**Capabilities:**
- Create issues and PRs
- Read repo content
- Manage branches
- View workflows

### Memory

Persistent memory across sessions:

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

**Capabilities:**
- Save information
- Retrieve previous contexts
- Build a knowledge graph

### PostgreSQL

Connection to a PostgreSQL database:

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

**Capabilities:**
- Run SQL queries
- Explore the schema
- Analyze data

### Fetch

External HTTP requests:

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

**Capabilities:**
- GET/POST/PUT/DELETE
- Custom headers
- Cookie handling

### Puppeteer

Browser automation:

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

**Capabilities:**
- Navigate web pages
- Take screenshots
- Execute JavaScript
- Fill out forms

## Configuration structure

### Full format

```json
{
  "mcpServers": {
    "server-name": {
      "command": "command",
      "args": ["arg1", "arg2"],
      "env": {
        "VAR": "value"
      },
      "enabled": true
    }
  }
}
```

### Fields

| Field | Description | Required |
|-------|-------------|-------------|
| `command` | Command to execute | Yes |
| `args` | Command arguments | No |
| `env` | Environment variables | No |
| `enabled` | Enable/disable | No (default: true) |

## Enable/Disable

### Via the file

```json
{
  "mcpServers": {
    "github": {
      "enabled": false  // Disabled
    }
  }
}
```

### Recommended configuration for claude-socle

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

## Create an MCP server

### Basic structure

```typescript
import { Server } from '@anthropic/mcp-server';

const server = new Server({
  name: 'my-server',
  version: '1.0.0',
});

// Define tools
server.tool('my_tool', {
  description: 'Tool description',
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

### Official documentation

- [MCP Specification](https://github.com/anthropics/mcp)
- [Official MCP Servers](https://github.com/anthropics/mcp-servers)

## Security

### Best practices

1. **Tokens as environment variables**
   ```json
   {
     "env": {
       "GITHUB_TOKEN": "${GITHUB_TOKEN}"
     }
   }
   ```

2. **Restrict filesystem paths**
   ```json
   {
     "args": ["-y", "@anthropic/mcp-server-filesystem", "/specific/path"]
   }
   ```

3. **Disable unused servers**
   ```json
   {
     "enabled": false
   }
   ```

4. **Do not commit secrets**
   ```gitignore
   # .gitignore
   .mcp.json.local
   ```

### Risks

| Server | Risk | Mitigation |
|---------|--------|------------|
| `filesystem` | Access to sensitive files | Limit paths |
| `postgres` | Database access | Read-only user |
| `puppeteer` | Code execution | Sandboxing |

---

## See also

- [Hooks](./hooks) - Pre/post tool actions
- [Architecture](/docs/intro/architecture) - Overview
- [MCP GitHub](https://github.com/anthropics/mcp) - Official documentation
