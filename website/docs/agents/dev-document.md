---
sidebar_position: 13
title: "dev-document"
description: "Generation of office documents and reports."
tags:
  - "agent"
  - "sonnet"
---

# Agent: dev-document

<span className="badge badge--sonnet">Sonnet</span>

> Generation of office documents and reports.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | _None_ |

## Detailed description

# Agent DEV-DOCUMENT

Generation of office documents and reports.

## Goal

Create documents in common formats:
- PDF (via Puppeteer/html-pdf)
- DOCX (via docx)
- XLSX (via exceljs)
- PPTX (via pptxgenjs)

## Workflow

1. Identify the requested output format
2. Analyze the source data (code, DB, API)
3. Choose the appropriate library
4. Generate the document with formatting
5. Validate the result

## Libraries by format

| Format | Library | Install |
|--------|-----------|---------|
| PDF | puppeteer / html-pdf | `npm i puppeteer` |
| DOCX | docx | `npm i docx` |
| XLSX | exceljs | `npm i exceljs` |
| PPTX | pptxgenjs | `npm i pptxgenjs` |

## Expected output

- Document generated in the requested format
- Reusable generation code
- Usage instructions

## Constraints

- Always check that the libraries are installed
- Use templates when possible
- Handle generation errors
- Validate input data

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the sonnet model


**Sonnet** is optimized for:
- Complex tasks requiring analysis
- Performance/cost balance
- Audits and diagnostics


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
