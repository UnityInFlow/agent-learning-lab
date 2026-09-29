# Phase 10 — Production observability + engineering impact

**Guardrail layer: L0 — observation** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** 🟡 Open at spine stop 25 · **Depends on:** Phase 9 (closed at stop 24, `7e3e1df`)

## Goal

Move from one-run learning telemetry to chapter-level operating evidence.

## Verified reading

- [x] ✅ [Copilot CLI OTel reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference) — read at stop 25, 2026-09-29, **from the raw HTML**; the page is 1 854 040 bytes and a markdown-converting fetch tool truncated it and reported the OTel section absent (see *An instrument reported absence* below)
- [x] ✅ [Enterprise managed settings](https://docs.github.com/en/copilot/reference/enterprise-administrators/enterprise-managed-settings) — read at stop 25, 2026-09-29. **The ↪️ is stale:** the URL resolves directly, 858 232 bytes, HTTP 200, no redirect. `SOURCES.md` already de-staled it at stop 22 and this list did not follow
- [x] ✅ [Claude Code — Monitoring usage](https://code.claude.com/docs/en/monitoring-usage) — re-read at stop 25, 2026-09-29, against the 2026-08-09 extract below; five corrections and four additions, all recorded
- [x] ⚠️ [GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/) — read at stop 25, 2026-09-29. **Tombstone, already recorded** at [0B](../00b-observatory/#extract) and in [`SOURCES.md`](../../SOURCES.md); live content is `open-telemetry/semantic-conventions-genai`. One thing the tombstone entry does not yet say is below

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

## Extract, second pass — re-read at spine stop 25, 2026-09-29

*Everything above this line is the author's first pass, read 2026-08-09/10. Nothing of it is
rewritten. This section amends it; where the two disagree, the disagreement is stated rather
than resolved by deletion.*

`Extracted by Opus 5 (claude-opus-5), autonomously, 2026-09-29; the author did not review
before the write.`

### An instrument reported absence over a scope smaller than the page

The first reading of the Copilot CLI reference was taken with a markdown-converting fetch
tool, which answered **"NOT PRESENT — the page does not document OpenTelemetry, nor any
telemetry-related environment variables."**

`SOURCES.md` line 96 says the opposite, and tells the reader what to expect: *"Search the
page for **OpenTelemetry monitoring**."* That row is the control, and it is the reason this
was checked instead of believed. Counted in the raw HTML:

| term | occurrences in `cli-ref.html` (1 854 040 bytes, HTTP 200) |
|---|---|
| `OpenTelemetry` | 10 |
| `OTEL_` | 66 |
| `invoke_agent` | 33 |
| `execute_tool` | 18 |

**The page documents OTel in detail. The reader truncated it and reported the truncation as
the page's content.** This is the house failure mode — a control reporting success (here,
absence) over a scope smaller than it claims — arriving through the reading instrument rather
than through a gate script. The operational rule it produces: **on a docs page over ~1 MB, a
converting fetch is a lower bound and a term count off the raw bytes is the measurement.**

`SOURCES.md`'s per-source *"question to bring to it"* column is what caught this. It is the
second time that column has earned its cost, the first being the semconv tombstone.

### Copilot CLI is on the GenAI semantic conventions; Claude Code is not

From the Copilot CLI reference, verbatim:

> "Copilot CLI can export traces and metrics via OpenTelemetry (OTel) … **All signal names
> and attributes follow the OTel GenAI Semantic Conventions.**"
>
> "OTel is **off by default** with zero overhead."

Its span/operation names are the semconv's own `gen_ai.operation.name` well-known values —
`chat`, `invoke_agent`, `execute_tool`. Claude Code's are vendor-prefixed:
`claude_code.interaction`, `claude_code.llm_request`, `claude_code.tool`,
`claude_code.tool.execution`, `claude_code.tool.blocked_on_user`, `claude_code.hook`.

**This is the measured reason the "Domain model" section below is right.** "Do not mirror
vendor span names into your database" was a design preference when it was written; it is now
a consequence of two runtimes that do not agree on the vocabulary, only one of which is on
the standard. A normalization layer is not a nicety here — without it the two arms are not
comparable at the span level at all.

Variables, from the same page: `COPILOT_OTEL_ENABLED`, `COPILOT_OTEL_FILE_EXPORTER_PATH`,
`OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_SERVICE_NAME`, `OTEL_RESOURCE_*`, `OTEL_LOG_LEVEL`.

### Copilot's content switch is the standard variable, and it has a file exporter too

| Variable | Runtime | What it releases |
|---|---|---|
| `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true` | Copilot CLI | prompt/response content — **the semconv's own switch, not a vendor one** |
| `OTEL_LOG_USER_PROMPTS=1` … `OTEL_LOG_RAW_API_BODIES` | Claude Code | the five vendor switches in the table above |
| `COPILOT_OTEL_FILE_EXPORTER_PATH` | Copilot CLI | spans/metrics **to a file on disk** |
| `OTEL_LOG_RAW_API_BODIES=file:<dir>` | Claude Code | **untruncated** request/response bodies to disk |

The Copilot page carries its own warning on the content switch:

> "Content capture may include sensitive information such as **code, file contents, and user
> prompts**. Only enable this in trusted environments."

**Both runtimes have a disk-write path that leaves the collector boundary entirely.** Issue
#41's collector-boundary work cannot be complete while either of these is settable by the
process under test, because neither traverses the collector.

### `lockCaptureContent` — an enforcement primitive exists, and this project cannot claim it

The enterprise managed-settings page ships this in its own example:

```json
"telemetry": {
  "enabled": true,
  "endpoint": "…",
  "protocol": "…",
  "captureContent": false,
  "lockCaptureContent": true,
  "serviceName": "copilot",
  "resourceAttributes": { "deployment.environment": "production" },
  "headers": { "Authorization": "Bearer TOKEN" }
}
```

`captureContent` sets the posture; **`lockCaptureContent` prevents a user from changing it.**

Apply the layer rule in order, and apply it to the proof rather than to the wish:

| Claim | Layer **for this project** | Why |
|---|---|---|
| "content capture stays OFF unless explicitly approved" (the note at the top of this workbook) | **L3** | Words a reader follows. Nothing in these three repositories executes it |
| `captureContent: false` in a managed-settings file | **L2** *for a Copilot deployment* | Something reads the file and applies it |
| `lockCaptureContent: true` | **L2**, closest thing here to L1 | The bad value can still be written into a user config; an enterprise layer rejects it. **Not L1** — the value remains writable |
| Any of the three, **as a control in this project** | **L3** | **Decision G: the Copilot arm does not exist here.** This is a reading, not a control. No claim about a Copilot-run agent may be made from it (§6) |

The last row is the whole point. The primitive is real and it is L2 *somewhere this project
does not run*. Recording it as a guardrail this project has would be the exact mistake
`GUARDRAILS.md` was written to stop.

### Five corrections and four additions to the first-pass extract above

Re-read of [Claude Code — Monitoring usage](https://code.claude.com/docs/en/monitoring-usage),
2026-09-29. The first pass is not edited; these are the deltas.

**Corrections:**

1. **`OTEL_LOG_ASSISTANT_RESPONSES` is not independent.** The page: it *"falls back to
   `OTEL_LOG_USER_PROMPTS` if unset."* The table above presents five orthogonal switches.
   **Setting `OTEL_LOG_USER_PROMPTS=1` alone also turns assistant responses on.** A
   privacy review that enables one to see prompts gets both.
2. **`organization.id` is not "always sent."** The page qualifies it *"(when authenticated)
   … always included when available"*. It belongs with `user.email` in the authenticated
   group, not in the unconditional one.
3. **`session.id` is conditional on a default**, not unconditional: it is present *because*
   `OTEL_METRICS_INCLUDE_SESSION_ID` defaults to `true`. "Always sent" and "sent unless you
   turn it off" are different claims and only the second is true.
4. **The metric names carry the `claude_code.` prefix.** The first pass writes
   `lines_of_code.count`, `pull_request.count`, `commit.count`; the page gives
   `claude_code.lines_of_code.count`, `claude_code.pull_request.count`,
   `claude_code.commit.count`. A query written from the first pass matches nothing.
5. **`claude_code.hook` needs two variables, not one.** obs#48 records
   `ENABLE_BETA_TRACING_DETAILED=1`; the page requires *"`ENABLE_BETA_TRACING_DETAILED=1`
   **and** `BETA_TRACING_ENDPOINT`"*. The hook span is the one Phase 5A and the isolation
   check would want, and it is behind a second, undocumented-here endpoint variable.

**Additions:**

6. **`ENABLE_ENHANCED_TELEMETRY_BETA` is an accepted alias** for
   `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA`. Two spellings of a registered variable is an
   independence hazard: a run whose record shows one unset is not proof the feature was off.
7. **Three more metric-inclusion flags exist**, all defaulting to **`false`**:
   `OTEL_METRICS_INCLUDE_VERSION`, `OTEL_METRICS_INCLUDE_ENTRYPOINT`,
   `OTEL_METRICS_INCLUDE_REPOSITORY`. The two the first pass names —
   `OTEL_METRICS_INCLUDE_ACCOUNT_UUID`, `OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES` — default
   `true`, as recorded.
8. **The event list has grown well past the nine recorded.** Newly documented names this
   project has a direct use for: **`claude_code.skill_activated`**,
   **`claude_code.hook_registered`**, **`claude_code.hook_execution_start`**,
   **`claude_code.hook_execution_complete`**, plus `api_refusal`,
   `api_request_body`, `api_response_body`, `auth`, `internal_error`, `at_mention`,
   `api_retries_exhausted`. *No total is stated here: the page's own count line and its list
   disagreed on this reading, and a number I cannot re-derive is not a measurement.*
   - `claude_code.skill_activated` is the signal **E-004 did not have.** That experiment
     measured activation through the observatory's run record, where `skill.name` is
     redacted to `custom_skill` and two installed skills cannot be told apart. Whether this
     event carries a usable name is **not known from the docs** and is a question for a run,
     not for this extract.
   - The three hook events are what would make *"0 hook executions"* in the isolation check
     an observation rather than an absence. Today that row proves a negative from a missing
     value; a `hook_execution_start` count of zero is a different and better proof.
9. **`user.email` is documented on metrics and events — and on no span type.** The page's
   standard-attributes table (which governs metrics and events) carries `user.email`,
   `user.account_uuid`, `user.account_id`. None of the six span types lists it.

### What that last item does to Lab 10.0, and to what obs#48 proved

obs#48 — *"Claude traces are available behind a beta flag"* — was confirmed and fixed in
`6333df8`, merged via obs#46, closed 2026-08-10. Lab 10.0's three checkboxes are **not
equally answered by it**, and the gap is the interesting part:

| Lab 10.0 checkbox | Answered by the #48 fix? | Evidence / what is still open |
|---|---|---|
| "Does a Claude run now produce a trace?" | **Yes, conclusively** | Off/on probe against Claude Code 2.1.226, same OTel env both times, only `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` differing: **0 traces off, 1 `claude_code.interaction` on**. `observatory.run.id` lands on the span resource, so the `traceUrl` written into every record since M6 resolves — *those deep links had been dead the whole time*. `STATE.md` corrected; `claude-telemetry.sh` no longer hardcodes `traceId: null` under a header asserting traces do not exist |
| "Run a task needing a build under `--permission-mode acceptEdits`, headless. Does `claude_code.tool.blocked_on_user` appear?" | **No — the span type was seen, the scenario was not run** | The #48 probe saw `claude_code.tool.blocked_on_user` on a **two-tool probe**, which proves the span type is emitted by this build. It does **not** test the checkbox's scenario. Tracked on obs#47. Treating "the span exists" as "the detector works under acceptEdits-headless" would be a scope claim the probe does not support |
| "Grep the collector output for `user.email`. Is it there?" | **No, and #48 could not have answered it** | #48's privacy re-check reads *"span attributes are ids, durations, token counts and model names. No prompt or response content"* — **true, and about spans.** `user.email` is not a span attribute in the first place (item 9 above). So **enabling traces changed the email exposure not at all**; whatever exposure exists arrived with metrics/events, i.e. on every telemetry-enabled run since long before #48. The checkbox is a question about the metrics/events pipeline and is still open |

**The re-scoping is the finding.** A reader of Lab 10.0 would take "#48 is fixed" as
answering all three lines; one is answered, one is answered at a smaller scope than it
asks, and one was never in the fix's path. The measurement obs#48 does own, and which
nothing here weakens: re-running the adapter over stored V2 run `6b0ca69c` returns cost
`0.125022` and 16 tool calls, identical to the recorded values — **no historical measurement
moves.**

### The GenAI semconv tombstone — one thing to add to it

The tombstone itself is recorded at [0B](../00b-observatory/#extract) and in `SOURCES.md`,
which also states the precedence rule (*a ✅ is a statement about HTTP, a tombstone is a
statement about CONTENT, and the tombstone wins*). Not re-litigated here. Two additions:

- **`SOURCES.md` says the sub-pages "still resolve" ✅.** They do. But the attribute
  registry at `https://opentelemetry.io/docs/specs/semconv/registry/attributes/gen-ai/`
  now labels **every `gen_ai.*` attribute `deprecated` — "moved to the OpenTelemetry GenAI
  semantic conventions repository."** Resolving and being current are different properties,
  which is the tombstone's own lesson applied one level down. `gen_ai.operation.name`'s
  value table is the one thing still marked `Development` rather than deprecated.
- **The spec has no cost attribute at all.** Names verified: `gen_ai.request.model`,
  `gen_ai.response.model`, `gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens`,
  `gen_ai.usage.cache_creation.input_tokens`, `gen_ai.usage.cache_read.input_tokens`,
  `gen_ai.usage.reasoning.output_tokens`, `gen_ai.agent.{id,name,description}`,
  `gen_ai.tool.{name,type,call.id,description}`, `gen_ai.operation.name`,
  `gen_ai.conversation.id`. Content rides on `gen_ai.input.messages` /
  `gen_ai.output.messages`, both flagged as likely to contain PII.
  - **This independently supports obs#48's decision to keep metrics on events.** That comment
    says `cost_usd` and the cache read/creation split *"have no span equivalent"* and calls
    the trace "correlation only". Precisely: the **cache split does exist in the spec**
    (`cache_creation` / `cache_read`) and is absent from *Claude's* spans — a claim about the
    implementation. **Cost is absent from the specification**, so no runtime's spans will
    supply it and the events path is not a workaround, it is the only path.
  - `gen_ai.conversation.id` is the spec's name for what Claude Code calls `session.id`.

---

## §4 step 2 — layers, and the trap this stop has to survive

`Decided by Opus 5 (claude-opus-5), autonomously, 2026-09-29.`

The rule is applied **in order**, stopping at the first yes, and it is applied **to the proof,
not to the artifact** (§5).

| Artifact of this stop | Layer | Why it stops there |
|---|---|---|
| This extract, and every correction in it | **L3** | Words in a workbook. Nothing executes them. A reader who skips the section is not stopped by anything |
| The ticked ☑ boxes in *Verified reading* | **L3** | A checkbox is a claim by whoever ticked it. `check-links.sh` does not read it and nothing reconciles the two |
| `check-links.sh` on this file | **L2**, over HTTP reachability **only** | It executes and it fails closed on a 404. It returned `ok=5 moved=0 broken=0` here — **including the semconv tombstone and the deprecated registry page.** Its scope is the server's answer, not the page's content, and this stop is the second recorded instance of that gap mattering |
| The term counts off `cli-ref.html` | **L2**, for this one question | A count either is or is not there. It is re-derivable by a stranger with `curl` + `awk`, which is why it is the thing that overturned the fetch tool's answer |
| `lockCaptureContent` / `captureContent` | **L3 here** | Real L2 primitives — for a Copilot deployment. **Decision G: that arm does not exist in this project.** Recording them as controls this project holds is the mistake `GUARDRAILS.md` exists to prevent |
| Lab 10.0's three checkboxes | **L3 until run** | The re-scoping table above says which the obs#48 fix already answers. Two are open and become L2 only when a run produces the observation |

**The trap.** `build/README.md#b13` — Phase 10's Track B counterpart, which is **stop 28 and is
not opened** — states it as measured history rather than as advice:

> "`JSONL → Markdown/CSV comparison → OpenTelemetry → Prometheus → Grafana` — **in that
> order.** Both business-case documents say do not start with Grafana; **you already did, and
> both documents were right.** Local artifacts first, dashboards only when enough runs exist to
> make one meaningful."

So the trap of production observability here is **building the dashboard before the runs exist
to fill it** — an L1 dashboard that answers *"are people using it?"* while the only question
asked was *"does it improve engineering?"*

**Which layer converts it: none of the three, and that is the honest answer.** No schema, hook
or checker can reject a premature dashboard; "enough repetitions exist" is clause 5 of the
seven-clause promotion gate, and that gate is **L3 prose in `build/README.md` today**. The
nearest L2 conversion is a gate script that refuses to publish a comparison below a registered
`n` — and it is **not built here**, because stop 28 owns B13 and §6 forbids a future step's
artifacts. Recorded for the author rather than built.

*Nothing of stop 26 or later is created by this stop. The B13 quotation above is required
reading for a Track A stop's trap, not the start of B13.*

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
