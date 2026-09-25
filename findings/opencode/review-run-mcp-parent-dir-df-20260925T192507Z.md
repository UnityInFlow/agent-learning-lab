# opencode review — run-mcp-parent-dir-df

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
reviewed_utc:    20260925T192507Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p06a/run-mcp-parent-dir-df.sh
    sha:  444d14187ab6
    dirty: false
lab_head:        073da3f
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/p06a/run-mcp-parent-dir-df.sh
  verdict: REJECT
  summary: The two guards at lines 97-98 verify the .mcp.json files but not the probe_server.py the parent's .mcp.json points at; under `set -uo pipefail` with no `-e`, a failed `cp` at line 87 silently leaves a planted-but-broken probe that records the predicted DF1/DF2 negative for the wrong reason — the experiment cannot distinguish "loader did not walk upward" from "loader walked upward but the server failed to start."
  blocking:
    - reason: Lines 97-98 guard .mcp.json placement but do not verify that the probe_server.py referenced by the parent's .mcp.json actually exists. The script's own comment at lines 94-96 says the guards exist because "a null is indistinguishable from a probe that was never planted" — but a planted probe pointing at a missing file is a different null, byte-for-byte indistinguishable from the predicted DF1/DF2 outcome the experiment is measuring. The handshake at lines 61-68 validated the fixture, not the copy; nothing checks the copy post-`cp`.
      wrong_action: A reader seeing DF1/DF2 confirmed (tool_present=no, server_present=no on 5/5) would conclude "the loader does not walk upward," when the loader could have walked upward, loaded the .mcp.json, attempted to start the server, failed because probe_server.py was missing, and recorded the same negative result. The conclusion about loader behavior is confounded by an unverified precondition the script's own framing claims to provide.
      anchor: "[[ -f \"$PARENT/.mcp.json\" ]] || die 10 \"parent directory has NO .mcp.json: $PARENT\""
      evidence: evidence/p06a/run-mcp-parent-dir-df.sh:87
  non_blocking:
    - reason: The header at lines 22-29 lists exit codes 0, 2, 3, 5, 6, 9, 10 with the contract "every one provoked by a fixture in verify-mcp-parent-dir-df.sh," but `die 1` is invoked at lines 86 and 91 for `mkdir -p` failures. Exit 1 has no entry in the list and the verifier is a separate file the artifact does not include — if it does carry a fixture for exit 1, the header is just missing the entry; if it does not, the contract claim is broken. The exit code in question is for infrastructure failure, not measurement, and the script records the full `claude --version` output to HASHES.txt at line 103 so a careful reader can verify the version extraction post-run.
      evidence: evidence/p06a/run-mcp-parent-dir-df.sh:86
    - reason: Line 147's jq expression `select(.type=="result") | .permission_denials | length` returns 0 when the field is absent (jq's `null | length` is 0), so the fallback at line 148 (`denials=na`) never fires. RESULT.tsv conflates "no permission denials" with "field absent from result message." The denials column is metadata for this arm, not a dependent variable, so the experiment's primary conclusion is unaffected.
      evidence: evidence/p06a/run-mcp-parent-dir-df.sh:147
  disputed:
    - finding: The line-level reviewer suggested line 53's `awk '{print $1}'` may extract "claude" instead of "2.1.282" if the binary prints `<name> <version>`, causing the version check to spuriously exit 2.
      why: The reviewer's own framing hedges ("Two reviewers would diverge on whether this works without actually running claude --version"). The artifact does not record the actual output format on disk for a static reader to inspect; the full output is logged to HASHES.txt at line 103 post-run, but I cannot substantiate the claim without running the binary.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 163s |
| ollama-cloud/glm-5.2 | ok | 115s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Header comment (lines 1-30) | 1/1 | L3 |
| Two guards (lines 94-98) | 1/1 | L2 |
| Run loop (lines 113-164) | 1/1 | L2 |
| Header comment block (lines 1-29) | 1/1 | L3 |
| Pre-flight validation (lines 52-68) | 1/1 | L2 |
| Directory setup (lines 83-92) | 1/1 | L2 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Header comment (lines 1-30)
**Verdict:** finding
**Failure:** Lines 86 and 91 call `die 1 "cannot create directories"`, but exit code 1 is absent from the registered list at lines 22-29 (0, 2, 3, 5, 6, 9, 10). The comment at line 22 states "Exit codes, every one provoked by a fixture in verify-mcp-parent-dir-df.sh." If `mkdir -p` fails — `/tmp` full, `$HERE` not writable — the script exits 1, a code no fixture covers. The verify harness's behavior on an unregistered code is unspecified by this artifact: it may pass, fail, or drop the result. Two reviewers diverge here: one reads "exit 1 is obviously a generic infrastructure failure, the harness handles it," the other reads "the contract says *every one* and this isn't listed, so the contract is broken."
**Layer of the implied fix:** L3
**Anchor:** `# Exit codes, every one provoked by a fixture in verify-mcp-parent-dir-df.sh:`

### Environment variables (lines 32-47)
**Verdict:** no finding

### Binary + version check (lines 52-55)
**Verdict:** no finding

### Fixture + handshake (lines 57-68)
**Verdict:** no finding

### Repo containment (lines 70-74)
**Verdict:** no finding

### Lock (lines 76-81)
**Verdict:** no finding

### Directory setup (lines 83-92)
**Verdict:** no finding

### Two guards (lines 94-98)
**Verdict:** finding
**Failure:** The guard at line 98 checks `[[ -f "$PARENT/.mcp.json" ]]` but not `[[ -f "$WORKDIR/probe_server.py" ]]`. The `.mcp.json` created at line 89 references `$WORKDIR/probe_server.py`, copied at line 87. The script runs under `set -uo pipefail` with no `-e`, so a failed `cp` is silent. If the copy fails, the guard passes, Claude finds `.mcp.json` in the parent (the loader *did* walk upward), tries to start the server, fails (file missing), and the result row records `server_present=no` / `tool_present=no` — byte-for-byte identical to the experiment's predicted negative result (DF2: "server ABSENT on 5 of 5"). The guard's own comment at lines 95-96 says it exists because "a null is indistinguishable from a probe that was never planted" — but this guard leaves a different null (server copy missing) indistinguishable from the negative result the experiment is measuring. The handshake at lines 61-68 validated the fixture, not the copy; nothing checks the copy post-`cp`.
**Layer of the implied fix:** L2
**Anchor:** `[[ -f "$PARENT/.mcp.json" ]] || die 10 "parent directory has NO .mcp.json: $PARENT"`

### Evidence header (lines 100-111)
**Verdict:** no finding

### Run loop (lines 113-164)
**Verdict:** finding
**Failure:** Line 147 extracts denials with `jq -r 'select(.type=="result") | .permission_denials | length'`. If the result message has no `permission_denials` field, jq evaluates `null | length`, which returns `0` — not an error, not empty. The fallback at line 148 (`[[ -n "$denials" ]] || denials=na`) never fires because jq always emits a number. So "field absent from Claude's output" and "zero permission denials" both write `0` to RESULT.tsv. A reader of the TSV cannot distinguish "the agent was never prompted to use a tool that could be denied" from "the agent was denied zero times." The column is metadata for this experiment (the dependent variables are `tool_present` / `server_present`), so the impact on the conclusion is low — but the evidence artifact is misleading on its face.
**Layer of the implied fix:** L2
**Anchor:** `denials="$(jq -r 'select(.type=="result") | .permission_denials | length' < "$stream" | tail -1)"`

### Finalize (lines 166-168)
**Verdict:** no finding

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? N/A — this is a probe driver, not a rubric.
- Which single section would two reviewers diverge on most? The "Two guards" section, by a wide margin. One reviewer reads the guard comment ("Without them a null is indistinguishable from a probe that was never planted") and concludes the guards are sufficient because the handshake already validated the fixture and `cp` of a validated file to a fresh `/tmp` path is reliable. The other reads the same comment and concludes the guard closes one null-shape while leaving open another that is indistinguishable from the experiment's predicted negative result — which is the exact failure shape the comment claims to prevent. The disagreement is about whether the handshake-to-copy chain is reliable enough to trust without a post-copy guard, and reasonable reviewers split on that.
- What did the artifact not say that it needed to say? Two things. (1) What the verify harness does with an exit code it has no fixture for — the artifact claims every exit code is fixture-provoked but produces one that isn't. (2) Whether a `server_present=no` / `tool_present=no` row is ever reclassified as infrastructure failure rather than a measurement — the `note` column has values `ok`, `no-init`, `f13-candidate`, and `dry-run`, but no value for "server file missing after copy," so a false negative from a failed `cp` would be recorded as `ok` with `server_present=no`, indistinguishable from a true negative.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Header comment block (lines 1-29)
**Verdict:** finding
**Failure:** The header lists exit codes 0, 2, 3, 5, 6, 9, 10 and states "every one provoked by a fixture in verify-mcp-parent-dir-df.sh." But `die 1` is called at lines 86 and 91 (`mkdir -p ... || die 1 "cannot create directories"`). Exit 1 is neither listed in the header nor, by the header's own claim, fixture-tested. A reviewer reading the header to decide which exit codes the verifier covers would conclude exit 1 is impossible — and a reviewer reading the body would see it is not. If `mkdir` fails (e.g. `/tmp` is read-only in a sandboxed CI run), the script exits 1, the verifier has no fixture for it, and the failure is misclassified as an unregistered crash rather than a known guard.
**Layer of the implied fix:** L3
**Anchor:** `# Exit codes, every one provoked by a fixture in verify-mcp-parent-dir-df.sh:` followed by a list that omits 1, while the body uses `die 1` at lines 86 and 91.

### Configuration block (lines 30-47)
**Verdict:** no finding

### Pre-flight validation (lines 52-68)
**Verdict:** finding
**Failure:** The version check at line 53 does `awk '{print $1}'` on the output of `claude --version`. If the binary prints `claude 2.1.282` (binary name first, as many CLIs do), `$1` is `claude`, the comparison fails, and the script exits 2 — rejecting a correct binary. Two reviewers would diverge on whether this works without actually running `claude --version` and inspecting its output format, which the script does not record. The handshake check (lines 61-68) is sound — it tests both spacing variants of the JSON key and exits 3 on failure.
**Layer of the implied fix:** L2
**Anchor:** `GOT_VERSION="$("$CLAUDE_BIN" --version 2>/dev/null | awk '{print $1}')"`

### Repo boundary guard (lines 70-74)
**Verdict:** no finding

### Lock (lines 76-81)
**Verdict:** no finding

### Directory setup (lines 83-92)
**Verdict:** finding
**Failure:** Line 87 copies the server fixture with `cp "$SERVER_FIXTURE" "$WORKDIR/probe_server.py"` — no error check, no `set -e`, no subsequent guard that the file exists. Line 89 writes a `.mcp.json` into the parent that references `$WORKDIR/probe_server.py` by absolute path. The two guards at lines 97-98 verify the `.mcp.json` files in both directories but never verify the server they point at. If `cp` fails silently (disk full, permissions, path too long), the experiment records `tool_present=no` — the exact DF1/DF2 predicted outcome — but for the wrong reason: the parent `.mcp.json` was loaded but the server could not start. The experiment's conclusion ("loader does not walk upward") would be falsely confirmed by a missing file. This is the same structural gap the script's own comment at lines 94-96 warns about for the `.mcp.json` ("a null is indistinguishable from a probe that was never planted"), applied to the server half of the probe but not guarded.
**Layer of the implied fix:** L2
**Anchor:** `cp "$SERVER_FIXTURE" "$WORKDIR/probe_server.py"` (line 87, no subsequent existence check before the run loop)

### The two guards (lines 94-98)
**Verdict:** no finding

### Evidence recording setup (lines 100-111)
**Verdict:** no finding

### Main probe loop (lines 113-164)
**Verdict:** no finding

### Footer (lines 166-168)
**Verdict:** no finding

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Not applicable — this is a probe driver, not a rubric. But the two guards at lines 94-98 duplicate the *intent* of the directory-setup block (lines 83-92): the setup is supposed to create the parent `.mcp.json` and leave the child clean, and the guards verify that. The server file has no such paired guard, which is the asymmetry that produces the directory-setup finding.
- Which single section would you expect two reviewers to diverge on most, and by how much? The directory-setup section. One reviewer sees `cp` without `set -e` and calls it a real threat to the experiment's validity; the other sees that `cp` of a verified fixture to `/tmp` essentially never fails and dismisses it. The gap is wide — the first calls the experiment's conclusion unreliable, the second calls it clean.
- What did the artifact not say that it needed to say? It never states what the experiment would conclude if the server file were missing post-copy — there is no guard and no documented fallback interpretation. The script distinguishes "no-init" from "ok" in RESULT.tsv but does not distinguish "server loaded but failed to start" from "parent .mcp.json not loaded at all." Both produce `tool_present=no`, and the experiment's dependent variable cannot separate them.
