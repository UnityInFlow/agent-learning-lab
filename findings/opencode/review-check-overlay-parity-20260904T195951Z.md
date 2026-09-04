# opencode review — check-overlay-parity

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
reviewed_utc:    20260904T195951Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: tools/check-overlay-parity.sh
    sha:  27b567ef0fe4
    dirty: false
  - path: tools/verify-overlay-parity-checker.sh
    sha:  48ce60b45c8b
    dirty: false
lab_head:        b1c0bd2
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

