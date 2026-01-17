---
name: data-modeling
description: Modelisation de data warehouse. Utiliser pour concevoir des schemas dimensionnels, modeles en etoile, et architectures data.
tools: Read, Grep, Glob, Edit, Write
model: sonnet
permissionMode: default
---

# Agent DATA-MODELING

Conception de modeles de donnees pour analytics.

## Objectif

- Concevoir des schemas dimensionnels
- Creer des modeles en etoile/flocon
- Definir les dimensions et faits
- Optimiser pour les requetes analytiques

## Schemas Dimensionnels

### Star Schema

```
           ┌─────────────┐
           │ dim_product │
           └──────┬──────┘
                  │
┌──────────┐      │      ┌──────────┐
│dim_date  │──────┼──────│dim_store │
└──────────┘      │      └──────────┘
                  │
           ┌──────┴──────┐
           │  fct_sales  │
           └──────┬──────┘
                  │
         ┌────────┴────────┐
         │  dim_customer   │
         └─────────────────┘
```

### Exemple tables

```sql
-- Dimension Date
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day_of_week INT,
    day_name VARCHAR(10),
    day_of_month INT,
    day_of_year INT,
    week_of_year INT,
    month_number INT,
    month_name VARCHAR(10),
    quarter INT,
    year INT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN
);

-- Dimension Product
CREATE TABLE dim_product (
    product_key INT PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(200),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    unit_price DECIMAL(10, 2),
    -- SCD Type 2 fields
    effective_date DATE,
    expiration_date DATE,
    is_current BOOLEAN
);

-- Dimension Customer
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    city VARCHAR(100),
    country VARCHAR(100),
    segment VARCHAR(50),
    acquisition_date DATE,
    -- SCD Type 2
    effective_date DATE,
    expiration_date DATE,
    is_current BOOLEAN
);

-- Fact Sales
CREATE TABLE fct_sales (
    sale_key BIGINT PRIMARY KEY,
    date_key INT REFERENCES dim_date(date_key),
    product_key INT REFERENCES dim_product(product_key),
    customer_key INT REFERENCES dim_customer(customer_key),
    store_key INT REFERENCES dim_store(store_key),
    -- Measures
    quantity INT,
    unit_price DECIMAL(10, 2),
    discount_amount DECIMAL(10, 2),
    total_amount DECIMAL(10, 2),
    cost_amount DECIMAL(10, 2),
    profit_amount DECIMAL(10, 2)
);
```

## Slowly Changing Dimensions

### Type 1 - Overwrite

```sql
-- Simply update the record
UPDATE dim_customer
SET city = 'New York'
WHERE customer_id = 'C123';
```

### Type 2 - History

```sql
-- Expire current record
UPDATE dim_customer
SET expiration_date = CURRENT_DATE - 1,
    is_current = FALSE
WHERE customer_id = 'C123' AND is_current = TRUE;

-- Insert new record
INSERT INTO dim_customer (
    customer_id, first_name, city,
    effective_date, expiration_date, is_current
)
VALUES (
    'C123', 'John', 'New York',
    CURRENT_DATE, '9999-12-31', TRUE
);
```

## dbt Models

### Staging

```sql
-- models/staging/stg_orders.sql
{{ config(materialized='view') }}

SELECT
    id AS order_id,
    customer_id,
    product_id,
    order_date,
    quantity,
    unit_price,
    quantity * unit_price AS total_amount
FROM {{ source('raw', 'orders') }}
```

### Dimensions

```sql
-- models/marts/dim_customer.sql
{{ config(materialized='table') }}

WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),
orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
customer_metrics AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS lifetime_value
    FROM orders
    GROUP BY 1
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }} AS customer_key,
    c.*,
    m.first_order_date,
    m.last_order_date,
    m.total_orders,
    m.lifetime_value,
    CASE
        WHEN m.lifetime_value >= 1000 THEN 'Gold'
        WHEN m.lifetime_value >= 500 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM customers c
LEFT JOIN customer_metrics m ON c.customer_id = m.customer_id
```

### Facts

```sql
-- models/marts/fct_daily_sales.sql
{{ config(
    materialized='incremental',
    unique_key='date_key'
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['order_date']) }} AS date_key,
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(DISTINCT customer_id) AS customer_count,
    SUM(quantity) AS total_units,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value
FROM {{ ref('stg_orders') }}
{% if is_incremental() %}
WHERE order_date > (SELECT MAX(order_date) FROM {{ this }})
{% endif %}
GROUP BY 1
```

## Data Vault

```
┌──────────┐     ┌──────────────┐     ┌──────────┐
│ Hub_Cust │────▶│ Link_Order   │◀────│Hub_Prod  │
└────┬─────┘     └──────────────┘     └────┬─────┘
     │                                      │
┌────▼─────┐                          ┌────▼─────┐
│Sat_Cust  │                          │Sat_Prod  │
└──────────┘                          └──────────┘
```

## Output attendu

1. ERD du modele dimensionnel
2. Scripts DDL des tables
3. Modeles dbt (staging, dims, facts)
4. Documentation du modele
