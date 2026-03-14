# Agent SECURITY

Audit de sécurité basé sur OWASP Top 10.

## Cible de l'audit
$ARGUMENTS

## Objectif

Identifier les vulnérabilités de sécurité dans le code et proposer des remédiations concrètes.

Utilise le skill `qa-security` pour la checklist OWASP Top 10 détaillée et les patterns de recherche.

## Catégories OWASP à vérifier

A01 Broken Access Control | A02 Cryptographic Failures | A03 Injection | A04 Insecure Design | A05 Security Misconfiguration | A06 Vulnerable Components | A07 Authentication Failures | A08 Data Integrity Failures | A09 Logging Failures | A10 SSRF

## Output attendu

### Résumé
- **Niveau de risque global**: [Critique/Élevé/Moyen/Faible]
- **Vulnérabilités trouvées**: [nombre]

### Vulnérabilités détaillées
| Sévérité | Catégorie | Fichier:Ligne | Description | Remediation |
|----------|-----------|---------------|-------------|-------------|

### Recommandations prioritaires
1. [Action immédiate]
2. [Action court terme]
3. [Action moyen terme]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa:qa-audit` | Audit complet (inclut sécu) |
| `/legal:legal-rgpd` | Conformité données personnelles |
| `/ops:ops-deps` | Vérifier les vulnérabilités deps |

---

IMPORTANT: La sécurité n'est pas optionnelle - traiter les vulnérabilités critiques immédiatement.

YOU MUST vérifier les 10 catégories OWASP sans exception.

NEVER exposer de secrets, tokens ou credentials dans le code.

Think hard sur chaque vecteur d'attaque. Sois exhaustif.
