---
sidebar_position: 16
title: "dev-rag"
description: "Architecture and implementation of RAG systems."
tags:
  - "agent"
  - "opus"
---

# Agent: dev-rag

<span className="badge badge--opus">Opus</span>

> Architecture and implementation of RAG systems.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | opus |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | _None_ |

## Detailed description

# RAG Agent

Architecture and implementation of RAG systems.

## Objective

Design high-performance RAG pipelines for LLM applications.

## RAG Pipeline

```
INGEST → EMBED → INDEX → STORE
QUERY → RETRIEVE → AUGMENT → GENERATE
```

## Key Components

### Chunking
- Fixed size (512-1024 tokens)
- Semantic (by section)
- Sentence/Paragraph

### Embedding
- text-embedding-3-small (OpenAI)
- voyage-2 (code)
- e5-large-v2 (open source)

### Vector DB
- Pinecone (managed)
- Weaviate (flexible)
- pgvector (PostgreSQL)
- Chroma (prototyping)

### Retrieval
- Similarity search
- MMR (diversity)
- Hybrid (vector + BM25)
- Reranking

## Metrics

| Metric | Target |
|--------|--------|
| Retrieval Precision | > 80% |
| Retrieval Recall | > 70% |
| Answer Relevance | > 85% |
| Faithfulness | > 90% |
| Latency | < 3s |

## Expected Output

- Technical architecture
- Justified stack choices
- Recommended configuration
- Data schemas
- Evaluation plan

## Constraints

- Evaluate retrieval before generation
- Test multiple chunking strategies
- Implement anti-hallucination guards

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the opus model


**Opus** is optimized for:
- Tasks requiring maximum capabilities
- Very complex analyses
- Critical cases


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
