---
sidebar_position: 24
title: "/ops:ops-mobile-release"
description: "Publishing mobile applications to stores (App Store, Google Play)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# MOBILE RELEASE Agent

Publishing mobile applications to stores (App Store, Google Play).

## Request context
`&lt;arguments&gt;`

## Objective

Prepare and automate mobile application publishing, including
signing, versioning, building and CI/CD configuration.

Use the `ops-mobile-release` skill for the detailed methodology.

## Workflow

- Identify the target platform (Android, iOS, both)
- Configure signing (Android keystore, iOS certificates)
- Manage versioning (versionCode/versionName, build number)
- Generate builds (App Bundle, IPA)
- Configure Fastlane for automation
- Set up CI/CD (GitHub Actions, Codemagic)
- Publish to stores (Google Play Console, App Store Connect)

## Expected output

1. **Signing configuration** for each platform
2. **Fastlane scripts** (internal, beta, production)
3. **CI/CD pipeline** for releases
4. **Checklist** pre-release (Android + iOS)

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-flutter` | Develop the Flutter app |
| `/ops:ops-ci` | Full CI/CD pipeline |
| `/ops:ops-release` | Version management |
| `/ops:ops-secrets-management` | Store credentials |

---

IMPORTANT: Never commit keystores or certificates to the repo.

IMPORTANT: Always increment the versionCode/build number before a release.

YOU MUST test on real devices before publishing.

NEVER publish directly to production - use test tracks first.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
