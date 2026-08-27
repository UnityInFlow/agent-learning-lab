# Backend Feature Implementer — Efficiency and Self-Learning Design

## 1. Executive Summary

Backend Feature Implementer v1 already contains the foundations for:

- context efficiency
- deterministic verification
- bounded self-healing
- repository-specific reusable knowledge
- safe automatic knowledge updates

However, v1 does **not** yet contain a complete autonomous learning system.

Current v1 is best described as:

```text
repository-aware
verification-driven
repair-capable
knowledge-updating
```

It is not yet:

```text
fully observable
hard-limit enforced
confidence-scored
automatically promoted
automatically expired
cross-run optimized
```

The recommended evolution is:

```text
v1.0 — existing agent foundations
v1.1 — reliability and observability
v1.2 — efficiency and context optimization
v1.3 — governed self-learning
v2.0 — only later, advanced orchestration
```

---

# 2. What We Already Have in v1

## 2.1 Context efficiency

V1 already defines a good retrieval order:

```text
knowledge/index.yaml
→ build commands
→ relevant compact knowledge
→ relevant instructions
→ one or two similar implementations
→ affected source files
→ broader context only when required
```

Existing efficiency rules include:

- do not load the full repository
- do not load all instructions by default
- do not reread unchanged files
- prefer compact knowledge artifacts
- restrict similar implementation lookup
- avoid full build logs in context
- maintain a compact active working state

This is a strong foundation.

### Current maturity

```text
DESIGNED: yes
PROMPT-ENFORCED: yes
TECHNICALLY MEASURED: no
HARD-ENFORCED: no
```

---

## 2.2 Self-healing

V1 already defines:

```text
failure
→ classify
→ inspect targeted evidence
→ find likely root cause
→ apply smallest repair
→ rerun failed check
→ continue verification
```

It also defines repair limits:

```text
MAX_REPAIR_ATTEMPTS_PER_FAILURE = 3
MAX_TOTAL_REPAIR_ATTEMPTS = 7
```

### Current maturity

```text
DESIGNED: yes
PROMPT-ENFORCED: yes
PERSISTENT COUNTERS: no
HARD STOP: no
CROSS-RUN ANALYSIS: no
```

The agent knows the limits, but no state file or hook currently guarantees them.

---

## 2.3 Reusable learning

V1 permits automatic updates to:

```text
knowledge/build-commands.md
knowledge/failure-patterns.md
```

The update rules are already strong:

- repository-specific
- verified
- compact
- reusable
- no full logs
- no guesses
- no one-time incidents
- no duplication

A failure pattern requires:

```text
symptom
cause
fix
avoid
```

This is already a form of self-learning.

### Important distinction

This is not model training.

It is:

```text
repository memory updated from verified execution evidence
```

That is the correct and safest type of self-learning for this project.

### Current maturity

```text
WRITE-BACK ALLOWED: yes
EVIDENCE RULES: yes
AUTOMATIC CANDIDATE EXTRACTION: no
CONFIDENCE SCORE: no
PROMOTION WORKFLOW: no
EXPIRATION: no
ROLLBACK: no
```

---

## 2.4 Verification

V1 already has a stable verification entry point:

```text
.github/scripts/agent-verify.sh
```

It provides:

- Maven wrapper preference
- stage-based execution
- focused-test support
- optional detekt, ktlint, and integration stages
- compact console output
- detailed log files
- explicit `NOT_CONFIGURED`

This is the strongest part of v1 because it converts agent claims into executable evidence.

---

# 3. What Is Missing

## 3.1 No persistent run state

The agent describes this active state:

```yaml
goal:
current_state:
completed_steps:
open_questions:
affected_module:
affected_files:
last_failure:
repair_attempts:
```

But it is not persisted in a structured file.

Missing:

```text
.agent/run-state.json
```

Without persistent state:

- repair limits are soft
- phase transitions cannot be audited
- interrupted sessions cannot resume safely
- repeated failures are difficult to identify
- learning evidence is harder to correlate

---

## 3.2 No structured observability

Current outputs are mostly:

- transcript
- Maven logs
- verification console summary
- CSV row

Missing:

- lifecycle events
- tool-call statistics
- failed-command timeline
- repair timeline
- time-to-green
- context-read counts
- repeated-read counts
- learning updates per run
- knowledge hit versus miss data

---

## 3.3 No governed learning pipeline

Currently, the agent can write directly to knowledge files after verified work.

This is safe enough for a pilot but not ideal for mature usage.

Missing stages:

```text
observation
→ learning candidate
→ validation
→ confidence calculation
→ promotion
→ usage tracking
→ revalidation
→ expiration
```

---

## 3.4 No knowledge provenance

Each learned item should answer:

```text
Where did this knowledge come from?
Which commit verified it?
Which command proved it?
How many times has it succeeded?
When was it last revalidated?
```

Current Markdown entries support some metadata, but the whole system does not enforce it.

---

## 3.5 No automatic context cache

V1 says not to reread unchanged files, but it does not maintain:

```text
file fingerprint
last summary
summary version
source commit
last used
```

Therefore, context efficiency depends mostly on agent discipline.

---

# 4. Recommended Architecture

Use a controlled learning loop:

```text
TASK
  ↓
RETRIEVAL PLAN
  ↓
IMPLEMENTATION
  ↓
VERIFICATION
  ↓
OBSERVATION
  ↓
LEARNING CANDIDATE
  ↓
VALIDATION
  ↓
PROMOTION TO KNOWLEDGE
  ↓
FUTURE REUSE
```

The critical rule is:

```text
Only verified outcomes may become reusable knowledge.
```

Never learn from:

- assumptions
- failed repairs
- temporary outages
- unverified commands
- one-off developer preferences
- full raw logs
- secrets
- hidden evaluator content

---

# 5. Version 1.1 — Reliability and Observability

## Goal

Make v1 behavior measurable and harden its safety boundaries.

## 5.1 Persistent run state

Create:

```text
.agent/run-state.json
```

Suggested schema:

```json
{
  "schemaVersion": "1.0",
  "runId": "shipment-confirmation-custom-agent-20260721T140500Z",
  "taskId": "shipment-confirmation",
  "agentVersion": "v1.1",
  "phase": "VERIFICATION",
  "goal": "Implement shipment confirmation",
  "affectedModule": "shipment-service",
  "affectedFiles": [],
  "completedSteps": [],
  "openQuestions": [],
  "lastFailure": null,
  "repairAttemptsForCurrentFailure": 0,
  "totalRepairAttempts": 0,
  "verification": {}
}
```

## 5.2 Hard repair limits

Hooks or helper scripts should enforce:

```text
attempts for same failure <= 3
total attempts <= 7
```

Define a failure fingerprint:

```text
failure class
+
command
+
normalized primary error
+
affected module
```

When the same fingerprint exceeds the limit:

```text
stop
emit BLOCKED result
require human decision
```

## 5.3 Lifecycle events

Create:

```text
.agent/observability/lifecycle-events.jsonl
```

Events:

```text
run_started
phase_started
phase_completed
verification_started
verification_failed
repair_started
repair_completed
learning_candidate_created
learning_candidate_promoted
review_completed
run_completed
run_blocked
```

## 5.4 Structured verification

Extend `agent-verify.sh` to write:

```text
.agent/observability/verification.json
```

Include:

- stage
- command
- start time
- end time
- duration
- exit code
- status
- log path
- first-pass status

## 5.5 Candidate-only lifecycle markers

Require the agent to print:

```text
PHASE: ANALYSIS
PHASE: DESIGN
PHASE: IMPLEMENTATION
PHASE: VERIFICATION
PHASE: SELF_HEALING
PHASE: REVIEW
PHASE: DONE
```

## v1.1 acceptance criteria

- [ ] Repair counters persist.
- [ ] Repair limits are technically enforced.
- [ ] Every phase transition is observable.
- [ ] Verification is emitted as structured data.
- [ ] A blocked run produces a clear machine-readable result.
- [ ] No behavior regression against v1 benchmark.

---

# 6. Version 1.2 — Efficiency and Context Optimization

## Goal

Reduce unnecessary reads, searches, commands, tokens, and repair cycles without reducing quality.

## 6.1 Task classifier

Before broad retrieval, classify the task:

```text
API
JPA
Kafka
cache
external client
security
build
test-only
migration
mixed
```

Output:

```yaml
task_type:
affected_layers:
required_instructions:
required_knowledge:
expected_verification:
```

This controls what the agent loads.

## 6.2 Retrieval budget

Define explicit limits:

```yaml
max_similar_implementations: 2
max_initial_searches: 5
max_files_before_design: 15
max_broad_searches: 1
max_full_log_lines: 0
```

Allow exceeding the budget only with a recorded reason.

## 6.3 File-summary cache

Create:

```text
.agent/cache/file-summaries.json
```

Each entry:

```json
{
  "path": "src/main/kotlin/.../ShipmentService.kt",
  "sha256": "...",
  "sourceCommit": "...",
  "summary": "Application service responsible for...",
  "lastUsedAt": "...",
  "summaryVersion": 1
}
```

Rules:

- reuse summary only when the file hash matches
- regenerate after file changes
- never trust a stale summary
- keep summaries compact

## 6.4 Knowledge-hit metrics

Record for every run:

```text
knowledge files loaded
knowledge entries matched
knowledge entries used
knowledge misses
broad searches
repeated reads
```

Important KPI:

```text
knowledge_hit_rate =
useful knowledge matches /
knowledge lookups
```

## 6.5 Verification planner

Select the smallest safe verification sequence based on impact.

Example:

```text
controller-only:
compile → controller test → verify

JPA change:
compile → repository/service tests → Spring integration test → verify

format-only:
ktlint → verify

build change:
compile → test → verify
```

Final independent verification remains unchanged.

## 6.6 Command deduplication

Track commands already run against the current code fingerprint.

Do not rerun an unchanged successful command unless:

- a related file changed
- configuration changed
- broader verification requires it
- the prior result is stale

## v1.2 acceptance criteria

Compared with v1.1:

- [ ] Same or better acceptance rate.
- [ ] Same hidden-test success.
- [ ] Fewer repeated reads.
- [ ] Fewer unnecessary tool calls.
- [ ] Lower median input tokens.
- [ ] Lower median time to green.
- [ ] No increase in material review corrections.

---

# 7. Version 1.3 — Governed Self-Learning

## Goal

Turn verified run outcomes into durable repository knowledge without allowing uncontrolled knowledge pollution.

## 7.1 Do not write directly to active knowledge

Instead, write candidates to:

```text
knowledge/candidates/
```

Example:

```text
knowledge/candidates/20260721-maven-focused-test-selector.yaml
```

## 7.2 Learning candidate schema

```yaml
id: maven-focused-test-selector
type: build-command
status: candidate

scope:
  repository: shipment-service
  module: root
  technologies:
    - Maven
    - Kotest

observation:
  symptom: Focused test did not run using the original selector
  cause: Repository requires the JVM test class name
  proposed_knowledge: Use -Dtest=ShipmentQueryServiceTest

evidence:
  source_run_id:
  source_commit:
  command:
  exit_code: 0
  focused_verification: PASS
  broader_verification: PASS

confidence:
  score: 0.8
  successful_uses: 1
  failed_uses: 0

governance:
  created_at:
  last_verified_at:
  expires_after_days: 90
  requires_human_approval: true
```

## 7.3 Promotion rules

A candidate may become active knowledge when:

```text
verified in the source run
broader verification passed
no conflicting active knowledge exists
scope is precise
content is compact
no secrets exist
```

Recommended initial policy:

```text
build commands:
  one successful verification + human approval

failure patterns:
  two successful occurrences + human approval

style or architecture patterns:
  human approval always required
```

## 7.4 Knowledge states

```text
candidate
active
deprecated
rejected
expired
```

Never delete immediately. Preserve history through status changes.

## 7.5 Confidence

Suggested score inputs:

```text
successful reuse count
failed reuse count
age
scope precision
broader verification result
human approval
```

Example simplified calculation:

```text
confidence =
(successful_uses + 1) /
(successful_uses + failed_uses + 2)
```

Do not use confidence as the sole promotion decision.

## 7.6 Revalidation

Before using old knowledge:

- confirm repository scope
- confirm module scope
- confirm relevant files or build config have not changed
- check expiration
- rerun lightweight validation when required

## 7.7 Automatic rollback

When active knowledge causes failure:

```text
mark suspect
stop reuse
fall back to discovery
create a correction candidate
```

Do not silently overwrite the original entry.

## v1.3 acceptance criteria

- [ ] All automatic learning has provenance.
- [ ] No direct uncontrolled writes to active knowledge.
- [ ] Promotion rules are enforced.
- [ ] Stale knowledge expires or revalidates.
- [ ] Conflicting knowledge is detected.
- [ ] A bad learned item can be rolled back.
- [ ] Learning improves future runs measurably.

---

# 8. What Should Be Learned

Good learning targets:

## Build knowledge

```text
correct module selector
Maven profile
focused-test syntax
integration-test command
required environment variables
local infrastructure requirements
```

## Failure knowledge

```text
MockK mismatch specific to repository conventions
Spring test slice missing repository bean
JPA lazy-loading boundary
Flyway/H2 compatibility issue
repository-specific formatter invocation
```

## Repository patterns

Only with stronger governance:

```text
controller response pattern
transaction boundary
error mapping convention
test fixture style
client timeout convention
```

---

# 9. What Must Never Be Learned Automatically

Do not automatically store:

- secrets
- tokens
- credentials
- production URLs
- customer data
- hidden evaluator content
- full source files
- full build logs
- temporary outages
- guesses
- personal developer preferences
- unreviewed architectural decisions
- one-time hacks
- broad suppressions
- weakened tests

---

# 10. Recommended Metrics

## Efficiency

```text
input tokens
output tokens
cache-read tokens
tool calls
file reads
repeated file reads
searches
commands
duplicate commands
time to green
```

## Reliability

```text
first-pass success
verification failures
repair attempts
repeated failure fingerprints
blocked runs
hook errors
```

## Learning

```text
learning candidates created
candidates promoted
candidates rejected
active knowledge hits
knowledge misses
successful knowledge reuse
failed knowledge reuse
expired entries
rolled-back entries
```

## Quality

```text
visible tests
hidden tests
Maven verify
human acceptance
material review corrections
```

---

# 11. Recommended Next Step

Do not implement full self-learning immediately.

The next practical version should be:

```text
v1.1 = observability + persistent run state + hard repair limits
```

Then collect results from:

```text
one benchmark pilot
+
five real tasks
```

Only after observing real repeated problems should you build:

```text
v1.2 = efficiency optimization
```

Only after repeated reusable patterns are demonstrated should you build:

```text
v1.3 = governed self-learning
```

---

# 12. Final Answer: Do We Have It?

## Efficiency

```text
YES — designed
PARTIAL — implemented
NO — not yet measured or hard-enforced
```

## Self-healing

```text
YES — lifecycle and repair strategy exist
PARTIAL — limits are prompt-based
NO — no persistent counters or automated enforcement
```

## Self-learning

```text
YES — verified updates to build commands and failure patterns are allowed
PARTIAL — basic repository memory exists
NO — no candidate, promotion, confidence, expiration, or rollback system
```

## Observability

```text
PARTIAL — logs and CSV exist
NO — structured lifecycle, repair, and knowledge metrics are not implemented
```

## Production readiness

```text
NOT YET
```

The correct progression is:

```text
v1.1 reliability
→ v1.2 efficiency
→ v1.3 governed self-learning
→ v2 only when justified
```
