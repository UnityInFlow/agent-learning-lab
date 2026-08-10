# Phase 10 — Production observability + engineering impact

**Guardrail layer: L0 — observation** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** ⬜ Not started · **Depends on:** Phase 9

## Goal

Move from one-run learning telemetry to chapter-level operating evidence.

## Verified reading

- [ ] ✅ [Copilot CLI OTel reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference)
- [ ] ↪️ [Enterprise managed settings](https://docs.github.com/en/copilot/reference/enterprise-administrators/enterprise-managed-settings)
- [ ] ✅ [Claude Code — Monitoring usage](https://code.claude.com/docs/en/monitoring-usage)
- [ ] ✅ [GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/)

> **Default: full prompt/response/tool content capture stays OFF unless explicitly
> approved.** Copilot OTel exposes useful metadata without it.

---

## Extract

From Claude Code — Monitoring usage, read 2026-08-09. Exact variable names.

### Two findings that change what this project believes

**1. `claude_code.tool.blocked_on_user` is a span type.**

Among the beta trace spans: `claude_code.interaction` (root), `claude_code.llm_request`,
`claude_code.tool`, **`claude_code.tool.blocked_on_user`**, `claude_code.tool.execution`,
`claude_code.hook`.

> **That is a direct detector for harness bug #7.** You do not have to infer "blocked" from a
> tool-call count and a bimodal duration. The runtime emits a span that says the tool was
> blocked waiting on a human. Issue #47 can be implemented against telemetry rather than
> heuristics — and Lab 5B.5 can *verify* the fix instead of trusting it.

**2. `traceId: null` is not "by design."**

`STATE.md` records that Claude runs have no trace because #20 "refused to fake span parity."
The docs say traces exist behind a beta flag:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1
export OTEL_TRACES_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://localhost:4318/v1/traces
```

The five-questions walkthrough was blocked on "needs a Copilot run." It needs an environment
variable. **Try it — it is a ten-minute experiment.**

### Content capture — every default is OFF

| Variable | Controls | Default |
|---|---|---|
| `OTEL_LOG_USER_PROMPTS=1` | user prompt text | **off** — redacted |
| `OTEL_LOG_ASSISTANT_RESPONSES=1` | response text | **off** — `<REDACTED>` |
| `OTEL_LOG_TOOL_DETAILS=1` | tool parameters, MCP/tool/skill names, **Bash commands** | **off** |
| `OTEL_LOG_TOOL_CONTENT=1` | tool input/output in span events | **off** |
| `OTEL_LOG_RAW_API_BODIES=1` | inline request/response JSON (60 KB truncation) | **off** |

> "Spans redact user prompt text, tool input details, and tool content by default."

`OTEL_LOG_RAW_API_BODIES=file:<dir>` writes **untruncated** bodies to disk. Know that this
exists before someone enables it for debugging.

### Identity — the part governance cares about

**Always sent:** `user.id` (random, anonymous, regenerates if `~/.claude.json` is deleted),
`session.id`, `organization.id`.

**When authenticated, also:** **`user.email`**, `user.account_uuid`, `user.account_id`.

Opt-outs:

```bash
OTEL_METRICS_INCLUDE_SESSION_ID=false        # default true
OTEL_METRICS_INCLUDE_ACCOUNT_UUID=false      # default true
OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES=false  # default true
```

> `user.email` reaching your collector is issue #11's central question, and issue #41's
> collector-boundary work. *"The purpose is to evaluate the system, not to rank developers"* —
> that principle needs these three variables set, not just stated.

### Metrics and events

```
claude_code.session.count · lines_of_code.count · pull_request.count · commit.count
claude_code.cost.usage · token.usage · code_edit_tool.decision · active_time.total
```

Events include `claude_code.user_prompt`, `assistant_response`, `tool_result`,
`api_request`, `api_error`, `tool_decision`, **`permission_mode_changed`**,
`mcp_server_connection`, `plugin_installed`, `plugin_loaded`.

> `permission_mode_changed`, `mcp_server_connection`, `plugin_installed` and `plugin_loaded`
> are the environment-drift signals **issue #35** needs. Between these and the
> `ConfigChange` hook, "was this run isolated?" becomes answerable from data rather than
> assumed.

### Lab 10.0 — try both findings *(do this first, it is ten minutes)*

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1 CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1
export OTEL_TRACES_EXPORTER=otlp OTEL_METRICS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
# run any short task, then look in Grafana/Tempo
```

- [ ] Does a Claude run now produce a trace? If yes, `STATE.md` needs correcting
- [ ] Run a task needing a build under `--permission-mode acceptEdits`, headless. Does
      `claude_code.tool.blocked_on_user` appear?
- [ ] Grep the collector output for `user.email`. Is it there?

---

## Three layers

| | Examples | Question |
|---|---|---|
| **L1 Adoption** | active users/teams, agent-mode usage, CLI usage | Are people using it? |
| **L2 Agent execution** | success rate, task type, tokens, cost, model/tool calls, retries, duration, hook denials, MCP failures | How do agents behave? |
| **L3 Engineering impact** | PR cycle time, review rework, escaped defects, change failure rate, lead time, incidents, time-to-fix, onboarding independence | Does it improve engineering? |

**Usage is not impact.** A dashboard full of L1 is a dashboard that cannot answer the only
question the business asked.

## Domain model

Do not mirror vendor span names into your database.

```
Experiment · Run · Task · Harness · Model · CustomizationSet
Evaluation · HumanReview · SafetyFinding

Copilot OTel ─┐
Claude OTel ──┼── normalization ──► Observatory domain
Codex OTel ───┘
```

## Dashboards

1. **Run explorer** — task, harness, model, customization version, score, tokens, cost, duration, tool calls, retries
2. **Comparison** — B0 / B1 / B3 / B4 with **median, p25/p75, success rate, sample count.** Never one "average score"
3. **Safety** — denied tools, hook errors, hook timeouts, MCP failures, unexpected network, permission escalations
4. **Model strategy** — quality / cost / latency / failure rate **per task class**

## Experiment policy

Change **one meaningful variable** at a time.

```
Bad:     new model + new skill + new prompt + new permissions   → unattributable
Better:  same task, harness, model, permissions; only AGENTS v2 changed
```

## Promotion gate

A customization moves from pilot to chapter standard only if:

1. deterministic checks do not regress
2. benchmark quality improves or stays within approved tolerance
3. safety guardrails do not regress
4. cost increase is justified
5. enough repetitions exist
6. a human reviews the qualitative diff
7. **rollback is defined**

## Exit gate

- [ ] I can name a metric in each of L1/L2/L3 for my chapter
- [ ] I can explain why usage is not impact to a non-engineer
- [ ] My comparison dashboard shows uncertainty, not just a winner
- [ ] I can state the promotion gate from memory
- [ ] I know what my telemetry captures and what it deliberately does not
