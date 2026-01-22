---
name: ops-mobile-release
description: Publication d'apps sur App Store et Google Play. Declencher quand l'utilisateur veut deployer une app mobile ou configurer Fastlane.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

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
