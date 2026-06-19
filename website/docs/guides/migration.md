---
sidebar_position: 8
title: Migration Guide
description: Migrate an existing project to claude-base
---

# Migration Guide to claude-base

This guide walks you through integrating claude-base into an existing project.

## Overview

Migrating to claude-base consists of:
1. Copying the configuration files
2. Adapting the rules to your stack
3. Validating the installation
4. Starting to use the workflow

**Estimated duration**: 15-30 minutes

## Prerequisites

- Claude Code installed and working
- An existing project (Web, Mobile, API, etc.)
- Write access to the project

## Standard Migration

### Step 1: Download claude-base

```bash
# Clone the repository
git clone https://github.com/christopherlouet/claude-base.git /tmp/claude-base
```

### Step 2: Copy the files

```bash
# Go to your project
cd your-project

# Copy the .claude folder
cp -r /tmp/claude-base/.claude/ .

# Copy CLAUDE.md
cp /tmp/claude-base/CLAUDE.md .

# Copy .mcp.json (optional)
cp /tmp/claude-base/.mcp.json .
```

### Step 3: Verify the structure

```bash
ls -la .claude/
```

You should see:
```
.claude/
├── commands/      # 131 commands
├── agents/        # 63 agents
├── skills/        # 54 skills
├── rules/         # 30 rules
├── templates/     # Spec templates
├── output-styles/ # Output styles
└── settings.json  # Configuration
```

### Step 4: Validate the installation

Open Claude Code in your project and test:

```bash
# Should work
/work:work-explore "Analyze this project"
```

If exploration works, the migration succeeded.

---

## Migration by Project Type

### Web Project (React/Next.js/Vue)

**Important files**:
- `.claude/rules/typescript.md` - TypeScript conventions
- `.claude/rules/react.md` - React conventions
- `.claude/rules/testing.md` - Testing conventions

**Adapt CLAUDE.md**:

```markdown
# My Web Project

## Essential Commands
| Command | Description |
|----------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Development server |
| `npm test` | Run tests |
| `npm run build` | Production build |

## Structure
```
/src
├── /components   # React components
├── /hooks        # Custom hooks
├── /services     # Business logic
└── /utils        # Utility functions
```

## Conventions
- Strict TypeScript
- Tailwind CSS for styling
- Jest + RTL for tests
```

**Recommended commands**:
- `/dev:dev-component` - Create components
- `/dev:dev-hook` - Create hooks
- `/qa:qa-perf` - Performance audit

### Mobile Project (Flutter)

**Important files**:
- `.claude/rules/flutter.md` - Flutter/Dart conventions

**Adapt CLAUDE.md**:

```markdown
# My Flutter App

## Commands
| Command | Description |
|----------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run on device |
| `flutter test` | Run tests |
| `flutter build apk` | Android build |

## Architecture
- Clean Architecture
- BLoC for state management
- get_it for dependency injection

## Structure
```
/lib
├── /core         # Shared code
├── /features     # Features by domain
│   └── /auth
│       ├── /data
│       ├── /domain
│       └── /presentation
└── /config       # Configuration
```
```

**Recommended commands**:
- `/dev:dev-flutter` - Create screens/widgets
- `/dev:dev-supabase` - Supabase backend
- `/qa:qa-mobile` - Mobile quality audit

### API Project (Node/Python/Go)

**Important files**:
- `.claude/rules/api.md` - API conventions
- `.claude/rules/security.md` - Security
- `.claude/rules/testing.md` - Tests

**Adapt CLAUDE.md**:

```markdown
# My API

## Commands
| Command | Description |
|----------|-------------|
| `npm start` | Start the server |
| `npm test` | Run tests |
| `npm run lint` | Check the code |

## Stack
- Express.js / Fastify
- PostgreSQL with Prisma
- Jest for tests
- Zod for validation

## API Conventions
- REST with versioning (v1, v2)
- Strict input validation
- Centralized error handling
- Structured logs (JSON)
```

**Recommended commands**:
- `/dev:dev-api` - Create endpoints
- `/dev:dev-tdd` - TDD development
- `/qa:qa-security` - Security audit

---

## Migration from Standard Claude Code

If you are already using Claude Code without claude-base:

### Key differences

| Aspect | Before | After |
|--------|-------|-------|
| Workflow | Ad-hoc | Explore → Specify → Plan → TDD → Audit → Commit |
| Commands | Manual | `/work:work-*`, `/dev:dev-*`, etc. |
| Conventions | Repeated | In CLAUDE.md and rules |
| Agents | No | <!-- count:agents -->55<!-- /count --> specialized agents |

### Migration steps

1. **Back up your custom prompts**
   ```bash
   # If you had custom .claude files
   cp -r .claude/ .claude-backup/
   ```

2. **Install claude-base**
   ```bash
   cp -r /tmp/claude-base/.claude/ .
   cp /tmp/claude-base/CLAUDE.md .
   ```

3. **Reintegrate your customizations**
   - Copy your custom commands into `.claude/commands/custom/`
   - Adapt CLAUDE.md with your conventions

4. **Test**
   ```bash
   /work:work-explore "Analyze the project"
   ```

---

## Post-Migration Customization

### Adapt the rules

Edit the rules according to your conventions:

```bash
# Edit a rule
nano .claude/rules/typescript.md
```

Customization example:

```markdown
# TypeScript Rules (Customized)

## Conventions Specific to Our Project

- Use `type` rather than `interface` for props
- Prefix interfaces with `I` (IUser, IProduct)
- Suffix types with `Type` (UserType, ProductType)
```

### Add custom commands

```bash
# Create a custom command
mkdir -p .claude/commands/custom
nano .claude/commands/custom/deploy-staging.md
```

```markdown
# Deploy Staging

## Instructions
Deploy the application to the staging environment:
1. Check that the tests pass
2. Build the application
3. Deploy to staging.example.com
4. Verify the deployment

## Commands
```bash
npm run test
npm run build
npm run deploy:staging
```
```

### Configure the hooks

Edit `.claude/settings.json`:

```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "echo 'Modification in progress...'"
      }
    ],
    "postToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "npm run lint:fix",
        "filePattern": "**/*.{ts,tsx}"
      }
    ]
  }
}
```

---

## Validation Checklist

After the migration, check:

### Configuration

- [ ] The `.claude/` folder exists with all subfolders
- [ ] The `CLAUDE.md` file is present
- [ ] The `.mcp.json` file is present (optional)

### Commands

- [ ] `/work:work-explore` works
- [ ] `/work:work-specify` works
- [ ] `/work:work-plan` works
- [ ] `/dev:dev-tdd` works
- [ ] `/qa:qa-loop` works
- [ ] `/work:work-commit` works

### Customization

- [ ] CLAUDE.md reflects the project's conventions
- [ ] The rules match the stack used
- [ ] Custom commands are created if needed

### Functional test

```bash
# Full test
/work:work-explore "Analyze this project and its conventions"
/work:work-plan "Add an example feature"
# (Cancel if needed)
```

---

## Troubleshooting

### The command does not work

```bash
# Check the structure
ls -la .claude/commands/work/

# The file must exist
cat .claude/commands/work/work-explore.md
```

### The agent does not trigger

```bash
# Check the agents
ls -la .claude/agents/

# Force usage
"Use the qa-security agent to audit the project"
```

### The rules do not apply

```bash
# Check that the paths match
cat .claude/rules/typescript.md | head -10

# Paths must match your files
# paths: ["**/*.ts", "**/*.tsx"]
```

---

## Resources

- [Full installation](/docs/intro/installation)
- [Architecture](/docs/intro/architecture)
- [FAQ](/docs/guides/faq)
- [Troubleshooting](/docs/guides/troubleshooting)

---

:::tip Tip
After the migration, spend a few minutes exploring with `/work:work-explore`. This helps Claude understand your project and give better recommendations.
:::
