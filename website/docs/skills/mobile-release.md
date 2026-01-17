---
sidebar_position: 16
title: "mobile-release"
description: "Publication d'apps sur App Store et Google Play. Declencher quand l'utilisateur veut deployer une app mobile ou configurer Fastlane."
tags:
  - "skill"
  - "fork"
---

# Skill: mobile-release

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Publication d'apps sur App Store et Google Play. Declencher quand l'utilisateur veut deployer une app mobile ou configurer Fastlane.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `mobile`, `release`, `deploy to testflight`, `myapp`, `deploy to app store`, `deploy to play store internal` |

## Description detaillee

# Mobile Release

## Fastlane Setup

```ruby
# fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Deploy to TestFlight"
  lane :beta do
    increment_build_number
    build_app(scheme: "MyApp")
    upload_to_testflight
  end

  desc "Deploy to App Store"
  lane :release do
    increment_build_number
    build_app(scheme: "MyApp")
    upload_to_app_store
  end
end

platform :android do
  desc "Deploy to Play Store Internal"
  lane :beta do
    gradle(task: "bundleRelease")
    upload_to_play_store(track: "internal")
  end

  desc "Deploy to Play Store"
  lane :release do
    gradle(task: "bundleRelease")
    upload_to_play_store
  end
end
```

## GitHub Actions

```yaml
name: Mobile Release

on:
  push:
    tags:
      - 'v*'

jobs:
  ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
      - run: bundle install
      - run: bundle exec fastlane ios release
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.ASC_KEY }}

  android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
      - run: bundle exec fastlane android release
        env:
          GOOGLE_PLAY_JSON_KEY: ${{ secrets.PLAY_KEY }}
```

## Checklist Release

### iOS
- [ ] Increment version/build number
- [ ] Screenshots a jour
- [ ] Description App Store
- [ ] Privacy policy URL
- [ ] TestFlight beta OK

### Android
- [ ] versionCode/versionName incrementes
- [ ] APK/AAB signe
- [ ] Screenshots Play Store
- [ ] Description a jour
- [ ] Internal testing OK

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux mobile..."_
- _"Je veux release..."_
- _"Je veux deploy to testflight..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
