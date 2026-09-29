# Result — the collector scrub probe

Prediction registered at commit `4af56b3`, before this probe ran. Nothing in the prediction
file is edited; this is the result beside it.

| Prediction | Verdict |
|---|---|
| **P1** record-level `user.email` deleted, resource-level `user.email` survives | **HELD** |
| **P2** 3 of 4 planted keys deleted, 1 of 4 survives | **HELD, exactly** |
| **P3** `config.yaml:5-8` is true over a smaller scope than it states | **HELD** — it follows from P1 |
| **P4** the refutation reading (resource key also deleted) | **did not occur** |
| **P5** the zero on real runs stays meaningful and must be labelled | **applied** — the write-up says the zero is *nothing ever sent it*, not *the collector removed it* |

Marker: `P10SCRUBPROBE20260929T180630Z`. Collector
`otel/opentelemetry-collector-contrib:0.115.1`, endpoint `http://127.0.0.1:4318/v1/logs`,
POST returned HTTP 200 `{"partialSuccess":{}}`. `events.jsonl` grew 1 639 594 → 1 640 216
bytes, one line.

As it left the collector:

```
RESOURCE   service.name        = p10-scrub-probe
RESOURCE   user.email          = resource-level-P10SCRUBPROBE20260929T180630Z@example.invalid   <- SURVIVED
RESOURCE   observatory.run.id  = P10SCRUBPROBE20260929T180630Z
RECORD     event.name          = p10.scrub.probe
           user.email          — DELETED
           gen_ai.prompt       — DELETED
           tool.arguments      — DELETED
```

**No leak occurred and none is claimed.** The address is `@example.invalid` and was planted
by this probe. The finding is the scope of the control, not an exposure.

*Probed by Opus 5 (claude-opus-5), autonomously, 2026-09-29T18:06Z.*
