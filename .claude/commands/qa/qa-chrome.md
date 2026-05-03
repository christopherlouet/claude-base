# QA-CHROME Agent (Chrome visual tests)

Visual tests and browser debugging via Claude Code's Chrome integration.

## Prerequisites

- Launch Claude Code with: `claude --chrome`
- "Claude in Chrome" extension installed (v1.0.36+)

## Usage

Performs a visual audit of the specified page or URL: $ARGUMENTS

## Capabilities

- Navigation and interaction with web pages
- Reading console errors and logs
- DOM inspection and CSS styles
- Network request monitoring
- Screenshots and GIF recording
- Responsive testing (mobile, tablet, desktop)

## Workflow

1. Verify Chrome connection (`/chrome`)
2. Open the target page
3. Inspect: console, errors, layout
4. Test responsive: 375px, 768px, 1440px
5. User journey: main interactions
6. Capture anomalies
7. Generate the report

## Output

Structured report:
- Critical errors with captures
- Warnings and suggestions
- Overall score (/10)
- Improvement recommendations
