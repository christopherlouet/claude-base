# Demo recording — claude-base 60-second tour

Scaffolding to regenerate the [asciinema cast / GIF](../static/img/60-second-tour.cast) embedded in the project README.

## What it shows

A real end-to-end workflow recorded inside an isolated Docker container :

1. `curl | bash` install of the foundation
2. `claude-base init --preset nextjs` into a fresh project
3. `tree .claude/` showing what's on disk
4. Real `claude` session with `/work:work-flow-feature` against the host's authenticated Claude Code (Max subscription mounted read-only)

The container is throwaway ; the recording captures the real install + a real Claude Code session.

## Prerequisites

| Tool | Install |
|---|---|
| Docker | per-OS, see [docs.docker.com](https://docs.docker.com/engine/install/) |
| asciinema | `pip install --user asciinema` (no sudo) |
| agg | `cargo install --git https://github.com/asciinema/agg` (no sudo, ~3 min compile) |
| Claude Code authenticated | `claude login` once on the host before recording |

## How to record

```bash
bash website/demo/record.sh
```

This builds the demo image, runs asciinema rec wrapping a `docker run` of the scenario, and renders the GIF.

## Output

| File | Purpose | Commit ? |
|---|---|---|
| `website/static/img/60-second-tour.cast` | asciinema source, regenerable | yes |
| `website/static/img/60-second-tour.gif` | README embed, generated from .cast | yes |

## Tuning

Edit `website/demo/scenario.sh` to change pacing, commands, or the prompt sent to Claude. Re-run `record.sh` to regen.

`agg --speed 1.5` in `record.sh` controls GIF playback speed — bump to `2.0` for a faster scroll.

## Variance warning

The Claude Code session is non-deterministic — the model responds differently each time. Plan to record 2-3 takes until you get one that reads naturally. The `.cast` you keep is the one you commit.

## CI auto-regen

Not wired by default. Recording requires the host's Claude Max auth, which can't be exposed to GitHub Actions secrets safely. Re-record manually on each major release (~5-10 min).
