# opencode review — retrieval-trace-probe

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
reviewed_utc:    20260926T073240Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p06b/retrieval-trace-probe.sh
    sha:  e21edf6ee83b
    dirty: true
lab_head:        20c2f4d
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

