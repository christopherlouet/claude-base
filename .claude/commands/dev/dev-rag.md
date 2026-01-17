# Agent RAG

Conception et implementation de systemes RAG (Retrieval-Augmented Generation).

## Contexte
$ARGUMENTS

## Architecture RAG

```
┌─────────────────────────────────────────────────────────────────┐
│                     PIPELINE RAG                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │ INGEST   │───▶│ EMBED    │───▶│ INDEX    │───▶│ STORE    │  │
│  │ Documents│    │ Chunks   │    │ Vectors  │    │ Vector DB│  │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘  │
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │ QUERY    │───▶│ RETRIEVE │───▶│ AUGMENT  │───▶│ GENERATE │  │
│  │ User Q   │    │ Top-K    │    │ Context  │    │ Response │  │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Phase 1: Ingestion des documents

### Chunking strategies

| Strategie | Taille | Usage |
|-----------|--------|-------|
| Fixed size | 512-1024 tokens | Documents homogenes |
| Semantic | Variable | Documents structures |
| Sentence | Par phrase | QA precis |
| Paragraph | Par paragraphe | Contexte large |
| Recursive | Hierarchique | Documents complexes |

### Implementation chunking

```typescript
// Chunking semantique avec overlap
interface ChunkConfig {
  chunkSize: number;      // Taille cible en tokens
  chunkOverlap: number;   // Overlap entre chunks
  separator: string[];    // Separateurs de priorite
}

const config: ChunkConfig = {
  chunkSize: 512,
  chunkOverlap: 50,
  separator: ['\n\n', '\n', '. ', ' ']
};
```

### Metadata enrichment

```typescript
interface ChunkMetadata {
  documentId: string;
  source: string;
  title: string;
  section: string;
  pageNumber?: number;
  createdAt: Date;
  tags: string[];
}
```

## Phase 2: Embedding

### Modeles d'embedding

| Modele | Dimensions | Performance | Usage |
|--------|------------|-------------|-------|
| text-embedding-3-small | 1536 | Rapide | General |
| text-embedding-3-large | 3072 | Meilleur | Precision |
| voyage-2 | 1024 | Excellent | Code |
| e5-large-v2 | 1024 | Open source | Self-hosted |

### Implementation

```typescript
import { OpenAI } from 'openai';

async function embedChunks(chunks: string[]): Promise<number[][]> {
  const openai = new OpenAI();

  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: chunks,
  });

  return response.data.map(d => d.embedding);
}
```

## Phase 3: Vector Database

### Options de stockage

| Solution | Type | Avantages | Cas d'usage |
|----------|------|-----------|-------------|
| Pinecone | Cloud | Managed, scalable | Production |
| Weaviate | Self-hosted/Cloud | GraphQL, hybrid | Flexible |
| Chroma | Local/Cloud | Simple, Python | Prototypage |
| pgvector | PostgreSQL | Integre a PG | Existant PG |
| Qdrant | Self-hosted/Cloud | Performant | High-scale |

### Schema type

```sql
-- pgvector example
CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content TEXT NOT NULL,
  embedding vector(1536),
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX ON documents
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);
```

## Phase 4: Retrieval

### Strategies de recherche

| Strategie | Description | Quand utiliser |
|-----------|-------------|----------------|
| Similarity | Cosine/Euclidean | Standard |
| MMR | Maximal Marginal Relevance | Diversite |
| Hybrid | Vector + BM25 | Precision |
| Reranking | Cross-encoder | Qualite |

### Implementation retrieval

```typescript
interface RetrievalConfig {
  topK: number;           // Nombre de resultats
  threshold: number;      // Score minimum
  filter?: object;        // Filtres metadata
  rerank?: boolean;       // Reranking
}

async function retrieve(
  query: string,
  config: RetrievalConfig
): Promise<Document[]> {
  // 1. Embed query
  const queryEmbedding = await embed(query);

  // 2. Search vector DB
  const results = await vectorDB.search({
    vector: queryEmbedding,
    topK: config.topK * 2, // Over-fetch for reranking
    filter: config.filter,
  });

  // 3. Filter by threshold
  const filtered = results.filter(r => r.score >= config.threshold);

  // 4. Rerank if enabled
  if (config.rerank) {
    return await rerank(query, filtered, config.topK);
  }

  return filtered.slice(0, config.topK);
}
```

## Phase 5: Augmentation & Generation

### Prompt template RAG

```markdown
Tu es un assistant qui repond aux questions en utilisant
UNIQUEMENT les informations fournies dans le contexte ci-dessous.

## Contexte

{context}

## Instructions

- Reponds UNIQUEMENT avec les informations du contexte
- Si l'information n'est pas dans le contexte, dis "Je ne trouve pas cette information dans les documents fournis"
- Cite les sources quand c'est pertinent
- Sois precis et concis

## Question

{question}

## Reponse
```

### Handling edge cases

```typescript
function buildPrompt(context: Document[], question: string): string {
  // Pas de contexte trouve
  if (context.length === 0) {
    return `Je n'ai pas trouve d'information pertinente pour: "${question}"`;
  }

  // Contexte trop long - truncate
  const maxTokens = 3000;
  const truncatedContext = truncateToTokens(context, maxTokens);

  return promptTemplate
    .replace('{context}', formatContext(truncatedContext))
    .replace('{question}', question);
}
```

## Evaluation RAG

### Metriques

| Metrique | Description | Cible |
|----------|-------------|-------|
| Retrieval Precision | Documents pertinents / Total | > 80% |
| Retrieval Recall | Documents pertinents trouves / Total pertinents | > 70% |
| Answer Relevance | Reponse repond a la question | > 85% |
| Faithfulness | Reponse basee sur le contexte | > 90% |
| Latency | Temps de reponse | < 3s |

### Framework d'evaluation

```typescript
interface RAGEvaluation {
  query: string;
  expectedAnswer: string;
  retrievedDocs: Document[];
  generatedAnswer: string;
  metrics: {
    retrievalPrecision: number;
    retrievalRecall: number;
    answerRelevance: number;
    faithfulness: number;
    latencyMs: number;
  };
}
```

## Optimisations avancees

### Query expansion

```typescript
// Generer des variantes de la question
async function expandQuery(query: string): Promise<string[]> {
  const prompt = `Genere 3 reformulations de cette question:
  "${query}"

  Retourne uniquement les reformulations, une par ligne.`;

  const expansions = await llm.complete(prompt);
  return [query, ...expansions.split('\n')];
}
```

### Hypothetical Document Embeddings (HyDE)

```typescript
// Generer un document hypothetique, puis chercher
async function hydeRetrieval(query: string): Promise<Document[]> {
  // 1. Generer document hypothetique
  const hypothetical = await llm.complete(
    `Ecris un passage qui repondrait a: "${query}"`
  );

  // 2. Embed le document hypothetique
  const embedding = await embed(hypothetical);

  // 3. Rechercher des documents similaires
  return vectorDB.search({ vector: embedding, topK: 5 });
}
```

## Output attendu

### Architecture proposee

```markdown
## Architecture RAG

### Stack technique
- **Vector DB**: [Choix + justification]
- **Embedding model**: [Choix + justification]
- **LLM**: [Choix + justification]

### Configuration
- Chunk size: [X] tokens
- Chunk overlap: [X] tokens
- Top-K retrieval: [X]
- Similarity threshold: [X]

### Schema de donnees
[Schema de la base vectorielle]

### Pipeline
[Diagramme du pipeline]
```

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev-prompt-engineering` | Optimiser les prompts |
| `/dev-api` | Endpoints RAG |
| `/ops-database` | Configuration DB |
| `/qa-perf` | Performance du systeme |

---

IMPORTANT: Toujours evaluer la qualite du retrieval avant de tuner la generation.

IMPORTANT: Le chunking est crucial - tester plusieurs strategies.

YOU MUST implementer des gardes pour les hallucinations.

NEVER ignorer les metriques de faithfulness.
