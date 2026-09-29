# Prediction — the collector scrub probe, registered before the probe runs

Lab 10.0 checkbox 3 is *"Grep the collector output for `user.email`. Is it there?"*
The grep has already been run and returns **zero** across 102 MB of persisted collector
output (`infra/telemetry-out/*.jsonl`, four files, 12 697 log records). A zero is not an
answer on its own: it does not distinguish *the scrubber deleted it* from *nothing ever sent
it*. `infra/otel-collector/config.yaml:5-8` claims the stronger reading —

> the attribute processor below deletes prompt/response/tool bodies **even if a runtime is
> misconfigured and sends them**, so a single wrong env var on a laptop cannot exfiltrate
> source code

— and that claim has never been exercised. A control that has never been shown to reject
anything is indistinguishable from one that rejects nothing.

The probe: POST one synthetic OTLP log record to the live collector
(`http://127.0.0.1:4318/v1/logs`) carrying `user.email` **twice** — once as a resource
attribute and once as a log-record attribute — plus `gen_ai.prompt` and `tool.arguments` as
record attributes, and a unique marker string so the result is greppable. Then grep
`infra/telemetry-out/events.jsonl` for each planted key.

## Predictions, with mechanism

**P1 — direction.** The **record-level** `user.email` is deleted; the **resource-level**
`user.email` **survives into `events.jsonl`**.
*Mechanism:* the OpenTelemetry Collector's `attributes` processor operates on the telemetry
item's own attributes — span attributes, metric data-point attributes, log-record attributes
— and does not touch the resource. Editing resource attributes is the separate `resource`
processor, and `config.yaml` configures no `resource` processor in any pipeline
(`service.pipelines.logs.processors: [attributes/scrub, batch]`). Nothing in the file is
wired to see a resource attribute.

**P2 — magnitude.** Of the four planted content/identity keys, **3 of 4 are deleted and
1 of 4 survives**: `gen_ai.prompt`, `tool.arguments` and record-level `user.email` gone,
resource-level `user.email` present.

**P3 — what it does to the claim.** If P1 holds, `config.yaml:5-8` is **true over a smaller
scope than it states**. The misconfiguration it names — "a single wrong env var on a laptop"
— is precisely the class that sets an OTel **resource** attribute, because
`OTEL_RESOURCE_ATTRIBUTES` is an env var and is the standard way identity reaches a
resource. The comment would then describe a guard against the one channel the guard does not
cover. This is the house failure mode arriving in the privacy control rather than in a gate
script.

**P4 — the reading if P1 is refuted.** If the resource-level key is also deleted, the
processor's scope is wider than the OTel documentation implies for this collector version
(`otel/opentelemetry-collector-contrib:0.115.1`) and the comment's claim is sound as
written. That would be the stronger result for the project and the weaker one for me; it is
registered as the more likely refutation.

**P5 — the zero stays meaningful either way.** Whatever the probe returns, the measured fact
about real runs is unchanged: `user.email` has never appeared in 102 MB of this project's
collector output. Under P1 that is because this project's runs never emit it, not because
the collector removes it, and the write-up must say which.

Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-29T18:4xZ; the author did not
review before the probe.
