# The review hook

Anyone who clones this repo gets it. It lives here, not in a personal config.

| File | Role |
|---|---|
| [`../settings.json`](../settings.json) | the wiring |
| [`opencode-review.sh`](opencode-review.sh) | the script, `chmod +x` |
| [`opencode-review.test.sh`](opencode-review.test.sh) | 16 cases with `gh`, `git`, `opencode` and the reviewer stubbed — no network, no tokens |

## What it does

On `git push` and `gh pr create`, the measurement contracts changed on this branch go to
`tools/opencode-review.sh`, and the findings land in `findings/opencode/`.

**Two models, two jobs.** Finding and deciding are different work, and running both on one
model means one set of blind spots covers both:

| Pass | Agent | Model | Job |
|---|---|---|---|
| line-level | `lab-critic` | `ollama-cloud/glm-5.2` | every section, every finding bound to a concrete failure scenario |
| acceptance | `lab-acceptance` | `ollama-cloud/minimax-m3` | one verdict on the whole artifact — is this ready to leave the machine |

The acceptance pass reads the artifact **and** the line-level findings. It does not re-find;
it decides, and it may put a line-level finding it cannot substantiate into `disputed`.

**The gate is advisory.** A `REJECT` is recorded and printed to stderr; the hook still exits
0, because a reviewer that can break `git push` gets removed within a day. That makes the
verdict L3 — words someone reads. `LAB_ACCEPT_STRICT=1` is the L2 version: `REJECT` exits 3.
Nothing in this repo sets it yet, and the README should not imply otherwise.

"Contracts" means exactly three globs, listed at the top of the script:

```
benchmark/rubrics/*.yaml    templates/*.yaml    experiments/*.md
```

A phase README changing does not need an adversarial reviewer. A rubric leaving the machine
does.

## Why a hook and not a habit

In one session the critic caught a *"guaranteed null"* that nothing enforced, and an
experiment record asserting a property a reader had to go and verify by hand. Both were
written minutes after landing a Layer 2 control against that exact mistake.

A review you have to remember to run is Layer 3. This is the Layer 2 version. Push is the
right trigger because it is the moment the artifact stops being yours alone.

## The contract with Claude Code

The tool call arrives as JSON on stdin:

```json
{"tool_name":"Bash","tool_input":{"command":"git push …"},"tool_response":{}}
```

Command filtering is `"if": "Bash(git push:*)"` in `settings.json`, so the hook is not
spawned at all for anything else, and `"async": true` keeps it off the critical path — the
push has already happened by the time the reviewer starts. Neither is hand-rolled inside the
script; the settings schema provides both.

The script re-checks the command anyway, because it is also run directly by its test and by
anyone debugging it.

**It exits 0 on every path** — missing `opencode`, a broken reviewer, malformed stdin, no
git. A reviewer that can break `git push` gets removed within a day, and then nothing is
reviewed at all.

## Turning it off

`LAB_REVIEW_HOOK=0` for one command, or `/hooks` to disable it for the session.
`LAB_REVIEW_MODEL` and `LAB_ACCEPT_MODEL` swap either model; `-A` on the wrapper skips the
gate entirely. `LAB_REVIEW_RUNS` overrides `-n` (default 2 — a single run at temperature 0 is a lower bound;
two runs disagreed on 2 of 12 sections, and both flips were real findings the earlier run
had missed).

## Installing it in another repo

1. Copy both `.claude/hooks/*.sh`, keeping the executable bit.
2. **Add** the `PostToolUse` block to that repo's `.claude/settings.json` — merge into the
   array, do not replace it.
3. Point `REVIEWABLE_GLOBS` at that repo's contracts, and make sure the reviewer it calls
   (`tools/opencode-review.sh` here) exists, along with whatever agent definition it needs.
   Without those the trigger has nothing to run.
4. Run `./.claude/hooks/opencode-review.test.sh` before trusting it. It stubs everything, so
   it costs nothing and it is the only thing that tells you the hook is not silently inert.
5. Open `/hooks` once, or restart. The settings watcher only watches directories that had a
   settings file when the session started, so a brand-new `.claude/settings.json` is not
   picked up mid-session.

**Scope.** This is project `.claude/settings.json` — committed, team-wide. The alternatives
are `~/.claude/settings.json` (personal, every project) and `.claude/settings.local.json`
(personal, gitignored).
