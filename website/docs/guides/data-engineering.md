---
sidebar_position: 5
title: Data Engineering
description: Guide pour pipelines et analytics
---

# Guide : Data Engineering

Guide complet pour les pipelines de donnees et l'analytics.

## Stack supportee

- **ETL/ELT** : Airflow, dbt, Prefect
- **Storage** : PostgreSQL, BigQuery, Snowflake
- **Analytics** : Metabase, Superset
- **Langages** : Python, SQL

## Commandes recommandees

### Developpement

| Commande | Usage |
|----------|-------|
| `/data:data-pipeline` | Pipelines ETL/ELT |
| `/data:data-modeling` | Modelisation |
| `/data:data-analytics` | Rapports et analyses |
| `/ops:ops-database` | Schema et migrations |

### Qualite

| Commande | Usage |
|----------|-------|
| `/qa:qa-perf` | Performance queries |
| `/qa:qa-security` | Securite donnees |

## Workflow type

### Nouveau pipeline

```bash
# 1. Comprendre les sources
/work:work-explore "sources de donnees existantes"

# 2. Planifier le pipeline
/work:work-plan "Pipeline ETL clients -> data warehouse"

# 3. Developper
/data:data-pipeline "Extraction CRM, transformation, chargement DWH"

# 4. Tests et monitoring
/ops:ops-monitoring

# 5. PR
/work:work-pr
```

### Nouveau modele de donnees

```bash
# 1. Analyser les besoins
/work:work-plan "Dimension clients avec historique"

# 2. Modeliser
/data:data-modeling "Schema dimensionnel clients"

# 3. Migrations
/ops:ops-database "Creer les tables"
```

## Architecture type

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Sources   │    │   Staging   │    │     DWH     │
│             │    │             │    │             │
│  - CRM      │───▶│  - Raw      │───▶│  - Facts    │
│  - ERP      │    │  - Cleaned  │    │  - Dims     │
│  - Logs     │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
       │                  │                  │
       │          Orchestration              │
       │           (Airflow)                 │
       │                                     │
       └──────────────────────────────────────┘
                         │
                         ▼
                ┌─────────────┐
                │  Analytics  │
                │  (Metabase) │
                └─────────────┘
```

## Bonnes pratiques

### Pipeline dbt

```sql
-- models/staging/stg_customers.sql
with source as (
    select * from {{ source('crm', 'customers') }}
),

renamed as (
    select
        id as customer_id,
        email,
        lower(trim(name)) as name,
        created_at,
        updated_at
    from source
    where email is not null
)

select * from renamed
```

```sql
-- models/marts/dim_customers.sql
with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        count(*) as total_orders,
        sum(amount) as total_spent,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from orders
    group by 1
)

select
    c.*,
    coalesce(o.total_orders, 0) as total_orders,
    coalesce(o.total_spent, 0) as total_spent,
    o.first_order_date,
    o.last_order_date
from customers c
left join customer_orders o using (customer_id)
```

### Tests de donnees

```yaml
# models/marts/dim_customers.yml
version: 2

models:
  - name: dim_customers
    description: Dimension clients avec metriques
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
      - name: email
        tests:
          - not_null
      - name: total_orders
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
```

## Monitoring

```bash
# Configurer le monitoring des pipelines
/ops:ops-monitoring "Alertes sur echecs pipeline et latence"
```

Elements a monitorer :
- Duree d'execution
- Nombre de lignes traitees
- Erreurs et echecs
- Qualite des donnees (nulls, doublons)

---

## Voir aussi

- [Pipeline](/docs/commands/data/data-pipeline)
- [Modeling](/docs/commands/data/data-modeling)
- [Database](/docs/commands/ops/ops-database)
