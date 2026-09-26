# opencode review — retrieval-trace-probe

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - codex
    - ollama-cloud/deepseek-v4-pro
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260926T073240Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p06b/retrieval-trace-probe.sh
    sha:  e21edf6ee83b
    dirty: true
lab_head:        20c2f4d
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/p06b/retrieval-trace-probe.sh
  verdict: REJECT
  summary: The probe's read-scoped counter over-claims what it measures, its schema guards collapse empty-population with wrong-key, and the JSONL handler crashes on a `[]` line — so neither the negative verdict (refutes finding 3) nor the positive verdict (does not refute) is reliable.
  blocking:
    - reason: read_scoped re-scans every string in the Read log record, not the attribute that names the read target, so a non-zero count can fire on `working_directory`, prompt context, message body, or any other path-like string in the record rather than the file actually read.
      wrong_action: A reviewer trusts the verdict "DETECTOR FIRED, AND ON A READ — a value on a Read event names a file. This would refute extract finding 3" and publishes finding 3 as refuted on the strength of a hit in an unrelated attribute.
      anchor: "only a non-zero read_scoped count means \"a READ was identified\"."
      evidence: evidence/p06b/retrieval-trace-probe.sh:23-26,248-257,313-315
    - reason: The schema guard is implemented for one mode only. Records mode has no equivalent: if the run array moves from `runs`/`content`/`items`/`data` to a new key, the file parses, `records == 0`, `parsed_docs == 1`, and the probe exits 4 with "POPULATION EMPTY — zero run records" — exactly the conflation the header disclaims.
      wrong_action: A reviewer hands the probe a runs.json whose schema moved and gets "zero run records"; they publish a measurement of nothing.
      anchor: "If telemetry input parses and contains log records but NOT ONE `tool_name` attribute is recognised, the schema has moved and the probe exits 6 rather than reporting an empty population — because \"zero reads\" and \"I cannot read this format\" are different answers."
      evidence: evidence/p06b/retrieval-trace-probe.sh:39-40,189-201,300-310
    - reason: The telemetry schema guard requires `log_records > 0`. If the top-level `resourceLogs` key is renamed, `doc.get("resourceLogs", [])` returns `[]`, `log_records` stays at 0, and the guard never fires — the probe exits 4 instead of 6.
      wrong_action: A reviewer sees exit 4 and reads it as "empty telemetry stream" when the input shape has actually moved; the schema-drift signal is swallowed.
      anchor: "if MODE == \"telemetry\" and log_records > 0 and tool_name_attrs == 0:"
      evidence: evidence/p06b/retrieval-trace-probe.sh:239-241,300-304
    - reason: A JSONL line whose value is `[]` parses as valid JSON but then raises an uncaught AttributeError at `doc.get("resourceLogs", [])` — the `try/except` only wraps `json.loads`, so the script exits with a Python traceback and a code outside the registered set.
      wrong_action: A reviewer running the probe on real telemetry that contains such a line gets a stack trace and no registered verdict; they cannot tell whether the input is malformed or whether the script is broken.
      anchor: "            try:\n                doc = json.loads(line)\n            except Exception:\n                f_bad += 1\n                continue"
      evidence: evidence/p06b/retrieval-trace-probe.sh:217-224,239-241
  non_blocking:
    - reason: An empty input (0 bytes / only blank lines) classifies as exit 5 "INPUT UNPARSABLE" rather than as a distinct empty-input condition — the exit code still triggers investigation but the text misnames the diagnosis.
      evidence: evidence/p06b/retrieval-trace-probe.sh:296-298
  disputed:
    - finding: "The probe never states where the file identity is expected to live, and `strings()` does not scan attribute keys, so an OTel pipeline that records the read target as an attribute key yields silent false negatives."
      why: The OTel attribute shape stores names in `key` and values in `value.<type>`; `strings()` already walks the value side, and a normal pipeline that stores file paths as values is caught. The risk the line-level pass names (paths stored as attribute *names*) is not an OTel idiom, and the real over-claim — values scanned indiscriminately, not just the read-target attribute — is already captured by the read_scoped blocking reason above.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 24s |
| ollama-cloud/deepseek-v4-pro | ok | 106s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 independent families (2 run(s))

How many DIFFERENT model families flagged each section — not how often one model
repeated itself. A section flagged twice by the same family counts once, so a chatty
model cannot outvote the panel.

**1/2 is not weak evidence.** Families find different classes of defect: on
2026-08-28, glm-5.2 found gaps in the anchor ladder and an anchor citing evidence that
is not attached, while deepseek-v4-pro found four textual ambiguities in the same file.
Neither saw the other's list. A 1/2 row is one lens holding something the others do
not — read it first, not last.

| Section | Families | Layer of implied fix |
|---|---|---|
| evidence/p06b/retrieval-trace-probe.sh | 1/2 | L2 |
| Cross-cutting | 1/2 | L2 |
| Python detector & scan (lines 102–260) | 1/2 | L2 |
| Verdict & precedence (lines 262–327) | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### evidence/p06b/retrieval-trace-probe.sh
**Verdict:** finding
**Failure:** Given a telemetry record with `tool_name: "Read"`, a read target stored only as an opaque ID, and an unrelated record attribute such as `working_directory: "/repo/src/project.py"`, the document-wide and read-scoped counters both fire. One reviewer can conclude that the read file was identified because `read_scoped` is non-zero; another can correctly observe that the matched path is merely the working directory and says nothing about what was read. The script nevertheless prints `DETECTOR FIRED, AND ON A READ` and says this refutes finding 3. Separately, a valid JSONL line containing `[]` parses successfully but then raises an uncaught exception at `doc.get(...)`, so it produces neither registered exit 4 nor exit 6.
**Layer of the implied fix:** L2
**Anchor:** # READ-SCOPED hits — hits on strings belonging to a log record whose `tool_name` is
# `Read` — and prints them on their own line. An exit 3 means "something in this document
# names a file"; only a non-zero read_scoped count means "a READ was identified".

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category or pass/fail gate exists, so there is no duplication to name. Reviewers would diverge most on the meaning of `read_scoped`: for the `working_directory: "/repo/src/project.py"` example, one would treat the non-zero count as proof that the read target was identified while another would reject it, changing the central conclusion from refuted to untested. The artifact needed to specify which fields identify the Read operation's input, rather than treating every string anywhere in a Read log record as equivalent evidence.
**Layer of the implied fix:** L2
**Anchor:** for _k, val in strings(lr):


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### Header & REGISTERED-EXIT-CODES (lines 1–63)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The header is the strongest part of the file: it states the detector, its two sensitivities, the conservative-negative rationale, and the assumed schema, and it ties exit codes to a verifier so a new code cannot be added without a case. No defect here.

### Usage / argument handling (lines 68–100)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Mode dispatch, the records-mode single-file constraint, and the file-existence check are all enforced before the Python payload runs. The `MODE="$MODE" python3 - "$@"` hand-off is correct (`sys.argv[1:]` is the file list). No finding.

### Python detector & scan (lines 102–260)
**Verdict:** finding
**Failure:** The probe's stated purpose (header line 8) is to *name what a run READ*, but `read_scoped` does not isolate the read's target file — it re-scans **every string in the Read record**, including `tool_name`-adjacent attributes, `observatory.run.id`, `trace_id`, and any `message`/`input`/context attribute. Concrete case: a Read event whose record carries a context or prompt attribute mentioning `target.kt` (a file the agent was instructed *about*) while its actual read argument is `other.py`. `strings(lr)` matches `target.kt` against STRICT/LOOSE, `read_scoped_strict` increments, and the verdict (line 314–315) prints "a value on a Read event names a file. This would refute extract finding 3." Two reviewers diverge: one reads that line as the probe having identified what was read (its purpose); the other reads it as "a filename appears somewhere inside a Read record," which is a much weaker claim and can fire on a file that was never read. The positive-direction unsafety the header documents for the document-wide scan (lines 23–26) is reproduced one level down in `read_scoped`, while the wording presents `read_scoped` as resolving it.
**Layer of the implied fix:** L2 — the fix is a code change that executes: restrict the read-scoped classification to the attribute that actually names the read target rather than `strings(lr)` over the whole record. The over-claim itself ("a READ was identified") is L3 prose, but the wrong verdict comes from what the scan touches, not from the sentence.
**Anchor:** `"read_scoped: strict={...} loose_only={...}"   <- ONLY a non-zero value here means a READ was identified` (line 280–281), together with the verdict text `"a value on a Read event names a file. This would refute extract finding 3."` (line 314–315)

### Verdict & precedence (lines 262–327)
**Verdict:** finding
**Failure:** The header (lines 39–40) states the governing principle — *"'zero reads' and 'I cannot read this format' are different answers"* — but the schema-mismatch guard (exit 6, lines 300–304) implements it for exactly one failure, in one mode. Three schema moves all collapse to exit 4 "POPULATION EMPTY," a confident-looking measurement of nothing:

- **records mode** has no guard at all. If the run array moves from `runs`/`content`/`items`/`data` to a new key (e.g. `entries`), `items` stays `[]`, `records == 0`, `parsed_docs == 1` (the file parsed fine), and the probe exits 4 — "zero run records" — when it actually could not locate any records in a file it did parse. This is the exact false-negative the exit 6 exists to prevent, and it is absent from records mode.
- **telemetry mode**, if the top-level key `resourceLogs` is renamed, `doc.get("resourceLogs", [])` yields nothing, `log_records == 0`, so the guard (which requires `log_records > 0`) never fires, and the probe exits 4 rather than 6.

Concrete divergent outcome: a reviewer handed exit 4 on a runs.json whose schema moved reads "the run history is empty — scan of nothing proves nothing"; another reads it as a real measurement. The instrument reports an empty population in both the genuinely-empty case and the schema-drifted case, which is precisely the conflation the header disclaims.
**Layer of the implied fix:** L2 — extending the executing schema guard (the same mechanism as the existing exit 6) to records mode and to a moved `resourceLogs` key.
**Anchor:** `because "zero reads" and "I cannot read this format" are different answers.` (line 40), paired with the guard `if MODE == "telemetry" and log_records > 0 and tool_name_attrs == 0:` (line 300)

A secondary defect in the same block, lower weight: an empty input (0-byte file, or only blank lines) is classified as exit 5 "INPUT UNPARSABLE — not one JSON document read from any input" (lines 296–298). An empty events.jsonl is not unparsable, it is empty, and two reviewers read "UNPARSABLE" as "the file is corrupt/garbled" versus "the file contains nothing." The verdict word and the exit code point at different diagnoses. **Layer:** L2 (the fix is a code branch distinguishing empty-input from unparsable); the divergent read is what makes it a finding.

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** Not applicable — this is an instrument (a probe), not a rubric; there are no scoring categories and no gate to duplicate. The analogue that *is* present is the duplication between exit 6 and exit 4: both can be reached by a schema drift depending only on whether `log_records > 0` at the moment of the check, so the "schema mismatch vs. empty population" distinction is not a stable property of the input but an accident of how far the parse got.
- **Which single section would two reviewers diverge on most?** The verdict block — specifically whether exit 4 means "empty population" or "schema I could not read." The header asserts these are different answers, but the code only separates them in one narrow case, so two careful readers will assign opposite meanings to the same exit-4 output on a schema-drifted input. I would estimate the divergence as binary and full (empty vs. drifted) rather than a matter of degree.
- **What did the artifact not say that it needed to say?** It never states where the *file identity itself* is expected to live in the OTLP record — as an attribute value, an attribute key, or inside a message body. The negative-direction safety claim ("zero hits anywhere implies zero hits on Read events") is only true if file paths appear as string **values**; `strings()` does not scan attribute **keys**, so a pipeline that records the read target as an attribute key (a common OTel idiom, e.g. `{key: "file.path", ...}`) yields zero hits and exit 0, silently *confirming* finding 3 by looking in the wrong place. The header documents the `tool_name` and `run.id` keys but not the key that would carry the file path, which is the one fact the whole negative result depends on.
