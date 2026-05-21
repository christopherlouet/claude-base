---
sidebar_position: 31
title: "ops-mobile-release"
description: "Publishing apps to the App Store and Google Play. Trigger when the user wants to deploy a mobile app or configure Fastlane."
tags:
  - "skill"
  - "fork"
---

# Skill: ops-mobile-release

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Publishing apps to the App Store and Google Play. Trigger when the user wants to deploy a mobile app or configure Fastlane.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `ops`, `mobile`, `release` |

## Detailed description

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

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to ops..."_
- _"I want to mobile..."_
- _"I want to release..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
