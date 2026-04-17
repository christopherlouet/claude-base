---
sidebar_position: 4
title: "data-pipeline"
description: "Conception de pipelines ETL/ELT. Declencher quand l'utilisateur veut creer des flux de donnees, transformations, ou orchestration."
tags:
  - "skill"
  - "fork"
---

# Skill: data-pipeline

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Conception de pipelines ETL/ELT. Declencher quand l'utilisateur veut creer des flux de donnees, transformations, ou orchestration.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `data`, `pipeline` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux data..."_
- _"Je veux pipeline..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Example: ETL Pipeline

# Example: ETL Pipeline

## Scenario
Build a pipeline to extract orders from a PostgreSQL database, transform for analytics, and load into a data warehouse.

## Pipeline Architecture

```
Source (PostgreSQL) -> Extract -> Transform -> Validate -> Load (BigQuery)
                                                  |
                                           Dead Letter Queue
```

## Extract

```python
# pipeline/extract.py
import pandas as pd
from sqlalchemy import create_engine

def extract_orders(since: str, until: str) -> pd.DataFrame:
    """Extract orders within date range from source DB."""
    engine = create_engine(os.environ['SOURCE_DATABASE_URL'])
    query = """
        SELECT o.id, o.user_id, o.total, o.status, o.created_at,
               u.country, u.signup_date
        FROM orders o
        JOIN users u ON o.user_id = u.id
        WHERE o.created_at BETWEEN %(since)s AND %(until)s
    """
    df = pd.read_sql(query, engine, params={'since': since, 'until': until})
    logger.info(f"Extracted {len(df)} orders from {since} to {until}")
    return df
```

## Transform

```python
# pipeline/transform.py
def transform_orders(df: pd.DataFrame) -> pd.DataFrame:
    """Clean and enrich order data for analytics."""
    # Clean
    df = df.dropna(subset=['user_id', 'total'])
    df['total'] = df['total'].clip(lower=0)

    # Enrich
    df['order_date'] = pd.to_datetime(df['created_at']).dt.date
    df['days_since_signup'] = (
        pd.to_datetime(df['created_at']) - pd.to_datetime(df['signup_date'])
    ).dt.days
    df['order_bucket'] = pd.cut(
        df['total'], bins=[0, 25, 100, 500, float('inf')],
        labels=['small', 'medium', 'large', 'enterprise']
    )

    # Aggregate
    daily = df.groupby(['order_date', 'country', 'order_bucket']).agg(
        order_count=('id', 'count'),
        revenue=('total', 'sum'),
        avg_order_value=('total', 'mean'),
    ).reset_index()

    return daily
```

## Validate

```python
# pipeline/validate.py
def validate(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Split into valid rows and invalid rows (dead letter)."""
    invalid_mask = (
        df['revenue'].isna() |
        (df['order_count'] <= 0) |
        (df['revenue'] < 0)
    )
    valid = df[~invalid_mask]
    dead_letter = df[invalid_mask]

    if len(dead_letter) > 0:
        logger.warn(f"{len(dead_letter)} rows sent to dead letter queue")

    return valid, dead_letter
```

## Load

```python
# pipeline/load.py
from google.cloud import bigquery

def load_to_bigquery(df: pd.DataFrame, table_id: str):
    """Load validated data to BigQuery with upsert."""
    client = bigquery.Client()
    job_config = bigquery.LoadJobConfig(
        write_disposition='WRITE_APPEND',
        schema_update_options=[bigquery.SchemaUpdateOption.ALLOW_FIELD_ADDITION],
    )
    job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
    job.result()  # Wait for completion
    logger.info(f"Loaded {len(df)} rows to {table_id}")
```

## Orchestration

```python
# pipeline/run.py
def run_daily_pipeline(execution_date: str):
    raw = extract_orders(since=execution_date, until=next_day(execution_date))
    transformed = transform_orders(raw)
    valid, dead_letter = validate(transformed)
    load_to_bigquery(valid, 'analytics.daily_orders')
    if len(dead_letter) > 0:
        load_to_bigquery(dead_letter, 'analytics.dead_letter_orders')
```

## Key Decisions

- **Parameterized queries**: Prevent SQL injection, enable date-range backfills
- **Dead letter queue**: Invalid rows saved for investigation, not silently dropped
- **Aggregation in transform**: Reduce row count before loading (cost optimization)
- **Idempotent loads**: Date-partitioned tables allow safe re-runs
- **Pandas over Spark**: Dataset fits in memory (< 1M rows/day); Spark for larger scale



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
