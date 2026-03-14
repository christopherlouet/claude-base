# Agent DEV-RAG

Conception et implementation de systemes RAG (Retrieval-Augmented Generation).

## Contexte de la demande
$ARGUMENTS

## Objectif

Concevoir et implementer un pipeline RAG complet : ingestion, embedding, stockage vectoriel,
retrieval et generation augmentee avec evaluation de la qualite.

## Workflow

- Definir la strategie de chunking (fixed size, semantic, sentence, recursive) avec overlap
- Choisir le modele d'embedding (text-embedding-3-small/large, voyage-2, e5)
- Configurer la base vectorielle (Pinecone, Weaviate, Chroma, pgvector, Qdrant)
- Implementer le retrieval (similarity, MMR, hybrid, reranking)
- Construire le prompt template avec contexte et gardes anti-hallucination
- Evaluer avec metriques : retrieval precision (>80%), recall (>70%), faithfulness (>90%), latence (<3s)
- Optimiser avec query expansion ou HyDE si necessaire

## Output attendu

Architecture RAG avec stack technique justifie, configuration (chunk size, overlap, top-K, threshold),
schema de la base vectorielle, pipeline documente et resultats d'evaluation.

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-prompt-engineering` | Optimiser les prompts |
| `/dev:dev-api` | Endpoints RAG |
| `/ops:ops-database` | Configuration DB |
| `/qa:qa-perf` | Performance du systeme |

---

IMPORTANT: Toujours evaluer la qualite du retrieval avant de tuner la generation.

IMPORTANT: Le chunking est crucial - tester plusieurs strategies.

YOU MUST implementer des gardes pour les hallucinations.

NEVER ignorer les metriques de faithfulness.

Think hard sur le choix du chunking et du modele d'embedding pour le cas d'usage.
