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
reviewed_utc:    20260926T075937Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p06b/retrieval-trace-probe.sh
    sha:  1c8ed0fd78d5
    dirty: true
lab_head:        b972c97
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/p06b/retrieval-trace-probe.sh
  verdict: REJECT
  summary: Four defects undermine the probe's stated contracts: README and other extensionless files are silently rendered as zero hits; a `None` inside `attributes` exits 1 instead of the registered 6; the STRICT regex requires a directory name where the header says separator; and the records-mode shape probe breaks on the first list-valued key, so a multi-key document with `{"runs": [], "content": [...]}` reports an empty population regardless of what `content` holds.
  blocking:
    - reason: README and any file without one of the registered extensions is silently rendered as zero hits. A Read event carrying `file_path = "/repo/README"` is exactly the kind of value the probe's stated purpose covers ("a value from which the identity of a file could be recovered"), but neither STRICT nor LOOSE matches because the EXT list does not include the empty-extension case and the regex demands `\.<EXT>\b` at the tail.
      wrong_action: A reviewer trusting the probe's verdict (`NO FILE-NAMING VALUE FOUND` or `read_scoped_attr: strict=0 loose_only=0`) concludes no file was named, while the telemetry shows `/repo/README` was. The lab's null hypothesis becomes unfalsifiable for an entire class of files.
      anchor: "It scans one of two stages of the observatory pipeline for a value from which the identity of a file could be recovered, and reports what it found."
      evidence: evidence/p06b/retrieval-trace-probe.sh:4, evidence/p06b/retrieval-trace-probe.sh:126-130
    - reason: A log record whose `attributes` array contains `None` causes `attrs_of` to call `None.get(...)`, raising AttributeError and exiting with code 1. The header registers exit codes 0,2,3,4,5,6 and states the verifier "fails if the set it exercises differs from the set declared here."
      wrong_action: The probe's schema-mismatch contract is bypassed: the artifact promises exit 6 for "input parsed but its SHAPE was not recognised," and instead the verifier sees an unregistered exit 1 and treats the run as infrastructure failure rather than a finding.
      anchor: "REGISTERED-EXIT-CODES: 0 2 3 4 5 6"
      evidence: evidence/p06b/retrieval-trace-probe.sh:53, evidence/p06b/retrieval-trace-probe.sh:159-167
    - reason: The STRICT regex `(?:[A-Za-z0-9_.+-]+/)+` requires at least one full directory *name* before the final component, but the header's plain-English definition says "at least one separator." A root-relative single-component path such as `./main.kt`, `/main.kt`, or `~/main.kt` has a separator and a source extension but matches only LOOSE.
      wrong_action: A reviewer reading the header expects STRICT to fire on `./main.kt`; the regex silently demotes it to LOOSE. Two reviewers reading the same `read_scoped_attr: strict=0 loose_only=1` line draw opposite conclusions about whether a strong path-shaped value is present.
      anchor: "STRICT — a path with at least one separator and a source/doc extension"
      evidence: evidence/p06b/retrieval-trace-probe.sh:12, evidence/p06b/retrieval-trace-probe.sh:128-129
    - reason: In records mode the shape probe iterates `("runs", "content", "items", "data")` and breaks on the first list-valued key, even an empty one. A document like `{"runs": [], "content": [{"runId": "x", "result": {"changedFiles": ["src/main.kt"]}}]}` is reported as POPULATION EMPTY (exit 4) because `runs` is hit first, `items = []`, and the loop breaks before `content` is inspected.
      wrong_action: A reviewer sees `verdict: POPULATION EMPTY — zero run records` and concludes the input held no records, when `content` actually holds a record naming a file. The probe's null hypothesis becomes unfalsifiable over a class of multi-key documents.
      anchor: "if isinstance(doc.get(key), list):"
      evidence: evidence/p06b/retrieval-trace-probe.sh:215-219, evidence/p06b/retrieval-trace-probe.sh:376-380
  non_blocking:
    - reason: Exit code 3 is emitted for any document-wide hit, including a Write event's `result.changedFiles`. The Read-vs-Write distinction is carried by the verdict text (`DETECTOR FIRED ON A READ EVENT'S ATTRIBUTE` vs `DETECTOR FIRED, BUT NOT ON ANY READ`) and the `read_scoped` counters, not by the exit code. The header explicitly tells the caller to "Read the read_scoped line before concluding a READ was identified," so this is documented design rather than an unstated overload.
      evidence: evidence/p06b/retrieval-trace-probe.sh:32-34, evidence/p06b/retrieval-trace-probe.sh:60, evidence/p06b/retrieval-trace-probe.sh:389-404
    - reason: The header does not enumerate which attribute keys would constitute the recorded read target (e.g. `file_path`, `path`, `input`). The probe locates any path-shaped attribute value and prints the key, but does not decide which key would refute the lab's hypothesis.
      evidence: evidence/p06b/retrieval-trace-probe.sh:23-31
    - reason: The header does not state that files without a registered extension are out of the measurable claim. The EXT list is implicit in the regex on line 126, not declared in the prose, so a reader cannot tell from the header alone what counts as a "file" the probe will recognise.
      evidence: evidence/p06b/retrieval-trace-probe.sh:11-16, evidence/p06b/retrieval-trace-probe.sh:126-130
  disputed:
    - finding: "Two competent callers handle the same exit 3 differently: one treats it as a detector firing on a read, the other as a write-only false positive that proves nothing."
      why: The artifact does distinguish Read from Write via machine-readable verdict text and the `read_scoped_any` / `read_scoped_attr` counters, and the header directs the caller to read them: "Read the `read_scoped` line before concluding a READ was identified." The exit-code overload is documented; the distinction is in the verdict string and counters, which a competent caller can grep for.
 - finding: "Cross-cutting: most divergent section is the STRICT/LOOSE sensitivity boundary, by roughly one full sensitivity bucket."
      why: This predicts reviewer disagreement without anchoring it in a specific downstream action. The probe does separate STRICT and LOOSE counts on every printed line, so the disagreement is recorded rather than silent — the bucket difference is visible in the output and the verifier can read it.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 30s |
| ollama-cloud/deepseek-v4-pro | ok | 105s |

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
| Cross-cutting | 1/2 | L3 |
| `THE DETECTOR IS REGISTERED HERE` (STRICT / LOOSE regexes) | 1/2 | L2 |
| `SCHEMA THIS PROBE ASSUMES` (records shape detection) | 1/2 | L2 |
| `REGISTERED-EXIT-CODES` / exit-3 semantics | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### evidence/p06b/retrieval-trace-probe.sh
**Verdict:** finding
**Failure:** Telemetry containing a valid Read event with `{"key":"file_path","value":{"stringValue":"/repo/README"}}` has a recoverable file identity, but neither detector matches because the path lacks a registered extension. With no other path-shaped strings, the probe exits 0 and reports `NO FILE-NAMING VALUE FOUND`; a reviewer trusting the stated purpose concludes no file was named, while a reviewer inspecting the attribute concludes that `/repo/README` was named. Separately, a schema-mismatch fixture whose attribute array contains `null` makes `attrs_of` call `a.get(...)` and terminate with unregistered exit 1 instead of exit 6.
**Layer of the implied fix:** L2
**Anchor:** It scans one of two stages of the observatory pipeline for a value from which the identity of a file could be recovered, and reports what it found.

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category or pass/fail gate is present, so no duplication can be named. Reviewers would diverge most on the detector definition: one may treat STRICT/LOOSE as explicitly limited probes, while another applies the broader declared claim about recoverable file identity; for the `/repo/README` Read event their conclusions differ from “clean null” to “file identity recorded.” The artifact needed to state that extensionless files are outside the measurable claim, and it needed to specify whether malformed nested telemetry must produce registered exit 6 rather than an uncontrolled exit 1.
**Layer of the implied fix:** L3
**Anchor:** STRICT — a path with at least one separator and a source/doc extension


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### `THE DETECTOR IS REGISTERED HERE` (STRICT / LOOSE regexes)
**Verdict:** finding
**Failure:** The header defines STRICT as *"a path with at least one separator and a source/doc extension"*, but the regex `(?:[A-Za-z0-9_.+-]+/)+` demands at least one directory *name* before the final component, not merely a separator. A root-relative single-component path such as `./main.kt`, `/main.kt`, or `~/main.kt` — which has a separator and a source extension — matches only LOOSE. Concrete divergence: a Read event attribute whose value is `./main.kt` produces `read_scoped_attr: strict=0 loose_only=1`. One reviewer reads `strict=0` as "no strong path-shaped value present" (the documented meaning of STRICT); the other sees a path with a separator and treats it as strong. The two sensitivities exist so a null is not an artefact of STRICT being too strict, and here STRICT silently demotes a genuine path to the weak bucket.
**Layer of the implied fix:** L2 — the regex executes at scan time; the defect is in the executable detector, not in a prose description of it.
**Anchor:** `STRICT — a path with at least one separator and a source/doc extension`

### `SCHEMA THIS PROBE ASSUMES` (records shape detection)
**Verdict:** finding
**Failure:** In `records` mode the shape probe breaks on the *first* list-valued key it finds, even an empty one. For input `{"runs": [], "content": [{"runId": "x", "result": {"changedFiles": ["src/main.kt"]}}]}`, the loop hits `runs` (an empty list), sets `records_shape_ok = True`, assigns `items = []`, and `break`s — `content`, which actually holds the run, is never inspected. `records == 0` → exit 4 `POPULATION EMPTY`. The probe reports "a scan of nothing proves nothing" over a document that contains a record naming a file. The schema assumption ("an object with a `runs`/`content`/`items`/`data` array") is read as "exactly one of these holds the array," but nothing enforces that one is non-empty or that the first is authoritative.
**Layer of the implied fix:** L2 — a code-logic change (prefer the first *non-empty* list, or require non-empty), executable at parse time.
**Anchor:** `if isinstance(doc.get(key), list):`

### `REGISTERED-EXIT-CODES` / exit-3 semantics
**Verdict:** finding
**Failure:** Exit 3 is emitted for *any* hit anywhere in the document, including a hit sitting on a Write event's `result.changedFiles` (which the header itself calls "expected"). The distinction that actually matters to the lab's hypothesis — *was a READ identified?* — is carried only by the prose `read_scoped_attr` line and the free-text `verdict:` string. Nothing executes to make that distinction machine-readable, so a downstream `verify-retrieval-trace-probe.sh` assertion on the exit code cannot tell "finding 3 refuted" from "a Write named a file." Two competent callers handle the same exit 3 differently: one treats it as a detector firing on a read, the other as a write-only false positive that proves nothing. The probe's own header concedes this ("a hit in `result.changedFiles` is expected"), which is a signal the signal is overloaded rather than resolved.
**Layer of the implied fix:** L2 — the read-vs-write distinction is currently L3 (prose a human reads and chooses to interpret); making it enforceable requires the executable output (an exit code or a structured, exact-match line) to carry it.
**Anchor:** `0  scan completed, population NON-EMPTY, and NO value matched either sensitivity` / `3  scan completed and at least one value matched somewhere in the document.`

### `usage` / bash preamble
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Verdict precedence block (unparsable → schema → empty → detection → clean)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Duplicate pass/fail gate:** the exit-3 verdict and the `read_scoped_attr` counters gate the same underlying question (was a file identity recoverable from a Read), but the exit code does not carry the read-scoped distinction — the gate is split between an enforced exit code (any hit) and unenforced prose (read-scoped). The `records`-mode `changedFiles` caveat and the exit-3 "expected" note are the same ambiguity stated twice rather than resolved once.
- **Most divergent section:** the STRICT/LOOSE sensitivity boundary (`./main.kt` vs `./src/main.kt`). I would expect two reviewers to split on whether a single-component root-relative path "has a separator," by roughly one full sensitivity bucket, because the definition (line 12) and the regex (line 128-129) disagree.
- **What it did not say that it needed to say:** (1) which attribute *key* on a Read event would constitute the recorded read target — the header says "the keys tell you what to go and look at" but never enumerates what key would actually refute finding 3, so a `read_scoped_attr` hit is left undecidable by the probe's own admission; and (2) that `records` shape detection takes the first list-valued key even when empty, so a multi-key document can silently scan the wrong (empty) array and exit 4.
