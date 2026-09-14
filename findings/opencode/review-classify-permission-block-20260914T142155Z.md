# opencode review — classify-permission-block

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
reviewed_utc:    20260914T142155Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: ../agent-observatory/runner/lib/classify-permission-block.sh
    sha:  84e860f76f23
    dirty: false
  - path: ../agent-observatory/runner/verify-permission-block-classifier.sh
    sha:  5b08ed6a0110
    dirty: false
lab_head:        e06e2ae
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

