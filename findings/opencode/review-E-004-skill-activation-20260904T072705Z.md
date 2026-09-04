# opencode review — E-004-skill-activation

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - codex
    - ollama-cloud/deepseek-v4-pro
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260904T072705Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-004-skill-activation.md
    sha:  1c2f8cce6409
    dirty: false
  - path: tools/skill-activation.sh
    sha:  958f82c2cfab
    dirty: false
lab_head:        ae42e02
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

