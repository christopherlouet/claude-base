# GRAFANA-DASHBOARD Agent (pointer)

Creation of Grafana dashboards with automatic provisioning.

## Context
$ARGUMENTS

## Delegate to the vendor toolkit

`claude-base`'s prior `ops-grafana-dashboard` content (47-line checklist) is **superseded** by [`grafana/skills`](https://github.com/grafana/skills) — Grafana's own toolkit covers dashboards, provisioning (datasources.yaml/dashboards.yaml), panels, variables and alerting at the depth and currency a hand-maintained checklist cannot match; this command wrapped a tool the vendor owns.

Install:

```bash
git clone --depth 1 https://github.com/grafana/skills ~/dev/vendor-skills/grafana-skills
ln -s ~/dev/vendor-skills/grafana-skills/skills/<sub> ./.claude/skills/<sub>
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Grafana Labs — `grafana/skills`". Reduction rationale: [`specs/command-vendor-graduation/spec.md`](../../../specs/command-vendor-graduation/spec.md).

To instrument code so metrics exist, and to stand up the full stack (Prometheus/Grafana/Loki/Alertmanager), delegate to `/ops:ops-monitoring`; for Kubernetes to `/ops:ops-k8s`.

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-monitoring` | Instrument code + deploy Prometheus/Grafana/Loki |
| `/ops:ops-k8s` | Kubernetes deployment |

---

NEVER expose Grafana without authentication in production.
