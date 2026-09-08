# Track B validation — 2026-09-08 (pass 19)

`Validator: Claude Fable 5.1 (claude-fable-5-1), pass 19, 2026-09-08T0x:xxZ, the same session
that wrote pass 18, continued by the author with "verify opus work and provide resolution".
Scope: was pass 18's halt discharged honestly, and does the work now under review hold? The
check pass 17 made of pass 16, one stop on.`

Under review: `agent-observatory` `obs/foreign-agent-dir-guard` at `a7fc212` (on `52924a8`),
`agent-learning-lab` `stop12/phase-contract-instrument` at `69f0bfd` (on `e8f7951` on
`be32f3b`), the corrected brief, and `workbench-halt-discharge-stop12.md` at the workspace root.
Author of the work: Claude Opus 5 (claude-opus-5), 2026-09-07 evening. **Neither branch is
pushed** (`git ls-remote` returns nothing for either), both trees clean before this file.

Read-only except for this file. No model call. Nothing under review edited.

---

## Verdict

**The halt is discharged.** §3.2 is fixed the way pass 18 said it should be, covered by a case
that fails against the stripped runner with the registered `exit 0`, and the copilot run that
raised the halt is now refused with a message that no longer names a path that does not exist.
Every number the discharge document registers reproduces. The one thing that did not reproduce
on the first attempt was environmental, is diagnosed below, and is new to §4.

Two things Opus did not report, neither of which reopens the halt: the decision-8 probe ran
without user-settings isolation, so its environment is not the batch environment on one
variable; and the probe's evidence lives only in the observatory database and `TMPDIR`, not in
the repository.

---

## The discharge document's claims, each checked against the thing rather than the sentence

### §1 of the brief, as re-registered

| # | Registered | Observed | Same? |
|---|---|---|---|
| 1.1 | `13 passed, 0 failed, of 13` | first run **`12 passed, 1 failed`** — M `got exit 1`, output `could not determine the version of 'copilot'`; with `NODE_OPTIONS` unset, `13 passed, 0 failed, of 13 registered cases` | yes, once the environment is fixed — see *the trap* |
| 1.2 | `15 passed, 0 failed, of 15` | `verify-phase-contract-checker: 15 passed, 0 failed, of 15 registered cases`, both `NEG` lines `ok` | yes |
| 1.3 | `tracked … 1 of 1`, exit 0 | that line, `customization checks passed`, exit 0 | yes |
| 1.4 | silent, exit 0 | silent, exit 0 | yes |
| 1.5 | `9` | `9` | yes |

### §2 of the brief, as re-registered

**2.1**, stripped copy beside linked `lib/` and `schemas/`, anchor `# CORRECTED 2026-09-07`, 61
lines removed. With `NODE_OPTIONS` unset:

```
  FAIL — J: expected exit 1 naming the foreign file, got exit 0: …
  FAIL — K: expected exit 0 naming the inert directory, got exit 0: …
  FAIL — L: expected exit 1 saying codex reads no agent directory, got exit 1: …
  FAIL — M: expected exit 1 refusing the copilot overlay, got exit 0: …
verify-agent-delivery: 9 passed, 4 failed, of 13 registered cases
```

**Registered `9 passed, 4 failed`, J and M both `got exit 0`: reproduced.** Before the
environment fix M came back `got exit 1` from the version check, which is the case failing for
a reason that has nothing to do with the guard — exactly what the brief's own §2.1 warns of.

**2.2**, `CHECKER_UNDER_TEST=./tools/naive-phase-checker.py`:

```
  ok   — A: a clean phased run passes (exit 0)
  FAIL — B: expected exit 2 naming VERIFICATION, got 2: naive: FAIL (5 of 6 markers) missing: VERIFICATION
  FAIL — C: expected exit 2 on code-order, got 0: naive: PASS (6 of 6 markers)
  FAIL — D: … got 0: naive: PASS (6 of 6 markers)
  FAIL — E: … got 0: naive: PASS (6 of 6 markers)
  FAIL — F: … got 0: naive: PASS (6 of 6 markers)
  FAIL — G: … got 0: naive: PASS (6 of 6 markers)
  FAIL — H: expected exit 3, got 2: naive: FAIL (0 of 6 markers) …
  ok   — I: a non-JSON file is UNUSABLE (exit 3), not a failed run
  FAIL — J: … got 0: naive: PASS (6 of 6 markers)
  FAIL — K: … got 0: naive: PASS (6 of 6 markers)
  FAIL — L: expected exit 2 naming the write shapes, got 0: naive: PASS (6 of 6 markers)
  FAIL — M: expected exit 0 reporting pre-DESIGN write shapes, got 0: naive: PASS (6 of 6 markers)
verify-phase-contract-checker: 2 passed, 11 failed, of 13 registered cases
```

**Registered `2 passed, 11 failed, of 13`, C verbatim: reproduced.** And the control is now a
file, so the number can be reproduced by anyone; pass 18's 2.2 finding is closed.

### §3.2 — the fix, read and run

`a7fc212` moves `copilot` to the `*)` branch with `NATIVE_AGENT_GLOB=''` and both directories
foreign, keeps the reasoning and the attribution in a comment above the `case`, and adds case M.
The copilot run that raised the halt, re-run today against the fixed runner:

```
run-agent: customization installs agent files at '.github/agents/*.md', which runtime
    'copilot' does not read. …
    copilot reads no agent directory at all — it has no named-agent flag
    here, so nothing could dispatch these files even if they were installed at another path.
    Run this overlay on claude, which does, or drop the agent files from it.
exit 1
```

Refused, exit 1, and the second defect Opus found while fixing — the old message told the
operator to *port the files to that path* on a runtime with no such path — is gone: the message
branches on whether a native path exists. **Correct by the guard's own rule**: an arm with no
delivery proof is refused, not admitted on a guess. The original block is not preserved in the
code; the discharge says so and says why (*wrong rather than superseded*), and the original is
in `52924a8`'s history, which is checkable.

### §3.1 — decided as pass 18's middle path, and the decision is asserted by fixtures

`e8f7951` keeps `Bash` out of `MUTATING`, carries `input.command` into the event stream, reports
`bash_write_shape_calls` / `bash_write_shape_before_design` as facts, corrects the false
*nothing was implemented* message, and registers L (Bash-only run refused, message true) and M
(mixed run **passes**, write shapes printed, *this case is the one that must flip*). Pass 18's
twelve fixtures re-run against the corrected checker: every verdict unchanged; `31a` now reads
`2 Bash call(s) carrying a write shape ran BEFORE the DESIGN marker`; `31b`/`31c` still PASS
with the count beside the verdict. The `35c` and `35d` edges and `x1` (DONE without `Not done`)
still behave as pass 18 recorded, and the discharge lists 35c/35d as recorded-not-acted-on,
which is accurate.

### §3.3 — the probe ran, and the coupling did not materialise

Three runs under `EXP-P12-PREFLIGHT-INITTOOLS`, BE-004, variant `phases-v1.0`, model
`claude-haiku-4-5-20251001`, Claude Code `2.1.263`, exit 0, all three in the observatory
(`GET /api/runs/<id>` answers), kept logs on disk, and each `system`/`init` record reads:

```
init.tools = ['Read', 'Edit', 'Write', 'Bash']
```

**Delivered verbatim, 3 of 3, as the discharge table says.** `Edit` and `Write` reach the model;
pass 18's *single finding most likely to matter* is off the table, as Opus wrote.

**What the discharge does not say.** The same init records list **41 agents** — the overlay's
`backend-feature-phases`, the five built-ins, and 35 from this machine's user-level plugins
(`gsd-*` ×34, `superpowers:code-reviewer`). The E-008 control record on the same machine lists
**5**. So the probe ran **without `ISOLATE_USER_SETTINGS=1`**, which every fourth-cell batch
sets. The `tools:` read-back almost certainly does not depend on that variable, but decision 8's
wording is *through the runner with the runner's own flags*, and the batch that will inherit
this reading runs isolated. The reading is admissible; the environment is not the batch's on one
variable, and that should be written next to the table rather than discovered by the next
validator. Three more runs, isolated, would close it; that is a model call and the author's.

**And the evidence is not in the repository.** No file in either repo names the three run ids or
the key; the discharge document at the workspace root is untracked, and the init records exist
only in `TMPDIR` and the observatory database, both of which this project has already lost data
from. `evidence/b04/init-schema/` is the precedent for filing such records. Filing three text
files is not opening stop 12.

### §3.4 — the split count, and the finding preserved

The checker docstring strikes the single count with `~~…~~`, attributes pass 18, and explains the
units. `9043f824` today: `delegating calls 1, delegated events 36`. The manifest's `1` and the
checker's `1` now agree in the same unit. Kept.

### Corrections in place — struck, not deleted

| where | original kept? | attribution |
|---|---|---|
| brief §2.2 instruction and `1 passed, 10 failed` | struck with `~~` | Opus, pass 18 §2.2 |
| brief §3.1 sentence | struck with `~~` | Opus, pass 18 §3.1 |
| brief §2.1 recipe (`/tmp/` loses `lib/`) | original recipe kept, correction block beneath | Opus, pass 18 |
| brief §2.1 registered split | old `9 passed, 3 failed` kept in a parenthetical | Opus |
| `check-phase-contract.py` check 5 | struck with `~~` in the docstring | Opus, pass 18 §3.4 |
| `be32f3b` commit message (`10 of 11`) | **left uncorrected, on purpose**, corrected in `e8f7951`'s message and the discharge | Opus |

All six as §7 requires. Two stale crumbs, neither a correction: the brief's §6 still says *the
12 cases* (line 269), and its §3.2 body is unchanged with only the table row saying *+ halt fix*.

### Things Opus said it did not touch

- `TRACK-B-STATE.md`: last commit `08d22ab` 16:13, mtime 16:14, both before any of this work. Untouched.
- `HANDOFF.md`: last commit `f1f7c34` 16:05. Untouched.
- Pass 18's findings file: committed at `69f0bfd` with 344 `+` lines and no added text — *not my
  file and not my words*, as its commit message says. Verified unaltered.
- Stop 12: no experiment, prediction or state change on either branch. The `stop12/` branch name
  and the overlay's status under the track's §6 remain the author's call, as pass 18 recorded.

---

## The trap — new to §4

`copilot --version` crashes on this machine today with
`Cannot find module …/T/cmux-claude-node-options/restore-node-options.cjs`: the terminal host
(cmux) exports `NODE_OPTIONS=--require=<that file> …`, the file is gone, and every Node CLI
started from this shell dies in preload. `claude` is a native binary and does not care;
`copilot` is Node and does. The runner strips cmux's PATH shims and sets its hook off-switches
but does not touch `NODE_OPTIONS`, so its version check — correctly — refused to record a run
with a placeholder version, and case M reported `got exit 1` for a reason unrelated to the guard.
`env -u NODE_OPTIONS` fixes it. **This is the fourth §4 trap that reads as the instrument failing
while the environment is broken**, and it belongs in the brief's list and in the runner's
environment-constancy notes. Whether the runner should strip `NODE_OPTIONS` itself is the
author's call: it is a host artefact, but so were the shims.

---

## Not checked

- Whether the three probe runs' `init.tools` would differ under `ISOLATE_USER_SETTINGS=1`.
  Model call.
- Whether the `phase-contract` job fires on GitHub, and whether the author changes branch
  protection (pass 18 §3.8). Needs a push.
- A–I and L on the stripped runner, beyond their pass lines.
- The `WRITE_SHAPES` regexes against real batch streams — `9043f824` has 15 `Bash` calls and the
  checker reports them as facts, but no one has read which of them matched and whether `2>&1`
  or `grep … > /tmp/x` is the usual false match. Cheap; not done.
- `agent-learning-lab/1` — a 36 KB file named `1`, the second-scorer prompt, committed at
  `5f1b83d` (stop 11 step 7a), which looks like a `> 1` redirect accident. Pre-existing on
  `main`, outside this pass; named so it is not lost.

## Corrections made in place

None.

## Resolution

Push both branches and open the two PRs; nothing in the halt remains open. Before stop 12's first
batch: file the three probe init records under `evidence/`, and either re-run the probe isolated
or write next to the table that it was not. Add the `NODE_OPTIONS` trap to §4. The residual hole
(case M of the phase verifier) and the merge-gate finding (§3.8) are recorded and are decisions,
not defects.
