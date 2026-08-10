# Phase 0B — Observatory + evaluation baseline

**Guardrail layer: L0 — observation** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** ✅ Built · **Lives in:** [`agent-observatory`](https://github.com/UnityInFlow/agent-observatory) + [`agent-observatory-benchmarks`](https://github.com/UnityInFlow/agent-observatory-benchmarks)

Build the measurement system **before** changing agent behavior. This is the phase that
makes every later phase mean anything.

## Goal

Four concepts, never collapsed into one number:

| | Question |
|---|---|
| **Observation** | What happened? |
| **Metrics** | How much happened? |
| **Evaluation** | Was the result correct/good? |
| **Impact** | Did engineering outcomes improve? |

## Verified reading

- [ ] ✅ [Copilot CLI reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference) — search for **OpenTelemetry monitoring**
- [ ] ✅ [OpenTelemetry — Signals](https://opentelemetry.io/docs/concepts/signals/)
- [ ] ✅ [OpenTelemetry — Collector](https://opentelemetry.io/docs/collector/)
- [ ] ✅ [GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/) — target these, not vendor span names
- [ ] ✅ [Grafana Tempo](https://grafana.com/docs/tempo/latest/)
- [ ] ✅ [Visualize traces](https://grafana.com/docs/tempo/latest/visualize-traces/)
- [ ] ✅ [Claude Code — Monitoring usage](https://code.claude.com/docs/en/monitoring-usage) — **added by us**: the field list you must scrub; `user.email` can appear

---

## Extract

### ⚠️ The GenAI semantic conventions have moved — and the old URL still returns 200

Checked 2026-08-09. `https://opentelemetry.io/docs/specs/semconv/gen-ai/` responds **HTTP 200**
and renders a page. The page says:

> "This page **has moved and is no longer maintained** in this repository."

The content now lives at
**[github.com/open-telemetry/semantic-conventions-genai](https://github.com/open-telemetry/semantic-conventions-genai)**
(verified 200). The sub-pages still resolve:

- [`gen-ai-spans`](https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-spans/) — 200
- [`gen-ai-metrics`](https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-metrics/) — 200

**This is the failure mode a link checker cannot catch.** `check-links.sh` reports this URL as
✅ — correct status code, live page, no redirect. Only reading it reveals it is a tombstone.

> A 200 means the server answered. It does not mean the page still says what you cited it for.
> The only defence is re-reading, which is why every source in this repo carries *the question
> to bring to it* rather than just a link.

Treat this as the Phase 0B lesson about your own instrument too: **a check that passes is not
evidence the thing it checks is healthy** — it is evidence the check ran.

### What the page still tells you

The GenAI conventions now cover agent spans, events, exceptions and metrics, plus
provider-specific conventions for Anthropic, AWS Bedrock, Azure and OpenAI, and MCP and
LLM-call examples.

For the attribute names your normalization layer should target — `gen_ai.system`,
`gen_ai.operation.name`, `gen_ai.request.model`, `gen_ai.response.model`,
`gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens` and the rest — **go to the
repository.** This extract deliberately does not list them from memory; the whole point of
the finding above is that stale secondhand copies are the problem.

### Why it matters for your domain model

Phase 0B's rule is *"do not mirror vendor span names directly into your database."* The
GenAI conventions are the vendor-neutral target that rule points at. If they are moving and
being restructured, then:

- pin the convention **version** you normalise against, the way you pin a model ID
- record it in the run record alongside `schema_version`
- expect to re-read rather than assume stability

---

## Core metrics

**Correctness** compile · unit tests · hidden acceptance tests · lint · acceptance score
**Behavior** model calls · tool calls · tools used · files read/changed · commands · retries · permission requests · compactions
**Efficiency** wall-clock · input/output/cached tokens · cost
**Change quality** unnecessary files · architecture violations · test quality · human review score
**Safety** denied tool calls · forbidden commands attempted · unexpected network · out-of-scope writes · secret exposure

## Labs

| Lab | | Status |
|---|---|---|
| 0B.1 | Build the benchmark **before** the dashboard — BE-001, evaluator decides success, not the agent | ✅ |
| 0B.2 | 5 plain-agent repetitions, same commit/task/harness/model/permissions, reset between | ✅ |
| 0B.3 | OTel Collector with a **debug exporter only** — understand `receiver → processor → exporter` before adding storage. Break the endpoint on purpose | ✅ |
| 0B.4 | Add Tempo + Grafana. Find one run. Identify the `invoke_agent → chat → execute_tool` shape | ✅ |
| 0B.5 | First experiment: establish B0 variance. Report median, min/max, **never averages alone** | ✅ |

> One run is a story, not evidence. Start with 5 for learning; use 10–30+ for anything you
> intend to act on.

## Exit gate

- [x] A deterministic benchmark works
- [x] Hidden tests catch at least one intentionally bad implementation
- [x] 5 baseline runs exist
- [x] One trace is visible in Grafana
- [x] Run records are normalized independently of vendor OTel shape

---

## What we got wrong here

The gate above passed. The instrument still produced five void experiments. Both statements
are true, and the gap between them is the real Phase 0B lesson.

### The evaluator can be right and the measurement still meaningless

Our evaluator was correct on every run: it checked compilation, the hidden acceptance
suite, and the diff scope, and it never once mis-scored the code in front of it. It was
scoring a task the agent had already been handed the answer to.

```
tasks/BE-00X/acceptance/*.kt        the exact tests the run is graded on
tasks/BE-00X/fixtures/known-good/   a model solution
tasks/BE-00X/evaluator.sh           the checks and their exit codes
```

The runner handed the agent a `git worktree` of the benchmarks repo. All of that came with
it. Proof it was not theoretical — a pilot run's own summary named
`BE002FunctionalTest` and `BE002ContractTest`, filenames that exist nowhere but the answer
directory.

**The fix failed once.** Deleting those paths and committing the deletion left them in the
object store, so inside the "stripped" tree `git show HEAD^:…/known-good/OrderController.kt`
still returned the solution, and the setup commit's own message advertised that it existed.

The runner now builds the agent's tree with `git archive` of an allowlist into a fresh
`git init` — one commit, no parent objects — and **asserts it on every run** rather than
trusting it.

> Design the agent's tree as an allowlist of what it may see, not a denylist of what you
> remembered to remove. Then assert the property on every run, because a fix you believe in
> is not a fix you have verified.

### Telemetry gaps must not look like zeros

`BehaviorDto`'s counters are non-null, so a missing telemetry field and a genuine zero are
indistinguishable. Still open.

### Privacy is a Phase 0B decision, not a Phase 10 one

Default **off** for prompt content, response content, and tool arguments/results. Turning
capture on later is a policy change with a review; discovering you captured six months of
prompts is an incident. See `agent-observatory` issues #11 and #41.

## Practical

```bash
make build-api                  # BEFORE docker compose build — the image copies a host jar
make up                         # ~40s
make run-benchmark RUNTIME=claude MODEL=haiku BENCHMARK=BE-002
make test-runner                # 47 tests
```

Ports: Grafana **3001**, API **8081**, web **5174** (gitignored `infra/.env`).
Claude runs have `traceId: null` by design — the five-questions walkthrough needs Copilot.
