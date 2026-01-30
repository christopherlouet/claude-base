---
name: qa-chrome
description: Tests visuels et debugging navigateur via Chrome. Utiliser pour tester des pages web, vérifier le rendu visuel, débuguer avec la console, ou automatiser des actions navigateur. Déclencher quand l'utilisateur mentionne "test visuel", "Chrome", "navigateur", "console browser", "DOM", "screenshot", "GIF".
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
context: fork
disable-model-invocation: true
argument-hint: "[url-or-page]"
---

# Tests Visuels et Debugging Chrome

## Prérequis

- Claude Code lancé avec `--chrome` flag
- Extension "Claude in Chrome" installée (v1.0.36+)
- Google Chrome ouvert

## Instructions

### 1. Vérifier la connexion Chrome

Vérifier que l'intégration Chrome est active. Si non, demander à l'utilisateur de relancer avec `claude --chrome`.

### 2. Capabilities disponibles

| Action | Description |
|--------|-------------|
| Navigation | Ouvrir une URL, naviguer entre pages |
| Interaction | Cliquer, taper du texte, remplir des formulaires |
| Inspection | Lire le DOM, les logs console, les requêtes réseau |
| Capture | Prendre des screenshots, enregistrer des GIFs |
| Test | Vérifier le rendu, tester des parcours utilisateur |

### 3. Workflows de test

#### Test visuel d'une page
1. Ouvrir la page dans Chrome
2. Vérifier le rendu visuel (layout, couleurs, typographie)
3. Tester le responsive (redimensionner la fenêtre)
4. Capturer un screenshot pour référence

#### Debugging console
1. Ouvrir la page
2. Lire les erreurs console
3. Identifier la source des erreurs dans le code
4. Proposer des corrections

#### Test de parcours utilisateur
1. Naviguer vers le point de départ
2. Suivre le parcours pas à pas (clic, saisie, navigation)
3. Vérifier chaque étape
4. Reporter les anomalies

#### Enregistrement GIF
1. Démarrer l'enregistrement
2. Exécuter le parcours
3. Sauvegarder le GIF

### 4. Checklist de vérification

- [ ] Page charge sans erreur console
- [ ] Layout correct (pas de overflow, pas de chevauchement)
- [ ] Textes lisibles (contraste, taille)
- [ ] Images chargées
- [ ] Liens fonctionnels
- [ ] Formulaires remplissables
- [ ] Responsive OK (mobile, tablet, desktop)
- [ ] Pas d'erreur réseau (404, 500)

### 5. Limitations

- Nécessite Chrome (pas Brave, Arc, ou Firefox)
- Fenêtre Chrome visible requise (pas de headless)
- Les dialogues JavaScript (alert, confirm) bloquent le flux
- WSL non supporté

## Output attendu

Rapport structuré avec :
- Screenshots/GIFs si pertinent
- Liste des erreurs trouvées
- Recommandations de corrections
- Score global (OK / Warnings / Erreurs)
