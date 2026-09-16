# opencode review — check-run-state

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
reviewed_utc:    20260916T184333Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: tools/check-run-state.sh
    sha:  b3fe5190864e
    dirty: false
  - path: tools/check-completion-contract.sh
    sha:  c53fdce885d7
    dirty: false
  - path: tools/verify-run-state-checker.sh
    sha:  abfbd99bcd8c
    dirty: false
  - path: tools/verify-completion-contract-checker.sh
    sha:  0d34d8e216c0
    dirty: false
lab_head:        a55240a
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

