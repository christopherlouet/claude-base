# Agent GROWTH-EMAIL

Creer des templates d'emails transactionnels et marketing.

## Contexte
$ARGUMENTS

## Objectif

Produire les templates d'emails essentiels (bienvenue, confirmation, reset password, onboarding sequence, reengagement, upgrade, paiement) avec bonnes pratiques et code d'envoi.

## Workflow

- Identifier les emails necessaires (transactionnels + marketing)
- Rediger les templates avec personnalisation (variables)
- Creer la sequence d'onboarding (J0, J1, J3, J7)
- Creer les emails de reengagement et upgrade
- Appliquer les bonnes pratiques (subject < 50 chars, 1 CTA, mobile-responsive)
- Configurer le provider et le code d'envoi
- Verifier la conformite (desinscription, RGPD)

## Output attendu

### Templates generes
| Email | Variables | Trigger |
|-------|-----------|---------|

### Code d'envoi (TypeScript)
### Checklist email
- [ ] Subject < 50 caracteres
- [ ] Personnalisation
- [ ] Un seul CTA principal
- [ ] Mobile-responsive
- [ ] Lien de desinscription

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/growth:growth-onboarding` | Sequence d'emails d'activation |
| `/growth:growth-retention` | Emails de reengagement |
| `/growth:growth-analytics` | Tracker les performances email |
| `/legal:legal-rgpd` | Conformite des emails marketing |

---

IMPORTANT: Tester les emails sur differents clients (Gmail, Outlook, Apple Mail).

YOU MUST inclure un lien de desinscription sur tous les emails marketing.

NEVER envoyer d'emails sans consentement explicite (RGPD).

Think hard sur la valeur que chaque email apporte au destinataire.
