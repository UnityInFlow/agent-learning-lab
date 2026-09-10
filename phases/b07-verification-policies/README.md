# B7 — Deterministic verification and policies

**Track A first:** [Phase 5A](../05a-guardrails/) · **Layer 2 — real enforcement**
**Version:** **v1.0 closes here**
**Spine position:** 15 of 28 · after [Phase 5A](../05a-guardrails/) · before [Phase 5B](../05b-verification-selfhealing/)
**Status:** 🟡 open — spine stop 15, opened 2026-09-10, branch `stop15/b7-verification-policies`

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b7).
> Everything else is yours to fill.

---

## Goal

Give the agent **one verification command with a machine-readable result**, and turn v1.0's
`Boundaries` block — which `phases-v1.0` itself calls *"prose and nothing executes them"* — into
something that **executes and refuses**.

This is the first B step whose deliverable is a Layer 2 control. B3 was a file the model read
(L3, and it moved nothing, `E-003` REJECT). B4 and B5 were an agent file and a phase procedure —
both prose, both delivered through the agent frontmatter, and the only executing thing in either
was `tools:`, which stop 9 measured as a **name filter, not a capability filter**. B6's skill was
prose too. So after four build steps, **the only line in v1.0 that runs is a tool allowlist**.

B7 is where that changes, and stop 14 has already made the job harder than the spine assumed:

- **Something already refuses**, and it is not ours. Under `--permission-mode acceptEdits` with
  `-p`, Claude Code's own approval gate refused **12–20 Bash commands per run** in Lab 5A.1, and it
  fires **before** any OS-level or policy-level control. A policy of ours that "holds" may simply
  never have been reached. Every clause of this step's gate has to be written so that it can tell
  those two apart.
- **Hooks fail open.** Phase 5A's extract: any exit code other than `2` is a *non-blocking error —
  the action proceeds*, and `preToolUse` timeouts fail open, including policy hooks. A denylist
  hook with a typo in it is a denylist hook that allows everything, silently.

So the goal is not "write four policy files". It is: **name what the boundary actually is, make one
thing execute, and measure what it stops that was not already being stopped.**

## Required reading

### Internal — the requirement

Read 2026-09-10, all in
[`businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md`](../../businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md).

| Section | What it asks for | Line |
|---|---|---|
| **§10.11 `.ai/scripts/verify.sh`** | *"One deterministic verification entry point"* — may run compilation, unit tests, integration tests, formatting, static analysis, architecture tests, forbidden-change checks. **Measure:** exit code, duration, failing stage, retry count | 529 |
| **§10.10 `.ai/policies/*.yaml`** | protected paths · allowed dependencies · database migration rules · shell command policy. *"Only after a concrete enforcement requirement appears."* | 512 |
| **FR-006** | *"one verification command with a machine-readable success/failure result"* | 663 |
| **FR-012** | *"Critical boundaries should be enforceable through scripts, hooks, protected paths, or command restrictions"* | 687 |
| **FR-014** | *"Every new agent version must be explicitly promoted, modified, or rejected"* — v1.0's promotion decision is due at this stop | 693 |

Two of those sentences decide this step's design and both are easy to read past:

- §10.10's *"only after a concrete enforcement requirement appears"* is a **refusal instruction**. It
  says: do not write four policy files because the build spec lists four filenames. Write the one
  whose violation has been observed.
- §10.11's **"Measure: … failing stage, and retry count"** is the part that makes `verify.sh`
  different from `./mvnw test`. A wrapper that returns the same one bit the build already returns
  has added a filename, not an instrument.

### External — the technique

| Read | Source | What it settles for this step |
|---|---|---|
| ✅ 2026-08-09, extracted in [5A](../05a-guardrails/#extract) | [Claude Code — Hooks](https://code.claude.com/docs/en/hooks) | The exit-code model (`0` proceed · `2` block, stderr fed back to the model · **anything else: non-blocking error, the action proceeds**), per-event meaning of `2`, `updatedInput`, and the timeout table. Already in `SOURCES.md`; **not re-listed, so `check-links.sh` has nothing new to check at this step** |
| ✅ 2026-08-09, extracted in [5A](../05a-guardrails/#extract) | [Copilot — Hooks reference](https://docs.github.com/en/copilot/reference/hooks-reference) | `preToolUse` allow/deny and **timeouts fail open, including policy hooks** |

**ArchUnit and Maven Enforcer are not read, and that is a result rather than an omission** — see the
Extract.

## Extract

### 1. Four of `verify.sh`'s seven stages are unreachable on this benchmark, and the task forbids reaching them

§10.11 lists seven possible stages. Against `sample-service` at
`benchmarks eea144ef`, and under BE-003's own constraint *"Do not add new dependencies"* (BE-004
repeats it, and the evaluator **exits 20** on a new dependency):

| Stage | Reachable here? | Why |
|---|---|---|
| compilation | ✅ | `./mvnw test` compiles first |
| unit tests | ✅ | `./mvnw test` |
| integration tests | ✅ | same suite; the service has no separate IT profile |
| **formatting** | ❌ | no formatter plugin is configured in `pom.xml`; adding one is a new dependency |
| **static analysis** | ❌ | same |
| **architecture tests** | ❌ | **ArchUnit is a test dependency.** Adding it is exactly the failure the evaluator scores as `20` |
| forbidden-change check | ✅ | `git diff --name-only` against the baseline sha — no dependency at all |

So on this benchmark `verify.sh` is **`./mvnw test` plus a git-based scope check**, and the reason
the other four are missing is that *the agent adding the tooling to run them would fail the task*.
That is worth stating plainly: **the build spec's verification stack and the benchmark's "no new
dependencies" constraint are in direct conflict**, and the benchmark wins because it is the thing
being measured. ArchUnit and Maven Enforcer were therefore not read: there is no run in this track
that could use them, and a source in `SOURCES.md` that no step can reach is a link to maintain
forever for nothing.

### 2. The exit-code model means a policy hook's *failure mode is that the action happens*

From Phase 5A's extract, verbatim from the Claude Code hooks reference:

| Exit | Effect |
|---|---:|
| **0** | stdout parsed as JSON. Action proceeds unless the JSON carries a blocking decision |
| **2** | **Blocking.** stderr is fed back to Claude as an error message |
| anything else | **Non-blocking error. The action proceeds.** |

A `PreToolUse` policy hook is therefore **fail-open by construction**: a syntax error, a missing
interpreter, a `jq` that is not on `PATH`, or a timeout all produce "the action proceeds", and the
transcript carries a notice the model is not required to act on. **A guardrail whose failure mode
is silence cannot be trusted from the fact that nothing bad happened.** The only proof that a
policy held is a record of it *firing*, which is why this step's gate clause "policy events
recorded" is not bookkeeping — it is the difference between L2 and L3.

### 3. The strongest boundary in v1.0 is one nobody wrote, and it is upstream of everything B7 can build

Stop 14's Lab 5A.1 measured it: under `acceptEdits` with `-p`, **Claude Code's own approval gate
refused 12–20 Bash commands per run** — `This command requires approval`, 20 hits in one run — and
it held 10 of 10 across two arms whose OS-level controls were being tested. Arm P's *"0 of 5
changed"* would have read as *"the permission bit held"* when the permission bit was never
reached.

The runner makes this concrete and narrow. `agent-observatory/runner/run-agent.sh:759-761` passes:

```
--permission-mode acceptEdits
--allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
```

**Edits are auto-approved; Bash is pre-approved for `mvnw`/`mvn` and nothing else.** Two
consequences, and both are design constraints rather than observations:

1. **A `verify.sh` the agent is told to run would be refused before it ran.** `Bash(./verify.sh)`
   is not in the allowlist. Delivering the entry point as *a script the agent invokes* would
   measure the approval gate, not the entry point — the house failure mode, one stop after the lab
   that named it.
2. **A `command-policy.yaml` forbidding dangerous shell commands has almost nothing left to
   forbid**, because `Bash(mvn:*)` is already an allowlist and everything outside it already needs
   approval. Writing that policy file would produce a control that has never been shown to reject
   anything — which `build/README.md` and §5 both name as indistinguishable from one that rejects
   nothing.

**What is left for B7 to actually control** is the channel the runtime leaves wide open: **`Edit`
and `Write` are auto-approved under `acceptEdits`**, unconditionally, to any path in the worktree.
That is where v1.0's prose boundaries live — *"a change to a build file, a lockfile, a CI file, a
Dockerfile … is out of scope by definition"* — and it is where the evaluator's own exit codes
already say a violation is a failure (`20` new dependency, `21` unrelated production files). So
`protected-paths` is the policy with a **concrete enforcement requirement** in §10.10's sense, and
the other three are not.

### 4. There is no per-run delivery proof for a hook, and that is an instrument gap this step has to close

`run-agent.sh:625-629` records exactly three customization hashes — `instructionsHash`,
`skillsHash`, `agentHash`. **There is no `settingsHash` and no hook hash**, despite a comment at
`:146` that refers to one. A treatment delivered as `.claude/settings.json` would therefore have
**no hash in the run record**, and §4 step 5 requires proving the treatment reached the model and
did not reach the control.

Two candidate proofs, and the second is stronger:

- a `settingsHash` added to the runner (additive telemetry, an instrument PR under §4 step 14);
- **the hook's own execution in the stream** — a `PreToolUse` hook that fires leaves a record, and
  a policy event log written by the hook itself is a per-run artifact that exists only if the hook
  ran. A hash proves a *file was copied*; an event log proves *the thing executed*. This project has
  already paid for that distinction twice (`tools:` delivered as something other than what the file
  said, stop 9; the overlay force-add, B4).

### 5. What this step must not do

- **Not four policy files.** §10.10 says one enforcement requirement, one policy.
- **Not a `verify.sh` the agent is asked to run** — the allowlist refuses it, and measuring that
  refusal is measuring the harness.
- **Not a change to `--allowedTools` or `--permission-mode`.** Both are constant from B2 onward and
  the B2 baseline cannot be re-run; moving either is a §7 halt, not a design option.

## Design — and the two measurements that decided it

Both were taken **before** anything was designed and before any prediction was written, because
each one could have made the obvious design wrong.

### The census: on this corpus, the enforcement requirement §10.10 asks for has not appeared

[`evidence/b07/violation-census-20260910.md`](../../evidence/b07/violation-census-20260910.md) —
every run the observatory holds, `GET /api/runs?limit=1000`, **499 runs**, evaluator
`evaluation.exitCode`:

| exit | meaning | all stored runs | **Track B corpus** |
|---:|---|---:|---:|
| 0 | all acceptance criteria passed | 438 | **305** |
| 10 | build failure | 0 | **0** |
| 11 | existing tests failed | 9 | **0** |
| 12 | functional acceptance failed | 49 | **20** |
| 13 | error contract violated | 0 | **0** |
| 20 | **new dependency introduced** | 0 | **0** |
| 21 | **unrelated production files changed** | 3 | **0** |
| 30 | evaluator/infrastructure failure | 0 | **0** |
| | total | 499 | **325** |

The Track B column is the 325 runs that share this step's model, tasks and harness. Read the rows
this step's build spec is aimed at:

- **`20` — new dependency: 0 of 499.** An `allowed-dependencies.yaml` would be a control that has
  never been shown to reject anything, on any run this project has ever made.
- **`21` — unrelated production files: 3 of 499, and 0 of 325.** All three are BE-002 work from
  before Track B.
- **`10` and `11` — build and existing tests: 0 of 325.** Which is to say: **`verify.sh`'s two
  strongest stages would have fired zero times.** The agent under test does not ship code that fails
  to compile, and it does not break the suite it was given.
- **`12` — functional acceptance: 20 of 325, and it is the only failure mode that occurs here.**
  It is decided by an **evaluator-owned** suite that does not exist in the worktree. **No
  verification entry point the agent or the overlay can run is able to detect it.**

So the honest statement of this step's position, with `n = 325`: **every failure class B7's build
spec is designed to catch has a measured incidence of zero, and the one failure class that does
occur is out of reach of the thing B7 is asked to build.** §10.10 says *"only after a concrete
enforcement requirement appears"*; on this corpus it has not appeared, and that sentence is the
reason three of the four named policy files are **not written** at this step rather than written and
left untested.

### The feasibility probe: an overlay *can* deliver something that executes and refuses

[`evidence/b07/hook-feasibility-20260910/`](../../evidence/b07/hook-feasibility-20260910/README.md)
— two probes under the runner's exact flag set, including `--setting-sources project`, whose whole
job is to keep the operator's ~21 hooks out. **It keeps project hooks in.** A `PreToolUse` hook
installed by the overlay fired; exiting `2` left `pom.xml` byte-unchanged on disk while `notes.txt`
was written normally; and the model reported *"Edit was blocked by a hook policy"* — so **stderr
reaches the model**, which is what makes a denial actionable rather than merely effective.

This had to be measured. If `--setting-sources project` had suppressed the overlay's own settings,
**B7 would have had no Layer 2 channel at all**, and the design would have been built on a guess in
the one place this project has been wrong most often.

### What gets built, and what deliberately does not

| Artifact | Layer, rule applied in order | Why that layer |
|---|---|---|
| `.claude/settings.json` + `.ai/hooks/policy-gate.sh` — `PreToolUse` on `Edit`/`Write`, denying paths listed in the policy | **L2** | Can the bad value still be written down after the fix? **Yes** — the path exists and the model may still attempt it. So not L1. Does something *execute* and reject it? **Yes, and it is named and proved**: the hook process, exit `2`, measured in probe 2 with the file unchanged afterwards |
| `.ai/policies/protected-paths.yaml` | **L3 on its own, L2 only through the hook that reads it** | A YAML file executes nothing. It is data. Its layer is borrowed from the thing that runs it, and if the hook stops reading it the file silently becomes a document — which is exactly the "schema note is L3" rule in the workspace `CLAUDE.md` |
| `.ai/scripts/verify.sh` — one entry point, one exit code, stage-structured JSON | **L2 as an instrument; L3 as a claim about the agent** | It executes and returns a machine-readable verdict, so as a check it is L2. But it changes nothing the agent does at this step (see below), so any sentence of the form *"the agent now verifies deterministically"* is L3 until B8 makes the verdict blocking |
| `tools/verify-policy-gate.sh`, `tools/verify-verify-sh.sh` — fixture sets | **L2** | They execute and they fail the build when a case regresses. Without them the two artifacts above are "ShellCheck clean with nine green fixtures", which this project has already shipped a blocking defect behind |
| `allowed-dependencies.yaml`, `command-policy.yaml`, `database-policy.yaml` | **not built** | 0 of 499, 0 of 499 (and Bash is already an allowlist), and the service has no migrations. §10.10's *"only after a concrete enforcement requirement appears"* |

**The trap this step converts.** `build/README.md#b7` states it as *"every hook you avoid writing is
a hook you never have to test, tune, or explain a false positive for."* That is a slogan until
something counts. The census is the counting, and it converts the trap at **L2**: the number
`0 of 325` is produced by a script over the store, not by a judgement, and it is what refuses three
of the four policy files.

### The one design decision that is mine, and it is reversible

**`verify.sh` is invoked by a `Stop` hook that RECORDS its verdict and does not block.**

Three things forced it and one bounded it:

1. **The agent cannot invoke it.** `run-agent.sh:761` pre-approves `Bash(./mvnw:*)` and
   `Bash(mvn:*)` and nothing else, so `./verify.sh` would be refused by Claude Code's own approval
   gate — the gate stop 14 measured refusing **12–20 Bash commands per run**. An arm built that way
   would measure the approval gate and report it as a verification result. That is the house failure
   mode, one stop after the lab that named it.
2. **Moving `--allowedTools` is not available.** It is constant from B2 on, the B2 baseline cannot
   be re-run, and §6 forbids moving a registered variable mid-experiment.
3. **A `Stop` hook needs no permission** — the runtime executes it — so it is the only route by
   which a deterministic verification command actually runs on every run.
4. **It does not block, and that boundary is deliberate.** A `Stop` hook exiting `2` would refuse
   completion until verification passes, which is a **completion contract with an unbounded repair
   loop**. The contract and the *limit* on that loop are B8's deliverable (`build/README.md#b8`), and
   §6 forbids creating a future step's artifacts early. Blocking it here would also confound B7's
   measurement with a repair loop, so the two questions would arrive fused.

**Consequence, stated plainly rather than buried:** at B7 `verify.sh` changes nothing the model sees.
The only artifact in this step that can move a number is the policy gate. Whether the recorded
verdict *should* become blocking is B8's first question, and this step is what hands it the data.

*Designed by Opus 5 (claude-opus-5), autonomous, 2026-09-10, from the census and the probe above.*

## Build

**Build:** one verification entry point, and policy as code.

```bash
scripts/verify.sh          # compile · unit · integration · format · static analysis
                           # architecture tests · forbidden-change check
                           # stage-structured output, machine-readable exit code
```

```yaml
policies/protected-paths.yaml       policies/command-policy.yaml
policies/allowed-dependencies.yaml  policies/database-policy.yaml
```

**Do 5A.1 first — remove a capability before policing it.** Every hook you avoid writing is a
hook you never have to test, tune, or explain a false positive for.

## Predict before you run

<!-- TODO: predict the false-positive rate on legitimate commands before
     you measure it. The gate requires the number either way. -->

## Lab B7.1 — measure against B6, and close v1.0 against B2

<!-- TODO: two comparisons here. The step comparison (vs B6) and the
     version comparison (v1.0 vs the B2 baseline) — the first thing in
     this project that answers the business question end to end. -->

## Deliberate failure

<!-- TODO: commit an intentional violation of each policy and prove the
     check catches it. A policy never tested against a violation is a
     policy you are trusting, not enforcing. -->

## Exit gate

**From the build track:** one command, one exit code · intentional violations tested ·
false-positive rate measured on legitimate commands · policy events recorded.

**Plus, for this to count as a learned phase:**

<!-- TODO: v1.0 vs B2 — state the result even if it is unfavourable.
     §17's promotion rules apply from here on. -->

## Commit

<!-- TODO -->
