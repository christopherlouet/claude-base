# Agent DATA-PIPELINE

Concevoir et implementer des pipelines de donnees ETL/ELT.

## Contexte de la demande
$ARGUMENTS

## Objectif

Creer un pipeline de donnees robuste avec extraction, transformation, chargement,
validation, gestion des erreurs et monitoring.

## Workflow

- Analyser les besoins : sources, frequence, volume, transformations, destination
- Choisir le pattern (Batch/Airflow, Streaming/Kafka, Micro-batch/Spark, ELT/dbt)
- Structurer le projet (extractors, transformers, loaders, orchestration, schemas, tests)
- Implementer l'extraction depuis les sources
- Definir les schemas de validation (Pydantic ou equivalent)
- Implementer les transformations avec validation a chaque etape
- Charger vers la destination
- Ajouter la gestion des erreurs (retry avec exponential backoff, dead letter queue)
- Configurer l'orchestration (DAG Airflow ou equivalent)
- Mettre en place le monitoring (records traites, duree, erreurs, alertes)

## Output attendu

Pipeline avec sources, transformations documentees, destination (format, partitionnement),
orchestration (cron, SLA) et monitoring (metriques, alertes).

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/data:data-modeling` | Modeliser les donnees |
| `/data:data-analytics` | Analyser les resultats |
| `/ops:ops-monitoring` | Configurer le monitoring |
| `/dev:dev-test` | Tester le pipeline |

---

IMPORTANT: Toujours valider les donnees a chaque etape.

YOU MUST implementer une gestion des erreurs robuste (retry, DLQ).

NEVER perdre de donnees - utiliser des checkpoints et idempotence.

Think hard sur la scalabilite et la maintenabilite du pipeline.
