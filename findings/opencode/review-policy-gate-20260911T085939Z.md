# opencode review — policy-gate

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260911T085939Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/026728f1-6cdb-4451-8222-b687f17522a6/scratchpad/review/policy-gate.sh
    sha:  f432abbcbf1f
    dirty: false
lab_head:        307a26d
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Acceptance

The gate failed to run (opencode exit 1).
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 36s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| policy-gate.sh | 1/1 | L2 |


---

## Run 1 of 1 — codex

### policy-gate.sh
**Verdict:** finding
**Failure:** Given a policy entry `.github/workflows/**` and a Write call whose `file_path` is `$CLAUDE_PROJECT_DIR/sub/../.github/workflows/ci.yml`, `REL` remains `sub/../.github/workflows/ci.yml`. The deny glob does not match, so the hook logs `allow` and exits 0, while the filesystem resolves the path to the protected `.github/workflows/ci.yml`. One reviewer testing canonical paths sees enforcement; another testing equivalent non-canonical paths sees a bypass.
**Layer of the implied fix:** L2
**Anchor:** REL="${RAW#"$ROOT"/}"; REL="${REL#./}"

### Cross-cutting
**Verdict:** no finding
**Failure:** No scoring categories or pass/fail gates are present to duplicate. Reviewer divergence is greatest around path normalization: reviewers using only canonical paths may report no bypass, while reviewers using `sub/../` paths will reproduce a complete allow-versus-deny divergence. The artifact does not specify or enforce canonicalization and containment of the requested path before policy matching.
**Layer of the implied fix:** n/a
**Anchor:** n/a

