# opencode review — memory-policy

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/glm-5.2          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260929T112646Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: governance/memory-policy.md
    sha:  16deb4edf343
    dirty: false
lab_head:        2f0044b
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

