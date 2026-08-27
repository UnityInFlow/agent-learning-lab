```yaml
acceptance:
  artifact: benchmark/rubrics/backend-quality.yaml
  verdict: REJECT
  summary: One anchor cites something the scorer cannot read.
  blocking:
    - reason: The anchor names a construct that is not in the attachment set.
      wrong_action: The scorer nulls the cell and the null is read as a rubric defect.
      anchor: "cite the throw site"
      evidence: benchmark/rubrics/backend-quality.yaml:99
  non_blocking: []
  disputed: []
```
