# opencode review — backend-quality

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/deepseek-v4-pro          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - ollama-cloud/deepseek-v4-pro
    - opencode-go/qwen3.7-max
    - ollama-cloud/gpt-oss:120b
    - ollama-cloud/mistral-large-3:675b
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.21
reviewed_utc:    20260828T062834Z
runs:            4           # independent sessions; findings unioned below
families:        4           # distinct models; the recurrence denominator
artifacts:
  - path: benchmark/rubrics/backend-quality.yaml
    sha:  f626ef14161f
lab_head:        e93ada3
lab_dirty:       true
```

