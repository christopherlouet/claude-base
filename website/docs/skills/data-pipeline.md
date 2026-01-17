---
sidebar_position: 6
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
| **Mots-cles** | `data`, `pipeline`, `duplicate ids`, `negative amounts`, `null customers` |

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
- _"Je veux duplicate ids..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
