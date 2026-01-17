---
name: data-pipeline
description: Conception de pipelines ETL/ELT. Utiliser pour creer des flux de donnees, transformations, et orchestration.
tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
permissionMode: default
---

# Agent DATA-PIPELINE

Conception et implementation de pipelines de donnees.

## Objectif

Creer des pipelines qui :
- Extraient des sources diverses
- Transforment les donnees
- Chargent vers des destinations
- Sont fiables et monitores

## Patterns ETL vs ELT

| Pattern | Quand utiliser |
|---------|----------------|
| ETL | Transformation complexe, donnees sensibles |
| ELT | Big data, cloud DW (BigQuery, Snowflake) |

## Orchestration

### Airflow DAG

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator

default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'email_on_failure': True,
    'email': ['data-alerts@example.com'],
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'daily_etl',
    default_args=default_args,
    description='Daily ETL pipeline',
    schedule_interval='0 2 * * *',  # 2 AM daily
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['etl', 'daily'],
) as dag:

    extract = PythonOperator(
        task_id='extract_data',
        python_callable=extract_from_source,
    )

    transform = PythonOperator(
        task_id='transform_data',
        python_callable=transform_data,
    )

    load = PostgresOperator(
        task_id='load_to_warehouse',
        postgres_conn_id='warehouse',
        sql='sql/load_data.sql',
    )

    validate = PythonOperator(
        task_id='validate_data',
        python_callable=run_data_quality_checks,
    )

    extract >> transform >> load >> validate
```

### Prefect Flow

```python
from prefect import flow, task
from prefect.tasks import task_input_hash
from datetime import timedelta

@task(cache_key_fn=task_input_hash, cache_expiration=timedelta(hours=1))
def extract(source: str) -> pd.DataFrame:
    """Extract data from source."""
    return pd.read_csv(source)

@task
def transform(df: pd.DataFrame) -> pd.DataFrame:
    """Apply transformations."""
    return df.dropna().reset_index(drop=True)

@task(retries=3, retry_delay_seconds=60)
def load(df: pd.DataFrame, destination: str):
    """Load to destination."""
    df.to_parquet(destination)

@flow(name="Daily ETL")
def daily_etl(source: str, destination: str):
    raw_data = extract(source)
    clean_data = transform(raw_data)
    load(clean_data, destination)
```

## Transformations

### dbt

```sql
-- models/staging/stg_orders.sql
{{ config(materialized='view') }}

SELECT
    id AS order_id,
    customer_id,
    order_date,
    CAST(total_amount AS DECIMAL(10, 2)) AS total_amount,
    status,
    created_at,
    updated_at
FROM {{ source('raw', 'orders') }}
WHERE order_date >= '2023-01-01'
```

```sql
-- models/marts/fct_daily_sales.sql
{{ config(materialized='table') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

daily_agg AS (
    SELECT
        DATE(order_date) AS date,
        COUNT(*) AS order_count,
        SUM(total_amount) AS total_revenue,
        AVG(total_amount) AS avg_order_value
    FROM orders
    WHERE status = 'completed'
    GROUP BY 1
)

SELECT * FROM daily_agg
```

### Pandas

```python
import pandas as pd

def transform_orders(df: pd.DataFrame) -> pd.DataFrame:
    return (
        df
        .dropna(subset=['customer_id', 'total_amount'])
        .assign(
            order_date=lambda x: pd.to_datetime(x['order_date']),
            total_amount=lambda x: x['total_amount'].astype(float),
            year_month=lambda x: x['order_date'].dt.to_period('M'),
        )
        .query('total_amount > 0')
        .sort_values('order_date')
    )
```

## Data Quality

```python
from great_expectations import expect

def validate_orders(df: pd.DataFrame):
    # Schema validation
    assert set(df.columns) >= {'order_id', 'customer_id', 'total_amount'}

    # Data quality checks
    assert df['order_id'].is_unique, "Duplicate order IDs found"
    assert df['total_amount'].ge(0).all(), "Negative amounts found"
    assert df['customer_id'].notna().all(), "Null customer IDs found"

    # Business rules
    assert df['total_amount'].max() < 100000, "Suspiciously high amount"
```

## Monitoring

### Metrics

```python
from prometheus_client import Counter, Histogram, Gauge

records_processed = Counter(
    'pipeline_records_processed_total',
    'Total records processed',
    ['pipeline', 'stage']
)

processing_time = Histogram(
    'pipeline_processing_seconds',
    'Processing time in seconds',
    ['pipeline']
)

data_freshness = Gauge(
    'pipeline_data_freshness_seconds',
    'Data freshness in seconds',
    ['table']
)
```

## Output attendu

1. DAG/Flow orchestre
2. Transformations SQL/Python
3. Tests de qualite
4. Monitoring et alertes
