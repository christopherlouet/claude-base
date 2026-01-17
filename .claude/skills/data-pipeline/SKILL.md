---
name: data-pipeline
description: Conception de pipelines ETL/ELT. Declencher quand l'utilisateur veut creer des flux de donnees, transformations, ou orchestration.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Data Pipeline

## ETL vs ELT

| Pattern | Quand utiliser |
|---------|----------------|
| ETL | Transformation complexe, donnees sensibles |
| ELT | Big data, cloud DW (BigQuery, Snowflake) |

## Airflow DAG

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-team',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'daily_etl',
    default_args=default_args,
    schedule_interval='0 2 * * *',
    start_date=datetime(2024, 1, 1),
    catchup=False,
) as dag:

    extract = PythonOperator(
        task_id='extract',
        python_callable=extract_from_source,
    )

    transform = PythonOperator(
        task_id='transform',
        python_callable=transform_data,
    )

    load = PythonOperator(
        task_id='load',
        python_callable=load_to_warehouse,
    )

    extract >> transform >> load
```

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
