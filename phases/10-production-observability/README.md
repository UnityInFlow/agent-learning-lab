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

> **Reconciled 2026-09-29 by the Lab 10.0 RUN, after the §4a round raised the apparent
> contradiction (2/2):** this list says `user.id` is *"always sent"*, and the checkbox-3 census
> finds **0 occurrences of `user.id` in 102 276 888 bytes** of collector output. Both are true
> and they are about different points in the path. *Always sent* is a statement about what the
> runtime **emits**; the census is a statement about what the collector **writes to disk**, and
> `user.id` is on the `attributes/scrub` delete list. **Corrected after §4a round 2, which
> caught an overclaim of mine at 2/2 recurrence:** an earlier version of this note said the probe
> *proves* the `user.id` deletion executes. **It does not. The probe never planted `user.id`.**
> It planted `user.email`, `gen_ai.prompt` and `tool.arguments`, and what it proves is that
> **that processor deletes record-level attributes it is configured to delete**. That `user.id`
> is on the same delete list is read off `config.yaml`; that it is therefore also removed is an
> **inference from configuration**, not an observation. The honest statement: emitted by the
> runtime, listed for deletion, absent from disk — and the deletion of *this particular key* is
> **unprobed**. One more planted placement would settle it and was not sent.
> *(For `user.email` the same reasoning does **not** apply, because these runs have no OAuth
> identity to emit in the first place — see the RUN's checkbox 3.)*
>
> **The same applies to `organization.id` and `session.id`, named by round 3 at 2/2 as a further
> contradiction with the second-pass extract, and it is the same one.** `organization.id` is on
> the scrub delete list and is absent from disk: emitted-then-deleted by configuration, and
> **unprobed**, exactly as `user.id` is. `session.id` is the opposite case and is the control
> that makes the others legible — it is **not** on the delete list, and the census finds it on
> **12 696 of 12 697 lines, 79 704 occurrences.** So the pipeline is demonstrably capable of
> carrying a per-session identifier all the way to disk; the keys that are missing are missing
> because they are configured to be. That is the nearest thing to a positive control the real
> corpus offers, and it costs nothing to read.

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
# ^ THESE THREE NAMES ARE INCOMPLETE — the page gives claude_code.lines_of_code.count,
#   claude_code.pull_request.count, claude_code.commit.count. Corrected in the second-pass
#   extract below; pointer added here 2026-09-29 after the §4a panel raised it at 2/2 in
#   BOTH rounds, because a reader of this block alone writes the wrong query.
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

> **Superseded in part on 2026-09-29 by the Lab 10.0 RUN below, and kept unedited.** This
> table says checkbox 2 is open and checkbox 3 is open. **The run closes both.** Checkbox 2 was
> open only because nobody had looked at a stored trace; checkbox 3 was open only because nobody
> had run a negative control. Nothing in the table was wrong when written — it is the reading of
> the #48 fix, and the #48 fix did not answer them. The §4a round flagged the resulting
> internal inconsistency (1/2) and this note is the fix; the table is not rewritten.

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
    implementation. **Cost is absent from the specification**, so no
    *conformant* span carries it and the events path is not a workaround but the only standard
    one. *(Narrowed 2026-09-29 after the §4a round, which was right that a vendor may add a
    non-standard attribute — so "no runtime's spans will supply it" was a claim about runtimes
    that only the specification can support. Claude's spans do not carry it, checked on this
    stop's two traces: `n = 2`, true of those runs.)*
  - `gen_ai.conversation.id` is the spec's name for what Claude Code calls `session.id`.

---

## Lab 10.0 — RUN at spine stop 25, 2026-09-29

*The lab as the author wrote it is three checkboxes, above. This is the run. Two of the
three were answerable from evidence already on disk and were not re-run; the third needed
one synthetic OTLP record and its prediction is committed at `4af56b3`, before the probe.
Nothing above this line is rewritten.*

**All evidence is under [`evidence/p10/`](../../evidence/p10/).** No benchmark run was
commissioned for this lab. The one claude run it reads, `e488ed2e-9f90-4e5b-b7d1-53871b8d2755`,
is this session's own §0a row-6b preflight run, which was already paid for and which
**enters no comparison** — it is read here as a telemetry sample, not as a measurement of any
arm.

### Checkbox 1 — "Does a Claude run now produce a trace?" → **YES, and it still does**

Answered conclusively by obs#48 (`[P1] Claude traces are available behind a beta flag —
STATE.md says they are not`, closed `completed` 2026-08-10T19:46:05Z, fixed in `6333df8` via
obs#46; issue state re-read from the API at 2026-09-29T18:1xZ, not quoted from the
workbook). Its off/on probe held Claude Code 2.1.226 and the same OTel env on both sides
with only `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` differing: **0 traces off, 1
`claude_code.interaction` on.** `STATE.md` was corrected there and `claude-telemetry.sh`
stopped hardcoding `traceId: null`. **Not re-run — §6 forbids spending a run on a settled
question.**

**What this lab adds that #48 could not:** the finding **still holds on a build seven weeks
newer**. Run `e488ed2e` emitted trace `a4dc23a3f3c9cefa1de70222adbc1799` under
`service.version` **2.1.284** (#48's probe was 2.1.226), and `observatory.run.id`
= `e488ed2e-9f90-4e5b-b7d1-53871b8d2755` is on the span **resource**, which is the thing that
makes the `traceUrl` in every run record since M6 resolve. Evidence:
[`evidence/p10/trace-e488ed2e-blocked-on-user.json`](../../evidence/p10/trace-e488ed2e-blocked-on-user.json),
76 486 bytes, fetched from Tempo at `http://127.0.0.1:3200/api/traces/a4dc23a3f3c9cefa1de70222adbc1799`.
One version observation is `n = 1` and is stated as true of this run, not as a property of
the build.

### Checkbox 2 — the acceptEdits-headless scenario → **RUN, NOT DEFERRED, twice, and the answer is not the one the name implies**

The second-pass extract logged this as open because the #48 probe saw the span type on a
*two-tool probe* rather than under the checkbox's scenario, and warned that reading the one as
the other would be a scope claim the probe does not support. **The scenario has in fact been
run — repeatedly — and nobody looked.** Runs `e488ed2e-9f90-4e5b-b7d1-53871b8d2755` and
`606ab03e-1171-494c-97f1-6dc2f485ba9c`, this session's two §0a row-6b preflight runs, are both:

| The checkbox asks for | Both runs | Proof |
|---|---|---|
| headless | `claude "${CLAUDE_ARGS[@]}" --output-format stream-json --verbose -p "$(cat …/task.md)"` | `runner/run-agent.sh:883-885` |
| `--permission-mode acceptEdits` | yes, a literal element of `CLAUDE_ARGS` | `runner/run-agent.sh:838` |
| a task needing a build | BE-001, `build: true`, `tests: true`, gates `maven_build` / `maven_test` | `agent-observatory-benchmarks/tasks/BE-001-customer-validation/benchmark.yaml:9-19` |
| does `claude_code.tool.blocked_on_user` appear? | **yes — 14 times and 15 times** | census below |

**The census** — `evidence/p10/checkbox2-span-census.txt`, plus the replication trace
`evidence/p10/trace-606ab03e-replication.json`. Both runs are Claude Code `service.version`
2.1.284 on BE-001:

| span | run `e488ed2e` | run `606ab03e` | pooled |
|---|---|---|---|
| `claude_code.interaction` | 1 | 1 | 2 |
| `claude_code.llm_request` | 15 | 12 | 27 |
| `claude_code.tool` | 14 | 15 | **29** |
| `claude_code.tool.blocked_on_user` | 14 | 15 | **29** |
| `claude_code.tool.execution` | 14 | 13 | 27 |

**It fires 1:1 with tool calls in both runs — 29 of 29, on every Bash, Read and Edit.** In a
headless run there is no user, so nothing could block on one. **A panel counting this span
counts tool calls**, and would have reported 29 human interventions across two runs in which
zero were possible.

**The first run said the span carries nothing; the second run refuted that, and the refutation
is the better finding.** On `e488ed2e` all 14 read `decision: "unknown"`. On `606ab03e`,
**13 read `unknown` and 2 read `reject`** — and the 2 are exactly the 2 tool calls that have no
`claude_code.tool.execution` span:

```
toolu_01JtKxYHAQirDQHTojU7V9jZ   Bash  argv0=cd    class=shell_builtin   -> decision=reject, never executed
toolu_01CHK1z2qM9qrn2WhUkK1Sh6   Bash  argv0=git   class=vcs             -> decision=reject, never executed
```

Both were refused by the runner's three-entry allowlist —
`--allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)" "Bash(.ai/knowledge/router.sh:*)"`,
`runner/run-agent.sh:838-841` — which admits neither `cd` nor `git`.

**So the discriminator exists, and it is not the span.** Corrected reading, pooled over
`n = 2 runs, 29 spans`:

- the **span** is emitted on every tool call, 29 of 29, blocked or not — **counting it measures
  tool calls**;
- the **`decision` attribute** is the signal: `unknown` on **27 of 29**, `reject` on **2 of 29**,
  and the 2 rejects match the 2 un-executed tools one for one;
- the **`source` attribute is `unknown` on 29 of 29** — nothing in the span says *what* refused
  the call. That the allowlist did it is deduced from the tool names and `run-agent.sh:838-841`,
  **not read off the telemetry**;
- and the 2 rejects were a **permission-mode refusal by a static allowlist, not a human**, under
  a span named `blocked_on_user`, in a run with no human in it.

**That last line is direct evidence for obs#47** — *"[P0] Permission-mode block recorded as
incorrect code"*, still **open**, state re-read from the API this session. The same
mis-attribution obs#47 reports in the harness is present in the runtime's own span name.

**Consequence for this project, stated rather than left implied:** a panel counting
`claude_code.tool.blocked_on_user` measures tool calls; a panel counting it *filtered to
`decision != "unknown"`* measures permission refusals; **neither measures human intervention**,
and nothing in the telemetry or its documentation says so. No dashboard may be built on the
unfiltered span. Stop 25 builds none, so nothing is retracted; the constraint is recorded for
stop 28's B13 dashboards.

**What changed between the two runs, and what did not.** Same model, same benchmark, same
runtime version, same flags, same allowlist — the runs differ only in what the model chose to
do, which is why one hit the allowlist and the other did not. **`n = 2` is two runs and is
stated as such**: the 1:1 ratio held on both, the `reject` value appeared on one, and neither is
claimed as a property of the build.

### Checkbox 3 — "Grep the collector output for `user.email`" → **it is not there, and the reason is not the one the config claims**

**The grep, first.** Across all four persisted collector files —
`infra/telemetry-out/events.jsonl` plus three rotations —
**102 276 888 bytes across 12 697 JSONL lines**, each line one collector export batch holding
several log records, so the line count is a lower bound on the records and is stated as lines
rather than rounded up into a record count. Counted **before** the probe below added its
one line — the counts are:

| key | lines | occurrences |
|---|---|---|
| `user.email` | 0 | 0 |
| `user.id` | 0 | 0 |
| `user.account_uuid` | 0 | 0 |
| `organization.id` | 0 | 0 |
| `terminal.type` | 0 | 0 |
| `gen_ai.prompt` | 0 | 0 |
| `tool.arguments` | 0 | 0 |
| `session.id` | 12 696 | 79 704 |

**A zero is not an answer.** It does not distinguish *the scrubber deleted it* from *nothing
ever sent it*, and `infra/otel-collector/config.yaml:3-5` makes the stronger claim — that the
processor deletes these keys *"even if a runtime is misconfigured and sends them, so a single
wrong env var on a laptop cannot exfiltrate source code."* **That claim had never been
exercised.** A control that has never been shown to reject anything is indistinguishable
from one that rejects nothing.

**So it was exercised.** One synthetic OTLP log record was POSTed to the live collector at
`http://127.0.0.1:4318/v1/logs` carrying `user.email` **twice** — once as a *resource*
attribute, once as a *log-record* attribute — plus `gen_ai.prompt` and `tool.arguments` as
record attributes, each value tagged with the unique marker
`P10SCRUBPROBE20260929T180630Z`. Sent payload:
[`evidence/p10/scrub-probe-sent.json`](../../evidence/p10/scrub-probe-sent.json). Prediction
committed **before** the probe at `4af56b3`
([`evidence/p10/PREDICTION-scrub-scope.md`](../../evidence/p10/PREDICTION-scrub-scope.md)).

**Result — P1 and P2 both hold, exactly**
([`evidence/p10/scrub-probe-surviving-record.json`](../../evidence/p10/scrub-probe-surviving-record.json)):

| planted key | where | survived into `events.jsonl`? |
|---|---|---|
| `user.email` | **resource** attribute | **YES — verbatim** |
| `user.email` | log-record attribute | no |
| `gen_ai.prompt` | log-record attribute | no |
| `tool.arguments` | log-record attribute | no |

**3 of 4 placements deleted, 1 of 4 survives** — four placements of three key names, since
`user.email` was planted twice. The survivor is an email address; the record as it left the
collector still reads
`user.email = resource-level-P10SCRUBPROBE20260929T180630Z@example.invalid`.

**The two copies were planted with DISTINCT markers on purpose**, `resource-level-…` and
`record-level-…`, so the survivor's level is read off the value itself rather than inferred
from where it landed. The §4a round raised this as an ambiguity because
`PREDICTION-scrub-scope.md` does not say so; **the prediction under-specified the probe and the
probe as executed did not suffer from it** (`evidence/p10/scrub-probe-sent.json`). The
prediction is not edited (§4 step 12); the correction is in `evidence/p10/RESULT-scrub-scope.md`.

**The record arriving at all is the probe's own positive control**, and it is what separates
*deleted* from *dropped*. `events.jsonl` grew by exactly one line; that line carries the marker,
the body and two of the three resource attributes. Ingestion, routing and file serialization
therefore all worked for this record, so **the three missing attributes are missing from a
record that arrived** — removed by a processor, not lost by the pipeline.

**Mechanism, as predicted:** the Collector's `attributes` processor edits the telemetry
item's own attributes and does not touch the resource; editing resource attributes is the
separate `resource` processor, and `config.yaml` configures none in any pipeline
(`service.pipelines.logs.processors: [attributes/scrub, batch]`).

**What this does to the claim.** `config.yaml:3-5` is **true over a smaller scope than it
states**. The misconfiguration it names — *"a single wrong env var on a laptop"* — is
precisely the class that lands on the **resource**, because `OTEL_RESOURCE_ATTRIBUTES` is an
env var and is the standard way identity reaches a resource. The comment describes a guard
against the one channel the guard does not cover.

**Stated as what it is: that last sentence is an inference, not a measurement.** The probe sent
a direct OTLP POST; it did **not** set `OTEL_RESOURCE_ATTRIBUTES` on a runtime and watch the
value travel. What is measured is that **a resource attribute survives the scrub**; that a
mis-set env var is one way to put one there is read from the OTel specification, and the §4a
round was right to separate the two. **The scrub is a real L2 control and its
measured scope is the LOGS pipeline's log-record attributes.** The §4a round was right to press
on this and the claim is narrowed to what was probed: **only the logs pipeline was probed.**
The traces and metrics pipelines list the *same* processor
(`service.pipelines.{traces,metrics}.processors: [attributes/scrub, batch]`) and the
processor's behaviour does not vary by signal, so the same gap is **expected** there — but
expected is not measured, and no span or data-point attribute was planted. Two probes that
were not run.

**What is NOT claimed.** No leak has occurred. `user.email` has never appeared in this
project's real collector output, on those 102 276 888 bytes; the runs are `ISOLATE_USER_SETTINGS=1` with
no OAuth identity to emit and they set no identity resource attribute. The finding is about
**what the control would stop if something did**, which is what checkbox 3 was asking.

**One artefact is deliberately left on disk:** the probe record, with its
`@example.invalid` address, is now the last line of `infra/telemetry-out/events.jsonl`. It is
evidence and §6 forbids deleting it. It is marked `service.name: p10-scrub-probe` and
`observatory.run.id: P10SCRUBPROBE20260929T180630Z`, matches no benchmark run, and enters no
adapter's per-run read.

### The layer table for this lab's own proofs

| What the lab concluded | Layer of the **proof** | Why that layer |
|---|---|---|
| A claude run produces a trace, on 2.1.284 | **L1** *(was L2 here and L1 in the §5 table; the §4a round raised the clash 2/2 and it is reconciled to L1)* | Applied in order: the value is a span written into Tempo by the runtime, and **nothing in this repository can hand-write it**, so the first question — *can the bad value still be written down?* — answers no and the rule stops there. It was labelled L2 for *"Tempo returned the trace"*, but a store answering a query is not a thing that rejects a wrong value |
| `blocked_on_user` appears under acceptEdits-headless | **L2** | 14 spans counted off the stored trace by a script in `evidence/p10/` |
| The span is not the discriminator; `decision` is | **L1** | `source` `unknown` on **29 of 29**; `decision` `unknown` on **27 of 29** and `reject` on **2 of 29**, the 2 matching the 2 un-executed tools exactly — read off the stored spans, no judgement in the path |
| Nothing may be built on that span yet | **L3** | A sentence in this workbook. Nothing executes to refuse such a panel. The L2 conversion is a gate script at stop 28 and §6 forbids building it here |
| The scrub deletes record-level identity **in the logs pipeline** | **L2** | The planted record-level `user.email` is provably absent from the file the collector wrote. **Scope named because only that pipeline was probed:** traces and metrics list the same processor and were not tested |
| The scrub does **not** cover resource attributes | **L1 for the fact, L3 for the fix** | The fact is structural: with no `resource` processor configured, no resource attribute can be edited — the bad value cannot be removed after it is written down. **No fix is made here**; changing the collector config is an observatory change outside this stop's one variable |

### What a stranger re-derives, in four commands

**Every path below is relative to `agent-learning-lab/`** — one base, because the §4a round
was right that the first version of this block mixed two in one copy-paste surface:

```bash
cd agent-learning-lab

# the whole lab's numbers, re-derived and checked (exit 0 = matched, 2 = mismatch)
python3 evidence/p10/verify-lab-numbers.py
python3 evidence/p10/verify-lab-numbers.py --selftest      # proves it rejects

# or by hand, one claim at a time
curl -s http://127.0.0.1:3200/api/traces/a4dc23a3f3c9cefa1de70222adbc1799   # checkbox 1 + 2
grep -c user.email ../agent-observatory/infra/telemetry-out/*.jsonl        # checkbox 3, the zero
curl -X POST http://127.0.0.1:4318/v1/logs -H 'Content-Type: application/json' \
     -d @evidence/p10/scrub-probe-sent.json                                # the probe
grep -o 'resource-level-[A-Z0-9]*' ../agent-observatory/infra/telemetry-out/events.jsonl
```

*Run by Opus 5 (claude-opus-5), autonomously, 2026-09-29. Prediction `4af56b3` precedes the
probe; the author did not review before the run.*

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
| Lab 10.0's three checkboxes | **L3 until run → now L1/L2, see the RUN section** | *(This row was written at §0 boundary 1, before the run. The §4a round flagged that it still says "two are open" while the RUN section answers all three; dated amendment 2026-09-29, row not rewritten.)* The re-scoping table says which the obs#48 fix already answers. Two were open; **both were then answered from evidence already on disk** — a stored trace for checkbox 2, a negative control for checkbox 3 — and their proofs are L1/L2 in the RUN's own layer table |

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

> **Name clash, flagged by the §4a round at 2/2 recurrence and recorded rather than resolved
> by edit (2026-09-29).** The L1/L2/L3 below are **adoption / agent execution / engineering
> impact** — a *metric taxonomy*, the author's, from the first pass. They are **not** the
> workspace `CLAUDE.md` guardrail layers (structural / enforced / guidance) used in every
> layer column in this workbook and in every §5 table in this project. Two unrelated
> three-level scales share three labels, and a reader who carries one into the other will
> mislabel a control. The author's section is not renamed here — it is the author's text and
> §6 is one step at a time — but **every "L1/L2/L3" elsewhere in this file is the guardrail
> scale**, and the two are never mixed in one sentence.

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

## §4 step 11 — the learning block, and the exit gate answered

```yaml
learning:
  what_was_added: >
    No artifact, no tool, no overlay. Stop 25 added a RUN of Lab 10.0 and the evidence under
    evidence/p10/ — a trace census, a grep census, one synthetic OTLP record, a prediction
    committed before it, and a result file beside it. The one thing that behaves like a
    control is the negative control on the collector's scrub processor, and it is a probe,
    not a fixture set.
  why_it_exists: >
    §3's itinerary row 25 registers "Lab 10.0 written up from the #48 fix", closing on
    "evidence on disk". The second-pass extract had already found that the #48 fix answers
    one of the lab's three checkboxes conclusively, one at a smaller scope than it asks, and
    one not at all; the lab exists to answer the other two rather than to let a reader take
    "#48 is fixed" as answering all three.
  observed_effect: >
    Two of three checkboxes were answerable from evidence already on disk, which is the
    cheapest possible outcome and was not the expected one: checkbox 2's acceptEdits-headless
    scenario had ALREADY RUN — twice this session, 29 tool calls between them — and the finding
    was sitting in Tempo unread. `claude_code.tool.blocked_on_user` fires 1:1 with tool calls,
    29 of 29, in headless runs where no user could block on anything. The first run suggested the
    span carried nothing (`decision` unknown 14 of 14); the second refuted that — 2 of its 15 read
    `reject`, matching the 2 tool calls the runner's allowlist refused, which makes the DECISION
    ATTRIBUTE the discriminator and the span itself a tool-call counter. `source` is `unknown` on
    29 of 29, so the telemetry never says what refused the call. Checkbox 3's zero was real (0 occurrences in 102 276 888 bytes) and meaningless
    until a negative control was run; the control then showed the scrub deletes record-level
    identity and DOES NOT TOUCH RESOURCE ATTRIBUTES, so a planted `user.email` on the resource
    survived verbatim onto disk. *(Scope, narrowed after §4a: the probe tested the LOGS
    pipeline only. Traces and metrics list the same processor, so the same gap is expected
    there and was not measured.)*
  unexpected_effect: >
    The lab's own instrument — the phase whose thesis is "usage is not impact" — turned out to
    contain a span that is a textbook instance of the thesis, and the project's privacy
    control turned out to be the house failure mode: true over a scope smaller than its own
    comment claims. Neither was predicted; the scrub SCOPE was predicted (P1/P2 held exactly)
    but only after the checkbox-3 zero forced the question.
  keep_or_remove: >
    KEEP the evidence; there is nothing built to remove. Two constraints are recorded rather
    than enforced: no dashboard may be built on `claude_code.tool.blocked_on_user` while its
    decision/source are `unknown`, and `config.yaml:3-5`'s claim must be read as covering
    record/span/data-point attributes only. Both are L3 sentences in this workbook and neither
    is converted here — §6 is one step at a time and the collector is an observatory change.
  next_question: >
    Does the resource-attribute gap matter in practice — i.e. does any runtime this project
    drives ever set identity via OTEL_RESOURCE_ATTRIBUTES? Measured here: no, on 102 MB. The
    L2 conversion, a `resource` processor with a fixture set proving it rejects, is an
    observatory instrument PR and is not this stop's.
```

### Exit gate

- [x] **I can name a metric in each of L1/L2/L3 for my chapter.** L1 adoption: runs
      commissioned per week against this observatory (the run table is the population).
      L2 agent execution: `evaluation.exitCode` pass rate per arm, with `estimatedCost` and
      `modelCalls` beside it — the pair every B step has reported since B2. L3 engineering
      impact: **this chapter has none and cannot have one**, because the agent under test
      operates on benchmark fixtures and never on a repository whose PR cycle time, escaped
      defects or change-failure rate could move. Naming an L3 metric here would be the
      dashboard-before-the-runs trap, so the honest fill is *L3 is out of reach for this
      instrument and the reason is structural, not a backlog item*.
- [x] **I can explain why usage is not impact to a non-engineer.** Stop 25 supplies the
      explanation as a measurement rather than an analogy: a panel counting
      `claude_code.tool.blocked_on_user` would have reported **14 human interventions in a run
      where no human was present**. The count is real, the events are real, and the conclusion
      is false — because the metric measures a span being emitted, not the thing the span is
      named after. That is what "usage is not impact" means with the abstraction removed.
- [ ] **My comparison dashboard shows uncertainty, not just a winner.** **NOT MET, and not
      met by design at this stop.** No comparison dashboard exists. The project's actual
      comparison surface is `make baseline-report`, which §4 step 8 requires to report
      **median and range, never a mean alone** — that is uncertainty rather than a winner, and
      it is where every B step's numbers have come from. The Dashboards section above asks for
      p25/p75 and sample count on top of that, and building it is stop 28's B13 work. §6
      forbids a future step's artifacts early, so this box stays unticked and names its owner.
- [x] **I can state the promotion gate from memory.** Seven clauses, `build/README.md#b13`:
      deterministic checks do not regress; benchmark quality improves or stays within approved
      tolerance; safety guardrails do not regress; cost increase is justified; enough
      repetitions exist; a human reviews the qualitative diff; rollback is defined. Clause 5
      is the one this phase is about, and it is L3 prose — nothing executes that would refuse
      to publish a comparison below a registered `n`.
- [x] **I know what my telemetry captures and what it deliberately does not.** Captured, and
      verified on disk this stop: five span types
      (`interaction`, `llm_request`, `tool`, `tool.blocked_on_user`, `tool.execution`) into
      Tempo; ten log-event names into `events.jsonl`, the most frequent being
      `hook_registered`, `api_request`, `tool_result`, `tool_decision`; resource attributes
      `observatory.run.id`, `benchmark.id`, `experiment.variant`, `service.{name,version}`,
      `host.arch`, `os.{type,version}`. Deliberately not captured, by
      `infra/otel-collector/config.yaml`: `gen_ai.prompt`, `gen_ai.completion`,
      `gen_ai.input.messages`, `gen_ai.output.messages`, `gen_ai.system_instructions`,
      `user.email`, `user.id`, `user.account_id`, `user.account_uuid`, `organization.id`,
      `terminal.type`, `tool.arguments`, `tool.result`, `code.content`. **And now, measured
      rather than read off the file: that deletion covers record-level attributes, in the logs
      pipeline, which is the only pipeline probed.** The traces and metrics pipelines carry the
      same processor and the same gap is expected there; expected is not measured, and two
      probes were not run.

**Was this the agent, or the harness?** **The harness, twice over, and neither finding is
about the agent under test at all.** `claude_code.tool.blocked_on_user` is emitted by the
Claude Code runtime irrespective of what the model did; the scrub scope is a property of the
collector's configuration. Stop 25 commissioned no run and measures no arm — it is a stop
about the instrument, which is what a Phase stop is for, and no number here enters any
comparison.

## §5 — validation table

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| §3 row 25: *"Phase 10: reading, extract, Lab 10.0 written up from the #48 fix"* — **reading** | `phases/10-production-observability/README.md` §"Verified reading" + §"Extract, second pass" (commit `468e105`); `./tools/check-links.sh` on it → exit 0, `ok=5 moved=0 blocked=0 unverified=0 broken=0` | **L2 for "the URLs answer", L3 for "the content is current".** The script executes and exits non-zero on a dead link, so the first half is enforced. It cannot see a tombstone: two of the five `ok` pages are dead for the reader's purpose (the GenAI semconv tombstone; the attribute registry now marking every `gen_ai.*` deprecated). That gap is lab#13's open question and is stated, not closed | `./tools/check-links.sh phases/10-production-observability/README.md` |
| §3 row 25 — **extract** | same commit `468e105`: four findings, five corrections, four additions | **L3.** A wrong sentence can still be written into this file and nothing executes over it — the same regrade stop 24 applied to its own extract row at its close, for the same reason | `git show 468e105 -- phases/10-production-observability/README.md` |
| §3 row 25 — **"Lab 10.0 written up from the #48 fix"** | `phases/10-production-observability/README.md` §"Lab 10.0 — RUN at spine stop 25" (commit `4065a99`), with all three checkboxes answered from `evidence/p10/` | **L3 for the write-up, L1/L2 per checkbox below.** The prose is prose; the checkbox rows carry the proof | read the section; every claim in it cites a file in `evidence/p10/` |
| Lab checkbox 1 — *"Does a Claude run now produce a trace?"* | obs#48 closed `completed` 2026-08-10T19:46:05Z (state re-read from the API 2026-09-29, not quoted from prose); re-observed this stop on run `e488ed2e-9f90-4e5b-b7d1-53871b8d2755`, trace `a4dc23a3f3c9cefa1de70222adbc1799`, `service.version` 2.1.284 | **L1 in the sense stop 24 settled** — the span and its resource were written into Tempo by the Claude Code runtime, not hand-written by me. **The copy at `evidence/p10/trace-e488ed2e-blocked-on-user.json` is L3**, being an editable file; the live store is the L1 half | `curl -s http://127.0.0.1:3200/api/traces/a4dc23a3f3c9cefa1de70222adbc1799` |
| Lab checkbox 2 — *"Run a task needing a build under `--permission-mode acceptEdits`, headless. Does `claude_code.tool.blocked_on_user` appear?"* | **Yes. 29 times against 29 tool calls, 1:1 in each of `n = 2` runs** (`e488ed2e` 14/14, `606ab03e` 15/15). `evidence/p10/checkbox2-span-census.txt`. Scenario proved element by element: `runner/run-agent.sh:838` (acceptEdits), `:883-885` (headless `-p`), `agent-observatory-benchmarks/tasks/BE-001-customer-validation/benchmark.yaml:9-19` (`build: true`, `tests: true`) | **L1** for the span data (same sense as the row above); **L2** for the scenario, because the three flags are read out of files that execute — the runner is what runs, not a description of it | re-run the census script against the trace JSON; `grep -n 'permission-mode' runner/run-agent.sh` |
| …and the finding beneath it: **the span counts tool calls; `decision` is what discriminates, and `source` never does** | `source: "unknown"` on **29 of 29**. `decision`: `unknown` **27 of 29**, `reject` **2 of 29** — and the 2 rejects are exactly the 2 `tool_use_id`s with no `claude_code.tool.execution` span, both `Bash` (`cd`, `git`), both outside the runner's three-entry allowlist at `runner/run-agent.sh:838-841`. Durations `n = 29`, min 2 ms, max 53 ms | **L1** for the attribute values — read off the stored spans. **L3 for "the allowlist is what refused them"**: that is deduced from the tool names and the runner's flags, because `source` declines to say | `evidence/p10/trace-606ab03e-replication.json`; correlate `tool_use_id` across the three span types |
| …and the constraint drawn from it: *no panel may be built on that span* | a sentence in this workbook | **L3.** Nothing executes that would refuse such a panel. Its L2 conversion is a gate script and belongs to stop 28 (B13); §6 forbids building it here | read the section |
| Lab checkbox 3 — *"Grep the collector output for `user.email`. Is it there?"* | **No. 0 lines, 0 occurrences** across `infra/telemetry-out/*.jsonl` = 102 276 888 bytes / 12 697 lines, counted **before** the probe. `evidence/p10/checkbox3-grep-counts.txt` | **L1** for the count — it is a grep over files the collector wrote. **But on its own it answers nothing**, and the table says so: a zero cannot separate *deleted* from *never sent* | `grep -c user.email agent-observatory/infra/telemetry-out/*.jsonl` |
| …the negative control that gives the zero meaning | Prediction `4af56b3` **precedes** the probe (18:0x commit → 18:06:30Z POST); probe `evidence/p10/scrub-probe-sent.json`, survivor `evidence/p10/scrub-probe-surviving-record.json`, result `evidence/p10/RESULT-scrub-scope.md`. Record-level `user.email`, `gen_ai.prompt`, `tool.arguments` **deleted**; resource-level `user.email` **survived verbatim** | **L2 for the three deletions** — the collector executed and rejected them, which is the first time this control has been shown to reject anything. **L1 for the survival**: with no `resource` processor in any pipeline, a resource attribute cannot be edited by this config, so the bad value cannot be removed after it is written down | POST `evidence/p10/scrub-probe-sent.json` to `http://127.0.0.1:4318/v1/logs`, then `grep -o 'resource-level-[A-Z0-9]*' infra/telemetry-out/events.jsonl` |
| §5 — *at least one scored cell re-read by hand* | **No scored cell exists. `n = 0` benchmark runs were commissioned at this stop** and no rubric sheet belongs to it. The §0a preflight sheet `findings/codex/score-good-nested-ifs-*.yaml` is a probe that **enters no comparison**, and its four values were nonetheless re-derived by hand with `awk` and checked by the registered `check-sheet-categories.sh` | **L2** for the sheet check that was done; the clause itself is **not applicable** and is recorded as such rather than ticked | see `preflight:` in `TRACK-B-STATE.md` |
| §5 — *every number quoted in prose has its `n`* | `29 of 29` spans over `n = 2` runs, with the per-run split `14/14` and `15/15` shown rather than only pooled; `0 of 12 697` lines; `3 of 4` planted **placements** (of three key names) on `n = 1` probe, in the **logs pipeline only**; the 2.1.284 version observation is explicitly `n = 1` and stated as true of that run | **L3** | read the section |
| §5 — *independence check: what else changed?* | **Nothing to compare, so nothing to confound.** Stop 25 has no arms. The one run it reads, `e488ed2e`, was `ISOLATE_USER_SETTINGS=1` with all **seven** `customization.*Hash` null and `runtime.model` `claude-haiku-4-5-20251001`, read off the API this session | **L1** — an API record the runner wrote | `curl -s http://127.0.0.1:8081/api/runs/e488ed2e-9f90-4e5b-b7d1-53871b8d2755` |
| §5 — *the table's own numbers are checked by something that executes* | `evidence/p10/verify-lab-numbers.py` — exit 0 on the real sources; exit 2 with `MISMATCH e488ed2e.tool: workbook says 999, sources give 14` under `--selftest` | **L2, and proved to reject.** Written in response to the §4a panel's 2/2 objection that runtime-written evidence was rated L1 while nothing executed to catch a false quotation of it | `python3 evidence/p10/verify-lab-numbers.py; python3 evidence/p10/verify-lab-numbers.py --selftest` |
| §5 — *re-run every verification command immediately before writing "done"* | §0a re-run in full this session, every row; the link check, the Tempo fetch, the grep census and the probe were all run in this session and their outputs are the evidence files cited above | **L3 throughout** — a saved stdout file is as editable as any other file and nothing re-runs it. Stop 24 made the same regrade | re-run any command in the "four commands" block of the lab |

**What the layer column grades, and the objection that survived two rounds.** The proof of the
clause, never the artifact the clause is about. This table uses "L1" in the one sense stop 24's
close settled after its acceptance gate blocked on three incompatible uses: **a value nothing in
this repository can hand-write** — a record written by the runner, the collector or the runtime
into a store outside the working tree.

**The §4a panel objected to that, at 2/2 in both rounds, and it was right:** a span in Tempo
cannot be hand-written, but **a sentence in this table about that span can be**, and nothing
executed to reject a false one. Under the rule applied strictly, every evidence row above was
**L3 on the correspondence** however solid its provenance. Two senses were being collapsed:

| | what it grades | this stop |
|---|---|---|
| **provenance** | can the cited value be hand-written? | **L1** — it is in Tempo / the collector's file / the API, none of which this repo writes |
| **correspondence** | does anything execute to prove *this table* quotes it correctly? | **was L3. Now L2** — see below |

**So a checker was written rather than the label argued.**
[`evidence/p10/verify-lab-numbers.py`](../../evidence/p10/verify-lab-numbers.py) holds every
number this lab asserts as an expectation, re-derives each from the trace JSONs and the live
`events.jsonl`, and **exits 2 on any mismatch**. It is proved to reject:
`python3 evidence/p10/verify-lab-numbers.py --selftest` corrupts one expectation and the script
exits 2 with `MISMATCH e488ed2e.tool: workbook says 999, sources give 14`. Real run: exit 0,
`ok: every number Lab 10.0 asserts was re-derived from the evidence files and matched.`

**That converts the correspondence of the numbers, and of nothing else.** The prose, the layer
labels, the interpretation and the exit-gate answers remain **L3** — no script reads them.
Every editable copy of a runtime-written value under `evidence/p10/` is still separately L3 as a
copy, except where the checker now compares it to its source.

**What is NOT closed by this table.** Exit-gate item 3 (*"my comparison dashboard shows
uncertainty"*) is unticked and names stop 28 as its owner. lab#13's content-vs-HTTP question
is restated, not answered. Neither is a §7 halt: no gate here needs a registered variable to
move, and this stop moves none.

## Exit gate — the author's original list, unedited

> **It is unedited on purpose and its boxes are therefore all empty.** The §4a round read the
> two lists as a contradiction (0 of 5 here, 4 of 5 above). They are the same five questions
> asked once and answered once: **the answered copy is the §4 step 11 section above**, and this
> block is kept as the author wrote it so a reader can see what was asked before it was answered.
> Nothing here is an open item. Pointer added 2026-09-29.

- [ ] I can name a metric in each of L1/L2/L3 for my chapter
- [ ] I can explain why usage is not impact to a non-engineer
- [ ] My comparison dashboard shows uncertainty, not just a winner
- [ ] I can state the promotion gate from memory
- [ ] I know what my telemetry captures and what it deliberately does not
