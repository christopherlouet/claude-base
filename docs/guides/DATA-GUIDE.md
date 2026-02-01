# Guide Data Engineering

> Workflow complet pour pipelines de donnees, analytics et data warehousing

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Orchestration | Airflow, Dagster, Prefect |
| Transformation | dbt, Spark, Pandas |
| Storage | PostgreSQL, BigQuery, Snowflake, S3 |
| Streaming | Kafka, Redis Streams, Kinesis |
| Visualisation | Metabase, Superset, Grafana |
| Quality | Great Expectations, dbt tests |

## Architecture Data

```
data-platform/
├── ingestion/            # Sources de donnees
│   ├── apis/
│   ├── databases/
│   └── files/
├── staging/              # Zone de preparation
│   └── raw/
├── warehouse/            # Modeles transformes
│   ├── staging/
│   ├── intermediate/
│   └── marts/
├── orchestration/        # DAGs et workflows
│   └── dags/
└── quality/              # Tests et validations
    └── expectations/
```

## Workflow Recommande

```
/work:work-explore → /work:work-plan → /data:data-pipeline → /data:data-modeling → /data:data-analytics
```

## Phase 1: Exploration

### Comprendre les sources

```bash
/work:work-explore
```

### Questions a clarifier

- Sources de donnees (APIs, DBs, fichiers)?
- Frequence de mise a jour (batch, streaming)?
- Volume de donnees?
- SLAs et qualite requise?

## Phase 2: Planification

### Planifier un pipeline

```bash
/work:work-plan "ETL pour donnees e-commerce vers BigQuery"
```

### Structure de plan type

```markdown
## Pipeline: E-commerce Analytics

### Sources
- PostgreSQL: orders, products, customers
- Stripe API: payments, refunds
- Google Analytics: traffic, conversions

### Transformations
1. Extract: Pull depuis sources
2. Clean: Deduplication, nulls, formats
3. Transform: Calculs metriques
4. Load: BigQuery marts

### Modeles dbt
- staging/stg_orders.sql
- staging/stg_products.sql
- intermediate/int_order_items.sql
- marts/fct_daily_sales.sql
- marts/dim_customers.sql

### Schedule
- Daily: 2h00 UTC
- Retry: 3 fois, delai 5min
- Alertes: Slack #data-alerts
```

## Phase 3: Ingestion

### Creer un pipeline ETL

```bash
/data:data-pipeline "extraction quotidienne des commandes vers BigQuery"
```

### DAG Airflow genere

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-team',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'on_failure_callback': alert_slack,
}

with DAG(
    'ecommerce_daily_etl',
    default_args=default_args,
    schedule_interval='0 2 * * *',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['ecommerce', 'daily'],
) as dag:

    extract_orders = PythonOperator(
        task_id='extract_orders',
        python_callable=extract_from_postgres,
        op_kwargs={'table': 'orders', 'incremental': True},
    )

    extract_payments = PythonOperator(
        task_id='extract_payments',
        python_callable=extract_from_stripe,
    )

    transform = PythonOperator(
        task_id='transform_data',
        python_callable=transform_orders,
    )

    load = PythonOperator(
        task_id='load_to_bigquery',
        python_callable=load_to_bq,
        op_kwargs={'dataset': 'analytics', 'table': 'orders'},
    )

    validate = PythonOperator(
        task_id='validate_data',
        python_callable=run_data_quality_checks,
    )

    [extract_orders, extract_payments] >> transform >> load >> validate
```

## Phase 4: Modelisation

### Creer modeles dbt

```bash
/data:data-modeling "data mart pour analyse des ventes"
```

### Structure dbt generee

```sql
-- models/staging/stg_orders.sql
{{ config(materialized='view') }}

SELECT
    id AS order_id,
    customer_id,
    order_date,
    CAST(total AS DECIMAL(10,2)) AS total_amount,
    status,
    created_at,
    updated_at
FROM {{ source('raw', 'orders') }}
WHERE order_date >= '2023-01-01'
  AND _fivetran_deleted IS FALSE

-- models/intermediate/int_order_items.sql
{{ config(materialized='table') }}

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    oi.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('stg_order_items') }} oi ON o.order_id = oi.order_id
JOIN {{ ref('stg_products') }} p ON oi.product_id = p.product_id

-- models/marts/fct_daily_sales.sql
{{ config(
    materialized='incremental',
    unique_key='date_day',
    partition_by={'field': 'date_day', 'data_type': 'date'}
) }}

SELECT
    DATE(order_date) AS date_day,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(total_amount) AS gross_revenue,
    SUM(CASE WHEN status = 'refunded' THEN total_amount ELSE 0 END) AS refunds,
    SUM(total_amount) - SUM(CASE WHEN status = 'refunded' THEN total_amount ELSE 0 END) AS net_revenue
FROM {{ ref('stg_orders') }}
{% if is_incremental() %}
WHERE order_date >= (SELECT MAX(date_day) FROM {{ this }})
{% endif %}
GROUP BY 1
```

## Phase 5: Qualite

### Tests dbt

```yaml
# models/staging/schema.yml
version: 2

models:
  - name: stg_orders
    description: Staged orders from source
    columns:
      - name: order_id
        description: Primary key
        tests:
          - unique
          - not_null
      - name: customer_id
        tests:
          - not_null
          - relationships:
              to: ref('stg_customers')
              field: customer_id
      - name: total_amount
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
```

### Great Expectations

```python
# expectations/orders_suite.py
def validate_orders(df):
    expectations = [
        expect_column_to_exist("order_id"),
        expect_column_values_to_be_unique("order_id"),
        expect_column_values_to_not_be_null("customer_id"),
        expect_column_values_to_be_between(
            "total_amount", min_value=0, max_value=100000
        ),
        expect_table_row_count_to_be_between(
            min_value=1000  # Au moins 1000 commandes par jour
        ),
    ]
    return run_expectations(df, expectations)
```

## Phase 6: Analytics

### Creer des rapports

```bash
/data:data-analytics "rapport hebdomadaire des ventes par categorie"
```

### Dashboard Metabase/Superset

| Metrique | Requete | Frequence |
|----------|---------|-----------|
| Revenue quotidien | `fct_daily_sales` | Temps reel |
| Top produits | `fct_product_sales` | Quotidien |
| Retention cohorte | `fct_cohort_retention` | Hebdomadaire |
| LTV clients | `fct_customer_ltv` | Mensuel |

### Alertes

```python
# alerts/revenue_alert.py
ALERT_THRESHOLD = -0.20  # -20%

def check_revenue_drop():
    today = get_revenue(date.today())
    yesterday = get_revenue(date.today() - timedelta(days=1))

    change = (today - yesterday) / yesterday

    if change < ALERT_THRESHOLD:
        send_slack_alert(
            channel="#data-alerts",
            message=f"Revenue drop: {change:.1%} ({today:,.0f} vs {yesterday:,.0f})"
        )
```

## Phase 7: Monitoring

### Monitoring pipelines

```bash
/ops:ops-monitoring
```

### Metriques a suivre

| Metrique | Outil | Alerte |
|----------|-------|--------|
| DAG success rate | Airflow | < 95% |
| Pipeline latency | Prometheus | > 2h |
| Data freshness | dbt | > 6h |
| Row count delta | Great Expectations | > 50% |
| Query cost | BigQuery | > $100/jour |

### Grafana dashboard

```bash
/ops:ops-grafana-dashboard "monitoring pipelines data"
```

## Commandes par Use Case

### Nouveau pipeline ETL

```bash
1. /work:work-explore       # Comprendre les sources
2. /work:work-plan          # Architecture pipeline
3. /data:data-pipeline      # Creer DAG Airflow
4. /data:data-modeling      # Modeles dbt
5. /ops:ops-ci             # CI/CD dbt + Airflow
```

### Nouveau data mart

```bash
1. /data:data-modeling      # Schema dimensionnel
2. /dev:dev-tdd            # Tests dbt
3. /data:data-analytics     # Dashboards
4. /doc:doc-generate       # Documentation lineage
```

### Debug pipeline

```bash
1. /dev:dev-debug          # Identifier le probleme
2. /ops:ops-health         # Verifier l'infra
3. /data:data-pipeline      # Corriger le DAG
```

### Optimisation

```bash
1. /qa:qa-perf            # Identifier bottlenecks
2. /ops:ops-database       # Index, partitions
3. /data:data-modeling      # Incremental models
```

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Cree un pipeline ETL" | data-pipeline | DAG Airflow |
| "Modelise les donnees" | data-modeling | dbt models |
| "Analyse les ventes" | data-analytics | Dashboards |
| "Optimise les requetes" | ops-database | Index, partitions |

## Patterns Data

### Slowly Changing Dimension (SCD Type 2)

```sql
-- dim_customers_scd2.sql
{{ config(
    materialized='incremental',
    unique_key='customer_sk'
) }}

WITH source AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

{% if is_incremental() %}
existing AS (
    SELECT * FROM {{ this }}
    WHERE is_current = TRUE
),

changes AS (
    SELECT s.*
    FROM source s
    JOIN existing e ON s.customer_id = e.customer_id
    WHERE s.email != e.email OR s.address != e.address
),
{% endif %}

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'updated_at']) }} AS customer_sk,
        customer_id,
        email,
        address,
        updated_at AS valid_from,
        NULL AS valid_to,
        TRUE AS is_current
    FROM source
)

SELECT * FROM final
```

### Incremental Processing

```python
def extract_incremental(table: str, watermark_column: str = 'updated_at'):
    last_watermark = get_last_watermark(table)

    query = f"""
    SELECT * FROM {table}
    WHERE {watermark_column} > '{last_watermark}'
    """

    df = execute_query(query)

    if not df.empty:
        new_watermark = df[watermark_column].max()
        save_watermark(table, new_watermark)

    return df
```

## Anti-patterns a Eviter

- Full refresh quotidien → Incremental quand possible
- Pas de tests data quality → Great Expectations/dbt tests
- SQL dans les DAGs → Separation orchestration/transformation
- Pas de lineage → Documenter avec dbt
- Pas de monitoring → Alertes sur freshness et quality

## Ressources

- [dbt Docs](https://docs.getdbt.com)
- [Airflow Docs](https://airflow.apache.org/docs/)
- [Great Expectations](https://docs.greatexpectations.io)
- [Data Engineering Cookbook](https://github.com/andkret/Cookbook)
