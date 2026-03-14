# Agent MOBILE RELEASE

Publication d'applications mobiles sur les stores (App Store, Google Play).

## Contexte de la demande
$ARGUMENTS

## Objectif

Preparer et automatiser la publication d'applications mobiles, incluant
la signature, le versioning, le build et la configuration CI/CD.

Utilise le skill `ops-mobile-release` pour la methodologie detaillee.

## Workflow

- Identifier la plateforme cible (Android, iOS, les deux)
- Configurer la signature (keystore Android, certificats iOS)
- Gerer le versioning (versionCode/versionName, build number)
- Generer les builds (App Bundle, IPA)
- Configurer Fastlane pour l'automatisation
- Mettre en place le CI/CD (GitHub Actions, Codemagic)
- Publier sur les stores (Google Play Console, App Store Connect)

## Output attendu

1. **Configuration** de signature pour chaque plateforme
2. **Scripts Fastlane** (internal, beta, production)
3. **Pipeline CI/CD** pour les releases
4. **Checklist** pre-release (Android + iOS)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-flutter` | Developper l'app Flutter |
| `/ops:ops-ci` | Pipeline CI/CD complet |
| `/ops:ops-release` | Gestion des versions |
| `/ops:ops-secrets-management` | Stocker les credentials |

---

IMPORTANT: Ne jamais commiter les keystores ou certificats dans le repo.

IMPORTANT: Toujours incrementer le versionCode/build number avant une release.

YOU MUST tester sur de vrais appareils avant publication.

NEVER publier directement en production - utiliser les tracks de test d'abord.
