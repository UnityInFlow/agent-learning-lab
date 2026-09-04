# opencode review — E-004-skill-activation

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
reviewed_utc:    20260904T073617Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-004-skill-activation.md
    sha:  e4503ac60b37
    dirty: false
  - path: tools/skill-activation.sh
    sha:  3c4db30949fb
    dirty: false
lab_head:        0075565
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

