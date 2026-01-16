# Agent DEV-MCP

Guide pour créer des serveurs MCP (Model Context Protocol) de qualité.

## Contexte
$ARGUMENTS

## Objectif

Créer des serveurs MCP permettant aux LLMs d'interagir avec des services externes
via des tools bien conçus. Support Python (FastMCP) et TypeScript (MCP SDK).

## Qu'est-ce que MCP ?

```
┌─────────────────────────────────────────────────────────────┐
│                    MODEL CONTEXT PROTOCOL                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   LLM (Claude)  ◄──────►  MCP Server  ◄──────►  Service    │
│                   stdio      │            API    externe    │
│                   ou SSE     │                              │
│                              ▼                              │
│                         Tools exposés                       │
│                    (fonctions appelables)                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Workflow en 4 phases

### Phase 1 : Research & Planning

#### 1.1 Principes de design agent-centric

| Principe | Description |
|----------|-------------|
| **Workflows, pas endpoints** | Consolider les opérations (ex: `schedule_event` qui vérifie la dispo ET crée l'event) |
| **Context limité** | Retourner des infos high-signal, pas des dumps exhaustifs |
| **Erreurs actionnables** | Messages qui guident vers la correction |
| **Noms naturels** | Nommer selon la tâche humaine, pas l'API |

#### 1.2 Documentation à consulter

```bash
# Documentation MCP officielle
# Charger via WebFetch: https://modelcontextprotocol.io/llms-full.txt

# SDK Python
# https://github.com/modelcontextprotocol/python-sdk

# SDK TypeScript
# https://github.com/modelcontextprotocol/typescript-sdk
```

#### 1.3 Étudier l'API cible

- [ ] Documentation API complète
- [ ] Authentification requise
- [ ] Rate limiting et pagination
- [ ] Modèles de données et schémas
- [ ] Codes d'erreur

#### 1.4 Plan d'implémentation

```markdown
## Tools à implémenter

| Tool | Priorité | Description |
|------|----------|-------------|
| [nom] | Haute | [description] |

## Utilitaires partagés
- [ ] Helper requêtes API
- [ ] Gestion pagination
- [ ] Formatage réponses
- [ ] Gestion erreurs
```

### Phase 2 : Implementation

#### 2.1 Setup projet Python (FastMCP)

```python
# server.py
from mcp.server.fastmcp import FastMCP
from pydantic import BaseModel, Field

mcp = FastMCP("mon-service")

# Configuration
API_BASE_URL = "https://api.example.com"
CHARACTER_LIMIT = 25000

class UserInput(BaseModel):
    """Input validation avec Pydantic."""
    user_id: str = Field(..., description="ID de l'utilisateur", min_length=1)
    include_details: bool = Field(default=False, description="Inclure les détails")

@mcp.tool()
async def get_user(input: UserInput) -> str:
    """
    Récupère les informations d'un utilisateur.

    Args:
        input: Paramètres de la requête

    Returns:
        Informations utilisateur en JSON ou Markdown

    Raises:
        ValueError: Si l'utilisateur n'existe pas
    """
    # Implementation...
    pass

if __name__ == "__main__":
    mcp.run()
```

#### 2.2 Setup projet TypeScript (MCP SDK)

```typescript
// src/index.ts
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new Server(
  { name: "mon-service", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

// Schema de validation avec Zod
const GetUserSchema = z.object({
  user_id: z.string().min(1).describe("ID de l'utilisateur"),
  include_details: z.boolean().default(false).describe("Inclure les détails"),
}).strict();

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "get_user",
      description: "Récupère les informations d'un utilisateur",
      inputSchema: zodToJsonSchema(GetUserSchema),
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "get_user") {
    const validated = GetUserSchema.parse(args);
    // Implementation...
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
```

#### 2.3 Bonnes pratiques d'implémentation

```python
# ✅ Réponse concise avec option détaillée
@mcp.tool()
async def search_users(
    query: str,
    format: Literal["concise", "detailed"] = "concise",
    limit: int = Field(default=10, le=100)
) -> str:
    results = await api.search(query, limit)

    if format == "concise":
        return "\n".join([f"- {u.name} ({u.id})" for u in results])
    else:
        return json.dumps([u.dict() for u in results], indent=2)

# ✅ Erreur actionnable
except UserNotFoundError:
    return f"User '{user_id}' not found. Try search_users to find valid IDs."

# ✅ Annotations de tool
@mcp.tool(
    annotations={
        "readOnlyHint": True,      # Lecture seule
        "idempotentHint": True,    # Appels répétés = même résultat
        "openWorldHint": True,     # Interagit avec l'extérieur
    }
)
```

#### 2.4 Gestion des erreurs

```python
async def api_request(endpoint: str, method: str = "GET", **kwargs) -> dict:
    """Helper centralisé pour les requêtes API."""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.request(method, f"{API_BASE_URL}/{endpoint}", **kwargs)
            response.raise_for_status()
            return response.json()
    except httpx.HTTPStatusError as e:
        if e.response.status_code == 404:
            raise ResourceNotFoundError(f"Resource not found: {endpoint}")
        elif e.response.status_code == 429:
            raise RateLimitError("Rate limit exceeded. Try again in a few seconds.")
        else:
            raise APIError(f"API error {e.response.status_code}: {e.response.text}")
    except httpx.RequestError as e:
        raise ConnectionError(f"Failed to connect to API: {str(e)}")
```

### Phase 3 : Review & Quality

#### 3.1 Checklist qualité

**Structure**
- [ ] Pas de code dupliqué entre tools
- [ ] Logique partagée extraite en fonctions
- [ ] Opérations similaires = formats similaires

**Types et validation**
- [ ] Pydantic v2 (Python) ou Zod (TypeScript)
- [ ] Contraintes sur les inputs (min/max, regex)
- [ ] Descriptions claires des champs

**Documentation**
- [ ] Docstring/description complète par tool
- [ ] Exemples d'utilisation
- [ ] Documentation des erreurs possibles

**Erreurs**
- [ ] Messages en langage naturel
- [ ] Suggestions d'actions correctives
- [ ] Pas d'exposition de détails techniques internes

#### 3.2 Test du serveur

```bash
# ATTENTION: Les serveurs MCP sont des processus long-running
# Ne pas exécuter directement, utiliser timeout ou tmux

# Python - Vérifier la syntaxe
python -m py_compile server.py

# TypeScript - Build
npm run build

# Test avec timeout
timeout 5s python server.py
```

### Phase 4 : Evaluation

#### 4.1 Créer des questions d'évaluation

Créer 10 questions pour tester l'efficacité du serveur :

```xml
<evaluation>
  <qa_pair>
    <question>Trouve tous les utilisateurs actifs créés cette semaine et retourne leur email</question>
    <answer>john@example.com, jane@example.com</answer>
  </qa_pair>
</evaluation>
```

#### 4.2 Critères des questions

- [ ] Indépendantes les unes des autres
- [ ] Lecture seule uniquement
- [ ] Complexes (plusieurs appels de tools)
- [ ] Réalistes (cas d'usage réels)
- [ ] Vérifiables (réponse unique)

## Structure de projet recommandée

### Python
```
mon-mcp-server/
├── server.py           # Point d'entrée
├── tools/              # Tools par domaine
│   ├── users.py
│   └── projects.py
├── utils/              # Utilitaires
│   ├── api.py
│   └── formatting.py
├── requirements.txt
└── README.md
```

### TypeScript
```
mon-mcp-server/
├── src/
│   ├── index.ts        # Point d'entrée
│   ├── tools/          # Tools par domaine
│   ├── schemas/        # Schemas Zod
│   └── utils/          # Utilitaires
├── package.json
├── tsconfig.json
└── README.md
```

## Output attendu

```markdown
## MCP Server : [Nom du service]

### Configuration
- **Transport**: stdio / SSE
- **Langage**: Python / TypeScript
- **API cible**: [URL]

### Tools implémentés
| Tool | Description | Annotations |
|------|-------------|-------------|
| [nom] | [desc] | readOnly, idempotent |

### Installation
[Instructions d'installation]

### Usage avec Claude
[Configuration claude_desktop_config.json]

### Évaluation
[Résultats des tests d'évaluation]
```

## Agents liés

| Agent | Usage |
|-------|-------|
| `/dev-api` | Si création d'API REST en parallèle |
| `/dev-test` | Tests du serveur MCP |
| `/doc-api-spec` | Documentation OpenAPI de l'API cible |

---

IMPORTANT: Concevoir pour les workflows, pas pour wrapper des endpoints.

YOU MUST valider tous les inputs avec Pydantic (Python) ou Zod (TypeScript).

YOU MUST retourner des erreurs actionnables qui guident l'utilisateur.

NEVER exposer de détails techniques internes dans les messages d'erreur.

Think hard sur les cas d'usage réels avant de définir les tools.
