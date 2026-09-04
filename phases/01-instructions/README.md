# Phase 1 — Custom instructions

**Guardrail layer: L3 — guidance only, not a boundary** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** ✅ Measured — `EXP-BE002-CLAUDEMD-V2` and `EXP-BE002-NOHOOKS`, both 10+10, both
non-void · **Verdict:** `INCONCLUSIVE` by the registered rule

> The three blockers that invalidated the first attempt are resolved: **#36** (the treatment
> now loads and is hash-asserted per run), **bug #7 / #47** (environmental stops classified
> by class, not phrase), and the isolation half of **#35** (`--isolate-user-settings`, 0 hook
> executions). What remains open on #35 is persisting the *resolved* model id; the id itself
> was checked across all 20 runs and did not drift.
>
> **The write-up below still describes the invalidated attempt.** Bringing it up to date is
> this phase's work, not a status line — see `agent-observatory` PR #46 for the result.

## Goal

Learn when always-loaded guidance helps, and when it wastes context or contradicts itself.

## Verified reading

- [ ] ✅ [Copilot — Custom instructions support matrix](https://docs.github.com/en/copilot/reference/custom-instructions-support)
      — **the authority.** Which file works on which surface
- [ ] ✅ [Copilot — Customization cheat sheet](https://docs.github.com/en/copilot/reference/customization-cheat-sheet)
- [ ] ✅ [Copilot CLI — Add custom instructions](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)
- [ ] ↪️ [Codex — AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
      — hierarchical discovery; **verify precedence from the live page**
- [ ] ✅ [Claude Code — Memory & instructions](https://code.claude.com/docs/en/memory)
- [ ] ✅ **[Claude Code — the `#agentsmd` section](https://code.claude.com/docs/en/memory#agentsmd)**
      — read this one twice. It is the fact that invalidated our experiment

## The file landscape

| Runtime | Reads |
|---|---|
| Copilot | `.github/copilot-instructions.md`, `.github/instructions/**/*.instructions.md`, `AGENTS.md` |
| Codex | `AGENTS.md`, hierarchical, project + user level |
| Claude Code | **`CLAUDE.md`** · imports `AGENTS.md` only via `@AGENTS.md` · `.claude/rules/` for modular rules · `paths` frontmatter for path scoping |

Concise instructions are explicitly recommended. This is not style advice — see Lab 1.3.

---

## Extract

From the Copilot custom-instructions support matrix, read 2026-08-09.

### The seven file types

```
.github/copilot-instructions.md              repository-wide
.github/instructions/**/*.instructions.md    path-specific
AGENTS.md
CLAUDE.md
GEMINI.md
~/.copilot/copilot-instructions.md           personal, CLI only
~/.copilot/instructions/**/*.instructions.md personal path-specific, CLI only
```

On GitHub.com and JetBrains, personal instructions live in **account settings**, not files.

### Support by surface

| File | GitHub.com | VS Code | Visual Studio | JetBrains | Eclipse | Xcode | **Copilot CLI** |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `copilot-instructions.md` | ✓ all | ✓ all | ✓ all | ✓ all | ✓ all | ✓ all | **✓** |
| `*.instructions.md` | ✓ agent, review | ✓ chat, agent | ✓ chat | ✓ all | ✓ agent | ✓ all | **✓** |
| `AGENTS.md` | ✓ review | ✓ chat, agent | **—** | ✓ agent | ✓ agent | ✓ agent | **✓** |
| `CLAUDE.md` | ✓ agent | ✓ agent | **—** | ✓ agent | ✓ agent | ✓ agent | **✓** |
| `GEMINI.md` | ✓ agent | ✓ agent | **—** | ✓ agent | ✓ agent | ✓ agent | **✓** |

### Two things worth stopping on

**1. Copilot CLI reads `CLAUDE.md`.** Every file type, every column, ✓ for the CLI.

That is a design opportunity this project has not used. A single `CLAUDE.md` is read natively
by **both** Claude Code and Copilot CLI — which means a cross-runtime instruction experiment
can hold the *file* constant instead of maintaining two adapters and hoping they are
equivalent. `agent-observatory` #36 has been treated as "port `AGENTS.md` to `CLAUDE.md` for
Claude"; the matrix says `CLAUDE.md` is the portable choice, not the Claude-specific one.

**2. Visual Studio supports none of `AGENTS.md`, `CLAUDE.md` or `GEMINI.md`.** Only the two
`copilot-*` forms. If a team standardises on `AGENTS.md`, Visual Studio users silently get
nothing — no error, no warning. That is the "why didn't my file load" failure the feature
matrix exists to prevent.

### The gap in the documentation itself

> The page contains **no statement about precedence, ordering, or how multiple instruction
> files combine**, and **no nesting or hierarchy rules**.

Verified by reading it. That is a real hole, not an oversight in this extract.

Compare Claude Code, which documents precedence explicitly — managed policy → user →
project → local, concatenated root-down, `CLAUDE.local.md` appended last. For Copilot you
would have to **measure** it.

> **That is a lab.** Put contradictory rules in `copilot-instructions.md` and `AGENTS.md`, run
> the benchmark, and see which one wins. Undocumented precedence is exactly the kind of thing
> an instrument like yours exists to establish.

---

## Predict before you run

1. Does adding one verification rule raise or lower token count? By how much?
2. Will the rule be followed **every** time, or some fraction?
3. Will any agent *claim* tests passed without running them?
4. What is the smallest instruction file that changes measured behavior?

## Lab 1.1 — One measurable instruction

Do not begin with a 150-line standards file. Add **one** rule that your benchmark
previously violated in at least some runs.

```markdown
# Repository rules

- After changing Kotlin production code, run the relevant Maven tests before
  declaring the task complete.
```

Run 5 repetitions. Compare B0 vs B1.

## Lab 1.2 — Path-scoped instruction

```markdown
---
applyTo: "**/*.kt"
---
- Prefer constructor injection.
- Do not use `!!`.
```

Create one Kotlin task and one Markdown-only task. The Kotlin task should receive the rule;
the unrelated one should not pay the same cost — **where the surface supports scoped
loading.** Check the support matrix before concluding the agent ignored you.

## Lab 1.3 — Bloated-instructions failure

An intentionally bad branch: repeated rules, irrelevant framework docs, contradictory
rules, examples copied wholesale. Run the benchmark. Measure tokens, rule adherence,
completion, mistakes. Then revert.

This teaches **context economics** better than any lecture.

## Exit gate

**ANSWERED 2026-09-03.** `Answered by Opus 5 (claude-opus-5), autonomous, 2026-09-03` from the
two measured experiments and from B2's result. **No new runs were taken.** Three of six are
answered from measurement; three are answered *"not measured"*, with what each would need —
which is an answer, and is not the same as a tick.

- [x] **What deserves always-on context?** — **Less than this phase assumed, and nothing has
      yet earned it here.** The only clean instruction comparison, `EXP-BE002-AGENTSMD-V3` at
      10 + 10, returned `INCONCLUSIVE`: every metric moved the same way and none cleared the
      24 % bar registered before the treatment arm existed. B2 then removed a candidate
      outright — its prediction 4 said a plain agent would miss an L3 prose convention and was
      **refuted 0-of-14**. A rule the agent already follows unprompted deserves no always-on
      context, so **B3's candidate list must be filtered against B2's measured behaviour before
      any of it is written**, not against the plausible-sounding list in `build/README.md#b3`.
- [x] **Why is an instruction not enforcement?** — Because nothing executes it, which is
      `GUARDRAILS.md`'s L3. **And this phase can now say the sharper thing:** *not enforcement*
      does not mean *no effect*. B2's prediction 4 and E-001's prediction 3b both put an L3
      instruction under test and both found it honoured — six of six for Decision A's null
      precondition, fourteen of fourteen for the `ApiError.kt` KDoc convention. **The layer
      model predicts what a control guarantees, not what a model will do.** An instruction is
      not a boundary; it is also not inert, and B3's entire treatment lives in that gap.
- [x] **Can I prove the instruction entered the model's context on a given run?** — **YES, and
      this is the item the phase added because it had failed it.** Read off the run records, not
      off a flag: `customization.instructionsHash` is `sha256:13a7b6afb4d4b07312035d72a21c3049`
      on **all 39 treatment runs** across `AGENTSMD-V3` (10), `CLAUDEMD-V2` (18) and
      `CLAUDEMD` (11), and **`null` on all 40 control runs of those three keys**. Perfect
      separation, zero exceptions. *(Corrected 2026-09-04 from "48" — see the amendment at the
      end of this file. The separation claim is unchanged; the denominator was wrong.)* `agent-observatory` **#36 is closed** and its closure is **L2** — the field is
      written by the runner and readable per run.

      The failure that motivated the question is worth restating: the original treatment placed
      `AGENTS.md` in the repository while Claude Code reads `CLAUDE.md`. Roughly $4 and twenty
      runs compared *file present* with *file absent*.
- [ ] **What belongs in a skill instead?** — **NOT MEASURED.** Phase 3 owns it and has not run.
      The documented distinction is in *The seven file types* above; nothing on record
      separates "always-on rule" from "situational knowledge" by measurement. Needs one
      experiment holding content constant and moving only the delivery surface — the same shape
      as the `AGENTSMD` / `CLAUDEMD` pair, which is why the shared `instructionsHash` above is
      a useful precedent rather than a curiosity.
- [ ] **What is path-scoped?** — **NOT MEASURED.** Lab 1.2 was never run. The support matrix in
      *Support by surface* is read, not tested, and the phase's own warning applies: check the
      matrix before concluding an agent ignored you.
- [ ] **Which Copilot surfaces actually support `AGENTS.md`?** — **NOT MEASURED, and blocked by
      Decision G.** The Copilot arm does not exist; `copilot --model gpt-5.4-mini` returns
      `You have no quota`, and the premium counter gates the CLI regardless of model. Any claim
      about a Copilot-run agent must be refused until that arm exists.

**The phase result is unchanged: `INCONCLUSIVE` on `n=10+10`.** Answering the gate does not
promote it. What changed is that the gate's hardest question now has an L2 answer, and the
phase's failure is fully characterised rather than merely regretted.

**One stale reference, corrected:** the *Commit* block below names
`experiments/B1-instructions.md`. No such file exists and none was written; the two measured
results live in the observatory under `EXP-BE002-AGENTSMD-V3` and `EXP-BE002-CLAUDEMD-V2`.

## Commit

```
AGENTS.md · .github/copilot-instructions.md
.github/instructions/kotlin.instructions.md · CLAUDE.md
experiments/B1-instructions.md
```

---

## What we got wrong here

### We measured a file sitting on disk

`EXP-BE002-AGENTSMD-V3` ran a clean 10 + 10 and concluded `INCONCLUSIVE`:

| | B0 baseline | B1 instructions |
|---|---:|---:|
| median cost *(primary)* | $0.1897 | $0.1654 (−12.8%, p=0.04) |
| median tool calls | 19 | 15 |
| pass rate | 80% | 100% |

Every metric moved the same way, and none of it cleared the 24% bar registered before the
B1 arm existed. Then the audit found it: **the treatment was placing `AGENTS.md` in the
repository, and Claude Code reads `CLAUDE.md`.** No `@AGENTS.md` import, no
`--append-system-prompt-file`. Roughly $4 and twenty runs comparing "file present" with
"file absent".

The result is not wrong so much as **not about instructions**.

> **Assert that the independent variable reached the agent.** Not that you wrote it — that
> it arrived. A preflight check that fails loudly costs one assertion and would have caught
> this before the first run.

Deliver the treatment through a mechanism the runtime documents, hash the content, record
the hash as part of the treatment, and run the control through the same isolated harness
with the treatment absent. Tracked as `agent-observatory` **#36**.

### One prediction was specific, mechanistic, and wrong

We predicted BE-001's `jakarta.validation` convention would push the agent off BE-002's
error envelope and produce contract failures (F02). **Zero F02 in either arm.** We also
predicted cost would rise; it fell, and so did cache creation.

One of four predictions held. That is the value of writing them down — an unrecorded
prediction is always retroactively correct.

### The environment was never controlled

Those runs loaded ~21 hooks, 2 plugins and 3–4 MCP connections from the local user
environment, **varying between runs**, while the protocol claimed only the treatment
varied. Tracked as **#35**. Use `--setting-sources project` and pin exact model IDs —
**not `--bare`**, which would also switch off the `CLAUDE.md` this phase is measuring.

## Validation

*Added 2026-09-04. The §5 table the run prompt requires was never written for this stop; the
exit gate above was answered, and the four-column table was not. Flagged by
[`findings/track-b-validation-2026-09-04.md`](../../findings/track-b-validation-2026-09-04.md)
and supplied here. No gate answer changed — this table records the proofs that were already
behind them, and labels each one honestly.*

| Gate clause (verbatim) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| "What deserves always-on context?" | `EXP-BE002-AGENTSMD-V3` (10+10), `EXP-BE002-CLAUDEMD-V2` (18+18), `EXP-BE002-CLAUDEMD` (11+12) in `GET /api/runs`; and the 14-of-14 `ApiError.kt` KDoc census in B2 | **L3** — the answer is a judgement read off measurements, and nothing executes it. The *measurements* are L2; the sentence "less than this phase assumed" is not | `curl $API/api/runs`, group by `experimentKey`, compare the arms |
| "Why is an instruction not enforcement?" | `GUARDRAILS.md` layer model; and B3's later `REJECT` on 25 runs (`experiments/E-003-instructions-v0.1.md`) | **L3** — prose a human reads. It is the definition of L3, so it cannot be proved at a higher layer than L3 without contradiction | read `GUARDRAILS.md`, then E-003's outcome table |
| "Can I prove the instruction entered the model's context on a given run?" | `customization.instructionsHash` = `sha256:13a7b6afb4d4b07312035d72a21c3049` on **39** runs, `null` on **40**, across the three named keys. Re-derived 2026-09-04 against the live API: AGENTSMD-V3 10/10, CLAUDEMD-V2 18/18, CLAUDEMD 11/12 — **39 hash / 40 null, zero exceptions** | **SPLIT, corrected 2026-09-04 — see note † below.** **L2** for *the file was present under the name the runtime reads and its digest was recorded*: the runner writes the field per run and `die`s on a foreign filename, and that refusal executes. **L3** for *the instruction entered the model's context*, which is what the clause actually asks — nothing executes that | `curl $API/api/runs`, filter the three keys, tally `customization.instructionsHash` non-null vs null |
| "What belongs in a skill instead?" | none — **NOT MEASURED** | **L3, and the honest label is "no proof"** — Phase 3 owns it and has not run | nothing to re-derive; the row is open |
| "What is path-scoped?" | none — **NOT MEASURED**, Lab 1.2 never ran | **L3, no proof** | nothing to re-derive; the row is open |
| "Which Copilot surfaces actually support `AGENTS.md`?" | none — **NOT MEASURED, blocked by Decision G** | **L3, no proof**, and it must stay that way: no claim about a Copilot-run agent is permitted until that arm exists | nothing to re-derive; the row is blocked, not merely open |

**† AMENDMENT 2026-09-04 — the context row was L2 on the strength of a refusal that covers a
narrower case than the clause.** Raised by `findings/track-b-validation-2026-09-04-8.md`
correction 5.1 and confirmed independently by `-9.md` on a different model. The row justified its
L2 with *"the runner refuses a customization whose instruction file the runtime does not read."*
That refusal is real and I read it — `agent-observatory/runner/run-agent.sh:358–368` calls `die`
— but **it fires only when a *foreign* filename is present and the runtime's own is absent**
(`AGENTS.md` installed for a `claude` run). Nothing executes that checks the correctly-named file
was ever read. Apply the rule in order: can *"the file sat at the right path and the model never
took it in"* still be written down? Yes. Does something execute and reject it? No. So the context
half is **L3**.

E-003 states this correctly and this table did not carry it forward: *"The runner now refuses a
customization whose instruction file the runtime does not read, which makes the **filename** half
of that failure L2. The content half is still this table's job."* The hash claim keeps its L2 and
loses nothing; what it proves is bytes-at-a-path, which is real and is not the same as delivery.
**This bears on B3's null at stop 6, not on this phase's `INCONCLUSIVE`** — see that workbook.

`Amended by Opus 5 (claude-opus-5), autonomous, 2026-09-04`

**Three of six rows have no proof at any layer, and that is the phase's result.** `INCONCLUSIVE`
on `n = 10+10` is not a hedge; it is what three unmeasured gate items and one measured null add
up to.

**Independence check.** No run was launched at this stop — it read results that already
existed. The three experiment keys predate it, the rubric was untouched, and `runtime.model` is
`claude-haiku-4-5-20251001` throughout.

## Amendment — 2026-09-04, from the §9 validator

Verdict: **CONFIRMED WITH CORRECTIONS.** Three corrections, all applied:

**(a) "all 48 control runs" does not reproduce; the number is 40.** The three keys this workbook
names hold 10 + 12 + 18 = 40 controls, not 48. Re-derived against the live API on 2026-09-04 and
confirmed: **39 hash / 40 null.** The separation claim — perfect, zero exceptions — is
**unchanged and still true**; only the denominator was wrong. Corrected in place above.

**(b) No §5 validation table existed.** Supplied above. Writing it forced the honest labelling of
three gate rows as having **no proof at any layer**, which the prose had softened to "NOT
MEASURED" without saying what that costs the closure.

**(c) The PR was cited as `lab#49`, which does not exist.** This stop shipped in **lab#53**,
merged 2026-09-03T19:07:36Z as `27d67e5`. Corrected in `findings/track-b-2026-09-03.md`.

## Before re-running

1. **#36** — deliver the treatment through `CLAUDE.md` + `@AGENTS.md` or
   `--append-system-prompt-file`; assert it loaded
2. **#35** — `--setting-sources project`, pinned model IDs, environment fingerprint, fail
   analysis on drift
3. **bug #7** — non-interactive build, and permission-blocked runs classified as
   infrastructure (F13/F15), not incorrect code
4. Preregister `EXP-BE002-INSTRUCTIONS-V4`, 10 + 10, **commit the registration before the
   first run** — check the timestamps, we got this wrong once too
5. Budget ~$4.10
