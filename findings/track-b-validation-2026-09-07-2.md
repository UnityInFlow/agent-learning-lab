# Track B validation — 2026-09-07 (pass 18)

`Validator: Claude Fable 5.1 (claude-fable-5-1), pass 18, 2026-09-07T16:5xZ, a fresh session
started by the author with one instruction: run a validator pass over
workbench.local/VERIFY-BRIEF-stop12-instruments.md. Scope: the brief's §1, §2 and §3 only. §5 out
of scope, §6 a halt.`

Under review: `agent-observatory` `obs/foreign-agent-dir-guard` at `52924a8` (2 files, +89 −1),
`agent-learning-lab` `stop12/phase-contract-instrument` at `be32f3b` (4 files, +562), and the
workspace `CLAUDE.md` position marker. Both trees clean before this pass; neither branch pushed;
both still unpushed. Author of the work: Claude Opus 5 (claude-opus-5), 2026-09-07.

Read-only against the repositories except for this file. Everything else this pass wrote lives
in the session scratchpad: a stripped copy of the runner, a naive six-marker checker, twelve
adversarial transcripts, a fixture `.github/agents/` overlay, and one evaluator log. No stop-12
artifact created. `TRACK-B-STATE.md` not edited. No model call made. `--check-customization`
runs create no observatory run record (`GET /api/runs/98a8503c…` → 404) and leave no worktree
(0 `observatory-run-*` directories modified in the last 90 minutes).

**Method.** Each §3 item was scored by building a transcript or invoking the runner and reading
the exit code and output, and only then compared with the sentence in the brief. The sentences
were of course read first, since they are the brief; the verdicts below are from the outputs.

---

## Halt

**§6 condition 2 is met: §3.2 is a real defect and the 12 cases do not cover it.** Evidence in
§3.2 below. The mitigation is Decision G (the copilot arm does not exist), which is a rule about
claims, not a line of code: the runner still accepts `--runtime copilot`, the binary is on PATH
(`GitHub Copilot CLI 1.0.81`), and the check passed. Everything else in the pass is complete and
read-only, so it is reported here rather than withheld. The author decides whether Decision G
discharges it; this pass does not.

Neither negative control came back green. No §1 command disagreed with its registered outcome.
No claim that an unrun thing was run was found in the two commits, the brief, or the corrected
`CLAUDE.md` paragraph. The one run-claim that could be re-executed without a model call — BE-004's
evaluator at 12 of 12 on `main` — was re-executed and holds (see *not checked*, last-but-one
item).

---

## §1 — reproduced, all five

Environment as §4 says: `API=http://127.0.0.1:18081`, health `{"status":"UP"}` before anything
ran; `BENCHMARKS_REPO` exported from `agent-observatory/`. One in-flight `opencode run` on this
machine belongs to a different workspace (`…/ai-agents/books`), not a benchmark batch; nothing
here scored or reviewed alongside it.

| # | Registered | Observed | Same? |
|---|---|---|---|
| 1.1 | `12 passed, 0 failed, of 12` | `verify-agent-delivery: 12 passed, 0 failed, of 12 registered cases`, exit 0 | yes |
| 1.2 | `11 passed, 0 failed, of 11` | `verify-phase-contract-checker: 11 passed, 0 failed, of 11 registered cases`, exit 0 | yes |
| 1.3 | `tracked overlay files in the setup commit: 1 of 1`, exit 0 | that line, then `run-agent: customization checks passed`, exit 0; `customization installs 1 agent overlay file(s)`; setup commit `84db68d9c23b` on baseline `eea144ef940f` | yes |
| 1.4 | silent, exit 0 | silent, exit 0 | yes |
| 1.5 | `9` | `9` | yes |

A first attempt at 1.1 and 1.3 ran from the wrong directory (shell cwd drifts between calls) and
printed `no such file or directory`. That is this session's error, not the instrument's, and it
is the shape §2.1's own warning describes: a control that fails to run is not a control.

---

## §2 — both negative controls red, quoted verbatim

### 2.1 — the runner with the foreign-agent block removed

The brief's recipe strips 47 lines (2 944 bytes) from `run-agent.sh` and writes the copy to
`/tmp/`. Run as written, the copy also loses its library: line 176 is
`source "$HERE/lib/evaluation-payload.sh"` with `HERE` derived from the script's own path, so a
copy outside `runner/` prints `lib/evaluation-payload.sh: No such file or directory` on every
case and carries on, because the runner runs under `set -uo pipefail` without `-e`. The
`--check-customization` path never calls anything from that library, so the exit codes are the
same either way — but a negative control that emits a stderr error on all 12 cases is not the
control the brief describes. Re-run with the stripped copy beside a symlink to `runner/lib/`:

```
== the runner's agent-delivery guard ==
  ok   — A: an agent overlay with no --agent is refused, and the file is named (exit 1)
  ok   — B: the same overlay with --agent is admitted, and the count is reported
  ok   — C: --agent naming a file the overlay does not install is refused
  ok   — D: --agent with no --customization is refused
  ok   — E: --agent on a runtime that has no such flag is refused, not silently dropped
  ok   — F: a customization with no agent file is untouched by the guard
  ok   — G: a run with no customization and no --agent passes (the control arm's path)
  ok   — H: --agent alone does not satisfy the skill guard; both switches are required
  ok   — I: the agent overlay is tracked 1 of 1 by the setup commit, not merely copied
  FAIL — J: expected exit 1 naming the foreign file, got exit 0:   stripped terminal CLI shims from PATH — the agent runs the real binary ==============================================================  run        21ee0f9d-1e08-4f3c-a2a9-58271c119e18
  FAIL — K: expected exit 0 naming the inert directory, got exit 0:   stripped terminal CLI shims from PATH — the agent runs the real binary ==============================================================  run        9a6f2abe-b6b5-403b-b1b4-7ea7f596e16a
  FAIL — L: expected exit 1 saying codex reads no agent directory, got exit 1:   stripped terminal CLI shims from PATH — the agent runs the real binary ==============================================================  run        50948576-7f9c-430b-872f-06eb3fc0c8e0

verify-agent-delivery: 9 passed, 3 failed, of 12 registered cases
```

**Registered `9 passed, 3 failed`, J `got exit 0`: reproduced.** A–I pass, J/K/L fail, J is exit
0 — the old runner admitted the `.github/agents` overlay. K is exit 0 without the *inert* line,
L is exit 1 for the wrong reason (the `.claude/agents` overlay hits the *passes no --agent*
refusal, not the foreign check), which is what removing exactly that block predicts. The
uncorrected `/tmp/` run gave the identical 9/3 split with the library error on top; both
transcripts are in the scratchpad.

### 2.2 — the phase checker against the naive one

The author's naive checker is not on disk (nothing under `/tmp/*naive*`), so it was rewritten
from the brief's one-line description: parse the stream, concatenate the assistant text blocks,
grep for six markers, exit 0 on six, 2 otherwise, 3 if a line is not JSON.

```
  ok   — A: a clean phased run passes (exit 0)
  FAIL — B: expected exit 2 naming VERIFICATION, got 2: naive: FAIL (5 of 6 markers) missing: VERIFICATION
  FAIL — C: expected exit 2 on code-order, got 0: naive: PASS (6 of 6 markers)
  FAIL — D: expected exit 2 on order, got 0: naive: PASS (6 of 6 markers)
  FAIL — E: expected exit 2 on placeholders, got 0: naive: PASS (6 of 6 markers)
  FAIL — F: expected exit 2 on completion, got 0: naive: PASS (6 of 6 markers)
  FAIL — G: expected exit 2 on duplicate, got 0: naive: PASS (6 of 6 markers)
  FAIL — H: expected exit 3, got 2: naive: FAIL (0 of 6 markers) missing: ANALYSIS, DESIGN, IMPLEMENTATION, VERIFICATION, REVIEW, DONE
  ok   — I: a non-JSON file is UNUSABLE (exit 3), not a failed run
  FAIL — J: expected exit 0 reporting delegation, got 0: naive: PASS (6 of 6 markers)
  FAIL — K: expected exit 2 on empty implementation, got 0: naive: PASS (6 of 6 markers)

verify-phase-contract-checker: 2 passed, 9 failed, of 11 registered cases
```

**Case C reads `got 0: naive: PASS (6 of 6 markers)` verbatim, as registered.** The count is
`2 passed, 9 failed` against a registered `1 passed, 10 failed`: case I also passed, because this
rewrite treats a non-JSON line as unusable and the author's evidently did not. That is a
difference between two naive checkers neither of which is committed, not a disagreement about
the instrument. It is still a gap: **the registered `1 passed, 10 failed` cannot be reproduced
by anyone, because the file that produced it does not exist.** The lab commit message states the
number (`10 of 11 fixtures reject it`). Recommend committing the naive checker under `tools/` as
the negative-control fixture and having `verify-phase-contract-checker.sh` assert against it, so
the control is the same one every time — the way `RUNNER_UNDER_TEST` already lets 2.1 be re-run.

---

## §3 — scored item by item

### 3.1 `Bash` not counted as mutating — the hole is real, but it is not the one described

Three twelfth-fixtures, run against the shipped checker:

| fixture | shape | result |
|---|---|---|
| `31a` | ANALYSIS · `Bash cat > X.kt` · `Bash cat > XTest.kt` · DESIGN · `Bash ./mvnw test` · rest in order, **no Edit/Write anywhere** | **FAIL, exit 2** — `no mutating tool call in the whole run — nothing was implemented` |
| `31b` | same two heredocs before DESIGN, then **one `Edit` on README.md after** DESIGN | **PASS, exit 0** — `first mutating tool Edit at 4 · DESIGN at 3` |
| `31c` | `sed -i`, `tee`, `git apply` before DESIGN, one `Edit` after | **PASS, exit 0** |

**The brief's sentence is wrong in direction.** An agent that writes its *whole* change through
`Bash` heredocs before DESIGN does not pass check 2; check 2's *nothing was implemented* branch
(case K) refuses it — with a message that is false about the run, since two files were written.
The admission is the mixed run: all the real work through `Bash` before DESIGN, one cosmetic
`Edit` after it, and the checker reports a clean phased run. That is a cheaper transcript for a
model to produce than 31a, because any run that edits at all after DESIGN qualifies.

Two facts the author's framing leaves out. First, the stream carries the shell: every `tool_use`
event in the kept logs has an `input` object, and for `Bash` it is `{"command": "..."}` (seen in
`9043f824`'s log; the checker currently records `name` and drops `input`). So a middle path
exists that parses no shell: report *Bash calls whose command contains a write shape* (`>`, `>>`,
`tee`, `sed -i`, `cat >`, `git apply`, `patch`, `mv`, `cp`, `touch`) as a **fact beside the
verdict**, the way delegation already is, and let the reader decide. Second, this item is
coupled to 3.3: if the decision-8 probe shows `Edit`/`Write` dropped from the delivered list the
way `Grep`/`Glob` were in E-005, every treated run becomes shape 31a and **the checker fails the
whole arm with `nothing was implemented`**, which would read as a treatment that did no work.
The two items must be decided together, not in file order.

Not widened. Recorded, per §5.

### 3.2 The copilot branch — a real defect, empirically, and the 12 cases do not reach it

Run, no model call, `--check-customization` only, with a fixture `.github/agents/fixture-implementer.md`:

```
$ ./runner/run-agent.sh --runtime copilot --benchmark BE-003 --experiment EXP-VERIFY-AGENT \
    --api $API --customization <scratch>/cp-overlay --check-customization
  customization installed from <scratch>/cp-overlay
  evaluation baseline moved to c5dcd1f2ac6e (setup commit)
  tracked overlay files in the setup commit: 1 of 1
run-agent: customization checks passed
exit 0
```

No *customization installs N agent overlay file(s)* line, no `--agent` requirement, no refusal.
And with `--agent fixture-implementer` on the same runtime:

```
run-agent: --agent 'fixture-implementer' is not forwarded to runtime 'copilot'.
    Only the claude arm has a named-agent flag. …
```

So on copilot **an agent overlay can never be dispatched by this runner and is never refused**:
it is copied, committed, tracked 1 of 1, hashed and reported clean. That is the B4 shape, on the
one runtime whose native glob the new block bothered to define. The author's reason for leaving
`AGENT_FILES` on `.claude/agents` — repointing it would make copilot overlays refuse
unconditionally — describes the *correct* behaviour: codex gets exactly that treatment for
exactly that reason (case L), and copilot is in the same position, since `--agent` is refused
there too. The `copilot)` arm of the `NATIVE_AGENT_GLOB` case therefore admits what the `*)` arm
refuses, on a runtime that has no more agent dispatch than codex has.

**Covered by the fixtures?** No. A–L run `claude` ten times and `codex` twice; no case runs
`copilot`. The verifier asserts the guard only where it works.

**Real?** As code, yes — it ran. As an experiment risk, Decision G says no claim about a
copilot-run agent may be made and the arm does not exist, so no run of this shape is planned.
But the runner accepts the runtime, the CLI is installed and answers `--version`, and the
verifier's own header says a control that reports success over a scope smaller than it claims
is the house failure mode. §6 says halt; halted.

The fix, when the author takes it, is one line — put `copilot` on the `*)` branch (both
directories foreign, `NATIVE_AGENT_GLOB=''`) — plus a thirteenth case. Not made here.

### 3.3 The `tools:` line is a prediction — nothing calls it a treatment, and the coupling above is new

Grep for `phases-v1.0` and `backend-feature-phases` across the workspace root, both repos and
the state file finds the overlay itself and the brief, nothing else. The lab commit message says
*material, not a registration*, *that prediction is untested on this file*, and *author decision
8's init.tools read-back has not run*. The workspace `CLAUDE.md` does not mention it. The overlay
body says `Grep` and `Glob` *are not in your tool list*, which is true of the declared list
whatever the runtime delivers. **Verdict: no document calls it a treatment.** The probe is the
author's to run (§5); not run here.

Two things the brief does not say. (a) The coupling in 3.1: the checker's `MUTATING` set assumes
`Edit`/`Write` reach the model, and E-005's evidence is that a list containing `Bash` is
rewritten before delivery — which entries survive is exactly what the probe measures, and the
checker's ability to score the arm at all depends on the answer. (b) The branch is named
`stop12/…` and the overlay is B5's material, while the corrected `CLAUDE.md` paragraph says
*Nothing of stop 12 exists — §6 forbids a future step's artifacts early.* The commit message
draws the line at *registration*; the track's §6 says *artifacts*. Whether an unregistered
treatment overlay on an unpushed branch is on the right side of that line is the author's call,
and the two sentences currently disagree about it.

### 3.4 The cross-check — run over all 38 kept streams; the checker sees what the counter missed

The runner keeps each stream-json at `${TMPDIR}/observatory-agent-<run-id>.log` (outside the
worktree, `run-agent.sh` line 585), and all 38 logs named in the four fourth-cell manifests are
on disk. `9043f824`'s is 201 lines, all JSON.

| batch | run | arm | checker `delegations` | `delegation_kinds` | manifest stream | telemetry |
|---|---|---|---|---|---|---|
| E-008 `122828Z` seq 08 | `9043f824` | control | **37** | `Agent, parent_tool_use_id` | 1 | **0** |
| every other run — E-008 ×17, E-009 ×20 | — | F and control | 0 | — | 0 | 0 |

All 38 are `FAIL` (missing markers — no phases were asked for; the exit code is not the point).
**On `9043f824` the checker reads 37 where the observatory counter read 0**, and 0 on every run
where the counter read 0. That is an independent detection of the blind spot filed in
`blocked_on_author`: one `Agent` `tool_use` with `"subagent_type":"Explore"` plus 36 events
carrying `parent_tool_use_id`. Belongs in findings; here it is.

One reading note. `delegations: 37` counts events, not delegations: one `Agent` call and 36
sub-events from it. The narrative line says *this run delegated (Agent, parent_tool_use_id)*,
which is right, but a reader comparing the number with the manifest's `1` will think the two
instruments disagree. Recommend two facts — `delegating_calls` and `delegated_events` — rather
than one sum.

### 3.5 Markers read only from `assistant` text — right, with two edges worth knowing

| fixture | shape | result |
|---|---|---|
| `35a` | DESIGN only inside `Bash echo "<<PHASE:DESIGN>>"` input | FAIL — `missing phase marker(s): DESIGN` |
| `35b` | DESIGN only in the `tool_result` echoed back (`user` event) | FAIL — same |
| `35c` | prose says *Next I will emit <<PHASE:DESIGN>>*, then the real marker | **FAIL — `emitted more than once: DESIGN`** |
| `35d` | DESIGN marker emitted by a **subagent** (`parent_tool_use_id` assistant event) | **PASS**, delegation noted |
| `35e` | subagent runs `Edit` before the main session's DESIGN | FAIL — `code was written before DESIGN` |

The author's belief holds for 35a/35b. Two edges: **35c** is a false refusal a model can trip by
quoting the instruction — and the agent file puts every marker in a code fence and in six
headings, so echoing one is not far-fetched; a marker is counted wherever it appears in text,
including mid-sentence. **35d** is a small admission: `load_stream` tags a delegated event and
then *also* parses its content as if it were the main session's, so a subagent's marker counts
for the parent. 35e shows the same choice working in the safe direction for tool calls. Worth a
line in the docstring either way; no fixture covers either edge.

### 3.6 Same-message ordering — right, and moot on real data

`36a` `[text DESIGN, tool_use Edit]` → PASS; `36b` `[tool_use Edit, text DESIGN]` → FAIL. As
described. In the kept `9043f824` log, **0 of 201 events carry more than one content block**,
and the b04 probe streams are the same shape: `claude -p --output-format stream-json` emits one
block per `assistant` event, so the order the checker sees is the order the CLI wrote them.
The question does not arise on this runner's output; if it did, block order in an API message is
generation order, and the call is correct.

### 3.7 CI claims — (a) solid, (b) now verified from the action's source, not observed

(a) `for f in tools/*.sh …` — the glob excludes `.py`. Read off the file; correct.

(b) `ludeeus/action-shellcheck@master`, `action.yaml` fetched via the GitHub API today: files
are selected by a `find` over a fixed extension list (`*.sh`, `*.bash`, `*.ksh`, `*.zsh`,
`*.shlib`, the rc files) **plus** a second pass that applies the shebang regex
`^#! */[^ ]*/(env *)?[abk]*sh` only to files matching `! -name '*.*' -perm /111` — executable
files with **no dot in the name**. `check-phase-contract.py` has a dot and a `python3` shebang,
so it is excluded by both passes. **The assumption is right, and it stays unobserved on this
repo** until a push: `tools/` has never held a `.py` on `origin/main`, and the observatory's CI
does not use this action. One thing the brief does not mention: the action is pinned to
`@master`, so the behaviour just verified is the behaviour today.

### 3.8 The job has never run — and when it does, it will not gate

Cannot be observed until a push; not pushed (§5). Two things checkable now. The job is on
`pull_request` and `push: main`, so it fires on the first PR. And **branch protection on
`agent-learning-lab` `main` requires only two checks: `shell tools` and `contracts parse`**
(`gh api …/branches/main/protection`). `phase-contract` — and `run-record`, `score-output`,
`sheet-categories`, `board-freshness`, `run-gate`, `links` — will run and report, and a red one
does not block a merge. The state file's *8 of 8 CI checks* counts reported checks, of which two
are required. By the layer rule: the job executes, so it is L2 over the fixtures; the merge gate
it is assumed to be is L3, a green tick a human chooses to wait for.

---

## Not checked

- The decision-8 `init.tools` probe on `phases-v1.0`. Model call; §5 reserves it for the author.
- Whether the `phase-contract` job fires and is green on GitHub. Needs a push.
- The author's own naive checker and its `1 passed, 10 failed`. Not on disk; see 2.2.
- What Copilot CLI 1.0.81 does with `.github/agents/*.md` when no agent is selected — whether the
  main session can delegate to one. §3.2 does not depend on the answer: the runner produces no
  delivery proof either way.
- `verify-agent-delivery.sh` cases A–I on the stripped runner beyond their pass lines — they
  passed, and were not re-read by hand (§6 of the track says re-verify one green case by hand;
  §2.1's J/K/L outputs were read in full instead).
- ~~BE-004's `verify-evaluator.sh` on benchmarks `main`, which the corrected `CLAUDE.md` says was
  re-run at 12 of 12. First attempt killed at a 5-minute cap (it builds and tests per fixture);
  re-run in the background with a 10-minute budget, result not in hand when this file was
  written.~~ **Checked after all, before this file was finished:** the background re-run
  completed — 12 cases, every one `RESULT: OK`, closing line
  `verify-evaluator: all 12 cases behaved as specified — evaluator discriminates.`, exit 0. The
  `CLAUDE.md` claim holds. The first attempt's 5-minute kill left no process behind
  (`LC_ALL=C pgrep -fl verify-evaluator` empty before the re-run). *Struck and corrected by
  Claude Fable 5.1 (claude-fable-5-1), 2026-09-07, same pass.*
- `lab#74 → e342d1e` as cited in `CLAUDE.md`: verified as a two-parent merge of
  `stop11/fourth-cell` on `origin/main`. The rest of the paragraph was read for consistency
  with the state file's `status: running` / stop 12 not opened, and is consistent, except for
  the *nothing of stop 12 exists* tension recorded under 3.3.

## Corrections made in place

None. Every finding is recorded here and nothing under review was edited (§5, last bullet).
Both trees are as the brief left them, plus this file, uncommitted.

## The single finding most likely to matter

Not 3.2, despite the halt — Decision G fences it. **3.1 coupled with 3.3.** The checker's only
strong check keys on `Edit`/`Write`, the overlay's delivered tool list is unmeasured, and E-005's
one measurement of a `Bash`-bearing list is that entries vanish. If the probe drops `Edit`/`Write`,
every treated run scores as *nothing was implemented*, and stop 12 opens with an instrument that
cannot pass its own treatment arm. Run the probe before the first batch, then decide 3.1.
