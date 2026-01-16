# Agent AUDIT-FULL

Audit qualité complet d'un projet. Combine les analyses de sécurité, RGPD, accessibilité et performance.

## Contexte
$ARGUMENTS

## Périmètre de l'audit

Cet agent exécute les audits suivants :
1. Sécurité (OWASP Top 10)
2. RGPD (Conformité données personnelles)
3. Accessibilité (WCAG 2.1)
4. Performance (Core Web Vitals)
5. Qualité de code

---

## Phase 1 : Audit Sécurité (OWASP Top 10)

### 1.1 Explorer le code

```bash
# Structure du projet
tree -L 2 -I 'node_modules|.git|dist|build' 2>/dev/null

# Rechercher les patterns sensibles
grep -rn "password\|secret\|api.key\|token" --include="*.ts" --include="*.js" --include="*.env*" | head -20
```

### 1.2 Checklist OWASP

| # | Vulnérabilité | Statut | Détails |
|---|---------------|--------|---------|
| 1 | **Injection** (SQL, NoSQL, OS, LDAP) | ⬜ | |
| 2 | **Broken Authentication** | ⬜ | |
| 3 | **Sensitive Data Exposure** | ⬜ | |
| 4 | **XML External Entities (XXE)** | ⬜ | |
| 5 | **Broken Access Control** | ⬜ | |
| 6 | **Security Misconfiguration** | ⬜ | |
| 7 | **Cross-Site Scripting (XSS)** | ⬜ | |
| 8 | **Insecure Deserialization** | ⬜ | |
| 9 | **Known Vulnerabilities** | ⬜ | |
| 10 | **Insufficient Logging** | ⬜ | |

### 1.3 Vérifications supplémentaires

- [ ] HTTPS forcé
- [ ] Headers de sécurité (CSP, HSTS, X-Frame-Options)
- [ ] CORS configuré correctement
- [ ] Rate limiting en place
- [ ] Secrets hors du code (env vars)

### 1.4 Résultat Sécurité

```
Score Sécurité: [X/100]
Vulnérabilités critiques: [N]
Vulnérabilités hautes: [N]
Vulnérabilités moyennes: [N]
```

---

## Phase 2 : Audit RGPD

### 2.1 Données personnelles collectées

```bash
# Rechercher les modèles de données
grep -rn "email\|phone\|name\|address\|birth" --include="*.ts" --include="*.js" | head -20
```

| Donnée | Localisation | Base légale | Durée conservation |
|--------|--------------|-------------|-------------------|
| | | | |
| | | | |

### 2.2 Checklist RGPD

#### Consentement et information
- [ ] Bannière cookies conforme
- [ ] Cookies non-essentiels bloqués avant consentement
- [ ] Politique de confidentialité accessible
- [ ] Information claire sur l'usage des données

#### Droits des personnes
- [ ] Droit d'accès implémenté
- [ ] Droit de rectification implémenté
- [ ] Droit à l'effacement implémenté
- [ ] Droit à la portabilité implémenté

#### Sécurité des données
- [ ] Chiffrement en transit (HTTPS)
- [ ] Chiffrement au repos
- [ ] Accès restreint aux données
- [ ] Logs d'accès

#### Documentation
- [ ] Registre des traitements
- [ ] DPA avec sous-traitants
- [ ] Procédure de violation de données

### 2.3 Transferts hors UE

| Service | Localisation | Garantie |
|---------|--------------|----------|
| | | |

### 2.4 Résultat RGPD

```
Score RGPD: [X/100]
Non-conformités critiques: [N]
Non-conformités mineures: [N]
```

---

## Phase 3 : Audit Accessibilité (WCAG 2.1)

### 3.1 Vérifications automatisées

```bash
# Rechercher les images sans alt
grep -rn "<img" --include="*.tsx" --include="*.jsx" --include="*.html" | grep -v "alt=" | head -10

# Rechercher les boutons sans label
grep -rn "<button" --include="*.tsx" --include="*.jsx" | grep -v "aria-label\|>.*<" | head -10
```

### 3.2 Checklist WCAG 2.1 (Niveau AA)

#### Perceptible
- [ ] Textes alternatifs pour les images
- [ ] Sous-titres pour les vidéos
- [ ] Contraste suffisant (4.5:1 texte, 3:1 grands textes)
- [ ] Redimensionnement jusqu'à 200% sans perte

#### Utilisable
- [ ] Navigation au clavier complète
- [ ] Pas de piège clavier
- [ ] Focus visible
- [ ] Liens d'évitement
- [ ] Titres de page descriptifs

#### Compréhensible
- [ ] Langue de la page définie
- [ ] Labels sur les champs de formulaire
- [ ] Messages d'erreur clairs
- [ ] Navigation cohérente

#### Robuste
- [ ] HTML valide
- [ ] ARIA utilisé correctement
- [ ] Compatible lecteurs d'écran

### 3.3 Résultat Accessibilité

```
Score Accessibilité: [X/100]
Niveau visé: AA
Erreurs critiques: [N]
Erreurs mineures: [N]
```

---

## Phase 4 : Audit Performance

### 4.1 Core Web Vitals

| Métrique | Cible | Actuel | Statut |
|----------|-------|--------|--------|
| **LCP** (Largest Contentful Paint) | < 2.5s | | ⬜ |
| **FID** (First Input Delay) | < 100ms | | ⬜ |
| **CLS** (Cumulative Layout Shift) | < 0.1 | | ⬜ |

### 4.2 Checklist Performance

#### Frontend
- [ ] Images optimisées (WebP, lazy loading)
- [ ] CSS/JS minifiés
- [ ] Code splitting implémenté
- [ ] Cache navigateur configuré
- [ ] CDN utilisé

#### Backend
- [ ] Requêtes DB optimisées
- [ ] Indexes appropriés
- [ ] Cache serveur (Redis, etc.)
- [ ] Compression activée (gzip/brotli)

#### Réseau
- [ ] HTTP/2 ou HTTP/3
- [ ] Compression des assets
- [ ] Prefetch/preload stratégique

### 4.3 Résultat Performance

```
Score Performance: [X/100]
LCP: [valeur]
FID: [valeur]
CLS: [valeur]
```

---

## Phase 5 : Qualité de Code

### 5.1 Analyse statique

```bash
# Vérifier les dépendances
npm audit 2>/dev/null || echo "npm audit non disponible"

# Linting
npm run lint 2>/dev/null || echo "Linting non configuré"
```

### 5.2 Checklist Qualité

#### Structure
- [ ] Architecture claire et documentée
- [ ] Séparation des responsabilités
- [ ] Pas de code dupliqué excessif
- [ ] Nommage cohérent

#### Tests
- [ ] Tests unitaires présents
- [ ] Couverture > 80%
- [ ] Tests d'intégration
- [ ] Tests E2E (si applicable)

#### Maintenance
- [ ] Dépendances à jour
- [ ] Pas de vulnérabilités connues
- [ ] Documentation technique
- [ ] README à jour

### 5.3 Résultat Qualité

```
Score Qualité: [X/100]
Couverture tests: [X%]
Vulnérabilités deps: [N]
```

---

## Rapport Final

### Scores Globaux

```
┌─────────────────────────────────────────────────┐
│           RAPPORT D'AUDIT COMPLET               │
├─────────────────────────────────────────────────┤
│                                                 │
│  Sécurité      [████████░░] 80%                │
│  RGPD          [██████░░░░] 60%                │
│  Accessibilité [███████░░░] 70%                │
│  Performance   [█████████░] 90%                │
│  Qualité       [████████░░] 80%                │
│                                                 │
│  SCORE GLOBAL  [███████░░░] 76%                │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Synthèse par domaine

| Domaine | Score | Critique | Haute | Moyenne | Basse |
|---------|-------|----------|-------|---------|-------|
| Sécurité | /100 | | | | |
| RGPD | /100 | | | | |
| Accessibilité | /100 | | | | |
| Performance | /100 | | | | |
| Qualité | /100 | | | | |

### Problèmes Critiques (Action immédiate)

| # | Domaine | Problème | Impact | Recommandation |
|---|---------|----------|--------|----------------|
| 1 | | | | |
| 2 | | | | |

### Problèmes Importants (À planifier)

| # | Domaine | Problème | Impact | Recommandation |
|---|---------|----------|--------|----------------|
| 1 | | | | |
| 2 | | | | |

### Améliorations Suggérées (Nice-to-have)

| # | Domaine | Suggestion | Bénéfice |
|---|---------|------------|----------|
| 1 | | | |
| 2 | | | |

### Plan d'Action Priorisé

#### Priorité 1 - Critique (Cette semaine)
1. [Action 1]
2. [Action 2]

#### Priorité 2 - Haute (Ce mois)
1. [Action 1]
2. [Action 2]

#### Priorité 3 - Moyenne (Ce trimestre)
1. [Action 1]
2. [Action 2]

### Checklist de Remédiation

- [ ] [Action critique 1]
- [ ] [Action critique 2]
- [ ] [Action haute 1]
- [ ] [Action haute 2]
- [ ] [Action moyenne 1]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/security` | Audit sécurité approfondi |
| `/rgpd` | Audit RGPD approfondi |
| `/a11y` | Audit accessibilité approfondi |
| `/perf` | Audit performance approfondi |
| `/health` | Check rapide avant audit |

---

IMPORTANT: Cet audit fournit une vue d'ensemble. Pour un audit approfondi d'un domaine spécifique, utiliser l'agent dédié (/security, /rgpd, /a11y, /perf).

YOU MUST prioriser les problèmes par criticité et fournir des actions concrètes.

NEVER ignorer les problèmes critiques de sécurité - ils doivent être corrigés immédiatement.

Think hard sur les interdépendances entre les domaines (ex: sécurité impacte RGPD).
