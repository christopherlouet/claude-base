# Agent DATA-ANALYTICS

Analyser des données et créer des visualisations/rapports.

## Contexte
$ARGUMENTS

## Workflow

### 1. Comprendre la question métier

**Questions à poser:**
- Quelle décision cette analyse doit-elle éclairer ?
- Qui est l'audience ?
- Quelle granularité temporelle ?
- Quels KPIs sont pertinents ?

### 2. Explorer les données

```python
import pandas as pd

# Chargement
df = pd.read_sql(query, connection)

# Exploration initiale
print(f"Shape: {df.shape}")
print(f"Colonnes: {df.columns.tolist()}")
print(f"Types:\n{df.dtypes}")
print(f"Valeurs manquantes:\n{df.isnull().sum()}")
print(f"Statistiques:\n{df.describe()}")
```

### 3. Types d'analyses

| Type | Objectif | Outils |
|------|----------|--------|
| **Descriptive** | Que s'est-il passé ? | SQL, pandas |
| **Diagnostic** | Pourquoi ? | Corrélations, segmentation |
| **Prédictive** | Que va-t-il se passer ? | ML, forecasting |
| **Prescriptive** | Que faire ? | Optimisation, simulation |

### 4. Analyse exploratoire (EDA)

```python
import matplotlib.pyplot as plt
import seaborn as sns

# Distribution
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Histogramme
df['revenue'].hist(ax=axes[0, 0])
axes[0, 0].set_title('Distribution du revenu')

# Boxplot par catégorie
df.boxplot(column='revenue', by='category', ax=axes[0, 1])

# Évolution temporelle
df.groupby('date')['revenue'].sum().plot(ax=axes[1, 0])
axes[1, 0].set_title('Évolution du revenu')

# Matrice de corrélation
sns.heatmap(df.corr(), annot=True, ax=axes[1, 1])

plt.tight_layout()
plt.savefig('eda_report.png')
```

### 5. Métriques courantes

| Domaine | Métriques clés |
|---------|----------------|
| **E-commerce** | GMV, AOV, Conversion rate, CAC, LTV |
| **SaaS** | MRR, Churn rate, NPS, DAU/MAU |
| **Marketing** | CTR, CPC, ROAS, Attribution |
| **Produit** | Retention, Engagement, Feature adoption |

### 6. Requêtes SQL analytiques

```sql
-- Cohorte de rétention
WITH cohorts AS (
  SELECT
    user_id,
    DATE_TRUNC('month', first_purchase_date) AS cohort_month,
    DATE_TRUNC('month', order_date) AS order_month
  FROM orders
  JOIN users USING (user_id)
)
SELECT
  cohort_month,
  order_month,
  COUNT(DISTINCT user_id) AS users,
  COUNT(DISTINCT user_id) * 100.0 /
    FIRST_VALUE(COUNT(DISTINCT user_id)) OVER (
      PARTITION BY cohort_month ORDER BY order_month
    ) AS retention_pct
FROM cohorts
GROUP BY 1, 2
ORDER BY 1, 2;
```

```sql
-- Analyse RFM
SELECT
  user_id,
  DATEDIFF(day, MAX(order_date), CURRENT_DATE) AS recency,
  COUNT(*) AS frequency,
  SUM(amount) AS monetary,
  NTILE(5) OVER (ORDER BY DATEDIFF(day, MAX(order_date), CURRENT_DATE) DESC) AS r_score,
  NTILE(5) OVER (ORDER BY COUNT(*)) AS f_score,
  NTILE(5) OVER (ORDER BY SUM(amount)) AS m_score
FROM orders
GROUP BY user_id;
```

### 7. Visualisation des résultats

```python
# Dashboard avec Plotly
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=('Revenu mensuel', 'Top produits', 'Répartition', 'Tendance')
)

# Graphiques...
fig.update_layout(height=800, title_text="Dashboard Ventes Q1 2024")
fig.write_html('dashboard.html')
```

## Template de rapport

```markdown
## Rapport d'analyse: [Titre]

### Résumé exécutif
[2-3 phrases clés avec les insights principaux]

### Contexte
- Période analysée: [dates]
- Sources de données: [liste]
- Limitations: [le cas échéant]

### Métriques clés

| KPI | Valeur | vs Période précédente | Tendance |
|-----|--------|----------------------|----------|
| Revenu | X€ | +Y% | ↑ |

### Analyse détaillée

#### [Section 1]
[Graphique + interprétation]

#### [Section 2]
[Graphique + interprétation]

### Recommandations
1. [Action 1] - Impact attendu: [X]
2. [Action 2] - Impact attendu: [Y]

### Prochaines étapes
- [ ] [Action à suivre]
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/data-pipeline` | Préparer les données |
| `/data-modeling` | Structurer le modèle de données |
| `/doc-generate` | Documenter l'analyse |
| `/biz-okr` | Définir les KPIs |

---

IMPORTANT: Toujours contextualiser les chiffres (période, scope).

YOU MUST valider les données avant analyse (outliers, missing values).

NEVER présenter des données sans les avoir vérifiées.

Think hard sur l'histoire que racontent les données.
