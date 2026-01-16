# Agent DATA-MODELING

Concevoir et implémenter des modèles de données (schémas, ERD, data warehouse).

## Contexte
$ARGUMENTS

## Workflow

### 1. Comprendre les besoins

**Questions clés:**
- Quels sont les cas d'usage analytiques ?
- Quelles sont les entités métier principales ?
- Quelles questions devrons-nous répondre ?
- Quel volume et quelle fréquence de mise à jour ?

### 2. Types de modélisation

| Type | Usage | Caractéristiques |
|------|-------|------------------|
| **OLTP (3NF)** | Applications transactionnelles | Normalisé, peu de redondance |
| **Star Schema** | Data warehouse, BI | Dénormalisé, optimisé lecture |
| **Snowflake** | DW complexe | Dimensions normalisées |
| **Data Vault** | Enterprise DWH | Historique complet, évolutif |
| **Wide Table** | Analytics moderne | Très dénormalisé, rapide |

### 3. Star Schema (recommandé pour BI)

```
                    ┌─────────────────┐
                    │   dim_product   │
                    │─────────────────│
                    │ product_id (PK) │
                    │ name            │
                    │ category        │
                    │ price           │
                    └────────┬────────┘
                             │
┌─────────────┐    ┌────────┴────────┐    ┌─────────────┐
│  dim_date   │    │   fact_sales    │    │ dim_customer│
│─────────────│    │─────────────────│    │─────────────│
│ date_id (PK)│◄───│ date_id (FK)    │───►│customer_id  │
│ date        │    │ customer_id (FK)│    │ name        │
│ month       │    │ product_id (FK) │    │ segment     │
│ quarter     │    │ quantity        │    │ region      │
│ year        │    │ revenue         │    └─────────────┘
└─────────────┘    │ discount        │
                   └─────────────────┘
```

### 4. Conventions de nommage

| Élément | Convention | Exemple |
|---------|------------|---------|
| Tables de faits | `fact_` prefix | `fact_sales`, `fact_orders` |
| Dimensions | `dim_` prefix | `dim_customer`, `dim_product` |
| Clés primaires | `_id` suffix | `customer_id`, `order_id` |
| Clés étrangères | `_id` suffix | `customer_id` (FK) |
| Colonnes date | `_at` ou `_date` | `created_at`, `order_date` |
| Booléens | `is_` ou `has_` | `is_active`, `has_subscription` |
| Montants | `_amount` | `total_amount`, `discount_amount` |

### 5. Implémentation avec dbt

```sql
-- models/marts/dim_customer.sql
WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        COUNT(*) AS total_orders,
        SUM(amount) AS lifetime_value
    FROM {{ ref('stg_orders') }}
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.email,
    c.name,
    c.segment,
    c.created_at,
    o.first_order_date,
    o.last_order_date,
    o.total_orders,
    o.lifetime_value,
    CASE
        WHEN o.lifetime_value >= 1000 THEN 'VIP'
        WHEN o.lifetime_value >= 500 THEN 'Regular'
        ELSE 'New'
    END AS customer_tier
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
```

```yaml
# models/marts/dim_customer.yml
version: 2

models:
  - name: dim_customer
    description: "Dimension client enrichie avec métriques"
    columns:
      - name: customer_id
        description: "Identifiant unique du client"
        tests:
          - unique
          - not_null
      - name: lifetime_value
        description: "Valeur totale des commandes"
        tests:
          - not_null
```

### 6. Slowly Changing Dimensions (SCD)

```sql
-- SCD Type 2: Historique complet
CREATE TABLE dim_customer_scd2 (
    surrogate_key BIGINT PRIMARY KEY,
    customer_id VARCHAR(50),
    name VARCHAR(200),
    segment VARCHAR(50),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN
);

-- Requête avec SCD2
SELECT *
FROM fact_sales f
JOIN dim_customer_scd2 d
  ON f.customer_id = d.customer_id
  AND f.order_date BETWEEN d.valid_from AND COALESCE(d.valid_to, '9999-12-31')
```

### 7. Documentation ERD

```
Utiliser dbdiagram.io ou draw.io pour créer l'ERD.

Format dbdiagram.io:
Table fact_sales {
  sale_id bigint [pk]
  date_id int [ref: > dim_date.date_id]
  customer_id int [ref: > dim_customer.customer_id]
  product_id int [ref: > dim_product.product_id]
  quantity int
  revenue decimal
}

Table dim_customer {
  customer_id int [pk]
  name varchar
  segment varchar
}
```

## Checklist modélisation

- [ ] Entités métier identifiées
- [ ] Relations définies (cardinalité)
- [ ] Clés primaires et étrangères
- [ ] Types de données appropriés
- [ ] Conventions de nommage respectées
- [ ] SCD défini si nécessaire
- [ ] Documentation (ERD, dictionnaire)
- [ ] Tests de qualité des données

## Output attendu

```markdown
## Modèle de données: [Nom]

### Entités

| Table | Type | Description | Volume estimé |
|-------|------|-------------|---------------|
| fact_sales | Fait | Transactions | 10M/jour |
| dim_customer | Dimension | Clients | 1M |

### ERD
[Diagramme ou lien]

### Dictionnaire de données
[Table avec colonnes, types, descriptions]

### Requêtes d'exemple
[Requêtes SQL pour cas d'usage principaux]
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/data-pipeline` | Alimenter le modèle |
| `/data-analytics` | Analyser les données |
| `/ops-database` | Optimiser les performances |
| `/doc-architecture` | Documenter l'architecture |

---

IMPORTANT: Le modèle doit répondre aux questions métier, pas l'inverse.

YOU MUST documenter chaque table et colonne.

NEVER créer de modèle sans comprendre les cas d'usage.

Think hard sur l'évolutivité et la maintenabilité du modèle.
