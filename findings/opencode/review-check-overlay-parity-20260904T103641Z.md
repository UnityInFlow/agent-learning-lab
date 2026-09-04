# opencode review — check-overlay-parity

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260904T103641Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: tools/check-overlay-parity.sh
    sha:  2f317601a930
    dirty: false
  - path: tools/skill-activation.sh
    sha:  5e7f05fabd9d
    dirty: false
lab_head:        f8ff084
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 20s |
| codex | ok | 20s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| tools/check-overlay-parity.sh | 1/1 | L2 |
| tools/skill-activation.sh | 1/1 | L2 |


---

## Run 1 of 2 — codex

### tools/check-overlay-parity.sh
**Verdict:** finding
**Failure:** Add `# reviewer note` inside the YAML frontmatter of only overlay A. The script ignores comment lines when constructing `fm`, so it exits 0 even though the overlays differ outside any declared key. One reviewer applying the stated byte-level parity contract rejects the experiment; another trusting this validator accepts it. Duplicate keys can similarly conceal a difference because later values overwrite earlier ones.
**Layer of the implied fix:** L2
**Anchor:** - SKILL.md frontmatter may differ ONLY in the keys named by --allow-differ

### tools/skill-activation.sh
**Verdict:** finding
**Failure:** Supply a parseable JSONL record whose resource attributes contain `{"key":"observatory.run.id","value":{}}`. `attrs(rl.get("resource", {}))` raises `DamagedRecord` outside any handler, producing a traceback and process exit 1. The documented outcome for a damaged stream is status `PARTIAL-telemetry-damaged` and exit 4, so automation will misclassify telemetry damage as a usage error or broken tool.
**Layer of the implied fix:** L2
**Anchor:** res = attrs(rl.get("resource", {}))

### Cross-cutting
**Verdict:** no finding
**Failure:** No scoring categories or pass/fail gates exist, so none duplicate each other. Reviewers would diverge most on `tools/check-overlay-parity.sh`: one could treat frontmatter comments, ordering, and duplicate-key syntax as irrelevant YAML presentation while another applies the stated rule that only named keys may differ; their outcomes differ between exit 0 and exit 2. The artifact needed to specify whether frontmatter parity is lexical, parsed-YAML semantic, or limited to the script’s simplified key/value model.
**Layer of the implied fix:** n/a
**Anchor:** n/a


---

## Run 2 of 2 — codex

### tools/check-overlay-parity.sh
**Verdict:** finding
**Failure:** Overlay A contains a regular `SKILL.md`; overlay B contains a symbolic link named `SKILL.md` whose target has identical bytes. `rel_files()` records only the relative name and `open()` follows the link, so the script exits 0. One reviewer can treat the overlays as equivalent by content, while another can correctly treat the symlink as an undeclared packaging and resolution difference that may change what is loaded. The claimed same-set and byte-parity gate therefore accepts structurally different overlays.
**Layer of the implied fix:** L2
**Anchor:** This is the executing version. It compares two overlay directories and fails closed on any difference the caller did not declare:

### tools/skill-activation.sh
**Verdict:** finding
**Failure:** Given a parseable telemetry line whose `resource.attributes` contains `{"key":"observatory.run.id","value":{}}`, `attrs(rl.get("resource", {}))` raises `IndexError` before the guarded log-record block. Python terminates with a traceback and exit 1, rather than reporting damaged telemetry and exit 4. A caller following the documented exit codes will classify instrument damage as a usage error, and no lower-bound result is emitted.
**Layer of the implied fix:** L2
**Anchor:** res = attrs(rl.get("resource", {}))

### Cross-cutting
**Verdict:** no finding
**Failure:** No scoring categories or pass/fail gates are present, so there is no duplicated scoring gate. Reviewers would diverge most on `tools/check-overlay-parity.sh`: one may define parity as resolved file bytes while another includes filesystem object type, changing the result from pass to fail for the symlink scenario. The artifact does not state whether overlay parity includes file type, link target, permissions, or other filesystem metadata; `tools/skill-activation.sh` also does not state how unexpected structural damage outside log-record attributes maps to its documented statuses.
**Layer of the implied fix:** n/a
**Anchor:** n/a

