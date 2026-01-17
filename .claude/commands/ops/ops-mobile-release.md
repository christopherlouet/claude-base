# Agent MOBILE RELEASE

Publication d'applications mobiles sur les stores (App Store, Google Play).

## Cible
$ARGUMENTS

## Modes d'utilisation

### Mode 1 : Preparer une release Android (Google Play)
Configure la signature, le versioning et genere le bundle.

### Mode 2 : Preparer une release iOS (App Store)
Configure les certificats, provisioning profiles et archive.

### Mode 3 : Automatiser avec Fastlane
Configure Fastlane pour automatiser les releases.

### Mode 4 : CI/CD mobile
Configure GitHub Actions ou Codemagic pour les releases.

---

## Android (Google Play)

### Configuration de signature

#### 1. Creer un keystore
```bash
# Generer un nouveau keystore (une seule fois, a conserver precieusement)
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

#### 2. Configurer le projet Flutter
```properties
# android/key.properties (NE PAS COMMITER)
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

```groovy
// android/app/build.gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Versioning
```yaml
# pubspec.yaml
version: 1.2.3+45
# 1.2.3 = versionName (affiche aux utilisateurs)
# 45 = versionCode (incremente a chaque release)
```

### Build du bundle
```bash
# Nettoyer et builder
flutter clean
flutter pub get

# Generer l'App Bundle (recommande)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab

# Alternative: APK
flutter build apk --release --split-per-abi
```

### Publication Google Play Console

1. **Premiere publication**
   - Creer l'application dans Google Play Console
   - Configurer les fiches Store (description, screenshots)
   - Uploader le bundle dans "Production" ou "Test interne"

2. **Mises a jour**
   - Incrementer `versionCode` dans pubspec.yaml
   - Builder le nouveau bundle
   - Uploader et soumettre pour review

---

## iOS (App Store)

### Prerequisites
- Compte Apple Developer ($99/an)
- Xcode installe
- Certificats et provisioning profiles configures

### Configuration des certificats

#### 1. Via Xcode (recommande pour debut)
```
Xcode → Preferences → Accounts → Manage Certificates
```

#### 2. Via Fastlane Match (recommande pour equipe)
```bash
# Initialiser match (stocke les certs dans un repo Git prive)
fastlane match init

# Generer/telecharger les certificats
fastlane match appstore
```

### Configuration du projet Flutter
```yaml
# ios/Runner.xcodeproj/project.pbxproj
# Configurer via Xcode:
# - Bundle Identifier
# - Team
# - Signing Certificate
# - Provisioning Profile
```

### Versioning
```bash
# Modifier dans Xcode ou via agvtool
cd ios
agvtool new-marketing-version 1.2.3
agvtool new-version -all 45
```

### Build et Archive
```bash
# Nettoyer et builder
flutter clean
flutter pub get

# Builder pour iOS
flutter build ios --release

# Ouvrir dans Xcode pour archiver
open ios/Runner.xcworkspace
# Product → Archive → Distribute App
```

### Publication App Store Connect

1. **Premiere publication**
   - Creer l'application dans App Store Connect
   - Configurer les metadonnees (description, screenshots, categories)
   - Uploader via Xcode ou Transporter
   - Soumettre pour review

2. **Mises a jour**
   - Incrementer version et build number
   - Archiver et uploader
   - Soumettre pour review

---

## Fastlane (Automatisation)

### Installation
```bash
# macOS
brew install fastlane

# Ruby
gem install fastlane
```

### Configuration Android
```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to Google Play Internal Testing"
  lane :internal do
    gradle(
      task: "bundle",
      build_type: "Release",
      project_dir: "android/"
    )
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end

  desc "Deploy to Google Play Production"
  lane :production do
    gradle(
      task: "bundle",
      build_type: "Release",
      project_dir: "android/"
    )
    upload_to_play_store(
      track: "production",
      aab: "../build/app/outputs/bundle/release/app-release.aab"
    )
  end
end
```

### Configuration iOS
```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Push to TestFlight"
  lane :beta do
    setup_ci if ENV['CI']
    match(type: "appstore", readonly: true)

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )

    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Deploy to App Store"
  lane :release do
    setup_ci if ENV['CI']
    match(type: "appstore", readonly: true)

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )

    upload_to_app_store(
      force: true,
      skip_metadata: false,
      skip_screenshots: false
    )
  end
end
```

### Appfile
```ruby
# ios/fastlane/Appfile
app_identifier("com.example.app")
apple_id("developer@example.com")
itc_team_id("123456789")
team_id("ABCD1234")
```

---

## CI/CD Mobile

### GitHub Actions - Android
```yaml
# .github/workflows/android-release.yml
name: Android Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'

      - name: Decode Keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/upload-keystore.jks
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=upload-keystore.jks" >> android/key.properties

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.example.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
```

### GitHub Actions - iOS
```yaml
# .github/workflows/ios-release.yml
name: iOS Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'

      - name: Install Fastlane
        run: |
          cd ios
          bundle install

      - name: Setup SSH for Match
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.MATCH_DEPLOY_KEY }}

      - name: Build and Upload
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_API_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_API_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_API_KEY }}
        run: |
          flutter build ios --release --no-codesign
          cd ios
          bundle exec fastlane beta
```

### Codemagic (Alternative)
```yaml
# codemagic.yaml
workflows:
  android-release:
    name: Android Release
    max_build_duration: 60
    environment:
      flutter: stable
      groups:
        - google_play
    scripts:
      - name: Build AAB
        script: flutter build appbundle --release
    artifacts:
      - build/**/outputs/**/*.aab
    publishing:
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal

  ios-release:
    name: iOS Release
    max_build_duration: 60
    instance_type: mac_mini_m1
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
      groups:
        - app_store_connect
    scripts:
      - name: Build IPA
        script: |
          flutter build ipa --release \
            --export-options-plist=/Users/builder/export_options.plist
    artifacts:
      - build/ios/ipa/*.ipa
    publishing:
      app_store_connect:
        auth: integration
        submit_to_testflight: true
```

---

## Checklist Pre-Release

### Android
- [ ] versionCode incremente
- [ ] versionName mis a jour
- [ ] Keystore securise (backup)
- [ ] ProGuard configure si necessaire
- [ ] Screenshots a jour
- [ ] Description traduite

### iOS
- [ ] Version et build number incrementes
- [ ] Certificats valides (non expires)
- [ ] Provisioning profiles a jour
- [ ] App Icons toutes les tailles
- [ ] Privacy policy URL configure
- [ ] Screenshots tous les devices

### Les deux
- [ ] Tests passes
- [ ] Changelog prepare
- [ ] Release notes ecrites
- [ ] Nouvelles permissions justifiees

---

## Secrets a configurer

| Secret | Description | Ou le creer |
|--------|-------------|-------------|
| `KEYSTORE_BASE64` | Keystore encode en base64 | `base64 upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | Mot de passe du keystore | - |
| `KEY_PASSWORD` | Mot de passe de la cle | - |
| `KEY_ALIAS` | Alias de la cle | - |
| `PLAY_STORE_SERVICE_ACCOUNT` | JSON du service account | Google Cloud Console |
| `MATCH_PASSWORD` | Mot de passe Match | - |
| `APP_STORE_API_KEY` | Cle API App Store Connect | App Store Connect |

---

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/flutter` | Developper l'app Flutter |
| `/ci` | Pipeline CI/CD complet |
| `/release` | Gestion des versions |
| `/changelog` | Generer les release notes |
| `/secrets-management` | Stocker les credentials |

---

IMPORTANT: Ne jamais commiter les keystores ou certificats dans le repo.

IMPORTANT: Toujours incrementer le versionCode/build number avant une release.

YOU MUST tester sur de vrais appareils avant publication.

NEVER publier directement en production - utiliser les tracks de test d'abord.
