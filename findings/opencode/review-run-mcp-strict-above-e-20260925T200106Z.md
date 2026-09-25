# opencode review — run-mcp-strict-above-e

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
reviewed_utc:    20260925T200106Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p06a/run-mcp-strict-above-e.sh
    sha:  a245808dd08e
    dirty: false
lab_head:        aa98487
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/evidence/p06a/run-mcp-strict-above-e.sh
  verdict: REJECT
  summary: The arm cannot reliably confirm DF5 — the sed substitution can silently fail on fixture template drift, and even with a correct .mcp.json an ABSENT result is consistent with both strict-mode filtering and Claude never reading ancestor files (no positive control to distinguish).
  blocking:
    - reason: The sed substitution on line 87 can silently fail if the fixture's `__PROBE_SERVER_PATH__` placeholder is renamed: sed produces no error on a no-match, so the resulting `$PARENT/.mcp.json` still carries the literal placeholder. Claude then cannot start the server and the arm records `tool_present=no`, indistinguishable from the strict-mode-filtering outcome DF5 predicts. The post-copy `[[ -s ]]` on line 89 only checks that `probe_server.py` has size, not that the .mcp.json substitution worked. The handshake on lines 62-69 pipes JSON directly into `probe_server.py`, bypassing the .mcp.json entirely, so it proves the server works but not that the .mcp.json points to it. The sha256 on line 115 is a recorded value for post-hoc review, not a runtime check.
      wrong_action: A reader cites "5/5 ABSENT" as evidence that strict mode filters ancestor files, when the actual cause could be a broken .mcp.json. The false positive would land in the evidence directory and be cited as a measured result.
      anchor: 'sed "s|__PROBE_SERVER_PATH__|$WORKDIR/probe_server.py|" "$MCPJSON_FIXTURE" > "$PARENT/.mcp.json"'
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/evidence/p06a/run-mcp-strict-above-e.sh:87
    - reason: ABSENT is consistent with two scenarios: (a) strict mode filtered the ancestor's .mcp.json (DF5 confirmed), and (b) Claude does not read ancestor .mcp.json files regardless of the flag — for instance because `--setting-sources project` resolves the project root to the cwd, not the directory hierarchy (DF5 unfalsifiable in this setup, not confirmed). The arm can refute DF5 on a PRESENT row but cannot confirm it on ABSENT. There is no positive control — no run with `--strict-mcp-config` OFF and the file in the cwd — to verify the flag does anything in this configuration. The header only frames refutation, not confirmation, leaving the reader to assume ABSENT implies strict-mode filtering.
      wrong_action: A reader takes "5/5 ABSENT" as confirmation that strict mode filters ancestor files, when the arm cannot rule out that Claude never reads ancestor files at all (in which case strict mode has nothing to filter). The published claim would be stronger than the measurement supports.
      anchor: 'A refutation would mean the flag filters the cwd'\''s .mcp.json and not an ancestor'\''s, which would make this stop'\''s registered Decision wrong.'
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/evidence/p06a/run-mcp-strict-above-e.sh:14-16
  non_blocking:
    - reason: The `permission_denials` extraction on lines 147-148 uses `jq ... | tail -1` to pick the last `result` event; if multiple result events are emitted and the first carries denials while the last does not, the script reports `absent` even though denials occurred. For a single `-p` prompt this is safe in practice but not by construction, and the `tail -1` choice is undocumented.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/evidence/p06a/run-mcp-strict-above-e.sh:147-151
    - reason: The TSV can produce four combinations of `server_present` × `tool_present`, but the header frames the prediction as binary (ABSENT or refuted). A `server_present=yes, tool_present=no` row is interpretable as either "strict mode allowed discovery but blocked tool loading" or "the server failed to connect for reasons unrelated to strict mode." The script records the data but does not state which interpretation the analysis should adopt.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/evidence/p06a/run-mcp-strict-above-e.sh:14-16
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 155s |
| ollama-cloud/glm-5.2 | ok | 163s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Guards — binary, version, fixtures, handshake (lines 51-69) | 1/1 | L2 |
| args=(--permission-mode acceptEdits | 1/1 | L3 |
| for ((i = 1; i <= N; i++)); do | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Header comment (lines 1-30)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The header's claim structure is appropriately cautious. It says DF5 was "ABSENT on 5 of 5" and that "A refutation would mean the flag filters the cwd's .mcp.json and not an ancestor's" — it is looking for a refutation, not claiming to confirm the negative. The exit-code table matches every `die` call in the body (0, 1, 2, 3, 5, 6, 9, 10, 12 all verified against their call sites). The gaps (4, 7, 8, 11) are consistent with the other arms' code spaces.

### Configuration (lines 31-49)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Defaults are explicit, environment overrides are namespaced with `PROBE_`, and every variable is consumed downstream. `OMIT_STRICT` is documented as fixture-only to provoke guard 12, which is the correct use of a test-only knob.

### Guards — binary, version, fixtures, handshake (lines 51-69)
**Verdict:** finding
**Failure:** The `mcp.json.fixture` is a committed template containing the placeholder `__PROBE_SERVER_PATH__`. Line 87 runs `sed "s|__PROBE_SERVER_PATH__|$WORKDIR/probe_server.py|"` to produce `$PARENT/.mcp.json`. Nothing verifies the substitution actually occurred. If the fixture is edited and the placeholder is renamed or removed (template drift), sed succeeds silently and writes a `.mcp.json` whose server path is the literal string `__PROBE_SERVER_PATH__` (or whatever the new template says). Claude then tries to start a server at a nonexistent path, fails, and reports no MCP tools. The arm records `tool_present=no, server_present=no` — indistinguishable from "the strict flag filtered the ancestor's `.mcp.json`," which is the exact hypothesis. The handshake test on lines 62-69 does not catch this: it pipes JSON directly to `probe_server.py`, bypassing the `.mcp.json` entirely, so it proves the server works but not that the `.mcp.json` points to it. The sha256 on line 115 records the hash for post-hoc review but nothing executes a check at run time. A false confirmation of DF5 would land in the evidence directory and be cited as a measured result.
**Layer of the implied fix:** L2
**Anchor:** `sed "s|__PROBE_SERVER_PATH__|$WORKDIR/probe_server.py|" "$MCPJSON_FIXTURE" > "$PARENT/.mcp.json"`

### Guards — repo, lock, directory setup (lines 71-93)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The repo-containment guard (lines 71-75), mkdir-based lock (line 77), child-cleanliness check (line 92), and parent-existence check (line 93) all execute and exit non-zero on violation. The post-copy `[[ -s ]]` check on line 89 is the right response to the §4a review's finding on arm D's driver. The `SKIP_SETUP` path is operator-gated and its contract (reuse a prior `WORKDIR` with an existing `.mcp.json`) is clear from the variable name and default.

### Argv construction and assertion (lines 95-105)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The `grep -qx` on line 104 is an exact-line match, so `--strict-mcp-config-foo` would not satisfy it. The `OMIT_STRICT=1` path correctly provokes guard 12, and the comment on line 44 documents this as intentional. The argv is the unmodified plain-run set with the flag added, which is what the header claims.

### Evidence scaffolding (lines 107-120)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The TSV header, argv dump, prompt file, and hash record are all written before the run loop. The hash on line 115 is a recorded value for post-hoc comparison, not a runtime check — but it is not presented as one.

### Run loop (lines 122-163)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The `has("permission_denials")` guard on lines 147-151 correctly distinguishes an absent key from an empty array, which is the fix the comment on lines 144-146 says it is. The `tail -1` on result extraction handles the expected single-result stream; if claude emits multiple result lines, the last one wins, which is the safe choice. The `no-init` path on line 137 records the failure rather than skipping the row. The rate-limit `f13-candidate` tag on line 156 is a note column, not a gate, which is the right place for it.

### Finalization (lines 165-167)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- No scoring category duplicates a pass/fail gate. Exit code 12 gates the presence of `--strict-mcp-config` in the argv; the `tool_present` column in RESULT.tsv measures the outcome. These test different things — the gate checks the input, the column records the output.
- The section two reviewers would diverge on most is the sed substitution on line 87. One reviewer reads the fixture as a committed, stable template and dismisses the risk; another reads the absence of a post-sed verification as a gap whose failure mode produces a false positive for the experiment's hypothesis. The divergence is about 1 point on a 0-3 confidence scale — the failure scenario is real but requires a fixture edit that the lock and version pin do not prevent.
- The artifact does not say what `--setting-sources project` causes claude to treat as the project root — the cwd alone, or the directory hierarchy. If claude only reads the cwd for project settings, the parent's `.mcp.json` is invisible regardless of `--strict-mcp-config`, and the arm measures "claude never looked" rather than "the flag filtered it." The header's refutation framing ("A refutation would mean…") is cautious enough to survive this ambiguity — a `tool_present=yes` result would still be a valid refutation — but a `tool_present=no` result cannot be attributed to the flag without an additional arm that runs with `--strict-mcp-config` OFF and the same parent-file setup. The artifact does not mention this confound.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Stop 18 / Lab 6.5 — §4 step 13a. ARM E only.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The header documents the experimental design, the registered prediction (DF5 in E-021), and every exit code with its trigger. The prediction is recorded as pre-existing ("BEFORE this file existed"), the refutation condition is stated, and the exit-code table matches the `die` calls in the body. The claim that arms D/D2/D3 and B left this combination unmeasured is a factual assertion about prior work; nothing in this script depends on it being true, and if it were false the script would still measure what it measures.

### set -uo pipefail
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

All variables have `:-` defaults. `set -e` is deliberately omitted so the run loop can record a `no-init` row and continue instead of aborting on a jq failure. The `pipefail` is belt-and-suspenders given the `|| true` on the jq extractions. No unset-variable path exists: every `die` call passes two arguments, and every variable read in the loop body is assigned earlier in the same iteration.

### die() { printf 'arm-e: %s\n' "$2" >&2; exit "$1"; }
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Binary presence, version pin, fixture existence, and server handshake are all checked before any state is created. The handshake pattern match on line 66–68 accepts both `"name": "probe_marker"` and `"name":"probe_marker"` — the two JSON serializations a Python `json.dumps` might produce depending on separator settings. The server fixture is under the script's control, so the pattern is adequate.

### for repo in agent-learning-lab agent-observatory agent-observatory-benchmarks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The containment check uses `case "$WORKDIR/" in "$WORKSPACE/$repo/"*)` which correctly catches both exact matches and subdirectories. The default `WORKDIR` is `/tmp/...`, so this only fires on an explicit `PROBE_WORKDIR` override pointing inside a tracked repo — which is exactly the mistake it should prevent.

### if ! mkdir "$LOCK" 2>/dev/null
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`mkdir`-as-lock is atomic on all target filesystems. The EXIT trap removes it. A SIGKILL would leave it stale, but that is the known tradeoff of this pattern and the exit-6 message names the lock path so a human can `rmdir` it. The `SKIP_SETUP` path correctly skips the copy/sed but still runs guards 9 and 10, so a re-run into a pre-populated `WORKDIR` is admitted only if the parent `.mcp.json` is already there.

### args=(--permission-mode acceptEdits
**Verdict:** finding
**Failure:** Guard 12 (line 104–105) asserts `--strict-mcp-config` is present in the argv by printing each array element on its own line and matching with `grep -qx`. This works for the bare flag as added on line 101. But the guard's stated purpose is "THE ARM'S WHOLE POINT" — if the flag were silently ignored by claude at runtime (e.g., a future version accepts it but does nothing), the guard would still pass because the flag is in the argv, and the measurement would record whatever claude does without strict enforcement. Two reviewers would diverge on whether "the flag is in the argv" is sufficient evidence that strict mode is active, versus needing a runtime confirmation that the flag actually filtered something. The script has no positive control — no run with the flag OFF and the file IN the cwd — to confirm the flag does anything at all in this configuration. The DF5 prediction ("ABSENT on 5 of 5") would be consistent with both "strict mode works and filters the ancestor file" and "strict mode is a no-op and the file was never read anyway."
**Layer of the implied fix:** L3
**Anchor:** `printf '%s\n' "${args[@]}" | grep -qx -- '--strict-mcp-config' \   || die 12 "--strict-mcp-config is absent from the argv; this arm would measure arm D"`

### printf '%s\n' "$PROMPT" > "$EVID/PROMPT.txt"
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Provenance files (PROMPT, HASHES, argv, RESULT header) are written before the loop. The `shasum -a 256` on line 115 is macOS-native, matching the `darwin` platform. The TSV header matches the columns written in the loop. The `spent_usd` line is appended after the loop. All consistent.

### for ((i = 1; i <= N; i++)); do
**Verdict:** finding
**Failure:** The `permission_denials` extraction (lines 147–148) uses `jq ... | tail -1` to pick the last `result` event in the stream. If claude emits more than one `result`-typed event (e.g., a partial result followed by a final result, or a result event from a retry), and the first has `permission_denials` while the last does not, the script reports `absent` even though denials occurred. The `has()` check and the `.permission_denials | length` extraction both use `tail -1`, so they are at least consistent with each other — but a reviewer who expects the *union* of all result events to be counted would get a different number than one who expects only the final result. The script does not document which it intends. For a single `-p` prompt this is almost certainly one result event, but "almost certainly" is not "by construction."
**Layer of the implied fix:** L3
**Anchor:** `if [[ "$(jq -r 'select(.type=="result") | has("permission_denials")' < "$stream" | tail -1)" == "true" ]]; then`

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Not applicable — this is a probe driver, not a scoring rubric. The exit-code guards (0–12) are pass/fail gates on the script's own preconditions, and the RESULT.tsv columns are measurements, not scores. No duplication.
- Which single section would you expect two reviewers to diverge on most, and by how much? The `args=(--permission-mode acceptEdits` section — specifically whether guard 12's "the flag is in the argv" is sufficient to claim the arm measures strict-mode behavior, or whether a positive control (flag OFF, file IN cwd) is needed to distinguish "strict mode filtered the ancestor" from "the ancestor was never read regardless." I'd expect roughly a 1-point divergence on a 4-point confidence scale: one reviewer accepts the guard as adequate given the prior arms' evidence, another sees a confound that the script cannot resolve from its own output.
- What did the artifact not say that it needed to say? The script does not state what a `server_present=yes, tool_present=no` row would mean for DF5. The header frames the prediction as binary (ABSENT or refuted), but the TSV can produce four combinations of those two fields. A row where the server is listed but the tool is not available is interpretable as either "strict mode allowed discovery but blocked tool loading" or "the server failed to connect for reasons unrelated to strict mode." The script records the data but does not say which interpretation the analysis should adopt.
