# Agent DEV-AI-INTEGRATION

Integration de modeles de langage (LLM) et APIs IA dans les applications.

## Contexte
$ARGUMENTS

## APIs Supportees

| Provider | SDK | Modeles Principaux |
|----------|-----|-------------------|
| Anthropic | @anthropic-ai/sdk | Claude 3.5 Sonnet, Claude 3 Opus |
| OpenAI | openai | GPT-4o, GPT-4 Turbo |
| Google | @google/generative-ai | Gemini Pro, Gemini Ultra |
| Mistral | @mistralai/mistralai | Mistral Large, Mistral Medium |
| Cohere | cohere-ai | Command R+, Embed |

## Patterns d'Integration

### 1. Completion Simple

```typescript
import Anthropic from '@anthropic-ai/sdk';

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

async function complete(prompt: string): Promise<string> {
  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    messages: [{ role: 'user', content: prompt }],
  });

  return response.content[0].type === 'text'
    ? response.content[0].text
    : '';
}
```

### 2. Streaming

```typescript
async function* streamComplete(prompt: string) {
  const stream = await anthropic.messages.stream({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    messages: [{ role: 'user', content: prompt }],
  });

  for await (const event of stream) {
    if (event.type === 'content_block_delta' &&
        event.delta.type === 'text_delta') {
      yield event.delta.text;
    }
  }
}
```

### 3. Tool Use / Function Calling

```typescript
const tools = [
  {
    name: 'get_weather',
    description: 'Get current weather for a location',
    input_schema: {
      type: 'object',
      properties: {
        location: { type: 'string', description: 'City name' },
      },
      required: ['location'],
    },
  },
];

const response = await anthropic.messages.create({
  model: 'claude-sonnet-4-20250514',
  max_tokens: 1024,
  tools,
  messages: [{ role: 'user', content: 'What is the weather in Paris?' }],
});
```

### 4. RAG (Retrieval-Augmented Generation)

```typescript
async function ragQuery(query: string) {
  // 1. Embed query
  const queryEmbedding = await embed(query);

  // 2. Search similar documents
  const docs = await vectorStore.similaritySearch(queryEmbedding, 5);

  // 3. Generate response with context
  const context = docs.map(d => d.content).join('\n\n');

  return anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 2048,
    system: `Use the following context to answer questions:\n\n${context}`,
    messages: [{ role: 'user', content: query }],
  });
}
```

## Bonnes Pratiques

### Gestion des Erreurs

```typescript
import { APIError, RateLimitError } from '@anthropic-ai/sdk';

async function safeComplete(prompt: string, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      return await complete(prompt);
    } catch (error) {
      if (error instanceof RateLimitError) {
        await sleep(Math.pow(2, i) * 1000); // Exponential backoff
        continue;
      }
      if (error instanceof APIError) {
        console.error(`API Error: ${error.message}`);
        throw error;
      }
      throw error;
    }
  }
  throw new Error('Max retries exceeded');
}
```

### Caching

```typescript
import { Redis } from 'ioredis';

const redis = new Redis();
const CACHE_TTL = 3600; // 1 hour

async function cachedComplete(prompt: string) {
  const cacheKey = `llm:${hash(prompt)}`;

  const cached = await redis.get(cacheKey);
  if (cached) return JSON.parse(cached);

  const response = await complete(prompt);
  await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(response));

  return response;
}
```

### Rate Limiting

```typescript
import Bottleneck from 'bottleneck';

const limiter = new Bottleneck({
  maxConcurrent: 5,
  minTime: 200, // 5 requests per second
});

const rateLimitedComplete = limiter.wrap(complete);
```

## Securite

| Risque | Mitigation |
|--------|------------|
| Prompt Injection | Sanitization, separation user/system |
| Data Leakage | Ne pas envoyer de donnees sensibles |
| Cost Explosion | Rate limiting, budgets |
| API Key Exposure | Variables d'environnement, secrets manager |

### Validation Input

```typescript
function sanitizeInput(input: string): string {
  // Remove potential injection patterns
  return input
    .replace(/\[INST\]/gi, '')
    .replace(/\[\/INST\]/gi, '')
    .replace(/<\|.*?\|>/g, '')
    .slice(0, 10000); // Max length
}
```

## Monitoring

| Metrique | Description | Seuil |
|----------|-------------|-------|
| Latence | Temps de reponse | < 5s |
| Tokens/requete | Consommation | < 4000 |
| Cout/jour | Budget | < $50 |
| Error rate | Taux d'erreur | < 1% |

```typescript
async function monitoredComplete(prompt: string) {
  const start = Date.now();

  try {
    const response = await complete(prompt);

    metrics.histogram('llm.latency', Date.now() - start);
    metrics.counter('llm.tokens', response.usage.total_tokens);
    metrics.counter('llm.requests.success');

    return response;
  } catch (error) {
    metrics.counter('llm.requests.error');
    throw error;
  }
}
```

## Output Attendu

### Plan d'Integration

```markdown
## Integration IA: [Feature]

### Provider choisi
- **API**: [Anthropic/OpenAI/...]
- **Modele**: [claude-3-sonnet/gpt-4o/...]
- **Raison**: [Cout, performance, fonctionnalites]

### Architecture
[Diagramme ou description]

### Fichiers a creer/modifier
- [ ] src/lib/ai-client.ts
- [ ] src/services/ai-service.ts
- [ ] src/api/ai/route.ts

### Estimation couts
- Tokens/requete: ~[X]
- Requetes/jour: ~[Y]
- Cout mensuel: ~$[Z]

### Risques
| Risque | Mitigation |
|--------|------------|
```

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev-rag` | Systemes RAG |
| `/dev-prompt-engineering` | Optimiser les prompts |
| `/dev-api` | Endpoints API |
| `/ops-monitoring` | Monitoring production |

---

IMPORTANT: Toujours utiliser des variables d'environnement pour les API keys.

IMPORTANT: Ne jamais logger les prompts contenant des donnees utilisateur.

YOU MUST implementer rate limiting et retry logic.

NEVER exposer les cles API dans le code source.
