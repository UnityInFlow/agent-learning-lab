# opencode review — run-mcp-hole-probe

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/glm-5.2          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260925T191443Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p06a/run-mcp-hole-probe.sh
    sha:  6dc1fbc7eca1
    dirty: false
lab_head:        073da3f
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/p06a/run-mcp-hole-probe.sh
  verdict: REJECT
  summary: The script's header exit-code contract omits code 1 (used at line 114), and guard 3 cannot detect drift between arm B and the runner — both undermine claims the artifact itself stakes its experiment on.
  blocking:
    - reason: Exit code 1 is undocumented in the header's exit-code list (lines 15-25) but used at line 114 (`die 1 "cannot create evidence or work directory"`). The header explicitly establishes a contract: "every one of them provoked by a fixture" — and code 1 falls outside the documented set entirely.
      wrong_action: A reader case-dispatching on the registered codes (0,2,3,4,5,6,7,8) sees exit 1 from a real run, falls through to a catch-all, and treats "could not create evidence or work directory" as an unknown infrastructure failure rather than a known outcome — discarding or misclassifying evidence the artifact's own contract says it should handle.
      anchor: "#   0  batch completed at its registered n"
      evidence: evidence/p06a/run-mcp-hole-probe.sh:15-25,114
    - reason: Guard 3 is a presence check on 6 specific lines in a heredoc, not an equivalence check between arm B's hand-built reconstruction and the runner's actual flag block. If the runner adds any other flag outside those 6 lines, guard 3 still passes but arm B silently drifts from the harness.
      wrong_action: A reader sees guard 3 pass and trusts arm B as the "harness as-is" reference. After any runner change outside the 6 heredoc lines (e.g., a new `--mcp-config`), the recorded arm B no longer represents what the harness actually does — the experiment answers a different question than its header claims, and the reader has no signal that anything is off.
      anchor: "B  harness as-is     runner flags exactly as run-agent.sh runs them"
      evidence: evidence/p06a/run-mcp-hole-probe.sh:12,75-88
  non_blocking:
    - reason: The approval detector at line 189 uses substring matching for `can_use_tool`/`permission_request`/`permission_denial`. Under `--permission-mode acceptEdits`, `can_use_tool` events fire for every tool invocation as auto-approve notifications — not interactive prompts. The artifact's own F13 correction (lines 198-207) explicitly rejects substring detection in favor of structural checks, so this detector violates the standard the artifact set for itself. Operational risk is low because the prompt ("Reply with the single word READY and nothing else") and `--allowedTools` constraint make tool invocations unlikely.
      evidence: evidence/p06a/run-mcp-hole-probe.sh:189,198-207
    - reason: If the stream contains more than one init record (unlikely in `-p` mode but not guarded), the jq at lines 174-186 would emit multi-line values for `server_present`/`server_status`, embedding newlines inside a TSV field and splitting one logical row across two physical rows in RESULT.tsv.
      evidence: evidence/p06a/run-mcp-hole-probe.sh:174-186
    - reason: The artifact never explains why `run_one` reconstructs the runner's flags rather than calling `$RUNNER` directly. Without that note, a reader cannot tell whether the reconstruction is deliberate (to isolate the independent variable per arm) or an oversight — which is what makes the guard 3 finding ambiguous rather than unambiguous.
      evidence: evidence/p06a/run-mcp-hole-probe.sh:12,139-156
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 115s |
| ollama-cloud/glm-5.2 | ok | 291s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Header comment block (purpose, arms, exit codes) | 1/1 | L3 |
| guard 3: the runner's flag block is still the one E-021 copied | 1/1 | L2 |
| run_one | 1/1 | L2 |
| Stop 18 / Lab 6.5 — the print-mode MCP hole. Driver for E-021. | 1/1 | L2 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Header comment block (purpose, arms, exit codes)
**Verdict:** finding
**Failure:** Exit code 1 is used at line 114 (`die 1 "cannot create evidence or work directory"`) and line 169 (subshell `exit 1` on `cd` failure), but the documented exit-code list at lines 15-25 enumerates only 0, 2, 3, 4, 5, 6, 7, 8. A wrapper or verify harness that case-dispatches on the registered codes will fall through to a catch-all branch on 1, treating a directory-creation failure as an unregistered infrastructure error rather than a known outcome. The header also claims "every one of them provoked by a fixture in verify-mcp-hole-probe-guards.sh" — exit 1 has no fixture, so the claim is false for that code.
**Layer of the implied fix:** L3
**Anchor:** `#   0  batch completed at its registered n` through `#   8  the budget ceiling was reached; the population that occurred is reported`

### Configuration variables
**Verdict:** no finding

### guard 1: the claude binary and its version
**Verdict:** no finding

### guard 2: the probe server exists and answers the handshake
**Verdict:** no finding

### guard 3: the runner's flag block is still the one E-021 copied
**Verdict:** finding
**Failure:** The guard checks that six specific lines are *present* in `$RUNNER` via `grep -qF`, but the script never *calls* `$RUNNER` — `run_one` constructs its own `args` array and invokes `$CLAUDE_BIN` directly. Arm B is described as "runner flags exactly as run-agent.sh runs them," but it is a reconstruction, not a delegation. The guard cannot detect a *new* flag added to the runner (e.g., `--mcp-config /some/path` or `--dangerously-skip-permissions`), because `grep -qF` only checks for the presence of the six known lines, not the absence of others. Scenario: the runner adds `--mcp-config /etc/claude/mcp.json` tomorrow. Guard 3 passes (all six lines still present). Arm B does not include `--mcp-config`, so arm B no longer matches the runner. The experiment reports "no hole" for arm B, but the real runner would have loaded a different MCP config and possibly shown the tool. Two reviewers would disagree on whether arm B still represents the harness.
**Layer of the implied fix:** L2
**Anchor:** `# --- guard 3: the runner's flag block is still the one E-021 copied ---------`

### guard 4: no .mcp.json is ever written inside a tracked tree
**Verdict:** no finding

### guard 5: one probe at a time
**Verdict:** no finding

### guard 6: every requested arm is one we defined
**Verdict:** no finding

### Setup (directories, copies, hashes, RESULT.tsv header)
**Verdict:** no finding

### run_one
**Verdict:** finding
**Failure:** The `approval` detector at line 189 is a fixed-string grep for specific event names (`can_use_tool`, `permission_request`, `permission_denial`) and English prompt fragments (`approve this MCP`, `Do you want to (use|allow)`). If Claude's stream-json emits an MCP-specific permission event under a different key — e.g. `"type":"mcp_tool_approval"` or `"subtype":"mcp_permission"` — the grep returns no match and `approval` is recorded as `no`, falsely confirming Prediction 4. The F13 detector was corrected for exactly this class of mistake (substring vs structural), but the approval detector was not. A reviewer who trusts the `approval=no` column as evidence that no permission prompt occurred would be wrong if the event type name changed.
**Layer of the implied fix:** L2
**Anchor:** `if grep -qE '"(can_use_tool|permission_request|permission_denial)"|approve this MCP|Do you want to (use|allow)' "$stream"; then`

### Main loop (budget ceiling and arm iteration)
**Verdict:** no finding

### Final reporting and exit
**Verdict:** no finding

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? The `tool_present` column (line 184) records whether the probe tool appeared in the init stream — this is the experiment's dependent variable, not a gate. The F13 and `result-is-error` notes (lines 208-214) classify runs into populations (population vs exclusion), which functions as a post-hoc gate on what gets counted. No duplication between a pre-run guard and a scoring category.
- Which single section would two reviewers diverge on most, and by how much? Guard 3. One reviewer reads "the runner's flag block is still the one E-021 copied" as a drift detector sufficient for the experiment; another reads arm B's header description ("runner flags exactly as run-agent.sh runs them") as a fidelity claim that a presence-only grep cannot uphold. The gap is one full grade — sound vs finding — because the guard's name promises equivalence but its mechanism delivers subset matching.
- What did the artifact not say that it needed to say? It never states why `run_one` reconstructs the runner's flags instead of calling the runner. The header describes arm B as "harness as-is," but the implementation is a hand-built arg list. A reader cannot tell whether this is deliberate (to control the independent variable per arm) or an oversight (the runner was supposed to be called and wasn't). That gap is what makes the guard 3 finding ambiguous rather than clear-cut.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Stop 18 / Lab 6.5 — the print-mode MCP hole. Driver for E-021.
**Verdict:** finding
**Failure:** The header lists exit codes 0, 2, 3, 4, 5, 6, 7, 8 and states "every one of them provoked by a fixture in verify-mcp-hole-probe-guards.sh." Line 114 uses `die 1 "cannot create evidence or work directory"` — exit code 1 is not in the list and therefore cannot have a fixture. If `mkdir -p` fails (e.g. `PROBE_EVIDENCE` points to a read-only path, or `/tmp` is full), the script exits 1, a code no fixture tests and no reviewer checking the documented list would expect. Two reviewers would diverge on whether this is "an undocumented internal error" or "a gate with no proof" — the header's own standard ("a control that has never been shown to reject anything is indistinguishable from one that rejects nothing") makes it the latter.
**Layer of the implied fix:** L2
**Anchor:** `# Exit codes — every one of them provoked by a fixture in` / `# verify-mcp-hole-probe-guards.sh` … and line 114: `mkdir -p "$EVID" "$WORKDIR" || die 1 "cannot create evidence or work directory"`

### guard 1: the claude binary and its version
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### guard 2: the probe server exists and answers the handshake
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### guard 3: the runner's flag block is still the one E-021 copied
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### guard 4: no .mcp.json is ever written inside a tracked tree
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### guard 5: one probe at a time
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### guard 6: every requested arm is one we defined
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Setup: evidence/work directories, fixture copies, hashes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### run_one
**Verdict:** finding
**Failure:** The approval detector on line 189 greps the entire stream for `"can_use_tool"` among other patterns. In `--permission-mode acceptEdits`, Claude emits `can_use_tool` events for every tool invocation — these are auto-approved notifications, not interactive approval requests. If the model invokes any allowed tool (e.g. a stray `mvn` call), the stream carries `{"type":"can_use_tool",...}`, the grep fires, and `approval=yes` is written to RESULT.tsv. Two reviewers would disagree on whether a `can_use_tool` event in `acceptEdits` mode is an "approval event" — the artifact never defines the term. The prediction ("no approval/permission event anywhere in the stream") is ambiguous between "no interactive approval prompt" and "no permission-related JSON event of any kind." The grep does not distinguish these, and a false `approval=yes` on a run where no human was prompted would contaminate the column.
**Layer of the implied fix:** L2
**Anchor:** `if grep -qE '"(can_use_tool|permission_request|permission_denial)"|approve this MCP|Do you want to (use|allow)' "$stream"; then`

### Main loop and budget ceiling
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Final reporting
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. The `note` field (f13-candidate, result-is-error) records observations for downstream exclusion decisions but does not gate inside this script. The `approval` field is a prediction check, not a gate. No duplication.
- Which single section would two reviewers diverge on most, and by how much? `run_one`, by a full category — the approval grep's conflation of `can_use_tool` notifications with interactive approval events. One reviewer reads "approval event" as "a human was prompted"; the other reads it as "any permission-related JSON type appeared." The artifact supplies no definition, and the grep services both readings simultaneously.
- What did the artifact not say that it needed to say? Two things. (1) What "approval event" means — interactive prompt vs. any permission-typed JSON event. The grep covers both but the prediction's language covers only one. (2) What happens if the stream contains more than one init record. The jq on line 174 would emit multiple objects to `$init`; the jq on lines 185–186 would emit multiple values into `server_present`/`server_status`, embedding newlines inside a TSV field and splitting one logical row across two physical rows. In `-p` mode this is unlikely (single session, one init), but the script neither guards against it nor acknowledges the assumption.
