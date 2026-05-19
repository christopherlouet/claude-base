# Recipe: choosing a Python toolchain in a `cli-tools` (or `fastapi`) project

**Audience**: developers using the `cli-tools` or `fastapi` preset who need to pick a package manager, linter/formatter, and type checker. NOT a recommendation that one option is universally best — only guidance for the case where you need to make a defensible choice.

This recipe lives outside the presets deliberately. The choice of Python toolchain is a project decision, not a stack essential. The presets bundle what every Python project needs in terms of foundation rules and skills (TDD, security, API patterns, Docker). Toolchain selection belongs in a recipe you opt into, not in the default install.

---

## Why this is a recipe, not a preset bundle

The dominant modern Python toolchain in 2026 is Astral's stack (`uv` + `ruff` + `ty`). Adoption is large and the tools are excellent. The official Claude Code marketplace plugin is `astral@astral-sh` — a high-quality skills bundle that integrates the toolchain into Claude Code via `/astral:uv`, `/astral:ruff`, `/astral:ty` commands.

claude-base does **not** bundle `astral@astral-sh` in the `cli-tools` or `fastapi` preset. Two reasons:

1. **Vendor positioning**: Astral was acquired by OpenAI on 2026-03-19 ([source](https://openai.com/index/openai-to-acquire-astral/)). claude-base is a configuration kit for Claude Code (Anthropic). Publishing an implicit endorsement of OpenAI-acquired tooling in an Anthropic-ecosystem kit would be dissonant for users who deliberately chose Claude Code over Codex. The MIT license protects today's code; it does not protect against future roadmap drift toward Codex-specific integration.

2. **Stack-essential vs opinion**: A preset bundles what every project on the stack needs. Two developers building Python CLI tools or FastAPI services will legitimately diverge on toolchain politics — some are Astral-pragmatic, others are vendor-neutral, others are conservative-PyPA. Bundling one path forces a non-essential opinion. Documenting the three paths is more useful.

The full reasoning is in `specs/marketplace-audit/cli-tools-pilot-2026-05-05.md`.

---

## The three paths

Pick one based on your performance needs, your stance on vendor concentration, and your team's existing setup.

### Path 1 — Astral (performance-first, OpenAI-adjacent)

What you get:
- `uv` for package and project management — meaningfully faster than alternatives, drop-in for `pip`, `pip-tools`, `pyenv`, `pipx` use cases
- `ruff` for linting and formatting — replaces flake8, black, isort, pyupgrade with one tool, ~100x faster
- `ty` for type checking — a fast Pyright-class type checker (still in active development as of 2026-05)
- `/astral:uv`, `/astral:ruff`, `/astral:ty` skills inside Claude Code

What you accept:
- Roadmap is now driven by OpenAI's Codex team. The maintainers commit to OSS, but priorities can shift.
- Tools are MIT-licensed; this protects current code, not future direction.

#### Install

```bash
# Install the Claude Code plugin
claude plugin install astral@astral-sh

# Enable it in your project's .claude/settings.json
# (merge with existing keys — do not replace the whole file)
```

```json
{
  "enabledPlugins": {
    "astral@astral-sh": true
  }
}
```

Alternatively, use the `--add-plugin` helper (claude-base ≥ v1.33.0):

```bash
claude-base update --add-plugin astral@astral-sh ./your-project
```

This adds the entry to `enabledPlugins` without touching the rest of `settings.json` and is idempotent — re-running on an already-enabled plugin succeeds silently. Useful if `claude-base update --settings` is run later: just re-run the `--add-plugin` command to restore the entry.

### Path 2 — Vendor-neutral (community-maintained)

What you get:
- `pdm` (independent maintainer) or `poetry` (Python-poetry org) for package management
- `flake8` + `black` + `isort` + `pyupgrade` for linting/formatting (slower than ruff but stable, well-known)
- `mypy` for type checking — the original gradual type checker, written by Python core maintainers
- No Claude Code plugin to install at this time; toolchain is configured directly in `pyproject.toml` and used outside Claude Code

What you accept:
- Slower toolchain. `flake8` + `black` + `isort` is meaningfully slower than `ruff` on large codebases (often 30-60s vs <1s).
- No equivalent `astral@astral-sh` plugin yet exists for these tools in the Claude Code marketplace. Toolchain integration with Claude Code is via your project's CI scripts and editor LSPs, not via plugin commands.

#### Install (PDM example)

```bash
# Install pdm system-wide
curl -sSL https://pdm-project.org/install-pdm.py | python3 -

# In your project
pdm init
pdm add --dev mypy flake8 black isort pyupgrade
```

`pyproject.toml` configures everything; no Claude Code plugin install needed.

### Path 3 — Conservative PyPA defaults

What you get:
- `pip` + `pip-tools` (or `requirements.txt`) for package management — the official Python Packaging Authority path
- `venv` for environment isolation
- `flake8` (community) or skip linting (project choice)
- `mypy` (Python community)
- Whatever your team or organisation already uses

What you accept:
- Slowest of the three paths. Justified if your team / organisation has hard constraints (e.g. air-gapped environments, dependency-vetting processes that require pip's well-known supply chain).
- Maximum compatibility with legacy tooling, OS packagers, organisational mirrors.

#### Install

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pip-tools mypy flake8

# Compile requirements
echo "fastapi" > requirements.in
pip-compile requirements.in
pip install -r requirements.txt
```

---

## Decision matrix

| Concern | Path 1 (Astral) | Path 2 (Neutral) | Path 3 (PyPA) |
|---|---|---|---|
| Speed | Best | Average | Slowest |
| Vendor neutrality | Now OpenAI-owned | Community | Most neutral |
| CC plugin available | Yes (`astral@astral-sh`) | Not yet | No (legacy) |
| Toolchain coverage | All three layers in one plugin | Mix-and-match | Mix-and-match |
| Future risk | Roadmap drift toward Codex | Maintainer fatigue (some tools are solo-maintained) | Slow evolution but stable |
| Best for | Modern projects, perf-conscious | Projects that want OSS independence | Regulated / legacy environments |

---

## When this recipe will be revisited

- If a vendor-neutral Claude Code plugin equivalent to `astral@astral-sh` ships (e.g. for `pdm` or `mypy`), Path 2 will gain a CC integration option.
- If Astral's roadmap under OpenAI publishes meaningful Codex-specific divergence — or stays neutral after 12 months — the policy filter on `astral@astral-sh` may be reconsidered.
- ✅ `scripts/update.sh --add-plugin <id>` shipped in v1.33.0 (idempotent helper that adds an entry to `enabledPlugins` without overwriting other keys).

The pilot trace is in `specs/marketplace-audit/cli-tools-pilot-2026-05-05.md`. Re-evaluation criteria are listed there.

---

## What this recipe is NOT

- A claim that one path is universally better. Each has legitimate use cases.
- An endorsement of the position that vendor concentration in OSS toolchains is bad. Reasonable practitioners differ.
- A statement that `uv`/`ruff` are inferior to alternatives. They are not — they are the fastest tools by a large margin.
- A complete index of Python tooling. If your stack uses `hatch`, `rye`, `pyflyby`, or anything else not listed, it is not excluded by this recipe — it is simply not detailed here.
