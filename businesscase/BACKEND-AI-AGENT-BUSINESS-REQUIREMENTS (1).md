# Custom Backend AI Agent Platform

## Business Requirements, Learning Plan, Measurement Strategy, and Step-by-Step TODO

**Status:** Draft v0.1  
**Primary use case:** Design, build, and evaluate custom backend coding agents for Spring Boot, Kotlin, and Java repositories  
**Initial execution tools:** Codex CLI or Claude Code  
**Future execution tools:** GitHub Copilot and optional mixed-provider workflows  
**Document purpose:** Define what we want to build, why every part exists, how we will measure improvement, and how to proceed slowly enough to learn each concept

---

# 1. Executive Summary

We want to build a controlled backend AI-agent system that can implement real backend changes while respecting:

- project architecture,
- engineering standards,
- security and operational boundaries,
- required verification,
- context and token limits,
- and measurable quality expectations.

The system must not become one enormous prompt. It should be composed of small, understandable, versioned parts:

1. a stable task contract,
2. an evaluation harness,
3. minimal global instructions,
4. one narrowly scoped backend agent,
5. optional specialist skills,
6. deterministic scripts and hooks,
7. progressive knowledge retrieval,
8. provider-specific adapters,
9. and a provider-neutral observability layer.

The project will be built experimentally. Every new version should change one important variable, run against the same benchmark task, collect the same measurements, and be promoted only when the evidence shows improvement.

The main business question is:

> Can a controlled custom backend agent produce accepted backend changes with higher first-pass quality and less human correction, while keeping token use, context loading, execution time, and operational risk under control?

---

# 2. Source Principles

This design starts from the principles in `efficient.md`:

1. Correctness is the highest priority.
2. Deterministic execution is preferred.
3. Token consumption should be minimized.
4. Context loading should be minimized.
5. Reusable artifacts should be preferred.
6. Workflow execution should be controlled.
7. Cache, artifacts, rules, and retrieval should be considered before expensive reasoning.
8. Knowledge should be loaded progressively: index, summary, then full document.
9. One active specialist should be preferred by default.
10. Unchanged documents should not be repeatedly reread.
11. Escalation should move from inexpensive deterministic mechanisms toward large-model or multi-agent reasoning only when necessary.

This project adds several design decisions:

- quality and efficiency are measured separately,
- quality gates must pass before token efficiency is compared,
- exact, estimated, and proxy token measurements are distinguished,
- observability is kept outside the core agent prompt,
- provider-specific files are adapters around a portable core,
- workflow complexity may depend on task risk,
- and every phase ends with a learning and go/no-go checkpoint.

---

# 3. Problem Statement

Plain coding assistants can generate useful code, but their behaviour is often inconsistent.

Typical problems include:

- editing before understanding the repository,
- loading too much irrelevant context,
- rereading the same files,
- skipping tests,
- introducing unnecessary dependencies,
- violating existing architecture,
- making unrelated changes,
- declaring completion too early,
- consuming more tokens without producing better results,
- and judging their own output too positively.

A large instruction file does not solve all these problems. Instructions are mainly soft guidance. A reliable system needs a combination of:

- clear responsibility,
- explicit boundaries,
- progressive context loading,
- specialist skills,
- deterministic verification,
- observable execution,
- repeatable benchmarks,
- and explicit version promotion rules.

---

# 4. Vision

Create a reusable backend-agent framework that can be added to a repository and used through Codex, Claude Code, Copilot, or another compatible coding assistant.

The framework should allow an engineer to:

- understand what the agent is doing,
- understand why every file exists,
- see which context was loaded,
- see whether the expected workflow was followed,
- compare plain prompting with custom-agent versions,
- measure correctness, human effort, token use, context use, and cost,
- and improve the system gradually without losing control.

---

# 5. Goals

## G1. Improve first-pass correctness

The agent should implement requirements correctly and pass verification with fewer correction rounds.

## G2. Reduce human correction effort

The engineer should spend less time fixing incomplete, unsafe, or architecturally inconsistent output.

## G3. Control token and context consumption

The agent should load only the files and specialist knowledge required by the current task.

## G4. Make execution observable

Each run should produce enough evidence to explain what happened and compare it with another run.

## G5. Support learning

The project owner should understand every file, rule, metric, hook, skill, and decision before adding the next layer.

## G6. Remain provider-neutral where practical

Portable knowledge and workflow concepts should not be unnecessarily tied to Codex, Claude Code, or Copilot.

## G7. Enforce hard requirements deterministically

Builds, tests, protected paths, dependency policies, and dangerous commands should be checked by scripts or hooks wherever possible.

---

# 6. Initial Non-Goals

The first versions will not:

- deploy directly to production,
- change infrastructure automatically,
- perform unrestricted shell operations,
- create many parallel agents,
- build a vector database,
- create Grafana dashboards before the event model is stable,
- support every possible backend technology,
- replace human architectural responsibility,
- or evaluate success only through token counts.

---

# 7. Core Principles

## P1. Correctness before token optimization

A result that uses fewer tokens but fails the task is not better.

## P2. One main variable per experiment

Do not add an agent, several skills, hooks, a new model, and a changed task in the same comparison.

## P3. Same starting conditions

Comparisons should use the same:

- repository commit,
- task version,
- provider,
- model,
- verification commands,
- and review rubric.

## P4. Evidence before complexity

Do not add a skill, hook, dashboard, cache, or second agent unless a measured problem justifies it.

## P5. Portable core and thin adapters

Keep reusable concepts provider-neutral. Keep Codex-, Claude-, and Copilot-specific configuration in adapters.

## P6. Deterministic checks for hard requirements

Use scripts or hooks rather than prose for checks that must always happen.

## P7. Unknown data remains unknown

When exact token or tool-call data is unavailable, record `null` and collect a proxy. Never invent precise values.

## P8. Learning checkpoint after every phase

Before continuing, answer:

1. What was added?
2. Why does it exist?
3. What problem did it solve?
4. What evidence supports keeping it?
5. What new cost or complexity did it introduce?
6. What remains unclear?

---

# 8. High-Level Architecture

```text
User task
   |
   v
Task contract
   |
   v
Provider adapter
(Codex / Claude Code / Copilot)
   |
   v
Backend agent
   |-- core rules
   |-- workflow
   |-- selected skill
   |-- selected knowledge
   |-- allowed tools
   |
   v
Implementation and verification
   |
   +------------------------------+
   |                              |
   v                              v
Run artifacts                 Event collector
(diff, tests, review)         (JSONL initially)
   |                              |
   +---------------+--------------+
                   v
            Evaluation report
                   |
                   v
          Promote or reject version
```

---

# 9. Target Repository Structure

This is the long-term target, not the first commit. Directories should be introduced only when their phase starts.

```text
.ai/
├── README.md
├── core/
│   ├── principles.md
│   ├── boundaries.md
│   ├── workflow.md
│   ├── context-policy.md
│   └── completion-contract.md
├── agents/
│   └── backend-feature-implementer.md
├── skills/
│   ├── spring-backend-feature/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── scripts/
│   ├── database-change/
│   └── testing-and-verification/
├── knowledge/
│   ├── index.yaml
│   ├── summaries/
│   ├── documents/
│   └── workflows/
├── policies/
│   ├── protected-paths.yaml
│   ├── allowed-dependencies.yaml
│   ├── database-policy.yaml
│   └── command-policy.yaml
├── scripts/
│   ├── start-run.sh
│   ├── finish-run.sh
│   ├── verify.sh
│   └── collect-git-metrics.sh
├── evaluation/
│   ├── README.md
│   ├── tasks/
│   ├── configurations/
│   ├── runs/
│   ├── rubrics/
│   └── reports/
├── observability/
│   ├── event-schema.json
│   ├── collectors/
│   ├── exporters/
│   └── dashboards/
└── adapters/
    ├── codex/
    ├── claude-code/
    └── copilot/
```

---

# 10. File-by-File Purpose

## 10.1 `.ai/README.md`

**Purpose:** Human and tool entry point.

It should explain:

- what the framework is,
- which version is active,
- how to run an evaluation,
- where instructions, agents, skills, policies, and metrics live,
- and which future components are not active yet.

**Why:** Without an entry point, the repository becomes a collection of unrelated Markdown files.

**Do not put here:** Detailed Spring, Kotlin, database, or Kafka procedures.

---

## 10.2 `.ai/core/principles.md`

**Purpose:** Stable provider-neutral rules that apply to almost every task.

Examples:

- correctness before optimization,
- smallest cohesive change,
- inspect existing patterns first,
- deterministic verification,
- no unrelated refactoring.

**Why:** These rules should not be duplicated across every agent and skill.

**Risk:** A large global file becomes permanent context overhead.

**Control:** Keep it short and prove that each rule is broadly applicable.

---

## 10.3 `.ai/core/boundaries.md`

**Purpose:** Define allowed, prohibited, and approval-required actions.

Examples:

- allowed: modify code and tests relevant to the task,
- prohibited: deployment, credentials, unrelated refactoring,
- approval required: breaking API changes, new dependencies, destructive database migrations.

**Why:** Responsibility without boundaries leads to uncontrolled changes.

**Important:** Markdown describes the policy. Critical parts should later be enforced through scripts or hooks.

---

## 10.4 `.ai/core/workflow.md`

**Purpose:** Define phases and phase exit criteria.

Initial workflow:

```text
ANALYSIS -> DESIGN -> IMPLEMENTATION -> VERIFICATION -> REVIEW -> DONE
```

Possible future risk profiles:

```text
QUICK:
ANALYSIS -> IMPLEMENTATION -> VERIFICATION -> DONE

STANDARD:
ANALYSIS -> DESIGN -> IMPLEMENTATION -> VERIFICATION -> REVIEW -> DONE

HIGH_RISK:
ANALYSIS -> DESIGN -> APPROVAL -> IMPLEMENTATION
-> VERIFICATION -> SECURITY_REVIEW -> HUMAN_APPROVAL -> DONE
```

**Why:** It prevents premature coding and false completion.

**Measure:** Skipped phases, failed exits, time per phase, and additional token cost.

---

## 10.5 `.ai/core/context-policy.md`

**Purpose:** Define what context may be loaded and in what order.

Preferred order:

```text
Current task
-> repository map
-> directly relevant files
-> knowledge index
-> summary
-> full document only if required
```

**Why:** Token efficiency is mainly a context-selection problem.

**Measure:** Files read, unique files read, repeated reads, summaries loaded, full documents loaded, context bytes, and tokens where available.

---

## 10.6 `.ai/core/completion-contract.md`

**Purpose:** Define what `DONE` means.

Example requirements:

- acceptance criteria mapped to implementation,
- build passed,
- required tests passed,
- static analysis passed,
- no critical findings,
- no forbidden files changed,
- final summary generated.

**Why:** Code written is not the same as task completed.

---

## 10.7 `.ai/agents/backend-feature-implementer.md`

**Purpose:** Define one specialist agent for one backend feature or bug fix.

It should define:

- mission,
- supported tasks,
- required inputs,
- allowed tools,
- boundaries,
- workflow,
- skill-selection rules,
- output contract,
- escalation conditions,
- completion rules.

**Initial scope:**

- existing Spring Boot repository,
- Kotlin or Java,
- one focused feature or bug fix,
- tests required,
- no deployment or infrastructure changes.

---

## 10.8 `.ai/skills/<skill>/SKILL.md`

**Purpose:** Store specialist procedures that load only for relevant tasks.

A skill must answer:

1. When should it activate?
2. When should it not activate?
3. What inputs are required?
4. What workflow should be followed?
5. Which references may load?
6. Which scripts should run?
7. What output is required?
8. How is success verified?

**Why:** Detailed specialist guidance should not occupy every task's context.

**First candidates:**

- `database-change`,
- `testing-and-verification`,
- or `spring-backend-feature`.

Only one should be introduced in the first skill experiment.

---

## 10.9 `.ai/knowledge/index.yaml`

**Purpose:** Small router to summaries and detailed documents.

Example:

```yaml
topics:
  spring-transactions:
    triggers:
      - transactional
      - rollback
      - multiple repositories
    summary: summaries/spring-transactions.md
    details: documents/spring-transactions-deep-dive.md
```

**Why:** The agent should discover relevant knowledge without loading the whole knowledge base.

---

## 10.10 `.ai/policies/*.yaml`

**Purpose:** Machine-readable rules.

Possible policies:

- protected paths,
- allowed dependencies,
- database migration rules,
- shell command policy.

**Why:** Structured rules are easier to validate deterministically than prose.

**When to add:** Only after a concrete enforcement requirement appears.

---

## 10.11 `.ai/scripts/verify.sh`

**Purpose:** One deterministic verification entry point.

It may run:

- compilation,
- unit tests,
- integration tests,
- formatting,
- static analysis,
- architecture tests,
- forbidden-change checks.

**Why:** Verification should not depend on the model remembering several commands.

**Measure:** Exit code, duration, failing stage, and retry count.

---

## 10.12 `.ai/evaluation/tasks/`

**Purpose:** Stable benchmark tasks.

Every task should define:

- starting commit,
- exact requirements,
- acceptance criteria,
- forbidden changes,
- required verification,
- reset instructions,
- optional hidden tests.

**Why:** Random tasks do not produce reliable comparisons.

---

## 10.13 `.ai/evaluation/runs/`

**Purpose:** Evidence for every experiment.

Suggested run folder:

```text
run-001/
├── metadata.yaml
├── events.jsonl
├── task.md
├── prompt.md
├── diff.patch
├── test-results/
├── review.yaml
└── summary.md
```

**Why:** A final score without evidence is hard to trust or reproduce.

---

## 10.14 `.ai/observability/event-schema.json`

**Purpose:** Define a common event model.

Initial events:

- `run_started`,
- `phase_started`,
- `phase_completed`,
- `command_executed`,
- `verification_completed`,
- `policy_violation`,
- `artifact_created`,
- `run_completed`.

File-read telemetry is optional because provider support may differ.

---

## 10.15 `.ai/adapters/codex/`

**Purpose:** Map the portable framework to Codex-specific instructions, launch scripts, telemetry extraction, and configuration.

**Why:** Codex details should not contaminate portable skills and policies.

---

## 10.16 `.ai/adapters/claude-code/`

**Purpose:** Map the portable framework to Claude Code instructions, skills, hooks, launch scripts, and telemetry extraction.

**Why:** Claude-specific controls should remain separate from portable agent design.

---

# 11. Functional Requirements

## FR-001 Run identity

Every execution must have a unique `run_id`.

## FR-002 Configuration identity

Every run must record:

- task version,
- starting Git commit,
- provider,
- model when known,
- prompt version,
- agent version,
- instruction version,
- skill version,
- observability schema version.

## FR-003 Stable benchmark task

Every benchmark must define measurable acceptance criteria and forbidden changes.

## FR-004 Repository reset

The repository must be restored to the same starting commit before each comparison run.

## FR-005 Run evidence

Every run must capture or reference:

- task,
- prompt/configuration,
- diff,
- verification results,
- human or reviewer score,
- usage values or proxies.

## FR-006 Deterministic verification

The system must expose one verification command with a machine-readable success/failure result.

## FR-007 Stable review rubric

Every run for the same task must use the same review rubric.

## FR-008 Provider-neutral usage record

Every usage value must indicate whether it is exact, estimated, or unavailable.

## FR-009 Progressive context loading

The agent should load index, summary, and full knowledge progressively.

## FR-010 No-reread preference

Where observable, unchanged documents should be reused from a cached summary or artifact.

## FR-011 Workflow observation

Phase transitions should be recorded when supported.

## FR-012 Policy enforcement

Critical boundaries should be enforceable through scripts, hooks, protected paths, or command restrictions.

## FR-013 Version comparison

At least two configurations must be compared with the same task and starting conditions.

## FR-014 Promotion decision

Every new agent version must be explicitly promoted, modified, or rejected.

## FR-015 Reusable artifacts

Analysis, designs, decisions, summaries, and verification evidence should be stored when they have future value.

---

# 12. Non-Functional Requirements

## NFR-001 Reproducibility

Another engineer should be able to rerun an experiment from the recorded task and commit.

## NFR-002 Transparency

Every active file should have a documented purpose.

## NFR-003 Minimal overhead

Measurement must not require excessive manual work.

## NFR-004 Low provider coupling

Portable content must be separated from provider adapters.

## NFR-005 Versionability

Tasks, agents, skills, prompts, rubrics, and schemas must be versioned.

## NFR-006 Evidence integrity

Previous run evidence must never be silently overwritten.

## NFR-007 Security

Secrets, credentials, private prompts, and sensitive source content must not be exported to external metrics systems.

## NFR-008 Low-cardinality metrics

Prometheus labels must not contain unique run IDs, file paths, prompts, or complete task descriptions.

## NFR-009 Graceful degradation

A run must continue when exact token data is unavailable.

## NFR-010 Explainability

The system must make it possible to explain why one version was promoted over another.

---

# 13. Measurement Model

## 13.1 Mandatory quality gates

| Metric | Initial requirement |
|---|---:|
| Build passed | true |
| Required tests passed | true |
| Acceptance criteria met | 100% |
| Forbidden changes | 0 |
| Critical review findings | 0 |

A run that fails one of these is unsuccessful even when it consumes fewer tokens.

## 13.2 Quality score

Score each category from `0` to `2`:

- `0` = unacceptable,
- `1` = acceptable but needs correction,
- `2` = production-ready.

Suggested weights:

| Category | Weight |
|---|---:|
| Functional correctness | 25% |
| Requirement completeness | 20% |
| Architecture consistency | 15% |
| Test quality | 15% |
| Error handling | 10% |
| Maintainability | 10% |
| Change focus | 5% |

Normalize the result to `0-100`.

## 13.3 Human effort metrics

- correction rounds,
- review minutes,
- manually changed files,
- manually changed lines,
- critical findings,
- major findings,
- minor findings,
- accepted without correction.

## 13.4 Token and context metrics

- input tokens,
- output tokens,
- cached tokens,
- estimated tokens,
- prompt characters,
- context bytes,
- files read,
- unique files read,
- repeated reads,
- summaries loaded,
- full documents loaded.

## 13.5 Execution metrics

- run duration,
- user interventions,
- tool calls,
- commands executed,
- failed commands,
- retries,
- verification attempts,
- files changed,
- lines added,
- lines deleted.

## 13.6 Compliance metrics

- workflow phases skipped,
- forbidden command attempts,
- protected file attempts,
- unauthorized dependency attempts,
- verification skipped,
- missing approval,
- unnecessary skill activation.

## 13.7 Derived metrics

```text
total_tokens =
input_tokens + output_tokens
```

```text
effective_input_tokens =
input_tokens - cached_input_tokens
```

```text
first_pass_success_rate =
accepted_without_correction / all_runs
```

```text
successful_run_rate =
successful_runs / all_runs
```

```text
reread_ratio =
repeated_file_reads / all_file_reads
```

```text
tokens_per_accepted_task =
total_tokens / accepted_tasks
```

```text
human_minutes_per_accepted_task =
total_human_minutes / accepted_tasks
```

```text
cost_per_accepted_task =
total_model_cost / accepted_tasks
```

---

# 14. Token Measurement Levels

## Level A: Exact provider data

```yaml
input_tokens:
  value: 12400
  source: provider
  estimated: false
```

## Level B: Local tokenizer estimate

```yaml
input_tokens:
  value: 11950
  source: local-tokenizer
  estimated: true
```

## Level C: Proxy measurements

When tokens are unavailable, record:

- prompt characters,
- context bytes,
- files loaded,
- repeated reads,
- tool calls,
- user interventions,
- duration,
- provider request count when visible.

Exact and estimated values must never be mixed without their source.

---

# 15. Provider-Neutral Run Record

```yaml
schema_version: "0.1"

identity:
  run_id: "run-001"
  task_id: "confirm-shipment"
  task_version: "0.1"
  configuration: "plain-prompt"
  agent_version: null
  instructions_version: null
  skills_version: null
  observability_version: "0.1"

environment:
  provider: "codex-or-claude"
  model: null
  repository_commit: "<git-sha>"
  started_at: "<timestamp>"
  completed_at: "<timestamp>"

usage:
  input_tokens:
    value: null
    source: null
    estimated: null
  output_tokens:
    value: null
    source: null
    estimated: null
  cached_input_tokens:
    value: null
    source: null
    estimated: null
  prompt_characters: null
  context_bytes: null
  prompts: null
  tool_calls: null
  duration_seconds: null

context:
  file_reads: null
  unique_files_read: null
  repeated_file_reads: null
  summaries_loaded: null
  full_documents_loaded: null

changes:
  files_changed: null
  lines_added: null
  lines_deleted: null

verification:
  build_passed: null
  tests_passed: null
  static_analysis_passed: null
  forbidden_changes: null

outcome:
  acceptance_criteria_met: null
  acceptance_criteria_total: null
  quality_score: null
  first_pass_success: null
  manual_corrections: null
  human_review_minutes: null
  accepted: null

review_findings:
  critical: null
  major: null
  minor: null

notes: []
```

---

# 16. Controlled Evaluation Method

## 16.1 Keep constant

When comparing two configurations, keep constant:

- repository starting commit,
- task version,
- acceptance criteria,
- provider,
- model,
- environment,
- verification commands,
- review rubric.

Change one main variable.

## 16.2 Repeat runs

Early stage:

- three runs per configuration per task.

Later:

- five to ten runs per configuration.

## 16.3 Independent review

Use three layers:

1. deterministic verification,
2. human rubric,
3. optional blinded reviewer agent.

The implementation agent must not be the only judge of its result.

## 16.4 Comparison report

Every report should answer:

1. What changed?
2. Which hypothesis was tested?
3. Did mandatory gates pass?
4. Did quality improve?
5. Did human effort improve?
6. Did token or context efficiency improve?
7. Did any regression appear?
8. Should the version be kept, changed, or rejected?

---

# 17. Initial Promotion Rules

```yaml
promotion_rules:
  successful_run_rate:
    minimum: 0.80

  quality_score:
    minimum: 80

  critical_findings:
    maximum: 0

  forbidden_changes:
    maximum: 0

  first_pass_success:
    must_not_decrease: true

  human_review_minutes:
    must_not_increase: true

  tokens_per_accepted_task:
    maximum_allowed_increase: 0.15
```

A larger token increase may be accepted only when a meaningful quality improvement is documented.

---

# 18. First Benchmark Task

Recommended first task: **Confirm Shipment**

Requirements:

- add `POST /shipments/{id}/confirm`,
- validate current state,
- make repeated confirmation idempotent,
- persist `CONFIRMED`,
- return correct HTTP status codes,
- provide unit and integration tests,
- add no dependency,
- perform no unrelated refactoring.

Why this task is useful:

- REST design,
- service logic,
- persistence,
- transaction handling,
- state validation,
- idempotency,
- error handling,
- testing.

---

# 19. Step-by-Step Delivery Roadmap

Every phase ends with:

- implementation,
- measured runs,
- comparison report,
- learning notes,
- go/no-go decision.

---

## Phase 0: Define the Experiment Contract

### Objective

Define what “better” means before building the custom agent.

### Files

```text
evaluation/
├── README.md
├── tasks/
│   └── 001-confirm-shipment.md
├── rubrics/
│   └── backend-quality-rubric.yaml
└── runs/
    └── run-template.yaml
```

### Why

Without a stable task, rubric, and run record, later comparisons are subjective.

### Learning questions

- What is a controlled experiment?
- Why must starting conditions stay stable?
- Why are quality gates separate from a quality score?
- Which values are exact, estimated, manual, or unavailable?

### Exit criteria

- one task can be repeated,
- one run record can be completed,
- one quality score can be calculated.

### TODO

- [ ] Create `evaluation/README.md`.
- [ ] Create the first benchmark task.
- [ ] Define mandatory quality gates.
- [ ] Create the review rubric.
- [ ] Create the run template.
- [ ] Review every field and explain its purpose.
- [ ] Execute one trial run.
- [ ] Adjust the schema before repeating the benchmark.

---

## Phase 1: Plain-Prompt Baseline

### Objective

Measure Codex or Claude Code without custom-agent behaviour.

### Configuration

- no custom agent,
- no skill,
- no hook,
- task prompt only,
- same provider and model.

### Deliverables

- at least three run folders,
- diffs,
- verification results,
- completed rubrics,
- baseline report.

### Learning questions

- Which files did the tool inspect?
- Did it understand the architecture?
- Did it verify its work?
- What required correction?
- Which metrics were available?

### TODO

- [ ] Reset repository to the starting commit.
- [ ] Execute baseline run 1.
- [ ] Save prompt, diff, and verification.
- [ ] Complete the rubric.
- [ ] Repeat at least three times.
- [ ] Calculate success rate.
- [ ] Calculate median quality score.
- [ ] Calculate human correction time.
- [ ] Record tokens or proxies.
- [ ] Publish baseline report.

---

## Phase 2: Automate Basic Run Capture

### Objective

Reduce manual measurement errors without changing agent behaviour.

### Files

```text
scripts/
├── start-run.sh
├── finish-run.sh
└── collect-git-metrics.sh
```

### Automatically capture

- start and end time,
- starting and ending commit,
- changed files,
- lines added and deleted,
- verification exit codes,
- artifact paths.

### Learning questions

- Which metrics are deterministic?
- Which still require provider telemetry?
- Which still require human judgement?
- How can measurement remain independent from agent decisions?

### TODO

- [ ] Implement `start-run.sh`.
- [ ] Implement `collect-git-metrics.sh`.
- [ ] Implement `finish-run.sh`.
- [ ] Prevent overwriting run folders.
- [ ] Add error handling.
- [ ] Verify values manually.
- [ ] Document every script.
- [ ] Repeat one baseline run through the scripts.

---

## Phase 3: Minimal Global Instructions

### Objective

Test a very small set of repository-wide rules.

### Candidate rules

- inspect existing patterns before creating new ones,
- make the smallest cohesive change,
- do not add dependencies without approval,
- run the repository verification command,
- do not claim completion when verification fails.

### Hypothesis

Minimal global instructions reduce unrelated changes and skipped verification without large context overhead.

### Comparison

```text
A: plain prompt
B: same prompt + minimal instructions
```

### TODO

- [ ] Create minimal instruction file.
- [ ] Version it as `instructions-v0.1`.
- [ ] Explain the expected effect of every rule.
- [ ] Run three controlled comparisons.
- [ ] Compare quality, focus, verification, and tokens.
- [ ] Remove rules with no clear value.
- [ ] Publish experiment report.

---

## Phase 4: First Backend Agent Boundary

### Objective

Create one narrowly scoped `backend-feature-implementer`.

### Initial responsibility

Implement one backend feature or bug fix in an existing Spring Boot Kotlin/Java repository, including tests and verification.

### Allowed

- inspect relevant code,
- modify relevant application code,
- modify relevant tests,
- run approved commands,
- produce analysis and verification summaries.

### Prohibited

- deployment,
- infrastructure changes,
- credential access,
- unrelated refactoring,
- destructive schema changes,
- new dependencies without approval.

### Approval required

- breaking API change,
- destructive migration,
- cross-module architectural change,
- security-sensitive redesign,
- new external dependency.

### Comparison

```text
A: minimal instructions
B: minimal instructions + agent boundary
```

### TODO

- [ ] Define mission.
- [ ] Define accepted task types.
- [ ] Define inputs.
- [ ] Define allowed actions.
- [ ] Define prohibited actions.
- [ ] Define approval-required actions.
- [ ] Define outputs.
- [ ] Define `DONE`.
- [ ] Create one provider adapter.
- [ ] Run controlled comparisons.
- [ ] Record whether diffs became more focused.

---

## Phase 5: Workflow Phases

### Objective

Prevent premature implementation and false completion.

### Workflow

```text
ANALYSIS -> DESIGN -> IMPLEMENTATION -> VERIFICATION -> REVIEW -> DONE
```

### Phase outputs

**ANALYSIS**

- restated goal,
- repository findings,
- risks,
- affected files,
- open questions.

**DESIGN**

- proposed change,
- alternatives,
- data and error flow,
- test strategy,
- ADR decision.

**IMPLEMENTATION**

- focused code matching the design.

**VERIFICATION**

- commands,
- results,
- failures,
- fixes.

**REVIEW**

- acceptance-criteria mapping,
- diff review,
- unresolved findings.

**DONE**

- completion contract passed.

### TODO

- [ ] Define phase outputs.
- [ ] Define transition criteria.
- [ ] Version workflow as `v0.1`.
- [ ] Capture phase duration when possible.
- [ ] Run three comparisons.
- [ ] Measure workflow token overhead.
- [ ] Decide whether risk-based profiles are needed later.

---

## Phase 6: One Specialist Skill

### Objective

Test situational knowledge loading.

### Select one skill

Choose based on measured failures:

- `database-change`,
- `testing-and-verification`,
- or `spring-backend-feature`.

Do not add all three.

### Skill contract

- activation criteria,
- exclusion criteria,
- required inputs,
- workflow,
- references,
- scripts,
- output,
- verification.

### TODO

- [ ] Select one measured problem.
- [ ] Design one skill.
- [ ] Keep `SKILL.md` concise.
- [ ] Add at most one summary reference.
- [ ] Record activation.
- [ ] Run with and without the skill.
- [ ] Compare quality, tokens, context, and corrections.
- [ ] Keep, modify, or remove the skill.

---

## Phase 7: Deterministic Verification and Policies

### Objective

Move hard requirements from prose into executable controls.

### First controls

- one verification script,
- protected-path check,
- dependency-change detection,
- forbidden-command policy when supported.

### TODO

- [ ] Create `verify.sh`.
- [ ] Add structured stage results.
- [ ] Define protected paths.
- [ ] Detect dependency changes.
- [ ] Define warning versus blocking behaviour.
- [ ] Add provider hooks where supported.
- [ ] Record policy events.
- [ ] Test intentional violations.
- [ ] Document approval or bypass process.

---

## Phase 8: Progressive Knowledge Retrieval

### Objective

Reduce context loading while preserving access to project knowledge.

### Structure

```text
knowledge/
├── index.yaml
├── summaries/
├── documents/
└── workflows/
```

### Hypothesis

Index-to-summary-to-document retrieval reduces context without quality regression.

### TODO

- [ ] Create one index.
- [ ] Add one summary.
- [ ] Add one detailed document.
- [ ] Define retrieval triggers.
- [ ] Record selected entries.
- [ ] Record summary/full-document usage.
- [ ] Compare context metrics.
- [ ] Test no-reread behaviour where observable.

---

## Phase 9: Provider-Neutral Observability

### Objective

Create a common event format for Codex and Claude Code.

### Initial storage

Local append-only JSONL.

### Why JSONL first

- inspectable,
- diffable,
- script-friendly,
- no infrastructure,
- schema can evolve.

### Initial events

- run started/completed,
- phase started/completed,
- command executed,
- verification completed,
- policy violation,
- artifact created.

### TODO

- [ ] Define `event-schema.json`.
- [ ] Define required and optional fields.
- [ ] Build Codex mapping.
- [ ] Build Claude Code mapping.
- [ ] Validate events.
- [ ] Add schema version.
- [ ] Add redaction rules.
- [ ] Generate a run summary.

---

## Phase 10: Reports and Dashboards

### Objective

Aggregate enough runs to support decisions.

### Order

```text
JSONL
-> Markdown/CSV comparison
-> optional OpenTelemetry
-> optional Prometheus
-> Grafana
```

### Possible aggregate metrics

- `agent_runs_total`,
- `agent_successful_runs_total`,
- `agent_run_duration_seconds`,
- `agent_verification_failures_total`,
- `agent_policy_violations_total`,
- `agent_first_pass_success_total`,
- `agent_human_correction_minutes_total`.

### TODO

- [ ] Generate Markdown comparison.
- [ ] Generate CSV comparison.
- [ ] Validate which metrics support decisions.
- [ ] Define low-cardinality aggregate metrics.
- [ ] Add exporter only when useful.
- [ ] Add Grafana only after enough runs exist.
- [ ] Remove charts that do not change decisions.

---

## Phase 11: Compare Codex and Claude Code

### Objective

Compare providers after the portable framework stabilizes.

### Keep stable

- task,
- starting commit,
- portable agent,
- skill,
- verification,
- rubric.

### Change

- provider adapter and model.

### TODO

- [ ] Freeze portable configuration.
- [ ] Run Codex at least three times.
- [ ] Run Claude Code at least three times.
- [ ] Compare quality.
- [ ] Compare correction effort.
- [ ] Compare exact or proxy usage carefully.
- [ ] Compare observability capabilities.
- [ ] Document provider limitations.
- [ ] Select primary and fallback provider.

---

## Phase 12: Decide Whether Multi-Agent Execution Is Needed

### Objective

Add another agent only when a measured limitation justifies it.

### Valid reasons

- independent subtasks,
- useful context isolation,
- clear handoff contracts,
- improved review separation,
- benefit greater than added cost.

### First possible additional agent

A read-only reviewer.

### TODO

- [ ] Identify a measured single-agent limitation.
- [ ] Define one additional agent.
- [ ] Define its handoff contract.
- [ ] Measure extra tokens and duration.
- [ ] Measure review improvement.
- [ ] Reject multi-agent design when evidence is weak.

---

# 20. Learning Workflow with Codex or Claude Code

Use the same learning cycle for every file.

## Step A: Explanation before implementation

```text
We are working only on <file/path>.

Before writing it:
1. Explain the problem this file solves.
2. Explain why this responsibility belongs here.
3. Explain what must not be placed here.
4. Show the smallest viable structure.
5. Explain how we will measure whether it helps.

Do not modify files yet.
```

## Step B: Review the design

Ask:

- Is this content global or situational?
- Is it guidance or enforcement?
- Will it always be loaded?
- What context cost does it add?
- How will failure be visible?

## Step C: Implement one file

```text
Implement only <file/path> using the agreed design.
Do not create additional files.
After writing it, explain every section and map it to the requirement it satisfies.
```

## Step D: Verify the file

```text
Review <file/path> against its acceptance criteria.

List:
- satisfied criteria,
- missing criteria,
- unnecessary content,
- ambiguous rules,
- expected measurement impact.

Do not edit the file.
```

## Step E: Run the experiment

Use the same task, commit, provider, and model as the previous version.

## Step F: Store learning notes

```yaml
learning:
  what_was_added:
  why_it_exists:
  observed_effect:
  unexpected_effect:
  keep_or_remove:
  next_question:
```

---

# 21. Rules for Codex or Claude Code While Building the Framework

1. Work on one phase only.
2. Work on one file or one cohesive script set.
3. Explain before editing.
4. Do not create future-phase directories.
5. Do not silently add metrics.
6. Every metric must support a decision.
7. Every instruction needs an expected behavioural effect.
8. Every hook must enforce a concrete policy.
9. Every skill must solve a measured specialist problem.
10. Every experiment must record its changed variable.
11. Never overwrite previous run evidence.
12. Do not promote a version after one successful run.

---

# 22. ADR Policy

Create an ADR when a decision:

- affects multiple modules or teams,
- is hard to reverse,
- introduces a new architectural pattern,
- introduces provider coupling,
- changes the telemetry model,
- changes security boundaries,
- or changes the core workflow.

Do not create an ADR for:

- every prompt wording change,
- every small script refactor,
- every benchmark run,
- or every minor skill edit.

Suggested initial ADRs:

1. Portable core with provider adapters.
2. JSONL as initial observability storage.
3. Quality gate before token comparison.
4. Single active specialist by default.
5. Controlled experiments for version promotion.

---

# 23. Risks and Mitigations

## Risk: Optimizing for tokens instead of outcomes

**Mitigation:** Compare token efficiency only after quality gates pass.

## Risk: Overfitting to one benchmark

**Mitigation:** Add several task types later and introduce hidden tests.

## Risk: Model randomness

**Mitigation:** Repeat runs and use median and average values.

## Risk: Too many Markdown files

**Mitigation:** Add a file only when a measured need exists.

## Risk: Provider telemetry differences

**Mitigation:** Use exact, estimated, and proxy classifications.

## Risk: Agent grades itself too positively

**Mitigation:** Deterministic checks, human rubric, optional blinded reviewer.

## Risk: Hooks become difficult to maintain

**Mitigation:** Start with one verification command and a small policy set.

## Risk: Metrics become developer surveillance

**Mitigation:** Measure agent-system behaviour and task outcomes, not individual employee productivity.

## Risk: Sensitive code enters external telemetry

**Mitigation:** Export aggregates only; keep detailed evidence local; add redaction.

## Risk: Workflow costs more tokens than it saves

**Mitigation:** Measure phase overhead and later add risk-based profiles only when justified.

---

# 24. Definition of Done for the Initial Initiative

The first major release is complete when:

- one backend agent exists,
- its responsibility and boundaries are documented,
- one specialist skill has demonstrated value,
- deterministic verification is present,
- benchmark tasks are repeatable,
- run evidence is stored consistently,
- quality, effort, and usage are compared,
- Codex or Claude Code can execute the workflow,
- provider details are isolated,
- comparison reports are generated,
- and one custom version outperforms the plain-prompt baseline under the promotion rules.

---

# 25. Master TODO Checklist

## Foundation

- [ ] Approve vision.
- [ ] Approve goals and non-goals.
- [ ] Approve measurement principles.
- [ ] Select first repository.
- [ ] Select first benchmark task.
- [ ] Select first baseline provider.

## Evaluation v0.1

- [ ] Create evaluation README.
- [ ] Create task specification.
- [ ] Create quality gates.
- [ ] Create review rubric.
- [ ] Create run template.
- [ ] Execute one trial run.
- [ ] Adjust the schema.
- [ ] Execute three baseline runs.
- [ ] Publish baseline report.

## Capture automation v0.1

- [ ] Capture timestamps.
- [ ] Capture commits and diff.
- [ ] Capture build/test results.
- [ ] Capture changed-file statistics.
- [ ] Prevent evidence overwrite.
- [ ] Verify collected values.

## Minimal instructions v0.1

- [ ] Add universal rules only.
- [ ] Version instructions.
- [ ] Run comparisons.
- [ ] Remove rules without evidence.

## Backend agent v0.1

- [ ] Define mission.
- [ ] Define accepted tasks.
- [ ] Define inputs.
- [ ] Define allowed actions.
- [ ] Define prohibited actions.
- [ ] Define approval conditions.
- [ ] Define outputs.
- [ ] Define completion.
- [ ] Create first provider adapter.
- [ ] Run comparisons.

## Workflow v0.1

- [ ] Define phases.
- [ ] Define outputs.
- [ ] Define transitions.
- [ ] Measure overhead.
- [ ] Validate quality impact.

## First skill v0.1

- [ ] Select one measured problem.
- [ ] Implement one skill.
- [ ] Record activation.
- [ ] Measure context impact.
- [ ] Measure quality impact.

## Deterministic controls v0.1

- [ ] Create verification script.
- [ ] Add protected-path check.
- [ ] Add dependency-change check.
- [ ] Add hooks where supported.
- [ ] Record violation events.

## Knowledge retrieval v0.1

- [ ] Create index.
- [ ] Create one summary.
- [ ] Create one detailed document.
- [ ] Measure loading behaviour.
- [ ] Test no-reread behaviour.

## Observability v0.1

- [ ] Define event schema.
- [ ] Add JSONL collector.
- [ ] Add provider mapping.
- [ ] Add redaction.
- [ ] Generate run summary.

## Reporting v0.1

- [ ] Generate Markdown comparison.
- [ ] Generate CSV comparison.
- [ ] Define aggregate metrics.
- [ ] Add dashboard only after enough runs.

## Provider comparison

- [ ] Freeze portable configuration.
- [ ] Run Codex benchmark.
- [ ] Run Claude Code benchmark.
- [ ] Compare quality, effort, usage, and telemetry.
- [ ] Select primary and fallback provider.

## Future decisions

- [ ] Evaluate reviewer agent.
- [ ] Evaluate multi-agent orchestration.
- [ ] Evaluate OpenTelemetry.
- [ ] Evaluate Prometheus and Grafana.
- [ ] Evaluate advanced caching.
- [ ] Evaluate a larger knowledge system.

---

# 26. Recommended Immediate Next Step

Do not create the backend agent yet.

Start with Phase 0 only:

1. create `evaluation/README.md`,
2. create one benchmark task,
3. create one review rubric,
4. create one run template,
5. review and understand every field,
6. execute one trial baseline run,
7. adjust the measurement model.

The first milestone must answer:

> Can we consistently record and review one plain Codex or Claude Code backend task before introducing custom-agent behaviour?

---

# 27. First Learning Session Agenda

1. Explain task, prompt, instruction, agent, skill, policy, hook, artifact, metric, log, and trace.
2. Select the first repository and benchmark task.
3. Define successful and unsuccessful output.
4. Review the run template field by field.
5. Classify values as exact, estimated, manual, or unavailable.
6. Create only the Phase 0 files.
7. Execute one trial run.
8. Review what was measurable.
9. Correct Phase 0 before continuing.

---

# 28. Glossary

## Agent

A specialist role with a mission, boundaries, workflow, tools, and output contract.

## Skill

A situational procedure loaded only for relevant tasks.

## Instruction

Guidance the model should follow. It remains soft unless backed by deterministic control.

## Policy

A rule describing allowed, prohibited, or approval-required behaviour.

## Hook

A deterministic action triggered at a lifecycle point.

## Artifact

A reusable or auditable output such as analysis, design, diff, test report, or ADR.

## Metric

A numeric aggregate used to compare trends or make decisions.

## Log event

A detailed record of something that happened.

## Trace

The ordered lifecycle of one run across phases.

## Quality gate

A mandatory pass/fail condition.

## Quality score

A weighted assessment after mandatory gates are checked.

## Baseline

Measured behaviour of the uncustomized tool under controlled conditions.

## Configuration

A combination of provider, model, prompt, instructions, agent, skills, hooks, and policies.

## Promotion

The decision to make a tested configuration the new default.

---

# 29. Final Principle

The project should not ask:

> How many agent files can we create?

It should ask:

> Which smallest controlled change produces a measurable improvement in accepted backend work, and why?
