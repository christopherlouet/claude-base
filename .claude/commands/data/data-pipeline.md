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

The orchestrator and transformation vendors publish their own skills — install the one matching the stack, as **skill folders** (recipe: `docs/recipes/recommended-vendor-skills.md` §"Stack-specific"):

- **Airflow** — [`astronomer/agents`](https://github.com/astronomer/agents) (Apache-2.0, pin `1ec1a1fa`): `airflow` (the entry point the others hand off to), `authoring-dags`, `testing-dags`, `debugging-dags`, `migrating-airflow-2-to-3`. They drive Airflow through Astronomer's `af` CLI (`astro-airflow-mcp`, installed unpinned by `uv tool install`) and the Astro CLI for tests — Astronomer tooling, with a paid platform (Astro) behind it.
- **Dagster** — [`dagster-io/skills`](https://github.com/dagster-io/skills) `plugins/dagster/skills/dagster-expert` (Apache-2.0, `v1.13.25` = commit `b08dd8e6`). Its description claims every "data pipelines" task: install it only in Dagster projects. The plugin also registers the remote Dagster+ MCP server (paid); the skill folder alone does not.
- **dbt** — [`dbt-labs/dbt-agent-skills`](https://github.com/dbt-labs/dbt-agent-skills) `skills/dbt/skills/*` (Apache-2.0, pin `168a2b0b`): models, tests and unit tests, documentation, semantic layer, mesh. Not `skills/dbt-migration/`: its upgrade script runs `uvx --from git+…` against an unpinned branch.

The tool choice (orchestrator, warehouse, batch vs streaming) stays with this resource.
