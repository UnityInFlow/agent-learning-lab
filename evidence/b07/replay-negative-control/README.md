# The negative control for `tools/replay-policy-gate.py`, and the defect it caught

`replay-policy-gate.py` returned **0 denials over 915 calls**. A replay that reads nothing
returns exactly the same answer, so the number is worthless until the instrument has been
shown to be *capable* of returning a denial. That is the rule in the workspace `CLAUDE.md`
— *"when a check goes green, re-verify one of its cases by hand before trusting it"* — and
here it earned its keep immediately.

**`synthetic-negative-control.log`** is four `tool_use` calls: `sample-service/pom.xml`,
`.github/workflows/ci.yml`, `infra/main.tf` — all three of which the policy names — and one
ordinary Kotlin source file, which it does not. **Three denials and one allow is the only
correct answer.**

## First run: `0 calls from 0 logs -> 0 denials`

The extractor was a single regex pinned to the exact byte sequence
`{"type":"tool_use","id":"...","name":"Edit","input":{`. The synthetic log was written with
`json.dumps` defaults, which inserts a space after every `:` and `,`. The regex matched
nothing, the script exited 0, and the report said **0 denials** in the same words it uses for
a real result.

**That is the house failure mode exactly: a control reporting success over a scope smaller
than it claims.** Had a real log format shifted by one space, the headline of this stop's
false-positive measurement would have been a clean `0.00 %` produced by reading nothing.

## The fix, and why it is not "a better regex"

`calls_in` now parses each line as JSON and walks the decoded object for `tool_use` blocks,
falling back to a loosened regex only for files that are not line-delimited JSON — **and it
counts what it could not read**. The report carries those counters:
`tool_use_from_json`, `files_needing_regex_fallback`, `regex_hits_undecodable`,
`unparsed_lines`, `unreadable_files`. A future format change now shows up as a **number**
instead of as silence.

## Second run, same fixture

```
4 calls from 1 logs -> {'deny': 3, 'allow': 1}
denials: 3 (75.00 %)
```

Three denials, one allow, the right three. **The instrument can reject.** Only then is the
real corpus's `0 of 915` worth quoting — and it is reproduced through the new code path, at
the same value, with `tool_use_from_json = 915`.

*Recorded by Opus 5 (claude-opus-5), autonomous, 2026-09-10.*
