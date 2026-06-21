# Recipe: deploying the nightly curation bot

**Audience**: the foundation maintainer who wants the marketplace curation engine to re-verify the recommended vendor skills automatically, on a schedule, and surface a single reviewable digest — without paying for model tokens.

This recipe wires `scripts/curation-watch.sh` (the rot-watch, Slice 3 of `specs/marketplace-curation-engine`) into a nightly timer on a small Linux box. It is **observe-and-propose only**: nothing is installed, nothing is merged automatically. The most the bot ever does is open a *draft* PR or a *propose-only* issue for you to approve.

---

## Why this is safe to run unattended

The nightly path is **deterministic and LLM-free** — it calls the GitHub API for public repo signals (stars, recency, archived, license) and compares content references against the pinned ones. It uses **zero model tokens**.

This matters because of the **2026-06-15 Anthropic agentic-billing change**: from that date `claude -p` / the Agent SDK / cron-driven model usage is metered on a separate credit at API rates, with no rollover, and automation stops on exhaustion. The rot-watch is immune to this — it never invokes a model (EF-012). The only part of the engine that touches an LLM is the **monthly discovery** sweep (Slice 5), which is a separate, infrequent job on a dedicated capped API key. **This recipe deploys the LLM-free nightly watch only.**

So the bot needs **no model API key** — just an authenticated `gh`.

---

## What the bot does each run

1. Refresh a clean checkout to `origin/main` (so the watch sees exactly what is shipped).
2. Run `curation-watch.sh`, which for every recommended / pointed vendor skill:
   - scores public trust signals (archived / abandoned / popularity-collapse / license-change),
   - detects **content drift** vs the pinned ref,
   - applies the **sustained-collapse** rule (a popularity drop is only flagged after ≥2 consecutive runs — a single noisy reading never alarms),
   - emits **one** batched digest (`digest.json` + `digest.md`).
3. Optionally surface findings via `gh`:
   - `--emit-issue` → one **propose-only** issue containing the digest (only when there are findings — an all-clean run stays silent).
   - `--emit-pr` → one **draft** PR re-pinning low-risk drift that re-passes **both** the trust scorer **and** the pin-time safety screen. A drift whose new content fails the safety screen is demoted to propose-only (it stays in the issue, never auto-drafted).

State (the `collapseStreak` / reference popularity needed for the sustained-collapse rule) is kept in a **`watch-state.json` outside the checkout** so it survives the nightly `git reset --hard` (see below).

---

## Prerequisites on the box

- `bash`, `jq`, `git`, and the GitHub CLI `gh`.
- A clone of the repo, e.g. at `/opt/claude-base`.
- An authenticated `gh`. Use a **fine-grained token** scoped to this one repo with the minimum permissions:
  - **Contents: read** — required (the watch reads the registry/presets and the GitHub API).
  - **Issues: read & write** — only if you use `--emit-issue`.
  - **Pull requests: read & write** + **Contents: write** — only if you use `--emit-pr` (it pushes a branch and opens a draft PR).

Store the token as an environment variable for `gh` (never commit it):

```bash
# /etc/claude-base-bot.env   (chmod 600, owned by the bot user)
GH_TOKEN=github_pat_xxxxxxxxxxxxxxxxxxxxx
```

`gh` reads `GH_TOKEN` automatically. No other secret is needed — there is **no model key** in the nightly path.

---

## The wrapper script

Keep the git hygiene and flags in one place. Save as `/opt/claude-base/scripts/curation-bot-run.sh` (or anywhere on the box — it is not part of the repo):

```bash
#!/usr/bin/env bash
# Nightly curation bot wrapper — LLM-free, $0 tokens.
set -euo pipefail

REPO=/opt/claude-base
STATE=/var/lib/curation-bot/watch-state.json   # persists across runs (outside the checkout)
DIGEST=/var/lib/curation-bot/digest            # last digest.json + digest.md

mkdir -p "$(dirname "$STATE")" "$DIGEST"

# Always re-verify exactly what main ships. reset --hard guarantees the clean
# tree that --emit-pr requires; the external --state-file is what survives it.
git -C "$REPO" fetch --quiet origin main
git -C "$REPO" reset --hard --quiet origin/main

"$REPO/scripts/curation-watch.sh" \
    --state-file "$STATE" \
    --digest-dir "$DIGEST" \
    --emit-issue
    # add --emit-pr to also auto-draft low-risk re-pins (needs Contents+PR write)
```

Notes:
- The nightly `git reset --hard origin/main` discards the watch's in-place `lastVerified` writes to `registry.json` — that is intentional and harmless (freshness bookkeeping; the digest is the durable output). The sustained-collapse **state** is preserved because it lives in `--state-file`, outside the checkout.
- `curation-watch.sh` exits `0` on a completed run (with or without findings) and `2` only on a usage/setup error, so the timer's `OnFailure` only fires on real breakage.
- `--emit-pr` is **draft by default**; pass `--no-draft` only if you want a ready PR.

```bash
chmod +x /opt/claude-base/scripts/curation-bot-run.sh
```

---

## Option A — systemd timer (recommended)

`/etc/systemd/system/curation-bot.service`:

```ini
[Unit]
Description=Marketplace curation rot-watch (LLM-free)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=curation-bot
EnvironmentFile=/etc/claude-base-bot.env
ExecStart=/opt/claude-base/scripts/curation-bot-run.sh
# Hardening (read-only system, writable state dir only)
ProtectSystem=strict
ReadWritePaths=/opt/claude-base /var/lib/curation-bot
PrivateTmp=true
NoNewPrivileges=true
```

`/etc/systemd/system/curation-bot.timer`:

```ini
[Unit]
Description=Run the curation rot-watch nightly

[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true
RandomizedDelaySec=900

[Install]
WantedBy=timers.target
```

Enable it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now curation-bot.timer
systemctl list-timers curation-bot.timer
```

## Option B — cron

```cron
# /etc/cron.d/curation-bot   (runs 03:30 nightly as the bot user)
30 3 * * * curation-bot . /etc/claude-base-bot.env; /opt/claude-base/scripts/curation-bot-run.sh >> /var/log/curation-bot.log 2>&1
```

---

## First run / verification

Run the wrapper once by hand and confirm the outcome:

```bash
sudo -u curation-bot --preserve-env=GH_TOKEN /opt/claude-base/scripts/curation-bot-run.sh
# or:  sudo systemctl start curation-bot.service && journalctl -u curation-bot.service -n 40

cat /var/lib/curation-bot/digest/digest.md          # the human-readable digest
jq '.findingCount' /var/lib/curation-bot/digest/digest.json
```

- If there are findings and you passed `--emit-issue`, a single issue titled `Curation digest — <date>` appears on the repo.
- An all-clean run writes a "No rot or drift detected" digest and opens **no** issue (no-noise contract).
- To rehearse without any side effects, run with `--dry-run` (no state write, no issue, no PR).

---

## Monthly discovery (the one LLM job — keep it separate)

`scripts/curation-discover.sh` surfaces **newly-published** community skills in covered domains and proposes the ones that clear trust + safety + advice-neutrality. The trust and safety gates are LLM-free; only the advice-neutrality + fit judgment calls a model (`claude -p`, Haiku triage with escalation), under a **hard token budget** that **fails safe** — budget exhaustion defers the remaining candidates and is reported, never a silent stop or runaway spend (EF-012).

Because it bills against the post-2026-06-15 agentic credit, it runs **monthly** on a **dedicated, capped API key — in its own unit with its own `EnvironmentFile`, never mixed with the nightly watch** (which must stay $0).

`/etc/claude-base-discover.env` (chmod 600 — the **only** place the model key lives):

```bash
ANTHROPIC_API_KEY=sk-ant-xxxxxxxx   # a dedicated key with a low monthly cap set in the console
```

Wrapper `/home/ubuntu/curation-bot/discover-run.sh` (mirrors the watch's `run.sh` — `cd` into the repo so `claude`/`git` resolve, then run from a fresh checkout):

```bash
#!/usr/bin/env bash
set -euo pipefail
REPO=/opt/claude-base
OUT=/home/ubuntu/curation-bot/discovery
mkdir -p "$OUT"
git -C "$REPO" fetch --quiet origin main
git -C "$REPO" reset --hard --quiet origin/main
cd "$REPO"   # so `gh issue create` (via --emit-issue) and `claude` resolve context

# --budget caps token spend; the job stops and reports on exhaustion.
# --emit-issue opens ONE propose-only issue with the proposals (no-noise: only
# when there is something to review). Without it the digest sits unread in $OUT.
"$REPO/scripts/curation-discover.sh" --digest-dir "$OUT" --budget 150000 --emit-issue
# Review the issue (or $OUT/proposals.md), then open candidates manually — discovery never auto-adds.
```

`/etc/systemd/system/curation-discover.service`:

```ini
[Unit]
Description=Marketplace curation discovery (monthly, LLM, budget-capped)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=ubuntu
Environment=HOME=/home/ubuntu
EnvironmentFile=/etc/claude-base-discover.env   # the ONLY place the model key lives
ExecStart=/home/ubuntu/curation-bot/discover-run.sh
NoNewPrivileges=true
PrivateTmp=true
```

`/etc/systemd/system/curation-discover.timer`:

```ini
[Unit]
Description=Run curation discovery monthly

[Timer]
OnCalendar=*-*-01 04:00:00
Persistent=true
RandomizedDelaySec=1800

[Install]
WantedBy=timers.target
```

Enable: `sudo systemctl enable --now curation-discover.timer`.

> **`--emit-issue` needs the same `gh` as the nightly watch**, with **`Issues: read & write`** on the fine-grained PAT — otherwise `gh issue create` fails and the proposals never surface (the exact bug fixed for the watch: emission now passes `-R`, but the **token still needs the scope**). `gh` is shared from `~/.config/gh`; the discover env file adds **only** `ANTHROPIC_API_KEY`, never the `gh` token.

> **Auth note:** `claude -p` here should use a **dedicated, capped `ANTHROPIC_API_KEY`** (the env file), **not** the interactive subscription login in `~/.claude/.credentials.json` — post-2026-06-15 a headless/cron `claude -p` is metered on the agentic credit, so isolate its spend on a key with a **hard monthly cap set in the Anthropic console** (the real backstop, independent of `--budget`).

> Setting a **hard monthly spend cap on the API key in the Anthropic console** is the real backstop: even if `--budget` were misconfigured, the key cannot overspend.

---

## Scope

- Two timers, two trust boundaries: the **nightly watch** ($0, `gh`-only) and the **monthly discovery** (model key, capped). Never share an `EnvironmentFile` — the model key must never be present in the nightly path.
- The bot only ever **proposes**. Acting on a digest (approving a re-pin, removing a dead recommendation, adding a discovered candidate) stays a human decision, consistent with the foundation's observe-never-install stance.
