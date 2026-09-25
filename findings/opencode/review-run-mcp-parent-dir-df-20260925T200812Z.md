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
reviewed_utc:    20260925T200812Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p06a/run-mcp-parent-dir-df.sh
    sha:  7185fbdd5efe
    dirty: false
lab_head:        aa98487
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/p06a/run-mcp-parent-dir-df.sh
  verdict: ACCEPT
  summary: Probe script for stop 18 arm D that produced a measured, positive refutation of DF1/DF2 (tool delivered on 5/5); the three disclosed scope limits (a, b, c) are honestly named in the header and the run-on-disk outcome rules out (a) and (b) retroactively, so the artifact leaves the machine with valid evidence on disk.
  blocking: []
  non_blocking:
    - reason: >
        The `cp "$SERVER_FIXTURE" "$WORKDIR/probe_server.py"` at line 112 has no
        error check. `set -uo pipefail` is on without `-e`, and the script does
        not have an explicit `|| die 3` after the cp; a failed copy on a full
        disk or a broken mount would let the `.mcp.json` point at a missing
        server and record `tool_present=no` as a false DF1/DF2 confirmation.
        This is already disclosed in the header as scope limit (a) and is ruled
        out for the run on disk by the positive result — but it remains the
        load-bearing L2 gap and the documented one-line fix is not applied.
      evidence: evidence/p06a/run-mcp-parent-dir-df.sh:37-44,111-114
    - reason: >
        The mcp.json fixture receives only an existence check at line 85
        (`[[ -f "$MCPJSON_FIXTURE" ]]`), while the server fixture receives a
        functional handshake at lines 86–93. The `sed` at line 114 produces the
        planted config with no JSON-parseability check on either input or
        output. If the fixture were ever malformed (trailing comma, unquoted
        value, a path-substitution that breaks a JSON string), the planted
        `.mcp.json` would be invalid, claude would fail to load it, and the
        arm would record a false DF1/DF2 confirmation indistinguishable from
        "loader does not walk upward." The sha256 at line 132 lets a post-hoc
        reader detect this, but does not prevent the false measurement. This
        is the same defect class as scope limit (a) and is not disclosed in
        the header.
      evidence: evidence/p06a/run-mcp-parent-dir-df.sh:82-85,114,132
    - reason: >
        The permission_denials column at line 172 collapses the absent-key case
        (`null | length == 0`) and the present-but-empty case (`[] | length == 0`)
        into the same `0`. Already disclosed as scope limit (b); the header
        records that the key was present and `[]` on every run of this arm,
        which is a hand-check rather than a structural guarantee. A downstream
        consumer reading `0` cannot tell the two cases apart from RESULT.tsv
        alone.
      evidence: evidence/p06a/run-mcp-parent-dir-df.sh:46-49,172
    - reason: >
        The cross-cutting question — does `verify-mcp-parent-dir-df.sh` exercise
        a fixture for "cp failed after handshake passed" or "mcp.json is invalid
        JSON" — cannot be answered from the attachments. The header's claim at
        lines 22–32 that "every [exit code] provoked by a fixture" is
        consistent with the script as written (the script does not check
        either condition, so no such fixture is needed), but the verifier file
        itself is not in evidence here. Worth a one-line note in a follow-up
        rather than a blocker for this artifact.
      evidence: evidence/p06a/run-mcp-parent-dir-df.sh:22-32
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 87s |
| ollama-cloud/glm-5.2 | ok | 181s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Header comment block (lines 1–54) | 1/1 | L2 |
| Fixture validation and handshake (lines 82–93) | 1/1 | L2 |
| Directory setup (lines 108–117) | 1/1 | L2 |
| Main probe loop (lines 138–189) | 1/1 | L2 |
| KNOWN SCOPE LIMITS | 1/1 | L2 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Header comment block (lines 1–54)
**Verdict:** finding
**Failure:** The header documents three known scope limits (a, b, c) but does not fix any of them. Limit (a) is the load-bearing one: `cp "$SERVER_FIXTURE" "$WORKDIR/probe_server.py"` at line 112 is unchecked, and the handshake at lines 86–89 validates the *fixture* (`$SERVER_FIXTURE`), not the *copy* (`$WORKDIR/probe_server.py`). Concrete scenario: a future run on a full disk or with a broken mount where `cp` returns non-zero but the script continues (no `set -e`), the `.mcp.json` points to a non-existent server, claude cannot start it, `tool_present=no` is recorded, and a null is read as DF1/DF2 confirmed — the exact false-positive the arm exists to prevent. The header says "A post-cp existence check is the fix and is not applied here," which is an honest L3 admission, not a control. Two reviewers diverge here: one reads the documentation as sufficient given the run-on-disk outcome, the other reads it as an unfixed L2 gap that will bite the next null.
**Layer of the implied fix:** L2
**Anchor:** `The guards never verify probe_server.py SURVIVED THE cp. ... A post-cp existence check is the fix and is not applied here.`

### `set -uo pipefail` and configuration (lines 55–72)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Binary and version check (lines 77–80)
**Verdict:** no finding
**Failure:** n/a — the `awk '{print $1}'` parse is addressed in the header (item c) and fails closed at exit 2 on a mismatch.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Fixture validation and handshake (lines 82–93)
**Verdict:** finding
**Failure:** The handshake at lines 86–89 pipes the initialize/tools/list pair through `python3 "$SERVER_FIXTURE"` — the *source fixture*, not the *copied* server. This is the same defect as header limit (a), viewed from the code: the handshake proves the fixture can answer, then the script copies it (unchecked), then the `.mcp.json` points at the copy. A reviewer reading only this block would conclude the server is validated; a reviewer reading the cp at line 112 would see the validation does not cover the file claude actually loads. The two blocks, read together, are where the gap lives.
**Layer of the implied fix:** L2
**Anchor:** `HANDSHAKE="$(printf '%s\n%s\n' ... | python3 "$SERVER_FIXTURE" 2>/dev/null)"`

### Repository guard (lines 95–99)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lock acquisition (lines 101–106)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Directory setup (lines 108–117)
**Verdict:** finding
**Failure:** Line 112 `cp "$SERVER_FIXTURE" "$WORKDIR/probe_server.py"` has no error check. Without `set -e`, a failed cp is silent. Line 114 `sed` then writes a `.mcp.json` pointing at a file that may not exist. The guard at line 123 checks `[[ -f "$PARENT/.mcp.json" ]]` — existence of the config, not of the server it references. Concrete scenario: `cp` fails (permissions, disk full), `sed` succeeds (it reads the fixture, not the server), the guard passes, and the arm runs against a missing server. This is the code-level instance of header limit (a); the fix is a one-line `[[ -f "$WORKDIR/probe_server.py" ]] || die 3` after the cp, which is L2 and not present.
**Layer of the implied fix:** L2
**Anchor:** `cp "$SERVER_FIXTURE" "$WORKDIR/probe_server.py"`

### The two guards (lines 119–123)
**Verdict:** no finding
**Failure:** n/a — the guards correctly verify the child is clean and the parent has the config. They do not verify the server the config references, but that is the cp finding above, not a defect in this block.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Evidence header writing (lines 125–136)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Main probe loop (lines 138–189)
**Verdict:** finding
**Failure:** Line 172: `denials="$(jq -r 'select(.type=="result") | .permission_denials | length' < "$stream" | tail -1)"`. If `permission_denials` is absent from the result object, `jq` evaluates `.permission_denials` as `null`, and `null | length` returns `0`. If it is present as `[]`, `length` also returns `0`. The script cannot distinguish "no denials" from "key absent." This is header limit (b), and it is correct that it did not bite on this run (the key was present and `[]` everywhere). But the column is in `RESULT.tsv` and a future consumer reading `0` cannot tell whether the field was measured or missing. Two reviewers diverge: one says "checked by hand, documented, no finding"; the other says "the column is ambiguous by construction and a downstream consumer has no way to know."
**Layer of the implied fix:** L2
**Anchor:** `jq -r 'select(.type=="result") | .permission_denials | length' < "$stream" | tail -1`

### Exit (lines 191–193)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Name both. — This is a probe script, not a rubric; no scoring categories. The handshake check (lines 90–93) and the two guards (lines 122–123) are pass/fail gates that overlap with the header's exit-code documentation, but they are gates restated as documentation, not scoring categories restating gates.
- Which single section would you expect two reviewers to diverge on most, and by how much? — The directory setup / cp block (line 112). The header's documentation is thorough enough that one reviewer reads "known and ruled out for the run on disk" and writes `no finding`; the other reads "L2 fix explicitly not applied, false-positive path open for any future null" and writes `finding`. That is a full verdict flip, not a shade of severity.
- What did the artifact not say that it needed to say? — Whether `verify-mcp-parent-dir-df.sh` (referenced at line 22) actually exercises a cp-failure fixture. The header claims "every one [exit code] provoked by a fixture," but exit 3 covers both "fixture missing" and "handshake failed" — neither of which is "cp failed after handshake passed." If no fixture simulates a post-handshake cp failure, the exit-code proof does not cover the defect the header itself names as blocking.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Header comment — purpose and exit codes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Exit codes 0–10 are each documented with a one-line trigger, each is provoked by a fixture in the named verifier, and each `die N` in the body maps to a documented code — including exit 1, which the header explicitly notes was added late from a review and never fired. The version-pin at line 78–80 fails closed at exit 2 if the parse is wrong, which the header argues correctly in scope limit (c). No divergent reading found.

### KNOWN SCOPE LIMITS
**Verdict:** finding
**Failure:** The `mcp.json.fixture` is checked at line 85 with `-f` (existence only) and then sed-substituted into `$PARENT/.mcp.json` at line 114. Nothing validates that the fixture — or the sed output — is parseable JSON. The guard at line 123 checks `-f` again (existence, not content). The server fixture gets a functional handshake (lines 86–93); the config fixture gets nothing equivalent. If the fixture contains invalid JSON (a trailing comma, an unquoted value, a placeholder positioned so the path substitution breaks the JSON string), the `.mcp.json` written to the parent is invalid, claude cannot load it, `tool_present=no` / `server_present=no`, and DF1/DF2 appear confirmed. The sha256 at line 132 records the bad content for post-hoc detection but nothing prevents the false measurement from being written to RESULT.tsv. This is the same defect class as scope limit (a) — a silent setup failure producing a false null — but (a) discloses it for the `cp` of `probe_server.py` and does not mention the `sed` of `mcp.json`. Two reviewers would diverge on whether the committed fixture makes this theoretical or whether the asymmetry between server-handshake and config-nothing is the real gap.
**Layer of the implied fix:** L2
**Anchor:** `[[ -f "$MCPJSON_FIXTURE" ]] || die 3 "mcp.json fixture missing: $MCPJSON_FIXTURE"`

### Setup and validation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Binary lookup, version pin, fixture existence, server handshake, repo guard, and lock are each explicit and each fail to a documented exit code. The handshake tests the fixture in its original location (not the post-cp copy), which scope limit (a) already discloses. `set -uo pipefail` without `-e` is deliberate — the script uses explicit `|| die N` checks for every operation whose failure matters, and the claude run is guarded downstream by the init-file size check at line 164.

### Directory setup and the two guards
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The two guards at lines 122–123 (child clean, parent populated) are the arm's meaning-making checks, and the header says so. The existence-only check on the parent's `.mcp.json` is the subject of the finding above (KNOWN SCOPE LIMITS), not a separate one. The `SKIP_SETUP` path correctly re-runs the guards against a pre-existing setup. The `mkdir -p` calls fail to exit 1, which is documented.

### Evidence recording
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

PROMPT.txt, HASHES.txt (with parent `.mcp.json` sha256), and the RESULT.tsv header are written before the loop. The hash records what was actually planted, which is the post-hoc safety net for the cp/sed gaps — honest, if not preventive.

### Run loop
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The args array is recorded per-iteration (line 148). A claude crash before init emission produces an empty stream, caught as `no-init` at line 164. A crash after init emission does not invalidate the arm's measurement — `tool_present` and `server_present` come from the init message, which was already emitted, and those are the fields that answer the arm's question (does the loader walk upward?). The `denials=na` / `cost=0` that a post-init crash would leave are secondary fields, and `na` is distinguishable from `0` in the TSV. The `note=ok` default means "no F13 candidate," not "run completed successfully," and a reviewer reading the column header (`note`) alongside `denials=na` would not misread it. The `jq ... // empty` fallbacks and the `[[ -n ]] || val=0` guards handle absent result fields without crashing.

### Finalization
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? N/A — this is a probe script, not a rubric. The exit codes are pass/fail gates; the scope limits are disclosures of known gaps in those gates. No duplication.
- Which single section would two reviewers diverge on most, and by how much? KNOWN SCOPE LIMITS, by a full finding. One reviewer reads scope limit (a) as covering "silent setup failures" generally and sees the mcp.json gap as already disclosed by implication; another reads (a) as specifically about the `cp` of `probe_server.py` and sees the mcp.json `sed` as an undisclosed gap of the same class. The difference is whether "same defect class, different operation" is a new finding or a restatement.
- What did the artifact not say that it needed to say? That the `mcp.json.fixture` is never validated as JSON — only checked for existence — while the server fixture receives a functional handshake. The asymmetry is the gap, and it is not named in the scope limits.
