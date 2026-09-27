# opencode review — SOURCES

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
reviewed_utc:    20260927T183303Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: SOURCES.md
    sha:  be5157d37b4f
    dirty: false
lab_head:        dd26cb3
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Acceptance

The gate failed to run (opencode exit 1).
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 44s |
| codex | ok | 59s |

Stall budget: 900s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| What the check found | 1/1 | L2 |
| Observability | 1/1 | L2 |
| Code intelligence — LSP & MCP | 1/1 | L3 |
| Plugins & distribution | 1/1 | L3 |
| Cross-cutting | 1/1 | n/a |
| Verified sources | 1/1 | L3 |
| ⚠️ One source is a tombstone that returns 200 | 1/1 | L3 |
| Security and trust | 1/1 | L3 |
| Where each extract lives | 1/1 | L3 |


---

## Run 1 of 2 — codex

### Verified sources
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### What the check found
**Verdict:** finding
**Failure:** The reported totals account for only 74 of the stated 76 URLs: 64 ok + 8 moved + 2 blocked + 0 unverified + 0 broken. One reviewer can conclude two URLs were omitted from the results, while another can infer an undocumented status bucket. The later account also says “Two URLs were never checked” but then says “All three went public,” so reviewers can report either two or three skipped links.
**Layer of the implied fix:** L2
**Anchor:** “the same 76 URLs. `ok=64 moved=8 blocked=2 unverified=0 broken=0`” / “Two URLs were never checked at all.” / “All three went public”

### Agent loop / mental model
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Observability
**Verdict:** finding
**Failure:** A reviewer following the GenAI semantic-conventions row uses the linked page as the current normalization authority because it is marked ✅. The later tombstone section establishes that this exact URL is no longer maintained and that the content moved, so another reviewer follows the replacement repository; the two reviewers can normalize against different specifications.
**Layer of the implied fix:** L2
**Anchor:** “✅ | [OpenTelemetry — GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/) | The vocabulary your normalization layer should target instead of vendor span names”

### Instructions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Prompt files / reusable workflows
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Skills
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Agents & permissions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hooks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Code intelligence — LSP & MCP
**Verdict:** finding
**Failure:** On a supported Copilot surface with “Registry only” enabled, configure an MCP server whose name/ID is absent from the registry without editing the enforcement configuration. The client executes the name/ID check and rejects that server, which is L2 under the supplied layer test; the artifact labels the entire mechanism L3 because another actor can bypass it by editing configuration. A reviewer applying the stated layer model therefore records L2 while a reviewer following this section records L3.
**Layer of the implied fix:** L3
**Anchor:** “every other surface carries a client version floor. **This is L3, not a boundary**”

### Plugins & distribution
**Verdict:** finding
**Failure:** Write an archive plugin source with an incorrect `sha256`. The invalid digest remains representable in configuration, and the installer must execute a digest comparison before refusing installation. Under the stated layer test this is L2, but the artifact calls the refusal L1; two reviewers will classify the same control one layer apart.
**Layer of the implied fix:** L3
**Anchor:** “Two **L1** refusals exist — an `archive` source pinned to a `sha256` digest whose download must match, and the community catalog's commit-SHA pin where *"Claude Code refuses to install a different commit"*”

### Agentic workflows (gh-aw)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Memory
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Governance
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### ⚠️ One source is a tombstone that returns 200
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sources the curriculum does not cite but you will need
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Agent design and orchestration
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Context and knowledge
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Security and trust
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Flags, telemetry and the things that bit us
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Where each extract lives
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates a pass/fail gate because the artifact defines no scoring categories or pass/fail gates. Reviewers are most likely to diverge on “Code intelligence — LSP & MCP,” by one full layer: L2 versus L3. The artifact needed to state how every one of the 76 URLs maps into the reported status totals, and it needed to apply its executable-rejection test consistently when assigning layers.
**Layer of the implied fix:** n/a
**Anchor:** n/a


---

## Run 2 of 2 — codex

### Verified sources
**Verdict:** finding
**Failure:** A reviewer treating “checked on 2026-08-28” as the verification date will report the September additions as unverified, while another will accept their row-level 2026-09-27 checks. For example, the Codex Plugins row says it was read on 2026-09-27, which cannot be part of an evidence set described as entirely checked on 2026-08-28.
**Layer of the implied fix:** L3
**Anchor:** Every URL the curriculum cites, checked with `curl -sSL` on **2026-08-28**.

### What the check found
**Verdict:** finding
**Failure:** A permanently dead host and a temporary connection failure can both produce curl status `000`. After one retry, both become non-fatal `unverified`, so a pre-cohort run can exit successfully even when a required source is permanently unreachable. One reviewer may allow the cohort because the script passed; another may stop because the legend says ⚠️ is “not a pass.”
**Layer of the implied fix:** L2
**Anchor:** `000` now retries once and then lands in ⚠️ `unverified`: not ok, not broken, non-fatal, and yours to resolve

### Agent loop / mental model
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Observability
**Verdict:** finding
**Failure:** One reviewer following the table will use the unmaintained OpenTelemetry GenAI page as the normalization authority, while another following the later tombstone warning will use the replacement repository. The same input—a vendor span being mapped to the current convention—can therefore receive fields from different convention versions.
**Layer of the implied fix:** L3
**Anchor:** The vocabulary your normalization layer should target instead of vendor span names

### Instructions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Prompt files / reusable workflows
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Skills
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Agents & permissions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hooks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Code intelligence — LSP & MCP
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Plugins & distribution
**Verdict:** finding
**Failure:** An archive whose bytes do not match its declared SHA-256 can still be authored and submitted; the installer must execute, calculate the digest, and refuse installation. Under the stated layer test this is L2, but the artifact calls it L1. A reviewer applying the lab’s algorithm and one trusting this section will classify the same control differently. The commit-SHA installation refusal has the same secondary problem.
**Layer of the implied fix:** L2
**Anchor:** Two **L1** refusals exist — an `archive` source pinned to a `sha256` digest whose download must match, and the community catalog's commit-SHA pin where *"Claude Code refuses to install a different commit"*

### Agentic workflows (gh-aw)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Memory
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Governance
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### ⚠️ One source is a tombstone that returns 200
**Verdict:** finding
**Failure:** The warning identifies the replacement repository but leaves the earlier Observability row marked ✅ and still instructing readers to use the tombstone. Given the same source-selection task, one reviewer will accept the ✅ URL while another will reject it based on this section; the artifact has no precedence rule resolving the conflict.
**Layer of the implied fix:** L3
**Anchor:** No link checker catches this — only reading does.

### Sources the curriculum does not cite but you will need
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Agent design and orchestration
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Context and knowledge
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Security and trust
**Verdict:** finding
**Failure:** For an attempted write outside the allowed filesystem, a sandbox policy executes and denies the operation. Under the artifact’s required decision procedure, that is L2 unless the capability is structurally absent before execution. One reviewer will therefore classify the sandbox as L2, while another will follow this row and call it L1.
**Layer of the implied fix:** L3
**Anchor:** What a real Layer 1 boundary looks like

### Flags, telemetry and the things that bit us
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Where each extract lives
**Verdict:** finding
**Failure:** If Phase 7 gains an extract and only its phase directory changes, this hand-maintained sentence will continue claiming it is missing. A reviewer inspecting the directory will report complete coverage while a reviewer trusting this table will report a gap; the artifact itself says no executed check rejects that inconsistency.
**Layer of the implied fix:** L3
**Anchor:** **Still without an extract:** 7 — tracked in issue #17.

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring categories exist, so none duplicates a pass/fail gate. Reviewers are most likely to diverge on “Plugins & distribution”: the stated algorithm yields L2 for both installer refusals, while the artifact assigns L1—a one-layer difference. The artifact needed to state which verification date governs the document, how unresolved `000` results affect cohort readiness, and which source wins when a ✅ table row conflicts with a later tombstone warning.
**Layer of the implied fix:** n/a
**Anchor:** n/a

