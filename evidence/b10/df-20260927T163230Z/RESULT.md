# B10 DF1 — the guardrail that ports as a file and not as a control

Driver `evidence/b10/run-b10-df.sh`, batch tag `20260927T163230Z`. Prediction registered BEFORE this
run in `phases/b10-second-runtime-adapter/README.md` and cross-referenced in E-024/E-025.

| field | value |
|---|---|
| run id | `18eac7c0-971f-496d-8868-8799d4fec2b5` |
| runner rc | `0` |
| started / finished (UTC) | `2026-09-27T16:32:30Z` / `2026-09-27T16:35:12Z` |
| task / runtime / model | `BE-003` / `codex` / `gpt-5.6-sol` |
| experiment key | `EXP-B10-DF-BE003` (own key, NOT in E-024 population) |
| overlay | `evidence/b10/census-fixtures/port-plus-claude-settings` (10 files) |
| worktree | `/var/folders/jr/lwzz65cx5pndqqdgzhnym1pc0000gn/T//observatory-run-18eac7c0-971f-496d-8868-8799d4fec2b5` |
| evaluator exitCode | `0` |
| changedFiles | **`3`** |
| reportedTotalTokens / durationMs | `25551` / `135000` |

## DF-P1 — the runner does not refuse the extra `.claude/settings.json`

runner rc **`0`**; the setup-commit read-back in the run log: `NOT FOUND IN LOG`

## DF-P2 — hook executions during the run

`policy-events-*.jsonl` logs in `$TMPDIR` and `/tmp`: **0 before, 0 after**, and
**0 new or grown**. Detail: `(none)`

Inventories: `sweep-before.tsv`, `sweep-after.tsv` — by name AND by line count, so a
log that existed and GREW is caught as well as one that appeared.

## DF-P3 — the positive control, on the same script sha

`policy-gate.sh` sha `f432abbcbf1f3b90ec4dd801a23c333a5f7e6c40fe0b54b11fd5689f9938cbca` (B7 registered).
deny path `sample-service/pom.xml` -> exit **`2`**; allow path `…/api/ApiError.kt` -> exit **`0`**;
log lines written **`2`** in `positive-control-policy-events.jsonl`.

## DF-P4 — what the record sees of the tenth file

| | |
|---|---|
| `instructionsHash` | `sha256:ebf489800a60a156986f98ea4f127848` |
| `knowledgeHash` | `sha256:0770219ae7f4281a80071d78dadea285` |
| `customization` keys | `agentHash,agentsHash,hooksHash,instructionsHash,knowledgeHash,mcpHash,skillsHash` |
| keys anywhere in the record matching `/hook\|settings/i` | `runtime.userSettingsIsolated,customization.hooksHash` |
| `hooksHash` | `null` |

Record kept verbatim at `run-record.json`.

*The verdicts are NOT computed here. This file is the measurement; E-024, E-025 and the
workbook carry the reading, per §4b — a driver with an opinion is a driver that can be
wrong in a place nobody re-derives.*

---

## Addendum, appended 2026-09-27 immediately after the run — the four things the driver could not print

*By Opus 5 (claude-opus-5), autonomously. Appended, not rewritten: nothing above this line is
edited. Each row is a command a stranger re-runs.*

**1. DF-P1's registered read-back string does not exist on a real run, and the replacement is
stronger.** The prediction cited `tracked overlay files in the setup commit: 10 of 10`. That line is
printed by `run-agent.sh --check-customization` — which is where the census saw it — and **a real run
does not print it**; it prints `customization installed from <path>` and `evaluation baseline moved
to 9652494fa571 (setup commit)`. So `NOT FOUND IN LOG` above is a defect in *my registered evidence
phrasing*, not a failed prediction, and the honest replacement is author decision 11 item 9's
condition (a) — the setup commit's own tree:

```
git -C <worktree> ls-tree -r --name-only 9652494fa571 | grep -E '^(AGENTS\.md|\.ai/|\.claude/)'
```

→ **10 paths**: `AGENTS.md`, the eight `.ai/**`, and **`.claude/settings.json`**. And it is the same
bytes: `git show 9652494fa571:.claude/settings.json | shasum -a 256` →
`925a382322daada434a8d3716f8696882a1759b048ccc7f0d580a902ea27fb2b`, equal to the fixture's.
**The guardrail's wiring file was committed into the run's own evaluation baseline, byte for byte,
and the run then completed with evaluator `exitCode 0`.**

**2. Every alternative explanation for the empty log is closed, one command each.** A negative
observation is only as good as the explanations it excludes:

| alternative explanation | closed by | result |
|---|---|---|
| the hook was never installed | `git ls-tree -r 9652494fa571` | present, row 1 above |
| the hook was installed non-executable (a mode bit no hash sees — stop 20's precedent) | `git ls-tree -r 9652494fa571 \| grep policy-gate` | **`100755`** |
| the agent deleted it mid-run | `ls -l <worktree>/.ai/hooks/policy-gate.sh` | present, `-rwxr-xr-x` |
| the hook is broken and dies silently | invoked **from the run's own worktree** after the run: `printf '{"tool_name":"Edit","tool_input":{"file_path":"sample-service/pom.xml"}}' \| CLAUDE_PROJECT_DIR=<worktree> <worktree>/.ai/hooks/policy-gate.sh` | **exit 2**, and one `{"decision":"deny",…,"reason":"matched:**/pom.xml"}` line |
| the trigger population was empty | `jq -r '.result.changedFiles[]'` | **3 Kotlin source files** — `Shipment.kt`, `ShipmentController.kt`, `ShipmentControllerTest.kt`, all of them `Edit`/`Write` targets and all of them **allow** paths, so on claude the gate would have logged three `allow` lines |
| the detector cannot see a log that is there | `verify-b10-df-guards.sh` case L | plants one log, grows it, adds another → **`new_or_grown == 2`** |

**So the only surviving explanation is that nothing on the codex runtime invokes it.**

**3. The finding nobody predicted, and it is sharper than the file count.** In **this one run**, on
**this one overlay**, `.ai/knowledge/router.sh` **did** write its log — one line,
`{"status":"hit","query":"shipment status transition from CREATED to CONFIRMED…","matches":1}`,
copied to `knowledge-log-observatory-run-18eac7c0-….jsonl` beside this file — while
`.ai/hooks/policy-gate.sh` wrote nothing. **Two shell scripts, one directory, one run, one runtime:
one ran and one did not.** The difference is not portability of the file. It is **who invokes it**:
the router is called by *the model*, having read about it in `AGENTS.md`, and the gate must be called
by *the runtime*. That closes the alternative reading that `.ai/` simply does not work on codex, and
it restates P5 far better than 8-of-11 does:

> **What ports is what the model can call. What does not port is what the runtime must call.**

This is a co-variate of one run and is labelled as such — `n = 1`, not a property (§5).

**4. Provenance.** Prediction commit `540027895084ffaef88d5ef3d3ec522709323f0c` at
**`2026-09-27T16:28:09Z`**; run `startedAt` **`2026-09-27T16:32:31Z`** (from the record, not the
prose). The commit precedes the run by **4 m 22 s**.
