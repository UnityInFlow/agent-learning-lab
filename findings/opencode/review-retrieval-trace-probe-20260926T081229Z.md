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
reviewed_utc:    20260926T081229Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p06b/retrieval-trace-probe.sh
    sha:  1c8ed0fd78d5
    dirty: false
lab_head:        2e07543
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Acceptance

The gate failed to run (opencode exit 1).
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 45s |
| ollama-cloud/deepseek-v4-pro | ok | 112s |

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
| THE DETECTOR IS REGISTERED HERE, IN THIS FILE, AT TWO SENSITIVITIES | 1/2 | L2 |
| SCHEMA THIS PROBE ASSUMES, stated because nothing in a synthetic fixture can catch a wrong assumption (this is why exit 6 exists) | 1/2 | L2 |
| REGISTERED-EXIT-CODES: 0 2 3 4 5 6 | 1/2 | L2 |
| verdict. Precedence is registered in the header and is: unparsable-everything, then schema mismatch, then empty population, then detection, then clean. | 1/2 | L2 |
| Cross-cutting | 1/2 | L2 |
| Header — exit-code contract ("REGISTERED-EXIT-CODES" and "SCOPE OF A HIT") | 1/2 | L3 |
| Header — exit-code contract ("exit 5" description vs. "WRONG SHAPE" routing) | 1/2 | L3 |
| Detector — `attrs_of` (attribute container shape) | 1/2 | L2 |
| records mode — missing `runId` guard | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### THE DETECTOR IS REGISTERED HERE, IN THIS FILE, AT TWO SENSITIVITIES
**Verdict:** finding
**Failure:** A Read event whose target attribute is `/etc/hosts`, `Dockerfile`, or `src/Model.PY` identifies a specific file, but neither detector matches it. The probe exits 0 and reports `NO FILE-NAMING VALUE FOUND`; one reviewer can accept that conclusion from the extension-restricted detector definition, while another rejects it because the stated objective is to determine whether file identity is recoverable. The artifact does not define these recoverable file identities as out of scope.
**Layer of the implied fix:** L2
**Anchor:** STRICT — a path with at least one separator and a source/doc extension

### SCOPE OF A HIT — read this before trusting an exit 3.
**Verdict:** no finding
**Failure:** No concrete input was found for which the document-wide, Read-scoped-any, and Read-scoped-attribute counters produce a result inconsistent with the stated scope distinctions.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### SCHEMA THIS PROBE ASSUMES, stated because nothing in a synthetic fixture can catch a wrong assumption (this is why exit 6 exists)
**Verdict:** finding
**Failure:** Given a parsed OTLP document with `resourceLogs: ["unexpected"]`, the traversal calls `.get()` on a string and Python terminates with an AttributeError and exit 1. Given a log record whose `observatory.run.id` uses a valid nested non-scalar value such as `{ "arrayValue": { "values": [] } }`, `run_ids.add(...)` raises `TypeError: unhashable type: 'dict'`, again exiting 1. In both cases the input schema differs from the assumption, but the promised schema-mismatch exit 6 is not produced.
**Layer of the implied fix:** L2
**Anchor:** If telemetry input parses and contains log records but NOT ONE `tool_name` attribute is recognised, the schema has moved and the probe exits 6 rather than reporting an empty population

### Usage
**Verdict:** no finding
**Failure:** No concrete argument combination was found that violates the documented mode arity while escaping the usage and file-existence checks.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### REGISTERED-EXIT-CODES: 0 2 3 4 5 6
**Verdict:** finding
**Failure:** Give the probe an existing telemetry file containing invalid UTF-8 bytes. `open(path)` or iteration raises `UnicodeDecodeError`, the embedded Python process exits 1, and the shell propagates 1. Exit 1 is neither registered nor classified as exit 5 even though the artifact says exit 5 covers input that is not JSON. A verifier limited to ordinary malformed UTF-8 text can pass while this specific diff to the fixture exposes an undeclared exit.
**Layer of the implied fix:** L2
**Anchor:** nothing could be read: every input was empty, blank, or not JSON — NOT ONE JSON document parsed

### verdict. Precedence is registered in the header and is: unparsable-everything, then schema mismatch, then empty population, then detection, then clean.
**Verdict:** finding
**Failure:** Use telemetry containing one recognized Read event whose target is `/etc/hosts`. The population is non-empty, the schema is recognized, and all detector counters remain zero, so the final branch exits 0 with `NO FILE-NAMING VALUE FOUND`. The wrong clean verdict follows directly from the detector's unstated exclusion of extensionless file identities.
**Layer of the implied fix:** L2
**Anchor:** print("verdict: NO FILE-NAMING VALUE FOUND over a non-empty population.")

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category or pass/fail scoring gate exists, so there is no duplication to name. Reviewers are most likely to diverge on `THE DETECTOR IS REGISTERED HERE, IN THIS FILE, AT TWO SENSITIVITIES`: for `/etc/hosts`, one can treat the registered extension grammar as authoritative and accept exit 0, while another applies the probe's file-identity objective and expects a hit—an exit-code divergence of 0 versus 3. The artifact needed to state which file-identity syntaxes are excluded from the claim and what executable behavior handles unsupported-but-recoverable identities; without that boundary, the final negative claim is broader than the detector.
**Layer of the implied fix:** L2
**Anchor:** can this instrument name what a run READ?


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### Header — exit-code contract ("REGISTERED-EXIT-CODES" and "SCOPE OF A HIT")

**Verdict:** finding
**Failure:** A telemetry file containing exactly one log record whose `tool_name` is `Write` and whose body carries a path-shaped string (`"file":"src/main.kt"`), and **zero** `Read` records. Two reviewers reading the header disagree on the exit code. Reviewer A reads line 59-60 and expects **exit 3** — "at least one value matched somewhere in the document" is satisfied, and the "SCOPE OF A HIT" block (lines 21-22) explicitly promises the document-wide scan "reports a hit on ANY string in the document, in any event." Reviewer B reads the code (line 383 `if population == 0:` → `sys.exit(EX_EMPTY)`) and returns **exit 4**, because the empty-population check runs before the hit check. The header never registers the 4-vs-3 precedence — the only precedence it registers (lines 68-70) is "a partially unparsable input is NOT 5." The `DETECTOR FIRED, BUT NOT ON ANY READ` verdict (lines 397-400) is therefore unreachable whenever `read_events == 0`, which is exactly the case its own "SCOPE OF A HIT" prose describes.
**Layer of the implied fix:** L3 — the defect is that the machine-readable header contract and the implemented precedence disagree, and nothing enforces the *mapping* (only the *set* of codes is asserted by `verify-retrieval-trace-probe.sh`, line 53-56).
**Anchor:** `#   3  scan completed and at least one value matched somewhere in the document. Read the` — and, in the code, `if population == 0:` (line 383).

### Header — exit-code contract ("exit 5" description vs. "WRONG SHAPE" routing)

**Verdict:** finding
**Failure:** A telemetry input whose single line is the valid-JSON scalar `[]` (or `3`, or `"x"`). The line parses, `isinstance(doc, dict)` is False, `f_nonobj` increments, and the code reaches lines 355-357: it prints `verdict: WRONG SHAPE — … valid JSON but not JSON objects` and calls `sys.exit(EX_UNPARSABLE)` (exit **5**). The header's exit-5 description (lines 65-67) is "every input was empty, blank, or **not JSON**." A non-object JSON line is *not* "not JSON" — it parsed as JSON — so the header gives no home for this case, and the verdict string "WRONG SHAPE" is exit-**6** vocabulary ("SHAPE was not recognised — a SCHEMA MISMATCH"). Two reviewers: does `[]` input mean 5 or 6? The header cannot decide. The header also claims exit 5's message "distinguishes 'no content at all' from 'content that is not JSON'" (line 66), but there are three outcomes folded into 5 (empty / not-JSON / valid-but-non-object) and only two are described.
**Layer of the implied fix:** L3 — the exit-code *meanings* are prose no verifier asserts; `verify-retrieval-trace-probe.sh` only checks that the exercised *set* equals the declared set, so a wrong condition→code mapping is invisible to the L2 control.
**Anchor:** `verdict: WRONG SHAPE — {nonobject_lines} line(s) were valid JSON but not ` (line 356) together with `sys.exit(EX_UNPARSABLE)`.

### Detector — `attrs_of` (attribute container shape)

**Verdict:** finding
**Failure:** An OTLP telemetry file whose `logRecords[]` path is intact but where each record's `attributes` field is a single object rather than a list of objects — e.g. `"attributes": {"key":"tool_name","value":{"stringValue":"Read"}}` (a plausible flattening of the documented `[{key,value:{<type>:v}}]` shape). The `logRecords` guard and the `tool_name` guard both pass, so no exit-6 fires. But `attrs_of` does `for a in node.get("attributes", []) or []`, and a non-empty dict is truthy, so `a` iterates over *keys* (strings) and `a.get("key")` (line 161) raises `AttributeError`. The Python dies with **exit 1**, a code that is not in the registered set (line 53) and that the header's schema-drift promise (line 46-48: "the schema has moved and the probe exits 6") claims is impossible. This is precisely the "wrong assumption a synthetic fixture can't catch" the header worries about (lines 36-37), and the guard does not catch it.
**Layer of the implied fix:** L2 — a guard that executes and rejects the bad shape (exiting 6) instead of crashing to an unregistered 1.
**Anchor:** `for a in node.get("attributes", []) or []:` (line 160) / `key = a.get("key")` (line 161).

### records mode — missing `runId` guard

**Verdict:** finding
**Failure:** A records input `{"runs":[{"foo":1},{"foo":2}]}` where the run array exists but every member lacks `runId` (the field was renamed, e.g. to `run_id`). `records` is incremented per item (line 221), so `population == 2` and exit 4 does not fire; `run_ids` stays empty; and with no path match the probe returns **exit 0** — "NO FILE-NAMING VALUE FOUND over a non-empty population." The probe claims it scanned a non-empty population of run records when it could not extract a single run id. The telemetry mode has an explicit guard for exactly this asymmetry (`tool_name_attrs == 0` → exit 6, lines 370-374), but records mode has no `run_ids == 0` counterpart, so a schema drift in the run-id field is silently treated as a valid clean population rather than a schema mismatch.
**Layer of the implied fix:** L2 — a guard that executes and exits 6 when the run array parses but no `runId` is recognised, mirroring the telemetry `tool_name` guard.
**Anchor:** `population = read_events if MODE == "telemetry" else records` (line 382) — the asymmetry with `if MODE == "telemetry" and tool_name_attrs == 0:` (line 370).

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** Not a rubric; no scoring categories exist. The analogous duplication is internal: the exit-**6** "schema mismatch" concept is spread across four separate guards (log-records, tool-name, records-shape, plus the *missing* attributes-shape and run-id guards), and three of the five drift surfaces the header names are not actually gated — only the first three are.
- **Which single section would two reviewers diverge on most?** The exit-code contract header vs. the verdict tail. The 3-vs-4 precedence is the sharpest: the header's exit-3 text ("somewhere in the document") directly contradicts the code's empty-population-first ordering, and the only place that resolves it is a non-header code comment (line 349-350). I would expect a divergence of a full exit-code difference (3 vs 4) on the same input, and possibly 5 vs 6 on non-object JSON.
- **What did the artifact not say that it needed to say?** It never states, in the machine-readable header, the *precedence between* exit 4 (empty population) and exit 3 (detection). That single omission is what makes the strongest negative-claim input — "hits exist, but only on Write events" — resolve differently depending on which section a reader trusts. It also never declares that a non-object JSON line (valid JSON, wrong shape) is exit 5 rather than 6, and never registers that a crash (exit 1) is out of contract for the `attributes`-shape and run-id drift cases it claims exit 6 covers.
