---
name: data-pipeline
description: ETL/ELT pipeline design. Trigger when the user wants to create data flows, transformations, or orchestration.
---

# Data Pipeline

## ETL vs ELT

| Pattern | When to use |
|---------|----------------|
| ETL | Complex transformation, sensitive data |
| ELT | Big data, cloud DW (BigQuery, Snowflake) |

## Airflow DAG

```python
# Airflow 3: authoring API in airflow.sdk; the DAG takes `schedule` (its 2.x predecessor is gone)
from datetime import datetime, timedelta

from airflow.sdk import dag, task


@dag(
    schedule="0 2 * * *",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    default_args={"owner": "data-team", "retries": 3, "retry_delay": timedelta(minutes=5)},
)
def daily_etl():
    @task
    def extract():
        return extract_from_source()

    @task
    def transform(raw):
        return transform_data(raw)

    @task
    def load(clean):
        load_to_warehouse(clean)

    load(transform(extract()))


daily_etl()
```

Classic operators moved to the `standard` provider in Airflow 3: `from airflow.providers.standard.operators.python import PythonOperator`. Passing large data between tasks goes through XCom: return a path or a table name, not the rows.

## dbt Transformation

```sql
-- models/staging/stg_orders.sql
{{ config(materialized='view') }}

SELECT
    id AS order_id,
    customer_id,
    order_date,
    CAST(total AS DECIMAL(10,2)) AS total_amount
FROM {{ source('raw', 'orders') }}
WHERE order_date >= '2023-01-01'
```

## Data Quality

```python
def validate_data(df):
    assert df['order_id'].is_unique, "Duplicate IDs"
    assert df['amount'].ge(0).all(), "Negative amounts"
    assert df['customer_id'].notna().all(), "Null customers"
```
