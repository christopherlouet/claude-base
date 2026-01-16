# Agent HOTFIX

Workflow de correction urgente en production.

## Problème à corriger
$ARGUMENTS

## Workflow Hotfix

### 1. Classification de l'incident

| Sévérité | Description | Temps de réponse | Exemples |
|----------|-------------|------------------|----------|
| **P0 - Critique** | Service totalement indisponible | < 15 min | Crash total, perte de données |
| **P1 - Élevé** | Fonctionnalité majeure cassée | < 1h | Paiements KO, auth cassée |
| **P2 - Moyen** | Impact limité, workaround existe | < 4h | Bug UI, perf dégradée |
| **P3 - Faible** | Impact mineur | < 24h | Faute d'orthographe, style |

### 2. Évaluation de l'urgence
- [ ] Impact utilisateur (critique/élevé/moyen)
- [ ] Nombre d'utilisateurs affectés
- [ ] Workaround disponible ?
- [ ] Rollback possible ?
- [ ] Données utilisateurs compromises ?

### 3. Préparation
```bash
# Créer branche hotfix depuis main/production
git checkout main
git pull origin main
git checkout -b hotfix/[description-courte]
```

### 4. Diagnostic rapide
- Identifier la cause root (logs, monitoring)
- Localiser le code problématique
- Évaluer le scope du fix (1 fichier ? plusieurs ?)

### 5. Fix minimal
- IMPORTANT: Corriger UNIQUEMENT le problème immédiat
- IMPORTANT: Pas de refactoring, pas d'améliorations
- Le fix le plus petit et sûr possible

### 6. Validation accélérée
```bash
# Tests critiques uniquement
npm test -- --grep "critical"

# Smoke test manuel si possible
npm run build
```

### 7. Déploiement
```bash
# Commit avec référence au problème
git commit -m "hotfix: [description]

Fixes #[issue]
Impact: [description de l'impact]
Root cause: [cause identifiée]"

# PR vers main avec review accélérée
gh pr create --title "HOTFIX: [description]" --label "hotfix,urgent"
```

### 8. Post-mortem (après déploiement)
- [ ] Documenter l'incident
- [ ] Identifier les améliorations pour éviter récurrence
- [ ] Créer tickets pour corrections long-terme
- [ ] Merger hotfix dans develop

## Communication d'incident

### Pendant l'incident
```markdown
🔴 INCIDENT EN COURS - [Titre]
Statut: Investigation / Identification / Correction en cours
Impact: [Description de l'impact utilisateur]
Heure de début: [HH:MM UTC]
Prochaine mise à jour: [HH:MM UTC]
```

### Après résolution
```markdown
✅ INCIDENT RÉSOLU - [Titre]
Durée: [X heures Y minutes]
Cause: [Description courte]
Actions: [Ce qui a été fait]
Post-mortem: [Lien vers le document]
```

## Alternatives au hotfix

| Approche | Quand l'utiliser | Avantages |
|----------|------------------|-----------|
| **Feature flag** | Code déjà en prod, désactivable | Rollback instantané |
| **Rollback** | Version précédente stable | Rapide, sûr |
| **Forward fix** | Bug simple, fix rapide | Pas de perte de fonctionnalité |
| **Hotfix** | Correction urgente complexe | Ciblé, minimal |

## Checklist de sécurité

- [ ] Le fix n'introduit pas de régression
- [ ] Le fix n'expose pas de données sensibles
- [ ] Les logs ne contiennent pas d'info sensible
- [ ] Le fix a été testé en staging si possible
- [ ] Rollback préparé et testé

## Template de commit hotfix

```
hotfix(scope): description courte du fix

Incident: [lien vers incident/alert]
Impact: [X utilisateurs affectés pendant Y minutes]
Root cause: [description technique]

Fixes #[issue-number]
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/debug` | Diagnostiquer le problème |
| `/test` | Test de non-régression |
| `/release` | Release après hotfix |
| `/monitoring` | Vérifier post-déploiement |
| `/disaster-recovery` | Si incident majeur |

---

IMPORTANT: Vitesse ET sécurité. Ne pas sacrifier la sécurité pour la vitesse.

IMPORTANT: Un hotfix = UN problème. Pas de "tant qu'on y est".

YOU MUST tester le hotfix avant déploiement prod.

NEVER déployer un hotfix sans possibilité de rollback.
