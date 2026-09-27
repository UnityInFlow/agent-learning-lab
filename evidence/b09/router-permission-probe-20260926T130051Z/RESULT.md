# Can a treatment grant itself a Bash permission in this harness? No.

*Run by Opus 5 (claude-opus-5), autonomously, 2026-09-26T13:00–13:07Z, at spine stop 20 §4 step 5,
after the preflight refused the batch. Three arms, one model call each, about $0.07 in total.*

## The question, and why it had to be a probe rather than a reading

Stop 20's preflight failed its condition (ii): the router's log was absent on both treated runs. The
cause was in the run record rather than in the agent — on BE-003 treated `fbdebf75` the agent ran
`.ai/knowledge/router.sh "state transition validation error codes"` at its first opportunity and the
call is in that run's `permission_denials` array, while `repair-limit.sh` recorded nine allows and
zero blocks. `run-agent.sh` passes `--permission-mode acceptEdits` with
`--allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"`, and `claude -p` has no human to approve anything
else.

Two fixes were available and they are **not** equivalent:

- **(A)** a `permissions.allow` entry in the **overlay's** `.claude/settings.json` — the treatment
  carrying its own precondition, loaded because the runner passes `--setting-sources project`;
- **(B)** a new entry in the **runner's** `--allowedTools` — a change to a harness variable held
  constant since B2 and inherited by every later stop.

(A) is strictly preferable if it works at all. Whether a project-scope permission rule is honoured
at all is a property of the runtime, not of this repository, and stop 9 is the standing reason to
probe rather than assume: a four-name `tools:` list was delivered as two names on 10 of 10 runs.

## The arms

Three `claude -p` runs of nine words of work each, in three throwaway git repos each containing a
copy of `build/customizations/agent-v1.2-knowledge`, with the runner's exact claude flags
(`--permission-mode acceptEdits --strict-mcp-config --disable-slash-commands --setting-sources
project --agent backend-feature-phases --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"`), model
`claude-haiku-4-5-20251001`. The prompt asks for one thing: run the router and report what it
printed or the exact error.

| arm | what it adds | `permission_denials` | router log | lines |
|---|---|---|---|---|
| `baseline` | nothing | **non-empty**, names the router | none | 0 |
| `overlay-permission` | `permissions.allow: ["Bash(.ai/knowledge/router.sh:*)"]` in the overlay's `.claude/settings.json` | **non-empty** | none | 0 |
| `cli-allowlist` | `--allowedTools "Bash(.ai/knowledge/router.sh:*)"` | **`[]`** | **written** | 1 |

## The decisive output, verbatim

`overlay-permission.log`, in its entirety:

```
Ignoring 1 permissions.allow entry from .claude/settings.json: this workspace has not been trusted.
Run Claude Code interactively here once and accept the trust dialog, or set
projects["…/overlay-permission"].hasTrustDialogAccepted: true in /Users/jirihermann/.claude.json.
```

`cli-allowlist-knowledge.jsonl`, in its entirety:

```json
{"ts":"2026-09-26T13:07:13Z","status":"hit","query":"status enum branch","topic":"kotlin-exhaustive-when","summary":"summaries/kotlin-exhaustive-when.md","details":"documents/kotlin-exhaustive-when.md","matches":1,"pid":96360}
```

and that arm's model reported back
`` `.ai/knowledge/summaries/kotlin-exhaustive-when.md` and `.ai/knowledge/documents/kotlin-exhaustive-when.md` ``
with `permission_denials":[]` and a cost of `$0.0244968`.

## What it decides, and what it decides beyond this stop

**Route (A) is refused by the runtime, not by this project's design.** A project-scope
`permissions.allow` entry is ignored in an untrusted workspace, and **every benchmark worktree is a
new temporary directory and is untrusted by construction**. The remedy the runtime offers — marking
the path trusted in `~/.claude.json` — is a user-scope mutation of a path that is different on every
run, and `--isolate-user-settings` exists precisely to keep user scope out of a run.

> **A treatment in this harness cannot grant itself a Bash permission.** Any later step whose
> treatment is a command inherits that constraint, and the only place the permission can live is the
> runner — where it applies to both arms.

**Route (B) works and was taken**: obs#90, `Bash(.ai/knowledge/router.sh:*)` added unconditionally to
`--allowedTools`, for the reason the runner's own stream-json comment gives about itself — a flag
passed to the treatment arm only makes the launch a between-arm difference and confounds the
comparison it was added to protect. An allow rule for a path that does not exist cannot change a
control run's behaviour.

## What this probe is not

It is **not** a measurement of the treatment. Nine words of work, `n = 1` per arm, no benchmark, no
evaluator, no rubric. It answers one mechanical question — *does the permission take effect* — and
nothing about whether routed knowledge changes any run's output. That is what the batch is for, and
its registered outcome, decision rules and thresholds are untouched by this file.

It is also **not** a proof that the flag is present on a real benchmark run. That is asserted per
run, on every run of the preflight and the batch, by `router_denied` in their manifests: an empty
denial array on a run that made the call is the observation; a flag echoed into a log is only
provenance.
