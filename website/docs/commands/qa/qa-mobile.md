---
sidebar_position: 10
title: "/qa:qa-mobile"
description: "Quality audit specific to mobile applications (Flutter, React Native)."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# QA-MOBILE Agent

Quality audit specific to mobile applications (Flutter, React Native).

## Audit target
`&lt;arguments&gt;`

## Objective

Audit performance, accessibility, responsive and stability of a mobile application across various devices.

## Workflow

- Audit performance: 60 FPS, memory leaks, battery, network
- Audit accessibility: Semantics labels, touch targets (48dp min), contrast
- Audit responsive: mobile breakpoints, orientation, SafeArea
- Test on real devices (iPhone SE, iPhone 14, Pixel, Galaxy A)
- Test degraded conditions (offline, 3G, low battery)
- Generate report with detailed metrics

## Expected output

### Scores
| Category | Score /100 |
|-----------|-----------|
| Performance | |
| Accessibility | |
| Responsive | |
| Stability | |

### Identified issues
| Severity | Category | Description | Solution | File |
|----------|-----------|-------------|----------|---------|

### Metrics
- Startup time, memory usage, frame times, APK/IPA size

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/dev:dev-flutter` | Fix widgets |
| `/qa:qa-perf` | In-depth performance audit |
| `/qa:wcag-audit` | In-depth accessibility |
| `/qa:qa-responsive` | Detailed responsive web |

---

IMPORTANT: Always test on real devices, not just emulators.

YOU MUST reach 60 FPS on target devices minimum.

NEVER ignore performance warnings from Flutter DevTools.

Think hard about the user experience on various devices (old phones, slow connections).


---

## See also

- [Back to QA commands](/docs/commands/qa)
- [All commands](/docs/commands)
