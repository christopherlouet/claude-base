# Guardrails — what claude-base enforces that a bare Claude project doesn't

Claude (Opus) is already a strong coder. On a well-scoped task it writes good code
**without** claude-base — our own measurements show that honestly (see
[`eval/value-proof/`](../eval/value-proof/)). So the value of this foundation is
**not** "better code".

The value is the **net of enforced checkpoints that is present by default**. A
fresh `claude` project has *none* of these; you would have to know each one exists,
wire it up, and remember to run it every time. claude-base ships ~25 of them,
active from `init` — a method, specialists on tap, and deterministic guardrails.
Each one targets a real failure mode; together they lower the chance a change ships
broken, insecure, or half-done.

> **How to read the last column.** "Native?" = does a bare Claude project have this
> by default. The answer is **No** for every row — that *is* the point. Native
> Claude *can* do most of these if you ask precisely and remember every time;
> claude-base makes them automatic, consistent, and model-independent.

Everything here is **opt-out** (an env var per gate, noted in
[`reference/hooks-reference.md`](reference/hooks-reference.md)) — guardrails, not
handcuffs.

---

## 1. Method gates — *how the work is done*

The biggest differentiator: a bare session jumps straight to code. claude-base
routes work through a process, and the **artifacts** it produces (a spec, a plan,
tests-first, an audit report, a clean PR) are things a native session never makes.

| Gate | What it prevents | How enforced | Native? |
|------|------------------|--------------|---------|
| **Explore-before-edit** | changing code you don't understand | `work-explore`, workflow rule | No |
| **Specify** (user stories + Given/When/Then) | building the wrong thing | `work-specify` | No |
| **Plan-before-code** | architecture decided mid-implementation | `work-plan` | No |
| **TDD (tests first)** | code with no/After-the-fact tests | `tdd-enforcement` rule, `dev-tdd` | No |
| **Audit-before-commit** | shipping unreviewed (security/a11y/perf) | `qa-loop "score 90"` | No |
| **Conventional commits / PR structure** | unreadable history, thin PRs | `git` rule, `work-commit`/`work-pr` | No |

## 2. Security gates — *blocking, at the moment of the action*

| Gate | What it prevents | How enforced | Native? |
|------|------------------|--------------|---------|
| **Main-branch protection** | committing straight to `main` | PreToolUse (auto-branch) | No |
| **Secret scan** | a hardcoded key/token reaching the repo | PreToolUse `secret-scan.sh` (built-in, zero-dep) | No |
| **Command validator** | fork bombs, `curl \| sh`, `--no-verify` gate-bypass, … | PreToolUse `command-validator.sh` | No |
| **Destructive-op confirm** | `DROP`/`TRUNCATE`/`rm -rf` data loss via a command | PreToolUse destructive guard | No |
| **Destructive-migration** | destructive DDL written into a migration *file* | PreToolUse `destructive-migration.sh` | No |
| **Config-protection** | weakening a linter/tsconfig to silence a check | PreToolUse `config-protection.sh` | No |
| **Bash-write guard** | dodging the guards above by writing via Bash (`>`/`tee`/`sed -i`) to a lint config, a secrets file, or a tracked file on `main` | PreToolUse `bash-write-guard.sh` | No |
| **Pre-deploy build** | deploying when the prod build is broken | PreToolUse deploy guard | No |

## 3. Verification gates — *proof, not the model's word*

| Gate | What it prevents | How enforced | Native? |
|------|------------------|--------------|---------|
| **Pre-commit tests** | committing with a red suite | PreToolUse (runs tests, blocks) | No |
| **Pre-push CI parity** | a push that fails CI on something runnable locally | `.husky/pre-push` → `preflight.sh` | No |
| **Format + type/lint feedback** | unformatted code; type/lint errors slipping by | PostToolUse (auto-format + tsc/eslint re-injected) | No |
| **Coverage check** | a test edit that drops coverage unnoticed | PostToolUse | No |
| **Substance gate** | hollow tests, stubs, and focused `.only` tests that make a green suite prove nothing | PostToolUse `substance-check.sh` | No |

## 4. Anti-gaming gates — *stop defeating the gate instead of satisfying it*

| Gate | What it prevents | How enforced | Native? |
|------|------------------|--------------|---------|
| **Counts self-heal** | derived counters drifting into a CI failure | pre-commit `sync-counts.sh` | No |
| **`--no-verify` block** | skipping the whole pre-commit/pre-push stack | command-validator CATEGORY 9 | No |
| **Config-protection** | "passing" the linter by disabling its rule | (see §2) | No |
| **Substance gate** | "passing" tests with assertion-free / `.only` tests | (see §3) | No |

## 5. Audit gates — *on demand, expert-grade*

| Gate | What it prevents | How enforced | Native? |
|------|------------------|--------------|---------|
| **Security audit** | OWASP Top 10 vulnerabilities | `qa-security`, `qa-loop` | No |
| **Accessibility audit** | WCAG 2.1/2.2 violations | `wcag-audit` | No |
| **Performance audit** | Core Web Vitals / bottlenecks | `qa-perf` | No |
| **Audit-fix loop** | shipping below a quality bar | `qa-loop "score 90"` | No |

## 6. Integrity gates — *keep the project honest*

| Gate | What it prevents | How enforced | Native? |
|------|------------------|--------------|---------|
| **Doc/counter integrity** | docs & counters drifting from `.claude/` | PostToolUse `base-integrity-check.sh` | No |
| **`.env` in `.gitignore`** | committing a real `.env` | SessionStart check | No |
| **Dependencies installed** | "works on my machine" / missing `node_modules` | SessionStart check | No |
| **Private names** | an end user's private project names reaching this public repo *in staged paths or staged content* | pre-commit `private-names-check.sh` | No |

> **Private names, in detail.** This foundation is developed against real personal
> projects, so their names slip into docs, specs and fixtures — historically into
> the very checklists meant to catch them. The protected-name list therefore lives
> **outside the repo** (`~/.claude/private-names`, or `CLAUDE_BASE_PRIVATE_NAMES`):
> committing the list would publish exactly what it protects. **No list means a
> silent no-op**, so a fresh clone of the public foundation is never blocked by a
> list it does not have. The gate scans only what a commit *adds*, so a
> pre-existing mention never blocks unrelated work and removing one is always
> allowed. Names are matched as fixed strings, case-insensitively. Prefer a
> distinctive form (`orchid-relay-backup`, not `relay`) — a name that is also an
> ordinary word will block correct commits. An entry **shorter than 4 characters
> is refused and named on stderr**: matched as a substring it would block
> ordinary text (`K` inside `const kilo = 1000;`), and a gate that refuses every
> second commit gets bypassed wholesale. Such a name cannot be protected this
> way — give it a longer distinctive form. The rest of the list keeps working;
> only the short entry is dropped. Deliberate bypass: `SKIP_PRIVATE_NAMES=1`.
>
> **Known limits** — the gate sees the staged *paths* and staged *content*, and
> nothing else. A commit **message** or a **branch name** carrying a private name
> still becomes public on push, and neither is covered here. Treat this gate as
> the floor, not the whole fence.

### The convention behind the gate: name the ROLE, not the machine

A deterministic gate only catches what someone thought to list. The habit it
backs up is this: **in a spec, a plan, a task or a doc, name the role a thing
plays — never the private identity it happens to have.** Write "a self-hosted
homelab host", "the CI runner", "the staging database"; keep the address, the
hostname and the login in personal notes.

This matters because the leak does not arrive through carelessness. It arrives
through *correct documentation of a private fact*: a spec is supposed to record
where a thing deploys, so writing "deployment target is `user@10.x.y.z`" looks
exactly like doing the job well. That is what happened here — a curation-engine
spec recorded its real deployment host, and it sat in this public repo for two
months. No mechanism could have caught it: a project-name checklist does not
cover hosts, and a secret scanner does not consider an RFC1918 address a secret.

What counts as a private identity, in practice:

| Do not write | Write instead |
|--------------|---------------|
| an internal IP or hostname (`192.0.2.10`, `nas.local`) | "the homelab host", "the internal registry" |
| a shell target (`user@host`) | "the deploy account on that host" |
| a personal path (`/home/<you>/src/<project>`) | "the project root" |
| an end user's private project name | "a personal project", `<project-a>` |

Documentation examples are the deliberate exception: RFC5737/RFC1918 sample
addresses in a networking tutorial are content, not identity. The test is
whether the value points at something that actually exists and is yours.

---

## How we know these earn their place (not just exist)

This catalogue is backed by measurement, not assertion — the honest result of the
[`eval/value-proof/`](../eval/value-proof/) work:

- **Deterministic gates are proven by construction + recurrence** — see
  [`eval/value-proof/LEDGER.md`](../eval/value-proof/LEDGER.md) and the executable
  [`gate-demo`](../eval/value-proof/gate-demo/) matrix (each gate catches a planted
  violation **and** spares a clean control).
- **New gates are added only when measured** — a candidate ships only if a casual
  Opus session actually commits the failure it guards (e.g. secret-hardcode and
  focused-`.only` slip ~50% of the time; `.env.example` sync was measured at ~0%
  and **deliberately not built**, to avoid a redundant gate).
- **Honest scope** — on a single bounded task with a capable model the *behavioral*
  delta is small; the value is the *presence and consistency* of this whole net,
  and its insurance value grows on weaker models. We don't oversell "better code".

See [`POSITIONING.md`](POSITIONING.md) for where this sits in the broader value story.
