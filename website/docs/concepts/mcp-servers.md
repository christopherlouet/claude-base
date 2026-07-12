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

MCP servers are configured in `.mcp.json` at the root of the project. It ships empty (`{"mcpServers": {}}`); a server is active if and only if its block is present here. There is no per-server `"enabled"` flag — copy the block you want from `.mcp.json.example` into `.mcp.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_xxxx"
      }
    }
  }
}
```

## Available servers

### Official servers

| Server | Description | Package |
|---------|-------------|---------|
| `filesystem` | Advanced file access | `@modelcontextprotocol/server-filesystem` |
| `github` | GitHub integration | `@modelcontextprotocol/server-github` |
| `memory` | Persistent memory | `@modelcontextprotocol/server-memory` |
| `fetch` | HTTP requests | `@anthropics/mcp-server-fetch` |
| `postgres` | PostgreSQL database | `@modelcontextprotocol/server-postgres` |
| `sqlite` | SQLite database | `@anthropics/mcp-server-sqlite` |
| `puppeteer` | Browser automation | `@anthropics/mcp-server-puppeteer` |

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
        "@modelcontextprotocol/server-filesystem",
        "/home/user/projects",
        "/home/user/documents"
      ]
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
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_xxxxxxxxxxxx"
      }
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
      "args": ["-y", "@modelcontextprotocol/server-memory"]
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
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/db"
      }
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
      "args": ["-y", "@anthropics/mcp-server-fetch"]
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
      "args": ["-y", "@anthropics/mcp-server-puppeteer"]
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
      }
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

## Enable/Disable

There is no per-server `"enabled"` flag. A server is active **if and only if** its block is present in `.mcp.json`. Enabling and disabling are copy/delete operations:

- **Enable** — copy the server's block from `.mcp.json.example` into the `mcpServers` object of `.mcp.json`, then provide any referenced env vars.
- **Disable** — remove that server's block from `.mcp.json`.

### Recommended configuration for claude-base

`.mcp.json` ships empty so no server runs until you opt in:

```json
{
  "mcpServers": {}
}
```

To enable, for example, `filesystem`, copy its block from `.mcp.json.example`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    }
  }
}
```

## Create an MCP server

### Basic structure

```typescript
import { Server } from '@anthropics/mcp-server';

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
     "args": ["-y", "@modelcontextprotocol/server-filesystem", "/specific/path"]
   }
   ```

3. **Disable unused servers** — keep `.mcp.json` minimal; remove the block of any server you are not using (there is no `"enabled": false` toggle).

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
