# B12 — Governed self-learning

**Track A first:** [Phase 9](../09-memory/) · **Layer 3 — untrusted derived state**
**Version:** **v1.3**
**Spine position:** 27 of 28 · after [B11](../b11-efficiency/) · before [B13](../b13-production-observability/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b12).
> Everything else is yours to fill.
>
> ⚠️ **Placement is provisional.** B12's prerequisite (Phase 9) clears at spine position 24,
> but B11 must precede it by numeric order and B11 needs Phase 10. See the open decision about
> prerequisite order vs version order.
>
> 📌 **The business case says do not build this yet** — and `LEARNING-PATH.md` decision 5 agrees.
> Keep the design; do not ship it until v1.2 is stable.

---

## Goal

<!-- TODO -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     EFFICIENCY-SELF-LEARNING §  v1.3 governed self-learning (the whole design)
     BUSINESS-REQUIREMENTS P7    unknown data remains unknown
     BUSINESS-REQUIREMENTS NFR-006 evidence integrity
     BUSINESS-REQUIREMENTS §22   ADR policy -->

### External — the technique

<!-- TODO -->

## Extract

<!-- TODO. The line that matters most: only *verified* outcomes may
     become reusable knowledge. Quote it and list what that excludes. -->

## Build

**Build:** the pipeline that turns verified outcomes into durable knowledge without polluting it.

```
observation → learning candidate → validation → confidence
            → promotion → usage tracking → revalidation → expiration
```

**The rule:** only **verified** outcomes may become reusable knowledge. Never learn from
assumptions, failed repairs, transient outages, unverified commands, one-off preferences, raw
logs, secrets, or hidden evaluator content.

**Never write directly to active knowledge.** Candidates land in `knowledge/candidates/` with
full provenance: source run, source commit, the command, exit code, focused and broader
verification results, confidence, expiry.

```
Promotion policy
  build commands       1 successful verification + human approval
  failure patterns     2 successful occurrences   + human approval
  style/architecture   human approval always
```

States: `candidate → active → deprecated → rejected → expired`. **Never delete** — change
status, preserve history. On a failure caused by learned knowledge: mark suspect, stop reuse,
fall back to discovery, create a correction candidate.

**Where it lives.** The observatory's Postgres, next to `runs` — because a candidate's whole
value is its provenance, and provenance is a foreign key:

```sql
knowledge_entry(id, type, scope, content, status, confidence, expires_at,
                source_run_id REFERENCES runs(id),   -- the join that makes this worth doing
                source_commit, verifying_command, exit_code)
knowledge_usage(entry_id, run_id, outcome)           -- hit rate, for free
```

Split across two databases, *"did runs using entry X pass more often?"* becomes a
correlation exercise. In one it is a `JOIN`.

**Expose it as a read-only MCP server, not an embedded file.** It stays outside the agent's
`git archive` tree so the allowlist assertion still sees everything, and the write path goes
through the governance job rather than the agent — the same separation as gh-aw safe outputs.

## Predict before you run

<!-- TODO -->

## Lab B12.1 — does learning measurably improve future runs?

<!-- TODO: this is the hardest measurement in the track. The gate says
     "learning measurably improves future runs" — decide the design of
     that comparison before building the pipeline, or you will build
     something unmeasurable. -->

## Deliberate failure

<!-- TODO: promote a deliberately wrong entry and confirm the rollback
     path works — mark suspect, stop reuse, fall back to discovery. -->

## Exit gate

**From the build track:** all learning has provenance · no uncontrolled writes to active
knowledge · stale knowledge expires or revalidates · conflicts detected · a bad item can be
rolled back · **learning measurably improves future runs.**

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
