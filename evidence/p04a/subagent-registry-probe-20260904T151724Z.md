# Subagent registry probe — 20260904T151724Z

Model `claude-haiku-4-5-20251001`, n=3 per cell. Marker `ORANGE-PENGUIN-4A`.
Subagent at `.claude/agents/probe-reviewer.md`, project scope, committed.

Runner flag set (runner/run-agent.sh:509-526): `--permission-mode acceptEdits`
`--strict-mcp-config` `--allowedTools Bash(./mvnw:*) Bash(mvn:*)`
`--setting-sources project` `--model <id>`, plus `--disable-slash-commands`
unless `--enable-skills` is passed. This probe varies ONLY that last flag.

| cell | run | exit | marker present | first 100 chars of output |
|---|---|---|---|---|
| flag ON (runner default) | 1 | 0 | YES | `ORANGE-PENGUIN-4A` |
| flag ON (runner default) | 2 | 0 | no | `## README.md Review  I've reviewed the README.md file. Here are my findings:  **Current State:** - T` |
| flag ON (runner default) | 3 | 0 | YES | `ORANGE-PENGUIN-4A` |
| flag OFF (--enable-skills) | 1 | 0 | no | `## README.md Review  I've reviewed the README.md file. Here's what I found:  **Content:** The file c` |
| flag OFF (--enable-skills) | 2 | 0 | YES | `ORANGE-PENGUIN-4A` |
| flag OFF (--enable-skills) | 3 | 0 | YES | `ORANGE-PENGUIN-4A` |

## The negative control this probe did not have when its table was written

Added 2026-09-04T15:28Z, in the same session, **before any of the table above was quoted
anywhere.** The table proves nothing on its own: every cell exits 0, and a run that silently
ignored the subagent would also exit 0. *A control that has never been shown to reject
anything is indistinguishable from one that rejects nothing.*

Same worktree, same flags, only the agent NAME varies:

```
$ claude … --disable-slash-commands --agent no-such-agent-xyz -p "Say OK."
--agent 'no-such-agent-xyz' not found. Available agents: claude, Explore,
general-purpose, Plan, probe-reviewer, statusline-setup
exit 1

$ claude … --disable-slash-commands --agent probe-reviewer   -p "Say OK."
ORANGE-PENGUIN-4A
exit 0
```

**Corrected in the same session:** a first attempt read this exit code through a `| head -5`
pipe and recorded `exit 0` for the bogus name, which would have made `--agent` useless as a
delivery check. `$?` after a pipeline is the last command's. Re-run without the pipe, the
bogus name exits **1**. The wrong reading is written down here rather than deleted.

## What this establishes, and what it does not

1. **A project-scope subagent at `.claude/agents/<name>.md` REGISTERS under the runner's exact
   flag set, `--disable-slash-commands` included.** `probe-reviewer` is in the runtime's own
   enumeration of available agents while that flag is on. **Subagents are not skills.** The
   flag whose help text is *"Disable all skills"* — which silenced every project skill at
   every path, 6 of 6 versus 0 of 6, `p = 0.0022`
   ([`../p03/skill-flag-probe-20260904T102230Z.md`](../p03/skill-flag-probe-20260904T102230Z.md))
   — does **not** touch this channel. The Phase 3 halt does not repeat here.
2. **`--agent <name>` is an L2 delivery proof**, the first one this project has for any
   customization class: it *executes*, and it *refuses* an undelivered treatment with exit 1
   and a printed registry. Contrast `--enable-skills`, which the third validator pass just
   relabelled **L3** on the control arm because nothing executes it there.
3. **It measures registration at SESSION START and nothing else.** It does not measure whether
   the model *delegates* to the subagent mid-run, which is the observable a Phase 4A lab
   actually scores. Stop 8's halt conflated exactly these two and was wrong for eight hours.
   This paragraph exists so the next reader cannot make that trade.
4. **The subagent's PROMPT is obeyed 4 of 6 times; its registration is 6 of 6.** True of these
   runs, `n = 6`, not offered as a property. Where the task ("Review README.md.") competed with
   the agent prompt ("reply with exactly this word"), the task won twice. That split — the
   registry is deterministic, the prompt is not — is the Phase 4A thesis in miniature, and it
   is why the lab measures a `tools:` list rather than a persona.

`Probed by Opus 5 (claude-opus-5), autonomous, 2026-09-04. Model under test
claude-haiku-4-5-20251001, the track's controlled variable.`
