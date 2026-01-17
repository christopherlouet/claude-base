# Agent KUBERNETES

Deploiement et orchestration Kubernetes.

## Cible
$ARGUMENTS

## Modes d'utilisation

### Mode 1 : Creer des manifests Kubernetes
Genere les fichiers YAML pour deployer une application.

### Mode 2 : Creer des Helm charts
Genere un chart Helm complet pour l'application.

### Mode 3 : Configurer un cluster
Configure un cluster existant (namespaces, RBAC, ingress).

---

## Manifests Kubernetes de base

### Deployment
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  labels:
    app: app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
        - name: app
          image: myregistry/app:latest
          ports:
            - containerPort: 3000
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
          env:
            - name: NODE_ENV
              value: "production"
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: database-url
      imagePullSecrets:
        - name: registry-credentials
```

### Service
```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: app
spec:
  type: ClusterIP
  selector:
    app: app
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
```

### Ingress (Nginx)
```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - app.example.com
      secretName: app-tls
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app
                port:
                  number: 80
```

### ConfigMap
```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  LOG_LEVEL: "info"
  FEATURE_FLAG_NEW_UI: "true"
```

### Secret
```yaml
# k8s/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  database-url: "postgres://user:pass@db:5432/app"
  api-key: "secret-api-key"
```

### HorizontalPodAutoscaler
```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

---

## Helm Chart

### Structure
```
helm/app/
├── Chart.yaml
├── values.yaml
├── values-staging.yaml
├── values-production.yaml
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── configmap.yaml
    ├── secret.yaml
    ├── hpa.yaml
    └── NOTES.txt
```

### Chart.yaml
```yaml
apiVersion: v2
name: app
description: My application Helm chart
type: application
version: 1.0.0
appVersion: "1.0.0"
```

### values.yaml
```yaml
replicaCount: 2

image:
  repository: myregistry/app
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 3000

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: app-tls
      hosts:
        - app.example.com

resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "500m"

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

env:
  NODE_ENV: production

secrets:
  databaseUrl: ""
  apiKey: ""
```

### templates/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "app.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.targetPort }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            {{- range $key, $value := .Values.env }}
            - name: {{ $key }}
              value: {{ $value | quote }}
            {{- end }}
```

---

## Kustomize

### Structure
```
k8s/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── overlays/
│   ├── staging/
│   │   ├── kustomization.yaml
│   │   └── patch-replicas.yaml
│   └── production/
│       ├── kustomization.yaml
│       └── patch-replicas.yaml
```

### base/kustomization.yaml
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml
  - ingress.yaml
```

### overlays/production/kustomization.yaml
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

namespace: production

patches:
  - path: patch-replicas.yaml

images:
  - name: myregistry/app
    newTag: v1.2.3
```

---

## Deploiement CI/CD

### GitHub Actions
```yaml
# .github/workflows/deploy-k8s.yml
name: Deploy to Kubernetes

on:
  push:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up kubectl
        uses: azure/setup-kubectl@v3

      - name: Set Kubernetes context
        uses: azure/k8s-set-context@v3
        with:
          kubeconfig: ${{ secrets.KUBE_CONFIG }}

      - name: Deploy with Helm
        run: |
          helm upgrade --install app ./helm/app \
            --namespace production \
            --set image.tag=${{ github.sha }} \
            --wait

      # Alternative: Deploy with kubectl
      # - name: Deploy with kubectl
      #   run: |
      #     kubectl set image deployment/app \
      #       app=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} \
      #       -n production
```

---

## Providers Cloud

### OVH Managed Kubernetes
```bash
# Installer ovhcloud CLI
pip install ovh

# Configurer kubectl
ovhcloud kube get-kubeconfig <cluster-id> > ~/.kube/config

# Deployer
kubectl apply -f k8s/
```

### Scaleway Kapsule
```bash
# Installer scw CLI
scw init

# Recuperer kubeconfig
scw k8s kubeconfig get <cluster-id> > ~/.kube/config
```

### DigitalOcean Kubernetes
```bash
# Installer doctl
doctl auth init

# Recuperer kubeconfig
doctl kubernetes cluster kubeconfig save <cluster-name>
```

---

## Commandes Utiles

```bash
# Contexte
kubectl config get-contexts
kubectl config use-context production

# Deploiement
kubectl apply -f k8s/
kubectl rollout status deployment/app
kubectl rollout history deployment/app
kubectl rollout undo deployment/app

# Debug
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs -f <pod-name>
kubectl exec -it <pod-name> -- sh

# Scaling
kubectl scale deployment app --replicas=5
kubectl autoscale deployment app --min=2 --max=10 --cpu-percent=70

# Helm
helm install app ./helm/app -n production
helm upgrade app ./helm/app -n production
helm rollback app 1 -n production
helm list -n production
```

---

## Checklist Deploiement

### Securite
- [ ] Secrets stockes dans Kubernetes Secrets ou external-secrets
- [ ] RBAC configure (pas de cluster-admin pour les apps)
- [ ] Network Policies en place
- [ ] Pod Security Standards appliques
- [ ] Images scannees pour vulnerabilites

### Haute Disponibilite
- [ ] Replicas >= 2
- [ ] PodDisruptionBudget configure
- [ ] Anti-affinity pour repartir les pods
- [ ] Liveness et readiness probes

### Observabilite
- [ ] Logs envoyes vers un agregateur
- [ ] Metriques Prometheus exposees
- [ ] Alertes configurees
- [ ] Dashboards Grafana

### Production-Ready
- [ ] Resource requests et limits
- [ ] HPA configure
- [ ] Ingress avec TLS
- [ ] Rolling update strategy

---

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/docker` | Creer l'image Docker |
| `/ci` | Pipeline CI/CD |
| `/infra-code` | Provisionner le cluster (Terraform) |
| `/monitoring` | Observabilite du cluster |
| `/secrets-management` | Gestion des secrets |

---

IMPORTANT: Toujours definir des resource requests et limits.

IMPORTANT: Utiliser des namespaces pour isoler les environnements.

YOU MUST configurer liveness et readiness probes pour chaque application.

NEVER stocker de secrets en clair dans les manifests - utiliser Kubernetes Secrets ou un vault externe.
