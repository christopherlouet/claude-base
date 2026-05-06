---
sidebar_position: 38
title: "qa-chrome"
description: "Visual tests and browser debugging via Chrome. Use to test web pages, verify visual rendering, debug with the console, or automate browser actions. Trigger when the user mentions \"visual test\", \"Chrome\", \"browser\", \"browser console\", \"DOM\", \"screenshot\", \"GIF\"."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-chrome

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Visual tests and browser debugging via Chrome. Use to test web pages, verify visual rendering, debug with the console, or automate browser actions. Trigger when the user mentions "visual test", "Chrome", "browser", "browser console", "DOM", "screenshot", "GIF".

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Bash`, `Grep`, `Glob` |
| **Keywords** | `chrome`, `claude in chrome` |

## Detailed description

# Visual Tests and Chrome Debugging

## Prerequisites

- Claude Code launched with `--chrome` flag
- "Claude in Chrome" extension installed (v1.0.36+)
- Google Chrome open

## Instructions

### 1. Verify the Chrome connection

Verify that the Chrome integration is active. If not, ask the user to relaunch with `claude --chrome`.

### 2. Available capabilities

| Action | Description |
|--------|-------------|
| Navigation | Open a URL, navigate between pages |
| Interaction | Click, type text, fill out forms |
| Inspection | Read the DOM, console logs, network requests |
| Capture | Take screenshots, record GIFs |
| Test | Verify rendering, test user journeys |

### 3. Test workflows

#### Visual test of a page
1. Open the page in Chrome
2. Verify the visual rendering (layout, colors, typography)
3. Test responsiveness (resize the window)
4. Capture a screenshot for reference

#### Console debugging
1. Open the page
2. Read the console errors
3. Identify the source of the errors in the code
4. Propose fixes

#### User journey test
1. Navigate to the starting point
2. Follow the journey step by step (click, input, navigation)
3. Verify each step
4. Report anomalies

#### GIF recording
1. Start the recording
2. Execute the journey
3. Save the GIF

### 4. Verification checklist

- [ ] Page loads without console error
- [ ] Correct layout (no overflow, no overlap)
- [ ] Readable texts (contrast, size)
- [ ] Images loaded
- [ ] Working links
- [ ] Fillable forms
- [ ] Responsive OK (mobile, tablet, desktop)
- [ ] No network error (404, 500)

### 5. Limitations

- Requires Chrome (not Brave, Arc, or Firefox)
- Visible Chrome window required (no headless)
- JavaScript dialogs (alert, confirm) block the flow
- WSL not supported

## Expected output

Structured report with:
- Screenshots/GIFs if relevant
- List of errors found
- Recommendations for fixes
- Overall score (OK / Warnings / Errors)

## See also

[`ChromeDevTools/chrome-devtools-mcp`](https://github.com/ChromeDevTools/chrome-devtools-mcp) (38,221★, last commit 2026-05-05) is maintained by the official Google Chrome DevTools team. Apache-2.0.

**Format note**: this is an MCP server, NOT a SKILL.md skill. It exposes Chrome DevTools features (network inspection, profiling, accessibility tree) as MCP tools that Claude Code can invoke directly during a session — different mechanism than this skill, which describes how to read DevTools manually.

When working on a project where Claude Code needs **direct programmatic access to Chrome DevTools**, configure the `chrome-devtools-mcp` server in your project's `.mcp.json`. This skill remains useful for the **manual review checklist** (what to look for, how to interpret); the MCP server adds the automation layer.

Install command and full list of validated vendor skills: `docs/recipes/recommended-vendor-skills.md`. Audit pilot trace: `specs/marketplace-audit/qa-skills-pilot-2026-05-06.md`.

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to chrome..."_
- _"I want to claude in chrome..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
