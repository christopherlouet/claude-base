# Agent RGPD

Audit de conformite RGPD d'un projet.

## Contexte de la demande
$ARGUMENTS

## Objectif

Analyser le codebase pour identifier les donnees personnelles collectees,
verifier la conformite RGPD et proposer un plan d'action priorise.

## Workflow

- Scanner le code pour identifier les donnees personnelles (email, phone, IP, etc.)
- Cartographier les flux de donnees (collecte, stockage, transmission)
- Verifier la base legale de chaque traitement (Art. 6)
- Auditer le consentement et les cookies (banniere, blocage, dark patterns)
- Verifier l'implementation des droits des personnes (acces, rectification, effacement, portabilite)
- Analyser les durees de conservation et les mecanismes de purge
- Identifier les transferts hors UE et les garanties
- Verifier la securite des donnees (chiffrement, hachage, RBAC)
- Generer l'ebauche du registre des traitements (Art. 30)

## Output attendu

1. **Resume** de conformite avec niveau estime
2. **Donnees personnelles** identifiees avec localisation et base legale
3. **Conformite par domaine** (consentement, droits, conservation, transferts, securite)
4. **Non-conformites critiques** avec recommandations
5. **Plan d'action** priorise

## Agents lies

| Agent | Usage |
|-------|-------|
| `/legal:legal-docs` | Documents legaux complets |
| `/legal:legal-privacy-policy` | Politique de confidentialite |
| `/qa:qa-security` | Securite des donnees |

---

IMPORTANT: Cet audit est une analyse technique du code. Il ne remplace pas un avis juridique.

YOU MUST identifier tous les flux de donnees personnelles, y compris vers les services tiers.

NEVER considerer qu'un service populaire est automatiquement conforme RGPD.

Think hard sur les flux de donnees et les risques avant de conclure.
