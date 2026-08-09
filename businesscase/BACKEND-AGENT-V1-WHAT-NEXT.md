# Backend Feature Implementer v1 — What Comes Next

## 1. Current Status

Backend Feature Implementer v1 has been delivered.

Completed v1 assets:

```text
.github/
├── agents/backend-feature-implementer.agent.md
├── hooks/
├── instructions/
├── scripts/agent-verify.sh
├── copilot-instructions.md
└── pull_request_template.md

knowledge/
├── index.yaml
├── build-commands.md
└── failure-patterns.md

samples/
└── feature-spec-template.md

evaluation/
├── README.md
├── agent-runs.csv
└── record-run.sh
```

V1 already defines:

- repository-scoped backend implementation agent
- ANALYSIS → DESIGN → IMPLEMENTATION lifecycle
- deterministic verification
- bounded self-healing rules
- compact knowledge routing
- safety hooks
- reusable build and failure knowledge
- minimal CSV evaluation

Current conclusion:

```text
Agent v1 implementation: COMPLETE
Repository benchmark setup: NOT COMPLETE
Observability v0.1: NOT COMPLETE
Pilot evaluation: NOT STARTED
Real-task validation: NOT STARTED
```

The next work is not to redesign the agent.

The next work is to prove that v1 works.

---

# 2. Recommended Roadmap

```text
1. Freeze v1
2. Build observability v0.1
3. Prepare the canonical benchmark fixture
4. Prepare baseline and custom-agent repositories
5. Freeze the experiment contract
6. Run one controlled pilot
7. Run the hidden evaluator and human review
8. Record and compare results
9. Use v1 on five real tasks
10. Decide whether v1.1 or v1.2 is needed
11. Add advanced observability only when justified
```

Do not skip directly to dashboards or v2.

---

# Phase 1 — Freeze Backend Agent v1

## Goal

Create one immutable, authoritative v1 definition before testing.

## Why

The evaluation is invalid when agent files change during or between runs.

## TODO

- [ ] Verify the final agent frontmatter.
- [ ] Resolve the final model strategy.
- [ ] Decide whether the agent inherits the selected session model.
- [ ] Set deterministic manual invocation.
- [ ] Verify all v1 files are present.
- [ ] Verify script permissions.
- [ ] Verify hook JSON.
- [ ] Verify Bash syntax.
- [ ] Commit or tag v1.
- [ ] Record the v1 commit hash.

## Recommended frontmatter for evaluation

```yaml
---
name: backend-feature-implementer
description: Implements Spring Boot MVC backend features in Kotlin or Java with tests, deterministic verification, and bounded self-healing.
tools: ["read", "search", "edit", "execute"]
disable-model-invocation: true
user-invocable: true
---
```

For the pilot, prefer choosing the same model manually for baseline and candidate instead of pinning a model inside the agent.

## Verification

```bash
sed -n '1,25p' .github/agents/backend-feature-implementer.agent.md

jq . .github/hooks/backend-agent-hooks.json >/dev/null

bash -n .github/scripts/agent-verify.sh
bash -n .github/hooks/scripts/session-start.sh
bash -n .github/hooks/scripts/pre-tool-policy.sh
bash -n .github/hooks/scripts/post-tool-failure.sh

git status --short
```

## Deliverable

```text
V1-RELEASE-NOTES.md
```

Suggested metadata:

```yaml
agent_version: v1.0.0
git_commit:
model_strategy:
repair_limits:
supported_stack:
known_limitations:
```

## Acceptance gate

- [ ] All static checks pass.
- [ ] One v1 source of truth exists.
- [ ] V1 files are committed.
- [ ] No v1 file changes during the pilot.

---

# Phase 2 — Build Observability v0.1

## Goal

Collect enough evidence to understand:

- whether the result is correct
- how much it cost
- how long it took
- how many failures occurred
- whether v1 followed its intended workflow

## Scope

Use local files only.

Do not deploy Grafana, Prometheus, Tempo, Jaeger, or an OpenTelemetry Collector yet.

## Run artifact structure

```text
observability/
└── runs/
    └── <run-id>/
        ├── run-metadata.json
        ├── copilot-otel.jsonl
        ├── lifecycle-events.jsonl
        ├── verification.json
        ├── git-metrics.json
        ├── human-review.json
        └── summary.json
```

## TODO

- [ ] Create `observability/runs/`.
- [ ] Define a run ID convention.
- [ ] Enable Copilot OpenTelemetry file export.
- [ ] Keep prompt/source-content capture disabled.
- [ ] Create a session wrapper script.
- [ ] Add structured verification output.
- [ ] Add Git metric collection.
- [ ] Add a human-review template.
- [ ] Generate a normalized `summary.json`.
- [ ] Continue appending a compact row to `evaluation/agent-runs.csv`.

## Run ID convention

```text
<task>-<variant>-<UTC timestamp>
```

Example:

```text
shipment-confirmation-custom-agent-20260721T140500Z
```

## Required metrics

### Quality

```text
accepted
visible tests
hidden tests
Maven verify
first-pass success
blocking defects
material review corrections
```

### Cost

```text
AI credits
input tokens
output tokens
cache-read tokens
cache-created tokens
total tokens
```

### Performance

```text
session duration
time to green
model turns
tool calls
failed tool calls
repair attempts
```

### Change size

```text
files changed
lines added
lines removed
production files
test files
migration files
dependency changes
```

## Acceptance gate

- [ ] A dry run creates all expected files.
- [ ] OTel JSONL is valid JSON Lines.
- [ ] Verification output is structured.
- [ ] Git metrics can be reproduced from a starting commit.
- [ ] No source code or prompt content is unintentionally exported.
- [ ] Existing CSV workflow still works.

---

# Phase 3 — Prepare the Canonical Benchmark Fixture

## Goal

Create one validated Spring Boot starter that becomes the common base for both variants.

## Repository

```text
repos/.shipment-template
```

## Required stack

```text
Kotlin
Maven
Java 21
Spring Boot
Spring MVC
Validation
Spring Data JPA
Flyway
H2
Kotest
MockK
```

## Existing behavior

The starter must support:

```http
GET /api/v1/shipments/{shipmentId}
```

It must not support:

```http
POST /api/v1/shipments/{shipmentId}/confirm
```

## TODO

- [ ] Generate one project with Spring CLI.
- [ ] Add the shipment domain.
- [ ] Add JPA entity and repository.
- [ ] Keep optimistic locking with `@Version`.
- [ ] Add Flyway migrations.
- [ ] Add seed data.
- [ ] Add the carrier gateway boundary.
- [ ] Add the existing GET endpoint.
- [ ] Add starter tests.
- [ ] Copy `001-confirm-shipment.md`.
- [ ] Confirm the target POST endpoint is absent.
- [ ] Run `./mvnw test`.
- [ ] Run `./mvnw verify`.
- [ ] Commit the canonical starter.
- [ ] Store the hash in `repos/START-COMMIT.txt`.

## Acceptance gate

```text
starter tests = PASS
Maven verify = PASS
GET endpoint works
POST confirmation endpoint absent
working tree clean
canonical commit recorded
```

---

# Phase 4 — Prepare the Two Evaluation Repositories

## Goal

Create two comparable repositories from the exact same canonical commit.

## Repositories

```text
repos/shipment-baseline
repos/shipment-agent-v1
```

## Baseline

Contains:

```text
canonical application
same specification
same tests
same dependencies
no v1 agent
no v1 knowledge
no v1 hooks
```

## Candidate

Contains:

```text
same canonical application
same specification
same tests
same dependencies
complete backend-agent v1 package
repository-calibrated build commands
```

## Baseline TODO

- [ ] Clone from the canonical starter.
- [ ] Use `git clone --no-hardlinks`.
- [ ] Remove the local origin.
- [ ] Confirm HEAD equals `START-COMMIT.txt`.
- [ ] Confirm v1 files are absent.
- [ ] Run tests.
- [ ] Run verify.
- [ ] Confirm target feature is absent.
- [ ] Confirm the working tree is clean.

## Candidate TODO

- [ ] Clone from the canonical starter.
- [ ] Confirm the base commit equals `START-COMMIT.txt`.
- [ ] Copy the complete v1 package.
- [ ] Make scripts executable.
- [ ] Validate hooks and scripts.
- [ ] Calibrate `knowledge/build-commands.md`.
- [ ] Run compile.
- [ ] Run all tests.
- [ ] Run one focused test.
- [ ] Run verify.
- [ ] Run `agent-verify.sh all`.
- [ ] Commit v1 installation separately.
- [ ] Confirm the target feature is absent.
- [ ] Confirm the working tree is clean.

## Expected candidate history

```text
chore: install and calibrate backend agent v1
chore: create validated shipment benchmark starter
```

## Acceptance gate

- [ ] Both share the same canonical application base.
- [ ] Baseline has no v1 assets.
- [ ] Candidate has complete v1 assets.
- [ ] Both pass verification.
- [ ] Neither contains the target feature.
- [ ] Both working trees are clean.

---

# Phase 5 — Freeze the Experiment Contract

## Goal

Define the comparison before running either session.

## Unit under test

```text
normal Copilot
versus
complete backend-agent v1 package
```

The pilot does not isolate the value of each individual v1 component.

## Shared task

Create:

```text
EVALUATION-TASK.md
```

Recommended content:

```md
# Evaluation Task

Implement the backend feature described in:

`specifications/001-confirm-shipment.md`

Requirements:

- follow the existing repository architecture and conventions
- implement the complete required behavior
- add meaningful automated tests
- do not introduce unrelated refactoring
- do not add an unnecessary database migration
- do not upgrade dependencies
- preserve the existing GET shipment endpoint
- finish only after repository verification succeeds or report the exact blocker
- do not inspect hidden evaluator tests
```

Use exactly the same file in both repositories.

## Fairness controls

- [ ] Same canonical application base.
- [ ] Same feature specification.
- [ ] Same task prompt.
- [ ] Same model.
- [ ] Same Copilot CLI version.
- [ ] Same Java version.
- [ ] Same final verification.
- [ ] Same hidden evaluator.
- [ ] Equivalent command approvals.
- [ ] Fresh session for each run.
- [ ] Hidden tests unavailable during implementation.
- [ ] Run order chosen before starting.

## Metric definitions

### Repair attempt

```text
A modification made after a verification failure,
followed by another verification run.
```

### Material review correction

```text
A required human-requested change after the agent declares completion.
```

### Accepted

```text
visible tests PASS
Maven verify PASS
hidden evaluator PASS
human review ACCEPTED
```

## Deliverable

```text
EXPERIMENT-CONTRACT.yaml
```

## Acceptance gate

- [ ] Contract is complete.
- [ ] Inputs are frozen.
- [ ] Metric definitions are agreed.
- [ ] Run order is recorded.
- [ ] No evaluation session has started.

---

# Phase 6 — Run the Pilot Evaluation

## Goal

Validate the complete workflow with two feature sessions.

## Baseline run

```text
variant: baseline
repository: repos/shipment-baseline
agent: normal Copilot
```

## Candidate run

```text
variant: custom-agent
repository: repos/shipment-agent-v1
agent: backend-feature-implementer
```

## Before each run

- [ ] Confirm the working tree is clean.
- [ ] Record the starting commit.
- [ ] Record Copilot CLI version.
- [ ] Record Java version.
- [ ] Record the selected model.
- [ ] Start the observability wrapper.
- [ ] Verify loaded instructions.
- [ ] Verify the correct agent configuration.

## During each run

- [ ] Use the same `EVALUATION-TASK.md`.
- [ ] Do not manually suggest fixes.
- [ ] Approve equivalent commands.
- [ ] Do not inspect hidden tests.
- [ ] Let the session finish or report a blocker.

## After each run

- [ ] Capture `/usage`.
- [ ] Run independent visible tests.
- [ ] Run independent Maven verification.
- [ ] Collect Git metrics.
- [ ] Finalize observability artifacts.

## Candidate-only behavior checks

- [ ] ANALYSIS visible.
- [ ] DESIGN visible.
- [ ] No code changes before DESIGN.
- [ ] Verification script used.
- [ ] SELF_HEALING only after failure.
- [ ] Repair limits respected.
- [ ] REVIEW performed.
- [ ] DONE includes evidence.

---

# Phase 7 — Run the Hidden Evaluator

## Goal

Test both implementations against the same unseen API-level behavior.

## Rules

- keep the evaluator outside both repositories
- run it only after both implementation sessions
- use the same evaluator version
- remove hidden tests after each run

## TODO

- [ ] Evaluate baseline.
- [ ] Record PASS or FAIL.
- [ ] Evaluate candidate.
- [ ] Record PASS or FAIL.
- [ ] Confirm hidden test cleanup.
- [ ] Store evaluator version or checksum.

## Acceptance gate

- [ ] Both runs were evaluated identically.
- [ ] Neither implementation session had access to hidden tests.
- [ ] Results are included in `summary.json` and CSV notes.

---

# Phase 8 — Perform Human Review

## Goal

Apply the same architecture and code-quality review to both results.

## Review checklist

- [ ] No unnecessary migration.
- [ ] No unnecessary dependency.
- [ ] Existing GET endpoint remains correct.
- [ ] Tests were not weakened.
- [ ] No broad suppressions.
- [ ] No unrelated refactoring.
- [ ] Gateway is not called twice for an idempotent retry.
- [ ] Carrier failure leaves the shipment in `DRAFT`.
- [ ] Same key and same body is idempotent.
- [ ] Same key and different service level returns conflict.
- [ ] Different key after confirmation returns conflict.
- [ ] Missing shipment returns 404.
- [ ] Carrier rejection returns 422.
- [ ] Carrier unavailability returns 503.
- [ ] Optimistic locking remains enabled.
- [ ] Error contract remains consistent.
- [ ] Code follows repository conventions.
- [ ] Tests cover meaningful behavior.

## Human scoring

Use 1–5 for:

```text
correctness
architecture
test quality
maintainability
```

Also record:

```text
blocking defects
material review corrections
accepted yes/no
```

---

# Phase 9 — Record and Compare the Pilot

## Record

Run:

```bash
./evaluation/record-run.sh
```

Create exactly two rows:

```text
baseline
custom-agent v1
```

## Quality gate

Do not compare efficiency unless both satisfy:

```text
visible tests = PASS
Maven verify = PASS
hidden evaluator = PASS
human review = ACCEPTED
```

## Compare

```text
AI credits
total tokens
session duration
time to green
repair attempts
tool failure rate
files changed
lines changed
material review corrections
first-pass success
```

## Main question

```text
Which approach used fewer resources and required fewer corrections
to produce a quality-accepted implementation?
```

## Pilot outcome

Choose one:

```text
PIPELINE VALIDATED
PIPELINE NEEDS FIXES
V1 HAS A CORRECTNESS BLOCKER
```

Do not claim general superiority from one task.

---

# Phase 10 — Use v1 on Five Real Tasks

## Goal

Measure v1 on real work without duplicating every task.

## Approach

For the next five real backend features:

```text
use custom-agent v1 only
collect observability
run independent verification
perform normal review
append one CSV row
```

Do not create a baseline copy for every task.

## TODO

- [ ] Select five representative backend tasks.
- [ ] Use the same v1 release.
- [ ] Capture observability for each.
- [ ] Record acceptance.
- [ ] Record repair attempts.
- [ ] Record review corrections.
- [ ] Record tokens, credits, and duration.
- [ ] Calculate medians after five tasks.

## Summary metrics

```text
acceptance rate
first-pass success rate
median AI credits
median tokens
median time to green
median repair attempts
median review corrections
```

## Acceptance gate

- [ ] At least five completed tasks.
- [ ] No unresolved safety defect.
- [ ] No lifecycle-bypass pattern.
- [ ] Metrics are complete enough for a v1 decision.

---

# Phase 11 — Decide the Next Agent Version

## Decision A — Keep v1

Choose when:

- correctness is stable
- hidden behavior passes
- review effort is low
- repair behavior is controlled
- cost is acceptable

Action:

```text
tag v1 as stable
document usage
use it on more real tasks
```

## Decision B — Build v1.1

Use for correctness and reliability fixes.

Potential scope:

- hard-enforce repair counters
- improve failure classification
- add `subagentStart` context
- improve lifecycle markers
- protect unrelated changes
- improve test quality
- fix command selection

Do not add efficiency work until correctness is stable.

## Decision C — Stop v1

Choose when:

- correctness is worse than baseline
- verification is bypassed
- tests are weakened
- repair loops are unsafe
- maintenance cost exceeds value

---

# Phase 12 — Build v1.2 for Efficiency

Start only after correctness is stable.

## Possible goals

- reduce repeated file reads
- reduce repeated Maven stages
- improve focused-test selection
- improve context cache reuse
- reduce token consumption
- reduce AI-credit consumption
- reduce repair attempts
- improve compact knowledge summaries

## Verification rule

V1.2 must maintain or improve:

```text
acceptance rate
hidden-test success
human-review quality
```

Efficiency improvements are rejected when quality declines.

---

# Phase 13 — Advanced Observability Later

Build only when local JSON artifacts and five real tasks show a real need.

Possible stack:

```text
Copilot CLI
→ OTLP
→ OpenTelemetry Collector
→ Prometheus or Mimir
→ Tempo or Jaeger
→ Grafana
```

Possible later features:

- automatic trace storage
- model-call analysis
- tool-call dashboards
- cache-efficiency trends
- cross-task comparisons
- repeated benchmark analysis

Do not build this before the local observability format is stable.

---

# Immediate Next Actions

## Action 1 — Freeze v1

Deliver:

```text
V1-RELEASE-NOTES.md
```

## Action 2 — Build Observability v0.1

Deliver:

```text
observability session wrapper
run artifact schema
structured verification output
Git metric collector
human-review template
summary generator
```

## Action 3 — Prepare repositories

Use Codex to create:

```text
repos/.shipment-template
repos/shipment-baseline
repos/shipment-agent-v1
```

## Action 4 — Freeze the experiment

Create:

```text
EXPERIMENT-CONTRACT.yaml
EVALUATION-TASK.md
```

## Action 5 — Run the two-session pilot

Only after all previous gates pass.

---

# Master Status

## Completed

- [x] Custom agent v1 designed.
- [x] Agent lifecycle defined.
- [x] Scoped instructions created.
- [x] Knowledge routing created.
- [x] Verification script created.
- [x] Hooks created.
- [x] Minimal evaluation CSV created.
- [x] Shipment feature specification created.
- [x] Repository-preparation instructions created.

## Next

- [ ] Freeze v1 release.
- [ ] Build observability v0.1.
- [ ] Generate canonical starter.
- [ ] Create baseline repository.
- [ ] Create candidate repository.
- [ ] Freeze experiment contract.
- [ ] Run pilot baseline.
- [ ] Run pilot candidate.
- [ ] Run hidden evaluator.
- [ ] Perform human review.
- [ ] Record two CSV rows.
- [ ] Decide whether the evaluation pipeline is valid.

## Later

- [ ] Run five real v1 tasks.
- [ ] Decide whether v1.1 is required.
- [ ] Optimize efficiency in v1.2.
- [ ] Add centralized observability only when justified.

---

# Current Project State

```text
Backend Agent v1: DELIVERED
Evaluation CSV: DELIVERED
Benchmark Specification: DELIVERED
Repository Preparation: READY TO EXECUTE
Observability v0.1: NEXT
Pilot Evaluation: AFTER REPOSITORY PREPARATION
Production Adoption: NOT YET
```

The immediate priority is:

```text
Freeze v1
→ Build observability v0.1
→ Prepare the two repositories
→ Run the pilot
```
