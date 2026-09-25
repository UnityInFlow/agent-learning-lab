# The `f13-candidate` in this directory's `RESULT.tsv` is a FALSE POSITIVE

`RESULT.tsv` in this preflight directory records `note = f13-candidate` for run `P-1`.
**It is wrong, `RESULT.tsv` is NOT rewritten (§4 step 12), and this file is the correction.**

## What happened

The first version of `run-mcp-hole-probe.sh` decided F13 (rate limit) with a substring test:

```
grep -qE '"(429|529)"|rate.?limit|usage limit' "$stream"
```

Every claude stream-json run on this CLI carries a routine telemetry record:

```json
{"type":"rate_limit_event","rate_limit_info":{"status":"allowed","resetsAt":1790366400,
 "rateLimitType":"five_hour", ...}}
```

`"status":"allowed"` says the run was **not** limited. The substring `rate_limit` matched it
anyway, so the detector fired on a run that completed normally in four seconds for $0.0132.

## Why it matters, and it is not a small thing

E-021 registers F13 under **Exclusions**. A detector that fires on every run would have moved
**every run of both arms** out of the population and into the exclusion list — and the arm
counts, not the exclusion list, are the registered outcome. **A detector that fires on
everything is exactly as useless as one that fires on nothing**, and this project already has
the mirror image on record three times: `tools/skill-activation.sh`'s *everything not
`bundled` is MINE*, and the runner's contamination guard marking the treatment arm
`EXCLUDE from comparisons` for loading the skill it was given.

## The fix, and when it was made

Corrected **before the batch and with no run in flight**, which is the only time §4 step 4
permits editing a tool. The test is now structural, not textual:

```
jq -e 'select(.type=="rate_limit_event") | select(.rate_limit_info.status != "allowed")'
jq -e 'select(.type=="result")          | select(.is_error == true)'
```

`verify-mcp-hole-probe-guards.sh` was re-run under the patched driver: **13 of 13 cases pass.**

## The re-derivation of this run's note, by hand

```
$ jq -c 'select(.type=="rate_limit_event") | .rate_limit_info.status' < stream-P-1.jsonl
"allowed"
$ jq -c 'select(.type=="result") | .is_error' < stream-P-1.jsonl
false
```

**Under the corrected rule this run's note is `ok`.** Nothing about the run's registered
outcome changes: `tool_present = yes`, `server_present = yes`, `server_status = connected`,
and the positive control holds. The classifier change touches only the `note` column, which
enters no decision-rule row.

`Recorded by Opus 5 (claude-opus-5), autonomously, 2026-09-25T18:50Z.`
