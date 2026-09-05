# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260905T191942Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        f227551
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

Every family failed. No review was produced.

| Family | Outcome | |
|---|---|---|
| codex | FAILED | rc=1 4s |
