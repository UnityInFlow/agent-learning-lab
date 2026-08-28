# opencode review — backend-quality

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - codex
    - ollama-cloud/deepseek-v4-pro
    - ollama-cloud/gpt-oss:120b
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.21
reviewed_utc:    20260828T071503Z
runs:            3           # independent sessions; findings unioned below
families:        3           # distinct models; the recurrence denominator
artifacts:
  - path: benchmark/rubrics/backend-quality.yaml
    sha:  396e1799eb2b
lab_head:        bdd55a5
lab_dirty:       true
```

