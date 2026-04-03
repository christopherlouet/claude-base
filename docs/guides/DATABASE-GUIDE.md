# Guide Base de Donnees

> Conception, migrations, indexation et optimisation pour des bases de donnees robustes et maintenables

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Relationnel | PostgreSQL, MySQL, SQLite |
| Document | MongoDB |
| Cache / KV | Redis |
| ORM / Query builder | Prisma, TypeORM, Drizzle, SQLAlchemy, GORM |
| Migrations | Prisma Migrate, Alembic, Flyway, golang-migrate, Knex |
| Pooling | PgBouncer, Prisma connection pool, pgpool-II |

## Workflow Recommande

```
/work:work-explore → /work:work-plan → /dev:dev-prisma → /dev:dev-tdd → /qa:qa-loop "score 90" → /work:work-pr
```

## Phase 1: Choix de la Base de Donnees

### Decision table

| Base | Cas d'usage ideal | Eviter si |
|------|-------------------|-----------|
| **PostgreSQL** | Donnees relationnelles complexes, ACID strict, requetes analytiques, JSON semi-structure | Volume < 10 Mo et deploy ultra-simple |
| **MySQL** | Applications web classiques, ecosysteme PHP/Laravel etabli | Requetes analytiques complexes, JSON natif avance |
| **SQLite** | Developpement local, applications embarquees, CLI tools, tests | Multi-processus concurrents, > 1 To de donnees |
| **MongoDB** | Documents heterogenes, schemas evolutifs, logs, catalogues produit | Relations complexes, transactions multi-documents critiques |
| **Redis** | Cache, sessions, pub/sub, rate limiting, leaderboards | Persistence principale, donnees > RAM disponible |

### Managed vs self-hosted

| Critere | Managed (RDS, Supabase, Atlas) | Self-hosted |
|---------|-------------------------------|-------------|
| Operations | Backups, patches auto | Responsabilite equipe |
| Cout | Plus cher a volume egal | Infrastructure propre |
| Scalabilite | Read replicas en quelques clics | Configuration manuelle |
| Controle | Limite (pas d'acces OS) | Total |
| Recommande pour | Startups, equipes sans DBA | Gros volumes, RGPD strict |

## Phase 2: Design de Schema

### Normalisation

| Forme | Regle | Quand denormaliser |
|-------|-------|--------------------|
| **1NF** | Valeurs atomiques, pas de groupes repetitifs | Jamais d'exception |
| **2NF** | Pas de dependance partielle sur la cle primaire | Jamais d'exception |
| **3NF** | Pas de dependance transitive (colonne → colonne → cle) | Reporting intensif, performances critiques |
| **Denormalise** | Colonnes dupliquees deliberement | OLAP, caches calcules, agregats frequents |

La regle pratique : normaliser par defaut, denormaliser apres mesure. Ne jamais denormaliser par anticipation.

### Conventions de nommage

| Element | Convention | Exemple |
|---------|-----------|---------|
| Tables | Pluriel snake_case | `user_accounts`, `order_items` |
| Colonnes | snake_case | `created_at`, `first_name` |
| Cle primaire | `id` | `id` |
| Cle etrangere | `{table_singulier}_id` | `user_id`, `product_id` |
| Index | `idx_{table}_{colonne(s)}` | `idx_orders_user_id` |
| Index unique | `uq_{table}_{colonne(s)}` | `uq_users_email` |
| Contrainte check | `chk_{table}_{description}` | `chk_products_price_positive` |

### Schema Prisma bien concu

```prisma
// schema.prisma
model User {
  id        String    @id @default(cuid())
  email     String    @unique
  firstName String
  lastName  String
  role      UserRole  @default(CUSTOMER)
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  deletedAt DateTime? // soft delete

  orders    Order[]

  @@index([email])
  @@index([createdAt])
  @@map("users")
}

model Order {
  id          String      @id @default(cuid())
  userId      String
  status      OrderStatus @default(PENDING)
  totalAmount Decimal     @db.Decimal(10, 2)
  currency    String      @default("EUR") @db.Char(3)
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt

  user  User        @relation(fields: [userId], references: [id])
  items OrderItem[]

  @@index([userId])
  @@index([status, createdAt])
  @@map("orders")
}

model OrderItem {
  id        String  @id @default(cuid())
  orderId   String
  productId String
  quantity  Int
  unitPrice Decimal @db.Decimal(10, 2)

  order   Order   @relation(fields: [orderId], references: [id], onDelete: Cascade)
  product Product @relation(fields: [productId], references: [id])

  @@index([orderId])
  @@index([productId])
  @@map("order_items")
}

enum UserRole   { ADMIN CUSTOMER }
enum OrderStatus { PENDING CONFIRMED SHIPPED DELIVERED CANCELLED }
```

### Modele SQLAlchemy (Python)

```python
# models/order.py
import enum
from datetime import datetime
from decimal import Decimal
from sqlalchemy import String, Numeric, DateTime, ForeignKey, Enum as SAEnum, Index
from sqlalchemy.orm import relationship, Mapped, mapped_column, DeclarativeBase

class Base(DeclarativeBase):
    pass

class OrderStatus(enum.Enum):
    PENDING = "pending"; CONFIRMED = "confirmed"
    SHIPPED = "shipped"; DELIVERED = "delivered"; CANCELLED = "cancelled"

class Order(Base):
    __tablename__ = "orders"

    id          : Mapped[str]         = mapped_column(String(26), primary_key=True)
    user_id     : Mapped[str]         = mapped_column(String(26), ForeignKey("users.id"), nullable=False)
    status      : Mapped[OrderStatus] = mapped_column(SAEnum(OrderStatus), default=OrderStatus.PENDING)
    total_amount: Mapped[Decimal]     = mapped_column(Numeric(10, 2), nullable=False)
    currency    : Mapped[str]         = mapped_column(String(3), default="EUR")
    created_at  : Mapped[datetime]    = mapped_column(DateTime, default=datetime.utcnow)
    updated_at  : Mapped[datetime]    = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user  = relationship("User", back_populates="orders")
    items = relationship("OrderItem", cascade="all, delete-orphan")

    __table_args__ = (
        Index("idx_orders_user_id", "user_id"),
        Index("idx_orders_status_created_at", "status", "created_at"),
    )
```

## Phase 3: Migrations

### Workflow de migration

```
Schema change identifie
    --> Ecrire migration (fichier versionne)
    --> Review (checklist safe migration)
    --> Appliquer en staging + verifier donnees
    --> Appliquer en production (zero-downtime si necessaire)
    --> Verifier metriques post-deploy
```

### Comparaison des outils

| Outil | Ecosysteme | Points forts | Limites |
|-------|-----------|--------------|---------|
| **Prisma Migrate** | Node.js / TypeScript | Schema-first, DX excellent, type-safe | Lie a Prisma Client |
| **Alembic** | Python / SQLAlchemy | Auto-generation, flexible | Verbeux, conflits sur branches |
| **Flyway** | JVM / tout backend | Simple, robuste, SQL pur | Pas d'auto-generation |
| **golang-migrate** | Go | Leger, SQL pur, CI-friendly | Pas d'auto-generation |
| **Knex** | Node.js | JS/TS natif, agnostique ORM | Moins type-safe que Prisma |

### Migration Prisma

```bash
# 1. Modifier schema.prisma, puis generer la migration
npx prisma migrate dev --name add_shipping_address_to_orders

# 2. La migration generee (migrations/20240315_add_shipping_address_to_orders/migration.sql)
```

```sql
-- migrations/20240315_add_shipping_address_to_orders/migration.sql

-- Etape 1: ajouter nullable (zero-downtime safe)
ALTER TABLE "orders" ADD COLUMN "shipping_address_id" TEXT;

-- Etape 2: backfill si necessaire (en script separe)
-- UPDATE "orders" SET "shipping_address_id" = ... WHERE ...;

-- Etape 3: contrainte NOT NULL dans une migration suivante
-- ALTER TABLE "orders" ALTER COLUMN "shipping_address_id" SET NOT NULL;

-- Index sur la nouvelle colonne
CREATE INDEX "idx_orders_shipping_address_id" ON "orders"("shipping_address_id");
```

```bash
# Appliquer en production
npx prisma migrate deploy
```

### Migration Alembic (Python)

```bash
alembic revision --autogenerate -m "add_shipping_address_to_orders"
alembic upgrade head   # appliquer
alembic downgrade -1   # rollback
```

```python
# alembic/versions/20240315_add_shipping_address.py
def upgrade() -> None:
    op.add_column('orders', sa.Column('shipping_address_id', sa.String(26), nullable=True))
    op.create_index('idx_orders_shipping_address_id', 'orders', ['shipping_address_id'])
    op.create_foreign_key('fk_orders_shipping_address_id', 'orders', 'addresses',
                          ['shipping_address_id'], ['id'])

def downgrade() -> None:
    op.drop_constraint('fk_orders_shipping_address_id', 'orders')
    op.drop_index('idx_orders_shipping_address_id', 'orders')
    op.drop_column('orders', 'shipping_address_id')
```

### Pratiques safe migration

| A FAIRE | A NE PAS FAIRE |
|---------|----------------|
| Ajouter une colonne nullable en premier | Ajouter une colonne NOT NULL sans valeur par defaut |
| Backfiller les donnees avant la contrainte NOT NULL | Renommer une colonne directement (utiliser add + backfill + drop) |
| Creer les index CONCURRENTLY (PostgreSQL) | Creer un index sans CONCURRENTLY (lock table) |
| Tester la migration sur un dump de production | Tester uniquement en local avec peu de donnees |
| Versionner chaque migration avec horodatage | Modifier une migration deja appliquee |
| Prevoir un downgrade() | Ignorer la rollback strategy |

### Zero-downtime : renommer une colonne

```
Migration 1 : ajouter new_column (nullable)
      |
Application v2 : ecrire dans old_column ET new_column
      |
Migration 2 : backfiller new_column depuis old_column
      |
Application v3 : lire depuis new_column uniquement
      |
Migration 3 : supprimer old_column
```

## Phase 4: Strategie d'Indexation

### Quand indexer

| Situation | Action |
|-----------|--------|
| Cle etrangere | Toujours indexer |
| Colonne utilisee dans WHERE frequemment | Indexer |
| Colonne utilisee dans ORDER BY | Indexer (index couvrant si possible) |
| Colonne a tres faible cardinalite (booleen) | Eviter, peu selectif |
| Table < 10 000 lignes | Index optionnel, seq scan souvent plus rapide |
| Colonne modifiee tres frequemment | Evaluer le cout en ecriture |

### Types d'index PostgreSQL

| Type | Usage | Exemple |
|------|-------|---------|
| **B-tree** | Egalite, ranges, ORDER BY (defaut) | `WHERE created_at > '2024-01-01'` |
| **Hash** | Egalite pure uniquement | `WHERE email = 'x@y.com'` (rare, B-tree souvent meilleur) |
| **GIN** | Tableaux, JSONB, full-text search | `WHERE tags @> '{promo}'` |
| **GiST** | Geometrie, ranges, full-text | `WHERE location && ST_MakeEnvelope(...)` |
| **BRIN** | Tres grandes tables ordonnees physiquement | Tables de logs par date |
| **Partiel** | Sous-ensemble de lignes | `WHERE deleted_at IS NULL` |

### Exemples d'indexation

```sql
-- Cle etrangere (toujours)
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Composite pour filtre + tri: WHERE status = 'PENDING' ORDER BY created_at DESC
CREATE INDEX idx_orders_status_created_at ON orders(status, created_at DESC);

-- Partiel: seulement les lignes actives
CREATE INDEX idx_orders_active ON orders(user_id, created_at)
WHERE status NOT IN ('DELIVERED', 'CANCELLED');

-- CONCURRENTLY: sans lock table en production
CREATE INDEX CONCURRENTLY idx_products_category_id ON products(category_id);

-- GIN pour full-text search
CREATE INDEX idx_products_search ON products
USING GIN (to_tsvector('french', name || ' ' || description));
```

### Interpreter EXPLAIN ANALYZE

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.id, o.total_amount, u.email
FROM orders o JOIN users u ON u.id = o.user_id
WHERE o.status = 'PENDING' ORDER BY o.created_at DESC LIMIT 20;
```

| Indicateur | Signification | Seuil d'alerte |
|-----------|---------------|----------------|
| `Seq Scan` sur grande table | Pas d'index utilise | > 10 000 lignes |
| `actual time=X..Y` | Temps reel en ms | > 100 ms a investiguer |
| `rows=N` vs `actual rows=N` | Ecart stats/realite planificateur | Facteur > 10 : lancer ANALYZE |
| `Buffers: hit=N read=M` | Cache hits vs I/O disque | Ratio hit/(hit+read) < 90% |
| `Nested Loop` sur grand set | JOIN sans index efficace | Envisager Hash Join |

## Phase 5: Optimisation des Requetes

### Probleme N+1

```typescript
// MAL: N+1 - 1 requete users + N requetes orders
const users = await prisma.user.findMany();
for (const user of users) {
  user.orders = await prisma.order.findMany({ where: { userId: user.id } });
}

// BIEN: 1 requete avec include (JOIN genere)
const users = await prisma.user.findMany({
  include: {
    orders: {
      where: { status: 'PENDING' },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
  },
});

// BIEN: select uniquement les champs necessaires
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    orders: {
      select: { id: true, totalAmount: true, status: true },
    },
  },
});
```

### Pagination : offset vs cursor

| Critere | Offset `LIMIT x OFFSET y` | Cursor `WHERE id > last_id` |
|---------|--------------------------|----------------------------|
| Complexite implementation | Simple | Moderee |
| Performance (grande table) | O(offset) - ralentit | O(1) - constant |
| Saut de page | Supporte | Non supporte |
| Donnees stables | Duplicats si insertion | Stable |
| Cas d'usage | Admin, petites tables | Feed infini, API publique |

```typescript
// Pagination cursor-based avec Prisma
async function getOrdersCursor(cursor?: string, limit = 20) {
  const orders = await prisma.order.findMany({
    take: limit + 1, // +1 pour detecter s'il y a une page suivante
    cursor: cursor ? { id: cursor } : undefined,
    orderBy: { createdAt: 'desc' },
    skip: cursor ? 1 : 0, // skip le curseur lui-meme
  });

  const hasNextPage = orders.length > limit;
  const items = hasNextPage ? orders.slice(0, -1) : orders;

  return {
    items,
    nextCursor: hasNextPage ? items[items.length - 1].id : null,
  };
}
```

### Connection pooling

```typescript
// prisma/client.ts - Singleton avec pool configure
import { PrismaClient } from '@prisma/client';
const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'warn', 'error'] : ['error'],
});
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

```ini
# Parametres de pool dans DATABASE_URL
DATABASE_URL="postgresql://user:pass@host:5432/db?connection_limit=10&pool_timeout=20"
```

| Parametre | Valeur recommandee | Description |
|-----------|-------------------|-------------|
| `connection_limit` | CPU * 2 + 1 | Connexions max par instance |
| `pool_timeout` | 20 s | Attente max pour une connexion libre |
| PgBouncer mode | transaction | Partage connexions entre workers |

## Phase 6: Backup et Recovery

### Strategies de backup

| Methode | Outil | RPO | RTO | Usage |
|---------|-------|-----|-----|-------|
| Dump logique | `pg_dump` | Horaire/quotidien | Lent (restore) | Dev, petites BDD |
| Backup physique | `pg_basebackup` | Quotidien | Rapide | Production medium |
| WAL archiving | `pgBackRest`, `WAL-G` | < 5 min | Rapide | Production critique |
| Managed snapshots | AWS RDS, Supabase | 5 min (PITR) | Quelques minutes | Recommande par defaut |

```bash
# Dump logique PostgreSQL
pg_dump \
  --format=custom \
  --compress=9 \
  --no-acl \
  --no-owner \
  "$DATABASE_URL" > backup_$(date +%Y%m%d_%H%M%S).dump

# Restore
pg_restore \
  --format=custom \
  --clean \
  --no-acl \
  --no-owner \
  --dbname="$TARGET_DATABASE_URL" \
  backup_20240315_020000.dump
```

### Point-in-time recovery et tests de restore

```bash
# WAL-G: archivage continu PostgreSQL vers S3
export WALG_S3_PREFIX="s3://my-bucket/wal"
wal-g backup-fetch /var/lib/postgresql/data LATEST
# recovery.conf: recovery_target_time = '2024-03-15 14:30:00'
```

| Frequence | Action |
|-----------|--------|
| Hebdomadaire | Restore automatise sur environnement de test |
| Mensuelle | Restore complet + validation applicative |
| A chaque incident | Restore isole + verification donnees |

Un backup non teste est un backup dont on ne connait pas l'etat. Automatiser les restore drills.

## Phase 7: Patterns Avances

### Soft delete vs hard delete

| Critere | Soft delete (`deleted_at`) | Hard delete |
|---------|--------------------------|-------------|
| Audit trail | Automatique | Necessite log externe |
| Performance | Index partiel requis | Table plus petite |
| RGPD (droit a l'oubli) | Complexe (purge differee) | Simple |
| Jointures | Toujours filtrer `deleted_at IS NULL` | Aucun filtre |
| Recommande pour | Entites metier, contenus utilisateur | Donnees techniques, logs |

```sql
-- Index partiel pour soft delete: ignorer les deleted dans les requetes courantes
CREATE INDEX idx_users_active ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_user_active ON orders(user_id, created_at)
WHERE deleted_at IS NULL;
```

### Audit trail

```prisma
model AuditLog {
  id         String   @id @default(cuid())
  entityType String   // "Order", "User", ...
  entityId   String
  action     String   // "CREATE", "UPDATE", "DELETE"
  oldValues  Json?
  newValues  Json?
  userId     String?
  ipAddress  String?
  createdAt  DateTime @default(now())

  @@index([entityType, entityId])
  @@index([userId, createdAt])
  @@map("audit_logs")
}
```

### Multi-tenancy patterns

| Pattern | Isolation | Complexite | Scalabilite | Cas d'usage |
|---------|-----------|------------|-------------|-------------|
| **Schema par tenant** | Forte | Moyenne | Bonne | SaaS B2B < 1000 tenants |
| **Row-level security (RLS)** | Bonne via Postgres | Faible | Excellente | SaaS B2C, Supabase |
| **Base par tenant** | Maximale | Elevee | Limitee | Tres gros comptes, compliance |

```sql
-- Row-level security PostgreSQL
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON orders
  USING (tenant_id = current_setting('app.current_tenant_id')::text);
-- Avant chaque requete applicative: SET LOCAL app.current_tenant_id = 'tenant_abc';
```

### Read replicas et routage

```typescript
// Prisma: deux instances pour router lecture/ecriture
const prismaWrite = new PrismaClient({ datasources: { db: { url: process.env.DATABASE_URL_PRIMARY } } });
const prismaRead  = new PrismaClient({ datasources: { db: { url: process.env.DATABASE_URL_REPLICA } } });

const products = await prismaRead.product.findMany({ where: { active: true } }); // replica
const order    = await prismaWrite.order.create({ data: orderData });            // primaire
```

## Commandes Socle

### Modelisation et gestion schema

```bash
# Modeliser un schema depuis une description metier
/data:data-modeling "schema e-commerce: users, products, orders, reviews"

# Generer ou modifier le schema Prisma
/dev:dev-prisma "ajouter la relation order → shipment avec tracking"

# Appliquer et versionner les migrations
/dev:dev-prisma "migration: renommer billing_address en invoice_address (zero-downtime)"
```

### Operations base de donnees

```bash
# Audit performance: index manquants, requetes lentes, N+1
/ops:ops-database "analyser les slow queries sur la table orders"

# Backup, restore, maintenance
/ops:ops-database "configurer pg_dump quotidien + rotation 30 jours"
```

### Workflow complet nouvelle entite

```bash
1. /data:data-modeling    # Schema + relations
2. /dev:dev-prisma        # Migration + model type-safe
3. /dev:dev-tdd           # Tests repository
4. /qa:qa-loop "score 90" # Audit qualite
5. /work:work-pr          # Pull Request
```

## Anti-patterns a Eviter

- Aucun index sur les cles etrangeres : chaque JOIN devient un seq scan
- `SELECT *` : transfert de colonnes inutiles, rupture si schema change
- Pas de connection pooling : epuisement des connexions sous charge
- Stocker des JSON blobs au lieu de relations : impossible a querier efficacement, pas de contraintes
- Modifier le schema manuellement en production sans migration versionee
- Creer un index sans CONCURRENTLY sur une table de production (lock complet)
- Ignorer EXPLAIN ANALYZE : optimiser sans mesurer
- Backups non testes : faux sentiment de securite
- Renommer une colonne en une seule migration sur une app sans downtime
- Oublier de filtrer `deleted_at IS NULL` sur les tables avec soft delete

## Ressources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Prisma Data Guide](https://www.prisma.io/dataguide)
- [Use The Index, Luke](https://use-the-index-luke.com)
- [pganalyze EXPLAIN Viewer](https://explain.depesz.com)
- [WAL-G Backup Tool](https://github.com/wal-g/wal-g)
