# opencode review — READINESS

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/deepseek-v4-pro          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - ollama-cloud/deepseek-v4-pro
    - ollama-cloud/gpt-oss:120b
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.21
reviewed_utc:    20260828T174521Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: phases/b02-plain-baseline/READINESS.md
    sha:  8d17789bbe70
    dirty: true
lab_head:        d377c7f
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Off-contract output — ollama-cloud/gpt-oss:120b


> lab-critic · gpt-oss:120b

### # B2 readiness — what is true before the first run, 2026-08-28
**Verdict:** no finding  
**Failure:** n/a – the heading is purely descriptive.  
**Layer of the implied fix:** n/a  
**Anchor:** n/a  

### ## Part 1 — What is already true
**Verdict:** no finding  
**Failure:** n/a – the table lists preconditions that have been manually checked; no contradictory evidence is shown.  
**Layer of the implied fix:** n/a  
**Anchor:** n/a  

### ## Part 2 — The observatory already holds 172 runs, and none of them can be used
**Verdict:** finding  
**Failure:** If an operator runs `codex-score.sh --run-id <old-id>` for a run that predates `--keep`, the script will attempt to locate the deleted worktree, fail to find it, and then exit with a non‑zero error (“worktree not found”), causing the scoring step to abort and the entire B2 batch to be incomplete.  
**Layer of the implied fix:** L2 – the `codex-score.sh` script already exits non‑zero when the worktree is missing; the failure is that the script is invoked without a guard that prevents such calls. Adding a pre‑run check (`if [ ! -d "$WORKTREE" ]; then exit 1; fi`) would reject the bad state.  
**Anchor:** Lines 47‑52 describe the missing worktrees and the refusal behaviour of `codex-score.sh`.

### ## Part 3 — The codex arm is not isolated, not pinned, and would record a model it never used
**Verdict:** finding  
**Failure:**  
1. Run B2 with `MODEL=gpt-5.6-sol`. The codex CLI silently ignores `--model` (as shown in lines 95‑98). The run record (`runtime.model`) will contain `gpt-5.6-sol`, while the actual model used by codex is whatever is set in `~/.codex/config.toml`. Downstream analysis that compares treatment vs control will attribute a model change that never happened, corrupting the experimental comparison.  
2. The same run will also record `--isolate-user-settings=true` (line 108) even though the flag is never read by the codex branch (lines 87‑90). The run record will claim isolation while the actual execution used the user’s global configuration, again falsifying provenance.  
**Layer of the implied fix:** L1 – the bad state (incorrect provenance fields) is currently writable; nothing prevents a run from recording a false model or isolation flag. The only way to make the bad state unrepresentable is to change the codex arm implementation to *actually* pass the model flag and honour the isolation flag, or to discard those fields when they are not applied.  
**Anchor:** Lines 95‑108 detail the silent drop of `--model` and the ineffective isolation flag.

### ## Part 4 — The Copilot arm may not need to wait
**Verdict:** finding  
**Failure:** An operator assumes that `gpt-5.4-mini` does not consume premium quota (lines 192‑194) without running an explicit verification command. If the quota‑remaining metric were to change (e.g., due to a hidden premium‑charged request), the Copilot arm would silently exhaust premium quota, causing subsequent runs to fail with `403` errors. Because no automated test validates the quota before the batch, the failure would be discovered only after a run crashes.  
**Layer of the implied fix:** L3 – the artifact only *states* the claim; there is no script or validator that checks the quota before proceeding. Adding a pre‑run script that calls `gh api /copilot_internal/user` and verifies `quota_remaining` stays the same would enforce the claim.  
**Anchor:** Lines 186‑199 outline the claim and the suggested manual check.

### ## Part 5 — The preconditions the runbook names that are NOT met
**Verdict:** finding  
**Failure:** The runbook requires `0A` to be complete and `B1` to be closed before B2 starts (lines 208‑210). No automated gate or CI step enforces these prerequisites; a developer could invoke `make run-benchmark` while those conditions are false, leading to runs that are later deemed invalid because the experimental context is incomplete.  
**Layer of the implied fix:** L3 – the statement is declarative only; a pre‑run guard script that aborts if `0A` or `B1` status files are not present would raise the control level.  
**Anchor:** Lines 208‑213 present the unmet preconditions.

### ## Part 6 — What must be true before the five‑run batch, in order
**Verdict:** finding  
**Failure:** Item 2 requires that `runtime.model` in the run record truly reflect the model passed to the runtime. No test verifies this invariant; a run could again record a mismatched model (as in Part 3) and the batch would proceed, contaminating the experimental data without detection.  
**Layer of the implied fix:** L3 – the requirement is listed but not enforced. Implementing a post‑run validation that compares the `runtime.model` field against the actual model used (e.g., by parsing the CLI’s verbose output) would raise the control level.  
**Anchor:** Lines 232‑237 enumerate the required truths; line 235 highlights the provenance issue.

### ## Part 7 — Known, and deliberately not fixed here
**Verdict:** finding  
**Failure:** The `make baseline-runs` target swallows failures by appending `|| true` to the run loop (lines 247‑250). If any of the five runs crashes, the Make target still exits with status 0, causing downstream scripts to believe the batch succeeded and to proceed to comparison steps with incomplete data. This masks real failures and can produce misleading baseline numbers.  
**Layer of the implied fix:** L2 – the script should **not** ignore the exit status; removing `|| true` (or explicitly checking the exit code after each iteration) would cause the Make process to exit non‑zero on a failed run, preventing silent continuation.  
**Anchor:** Lines 247‑250 describe the swallowing of failures.

---

### Cross-cutting
- **Duplicate scoring gate:** The “Path B gate works” entry in Part 1 (line 28) overlaps with the explicit `check-run-gate.sh` validation described in Part 2. Both attest to the same gate outcome (accept on exit 0, refuse on `F13`).  
- **Most divergent reviewers:** Reviewers are likely to disagree most on Part 5 (unmet preconditions). One reviewer may deem the lack of automated enforcement a critical defect (L2), while another may label it a mere documentation issue (L3). The divergence could be on the order of **one severity level**.  
- **Missing requirement:** The artifact never states that the `CODEX_HOME` environment variable must be cleared or redirected to an empty directory when `--ignore-user-config` is used. Without this, the codex arm can still load `~/.codex/AGENTS.md`, compromising the L1 guarantee of isolation. This omission leaves the isolation control under‑specified.
## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

acceptance:
  artifact: phases/b02-plain-baseline/READINESS.md
  verdict: ACCEPT
  summary: The artifact is evidence-cited throughout and names its own open questions (AGENTS.md unverified, Copilot quota unmeasured, 0A/B1 unfinished) with decisions recorded against each; the line-level findings either misread the table structure or describe gaps the artifact already acknowledges as partial.
  blocking: []
  non_blocking:
    - reason: §3.4's CODEX_ARGS block has 7 flags where §3.3 listed 9 as "needed for parity"; -o/--output-last-message and --ephemeral are silently absent. §3.4 frames itself as partial ("What it does not fix" on AGENTS.md), but the two unmentioned flags could mislead a reader applying §3.4 verbatim and expecting full parity. Consequence of missing -o is already acknowledged in Part 7 (telemetry gap); consequence of missing --ephemeral cannot be named without knowing where codex writes sessions by default, which the artifact does not state.
      evidence: phases/b02-plain-baseline/READINESS.md:142-180
    - reason: Part 5 says "run the harness rehearsal now, on one run" without naming the arm, in tension with Part 6 item 1 (codex parity must come first). Part 6's explicit ordering resolves the ambiguity for any reader following it.
      evidence: phases/b02-plain-baseline/READINESS.md:222-227
  disputed:
    - finding: Part 1's "Stack | up and healthy" is overstated because the curl only checks the API; under one reading, Tempo/Grafana/UI are unverified.
      why: The table separates "Stack" (sample-service, curl-checked → API health response) from "Ports" (observatory services, listed without a health claim). "Stack up and healthy" maps to the sample-service; the observatory lives in the Ports row and makes no health claim. The line-level finding conflates the two rows; under the table's own structure the claim is consistent with its evidence.
    - finding: Part 3 — without --ephemeral, codex session files contaminate the --keep worktree inspection that Part 6 item 3 requires.
      why: The artifact says --ephemeral is for "no session files on disk" but does not state where codex writes sessions by default. The line-level finding assumes worktree contamination without substantiating it; the artifact doesn't claim it either. Codex's documented session path is $CODEX_HOME/sessions/, not the worktree.
    - finding: Part 4 simultaneously asserts "0-premium model" as fact and as unverified, creating contradictory readings that could let one reviewer green-light a three-armed run.
      why: The artifact says "If that holds" and "Do not take this section as settled — it contradicts a written deferral, and the only thing that should overturn a written decision here is a measurement." The uncertainty is named explicitly with the required test (a copilot run + gh api quota check) stated. A reader following the artifact treats the claim as awaiting measurement, not as established.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/deepseek-v4-pro | ok | 64s |
| ollama-cloud/gpt-oss:120b | OFF CONTRACT | 41s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Part 1 — What is already true | 1/1 | L2 |
| Part 3 — The codex arm is not isolated, not pinned, and would record a model it never used | 1/1 | L2 |
| Part 4 — The Copilot arm may not need to wait | 1/1 | L3 |
| Part 5 — The preconditions the runbook names that are NOT met | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### Part 1 — What is already true
**Verdict:** finding
**Failure:** The "Stack" row claims `up and healthy` but the check only curls the API health endpoint (`localhost:8081/actuator/health`). The "Ports" row lists four services — API 8081, UI 5174, Tempo 3200, Grafana 3001 — checked via `make urls`, which prints URLs rather than probing health. Two reviewers read "Stack up and healthy" differently: one as "the sample-service API is up", the other as "all four observatory services are up". Under the second reading the claim is unverified for three of four services. An operator who trusts the row proceeds to a run, and if Tempo (3200) is down the run completes but its traces are silently lost — discovered only after the run is spent.
**Layer of the implied fix:** L2
**Anchor:** `| Stack | up and healthy | `curl localhost:8081/actuator/health` → `{"status":"UP"}` |`

### Part 2 — The observatory already holds 172 runs, and none of them can be used
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Part 3 — The codex arm is not isolated, not pinned, and would record a model it never used
**Verdict:** finding
**Failure:** §3.3 lists nine flags as "needed" for parity, but the §3.4 proposed change uses only seven. `-o, --output-last-message` (the `$AGENT_LOG` analogue) and `--ephemeral` (no session files on disk) are omitted. Someone applying the §3.4 block verbatim believes parity is achieved; it is not. Without `--ephemeral`, session files land on disk and contaminate the `--keep` worktree inspection that Part 6 item 3 says must show "the changed files and their pre-agent versions — not all 25 files". Without `-o`, the codex arm still has no `$AGENT_LOG` equivalent, so the observability gap Part 7 flags is not actually closed by the change that claims to close it.
**Layer of the implied fix:** L2
**Anchor:** `CODEX_ARGS=(--sandbox workspace-write --approve-for-me --color never --json)`

### Part 4 — The Copilot arm may not need to wait
**Verdict:** finding
**Failure:** The numbered list asserts as fact that "`gpt-5.4-mini` is a 0-premium model on this account", and uses the existence of the 11 runs as evidence ("which is why those 11 runs exist at all"). Two paragraphs later the same section says the claim "needs one cheap check before it is believed" and "Do not take this section as settled". The premise is simultaneously a recorded fact and an unverified assumption. Two reviewers diverge: one treats the 0-premium claim as established and green-lights the three-armed run; the other treats it as pending measurement and blocks. The section is trying to overturn a written deferral, so this ambiguity decides whether a decision gets overturned on an unmeasured premise.
**Layer of the implied fix:** L3
**Anchor:** `gpt-5.4-mini is a 0-premium model on this account, and `chat`/`completions` remain unlimited — which is why those 11 runs exist at all.`

### Part 5 — The preconditions the runbook names that are NOT met
**Verdict:** finding
**Failure:** The third option says "run the harness rehearsal now, on one run" without naming the arm, while Part 6 orders parity (item 1) *before* the rehearsal (item 3). If a reader takes "now" literally and runs the rehearsal on the codex arm, that produces a codex run before parity — directly violating §3.4's own warning "Change it before the first codex run or accept it forever." The rehearsal run would then be a contaminated codex run on record, not comparable to post-fix runs, and the "cost is currently zero" window is spent. Two reviewers order the work differently: one rehearses on claude only (safe), the other rehearses on codex (contaminates the baseline).
**Layer of the implied fix:** L3
**Anchor:** `run the harness rehearsal now, on one run, and hold the five-run batch until the two arms are at parity.`

### Part 6 — What must be true before the five-run batch, in order
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Part 7 — Known, and deliberately not fixed here
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Name both. — Not applicable. This is a readiness document, not a rubric; it contains no scoring categories. The nearest analogue is that Part 1's "Path B gate works" row restates a gate, but it is a precondition check, not a scored category.
- Which single section would you expect two reviewers to diverge on most, and by how much? — Part 4. It is the only section that argues for overturning a written decision, and its load-bearing premise ("0-premium model") is asserted as fact in one sentence and flagged as unmeasured in the next. Divergence is binary and consequential: green-light vs. block the three-armed run, a difference of one full arm in the baseline.
- What did the artifact not say that it needed to say? — It never names which arm the Part 5 rehearsal runs on, and it never states whether the §3.4 proposed change is intended to be exhaustive of the §3.3 flag table (it is not, and the gap is silent). Both omissions are exactly the kind of thing a later reader fills in differently.
