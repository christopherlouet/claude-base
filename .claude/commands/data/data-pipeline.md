# Agent DATA-PIPELINE

Design and implement ETL/ELT data pipelines.

## Request context
$ARGUMENTS

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
| `/dev:dev-tdd` | Test the pipeline |

---

IMPORTANT: Always validate data at each step.

YOU MUST implement robust error handling (retry, DLQ).

NEVER lose data - use checkpoints and idempotence.

Think hard about pipeline scalability and maintainability.

## See also

The orchestrator and transformation vendors publish their own skills — install the one matching the stack (recipe: `docs/recipes/recommended-vendor-skills.md` §"Stack-specific"):

- **Airflow** — [`astronomer/agents`](https://github.com/astronomer/agents) (Apache-2.0, pin `1ec1a1fa`): `authoring-dags`, `testing-dags`, `debugging-dags`, `migrating-airflow-2-to-3`. Some of its other skills drive Astro, Astronomer's paid platform.
- **Dagster** — [`dagster-io/skills`](https://github.com/dagster-io/skills) `plugins/dagster/skills/dagster-expert` (Apache-2.0, `v1.13.25`). Its description says to use it for any "data pipelines" task: install it only in Dagster projects.
- **dbt** — [`dbt-labs/dbt-agent-skills`](https://github.com/dbt-labs/dbt-agent-skills) `skills/dbt/skills/*` (Apache-2.0, pin `168a2b0b`): models, tests and unit tests, documentation, semantic layer, mesh; `skills/dbt-migration/` for upgrades.

The tool choice (orchestrator, warehouse, batch vs streaming) stays with this resource.
