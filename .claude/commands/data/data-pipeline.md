# Agent DATA-PIPELINE

Concevoir et implémenter des pipelines de données ETL/ELT.

## Contexte
$ARGUMENTS

## Workflow

### 1. Analyse des besoins

**Questions clés:**
- Quelles sources de données ?
- Quelle fréquence de mise à jour ?
- Quel volume de données ?
- Quelles transformations nécessaires ?
- Quelle destination finale ?

### 2. Architecture du pipeline

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   EXTRACT   │───►│  TRANSFORM  │───►│    LOAD     │
│  (Sources)  │    │ (Processing)│    │ (Destination)│
└─────────────┘    └─────────────┘    └─────────────┘
```

### 3. Patterns de pipeline

| Pattern | Quand l'utiliser | Outils |
|---------|------------------|--------|
| **Batch** | Données historiques, rapports | Airflow, Luigi |
| **Streaming** | Temps réel, événements | Kafka, Flink |
| **Micro-batch** | Near real-time | Spark Streaming |
| **ELT** | Data warehouse moderne | dbt, BigQuery |

### 4. Structure recommandée

```
/pipelines
├── /extractors           # Connecteurs sources
│   ├── postgres_extractor.py
│   └── api_extractor.py
├── /transformers         # Logique de transformation
│   ├── clean_data.py
│   └── aggregate_data.py
├── /loaders             # Connecteurs destination
│   └── warehouse_loader.py
├── /orchestration       # DAGs Airflow
│   └── daily_pipeline.py
├── /schemas             # Schémas de validation
│   └── data_schema.json
└── /tests
    └── test_transformers.py
```

### 5. Exemple avec Python/Airflow

```python
# dags/daily_sales_pipeline.py
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-team',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'daily_sales_pipeline',
    default_args=default_args,
    schedule_interval='0 2 * * *',  # 2h du matin
    start_date=datetime(2024, 1, 1),
    catchup=False,
) as dag:

    extract = PythonOperator(
        task_id='extract_sales',
        python_callable=extract_from_postgres,
    )

    transform = PythonOperator(
        task_id='transform_data',
        python_callable=clean_and_aggregate,
    )

    load = PythonOperator(
        task_id='load_to_warehouse',
        python_callable=load_to_bigquery,
    )

    extract >> transform >> load
```

### 6. Validation des données

```python
# schemas/sales_schema.py
from pydantic import BaseModel, validator
from datetime import date
from decimal import Decimal

class SalesRecord(BaseModel):
    order_id: str
    customer_id: str
    amount: Decimal
    order_date: date

    @validator('amount')
    def amount_must_be_positive(cls, v):
        if v <= 0:
            raise ValueError('Amount must be positive')
        return v
```

### 7. Gestion des erreurs

```python
def process_with_retry(data, max_retries=3):
    for attempt in range(max_retries):
        try:
            return transform(data)
        except TransientError as e:
            if attempt == max_retries - 1:
                # Dead letter queue
                send_to_dlq(data, error=str(e))
                raise
            time.sleep(2 ** attempt)  # Exponential backoff
```

## Checklist pipeline

- [ ] Sources de données identifiées
- [ ] Schémas de validation définis
- [ ] Transformations documentées
- [ ] Gestion des erreurs (retry, DLQ)
- [ ] Monitoring et alertes
- [ ] Tests unitaires et d'intégration
- [ ] Documentation du lineage

## Output attendu

```markdown
## Pipeline: [Nom]

### Sources
- [Source 1]: type, fréquence, volume estimé
- [Source 2]: ...

### Transformations
1. [Étape 1]: description
2. [Étape 2]: description

### Destination
- [Destination]: format, partitionnement

### Orchestration
- Fréquence: [cron expression]
- SLA: [temps max acceptable]

### Monitoring
- Métriques: records traités, durée, erreurs
- Alertes: seuils configurés
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/data-modeling` | Modéliser les données |
| `/data-analytics` | Analyser les résultats |
| `/ops-monitoring` | Configurer le monitoring |
| `/dev-test` | Tester le pipeline |

---

IMPORTANT: Toujours valider les données à chaque étape.

YOU MUST implémenter une gestion des erreurs robuste (retry, DLQ).

NEVER perdre de données - utiliser des checkpoints et idempotence.

Think hard sur la scalabilité et la maintenabilité du pipeline.
