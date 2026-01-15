# Agent SECRETS-MANAGEMENT

Implémente une gestion sécurisée des secrets et credentials.

## Cible
$ARGUMENTS

## Objectif

Mettre en place une stratégie complète de gestion des secrets qui garantit
la sécurité, l'auditabilité et la rotation automatique des credentials.

## Stratégie de gestion des secrets

```
┌─────────────────────────────────────────────────────────────┐
│                    SECRETS MANAGEMENT                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. INVENTORIER   → Identifier tous les secrets            │
│  ═════════════                                              │
│                                                             │
│  2. CLASSIFIER    → Catégoriser par sensibilité            │
│  ════════════                                               │
│                                                             │
│  3. CENTRALISER   → Vault/Secrets Manager                  │
│  ═════════════                                              │
│                                                             │
│  4. ACCÉDER       → Injection sécurisée                    │
│  ══════════                                                 │
│                                                             │
│  5. ROTATION      → Automatiser le renouvellement          │
│  ══════════                                                 │
│                                                             │
│  6. AUDITER       → Tracer tous les accès                  │
│  ══════════                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Inventaire des secrets

### Types de secrets à gérer

| Type | Exemples | Sensibilité |
|------|----------|-------------|
| **API Keys** | Stripe, Twilio, SendGrid | Haute |
| **Database** | Connection strings, passwords | Critique |
| **Auth** | JWT secrets, OAuth secrets | Critique |
| **Cloud** | AWS keys, GCP service accounts | Critique |
| **Certificates** | SSL/TLS, signing keys | Haute |
| **Encryption** | AES keys, RSA private keys | Critique |
| **Third-party** | SaaS API tokens | Moyenne-Haute |
| **Internal** | Inter-service tokens | Moyenne |

### Audit de l'existant

```bash
# Rechercher des secrets potentiels dans le code
# ⚠️ À exécuter localement, ne pas commiter les résultats

# Patterns de secrets courants
grep -rn "password\|secret\|api_key\|apikey\|token\|credential" --include="*.ts" --include="*.js" --include="*.json" .

# Recherche de patterns suspects
grep -rn "sk_live\|pk_live\|AKIA\|AIza" .

# Fichiers .env non gitignorés
find . -name ".env*" -not -path "./node_modules/*"

# Vérifier le .gitignore
cat .gitignore | grep -E "\.env|secret|credential"
```

### Template d'inventaire

```markdown
## Inventaire des Secrets

### Critique (Rotation immédiate si compromis)
| Secret | Usage | Stockage actuel | Risque |
|--------|-------|-----------------|--------|
| DB_PASSWORD | PostgreSQL prod | .env | ⚠️ Non sécurisé |
| JWT_SECRET | Auth tokens | .env | ⚠️ Non sécurisé |
| AWS_SECRET_KEY | S3, SES | .env | ⚠️ Non sécurisé |

### Haute sensibilité
| Secret | Usage | Stockage actuel | Risque |
|--------|-------|-----------------|--------|
| STRIPE_SECRET | Paiements | .env | ⚠️ Non sécurisé |
| SENDGRID_KEY | Emails | .env | ⚠️ Non sécurisé |

### Moyenne sensibilité
| Secret | Usage | Stockage actuel | Risque |
|--------|-------|-----------------|--------|
| ANALYTICS_KEY | Tracking | .env | Acceptable |
```

## Étape 2 : Solutions de stockage

### AWS Secrets Manager

```typescript
// src/config/secrets.ts
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: process.env.AWS_REGION });

interface SecretCache {
  value: string;
  expiresAt: number;
}

const cache = new Map<string, SecretCache>();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

export async function getSecret(secretName: string): Promise<string> {
  // Check cache
  const cached = cache.get(secretName);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.value;
  }

  try {
    const command = new GetSecretValueCommand({ SecretId: secretName });
    const response = await client.send(command);

    if (!response.SecretString) {
      throw new Error(`Secret ${secretName} has no string value`);
    }

    // Update cache
    cache.set(secretName, {
      value: response.SecretString,
      expiresAt: Date.now() + CACHE_TTL,
    });

    return response.SecretString;
  } catch (error) {
    console.error(`Failed to retrieve secret ${secretName}:`, error);
    throw error;
  }
}

export async function getSecretJSON<T>(secretName: string): Promise<T> {
  const secret = await getSecret(secretName);
  return JSON.parse(secret) as T;
}

// Usage
interface DatabaseCredentials {
  host: string;
  port: number;
  username: string;
  password: string;
  database: string;
}

const dbCreds = await getSecretJSON<DatabaseCredentials>('prod/database');
```

### HashiCorp Vault

```typescript
// src/config/vault.ts
import Vault from 'node-vault';

const vault = Vault({
  apiVersion: 'v1',
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN,
});

export async function getVaultSecret(path: string): Promise<Record<string, string>> {
  try {
    const result = await vault.read(path);
    return result.data.data;
  } catch (error) {
    console.error(`Failed to read secret from ${path}:`, error);
    throw error;
  }
}

// AppRole authentication (recommandé pour applications)
export async function authenticateAppRole(
  roleId: string,
  secretId: string
): Promise<string> {
  const result = await vault.approleLogin({
    role_id: roleId,
    secret_id: secretId,
  });
  return result.auth.client_token;
}

// Usage avec renouvellement automatique
class VaultClient {
  private token: string | null = null;
  private tokenExpiry: number = 0;

  async getToken(): Promise<string> {
    if (this.token && this.tokenExpiry > Date.now()) {
      return this.token;
    }

    this.token = await authenticateAppRole(
      process.env.VAULT_ROLE_ID!,
      process.env.VAULT_SECRET_ID!
    );
    this.tokenExpiry = Date.now() + 3600 * 1000; // 1 hour
    return this.token;
  }

  async getSecret(path: string): Promise<Record<string, string>> {
    await this.getToken();
    return getVaultSecret(path);
  }
}
```

### Environment Variables sécurisées (Docker/K8s)

```yaml
# kubernetes/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: production
type: Opaque
stringData:
  DATABASE_URL: "postgresql://user:pass@host:5432/db"
  JWT_SECRET: "your-jwt-secret"
  STRIPE_SECRET_KEY: "sk_live_xxx"

---
# kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      containers:
        - name: app
          envFrom:
            - secretRef:
                name: app-secrets
          # Ou montage en fichier
          volumeMounts:
            - name: secrets
              mountPath: "/etc/secrets"
              readOnly: true
      volumes:
        - name: secrets
          secret:
            secretName: app-secrets
```

### External Secrets Operator (K8s)

```yaml
# external-secret.yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: aws-secrets-manager
  target:
    name: app-secrets
    creationPolicy: Owner
  data:
    - secretKey: DATABASE_URL
      remoteRef:
        key: prod/database
        property: connection_string
    - secretKey: JWT_SECRET
      remoteRef:
        key: prod/auth
        property: jwt_secret
```

## Étape 3 : Injection sécurisée

### Pattern de configuration

```typescript
// src/config/index.ts
import { getSecretJSON } from './secrets';

interface AppConfig {
  database: {
    host: string;
    port: number;
    username: string;
    password: string;
    database: string;
  };
  jwt: {
    secret: string;
    expiresIn: string;
  };
  stripe: {
    secretKey: string;
    webhookSecret: string;
  };
}

let config: AppConfig | null = null;

export async function loadConfig(): Promise<AppConfig> {
  if (config) return config;

  const environment = process.env.NODE_ENV || 'development';

  if (environment === 'development') {
    // En dev, utiliser dotenv
    config = {
      database: {
        host: process.env.DB_HOST!,
        port: parseInt(process.env.DB_PORT!),
        username: process.env.DB_USER!,
        password: process.env.DB_PASSWORD!,
        database: process.env.DB_NAME!,
      },
      jwt: {
        secret: process.env.JWT_SECRET!,
        expiresIn: '1d',
      },
      stripe: {
        secretKey: process.env.STRIPE_SECRET_KEY!,
        webhookSecret: process.env.STRIPE_WEBHOOK_SECRET!,
      },
    };
  } else {
    // En prod, charger depuis Secrets Manager
    const [dbCreds, authCreds, stripeCreds] = await Promise.all([
      getSecretJSON<AppConfig['database']>(`${environment}/database`),
      getSecretJSON<AppConfig['jwt']>(`${environment}/auth`),
      getSecretJSON<AppConfig['stripe']>(`${environment}/stripe`),
    ]);

    config = {
      database: dbCreds,
      jwt: authCreds,
      stripe: stripeCreds,
    };
  }

  return config;
}

export function getConfig(): AppConfig {
  if (!config) {
    throw new Error('Config not loaded. Call loadConfig() first.');
  }
  return config;
}
```

### Startup sécurisé

```typescript
// src/index.ts
import { loadConfig } from './config';
import { createApp } from './app';
import { logger } from './utils/logger';

async function bootstrap() {
  try {
    // Charger la configuration avant tout
    logger.info('Loading configuration...');
    await loadConfig();
    logger.info('Configuration loaded successfully');

    // Créer et démarrer l'application
    const app = await createApp();
    const port = process.env.PORT || 3000;

    app.listen(port, () => {
      logger.info(`Server running on port ${port}`);
    });
  } catch (error) {
    logger.error('Failed to start application', { error });
    process.exit(1);
  }
}

bootstrap();
```

## Étape 4 : Rotation automatique

### AWS Secrets Manager Rotation

```typescript
// lambda/rotate-db-password.ts
import {
  SecretsManagerClient,
  GetSecretValueCommand,
  PutSecretValueCommand,
  UpdateSecretVersionStageCommand,
} from '@aws-sdk/client-secrets-manager';
import { Client } from 'pg';
import { randomBytes } from 'crypto';

const secretsClient = new SecretsManagerClient({});

export async function handler(event: {
  SecretId: string;
  ClientRequestToken: string;
  Step: 'createSecret' | 'setSecret' | 'testSecret' | 'finishSecret';
}) {
  const { SecretId, ClientRequestToken, Step } = event;

  switch (Step) {
    case 'createSecret':
      await createSecret(SecretId, ClientRequestToken);
      break;
    case 'setSecret':
      await setSecret(SecretId, ClientRequestToken);
      break;
    case 'testSecret':
      await testSecret(SecretId, ClientRequestToken);
      break;
    case 'finishSecret':
      await finishSecret(SecretId, ClientRequestToken);
      break;
  }
}

async function createSecret(secretId: string, token: string) {
  // Récupérer le secret actuel
  const current = await secretsClient.send(
    new GetSecretValueCommand({
      SecretId: secretId,
      VersionStage: 'AWSCURRENT',
    })
  );

  const currentSecret = JSON.parse(current.SecretString!);

  // Générer nouveau mot de passe
  const newPassword = randomBytes(32).toString('base64');

  // Créer nouvelle version
  await secretsClient.send(
    new PutSecretValueCommand({
      SecretId: secretId,
      ClientRequestToken: token,
      SecretString: JSON.stringify({
        ...currentSecret,
        password: newPassword,
      }),
      VersionStages: ['AWSPENDING'],
    })
  );
}

async function setSecret(secretId: string, token: string) {
  // Récupérer les deux versions
  const [current, pending] = await Promise.all([
    secretsClient.send(
      new GetSecretValueCommand({
        SecretId: secretId,
        VersionStage: 'AWSCURRENT',
      })
    ),
    secretsClient.send(
      new GetSecretValueCommand({
        SecretId: secretId,
        VersionStage: 'AWSPENDING',
        VersionId: token,
      })
    ),
  ]);

  const currentCreds = JSON.parse(current.SecretString!);
  const pendingCreds = JSON.parse(pending.SecretString!);

  // Connexion avec credentials actuels
  const client = new Client({
    host: currentCreds.host,
    port: currentCreds.port,
    user: 'postgres', // admin user
    password: currentCreds.adminPassword,
    database: currentCreds.database,
  });

  await client.connect();

  // Changer le mot de passe
  await client.query(
    `ALTER USER ${currentCreds.username} WITH PASSWORD '${pendingCreds.password}'`
  );

  await client.end();
}

async function testSecret(secretId: string, token: string) {
  // Récupérer le nouveau secret
  const pending = await secretsClient.send(
    new GetSecretValueCommand({
      SecretId: secretId,
      VersionStage: 'AWSPENDING',
      VersionId: token,
    })
  );

  const creds = JSON.parse(pending.SecretString!);

  // Tester la connexion
  const client = new Client({
    host: creds.host,
    port: creds.port,
    user: creds.username,
    password: creds.password,
    database: creds.database,
  });

  await client.connect();
  await client.query('SELECT 1');
  await client.end();
}

async function finishSecret(secretId: string, token: string) {
  // Promouvoir AWSPENDING vers AWSCURRENT
  await secretsClient.send(
    new UpdateSecretVersionStageCommand({
      SecretId: secretId,
      VersionStage: 'AWSCURRENT',
      MoveToVersionId: token,
      RemoveFromVersionId: undefined, // Sera récupéré automatiquement
    })
  );
}
```

### Configuration de la rotation

```hcl
# terraform/secrets.tf
resource "aws_secretsmanager_secret" "database" {
  name        = "${var.environment}/database"
  description = "Database credentials"

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_rotation" "database" {
  secret_id           = aws_secretsmanager_secret.database.id
  rotation_lambda_arn = aws_lambda_function.rotate_secret.arn

  rotation_rules {
    automatically_after_days = 30
  }
}

resource "aws_lambda_function" "rotate_secret" {
  filename         = "rotate-db-password.zip"
  function_name    = "${var.environment}-rotate-db-password"
  role             = aws_iam_role.rotation_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 30

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${var.region}.amazonaws.com"
    }
  }
}
```

## Étape 5 : Audit et monitoring

### Logging des accès

```typescript
// src/middleware/secretsAudit.ts
import { logger } from '../utils/logger';

export function auditSecretAccess(
  secretName: string,
  action: 'read' | 'write',
  success: boolean,
  context?: Record<string, unknown>
) {
  logger.info('Secret access', {
    event: 'secret_access',
    secretName,
    action,
    success,
    timestamp: new Date().toISOString(),
    ...context,
  });
}

// Wrapper pour getSecret avec audit
export async function getSecretAudited(
  secretName: string,
  requestContext?: { userId?: string; service?: string }
): Promise<string> {
  try {
    const secret = await getSecret(secretName);
    auditSecretAccess(secretName, 'read', true, requestContext);
    return secret;
  } catch (error) {
    auditSecretAccess(secretName, 'read', false, {
      ...requestContext,
      error: error instanceof Error ? error.message : 'Unknown error',
    });
    throw error;
  }
}
```

### CloudWatch Alarms

```hcl
# terraform/monitoring.tf
resource "aws_cloudwatch_metric_alarm" "secrets_access_denied" {
  alarm_name          = "${var.environment}-secrets-access-denied"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CallCount"
  namespace           = "AWS/SecretsManager"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "High rate of denied secrets access"

  dimensions = {
    Operation = "GetSecretValue"
    ErrorCode = "AccessDeniedException"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_log_metric_filter" "secret_rotation_failure" {
  name           = "secret-rotation-failure"
  pattern        = "{ $.eventName = RotateSecret && $.errorCode = * }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name      = "SecretRotationFailure"
    namespace = "Custom/SecretsManager"
    value     = "1"
  }
}
```

## Bonnes pratiques

### À faire

| Pratique | Raison |
|----------|--------|
| **Centraliser** | Un seul point de gestion |
| **Chiffrer** | Protection at rest et transit |
| **Rotation** | Limiter impact si compromis |
| **Audit** | Traçabilité complète |
| **Least privilege** | Accès minimal nécessaire |
| **Séparation env** | Secrets distincts par env |

### À éviter

| Anti-pattern | Risque | Solution |
|--------------|--------|----------|
| Secrets en code | Fuite via git | Secrets Manager |
| .env en prod | Non sécurisé | Vault/K8s Secrets |
| Partage secrets | Pas de traçabilité | Accès individuels |
| Pas de rotation | Compromis long terme | Rotation auto |
| Logs de secrets | Fuite | Ne jamais logger |

### Checklist sécurité

```markdown
## Checklist Secrets Management

### Stockage
- [ ] Aucun secret en dur dans le code
- [ ] .env dans .gitignore
- [ ] Secrets centralisés (Vault/Secrets Manager)
- [ ] Chiffrement at rest activé

### Accès
- [ ] IAM/RBAC configuré
- [ ] Principle of least privilege
- [ ] Accès audités (CloudTrail)
- [ ] Alertes sur accès suspects

### Rotation
- [ ] Rotation automatique configurée
- [ ] Tests de rotation validés
- [ ] Procédure de rotation d'urgence
- [ ] Applications gèrent rotation gracefully

### Développement
- [ ] Secrets de dev séparés
- [ ] Pas de secrets prod en local
- [ ] Pre-commit hooks pour détecter secrets
- [ ] Documentation des secrets nécessaires
```

## Output attendu

```markdown
## Secrets Management Implementation

### Inventaire
| Secret | Ancienne méthode | Nouvelle méthode | Status |
|--------|------------------|------------------|--------|
| DB_PASSWORD | .env | AWS Secrets Manager | ✅ Migré |
| JWT_SECRET | .env | AWS Secrets Manager | ✅ Migré |
| STRIPE_KEY | .env | AWS Secrets Manager | ✅ Migré |

### Configuration
- **Provider:** AWS Secrets Manager
- **Rotation:** 30 jours (automatique)
- **Audit:** CloudTrail activé
- **Alertes:** SNS configuré

### Accès
| Service | Secrets autorisés |
|---------|-------------------|
| API | database, jwt, stripe |
| Worker | database, sqs |
| Admin | tous (read-only) |
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/security` | Audit sécurité complet |
| `/infra-code` | Provisionner Secrets Manager |
| `/env` | Configuration environnements |
| `/ci` | Injection secrets en CI |
| `/audit` | Audit des accès |

---

IMPORTANT: JAMAIS de secrets dans le code ou les logs.

YOU MUST utiliser un gestionnaire de secrets centralisé.

YOU MUST activer la rotation automatique.

NEVER partager des secrets entre environnements.

Think hard sur qui a vraiment besoin d'accéder à chaque secret.
