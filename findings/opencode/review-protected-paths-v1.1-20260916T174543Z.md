# opencode review — protected-paths-v1.1

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
reviewed_utc:    20260916T174543Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7275b73d-bbbf-4a95-a875-e1abed6c20cd/scratchpad/review/protected-paths-v1.1.yaml
    sha:  76c4c34c0f4c
    dirty: false
  - path: /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7275b73d-bbbf-4a95-a875-e1abed6c20cd/scratchpad/review/agent-v1.1-CLAUDE.md
    sha:  a94237242e8c
    dirty: false
  - path: /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7275b73d-bbbf-4a95-a875-e1abed6c20cd/scratchpad/review/backend-feature-phases.md
    sha:  b3450564b6f3
    dirty: false
  - path: /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7275b73d-bbbf-4a95-a875-e1abed6c20cd/scratchpad/review/agent-v1.1-settings.json
    sha:  925a382322da
    dirty: false
lab_head:        3a94afb
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: scratchpad/review/protected-paths-v1.1.yaml (with companion files agent-v1.1-CLAUDE.md, backend-feature-phases.md, agent-v1.1-settings.json in the same directory)
  verdict: REJECT
  summary: Four-file policy package whose central L2-enforcement claim does not survive the attached evidence — the deny list misses whole categories the boundary sentence names (Dockerfile.prod, Containerfile, Jenkinsfile, .gitlab-ci.yml, yarn.lock, pnpm-lock.yaml, compose.yml all pass the gate), the gate is wired only to Edit|Write|NotebookEdit so Bash bypasses it, and "fnmatch semantics" is named without an implementation so root-file match status is undefined.
  blocking:
    - reason: The deny list is enumerative; the boundary sentence it claims to encode at line 24 ("the L2 version of that sentence") is categorical. Dockerfile.prod, Containerfile, Dockerfile.dev, Jenkinsfile, .gitlab-ci.yml, .circleci/config.yml, yarn.lock, pnpm-lock.yaml, compose.yml, BUILD, BUILD.bazel, *.bazel, build.sbt, Cargo.lock are all named by category in the L3 sentence but pass the gate — `**/Dockerfile` requires the path to end in exactly `Dockerfile`, `**/*.lock` does not match `yarn.lock` / `pnpm-lock.yaml`, and `.github/**` is the only CI pattern listed.
      wrong_action: A reviewer applying the L2 claim records protected files as enforced. Specifically, they trust that Dockerfile.prod is denied because the boundary sentence names "a Dockerfile" as out of scope. The deny list specifies `**/Dockerfile` exactly, so Dockerfile.prod is allowed, the gate exits 0, the edit lands, and the audit records GREEN for a file the artifact itself asserts is protected.
      anchor: "That sentence is the L3 version of this file. This is the L2 version of that sentence."
      evidence: protected-paths-v1.1.yaml:22-24,26-43; backend-feature-phases.md:116-118

    - reason: policy-gate.sh is wired only to the Edit|Write|NotebookEdit matcher (agent-v1.1-settings.json line 5). Bash is not in that matcher. Bash is in the agent's tool list (backend-feature-phases.md line 5) and is what the agent is told to use for verification, search, and the verification phase claim ("the claim becomes evidence"). Any Bash command that writes a file (sed -i, tee -a, `echo >`, redirection, `git checkout -- .github/workflows/ci.yml`) bypasses the protected-paths boundary entirely. The YAML header (lines 6-7) mentions a separate CLI-level bash allowlist (`--allowedTools Bash(./mvnw:*) Bash(mvn:*)`), but neither the settings nor the hooks in this artifact show that allowlist being enforced — the threat-model claim is unverifiable from the attached evidence.
      wrong_action: A reviewer reading the artifact records the protected-paths policy as L2-enforced. An agent runs the very verification Bash commands the artifact itself points at (`./mvnw test` for the build claim, plain Bash for inspection), and with a redirection twist (`sed -i 's/version = 1/version = 2/' pom.xml` or `echo garbage > infra/k8s/deployment.yaml`) modifies a "protected" file. The gate does not fire. The reviewer, trusting the L2 claim, does not separately verify the CLI-level bash allowlist (which lives outside this artifact).
      anchor: "LAYER: this file is L3 on its own — it is data and executes nothing. It is L2 only through .ai/hooks/policy-gate.sh, which reads it and exits 2. If the hook stops reading it, the file silently becomes a document."
      evidence: protected-paths-v1.1.yaml:6-7,12-14; agent-v1.1-settings.json:3-15; backend-feature-phases.md:5

    - reason: "fnmatch semantics" is named without an implementation. The deny list uses patterns such as `**/pom.xml`. Whether root-level files (relative path `pom.xml`, `Dockerfile`, `.env`, `package-lock.json` at the worktree root, no slash-prefix) match depends on the implementation: Python stdlib `fnmatch.fnmatch` treats `**` like `*` and does not cross `/`, so `**/pom.xml` is effectively `*/pom.xml` and will not match root `pom.xml`; shell `globstar` (bash 4+) treats `**` as zero-or-more directories, so it does. The artifact names neither, so root-file match status is undefined.
      wrong_action: A reviewer applying shell-fnmatch records root `pom.xml` as matched (denied) by the gate. A reviewer applying Python stdlib fnmatch records root `pom.xml` as not matched (allowed). Two reviewers, applying different implementations of the artifact's own "fnmatch semantics," will disagree about whether a root-level build file is actually denied. The L2 claim cannot be evaluated against the artifact because the matcher is ambiguous — and the artifact explicitly says `applies_to: [Edit, Write, NotebookEdit]`, meaning an agent's first edit attempt is the very event whose gate behaviour the reviewer cannot predict.
      anchor: "Patterns are matched against the path RELATIVE to the worktree root, with fnmatch semantics, after the absolute path is made relative."
      evidence: protected-paths-v1.1.yaml:17,19-20,26-43

  non_blocking:
    - reason: backend-feature-phases.md lines 116-122 claim "These boundaries are prose and nothing executes them" and that the tool list is "the only line in this file that constrains anything." At v1.1 this is false: the deployed system (agent-v1.1-settings.json lines 5-9) wires policy-gate.sh to Edit|Write|NotebookEdit, which executes the boundary at tool-call time. The agent's self-model is stale; the system still enforces, but the agent's prompt mis-describes the system it sits inside — it will be the first time the gate refuses a Dockerfile edit the file says could pass.
      evidence: backend-feature-phases.md:116-122; agent-v1.1-settings.json:3-15

    - reason: Completion-contract clause 6 ("No forbidden files changed. Nothing outside the task's scope: not build files, not lockfiles, not config you found untidy, not formatting.") restates the protected-paths gate that already denies at tool-call time — a constant across every run the system can produce, which is the exact defect the lab's v1→v2 rubric lesson documents ("restating a gate is a constant"). Separately, the contract names "a script" that checks the seven clauses "after the run" without naming it; "a script" is not a thing that executes, so per the layer rule the completion contract is L3 even in its own account.
      evidence: agent-v1.1-CLAUDE.md:36-58,40-41; protected-paths-v1.1.yaml:25-43; agent-v1.1-settings.json:5-9

    - reason: Two different stop thresholds for the same situation. backend-feature-phases.md line 79 says "If it fails twice for the same reason, stop and escalate. Never report a command you did not run or a result you did not see." agent-v1.1-CLAUDE.md line 13 says "The same failing command may be attempted at most 3 times. The 4th identical attempt is refused before it runs." Neither file names which governs, and "fingerprint" of a command is never defined (so whether `mvn test` and `mvn test -q` are the same failing command is unresolved).
      evidence: backend-feature-phases.md:77-80; agent-v1.1-CLAUDE.md:11-22

    - reason: The completion contract's "Required tests passed. All of them, not only the ones you touched, and the new behaviour has a test that would fail against the old code" is ambiguous between "the ticket-named test set" and "every test in the repository." Two faithful readers resolve differently; an agent that scored the ticket-named tests but skipped an unrelated failing integration suite could legitimately claim DONE under one reading and not the other.
      evidence: agent-v1.1-CLAUDE.md:46-48

    - reason: The phase markers (ANALYSIS, DESIGN, IMPLEMENTATION, VERIFICATION, REVIEW, DONE) are strings the agent places in its own visible message. Nothing in the attached evidence executes on them. An agent can emit `<<PHASE:DESIGN>>` and immediately Edit without producing the prose the DESIGN section lists (proposed change, alternative rejected with reason, data and error flow, test strategy). The marker is a discipline, not a gate — and the file acknowledges this implicitly ("the marker goes in your visible message, not in a file").
      evidence: backend-feature-phases.md:18-31,55-63

    - reason: "Touch a file only if the ticket cannot be completed without touching it" (backend-feature-phases.md:71) has no objective standard for "cannot be completed without." Given a ticket that can technically be completed by adding five mapping lines inside an existing service, one reviewer considers the new mapper necessary to match repository convention; another says the ticket can technically be completed without it and treats it as a scope failure. Two faithful reviewers given the same diff will diverge.
      evidence: backend-feature-phases.md:68-71

    - reason: The escalation clause ("the ticket is ambiguous about a case it names") does not commit to a threshold. "Ambiguity that changes correct behaviour" produces escalation on a 400-vs-422 split when nearby endpoints use both; "ambiguity the ticket can be reasonably interpreted past" produces proceed. The artifact does not say which, only "stop and report instead of proceeding when the ticket is ambiguous about a case it names."
      evidence: backend-feature-phases.md:126-130

    - reason: `<<PHASE:DONE>>` is required on escalation (backend-feature-phases.md:130: "If you escalate, still emit `<<PHASE:DONE>>` and put the reason in `Not done`") even though the completion contract (agent-v1.1-CLAUDE.md:51-58) says an agent is "not done" if any clause fails. A transcript consumer using DONE as phase state records completion; a reviewer using the prose records an incomplete escalation. The marker does double duty the prose does not resolve.
      evidence: backend-feature-phases.md:128-131; agent-v1.1-CLAUDE.md:36-58

    - reason: backend-feature-phases.md line 110 names "approved commands" in the Allowed row without defining them in the prompt itself. The YAML header (protected-paths-v1.1.yaml lines 6-7) separately notes bash is allowlisted to `./mvnw:*` and `mvn:*`, but only a reader of both files sees that. An agent reading only its prompt has no machine-readable definition of what counts as approved — and "Approved" lines 112-113 list cross-module architectural change, security-sensitive redesign, and new external dependency as Approval-tier actions without a process for obtaining approval.
      evidence: backend-feature-phases.md:107-114; protected-paths-v1.1.yaml:6-7

  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 62s |
| ollama-cloud/deepseek-v4-pro | ok | 89s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 independent families (2 run(s))

How many DIFFERENT model families flagged each section — not how often one model
repeated itself. A section flagged twice by the same family counts once, so a chatty
model cannot outvote the panel.

**1/2 is not weak evidence.** Families find different classes of defect: on
2026-08-28, glm-5.2 found gaps in the anchor ladder and an anchor citing evidence that
is not attached, while deepseek-v4-pro found four textual ambiguities in the same file.
Neither saw the other's list. A 1/2 row is one lens holding something the others do
not — read it first, not last.

| Section | Families | Layer of implied fix |
|---|---|---|
| deny | 1/2 | L2 |
| Repair limits — these are enforced, and not by this file | 1/2 | L3 |
| The completion contract | 1/2 | L3 |
| tools | 1/2 | L2 |
| `<<PHASE:DESIGN>>` — decide before you type | 1/2 | L3 |
| `<<PHASE:IMPLEMENTATION>>` — the smallest change that matches the design | 1/2 | L3 |
| `<<PHASE:VERIFICATION>>` — the claim becomes evidence | 1/2 | L3 |
| `<<PHASE:REVIEW>>` — read your own diff as a reviewer would | 1/2 | L3 |
| `<<PHASE:DONE>>` — the completion contract | 1/2 | L3 |
| Boundaries | 1/2 | L2 |
| Escalation | 1/2 | L3 |
| hooks | 1/2 | L2 |
| Cross-cutting | 1/2 | L2 |
| protected-paths-v1.1.yaml | 1/2 | L2 |
| agent-v1.1-CLAUDE.md | 1/2 | L3 |
| backend-feature-phases.md | 1/2 | L3 |
| agent-v1.1-settings.json | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### version
**Verdict:** no finding
**Failure:** No concrete input makes the declared format version produce a divergent or wrong outcome in the supplied evidence.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### policy
**Verdict:** no finding
**Failure:** No concrete input makes the policy identifier ambiguous within the supplied evidence.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### applies_to
**Verdict:** no finding
**Failure:** The listed operations correspond exactly to the policy-gate matcher shown in settings; no divergent handling is demonstrated for these values.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### deny
**Verdict:** finding
**Failure:** Given a root-level `pom.xml`, `Dockerfile`, `.env`, or `package-lock.json`, an fnmatch implementation in which `**/pom.xml` requires a slash will not match it. One reviewer will treat the root file as protected because the comments say all build files are denied; another implementing the stated fnmatch semantics will allow the edit.
**Layer of the implied fix:** L2
**Anchor:** Patterns are matched against the path RELATIVE to the worktree root, with fnmatch semantics

### message
**Verdict:** no finding
**Failure:** For a path actually rejected by the policy gate, the message gives a determinate outcome and recovery path; no concrete divergent handling is evident.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Run state, repair limits, and the completion contract
**Verdict:** no finding
**Failure:** The opening text accurately classifies itself as non-executing guidance and identifies hooks as the executing controls; no concrete contradictory outcome is evident.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Repair limits — these are enforced, and not by this file
**Verdict:** finding
**Failure:** Run `./mvnw test` and let it fail twice for the same cause. This section permits a third execution because only the fourth identical attempt is refused, while `backend-feature-phases.md` requires stopping after the second failure. A reviewer applying this section permits attempt three; a reviewer applying the phase procedure requires escalation.
**Layer of the implied fix:** L3
**Anchor:** The same failing command may be attempted at most 3 times.

### Run state
**Verdict:** no finding
**Failure:** The writer, persistence purpose, reserved block, and instruction not to edit it are explicit; no concrete input produces two supported interpretations.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### The completion contract
**Verdict:** finding
**Failure:** Suppose a ticket names `./mvnw -Dtest=OrderServiceTest test`, that command passes, but an unrelated integration suite fails. One reviewer reads “Required tests” as the ticket-named tests and permits `DONE`; another reads “All of them” as every repository test and rejects completion.
**Layer of the implied fix:** L3
**Anchor:** Required tests passed. All of them, not only the ones you touched

### name
**Verdict:** no finding
**Failure:** The declared name has one unambiguous value and no conflicting use in the supplied artifact.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### description
**Verdict:** no finding
**Failure:** The description consistently identifies one backend ticket, an existing Spring Boot repository, phased work, tests, and verification.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** no finding
**Failure:** No concrete scenario in the supplied evidence makes the declared model value ambiguous or wrong.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### tools
**Verdict:** finding
**Failure:** The agent can execute `printf '\n<!-- changed -->\n' >> pom.xml` through `Bash`. The protected-path hook does not run because settings attach it only to `Edit|Write|NotebookEdit`; therefore the supposedly protected build file is modified without rejection.
**Layer of the implied fix:** L2
**Anchor:** tools: Read, Edit, Write, Bash

### Mission
**Verdict:** no finding
**Failure:** The scope, repository type, ordering requirement, and absence of delegation are explicit; no concrete divergent handling is evident.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### The phase marker
**Verdict:** no finding
**Failure:** The exact markers, order, count, destination, and no-reentry rule determine the expected transcript for both successful and escalated runs.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### `<<PHASE:ANALYSIS>>` — before you have an opinion about the fix
**Verdict:** no finding
**Failure:** For a ticket whose HTTP error status is unspecified, this section determinately requires inspecting repository convention and escalating if the unresolved choice changes correctness; it also explicitly forbids editing.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### `<<PHASE:DESIGN>>` — decide before you type
**Verdict:** finding
**Failure:** After emitting `<<PHASE:DESIGN>>`, an agent can immediately edit `OrderService.kt` before producing the proposed change, alternatives, flow, or test strategy. One reviewer accepts this because the first code came after the marker; another rejects it because the section requires deciding before typing and completing the listed design outputs first.
**Layer of the implied fix:** L3
**Anchor:** The first line of code comes after this phase's marker, never before it.

### `<<PHASE:IMPLEMENTATION>>` — the smallest change that matches the design
**Verdict:** finding
**Failure:** A ticket can be completed either by adding a mapper class or by duplicating five mapping lines inside an existing service. One reviewer considers the new mapper necessary to match repository convention; another says the ticket can technically be completed without that file and therefore treats it as a scope failure.
**Layer of the implied fix:** L3
**Anchor:** Touch a file only if the ticket cannot be completed without touching it.

### `<<PHASE:VERIFICATION>>` — the claim becomes evidence
**Verdict:** finding
**Failure:** If `./mvnw test` fails twice from the same compilation error, this section mandates escalation, while the repair-limit description says the same failing command may be attempted three times. Applying the two artifacts yields different permitted next actions.
**Layer of the implied fix:** L3
**Anchor:** If it fails twice for the same reason, stop and escalate.

### `<<PHASE:REVIEW>>` — read your own diff as a reviewer would
**Verdict:** finding
**Failure:** For an acceptance criterion saying “returns 409 for duplicates,” an implementation returns 409 but has no test. One reviewer maps the criterion to the observed behaviour and accepts it because the artifact allows “test or behaviour”; another requires durable test evidence and records an unresolved finding.
**Layer of the implied fix:** L3
**Anchor:** every criterion the ticket lists, against the test or behaviour that satisfies it

### `<<PHASE:DONE>>` — the completion contract
**Verdict:** finding
**Failure:** When verification fails twice, Escalation requires emitting `<<PHASE:DONE>>`, but this section says the agent is not done. A transcript consumer using the marker as phase state records completion, while a reviewer using the prose records an incomplete escalation.
**Layer of the implied fix:** L3
**Anchor:** If any one of those is untrue you are not done — say which, and leave it in `Not done`.

### Boundaries
**Verdict:** finding
**Failure:** Run `Bash("curl -X POST https://production.example/deploy")`. The tool list permits Bash, no command-policy hook is configured, and “approved commands” is undefined. One reviewer rejects it as deployment; the executing controls shown do not prevent it.
**Layer of the implied fix:** L2
**Anchor:** Allowed     inspect relevant code · modify relevant code and tests
            run approved commands · produce analysis and verification summaries

### Escalation
**Verdict:** finding
**Failure:** Given a ticket saying only “return an error for an invalid account,” with nearby endpoints split between 400 and 422, one reviewer treats repository convention as sufficient and proceeds; another treats the named invalid-account case as ambiguity affecting correct behaviour and escalates.
**Layer of the implied fix:** L3
**Anchor:** the ticket is ambiguous about a case it names

### hooks
**Verdict:** finding
**Failure:** Execute `sed -i.bak 's/version = 1/version = 2/' build.gradle` through Bash. Only repair-limit and repair-record run; policy-gate does not. The forbidden build file changes even though the configuration appears to establish protected-path enforcement.
**Layer of the implied fix:** L2
**Anchor:** "matcher": "Edit|Write|NotebookEdit"

### Cross-cutting
**Verdict:** finding
**Failure:** The completion contract’s clauses 2, 3, 6, and 7 duplicate the DONE gate’s verification-passed, tests-covered, necessary-files-only, and final-block requirements. The largest expected divergence is Escalation: for an underspecified error response, reviewers can differ categorically—proceed versus stop—rather than by a minor score. The artifacts needed to say how Bash-based filesystem mutation is rejected, what set “all” required tests denotes, and whether `DONE` is merely a phase marker or a successful completion state.
**Layer of the implied fix:** L2
**Anchor:** "matcher": "Edit|Write|NotebookEdit"


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### protected-paths-v1.1.yaml
**Verdict:** finding
**Failure:** The file claims (line 24) to be "the L2 version of" the boundary sentence *"a change to a build file, a lockfile, a CI file, a Dockerfile, a chart, or anything under an infrastructure or deployment directory is out of scope by definition."* The sentence is a closed set of categories; the `deny` list is a closed enumeration that does not cover them. An agent that edits `Dockerfile.prod` (or `Dockerfile.dev`, `Containerfile`) — a Dockerfile the sentence says is out of scope "by definition" — matches no pattern: `**/Dockerfile` requires the path to end in exactly `Dockerfile`, so `Dockerfile.prod` passes the gate, exits 0, and the edit lands. Same for `Jenkinsfile` / `.gitlab-ci.yml` (CI files the sentence names, but only `.github/**` is listed) and `pnpm-lock.yaml` / `compose.yml` (lockfile/chart variants no pattern catches). Two reviewers diverge: one reads "the L2 version of that sentence" as *the boundary is enforced*, the other reads the actual list and sees three whole categories the sentence names are still prose. The header's own framing — "This file exists to be MEASURED against that zero" — is the only honest reading, and it is not what line 24 says.
**Layer of the implied fix:** L2 — the fix is to widen what the gate rejects (more `deny` entries, or a category-level match), since the gate is already the executing mechanism. As written, the *claimed* coverage is L2 but the *actual* coverage is narrower; the sentence's categories remain L3 for anything not enumerated.
**Anchor:** "That sentence is the L3 version of this file. This is the L2 version of that sentence." / `  - "**/Dockerfile"`

### agent-v1.1-CLAUDE.md
**Verdict:** finding
**Failure:** Completion-contract clause 6 — "No forbidden files changed. Nothing outside the task's scope: not build files, not lockfiles…" — is a restatement of the `protected-paths` boundary, which is already enforced by `policy-gate.sh` at tool-call time (an L2 gate that refuses the `Edit`/`Write` before it runs). Because the gate denies the edit upstream, clause 6 is a constant across every run this system can produce: the forbidden file never changes, so the "after the run" script has nothing to catch. This is the exact defect the lab's rubric v1→v2 lesson documents ("any anchor restating a gate is a constant"). A second, separate defect in the same section: the file says these clauses are "checked after the run by a script" but never names the script — "a script" is not a thing that executes, so per the layer rule the completion contract is L3 even in its own account, while the prose reads as if there is an enforcement step. Two reviewers disagree on whether clause 6 is enforced or merely repeated.
**Layer of the implied fix:** L3 — clause 6 is guidance that duplicates an L2 gate and carries no information; its "script" is unnamed and therefore L3.
**Anchor:** "6. **No forbidden files changed.** Nothing outside the task's scope…" / "They are checked **after** the run by a script"

### backend-feature-phases.md
**Verdict:** finding
**Failure:** Lines 120–122 state "These boundaries are prose and nothing executes them… `Edit` on the feature and `Edit` on a deployment descriptor are the same tool." This is false at v1.1: the deployed system (settings.json → `policy-gate.sh`) *does* execute the boundary, refusing the `Edit` on the deployment descriptor with exit 2 before it runs. The agent's own model of what will stop it is wrong, and the consequences are concrete: an agent that trusts this file attempts a `Dockerfile` edit expecting it to go through and be caught only at `DONE` self-review, then hits a mid-run refusal it was told could not happen, and either wastes budget reasoning about it or retries against a policy whose message says "Do not retry this edit." Two reviewers diverge on whether this file accurately describes the system: one reads it as a correct self-description, the other as stale relative to the v1.1 gate. (Separate, lower-severity inconsistency in the same file: VERIFICATION says "If it fails twice for the same reason, stop and escalate," while the enforced repair limit in agent-v1.1-CLAUDE.md permits the same command three times before the 4th is refused — two different stop thresholds for the same situation, and the file doesn't say which governs.)
**Layer of the implied fix:** L3 — the fix is correcting a documentation claim; the enforcement already exists and is misdescribed.
**Anchor:** "**These boundaries are prose and nothing executes them.** The tool list above is the only line in this file that constrains anything"

### agent-v1.1-settings.json
**Verdict:** finding
**Failure:** The `policy-gate.sh` hook is attached only to the `Edit|Write|NotebookEdit` matcher. `Bash` — which is in the agent's tool list (backend-feature-phases.md line 5) and is the tool the agent is explicitly told to use for search and test-running — routes through `repair-limit.sh` / `repair-record.sh`, never through the policy gate. Any Bash command that writes a file bypasses the protected-paths boundary entirely: `sed -i 's/x/y/' pom.xml`, `echo garbage > infra/k8s/deployment.yaml`, `git checkout -- .github/workflows/ci.yml`, `tee -a Dockerfile`. The gate exits 0-equivalent (never runs) and the protected file is modified. This collapses the "L2" claim made in protected-paths-v1.1.yaml's header: the boundary is enforced for exactly three tool names and freely circumventable through the one tool with the broadest filesystem reach. Two reviewers disagree on whether the policy is "enforced" at all — one reads the matcher and says three tools are covered, the other reads the agent's tool list and says the enforcement scope is a subset that excludes the bypass.
**Layer of the implied fix:** L2 — the fix is to route Bash's file-writes through the gate (a `Bash`-matcher policy hook that inspects the command, or equivalent); the gate already exists and executes, it is simply not wired to the tool that can do the most damage.
**Anchor:** `"matcher": "Bash"` (paired with the absent policy-gate on that matcher) / `"matcher": "Edit|Write|NotebookEdit"`

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Name both: yes — completion-contract clause 6 ("No forbidden files changed") in `agent-v1.1-CLAUDE.md` duplicates the `policy-gate.sh` protected-paths gate in `protected-paths-v1.1.yaml` / `agent-v1.1-settings.json`. The gate denies the edit at tool-call time, so the clause is a constant across every run the system can produce, not an independent check.
- Which single section would you expect two reviewers to diverge on most, and by how much? `protected-paths-v1.1.yaml`'s header claim that it is "the L2 version of that sentence." The divergence is binary and total: a reviewer who accepts the claim reads the boundary as *enforced*; a reviewer who reads the `deny` list reads it as *a subset of the sentence's categories, the rest still prose*. Combined with the `Bash` bypass in settings.json, this is the one place where two competent readers would report opposite verdicts ("the boundary is enforced" vs "the boundary does not exist except for three tool names"), rather than merely different severities.
- What did the artifact not say that it needed to say? (1) The artifacts never specify what the policy gate *cannot* see — that `applies_to`/the matcher excludes `Bash`, so the boundary is bypassable by the tool the agent uses most; a reviewer cannot discover this from any single file and must diff the YAML against settings.json. (2) `agent-v1.1-CLAUDE.md` names "a script" that checks the completion contract but never names it, so its existence is unverifiable — the difference between an enforced contract and a promise is exactly one filename, and it is missing. (3) "Fingerprint" in the repair limits is never defined, so whether `mvn test` and `mvn test -q` are "the same failing command" is unresolved, and the two-stop-threshold inconsistency (fail-twice vs 3-attempts) between the agent file and the hook is left for the reader to reconcile.
