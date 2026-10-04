# Agent DATA-MODELING

Design and implement data models (schemas, ERD, data warehouse).

## Request context
$ARGUMENTS

## Objective

Design a data model suited to analytical or transactional use cases,
with naming conventions, documentation and quality tests.

## Workflow

- Understand the needs: analytical use cases, business entities, questions to answer, volume
- Choose the type of modeling (OLTP 3NF, Star Schema, Snowflake, Data Vault, Wide Table)
- Define the entities with relations and cardinality
- Apply naming conventions (fact_, dim_, _id, _at, is_, _amount)
- Implement with dbt if applicable (models, tests, YAML documentation)
- Manage Slowly Changing Dimensions (SCD Type 2) if needed
- Document with ERD (dbdiagram.io or draw.io) and data dictionary
- Add quality tests (unique, not_null, accepted_values)

## Expected output

Data model with entities (type, description, estimated volume),
ERD, data dictionary and example queries.

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/data:data-pipeline` | Feed the model |
| `/growth:growth-analytics` | Analyze KPIs on the modeled data |
| `/ops:ops-database` | Optimize performance |

---

IMPORTANT: The model must answer business questions, not the other way around.

YOU MUST document every table and column.

NEVER create a model without understanding the use cases.

Think hard about the model's scalability and maintainability.

## See also

For the dbt implementation of a model, dbt Labs' own skills — [`dbt-labs/dbt-agent-skills`](https://github.com/dbt-labs/dbt-agent-skills) `skills/dbt/skills/*` (Apache-2.0, pin `168a2b0b`) — cover models, tests, documentation and mesh versioning. The modelling itself (3NF, star schema, Data Vault, SCD, ERD, data dictionary) stays here: no vendor covers it tool-agnostically.
