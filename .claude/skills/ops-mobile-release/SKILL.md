---
name: ops-mobile-release
description: Publishing apps to the App Store and Google Play. Trigger when the user wants to deploy a mobile app or configure Fastlane.
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
        with:
          bundler-cache: true   # runs bundle install, caches gems
      - run: bundle exec fastlane ios release
        env:
          # read by fastlane's app_store_connect_api_key action
          APP_STORE_CONNECT_API_KEY_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_KEY: ${{ secrets.ASC_KEY_P8 }}

  android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true   # fastlane runs through Bundler: Ruby + gems first
      - run: bundle exec fastlane android release
        env:
          SUPPLY_JSON_KEY_DATA: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}   # read by supply
```

## Release Checklist

### iOS
- [ ] Increment version/build number
- [ ] Screenshots up to date
- [ ] App Store description
- [ ] Privacy policy URL
- [ ] TestFlight beta OK

### Android
- [ ] versionCode/versionName incremented
- [ ] APK/AAB signed
- [ ] Play Store screenshots
- [ ] Description up to date
- [ ] Internal testing OK
