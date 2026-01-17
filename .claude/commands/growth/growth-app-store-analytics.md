# Agent APP-STORE-ANALYTICS

Monitoring des metriques App Store et Google Play via APIs officielles (gratuites).

## Cible
$ARGUMENTS

## Modes d'utilisation

### Mode 1 : Setup initial
Configuration des credentials et premiere extraction.

### Mode 2 : Dashboard telechargements
Suivi des downloads, MAU, DAU, retention.

### Mode 3 : Dashboard revenus
IAP, abonnements, refunds, LTV.

### Mode 4 : Dashboard ratings
Notes, reviews, reponses automatiques.

### Mode 5 : Alertes
Notifications sur anomalies (chute downloads, bad reviews).

---

## Architecture

```
┌─────────────────┐     ┌─────────────────┐
│  App Store      │     │  Google Play    │
│  Connect API    │     │  Developer API  │
└────────┬────────┘     └────────┬────────┘
         │                       │
         └───────────┬───────────┘
                     │
              ┌──────▼──────┐
              │   Exporter  │
              │   (Python)  │
              └──────┬──────┘
                     │
              ┌──────▼──────┐
              │  Prometheus │
              └──────┬──────┘
                     │
              ┌──────▼──────┐
              │   Grafana   │
              └─────────────┘
```

---

## Configuration des APIs

### App Store Connect API (iOS)

#### 1. Creer une cle API
1. Aller sur [App Store Connect](https://appstoreconnect.apple.com)
2. Users and Access → Keys → App Store Connect API
3. Generer une nouvelle cle avec role "Sales and Reports"
4. Telecharger le fichier `.p8`

#### 2. Variables d'environnement
```bash
# .env
APPLE_KEY_ID=XXXXXXXXXX
APPLE_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
APPLE_KEY_PATH=/path/to/AuthKey_XXXXXXXXXX.p8
APPLE_VENDOR_ID=12345678
```

#### 3. Generation du JWT
```python
# apple_auth.py
import jwt
import time
from pathlib import Path

def generate_apple_token():
    """Genere un JWT pour App Store Connect API."""
    key_id = os.environ["APPLE_KEY_ID"]
    issuer_id = os.environ["APPLE_ISSUER_ID"]
    key_path = os.environ["APPLE_KEY_PATH"]

    with open(key_path, "r") as f:
        private_key = f.read()

    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        "exp": now + 1200,  # 20 minutes max
        "aud": "appstoreconnect-v1"
    }

    token = jwt.encode(
        payload,
        private_key,
        algorithm="ES256",
        headers={"kid": key_id}
    )
    return token
```

### Google Play Developer API (Android)

#### 1. Configurer un Service Account
1. Aller sur [Google Cloud Console](https://console.cloud.google.com)
2. Creer un projet ou utiliser l'existant
3. APIs & Services → Enable "Google Play Developer API"
4. Creer un Service Account avec role "Viewer"
5. Telecharger le fichier JSON de credentials
6. Dans Google Play Console → Users → Inviter le service account

#### 2. Variables d'environnement
```bash
# .env
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
GOOGLE_PLAY_PACKAGE_NAME=com.example.app
```

#### 3. Client Python
```python
# google_play_auth.py
from google.oauth2 import service_account
from googleapiclient.discovery import build

def get_play_client():
    """Cree un client Google Play Developer API."""
    credentials = service_account.Credentials.from_service_account_file(
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"],
        scopes=["https://www.googleapis.com/auth/androidpublisher"]
    )
    return build("androidpublisher", "v3", credentials=credentials)
```

---

## Exporter Prometheus

### Structure du projet
```
/app-store-exporter
├── main.py
├── collectors/
│   ├── __init__.py
│   ├── apple.py
│   └── google.py
├── metrics.py
├── config.py
├── requirements.txt
└── Dockerfile
```

### requirements.txt
```
prometheus-client==0.20.0
pyjwt==2.8.0
cryptography==42.0.0
google-api-python-client==2.118.0
google-auth==2.28.0
requests==2.31.0
python-dotenv==1.0.1
schedule==1.2.1
```

### metrics.py
```python
"""Definition des metriques Prometheus."""
from prometheus_client import Gauge, Counter, Info

# Downloads
app_downloads_total = Gauge(
    "app_store_downloads_total",
    "Total downloads",
    ["platform", "app_id", "country"]
)

app_downloads_daily = Gauge(
    "app_store_downloads_daily",
    "Daily downloads",
    ["platform", "app_id", "country"]
)

app_updates_total = Gauge(
    "app_store_updates_total",
    "Total app updates",
    ["platform", "app_id", "country"]
)

# Users
app_active_users = Gauge(
    "app_store_active_users",
    "Active users (DAU/MAU)",
    ["platform", "app_id", "period"]  # period: daily, monthly
)

app_sessions = Gauge(
    "app_store_sessions",
    "App sessions",
    ["platform", "app_id"]
)

app_retention_rate = Gauge(
    "app_store_retention_rate",
    "Retention rate by day",
    ["platform", "app_id", "day"]  # day: 1, 7, 14, 30
)

# Revenue
app_revenue_total = Gauge(
    "app_store_revenue_total",
    "Total revenue in USD",
    ["platform", "app_id", "type"]  # type: iap, subscription
)

app_revenue_daily = Gauge(
    "app_store_revenue_daily",
    "Daily revenue in USD",
    ["platform", "app_id", "type"]
)

app_subscribers = Gauge(
    "app_store_subscribers",
    "Active subscribers",
    ["platform", "app_id", "product_id"]
)

app_refunds = Counter(
    "app_store_refunds_total",
    "Total refunds",
    ["platform", "app_id"]
)

# Ratings
app_rating_average = Gauge(
    "app_store_rating_average",
    "Average rating (1-5)",
    ["platform", "app_id", "country"]
)

app_rating_count = Gauge(
    "app_store_rating_count",
    "Total ratings count",
    ["platform", "app_id", "country"]
)

app_reviews_count = Gauge(
    "app_store_reviews_count",
    "Total reviews count",
    ["platform", "app_id", "country"]
)

# Conversion
app_impressions = Gauge(
    "app_store_impressions",
    "Store page impressions",
    ["platform", "app_id", "source"]
)

app_page_views = Gauge(
    "app_store_page_views",
    "Product page views",
    ["platform", "app_id", "source"]
)

app_conversion_rate = Gauge(
    "app_store_conversion_rate",
    "Conversion rate (views to downloads)",
    ["platform", "app_id"]
)

# Crashes
app_crash_rate = Gauge(
    "app_store_crash_rate",
    "Crash rate percentage",
    ["platform", "app_id", "version"]
)

app_crash_free_users = Gauge(
    "app_store_crash_free_users_rate",
    "Percentage of crash-free users",
    ["platform", "app_id", "version"]
)

# App Info
app_info = Info(
    "app_store_app",
    "App information",
    ["platform", "app_id"]
)
```

### collectors/apple.py
```python
"""Collecteur de metriques App Store Connect."""
import requests
from datetime import datetime, timedelta
from ..metrics import *
from ..apple_auth import generate_apple_token

BASE_URL = "https://api.appstoreconnect.apple.com/v1"

class AppleCollector:
    def __init__(self, app_id: str):
        self.app_id = app_id
        self.headers = {}
        self._refresh_token()

    def _refresh_token(self):
        token = generate_apple_token()
        self.headers = {"Authorization": f"Bearer {token}"}

    def collect_downloads(self):
        """Recupere les donnees de telechargement."""
        # Sales and Trends API
        url = f"{BASE_URL}/salesReports"
        params = {
            "filter[vendorNumber]": os.environ["APPLE_VENDOR_ID"],
            "filter[reportType]": "SALES",
            "filter[reportSubType]": "SUMMARY",
            "filter[frequency]": "DAILY",
            "filter[reportDate]": (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
        }

        response = requests.get(url, headers=self.headers, params=params)
        if response.status_code == 200:
            data = self._parse_sales_report(response.content)
            for row in data:
                app_downloads_daily.labels(
                    platform="ios",
                    app_id=self.app_id,
                    country=row["country"]
                ).set(row["units"])

    def collect_analytics(self):
        """Recupere les analytics (impressions, conversions)."""
        # Analytics Reports API
        end_date = datetime.now()
        start_date = end_date - timedelta(days=1)

        url = f"{BASE_URL}/analyticsReportRequests"
        payload = {
            "data": {
                "type": "analyticsReportRequests",
                "attributes": {
                    "accessType": "ONGOING",
                    "reportType": "APP_USAGE"
                },
                "relationships": {
                    "app": {
                        "data": {"type": "apps", "id": self.app_id}
                    }
                }
            }
        }

        response = requests.post(url, headers=self.headers, json=payload)
        # Process response...

    def collect_ratings(self):
        """Recupere les notes et avis."""
        url = f"{BASE_URL}/apps/{self.app_id}/customerReviews"
        params = {"limit": 100, "sort": "-createdDate"}

        response = requests.get(url, headers=self.headers, params=params)
        if response.status_code == 200:
            reviews = response.json()["data"]

            # Calculer la moyenne
            if reviews:
                avg_rating = sum(r["attributes"]["rating"] for r in reviews) / len(reviews)
                app_rating_average.labels(
                    platform="ios",
                    app_id=self.app_id,
                    country="all"
                ).set(avg_rating)

                app_reviews_count.labels(
                    platform="ios",
                    app_id=self.app_id,
                    country="all"
                ).set(len(reviews))

    def collect_subscriptions(self):
        """Recupere les donnees d'abonnements."""
        url = f"{BASE_URL}/financeReports"
        params = {
            "filter[vendorNumber]": os.environ["APPLE_VENDOR_ID"],
            "filter[reportType]": "SUBSCRIBER",
            "filter[reportSubType]": "DETAILED",
            "filter[frequency]": "DAILY",
            "filter[reportDate]": (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
        }

        response = requests.get(url, headers=self.headers, params=params)
        if response.status_code == 200:
            data = self._parse_subscriber_report(response.content)
            for product_id, count in data.items():
                app_subscribers.labels(
                    platform="ios",
                    app_id=self.app_id,
                    product_id=product_id
                ).set(count)

    def collect_all(self):
        """Collecte toutes les metriques."""
        self._refresh_token()
        self.collect_downloads()
        self.collect_analytics()
        self.collect_ratings()
        self.collect_subscriptions()

    def _parse_sales_report(self, content):
        """Parse le rapport de ventes (TSV gzippe)."""
        import gzip
        import csv
        from io import StringIO

        decompressed = gzip.decompress(content).decode("utf-8")
        reader = csv.DictReader(StringIO(decompressed), delimiter="\t")

        results = []
        for row in reader:
            if row["Product Type Identifier"] in ["1F", "1T", "F1"]:  # Downloads
                results.append({
                    "country": row["Country Code"],
                    "units": int(row["Units"])
                })
        return results
```

### collectors/google.py
```python
"""Collecteur de metriques Google Play."""
from googleapiclient.discovery import build
from google.oauth2 import service_account
from datetime import datetime, timedelta
from ..metrics import *

class GooglePlayCollector:
    def __init__(self, package_name: str):
        self.package_name = package_name
        self.client = self._get_client()

    def _get_client(self):
        credentials = service_account.Credentials.from_service_account_file(
            os.environ["GOOGLE_APPLICATION_CREDENTIALS"],
            scopes=["https://www.googleapis.com/auth/androidpublisher"]
        )
        return build("androidpublisher", "v3", credentials=credentials)

    def collect_reviews(self):
        """Recupere les avis Google Play."""
        reviews = self.client.reviews().list(
            packageName=self.package_name,
            maxResults=100
        ).execute()

        if "reviews" in reviews:
            ratings = [r["comments"][0]["userComment"]["starRating"]
                      for r in reviews["reviews"]]

            if ratings:
                avg_rating = sum(ratings) / len(ratings)
                app_rating_average.labels(
                    platform="android",
                    app_id=self.package_name,
                    country="all"
                ).set(avg_rating)

                app_reviews_count.labels(
                    platform="android",
                    app_id=self.package_name,
                    country="all"
                ).set(len(ratings))

    def collect_stats(self):
        """Recupere les statistiques via Google Play Console API."""
        # Note: Certaines metriques necessitent l'API Cloud Storage
        # pour acceder aux rapports exportes

        # Downloads via Stats API
        end_date = datetime.now()
        start_date = end_date - timedelta(days=30)

        # Les rapports detailles sont disponibles via GCS bucket
        # configure dans Google Play Console
        pass

    def collect_subscriptions(self):
        """Recupere les abonnements actifs."""
        # Monetization API
        # Necessite des permissions supplementaires
        pass

    def collect_crashes(self):
        """Recupere les donnees de crash via Play Console."""
        # Les donnees de crash sont dans Firebase Crashlytics
        # ou via les rapports ANR/crash de Play Console
        pass

    def collect_all(self):
        """Collecte toutes les metriques."""
        self.collect_reviews()
        self.collect_stats()
        self.collect_subscriptions()
```

### main.py
```python
"""App Store Metrics Exporter pour Prometheus."""
import os
import time
import schedule
import logging
from prometheus_client import start_http_server, REGISTRY
from dotenv import load_dotenv

from collectors.apple import AppleCollector
from collectors.google import GooglePlayCollector

load_dotenv()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
APPLE_APP_ID = os.environ.get("APPLE_APP_ID")
GOOGLE_PACKAGE_NAME = os.environ.get("GOOGLE_PLAY_PACKAGE_NAME")
METRICS_PORT = int(os.environ.get("METRICS_PORT", 9100))
COLLECT_INTERVAL_HOURS = int(os.environ.get("COLLECT_INTERVAL_HOURS", 6))

def collect_all_metrics():
    """Collecte les metriques de toutes les plateformes."""
    logger.info("Starting metrics collection...")

    if APPLE_APP_ID:
        try:
            apple = AppleCollector(APPLE_APP_ID)
            apple.collect_all()
            logger.info("Apple metrics collected successfully")
        except Exception as e:
            logger.error(f"Error collecting Apple metrics: {e}")

    if GOOGLE_PACKAGE_NAME:
        try:
            google = GooglePlayCollector(GOOGLE_PACKAGE_NAME)
            google.collect_all()
            logger.info("Google Play metrics collected successfully")
        except Exception as e:
            logger.error(f"Error collecting Google Play metrics: {e}")

    logger.info("Metrics collection completed")

def main():
    # Demarrer le serveur HTTP pour Prometheus
    start_http_server(METRICS_PORT)
    logger.info(f"Metrics server started on port {METRICS_PORT}")

    # Premiere collecte au demarrage
    collect_all_metrics()

    # Planifier les collectes regulieres
    # (Les APIs ont des limites de rate, donc pas trop frequent)
    schedule.every(COLLECT_INTERVAL_HOURS).hours.do(collect_all_metrics)

    while True:
        schedule.run_pending()
        time.sleep(60)

if __name__ == "__main__":
    main()
```

### Dockerfile
```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 9100

CMD ["python", "main.py"]
```

---

## Docker Compose

### docker-compose.app-analytics.yaml
```yaml
version: '3.8'

services:
  app-store-exporter:
    build: ./app-store-exporter
    restart: unless-stopped
    ports:
      - "9100:9100"
    environment:
      - APPLE_KEY_ID=${APPLE_KEY_ID}
      - APPLE_ISSUER_ID=${APPLE_ISSUER_ID}
      - APPLE_VENDOR_ID=${APPLE_VENDOR_ID}
      - APPLE_APP_ID=${APPLE_APP_ID}
      - GOOGLE_PLAY_PACKAGE_NAME=${GOOGLE_PLAY_PACKAGE_NAME}
      - COLLECT_INTERVAL_HOURS=6
    volumes:
      - ./secrets/AuthKey.p8:/app/secrets/AuthKey.p8:ro
      - ./secrets/google-service-account.json:/app/secrets/google-sa.json:ro
    env_file:
      - .env

  prometheus:
    image: prom/prometheus:v2.50.0
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=90d'
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:11-alpine
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning
      - ./grafana/dashboards:/var/lib/grafana/dashboards
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD:-admin}
    ports:
      - "3000:3000"

volumes:
  prometheus_data:
  grafana_data:
```

### prometheus.yml
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'app-store-metrics'
    static_configs:
      - targets: ['app-store-exporter:9100']
    scrape_interval: 5m  # Moins frequent car les donnees changent peu
```

---

## Dashboard Grafana

### app-store-overview.json
```json
{
  "title": "App Store Analytics",
  "uid": "app-store-analytics",
  "tags": ["mobile", "app-store", "growth"],
  "templating": {
    "list": [
      {
        "name": "platform",
        "type": "custom",
        "query": "ios,android",
        "multi": true,
        "includeAll": true
      },
      {
        "name": "app_id",
        "type": "query",
        "datasource": { "type": "prometheus", "uid": "prometheus" },
        "query": "label_values(app_store_downloads_daily, app_id)",
        "refresh": 2
      }
    ]
  },
  "panels": [
    {
      "title": "Downloads Today",
      "type": "stat",
      "gridPos": { "h": 4, "w": 4, "x": 0, "y": 0 },
      "targets": [
        {
          "expr": "sum(app_store_downloads_daily{platform=~\"$platform\", app_id=\"$app_id\"})",
          "legendFormat": "Downloads"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "short",
          "color": { "mode": "thresholds" },
          "thresholds": {
            "steps": [
              { "color": "red", "value": null },
              { "color": "yellow", "value": 100 },
              { "color": "green", "value": 500 }
            ]
          }
        }
      }
    },
    {
      "title": "Average Rating",
      "type": "gauge",
      "gridPos": { "h": 4, "w": 4, "x": 4, "y": 0 },
      "targets": [
        {
          "expr": "avg(app_store_rating_average{platform=~\"$platform\", app_id=\"$app_id\"})"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "short",
          "min": 0,
          "max": 5,
          "thresholds": {
            "steps": [
              { "color": "red", "value": null },
              { "color": "orange", "value": 3 },
              { "color": "yellow", "value": 4 },
              { "color": "green", "value": 4.5 }
            ]
          }
        }
      }
    },
    {
      "title": "Active Subscribers",
      "type": "stat",
      "gridPos": { "h": 4, "w": 4, "x": 8, "y": 0 },
      "targets": [
        {
          "expr": "sum(app_store_subscribers{platform=~\"$platform\", app_id=\"$app_id\"})"
        }
      ],
      "fieldConfig": { "defaults": { "unit": "short" } }
    },
    {
      "title": "Daily Revenue",
      "type": "stat",
      "gridPos": { "h": 4, "w": 4, "x": 12, "y": 0 },
      "targets": [
        {
          "expr": "sum(app_store_revenue_daily{platform=~\"$platform\", app_id=\"$app_id\"})"
        }
      ],
      "fieldConfig": { "defaults": { "unit": "currencyUSD" } }
    },
    {
      "title": "Conversion Rate",
      "type": "stat",
      "gridPos": { "h": 4, "w": 4, "x": 16, "y": 0 },
      "targets": [
        {
          "expr": "avg(app_store_conversion_rate{platform=~\"$platform\", app_id=\"$app_id\"}) * 100"
        }
      ],
      "fieldConfig": { "defaults": { "unit": "percent" } }
    },
    {
      "title": "Crash-Free Users",
      "type": "gauge",
      "gridPos": { "h": 4, "w": 4, "x": 20, "y": 0 },
      "targets": [
        {
          "expr": "avg(app_store_crash_free_users_rate{platform=~\"$platform\", app_id=\"$app_id\"})"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percent",
          "min": 90,
          "max": 100,
          "thresholds": {
            "steps": [
              { "color": "red", "value": null },
              { "color": "yellow", "value": 98 },
              { "color": "green", "value": 99.5 }
            ]
          }
        }
      }
    },
    {
      "title": "Downloads Trend (30 days)",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 4 },
      "targets": [
        {
          "expr": "sum(app_store_downloads_daily{platform=\"ios\", app_id=\"$app_id\"}) by (platform)",
          "legendFormat": "iOS"
        },
        {
          "expr": "sum(app_store_downloads_daily{platform=\"android\", app_id=\"$app_id\"}) by (platform)",
          "legendFormat": "Android"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "custom": {
            "drawStyle": "bars",
            "fillOpacity": 80
          }
        }
      }
    },
    {
      "title": "Revenue Trend (30 days)",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 4 },
      "targets": [
        {
          "expr": "sum(app_store_revenue_daily{platform=~\"$platform\", app_id=\"$app_id\"}) by (type)",
          "legendFormat": "{{ type }}"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "currencyUSD",
          "custom": { "fillOpacity": 30 }
        }
      }
    },
    {
      "title": "Downloads by Country",
      "type": "geomap",
      "gridPos": { "h": 10, "w": 12, "x": 0, "y": 12 },
      "targets": [
        {
          "expr": "sum(app_store_downloads_daily{platform=~\"$platform\", app_id=\"$app_id\"}) by (country)",
          "legendFormat": "{{ country }}"
        }
      ]
    },
    {
      "title": "Ratings Distribution",
      "type": "piechart",
      "gridPos": { "h": 5, "w": 6, "x": 12, "y": 12 },
      "targets": [
        {
          "expr": "sum(app_store_rating_count{platform=~\"$platform\", app_id=\"$app_id\"}) by (rating)",
          "legendFormat": "{{ rating }} stars"
        }
      ]
    },
    {
      "title": "Platform Comparison",
      "type": "bargauge",
      "gridPos": { "h": 5, "w": 6, "x": 18, "y": 12 },
      "targets": [
        {
          "expr": "sum(app_store_downloads_total{app_id=\"$app_id\"}) by (platform)",
          "legendFormat": "{{ platform }}"
        }
      ]
    },
    {
      "title": "Retention Curve",
      "type": "timeseries",
      "gridPos": { "h": 5, "w": 12, "x": 12, "y": 17 },
      "targets": [
        {
          "expr": "app_store_retention_rate{platform=~\"$platform\", app_id=\"$app_id\"}",
          "legendFormat": "Day {{ day }}"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "percent" }
      }
    },
    {
      "title": "Recent Reviews",
      "type": "table",
      "gridPos": { "h": 8, "w": 24, "x": 0, "y": 22 },
      "targets": [
        {
          "expr": "app_store_reviews_count{platform=~\"$platform\", app_id=\"$app_id\"}",
          "format": "table",
          "instant": true
        }
      ]
    }
  ]
}
```

---

## Alertes

### alerts.yaml
```yaml
groups:
  - name: App Store Alerts
    rules:
      - alert: DownloadsDropped
        expr: |
          (
            sum(app_store_downloads_daily)
            /
            sum(app_store_downloads_daily offset 7d)
          ) < 0.5
        for: 1d
        labels:
          severity: warning
        annotations:
          summary: "Downloads dropped by more than 50%"
          description: "Downloads are {{ $value | humanizePercentage }} of last week"

      - alert: BadReviewSpike
        expr: |
          sum(rate(app_store_reviews_count{rating=~"1|2"}[24h]))
          >
          sum(rate(app_store_reviews_count{rating=~"1|2"}[24h] offset 7d)) * 2
        for: 6h
        labels:
          severity: warning
        annotations:
          summary: "Spike in negative reviews"
          description: "Negative reviews doubled compared to last week"

      - alert: RatingDropped
        expr: app_store_rating_average < 4.0
        for: 1d
        labels:
          severity: warning
        annotations:
          summary: "App rating below 4.0"
          description: "Current rating: {{ $value }}"

      - alert: HighCrashRate
        expr: app_store_crash_free_users_rate < 99
        for: 6h
        labels:
          severity: critical
        annotations:
          summary: "Crash-free users below 99%"
          description: "Current crash-free rate: {{ $value }}%"

      - alert: RevenueDropped
        expr: |
          sum(app_store_revenue_daily)
          <
          sum(app_store_revenue_daily offset 1d) * 0.7
        for: 1d
        labels:
          severity: warning
        annotations:
          summary: "Revenue dropped by more than 30%"
```

---

## Rapports Automatiques

### weekly_report.py
```python
"""Genere un rapport hebdomadaire des metriques stores."""
import os
from datetime import datetime, timedelta
from prometheus_api_client import PrometheusConnect

PROMETHEUS_URL = os.environ.get("PROMETHEUS_URL", "http://localhost:9090")
SLACK_WEBHOOK = os.environ.get("SLACK_WEBHOOK_URL")

def generate_weekly_report():
    prom = PrometheusConnect(url=PROMETHEUS_URL)

    # Recuperer les metriques de la semaine
    end_time = datetime.now()
    start_time = end_time - timedelta(days=7)

    # Downloads
    downloads_ios = prom.custom_query(
        'sum(increase(app_store_downloads_total{platform="ios"}[7d]))'
    )
    downloads_android = prom.custom_query(
        'sum(increase(app_store_downloads_total{platform="android"}[7d]))'
    )

    # Revenue
    revenue = prom.custom_query(
        'sum(increase(app_store_revenue_total[7d]))'
    )

    # Rating
    rating = prom.custom_query('avg(app_store_rating_average)')

    # Generer le rapport
    report = f"""
*Weekly App Store Report*
_{start_time.strftime('%Y-%m-%d')} to {end_time.strftime('%Y-%m-%d')}_

*Downloads*
- iOS: {int(float(downloads_ios[0]['value'][1])):,}
- Android: {int(float(downloads_android[0]['value'][1])):,}
- Total: {int(float(downloads_ios[0]['value'][1]) + float(downloads_android[0]['value'][1])):,}

*Revenue*
- Total: ${float(revenue[0]['value'][1]):,.2f}

*Rating*
- Average: {float(rating[0]['value'][1]):.2f} / 5.0

_Generated automatically by App Store Analytics_
    """

    # Envoyer sur Slack
    if SLACK_WEBHOOK:
        import requests
        requests.post(SLACK_WEBHOOK, json={"text": report})

    return report

if __name__ == "__main__":
    print(generate_weekly_report())
```

### Cron pour rapport hebdomadaire
```bash
# Ajouter au crontab
0 9 * * 1 cd /app && python weekly_report.py
```

---

## Checklist Implementation

### Configuration
- [ ] Compte Apple Developer actif ($99/an)
- [ ] Compte Google Play Console actif ($25)
- [ ] Cle API App Store Connect creee
- [ ] Service Account Google configure
- [ ] Permissions API validees

### Deploiement
- [ ] Exporter deploye et fonctionnel
- [ ] Prometheus scrape les metriques
- [ ] Dashboards Grafana importes
- [ ] Alertes configurees
- [ ] Notifications testees

### Maintenance
- [ ] Rotation des tokens automatisee
- [ ] Logs monitores
- [ ] Backups des dashboards

---

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/ops-mobile-release` | Publier sur les stores |
| `/growth-analytics` | Analytics in-app (Firebase, Mixpanel) |
| `/ops-grafana-dashboard` | Creer des dashboards personnalises |
| `/growth-retention` | Strategies de retention |
| `/growth-funnel` | Analyse du funnel d'acquisition |

---

## Limitations des APIs

| Limitation | App Store | Google Play |
|------------|-----------|-------------|
| Rate limit | 1000 req/heure | 200 req/seconde |
| Historique | 1 an | 2 ans |
| Latence donnees | J-1 | J-1 a J-2 |
| Granularite | Jour | Jour |

---

IMPORTANT: Les donnees sont disponibles avec 24-48h de retard.

IMPORTANT: Ne pas depasser les rate limits des APIs.

YOU MUST securiser les credentials (ne jamais les commiter).

NEVER partager les fichiers .p8 ou service account publiquement.
