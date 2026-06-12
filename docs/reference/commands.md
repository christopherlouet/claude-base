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

## claude-base CLI — module management

Installable opt-in modules — 3 horizontal domains (`biz`, `legal`, `growth`)
plus 12 thematic cross-domain modules (`mobile`, `self-hosted`, `iac`, `data-eng`,
`observability`, `editor`, `api-data`, `ai`, `frontend`, `nextjs`, `flutter`, `gitflow`) — are managed with
three `claude-base` verbs. They work on an **already-initialized project** —
run `claude-base init` first if the target directory has no `.claude/` yet,
or `claude-base update` once if the project predates `foundation.json`
(legacy `.foundation-version` marker — update migrates it automatically).

| Command | Description |
|---------|-------------|
| `claude-base add <module> [path]` | Install a module and record it in `foundation.json` |
| `claude-base add <module> --dry-run [path]` | Preview what would be installed (no writes) |
| `claude-base remove <module> [path]` | Remove a module (preserves user-modified files) |
| `claude-base remove <module> --dry-run [path]` | Preview what would be removed (no writes) |
| `claude-base modules [path]` | List available modules and their install status |

**Examples:**

```bash
# Install the legal compliance module into the current project
claude-base add legal .

# Preview installing the biz module without writing anything
claude-base add biz --dry-run .

# Remove the growth module (user-modified files are preserved with a notice)
claude-base remove growth .

# Check which modules are installed
claude-base modules .
```

Available modules: `biz` (11 commands + 4 agents), `legal` (5 commands + 4 agents),
`growth` (11 commands + 6 agents + growth-cro skill).

**Tip:** `claude-base init --preset <name>` automatically installs the preset's
`defaultModules` set and prints a `claude-base add` hint for the rest.

## Advanced CLI Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--agent <name>` | Launch a specific agent directly | `claude --agent qa-security` |
| `--agents` | List all available agents | `claude --agents` |
| `--chrome` | Enable Chrome integration (visual tests) | `claude --chrome` |
| `--teleport` | Enable Teleport connection (remote) | `claude --teleport` |
| `--remote` | Connect to a remote session | `claude --remote <session-id>` |
| `--fallback-model` | Fallback model if the primary is unavailable (also applies to interactive sessions since CLI 2.1.166; see the `fallbackModel` setting for a cascade of up to 3 models) | `claude --fallback-model haiku` |
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
