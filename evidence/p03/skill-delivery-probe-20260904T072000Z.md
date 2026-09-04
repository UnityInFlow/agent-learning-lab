# Can a Claude Code project skill be delivered to a BE-003 benchmark run?

`Probed by Opus 5 (claude-opus-5), autonomous, 2026-09-04.` Every command below was run; nothing
here is inferred from documentation. This is the evidence behind E-004's halt.

## The answer

**No. Not on this benchmark, with this runner, without changing a file §7 forbids changing.**

The two conditions the experiment needs — *the runner can commit the overlay* and *the runtime
registers the skill* — are satisfied by two different locations, and **never by the same one.**

| location | runner can commit it? | registered at session start? |
|---|---|---|
| `.claude/skills/<name>/SKILL.md` (worktree root) | **NO** | **YES** |
| `sample-service/.claude/skills/<name>/SKILL.md` (nested) | **YES** | **NO** |

## How each cell was established

### Root — the runner refuses, loudly

Run `16cd4378-5730-4bb2-a2dc-97931f35b2dd` died before the agent started:

```
On branch main
nothing to commit, working tree clean
run-agent: failed to commit the customization overlay
```

Cause: `agent-observatory-benchmarks/.gitignore:19` is `.claude/*`, allowlisting only
`!.claude/hooks/` and `!.claude/settings.json`. The runner installs with `cp -R` and commits
with `git add -A`, which respects `.gitignore`. `git check-ignore -v` on the installed file
returns that line.

**This is the Phase 1 guard working.** There, a treatment was installed at a path the runtime
does not read and every check reported success across twenty runs. Here the harness refused to
start a run whose treatment it could not commit.

### Root — but the runtime *does* register it

Tested by hand inside the kept worktree of run `d8be2b5f-9a88-4aa6-8aba-27fffe4de917`, with the
same binary, model and flags the runner uses:

```
cd <worktree> && claude --setting-sources project --model claude-haiku-4-5-20251001 \
  -p "/shipment-service-conventions"
```

Reply:

> "I've loaded the shipment-service-conventions skill. I'm ready to apply the conventions for any
> changes to shipment confirmation in this Kotlin Spring service.
> The key convention is: **Model state transitions as an exhaustive `when` over the enum in
> expression position, with no `else` branch.**"

It quotes the **body**, which exists nowhere but that file. Registration proven.

### Nested — the runner commits it happily

Run `c090f67e-0003-4c35-8ccf-9572b2584462`, evaluator exit 0, 7/7 acceptance. The file is in the
worktree, is **tracked**, and is in the setup commit `8300382 experiment setup: install
customization for variant 'skill-matched'`. `git ls-files | grep -c .claude/skills` → `1`. The
agent then edited three files under `sample-service/`.

### Nested — and the runtime never registers it

Same worktree, same flags, skill moved to `sample-service/.claude/skills/`:

```
-p "/shipment-service-conventions"
→ Unknown command: /shipment-service-conventions
```

**This is the finding.** A nested skill installs cleanly, commits cleanly, passes every check the
harness has, and is **not there**. Had E-004 batched fifteen runs at this path, all three arms
would have returned zero activations, the arms would have agreed perfectly, and the experiment
would have concluded that *the description does not affect skill loading* — from fifteen runs in
which **no skill existed at all**. That is Phase 1's disaster with a different filename, and §4
step 5 is the only reason it was caught.

## What is not claimed

**The nested rule is not shown to be broken in general.** In a scratch repository the same binary
and model loaded a nested skill (`sub/.claude/skills/nested-marker`) and returned its marker
`NESTED-SKILL-LOADED-9B2C`, after being told to read a file in that subdirectory first. Claude
Code documents nested skills as becoming available *"when Claude reads or edits a file in a
subdirectory"* — availability that arrives mid-session, and evidently not in the `/name` registry
at session start. Whether it would ever be selected proactively mid-run on this task is
**untested**, because a null there is uninterpretable without a registration proof, which is
exactly what the nested path cannot give.

## The one behavioural observation, at `n = 1` each, stated as no more than that

On the real BE-003 task, at a location where the skill **was** registered, the model **did not
choose to load it** — not with a matched description (`c090f67e`), and not with a description
reading *"REQUIRED for any change to shipment confirmation… You must load this skill before
editing ShipmentController"* (`d8be2b5f`). Both runs recorded **0** project-scope activations
with telemetry present (`status: measured`, so this is a real zero, not a missing one).

**This is `n = 1` per condition and is not a result.** It is the reason E-004's prediction 1 —
*the matched arm loads on ≥ 4 of 5* — is worth running the moment delivery is unblocked, and the
reason it may well be refuted.

## Commands a stranger re-runs

```bash
# the block
git -C agent-observatory-benchmarks check-ignore -v .claude/skills/x/SKILL.md   # → .gitignore:19
git -C agent-observatory-benchmarks check-ignore -q sample-service/.claude/skills/x/SKILL.md
echo $?                                                                          # → 1, not ignored

# registration, in any kept worktree
cd <worktree>
mkdir -p .claude/skills/probe && printf -- '---\nname: probe\ndescription: x\n---\nBODY-MARKER\n' \
  > .claude/skills/probe/SKILL.md
claude --setting-sources project --model claude-haiku-4-5-20251001 -p "/probe" < /dev/null
mv .claude/skills/probe sample-service/.claude/skills/probe    # same file, nested
claude --setting-sources project --model claude-haiku-4-5-20251001 -p "/probe" < /dev/null
```

## Two further instrument facts, from the same session

- **`customization.skillsHash` is non-null on 0 of 228 registered runs**, and
  `run-agent.sh:328` computes it as `hash_of .github/skills.md` — a single file, at a path no
  Claude Code skill uses. E-004's prediction 4 said it would be `null` on every treated run; on
  the two runs that happened, it was. The field is a provenance claim that cannot see its own
  subject.
- **`claude_code.skill_activated` exists and works**, carrying `observatory.run.id`,
  `skill.name`, `skill.source` and `invocation_trigger`. 30 events across 28 runs, all from
  earlier BE-001/BE-002 work. Every custom skill recorded so far is `plugin`-scope and reports
  the redacted name `custom_skill`; only `bundled` skills report a real name. **No project-scope
  skill has ever been recorded on this instrument**, so E-004's prediction 5 remains untested.

---

## Correction — 2026-09-04, from the §9 validator's second pass

Source: [`../../findings/track-b-validation-2026-09-04-2.md`](../../findings/track-b-validation-2026-09-04-2.md),
correction (b). Appended rather than edited in place; nothing above was changed.

**"Both runs recorded 0 project-scope activations" is an inference, not a printed number.** The
merged `tools/skill-activation.sh` at `049e871` prints four source buckets —
`bundled_activations`, `plugin_activations`, `unknown_source_activations`,
`other_source_activations` — and **deliberately labels none of them "the installed skill"**, after
the §4a gate showed three times that every attempt to do so kept an open *everything-else-is-mine*
bucket. What the two probe runs actually show is `status: measured` with **0 in every bucket**,
from which no project-scope activation follows. That is the honest form of the same fact, and it
is weaker than the sentence above states.

**Every reproduction command above was re-checked and still reproduces.** The block itself was
independently reproduced by the validator in a scratch repository, same binary and model: the root
path answers by quoting the body marker, the nested path answers `Unknown command`.

**What the block does and does not prove.** It proves a nested skill is absent from the `/name`
registry at session start. It does **not** prove a nested skill cannot activate *during* a run,
which is what E-004 actually measures. The telemetry above already carries
`invocation_triggers: … nested-skill=1` on run `899232bb`, and the *"What is not claimed"* section
records the same binary loading a nested skill after a file in that subdirectory was read. The
nested path is therefore probed at `n = 5` under experiment key `EXP-P3-NESTED-PROBE` before any
file §7 protects is moved.

Recorded by Opus 5 (claude-opus-5), autonomous, 2026-09-04

## Superseded in part — 2026-09-04, by the flag probe

[`skill-flag-probe-20260904T102230Z.md`](skill-flag-probe-20260904T102230Z.md) contradicts the
central diagnosis on this page and is the later, stronger evidence. Nothing above has been edited.

**What still holds.** Every command above still reproduces. Root `.claude/skills/` is gitignored
in the benchmarks repo; the runner's setup commit does refuse an all-ignored overlay; and a nested
skill is genuinely **not** in the `/name` registry at session start.

**What does not hold: the conclusion drawn from it.** *"A Claude Code project skill cannot be
delivered to a BE-003 run"* was true of the runs that had been done and false as a statement about
the instrument. The cause is not the path. It is that `run-agent.sh` passes
`--disable-slash-commands` — *"Disable all skills"* — on every claude run. Without that flag the
nested path activates **3 of 3**; with it, neither path activates at all (0 of 6, Fisher
p = 0.0022).

**And the reason this page could not see that.** Its registration probe was run by hand as
`claude --setting-sources project --model … -p "/name"` — the runner's flag set *minus the flag
that decides the outcome*. A reproduction of a harness that omits one of the harness's flags is a
control reporting success over a smaller scope than it claims. That is this project's house failure
mode, and this page is an instance of it.

Recorded by Opus 5 (claude-opus-5), autonomous, 2026-09-04
