# opencode review — run-b6-batch

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
reviewed_utc:    20260909T205557Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/b06/run-b6-batch.sh
    sha:  a6eed7a4b2d7
    dirty: false
lab_head:        3578685
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Acceptance — NO VERDICT (off-contract)

The gate broke its own output contract. This is not an ACCEPT.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/b06/run-b6-batch.sh
  verdict: REJECT
  summary: The treated-arm skill read-back guard admits `UNREAD` as a pass, so a treated run whose skill delivery was never confirmed is recorded and counted as a valid datum — the manifest header asserts enforcement the guard does not provide, and the experiment's selection-rate denominator can include rows whose delivery never held.
  blocking:
    - reason: The treated-arm skill read-back guard (line 274) admits `UNREAD` as a pass, and `check_common` (lines 260–263) admits `UNREAD` for both agentHash and instructionsHash on both arms. After `read_back` exhausts its 3×10s curl + 3s sleep budget (~39s), it returns the literal "UNREAD UNREAD UNREAD" (line 219), which every downstream guard then accepts.
      wrong_action: A reader looking at the manifest's `skill_hash=UNREAD` rows cannot tell whether (a) the skill was delivered but the API was unavailable, or (b) the skill never arrived — the two cases are indistinguishable in the manifest, and the script never states which downstream analysis should apply. Two competent reviewers will therefore compute different selection-rate denominators from the same file: one excludes UNREAD rows, the other counts them as delivered. The script's own documented exit code 8 ("treatment undelivered") is therefore unreachable for the failure mode it names.
      anchor: "[[ \"$LAST_SKILL\" == \"sha256:$EXPECT_SKILLS_HASH\" || \"$LAST_SKILL\" == \"UNREAD\" ]] \\\n    || abort_batch \"treated $s read back skillsHash=$LAST_SKILL, registered sha256:$EXPECT_SKILLS_HASH: the skill did not arrive.\""
      evidence: evidence/b06/run-b6-batch.sh:274
    - reason: The manifest header (line 197) asserts "treated runs must read back skillsHash sha256:$EXPECT_SKILLS_HASH" as if enforced, but the enforcement path admits `UNREAD` — the header overstates what the guard does, and the script names no rule for how the downstream analysis must classify a row whose delivery was unobserved.
      wrong_action: A reader who reads only the header believes per-run delivery is verified; a reader who reads `check_common` sees it is not. Without a stated rule for `UNREAD` rows, any score derived from this manifest is built on an assumption the artifact does not authorize.
      anchor: "# treated runs must read back skillsHash sha256:$EXPECT_SKILLS_HASH (the skills SUBTREE hash, not the file's)"
      evidence: evidence/b06/run-b6-batch.sh:197
  non_blocking:
    - reason: `events_bytes` is computed and recorded three times (start, abort, end) into `window.txt`, but the three values are never compared — a second observer writing to `events.jsonl` between guard and pair 05 contaminates the durations and the downstream event stream without any in-batch detection.
      evidence: evidence/b06/run-b6-batch.sh:191,209,253,288
    - reason: The `busy` check at line 163 only echoes a warning to stderr; a stray `run-agent.sh` started after the guard passes is not refused, and the warning is not captured in the manifest or `window.txt` for downstream visibility.
      evidence: evidence/b06/run-b6-batch.sh:163-165
    - reason: `skact` is measured with `grep -acE '"(name|tool_name)":"Skill"'` against the make log — `grep -c` counts matching lines, not occurrences, so a single log line containing a JSON array of multiple tool calls is undercounted. The structured source (`events.jsonl`) exists and could be re-counted downstream, but the manifest's `skill_stream` column is therefore not authoritative.
      evidence: evidence/b06/run-b6-batch.sh:232
    - reason: The explicit `[[ $LAST_RC -eq 9 ]]` exit-9 check is applied only to the treated arm (line 272); the control arm has no equivalent, so a control that returns 9 (delivered tool schema mismatch — the E-005 contamination mode) is allowed to continue. The delegation guard (`LAST_DELEG == 0`) catches the more common form of the same contamination earlier, so this is a narrow gap rather than a structural one.
      evidence: evidence/b06/run-b6-batch.sh:272,279-280
  disputed:
    - finding: The cross-cutting claim that "two competent reviewers could classify the same manifest differently" applies symmetrically to all UNREAD admissions and is best understood as one finding, not three.
      why: The line-level pass frames the treated-arm skill check, the `check_common` UNREAD admission, and the manifest-header overstatement as three separate findings. They share the same root (UNREAD admitted as a pass) and the same reader consequence (manifest rows whose status is ambiguous). Listing them separately risks a fix that closes one path while leaving the others open; the gate records them as one blocking reason with three anchors.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 36s |
| ollama-cloud/deepseek-v4-pro | ok | 72s |

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
| evidence/b06/run-b6-batch.sh | 1/2 | L2 |
| Cross-cutting | 1/2 | L2 |
| Guards (lines 119–170) | 1/2 | L2 |
| Manifest header / window (lines 190–209) | 1/2 | L3 |
| read_back (lines 211–220) | 1/2 | L2 |
| one_run (lines 222–247) | 1/2 | L3 |
| check_common (lines 258–266) | 1/2 | L2 |
| Main loop (lines 268–290) | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### evidence/b06/run-b6-batch.sh
**Verdict:** finding
**Failure:** A treated run completes while `/api/runs/<rid>` is unavailable for all three read-back attempts. `read_back` returns `UNREAD UNREAD UNREAD`, and every delivery check explicitly accepts `UNREAD`, so the batch records and retains a run whose agent, skill, and instruction delivery were never verified. A contaminated control can pass the same way. Separately, if a control run returns exit 9 with otherwise acceptable read-backs, only the treated arm has a `LAST_RC -eq 9` check; the control is allowed to continue despite the declared exit-9 failure condition. Two competent reviewers could therefore classify the same manifest differently: one as valid because the script completed, another as invalid because delivery was unobserved or the control returned 9.
**Layer of the implied fix:** L2
**Anchor:** [[ "$LAST_SKILL" == "sha256:$EXPECT_SKILLS_HASH" || "$LAST_SKILL" == "UNREAD" ]] \
    || abort_batch "treated $s read back skillsHash=$LAST_SKILL, registered sha256:$EXPECT_SKILLS_HASH: the skill did not arrive."
...
one_run control "$s" "${ARM_C[@]}"
check_common control "$s"

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is present, so none duplicates a pass/fail gate. Reviewers would diverge most on the run-validity behavior around `UNREAD`: one may treat the explicit allowance as a deliberate tolerance, while another rejects every affected run as unverifiable—a full valid/invalid classification difference. The artifact needed to state and enforce whether exhausted read-back attempts invalidate a run, and it needed to apply the documented exit-9 condition to both arms.
**Layer of the implied fix:** L2
**Anchor:** Exit 0 batch complete · 4 another batch holds the lock · 8 treatment undelivered, control
#        contaminated, or an arm delegated · 9 the runner reported an undelivered declared tool
#        set · 1 a guard refused before any run was made.


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### Header / design notes (lines 1–40)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The design notes are the strongest part of the artifact: they disclose the carrier choice (note b), the activation-as-outcome decision (note c), and the delegation symmetry (note d) explicitly. Note (c) is the one place a divergence could hide — "a treated run with a delivered skill and zero activations is a REAL DATUM" — but that is a deliberate, stated decision, not an ambiguity. The ambiguity it creates surfaces later, in `check_common`, and is reported there.

### Setup and environment (lines 41–94)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The `EXPECT_SKILL_SHA` (file) vs `EXPECT_SKILLS_HASH` (subtree read-back) distinction is correctly separated and the earlier abort is documented in place (lines 70–83). The `case "$BENCHMARK"` dispatch is exhaustive with a default that exits 1.

### acquire_lock / release_lock (lines 96–116)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`noclobber` + `kill -0` stale detection is sound. The one soft spot — a reused pid from an unrelated process would falsely refuse — is a theoretical failure with no concrete scenario that two reviewers would handle differently, so it is not a finding.

### Guards (lines 119–170)
**Verdict:** finding
**Failure:** The `busy` check at line 163 only echoes a warning and never aborts. Concrete scenario: a second observatory run (or any `run-agent.sh` process) starts after the guard passes but before pair 05, writing to the shared `events.jsonl`. The batch's duration measurements for pairs 05–10 are contaminated, and the only record of it is a line on stderr that nothing downstream reads. Two reviewers diverge: one treats the warning as sufficient disclosure, the other expects the batch to refuse or at least gate the affected pairs. The byte counts that *would* prove contamination are collected (see `events_bytes`) but never compared.
**Layer of the implied fix:** L2 — the fix is a check that executes and aborts (or flags pairs) when `events.jsonl` grows mid-batch; the current state is L3 (a warning a human must notice).
**Anchor:** `[[ -z "$busy" ]] || echo "run-b6-batch: WARNING - other work is live; durations may be contaminated:"`

### ARM definitions (lines 172–188)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Manifest header / window (lines 190–209)
**Verdict:** finding
**Failure:** `events_bytes` is computed and written to `window.txt` at start, abort, and end, but the three values are never compared by anything. The manifest header (line 197) asserts "treated runs must read back skillsHash sha256:…" as if it were enforced, but the enforcement path admits `UNREAD` (see `check_common`). A reviewer reading the header believes delivery is verified per run; a reviewer reading `check_common` sees it is not. The header is the only place the read-back requirement is stated, and it overstates what the guard does.
**Layer of the implied fix:** L3 — the header is prose; nothing executes the "must read back" claim.
**Anchor:** `# treated runs must read back skillsHash sha256:$EXPECT_SKILLS_HASH (the skills SUBTREE hash, not the file's)`

### read_back (lines 211–220)
**Verdict:** finding
**Failure:** After three retries with a 3s sleep (9s total), `read_back` returns the literal string `UNREAD UNREAD UNREAD`. A run whose record is persisted more than 9s after completion — or whose API endpoint is briefly down — reads back `UNREAD` and is then *admitted as a pass* by every downstream guard (see `check_common`). Concrete scenario: the observatory API stalls for 10s on pair 03; the treated run's skill delivery is never verified, yet the batch records it as a valid treated datum with `skill_hash=UNREAD` in the manifest and continues. The run is indistinguishable, in the manifest, from a run where delivery genuinely failed — and the batch's own comment (lines 80–82) concedes this guard is "structurally invisible" to the guards-only fixture set.
**Layer of the implied fix:** L2 — the fix is for the guard to reject `UNREAD` (execute and abort) rather than admit it; the current state is L3 (a comment acknowledging the gap, nothing enforcing it).
**Anchor:** `echo "UNREAD UNREAD UNREAD"`

### one_run (lines 222–247)
**Verdict:** finding
**Failure:** `deleg` and `skact` are measured with `grep -acE '"(name|tool_name)":"(Task|Agent)"'` and `'"(name|tool_name)":"Skill"'` against the make log. `grep -c` counts matching *lines*, not occurrences, and the pattern matches any JSON field named `name`/`tool_name` with those values — not necessarily a tool-call event. Concrete scenario: the log emits a single line containing a JSON array of two tool calls, `[{"name":"Skill"},{"name":"Skill"}]`; `skact` records 1, not 2. Since `skact` is the experiment's dependent variable (selection rate, written to `skill-selection.txt`), an undercount here directly distorts the headline measurement. Two reviewers diverge on whether the count is trustworthy enough to feed the selection-rate analysis.
**Layer of the implied fix:** L3 — the count is a heuristic; nothing validates it against the structured `events.jsonl` that already exists.
**Anchor:** `skact="$(grep -acE '"(name|tool_name)":"Skill"' "$log" 2>/dev/null)"; skact="${skact:-0}"`

### abort_batch (lines 249–256)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### check_common (lines 258–266)
**Verdict:** finding
**Failure:** Every guard here admits `UNREAD` as a pass: `[[ "$LAST_AGENT" == "sha256:$EXPECT_AGENT_SHA" || "$LAST_AGENT" == "UNREAD" ]]`, and the same for `LAST_INSTR`. This is the same defect the script itself names at line 75 — "a control reporting success over a scope smaller than it claims" — now present in its own read-back guards. Concrete scenario: the API returns no `customization` block for a treated run (endpoint down, record not yet written), so `read_back` yields `UNREAD`; the guard passes, the run is recorded as a valid treated datum, and the batch continues. A treated run whose skill silently failed to deliver is scored as delivered. Two reviewers diverge: one reads `UNREAD` as "exclude this row from analysis," the other as "the guard passed, so delivery held." The manifest header never states which.
**Layer of the implied fix:** L2 — the fix is to reject `UNREAD` (execute and abort); the current state is L3.
**Anchor:** `[[ "$LAST_AGENT" == "sha256:$EXPECT_AGENT_SHA" || "$LAST_AGENT" == "UNREAD" ]]`

### Main loop (lines 268–290)
**Verdict:** finding
**Failure:** The treated-arm skill check at line 274 repeats the same admission: `[[ "$LAST_SKILL" == "sha256:$EXPECT_SKILLS_HASH" || "$LAST_SKILL" == "UNREAD" ]]`. This is the same defect as `check_common`, but it is the one that gates the *treatment* — the single variable the whole experiment exists to measure. A treated run with `UNREAD` skill hash is recorded and counted toward the pair total, so the delivery rate (and therefore the selection rate's denominator) is computed over runs whose delivery was never confirmed. This is the most consequential instance of the `UNREAD` admission because it sits on the treatment arm.
**Layer of the implied fix:** L2 — reject `UNREAD` on the treated arm; current state L3.
**Anchor:** `[[ "$LAST_SKILL" == "sha256:$EXPECT_SKILLS_HASH" || "$LAST_SKILL" == "UNREAD" ]]`

### Cross-cutting
- **Duplicate pass/fail gate:** The carrier's arrival is guarded twice — once as a file sha in the guards block (line 137, `ta == EXPECT_AGENT_SHA`) and once as a read-back in `check_common` (line 260, `LAST_AGENT == sha256:…`). These are different quantities (file on disk vs runtime read-back), so they are not a true duplicate, but the read-back half is the one that admits `UNREAD`, which is exactly the half that matters for "did the carrier actually arrive at the runtime."
- **Divergence:** `check_common` / the treated-arm skill check. Two reviewers would diverge on whether a `UNREAD` row in the manifest is a pass or a failed delivery, and by how much — one would exclude the row, the other would count it as delivered. This is the single largest source of disagreement because it changes the experiment's denominator.
- **What it did not say:** The script never states what downstream analysis must do with `UNREAD` rows in the manifest — exclude them, treat them as failed delivery, or re-run them. Given that `UNREAD` is admitted by design (not aborted), the manifest is the only place the distinction between "delivered, not selected" and "delivery unverified" could be recovered, and the script leaves that recovery unspecified.
