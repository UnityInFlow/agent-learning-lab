# Track B validation, second pass — 2026-09-04

`Validated by Claude Fable 5.1 (claude-fable-5-1), section 9 of PROMPT-opus5-track-b.md,
2026-09-04, second run of the day.` Read-only; nothing outside this file was edited. Same
independence caveat as the first pass: this validator ran in the session that authored the
prompt. Every check below was made against files, git objects, the observatory API, the
telemetry file, the tools themselves, and one live reproduction in a scratch directory.

Inputs: `TRACK-B-STATE.md` (`status: blocked`, stop 8, loop step 5), `findings/track-b-2026-09-03.md`
(amended 2026-09-04), `findings/track-b-validation-2026-09-04.md` (first pass), PRs lab#55 and
lab#56 on `main`.

## Verdicts

| Stop | Verdict | Notes |
|---|---|---|
| 4 — B2 | **CONFIRMED** | first-pass corrections applied as dated, attributed amendments; nothing rewritten |
| 5 — Phase 1 | **CONFIRMED** | same; §5 table now exists; 48 → 40 corrected in place with a pointer |
| 6 — B3 | **CONFIRMED** | same; §5 table now exists |
| 7 — Phase 2 | **CONFIRMED** | same; DEFERRED count corrected |
| 8 — Phase 3 | **NOT CLOSED — and not claimed closed.** The **block is CONFIRMED** by independent reproduction, with four corrections | see below |

## Stops 4–7: were the first-pass corrections applied honestly?

PR lab#55 (`93ee5f7`, merged 2026-09-04T06:39:32Z) touched nine files. **It changed no file under
`experiments/`** — `git show 93ee5f7 -- experiments/` is empty, so no prediction or result moved.
In the four workbooks every removed line is a row that was corrected in place (two L2→L3
relabels in B2's table, the 48→40 denominator, the DEFERRED count), each with a dated pointer to
the first-pass file, and each workbook gained an `Amendment — 2026-09-04, from the §9 validator`
section naming the verdict and the corrections. `grep -c 'Layer of the'` now returns 1 in all
four workbooks (was 0 for Phase 1 and B3). The `lab#49` citations are gone from the report.

**Bookkeeping — corrected by the validator itself, same day.** An earlier draft of this
section said `validation_processed:` was empty. It is not: the field lists the first-pass
file with a one-line account of what was applied. The validator's grep had matched the key
line only and missed the list item beneath it. Withdrawn.

**One convention change, disclosed.** The review critic moved from `ollama-cloud/glm-5.2` to
`codex` (`-P codex`) after three consecutive failures. `opencode-review.sh`'s own header calls
both models registered variables; no experiment's numbers come from the critic, so this is a
control substitution and HANDOFF says so. Reviews before and after are not comparable and
nothing claims they are.

## Stop 8 — the block, checked against the instrument rather than the prose

The builder halted under §7 rather than change `agent-observatory-benchmarks/.gitignore` or the
runner. Its earlier halt at stop 6 rested on two premises that turned out to be unverified, so
each premise here was reproduced by this validator.

| Claim | Reproduced? | How |
|---|---|---|
| Root `.claude/skills/x/SKILL.md` is gitignored | **yes** | `git -C agent-observatory-benchmarks check-ignore -v .claude/skills/x/SKILL.md` → `.gitignore:19:.claude/*`, exit 0 |
| Nested `sample-service/.claude/skills/x/SKILL.md` is not | **yes** | same command on the nested path → exit 1. The pattern has an inner slash, so it is anchored to the repo root |
| The runner's setup commit fails when the overlay is entirely ignored | **yes, by reading the code** | `run-agent.sh` §5: `git add -A` then `commit … \|\| die "failed to commit the customization overlay"`. An all-ignored overlay stages nothing and `git commit` refuses. Run `16cd4378` is absent from the API, consistent with dying before persistence |
| Root skill registers; nested does not | **yes, by execution** | Scratch repo in this validator's scratchpad, same binary, `--setting-sources project --model claude-haiku-4-5-20251001 -p "/probe"`. Root: the reply quotes the body marker `BODY-MARKER-7F31`. Moved to `sub/.claude/skills/probe`: `Unknown command: /probe` |
| E-004 registered before the probe runs | **yes** | `5d14182` committer 2026-09-04T07:03:58Z; `c090f67e.startedAt` 07:08:59Z, `d8be2b5f.startedAt` 07:19:47Z, both `EXP-P3-PREFLIGHT`, evaluator exit 0, benchmark `0448643`, model pinned |
| Body of the two overlays byte-identical | **yes** | body-only `shasum` `d10a2c3988be520e` on both `SKILL.md` files |
| `verify-skill-activation.sh` passes | **yes** | `15 passed, 0 failed` |
| Absent run reads as UNKNOWN, not 0 | **yes** | fabricated id → `status: UNKNOWN-run-absent-from-telemetry`, every count `null`, exit 3 |
| Probe runs measured with zero activations of any source | **yes** | both ids → `status: measured`, all four source buckets 0, `activations_by_source: -` |
| No registered variable moved | **yes** | rubric `396e1799eb2b`, evaluator `1.0.0`, benchmark `0448643`, model `claude-haiku-4-5-20251001`; benchmarks repo untouched |

**Corrections.**

- **(a) The registered predictions were edited after registration.** `5d14182` is cited as the
  commit that registered E-004's predictions. The Predictions section on `main` differs from
  `5d14182`: prediction 2 was rewritten (from "project-scope … only the installed skill" to
  "installed-scope … every scope not installed is excluded", plus a paragraph saying it is not
  yet measurable), the delivery-mechanism row moved the overlay path from `.claude/skills/` to
  `sample-service/.claude/skills/`, and decision-table rows 1, 2, 4 and 5 were reworded. All of
  this happened **before any batch run**, under the gate's REJECTs, so no evidence was destroyed
  and no wrong prediction was revised. But the sentence "registered `5d14182` before any run"
  is no longer true of the text a reader sees. When the batch runs, §9 check 2 must cite the
  last pre-run edit (`5a14711` or later), and the original prediction 2 should stand as
  superseded text rather than be gone. The file's banner already says the design is unsound as
  it stands, which is the honest half; the citation is the stale half.
- **(b) The validation table and the probe evidence cite output the merged tool does not
  print.** `phases/03-skills/README.md` says the fabricated id returns
  `installed_scope_activations: null` and that run `899232bb` reads `installed_scope 0 / plugin
  2`; the review section says the outcome was "renamed `installed_scope`". The tool at `049e871`
  prints `bundled_activations`, `plugin_activations`, `unknown_source_activations`,
  `other_source_activations`, `activations_by_source` — and **no installed-scope line at all**,
  by design after round 3 ("no bucket is labelled installed"). The facts behind both citations
  reproduce (all-`null` on the absent id; `plugin_activations: 2` on `899232bb`); the quoted
  field names are from the round-2 tool. The workbook's "0 project-scope activations" on the
  probe runs is therefore an inference from "0 in every bucket", not a printed number.
- **(c) The run record cannot see the treatment.** `customization.skillsHash` is `null` on both
  treated probe runs, because `run-agent.sh:328` hashes `.github/skills.md` and nothing else.
  E-004's own prediction 4 registers exactly this, so it is known — but it means the §5
  independence check for any skill arm cannot use `customization.*Hash` to tell treatment from
  control. Delivery proof for E-004 will rest entirely on telemetry, and the telemetry's
  vocabulary for a project skill's `skill.source` is, by the tool's own header, unknown.
- **(d) Stale count in the state file.** `last_verified` says `verify-skill-activation 11/11`;
  the merged fixture set is 15 and passes 15/15.

## The single finding most likely to overturn the track's current state

**Stop 8's block proves that a nested skill is not in the `/name` registry at session start. It
does not prove that a nested skill cannot activate during a BE-003 run — and E-004's outcome is
mid-run activation, not registry membership.** Two things point the other way, both already on
disk:

- The telemetry stream contains `invocation_triggers: … nested-skill=1` on run `899232bb`,
  read with the merged tool. The runtime has a trigger named for exactly this case.
- The probe evidence's own "What is not claimed" section reports a scratch repo where the same
  binary loaded a nested skill after reading a file in that subdirectory. Every BE-003 run reads
  files under `sample-service/`.

The two nested probe runs recorded zero activations, but that is `n = 1` per condition and the
workbook says so. If five nested runs with the "REQUIRED" description also record zero, the
block stands and the author's one-line decision is needed. If any of them activates, the nested
path is deliverable after all, the halt was on the wrong premise — as the stop 6 halt was — and
no file §7 protects has to move. That probe costs about five runs and does not touch a
registered variable. It should run **before** the author is asked to choose between (a) and (b).
