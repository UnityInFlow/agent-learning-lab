# opencode review — check-overlay-parity

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260904T110411Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: tools/check-overlay-parity.sh
    sha:  84e15c583725
    dirty: false
  - path: tools/skill-activation.sh
    sha:  b49d972f4150
    dirty: false
  - path: ../agent-observatory/runner/lib/classify-skill-contamination.sh
    sha:  15ba1999e0d2
    dirty: false
  - path: ../agent-observatory/runner/verify-skill-delivery.sh
    sha:  c92130534613
    dirty: false
lab_head:        90cf65a
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 28s |
| codex | ok | 36s |

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
| ../agent-observatory/runner/lib/classify-skill-contamination.sh | 1/1 | L2 |
| ../agent-observatory/runner/verify-skill-delivery.sh | 1/1 | L2 |
| Cross-cutting | 1/1 | n/a |


---

## Run 1 of 2 — codex

### tools/check-overlay-parity.sh
**Verdict:** finding
**Failure:** Input A contains a directory symlink `shared -> ../v1`; input B contains `shared -> ../v2`, with no other files. `os.walk(..., followlinks=False)` places these symlinks in `dirnames`, but `rel_files` records only `names`. Both file sets are therefore empty and the script exits 0, although the overlays install different targets. A reviewer relying on the stated symlink guarantee rejects the experiment; a reviewer relying on the exit code accepts it.
**Layer of the implied fix:** L2
**Anchor:** a path must be a symlink in both arms or in neither, and links must point at the same
#     place

### tools/skill-activation.sh
**Verdict:** finding
**Failure:** Given a valid JSONL line `{"resourceLogs":null}`, `json.loads` succeeds and sets `parsed_any = True`, but `for rl in doc.get("resourceLogs", [])` attempts to iterate over `None` and raises `TypeError`. The script exits through an unclassified Python failure rather than exit 2 for unusable telemetry or exit 4 for damaged telemetry. One reviewer records an instrument crash; another, following the documented exit-code contract, has no defined status for the run.
**Layer of the implied fix:** L2
**Anchor:** for rl in doc.get("resourceLogs", []):

### ../agent-observatory/runner/lib/classify-skill-contamination.sh
**Verdict:** finding
**Failure:** Invoke the script with `true false '{'`. Both `jq` commands fail to parse the telemetry, but stderr is suppressed, `SOURCES` becomes empty, `TOOL_SKILL_CALLS` is coerced to 0, and the script prints `clean` with exit 0. The same malformed input can therefore be excluded as invalid by a reviewer who inspects it or admitted as uncontaminated by a reviewer who trusts the classifier.
**Layer of the implied fix:** L2
**Anchor:** SOURCES="$(jq -r '[.skillActivations[]? | "\(.source) \(.calls)"] | .[]' <<<"$TELEMETRY" 2>/dev/null)"

### ../agent-observatory/runner/verify-skill-delivery.sh
**Verdict:** finding
**Failure:** Suppose the enabled transcript contains one `Skill` tool_use for an unrelated bundled skill and never invokes `probe-fixture`, while the disabled transcript contains no `Skill` tool_use. `activated()` counts only the tool name, so check D passes with count 1 and E passes with count 0 even though the installed fixture was never delivered or activated. A reviewer inspecting skill identity calls the positive control failed; the script reports full success.
**Layer of the implied fix:** L2
**Anchor:** if c.get("name")=="Skill": skill+=1

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring categories are present, so none duplicates a pass/fail gate. Reviewers would diverge most on `../agent-observatory/runner/verify-skill-delivery.sh`: the same unrelated-skill transcript yields D=pass versus D=failed, changing the verifier’s overall result from exit 0 to inconclusive exit 1. The evidence set needed to specify and enforce how an activation is tied to the exact installed skill, and it also needed a shared malformed-input contract: malformed classifier telemetry currently becomes `clean`, while malformed activation telemetry is intended to become an explicit non-success state.
**Layer of the implied fix:** n/a
**Anchor:** n/a


---

## Run 2 of 2 — codex

### tools/check-overlay-parity.sh
**Verdict:** finding
**Failure:** Create overlay A with a directory symlink `.claude/skills -> /tmp/a` and overlay B with `.claude/skills -> /tmp/b`. Because `os.walk(..., followlinks=False)` places directory symlinks in `dirnames` while `rel_files` records only `names`, neither symlink is compared. The script can exit 0 although the overlays install different content.
**Layer of the implied fix:** L2
**Anchor:** for dirpath, _, names in os.walk(root):
        for n in names:
            out.add(os.path.relpath(os.path.join(dirpath, n), root))

### tools/skill-activation.sh
**Verdict:** finding
**Failure:** Use a JSONL file containing a valid JSON array line, `[]`. `json.loads` succeeds, then `doc.get("resourceLogs", [])` raises `AttributeError`; the script exits through an unhandled traceback, typically status 1. One reviewer can classify this as an unparseable telemetry record requiring exit 2, while another can treat it as stream damage requiring exit 4; the documented contract specifies neither outcome for valid JSON that is not an object.
**Layer of the implied fix:** L2
**Anchor:** doc = json.loads(line)
        except json.JSONDecodeError:
            malformed_lines += 1
            continue
        parsed_any = True
        for rl in doc.get("resourceLogs", []):

### ../agent-observatory/runner/lib/classify-skill-contamination.sh
**Verdict:** finding
**Failure:** Invoke the script with skills enabled, no installed skill, and malformed telemetry such as `{`. Both `jq` commands fail, but their stderr and exit status are discarded; `SOURCES` becomes empty and `TOOL_SKILL_CALLS` is coerced to zero. The script prints `clean` and exits 0 even though no contamination classification was possible.
**Layer of the implied fix:** L2
**Anchor:** SOURCES="$(jq -r '[.skillActivations[]? | "\(.source) \(.calls)"] | .[]' <<<"$TELEMETRY" 2>/dev/null)"
TOOL_SKILL_CALLS="$(jq -r '[.toolBreakdown[]? | select(.tool == "Skill") | .calls] | add // 0' <<<"$TELEMETRY" 2>/dev/null)"

### ../agent-observatory/runner/verify-skill-delivery.sh
**Verdict:** finding
**Failure:** Let the enabled probe D succeed with one `Skill` tool use, then make the disabled probe E fail before producing a transcript—for example, a transient authentication or process-start failure. `run_probe` returns nonzero, but its status is ignored; `activated` reads the error output, returns `0 0`, and E is reported as passing. The verifier can therefore exit 0 without having executed the negative control successfully.
**Layer of the implied fix:** L2
**Anchor:** run_probe "$TMP/off.jsonl" "--disable-slash-commands"
  read -r off_skill off_read < <(activated "$TMP/off.jsonl")

  if [[ "$on_skill" -ge 1 ]]; then

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates a pass/fail gate because these artifacts define executable gates but no scoring categories. Reviewers are most likely to diverge on `tools/skill-activation.sh`: for the `[]` JSONL input, the stated exit-code taxonomy supports either invalid input (exit 2) or damaged telemetry (exit 4), a two-class divergence. The evidence set needed to state how non-object JSON is classified, how malformed contamination telemetry is refused, and that both model probes must complete successfully before absence of activation can count as a pass; without those contracts, the concrete inputs above produce crashes or false clean/pass results.
**Layer of the implied fix:** n/a
**Anchor:** n/a

