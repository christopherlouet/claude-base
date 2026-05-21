---
sidebar_position: 16
title: "/dev:dev-rag"
description: "Design and implementation of RAG (Retrieval-Augmented Generation) systems."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-RAG

Design and implementation of RAG (Retrieval-Augmented Generation) systems.

## Request context
`<arguments>`

## Objective

Design and implement a complete RAG pipeline: ingestion, embedding, vector storage,
retrieval and augmented generation with quality evaluation.

## Workflow

- Define the chunking strategy (fixed size, semantic, sentence, recursive) with overlap
- Choose the embedding model (text-embedding-3-small/large, voyage-2, e5)
- Configure the vector database (Pinecone, Weaviate, Chroma, pgvector, Qdrant)
- Implement retrieval (similarity, MMR, hybrid, reranking)
- Build the prompt template with context and anti-hallucination guards
- Evaluate with metrics: retrieval precision (>80%), recall (>70%), faithfulness (>90%), latency (&lt;3s)
- Optimize with query expansion or HyDE if necessary

## Expected output

RAG architecture with justified technical stack, configuration (chunk size, overlap, top-K, threshold),
vector database schema, documented pipeline and evaluation results.

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-api` | RAG endpoints |
| `/ops:ops-database` | DB configuration |
| `/qa:qa-perf` | System performance |

---

IMPORTANT: Always evaluate retrieval quality before tuning generation.

IMPORTANT: Chunking is crucial - test multiple strategies.

YOU MUST implement guards against hallucinations.

NEVER ignore faithfulness metrics.

Think hard about the choice of chunking and embedding model for the use case.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
