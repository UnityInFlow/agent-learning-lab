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
reviewed_utc:    20260926T071645Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p06b/retrieval-trace-probe.sh
    sha:  70b234f7c287
    dirty: false
lab_head:        a99541a
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/p06b/retrieval-trace-probe.sh
  verdict: REJECT
  summary: The probe's exit codes cannot answer its own question — exit 3 fires on any file-naming value anywhere in the document (Write, Grep, or any non-Read event), not only on Read-event paths; and exit 4 depends on hardcoded attribute keys and a nested-dict format that nothing verifies against real observatory telemetry.
  blocking:
    - reason: The scan loop applies STRICT/LOOSE to every string in every log record, not only Read events. Exit 3 ("DETECTOR FIRED") is reached whenever any event in the document contains a file-naming value — Write, Grep, or any other tool — independently of whether the actual Read event carried a file path.
      wrong_action: A reader sees `verdict: DETECTOR FIRED — at least one value names a file.` and concludes the run's read identity was recovered, when the actual hit could be on a Write event's `path` attribute or any non-Read record. In records mode the header acknowledges the changedFiles case but the exit code does not encode the distinction; in telemetry mode the analogous conflation is not even acknowledged, and `hits by JSON key` cannot separate Read from Write hits because both attributes appear under the same `attributes.value.stringValue` key path.
      anchor: "for key, val in strings(doc):"
      evidence: evidence/p06b/retrieval-trace-probe.sh:173
    - reason: The exit-4 ("POPULATION EMPTY") guarantee depends on two hardcoded attribute keys (`tool_name`, `observatory.run.id`) and the `attrs_of` nested-dict format assumption (`isinstance(val, dict)`) that the fixture (`verify-retrieval-trace-probe.sh`) does not verify against a captured real telemetry sample; the header itself never states these schema assumptions. A real schema using flat-string attribute values or different key names yields zero `read_events` for a file that genuinely contains Read events.
      wrong_action: A reader sees `verdict: POPULATION EMPTY — zero Read events.` and concludes the run had no reads or the observatory does not capture reads, when reads may have happened under a different schema; the header's claimed guard against "found no path returned by a run that looked at nothing" inverts in the opposite direction.
      anchor: "if at.get(\"tool_name\") == \"Read\":"
      evidence: evidence/p06b/retrieval-trace-probe.sh:108, evidence/p06b/retrieval-trace-probe.sh:188, evidence/p06b/retrieval-trace-probe.sh:190
  non_blocking:
    - reason: For records mode, the machine verdict uses untruncated `strict_by_key`/`loose_by_key` counters while the printed `hits by JSON key` is truncated to top-10 keys with 2 examples per key; a hit on an 11th+ distinct key drives exit 3 but is invisible in the printed breakdown.
      evidence: evidence/p06b/retrieval-trace-probe.sh:214, evidence/p06b/retrieval-trace-probe.sh:229
    - reason: The header does not declare the probe's schema assumptions (which attribute keys name the tool and run id, whether attribute values are nested `{stringValue: ...}` dicts or flat strings); this documentation gap compounds the schema-key issue above.
      evidence: evidence/p06b/retrieval-trace-probe.sh:2
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 18s |
| ollama-cloud/deepseek-v4-pro | ok | 80s |

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
| Detector regexes (STRICT / LOOSE / EXT) | 1/2 | L2 |
| records mode | 1/2 | L3 |
| telemetry mode | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### evidence/p06b/retrieval-trace-probe.sh
**Verdict:** finding
**Failure:** In telemetry mode, supply one valid OTLP document containing (1) a `Read` log record with no file-naming value and (2) an unrelated `Write` log record whose attribute value is `src/output.py`. The script counts a non-empty Read population but scans every string in the entire document, so `src/output.py` triggers exit 3 and the verdict `DETECTOR FIRED`. One reviewer can treat this as evidence that a run’s reads are identifiable; another can correctly attribute the match only to the write event. The probe therefore produces the wrong answer to its stated question.
**Layer of the implied fix:** L2
**Anchor:** for key, val in strings(doc):

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category or pass/fail gate exists, so there is no duplication to name. Reviewers will diverge most on the telemetry scan scope: one may read `Every string value in the document` literally, while another follows the stated purpose and assumes only `Read` records are scanned; this can reverse the result from exit 0 to exit 3 for the same mixed-event input. The artifact needed to say—and enforce—whether matching is limited to values attached to `Read` events or intentionally includes every value in each telemetry document.
**Layer of the implied fix:** L2
**Anchor:** """Every string value in the document, with the JSON key path that holds it."""


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### Header and exit-code registry
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The header's framing is honest about one thing — it says the probe "does NOT judge" and that a `changedFiles` hit is expected — but it makes an absolute claim later (`exit 4 … so that "found no path" can never be returned by a run that looked at nothing`) that the code cannot actually back. I flag that under `telemetry mode`, where the claim breaks. This section itself is sound as prose.

---

### Argument parsing / usage
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Mode dispatch, file-existence checks, and the `records`-mode arity check (`$# -ne 1`) are all exercised before the Python heredoc and exit 2 on violation. Nothing here produces a divergent reading.

---

### Detector regexes (STRICT / LOOSE / EXT)
**Verdict:** finding
**Failure:** The detector scans **every string value in every log record**, not only Read events. The `read_events` filter (`tool_name == "Read"`) is applied to the *population counter* only, never to the STRICT/LOOSE scan. Concrete input — `events.jsonl` with one `Read` event whose argument holds no source path (e.g. reading a URL or a glob with no extension) plus one `Write` event with `path: "src/Order.kt"`: `read_events == 1` (so population is non-empty and exit 4 is skipped), the Write event's path fires STRICT, and the script exits 3 with `verdict: DETECTOR FIRED — at least one value names a file.` The read's file was never recovered; the detector is pointing at a *write*. Because the header says "a hit in telemetry would refute extract finding 3," this exit 3 reads as a false refutation. Two reviewers will disagree on whether exit 3 proves the run's *read* was traceable, which is the entire point of the probe.
**Layer of the implied fix:** L2 — the fix is code that scopes the scan to Read-event strings; after it, something executes and the detector only fires on a Read.
**Anchor:** `for key, val in strings(doc):` (line 173) — the scan loop is independent of the `at.get("tool_name") == "Read"` test at line 190.

---

### strings() and attrs_of() traversal
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`strings()` correctly recurses dicts and lists and yields only string leaves; `attrs_of()` guards `isinstance(val, dict)` before `next(iter(val.values()))`, so scalar attribute values are skipped rather than crashing. The list path collapsing (`path + "[]"`, no index) loses positional information, but that only degrades the diagnostic, not the verdict.

---

### records mode
**Verdict:** finding
**Failure:** `records` mode counts `result.changedFiles` strings the same as any other, so a records file containing a changedFiles path but no telemetry fires exit 3 identically to a genuine read recovery. The header acknowledges this ("a hit in `result.changedFiles` is expected … that field records writes"), but the *exit code* does not encode the distinction — the probe's headline answer (did a run's reads get recovered?) is `exit 3` either way. A reviewer handed exit-3 output for `records` mode cannot tell whether the run's read identity was recovered without manually re-reading the `hits by JSON key` breakdown, which itself is truncated (top-10 keys, 2 examples). A hit in the 11th key, or beyond the second example, drives exit 3 while being invisible in the printed evidence — so the machine verdict and the human-facing evidence can disagree about *where* the hit is.
**Layer of the implied fix:** L3 — the header's acknowledgment is a comment a reader must remember; nothing executes to separate write-path hits from read-path hits.
**Anchor:** `if strict_by_key or loose_by_key:` (line 229) computing the verdict from untruncated counters, vs `most_common(10)` (line 214) on the printed side.

---

### telemetry mode
**Verdict:** finding
**Failure:** The exit-4 guarantee is anchored to two hardcoded attribute keys that nothing verifies against the real observatory schema: `at.get("tool_name") == "Read"` (line 190) and `at.get("observatory.run.id")` (line 188). If the observatory records the tool name under a different key — e.g. `tool.name`, `otel.tool_name`, or a flat string `{"key":"tool_name","value":"Read"}` (which `attrs_of` drops at the `isinstance(val, dict)` guard because a plain-string value is skipped) — then `read_events` counts 0 for a telemetry file that genuinely contains Read events, and the script exits 4 with `POPULATION EMPTY — zero Read events.` This is exactly the false conclusion the header says the code exists to prevent, and it is produced by a run that *did* look at reads. The fixture (`verify-retrieval-trace-probe.sh`) cannot catch this: it proves the code against the same hardcoded keys, not against a captured real telemetry sample, so the test passes against itself while the schema drifts.
**Layer of the implied fix:** L2 — the correct fix is a fixture asserted against a real captured telemetry sample that fails when the keys don't match. As written, the key assumption is only a header comment, i.e. the current state is L3 (a claim nothing enforces).
**Anchor:** `if at.get("tool_name") == "Read":` (line 190)

---

### verdict / exit-code logic
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The exit precedence is internally consistent: empty population resolves to 5 (unparsable) only when `parsed_docs == 0`, else 4 (empty), and 3 (hit) is unreachable at population 0 because the population check runs first. Mixed input (some lines parse, some don't, zero Reads) correctly lands on 4 rather than 5, matching the stated exit-5 definition ("no JSON object could be read from *any* line"). The dead `unparsable`/`batches` accumulators are cosmetic only.

---

### Cross-cutting
- **Pass/fail gate duplication:** none. The exit codes are a single decision surface; the defect is not duplication but that exit 3 is *too coarse* — it reports "a file-naming value was found" and cannot say whether it was a read or a write, which is the question the probe exists to answer.
- **Greatest divergence between two reviewers:** `telemetry mode` — one reviewer reads exit 3 as "the read was traced" (per the header's refutation claim), the other inspects `hits by JSON key` and finds the hit is on a Write/Grep event's path or a non-Read record. The gap is a full refutation vs. a null result, i.e. the probe's entire dependent variable.
- **What it did not say that it needed to say:** the probe never states its schema assumptions — which attribute keys name the tool and the run id, and whether telemetry attribute values are nested `{stringValue: ...}` dicts or flat strings. Both are load-bearing for exit 4 and are asserted only in comments, so a consumer cannot tell whether a clean/empty verdict is a property of the run or of a key-name mismatch.
