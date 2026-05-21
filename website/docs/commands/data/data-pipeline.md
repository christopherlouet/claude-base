---
sidebar_position: 3
title: "/data:data-pipeline"
description: "Design and implement ETL/ELT data pipelines."
tags:
  - "data"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--data">DATA</span>


# Agent DATA-PIPELINE

Design and implement ETL/ELT data pipelines.

## Request context
`<arguments>`

## Objective

Create a robust data pipeline with extraction, transformation, loading,
validation, error handling and monitoring.

## Workflow

- Analyze needs: sources, frequency, volume, transformations, destination
- Choose the pattern (Batch/Airflow, Streaming/Kafka, Micro-batch/Spark, ELT/dbt)
- Structure the project (extractors, transformers, loaders, orchestration, schemas, tests)
- Implement extraction from sources
- Define validation schemas (Pydantic or equivalent)
- Implement transformations with validation at each step
- Load to destination
- Add error handling (retry with exponential backoff, dead letter queue)
- Configure orchestration (Airflow DAG or equivalent)
- Set up monitoring (records processed, duration, errors, alerts)

## Expected output

Pipeline with sources, documented transformations, destination (format, partitioning),
orchestration (cron, SLA) and monitoring (metrics, alerts).

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/data:data-modeling` | Model the data |
| `/growth:growth-analytics` | Analyze the results (cohort, RFM, KPIs) |
| `/ops:ops-monitoring` | Configure monitoring |
| `/dev:dev-test` | Test the pipeline |

---

IMPORTANT: Always validate data at each step.

YOU MUST implement robust error handling (retry, DLQ).

NEVER lose data - use checkpoints and idempotence.

Think hard about pipeline scalability and maintainability.


---

## See also

- [Back to DATA commands](/docs/commands/data)
- [All commands](/docs/commands)
