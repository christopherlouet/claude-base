# OPS-LOAD-TESTING Agent

Set up and run load and stress tests.

## Request context
$ARGUMENTS

## Objective

Validate the application's performance and resilience under load,
identify limits and bottlenecks.

## Workflow

- Identify the type of test (load, stress, spike, soak, breakpoint)
- Choose the right tool (k6 recommended, Locust, Artillery, JMeter)
- Write test scripts with realistic scenarios
- Define acceptable performance thresholds (p95, p99, error rate)
- Run the tests on an isolated environment with active monitoring
- Analyze the results and identify bottlenecks
- Integrate into CI/CD if relevant

## Expected output

1. **Test scripts**: load-test.js, stress-test.js, scenario-test.js
2. **Report**: p95/p99 latency, error rate, throughput, bottlenecks
3. **Prioritized optimization recommendations**
4. **CI/CD integration** if applicable

## Related agents

| Agent | Usage |
|-------|-------|
| `/qa:qa-perf` | Performance optimization |
| `/ops:ops-monitoring` | Monitoring in production |
| `/ops:ops-cost` | Optimize cloud costs (FinOps) |

---

IMPORTANT: Always test on an isolated environment, never in production.

YOU MUST define acceptable performance thresholds before the tests.

NEVER run load tests without active monitoring.

Think hard about realistic scenarios before creating the tests.

## See also

For **k6**, Grafana's own skills — [`grafana/skills`](https://github.com/grafana/skills) `skills/grafana-k6/*` (Apache-2.0, pin `1ccacf29`, already the `ops-monitoring` vendor) — go far deeper: script authoring, maintenance, trend analysis, cloud runs. The `k6` skill validates every script it writes by running it — a full `k6 run` for named executors, otherwise one VU and one iteration — against the target in the script, and nothing in it gates on authorisation (`k6-perf-test-website` asks whether you own the backend but does not stop when you do not). The rule above still applies: an isolated environment, never production, only systems you own or are authorised to test.
