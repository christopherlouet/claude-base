---
name: qa-chrome
description: Visual tests and browser debugging via Chrome. Use to test web pages, verify visual rendering, debug with the console, or automate browser actions. Trigger when the user mentions "visual test", "Chrome", "browser", "browser console", "DOM", "screenshot", "GIF".
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
context: fork
disable-model-invocation: true
argument-hint: "[url-or-page]"
---

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
