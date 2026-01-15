# Agent GROWTH-EMAIL

Créer des templates d'emails transactionnels et marketing.

## Contexte
$ARGUMENTS

## Types d'emails

### 1. Emails transactionnels

| Type | Trigger | Priorité |
|------|---------|----------|
| Bienvenue | Inscription | Haute |
| Confirmation email | Inscription | Critique |
| Reset password | Demande user | Critique |
| Confirmation commande | Achat | Critique |
| Facture | Paiement | Haute |
| Notification | Action système | Moyenne |

### 2. Emails marketing

| Type | Objectif | Fréquence |
|------|----------|-----------|
| Newsletter | Engagement | Hebdo/Mensuel |
| Onboarding séquence | Activation | J1, J3, J7 |
| Réengagement | Rétention | Après inactivité |
| Upgrade | Conversion | Contextuel |
| Feedback | NPS/Review | Post-usage |

## Templates

### 3. Email de bienvenue

```html
Subject: Bienvenue sur [App] ! 🎉

Bonjour {{firstName}},

Merci d'avoir rejoint [App] !

Vous faites maintenant partie des {{totalUsers}} utilisateurs
qui [bénéfice principal].

**Prochaines étapes :**

1. ✅ Créer votre compte - Fait !
2. 📝 Compléter votre profil (2 min)
3. 🚀 [Première action clé]

[CTA: Commencer maintenant →]

**Besoin d'aide ?**
- 📖 Guide de démarrage : [lien]
- 💬 Support : [email]
- 🎥 Vidéo tutoriel : [lien]

À très vite,
L'équipe [App]

---
[App] - [Tagline]
[Liens réseaux sociaux]
[Lien de désinscription]
```

### 4. Confirmation d'email

```html
Subject: Confirmez votre adresse email

Bonjour {{firstName}},

Cliquez sur le bouton ci-dessous pour confirmer votre email :

[CTA: Confirmer mon email]

Ce lien expire dans 24 heures.

Si vous n'êtes pas à l'origine de cette inscription,
ignorez simplement cet email.

L'équipe [App]

---
Lien direct : {{confirmationUrl}}
```

### 5. Reset de mot de passe

```html
Subject: Réinitialisation de votre mot de passe

Bonjour {{firstName}},

Vous avez demandé à réinitialiser votre mot de passe.

[CTA: Réinitialiser mon mot de passe]

Ce lien expire dans 1 heure.

**Vous n'avez pas fait cette demande ?**
Ignorez cet email. Votre mot de passe restera inchangé.

Pour votre sécurité, nous vous recommandons :
- Un mot de passe unique d'au moins 12 caractères
- L'utilisation d'un gestionnaire de mots de passe

L'équipe [App]
```

### 6. Séquence d'onboarding

#### J+0 (Inscription)
```html
Subject: Bienvenue ! Voici comment démarrer

[Voir template bienvenue]
```

#### J+1 (Setup)
```html
Subject: {{firstName}}, avez-vous terminé votre setup ?

Bonjour {{firstName}},

Je vois que vous avez créé votre compte hier.
Avez-vous eu le temps de [action principale] ?

{{#if setupComplete}}
Super ! Vous êtes prêt à [prochaine étape].
{{else}}
Il ne vous reste que 2 minutes pour finaliser :

[CTA: Terminer mon setup]
{{/if}}

**Astuce du jour :**
[Tip utile pour les nouveaux utilisateurs]

Des questions ? Répondez simplement à cet email.

{{senderName}}
[Titre] @ [App]
```

#### J+3 (Activation)
```html
Subject: Découvrez [feature populaire]

Bonjour {{firstName}},

Saviez-vous que nos utilisateurs les plus actifs
utilisent [feature] pour [bénéfice] ?

**Comment l'utiliser :**
1. [Étape 1]
2. [Étape 2]
3. [Étape 3]

[CTA: Essayer maintenant]

**Ce que disent nos utilisateurs :**
"[Témoignage court]" - {{testimonialAuthor}}

{{senderName}}
```

#### J+7 (Feedback)
```html
Subject: Votre avis compte pour nous

Bonjour {{firstName}},

Cela fait une semaine que vous utilisez [App].

**Une question rapide :**
Sur une échelle de 0 à 10, recommanderiez-vous
[App] à un collègue ?

[0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [10]

Votre feedback nous aide à améliorer le produit.

Merci !
{{senderName}}
```

### 7. Email de réengagement

```html
Subject: {{firstName}}, vous nous manquez !

Bonjour {{firstName}},

Nous avons remarqué que vous n'avez pas utilisé
[App] depuis {{daysSinceLastLogin}} jours.

**Ce qui a changé depuis :**
- ✨ [Nouvelle feature 1]
- 🚀 [Amélioration 2]
- 🐛 [Bug fix important]

[CTA: Revenir sur [App]]

**Besoin d'aide ?**
Si vous avez rencontré des difficultés, nous serions
ravis d'en discuter. Répondez à cet email !

{{senderName}}

PS: Si [App] ne répond plus à vos besoins,
nous comprenons. [Lien feedback]
```

### 8. Email d'upgrade

```html
Subject: Débloquez [feature Pro]

Bonjour {{firstName}},

Vous avez atteint {{usagePercent}}% de votre limite
sur le plan gratuit.

**Passez à Pro pour :**
- ✅ [Avantage 1]
- ✅ [Avantage 2]
- ✅ [Avantage 3]

**Offre spéciale :** -20% avec le code UPGRADE20

[CTA: Passer à Pro →]

Ou [comparer les plans].

{{senderName}}
```

### 9. Confirmation de paiement

```html
Subject: Confirmation de votre paiement

Bonjour {{firstName}},

Merci pour votre paiement !

**Récapitulatif :**
- Plan : {{planName}}
- Montant : {{amount}}€
- Date : {{date}}
- Prochain paiement : {{nextPaymentDate}}

[CTA: Voir ma facture]

Votre facture est également disponible dans
votre espace client.

**Besoin d'aide ?** Répondez à cet email.

L'équipe [App]
```

## Bonnes pratiques

### 10. Checklist email

- [ ] Subject < 50 caractères
- [ ] Préheader optimisé
- [ ] Personnalisation ({{firstName}})
- [ ] Un seul CTA principal
- [ ] Mobile-responsive
- [ ] Lien de désinscription
- [ ] Adresse physique (légal)
- [ ] Alt text sur images
- [ ] Plain text version

### 11. Structure recommandée

```
┌────────────────────────────────────┐
│ Logo                               │
├────────────────────────────────────┤
│                                    │
│ Titre accrocheur                   │
│                                    │
│ Corps du message                   │
│ - Court et scannable               │
│ - Bénéfices > Features             │
│                                    │
│      [CTA Principal]               │
│                                    │
│ PS: Message secondaire             │
│                                    │
├────────────────────────────────────┤
│ Footer                             │
│ - Réseaux sociaux                  │
│ - Désinscription                   │
│ - Adresse                          │
└────────────────────────────────────┘
```

## Output attendu

### Templates générés

| Email | Fichier | Variables |
|-------|---------|-----------|
| Bienvenue | welcome.html | firstName, totalUsers |
| Confirm | confirm-email.html | firstName, confirmationUrl |
| Reset | reset-password.html | firstName, resetUrl |
| ... | ... | ... |

### Configuration provider

```typescript
// email.config.ts
export const emailConfig = {
  from: 'App <hello@app.com>',
  replyTo: 'support@app.com',
  templates: {
    welcome: 'tmpl_welcome_v1',
    confirm: 'tmpl_confirm_v1',
    // ...
  }
};
```

### Code d'envoi

```typescript
// sendEmail.ts
await sendEmail({
  to: user.email,
  template: 'welcome',
  data: {
    firstName: user.firstName,
    totalUsers: await getUserCount(),
  },
});
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/onboarding` | Séquence d'emails d'activation |
| `/retention` | Emails de réengagement |
| `/analytics` | Tracker les performances email |
| `/rgpd` | Conformité des emails marketing |
| `/i18n` | Emails multilingues |

---

IMPORTANT: Tester les emails sur différents clients (Gmail, Outlook, Apple Mail).

YOU MUST inclure un lien de désinscription sur tous les emails marketing.

NEVER envoyer d'emails sans consentement explicite (RGPD).

Think hard sur la valeur que chaque email apporte au destinataire.
