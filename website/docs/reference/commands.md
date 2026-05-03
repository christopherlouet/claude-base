---
sidebar_position: 13
title: "Essential Commands"
description: ""
tags:
  - "reference"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Essential Commands

## Web (Node/React)
| Command | Description |
|----------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Development server |
| `npm test` | Run tests |
| `npm run test:watch` | Tests in watch mode |
| `npm run lint` | Check code (ESLint) |
| `npm run lint:fix` | Auto-fix |
| `npm run build` | Production build |
| `npm run typecheck` | Check TypeScript types |

## Mobile (Flutter)
| Command | Description |
|----------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run on device/emulator |
| `flutter test` | Run tests |
| `flutter analyze` | Analyze code (lint) |
| `dart fix --apply` | Auto-fix |
| `flutter build apk` | Android build |
| `flutter build ios` | iOS build |
| `flutter build web` | Web build |

## Backend (Python)
| Command | Description |
|----------|-------------|
| `pip install -r requirements.txt` | Install dependencies |
| `python -m venv .venv` | Create a virtual environment |
| `source .venv/bin/activate` | Activate the environment (Linux/Mac) |
| `pytest` | Run tests |
| `pytest --cov` | Tests with coverage |
| `ruff check .` | Fast linter |
| `ruff format .` | Format code |
| `mypy .` | Check types |

## Backend (Go)
| Command | Description |
|----------|-------------|
| `go mod download` | Install dependencies |
| `go run .` | Run the application |
| `go test ./...` | Run tests |
| `go test -cover ./...` | Tests with coverage |
| `go build` | Compile the binary |
| `go fmt ./...` | Format code |
| `go vet ./...` | Analyze code |
| `golangci-lint run` | Full linter |

## Advanced CLI Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--agent <name>` | Launch a specific agent directly | `claude --agent qa-security` |
| `--agents` | List all available agents | `claude --agents` |
| `--chrome` | Enable Chrome integration (visual tests) | `claude --chrome` |
| `--teleport` | Enable Teleport connection (remote) | `claude --teleport` |
| `--remote` | Connect to a remote session | `claude --remote <session-id>` |
| `--fallback-model` | Fallback model if the primary is unavailable | `claude --fallback-model haiku` |
| `--plugin-dir` | Plugin directory to load | `claude --plugin-dir ./plugins` |
| `--bare` | Minimal scripted mode (skip hooks, LSP, plugins, skills) | `claude -p --bare "query"` |
| `--channels` | Enable channels (Telegram, Discord, iMessage) | `claude --channels` |
| `--tools` | Restrict available tools | `claude --tools "Read,Grep,Glob"` |
| `--init` | Initialize the project (Setup init hook) | `claude --init` |
| `--init-only` | Initialize without starting a session | `claude --init-only` |
| `--maintenance` | Run maintenance (Setup maintenance hook) | `claude --maintenance` |
| `--max-budget-usd` | Maximum budget in USD for the session | `claude --max-budget-usd 5.00` |
| `--fork-session` | Fork an existing session | `claude --fork-session <id>` |
| `--strict-mcp-config` | Strict mode for MCP config | `claude --strict-mcp-config` |
| `--teammate-mode` | Agent Teams display mode (auto, in-process, tmux) | `claude --teammate-mode tmux` |
