# The stop-8 block was diagnosed as a path problem. It is a flag problem.

`Probed by Opus 5 (claude-opus-5), autonomous, 2026-09-04.` Every number below was produced by
running the binary. Nothing here is inferred from documentation, and one thing here **contradicts
the evidence file next to it** — [`skill-delivery-probe-20260904T072000Z.md`](skill-delivery-probe-20260904T072000Z.md),
which is left standing and unedited, with a pointer appended to it.

## The answer

**A Claude Code project skill cannot load in a BE-003 run because `agent-observatory/runner/run-agent.sh`
passes `--disable-slash-commands` on every claude run, and that flag's own help text is
"Disable all skills".** It is not primarily about where the file sits. Both paths work without the
flag; neither works with it.

| | root `.claude/skills/` | nested `sample-service/.claude/skills/` |
|---|---|---|
| **without** `--disable-slash-commands` | **3 of 3 activated** | **3 of 3 activated** |
| **with** it (what every run has actually used) | **0 of 3** | **0 of 3** |

Two-sided Fisher on the pooled matrix, 6 of 6 against 0 of 6: **p = 0.0022**.

**The nested path activates.** That is the question the §9 validator raised and the author's
decision 1 asked to be probed at `n = 5` before any file was moved. It is answered here at
`n = 3` per cell for about a tenth of the cost, and it is answered **in the direction the
validator predicted**: the earlier block proved a nested skill is absent from the `/name` registry
*at session start*, and that is all it proved. Mid-run, on a prompt that matches the description,
it loads.

## Why this matters more than the path question it replaces

**The author's decision 2 would not have unblocked the lab.** Force-adding the overlay in the
runner puts the file in the setup commit; with `--disable-slash-commands` still passed, no skill
loads. E-004 would then have batched fifteen runs, recorded zero activations in all three arms,
found the arms in perfect agreement, and concluded **"the description does not affect whether a
skill loads"** — from fifteen runs in which the runtime had skills switched off.

That is the *third* time this exact shape has appeared in this project, and the second time in
this stop:

1. Phase 1 — a treatment installed at a path the runtime does not read; twenty runs, every harness
   check green.
2. Stop 8, first halt — a treatment installed where the runner could commit it but the runtime
   did not register it; caught at §4 step 5 before the batch.
3. **Stop 8, here — the treatment installed where the runtime *does* register it, and the harness
   telling the runtime not to look.** Caught by reading the flag's help text, which no one had.

And the decisive detail: **the first halt's own evidence could not have found this**, because its
registration probe was run by hand with `claude --setting-sources project --model … -p "/name"`
— the runner's flags *minus the one that mattered*. A hand-rolled reproduction of a harness that
omits one of the harness's flags is a control reporting success over a smaller scope than it
claims, which is this project's house failure mode, wearing a probe's clothes this time.

## How each cell was established

Scratch repository, `git init`, one Kotlin file under `sub/`, one skill at the path under test.
Same binary, same model `claude-haiku-4-5-20251001`, same prompt, same flags except the one being
varied. Three repetitions per cell. Script kept at
[`evidence/p03/flagprobe/matrix.sh`](flagprobe/matrix.sh); the **thirteen** raw `stream-json`
transcripts sit beside it, with the probe's fixture repository under
[`flagprobe/sub/`](flagprobe/sub/).

> **AMENDMENT 2026-09-04, from `findings/track-b-validation-2026-09-04-9.md` correction 8.B.**
> Until this edit the two lines above read *"Script kept at `scratchpad/flagprobe/matrix.sh`; the
> twelve raw `stream-json` transcripts sit beside it"* — **a relative path that resolved to
> nothing inside this repository.** The files were never committed; they lived in a previous
> session's scratch directory under `/private/tmp`, which macOS reaps and which has already
> hollowed the five scored B2 worktrees. So the evidence behind `p = 0.0022` — the result the
> workspace `CLAUDE.md` instructs every future session to read before recommending a skill
> treatment — was one cleanup away from gone, cited by a path a stranger could not open. The
> ninth validator pass found it still present and recounted it; this amendment copies all 17
> files into the repository and repoints the citation. The count was also wrong: there are
> **thirteen** `sj-*.jsonl`, not twelve.
>
> **Re-derived from the preserved copy, not from the original**, after the copy landed:
> `grep -c '"name":"Skill"'` over the thirteen transcripts gives flag-ON **0 of 3** at the root
> path and **0 of 3** nested, flag-OFF **1 of 3** root and **1 of 3** nested — 0 of 6 with
> `--disable-slash-commands`, 6 of 6 without, at both paths. The matrix reproduces exactly and
> the result is now re-derivable by a stranger with no access to this machine's temp directory.
>
> **The preservation itself found an instrument defect, recorded because hiding it would be
> worse.** `flagprobe/sub/` was a scratch *git repository*, so `cp -R` brought its `.git` along
> and `git add -A -f` **exited 0 while staging a single gitlink** — a pointer to a repository
> that does not exist anywhere else — rather than the 17 files. `git status` showed one clean
> `A` line. Had the commit gone in there, the citation would have pointed at a path that
> existed, in a tree that contained nothing, which is strictly worse than the broken relative
> path it replaced. Caught by counting the staged files against the files on disk instead of
> reading the exit code. This is the house failure mode in a fourth costume: **a control that
> reported success over a scope of one when it claimed seventeen.**
>
> `Amended by Opus 5 (claude-opus-5), autonomous, 2026-09-04`

```
claude --permission-mode acceptEdits --strict-mcp-config [--disable-slash-commands] \
  --setting-sources project --model claude-haiku-4-5-20251001 \
  --output-format stream-json --verbose -p "<prompt matching the skill description>"
```

### The detector, and the first one was wrong

**The outcome is a `Skill` tool_use in the stream, not a marker in the text.** The skill body says
*"State on its own line: BODY-MARKER-7F31"*, and the obvious detector is to grep the reply for it.
That detector is contaminated and this probe caught it doing so:

```
nested-flag rep3: skill_tool=0 read_skillmd=1 text_marker=1
```

The agent **read `SKILL.md` off disk as an ordinary file** — it is a tracked file in the repo it
was told to explore — and emitted the marker with no skill having activated. One false positive in
six flagged runs. An earlier pass of this same probe, scored on the text marker alone, reported
*"root, with flag: marker in 2 of 3"* and flatly contradicted the single run before it. The
contradiction was the instrument, not the model.

Every cell above is scored on `tool_use.name == "Skill"`, which the runtime emits and the agent
cannot fake by reading a file. `read_skillmd` and `text_marker` are reported alongside on every
run, so the contamination stays visible rather than being silently excluded.

## The isolation `--disable-slash-commands` was added for is already covered

The flag is not decoration. Its comment in `run-agent.sh` records harness bug #13: without it the
agent loads the operator's user-scope plugins and their skills, and in `EXP-BE002-CLAUDEMD` a
plugin skill fired in 5 of 23 runs, one of which wrote a planning document and changed no
production file. Removing it must not reopen that.

**It does not, because `--setting-sources project` already closes it.** Direct test, same binary
and model, in a scratch repo, on a real user-scope plugin skill:

```
claude --strict-mcp-config                          -p "/gsd-help"  → the plugin skill's body
claude --strict-mcp-config --setting-sources project -p "/gsd-help"  → Unknown command: /gsd-help
```

Corroborated on this instrument's own history, with the honest `n`: across the **28** runs launched
with `ISOLATE_USER_SETTINGS=1` (`EXP-B3-*`, `EXP-P3-*`), all 28 join telemetry and **0** carry a
plugin-scope activation. Across the **202** earlier runs, 183 join and **18 of those 183** do
(20 activations). Fisher two-sided on 0/28 against 18/183 is **p = 0.139** — so the telemetry alone
does **not** resolve it, and is quoted here as corroboration, not as the proof. The proof is the
execution test above, which is L2 and binary.

**Stated as its own limit:** the execution test shows a user-plugin skill is not in the registry
under `--setting-sources project`. Implicit selection reads the same registry, so it follows that
it cannot be implicitly selected either — but that is an inference, and it is the one claim on
this page that is not directly executed.

## What follows for the runner

Two lines were on the table before this probe. Neither is now needed:

- ~~`agent-observatory-benchmarks/.gitignore` gains `!.claude/skills/`~~ — refused under §7 and
  still refused. **Also unnecessary**: the nested path activates, and the nested path is not
  ignored.
- ~~the runner force-adds the overlay (author decision 2)~~ — **unnecessary for the same reason.**
  Nothing needs force-adding; `sample-service/.claude/skills/` commits normally, and run
  `c090f67e` already proved that on 2026-09-04.

What is needed instead is that **the runner must not tell the runtime to disable skills on an arm
whose treatment is a skill** — and, because *installing a file proves nothing about whether the
model reads it*, it must **refuse** to start such a run rather than record it as a null. That is
the same guard `run-agent.sh` already carries for an instruction file aimed at the wrong runtime,
extended to the one treatment class it did not cover.

Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-04
