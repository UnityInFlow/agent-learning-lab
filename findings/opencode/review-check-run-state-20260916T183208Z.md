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
reviewed_utc:    20260916T183208Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: tools/check-run-state.sh
    sha:  495bc140e443
    dirty: false
  - path: tools/check-completion-contract.sh
    sha:  edbb494d8860
    dirty: false
  - path: tools/verify-run-state-checker.sh
    sha:  a1e64f8e8530
    dirty: false
  - path: tools/verify-completion-contract-checker.sh
    sha:  0eee588ff234
    dirty: false
lab_head:        d5bd985
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

→ Read build/customizations/agent-v1.1/.ai/policies/protected-paths.yaml

✗ Invalid Tool
The arguments provided to the tool are invalid: Model tried to call unavailable tool 'Bash'. Available tools: glob, grep, invalid, list_mcp_resource_templates, list_mcp_resources, memtrace_analyze_relationships, memtrace_ask_docs, memtrace_calculate_cyclomatic_complexity, memtrace_check_job_status, memtrace_cleanup_episodes, memtrace_cleanup_stale_records, memtrace_cleanup_worktrees, memtrace_create_anchor, memtrace_delete_repository, memtrace_detect_changes, memtrace_embed_diag, memtrace_embed_reset_breaker, memtrace_export_query_audit, memtrace_find_api_calls, memtrace_find_api_endpoints, memtrace_find_ast_review_issues, memtrace_find_bridge_symbols, memtrace_find_central_symbols, memtrace_find_code, memtrace_find_code_review_issues, memtrace_find_cross_module_issues, memtrace_find_dead_code, memtrace_find_dependency_path, memtrace_find_duplicate_code, memtrace_find_hotspots, memtrace_find_most_complex_functions, memtrace_find_symbol, memtrace_find_yaml_rule_matches, memtrace_fleet_acquire_lease, memtrace_fleet_audit, memtrace_fleet_branch_context, memtrace_fleet_get_episode, memtrace_fleet_get_escalation, memtrace_fleet_get_node_state, memtrace_fleet_list_escalations, memtrace_fleet_preflight, memtrace_fleet_publish_intent, memtrace_fleet_query_episodes, memtrace_fleet_record_episode, memtrace_fleet_release_lease, memtrace_fleet_renew_lease, memtrace_fleet_resolve_escalation, memtrace_fleet_status, memtrace_fleet_submit_verdict, memtrace_fleet_ydoc_append, memtrace_fleet_ydoc_read, memtrace_get_api_topology, memtrace_get_arc, memtrace_get_changes_since, memtrace_get_cochange_context, memtrace_get_codebase_briefing, memtrace_get_daily_briefing, memtrace_get_directory_tree, memtrace_get_episode_replay, memtrace_get_evolution, memtrace_get_function_quality_metrics, memtrace_get_impact, memtrace_get_process_flow, memtrace_get_repository_stats, memtrace_get_service_diagram, memtrace_get_source_window, memtrace_get_style_fingerprint, memtrace_get_symbol_context, memtrace_get_timeline, memtrace_governing_contracts, memtrace_governing_rules, memtrace_index_directory, memtrace_ingest_graph_fragment, memtrace_link_repositories, memtrace_link_symbols, memtrace_list_anchors, memtrace_list_communities, memtrace_list_indexed_repositories, memtrace_list_jobs, memtrace_list_processes, memtrace_list_watched_paths, memtrace_list_worktrees, memtrace_mem_diag, memtrace_preflight_check, memtrace_read_doc, memtrace_recall_decision, memtrace_record_external_episode, memtrace_replay_history, memtrace_review_agent_sessions, memtrace_review_github_pr, memtrace_search_docs, memtrace_unwatch_directory, memtrace_verify_intent, memtrace_watch_directory, memtrace_why_is_this_here, read, read_mcp_resource, skill, task, todowrite, webfetch.

```yaml
acceptance:
  artifact: tools/check-{run-state,completion-contract}.sh + tools/verify-{run-state,completion-contract}-checker.sh
  verdict: REJECT
  summary: The completion-contract checker enforces only 12 of 18 deny patterns because bash case-glob without globstar treats `**` as `*`, and its own fixture set has stale assertions that no longer match the §4a round-2 checker — both would fail on a fresh run.
  blocking:
    - reason: Clause 6's matcher under-enforces every directory-glob deny pattern. The first `case "$pat" in '**/'*)` branch only catches patterns starting with `**/`; the second `case "$f" in ${pat})` branch falls through, and bash without `globstar` collapses `**` to `*`, which does not cross `/`. So `.github/**`, `infra/**`, `deploy/**`, `charts/**`, `k8s/**` (6 of 18 patterns in the registered policy) match only one path component. A change to `.github/workflows/ci.yml` or `infra/terraform/main.tf` is not detected, and clause 6 prints PASS — a control reporting success over the full deny list when it only enforces the `**/`-prefixed subset. The policy file's comment claims "fnmatch semantics" but the implementation is single-level glob.
      wrong_action: A reader who trusts the documented fnmatch claim (and the green fixture set, which only exercises `**/pom.xml`) concludes clause 6 protects CI files and infrastructure directories. In reality, a forbidden change to `infra/terraform/main.tf` slips past the check and the run is recorded as satisfying the contract.
      anchor: >-
        A path matching any of these is DENIED. Patterns are matched against the path RELATIVE to the
        worktree root, with fnmatch semantics, after the absolute path is made relative.
      evidence: build/customizations/agent-v1.1/.ai/policies/protected-paths.yaml:19-23 - reason: verify-completion-contract-checker.sh has stale assertions for evaluator exit 21. Lines 73–75 expect `exit 1` and `line 2 == FAIL`, `line 3 == FAIL`, but the §4a round-2 fix in check-completion-contract.sh maps exit 21 to the `20|21)` case which calls `undec` on clauses 2 and 3 and prints the GUARD note. With a clean worktree (clause 5 PASS, clause 6 PASS, clause 7 PASS), the checker exits 0 — `line 2` and `line 3` print UNDECIDABLE, not FAIL — so the fixture set records three `bad` rows. The fixture was written for the pre-fix checker and was not updated alongside it; the cross-cutting "TWO LINES FROM ONE INSTRUMENT" note in the checker does not fix the fixture.
      wrong_action: Running `tools/verify-completion-contract-checker.sh` on the current tree fails at the first "IT REFUSES" block. CI green is no longer proof the fixture set actually exercises what it claims, and a reviewer reads the failing fixture as evidence the contract is broken when the defect is in the fixture itself.
      anchor: >-
        G=$(run --baseline "$BASE" --evaluator-exit 21 --summary "$SUMMARY" --policy "$POLICY")
        [[ "$G" == 1 ]] && ok "a failing evaluator exit is exit 1" "exit 1" || bad "failing evaluator" "exit 1" "exit $G"
        [[ "$(line 2)" == FAIL ]] && ok "clause 2 (build) FAILS on evaluator exit 21" "FAIL" || bad "clause 2" "FAIL" "$(line 2)"
 [[ "$(line 3)" == FAIL ]] && ok "clause 3 (tests) FAILS on evaluator exit 21" "FAIL" || bad "clause 3" "FAIL" "$(line 3)"
      evidence: tools/verify-completion-contract-checker.sh:73-75
  non_blocking:
    - reason: The clause-5 grep on `XXX` will flag legitimate uses such as `// XXX: see ticket 123` or URL-encoded placeholders in fixtures. The other three patterns (TODO/FIXME/not implemented) are unambiguous; XXX is a judgement call and could be tightened to a leading-anchored pattern.
      evidence: tools/check-completion-contract.sh:121
    - reason: The run-state fixture set does not exercise non-object members of `.blocks` or `.hookExecutions` (e.g. a string in the array). The current checker rejects them via the `null // ""` pattern in its `select` clauses, so this is a coverage gap rather than a current defect — but a future regression in that pattern would not be caught.
      evidence: tools/verify-run-state-checker.sh:78-79
    - reason: Clauses 2 and 3 of the completion contract share the evaluator exit code. The artifact acknowledges this with the "TWO LINES FROM ONE INSTRUMENT" note on the checker's stdout, which is the right shape for an honest reporting of the limitation; whether it is acceptable that two scoring categories are derived from one signal is a policy decision rather than a checker defect.
      evidence: tools/check-completion-contract.sh:200
  disputed:
    - finding: codex claimed that `.blocks = ["corrupt"]` and `.hookExecutions = ["corrupt"]` slip past check-run-state.sh because jq errors on field access of a string and the error is treated as a false predicate.
      why: jq returns null for property access on non-objects, and the checker's `select((.reason // "") == "" or (.fingerprint // "") == "")` evaluates `null // ""` = `""`, which matches the empty-string comparison, so the entry is selected, `length > 0` is true, and the file is rejected. Same logic for `.decision`. The premise (jq errors) is wrong, so the conclusion (checker accepts) does not hold against the artifact.
    - finding: codex claimed that check-completion-contract.sh reports clauses 2 and 3 as FAIL on evaluator exit 21, and that the verifier fixture set blesses it.
      why: The checker was updated by §4a round 2 to map exit 20/21 to `undec` on both clauses, with the GUARD note printed. The first part of codex's claim references the pre-fix state; the second part (against the fixture set) is correct and captured under the blocking findings.
    - finding: deepseek claimed that check-run-state.sh hardcodes REG_PER=3 and REG_TOTAL=7 at lines 94–95, duplicating the constants in repair-limit.sh and the fixture set.
      why: Lines 94–95 are part of a comment block explaining why the values are no longer hardcoded. The actual code at lines 111–117 reads the constants from repair-limit.sh via `sed -n 's/^MAX_PER_FINGERPRINT=...'` and refuses to guess on failure (lines 114–117, exit 30). The single-source reading deepseek asked for is already in place.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 53s |
| ollama-cloud/deepseek-v4-pro | ok | 276s |

Stall budget: 900s per family (LAB_REVIEW_TIMEOUT).

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
| tools/check-run-state.sh | 2/2 | L2 |
| tools/check-completion-contract.sh | 2/2 | L2 |
| tools/verify-run-state-checker.sh | 1/2 | L2 |
| tools/verify-completion-contract-checker.sh | 2/2 | L2 |
| Cross-cutting | 1/2 | L2 |

> **2 of 5 rows were raised by one family only.** Recurrence is counted per HEADING
> TEXT: two families describing one defect under different headings appear as two rows
> of 1/2. Read the solo rows against each other before treating them as separate.


---

## Run 1 of 2 — codex

### tools/check-run-state.sh
**Verdict:** finding
**Failure:** A run-state with `.blocks = ["corrupt"]` or `.hookExecutions = ["corrupt"]` passes the top-level array checks. The later jq expressions attempt field access such as `.reason` or `.decision` on a string and exit with an error; because those checks are inside `if jq -e ...`, the error is treated like a false predicate and no problem is recorded. One reviewer treating the arrays as typed record collections rejects the file, while this checker can report it valid.
**Layer of the implied fix:** L2
**Anchor:** if jq -e '[.blocks[] | select((.reason // "") == "" or (.fingerprint // "") == "")] | length > 0' "$FILE" >/dev/null 2>&1; then

### tools/check-completion-contract.sh
**Verdict:** finding
**Failure:** Given an evaluator that successfully compiles the project but exits 21 because a required test fails, the script reports both clause 2, “build passed,” and clause 3, “required tests passed,” as FAIL. A reviewer with the evaluator’s phase-level evidence reports clause 2 PASS and clause 3 FAIL. Conversely, any aggregate exit 0 makes both pass even though the script receives no separate evidence for either clause.
**Layer of the implied fix:** L2
**Anchor:** if [[ "$EVAL_EXIT" == "0" ]]; then
    pass 2 "build passed"          "evaluator exit 0 (shared source, see note)"
    pass 3 "required tests passed" "evaluator exit 0 (shared source, see note)"
  else
    fail 2 "build passed"          "evaluator exit $EVAL_EXIT (shared source, see note)"
    fail 3 "required tests passed" "evaluator exit $EVAL_EXIT (shared source, see note)"

### tools/verify-run-state-checker.sh
**Verdict:** finding
**Failure:** The fixture suite passes while the checker still accepts malformed collection members: mutate the known-good file to `.blocks = ["corrupt"]` or `.hookExecutions = ["corrupt"]`. No fixture exercises a non-object member, so the suite can return exit 0 even though the checker under test incorrectly accepts that file.
**Layer of the implied fix:** L2
**Anchor:** expect "a block with no reason"                          1 "$(mutate '.blocks = [{"fingerprint":"x","reason":""}]')"
expect "a hookExecution with an unknown decision"        1 "$(mutate '.hookExecutions = [{"hook":"h","decision":"maybe"}]')"

### tools/verify-completion-contract-checker.sh
**Verdict:** finding
**Failure:** Use an evaluator result where compilation succeeds and one required test fails, producing aggregate exit 21. The fixture asserts that both clauses 2 and 3 must be FAIL, so it blesses the checker’s wrong build result instead of exposing the lost distinction. A reviewer using phase-specific evidence would mark build PASS and tests FAIL; this suite requires FAIL/FAIL.
**Layer of the implied fix:** L2
**Anchor:** [[ "$(line 2)" == FAIL ]] && ok "clause 2 (build) FAILS on evaluator exit 21" "FAIL" || bad "clause 2" "FAIL" "$(line 2)"
[[ "$(line 3)" == FAIL ]] && ok "clause 3 (tests) FAILS on evaluator exit 21" "FAIL" || bad "clause 3" "FAIL" "$(line 3)"

### Cross-cutting
**Verdict:** finding
**Failure:** The completion checker duplicates the evaluator’s pass/fail gate in scoring categories 2 (“build passed”) and 3 (“required tests passed”); both are derived from the same aggregate exit code. Reviewers would diverge most on `tools/check-completion-contract.sh`: for a successful build followed by a failing test, this artifact yields two failures while a reviewer with separate phase evidence yields one PASS and one FAIL, a one-clause difference. The evidence set does not specify or carry separate build and required-test outcomes, and the run-state checker does not state or enforce the required element shapes for `blocks` and `hookExecutions`.
**Layer of the implied fix:** L2
**Anchor:** NOTE: clauses 2 and 3 are TWO LINES FROM ONE INSTRUMENT (the evaluator's exit code). They are not two independent decisions.


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

→ Read build/customizations/agent-v1.1/.ai/hooks/repair-limit.sh
→ Read build/customizations/agent-v1.1/.ai/policies/protected-paths.yaml
I'll read the two supporting files these scripts depend on, to ground any findings about integration mismatches.
I have all four artifacts plus their two dependencies (repair-limit.sh, protected-paths.yaml). Reviewing in order.

### tools/check-run-state.sh
**Verdict:** finding
**Failure:** The registered limits are hardcoded here (`REG_PER=3`, `REG_TOTAL=7`, lines 94–95) and independently hardcoded in `repair-limit.sh` (`MAX_PER_FINGERPRINT=3`, `MAX_TOTAL=7`, lines 51–52), and the fixture set's expectations hardcode them a third time. Nothing executes the link between these three copies. Raise the limit in `repair-limit.sh` (say the build spec relaxes it to 5/10), run the real hook — which now writes `maxRepairAttemptsPerFailure: 5` — and this checker rejects the hook's own output with `expected the registered 3, found 5`. `verify-run-state-checker.sh` then fails at `known-good` too. The drift is not detected by either script at the moment it occurs; it only surfaces as a rejection of valid data, which is exactly the "control reporting success over a scope smaller than it claims" shape this file's own comment rails against — here inverted, a control failing valid data because its constants went stale. Two reviewers split: one calls it an accepted single-source tradeoff, the other calls it three copies of a constant with no executed link. The comment at lines 86–93 defends hardcoding against the *file* grading itself; it does not address that the hook and the checker are two more copies that can disagree with each other.
**Layer of the implied fix:** L2 — reading the constants from `repair-limit.sh` at runtime, or a test asserting the two files agree, would execute and catch the drift.
**Anchor:** `REG_PER=3`

### tools/check-completion-contract.sh
**Verdict:** finding
**Failure:** Clause 6's deny-list matcher under-enforces every directory-glob pattern. For `pat` values like `.github/**`, `infra/**`, `deploy/**`, `charts/**`, `k8s/**`, the `'**/'*` first branch is skipped (they don't start with `**/`), so they fall to `case "$f" in ${pat})` — and in bash, `**` without `globstar` collapses to `*`, which does not cross `/`. So `.github/**` matches only `.github/<one-component>`; the canonical CI file `.github/workflows/ci.yml` is two levels deep and is *not* matched. Concrete run: baseline, then commit a change to `infra/terraform/main.tf`; run the checker with `--baseline --evaluator-exit 0 --summary --policy <registered>`. Clause 6 prints `PASS … 18 deny pattern(s) read; no changed path matches` and exits 0, while the contract's clause 6 is violated — a forbidden infrastructure file was changed and the checker green-ticks it. This is the house failure mode the artifact names in its own header: a control claiming success over a scope (the full deny list) it only partially enforces.

Two secondary problems in the same block, both real:
- **Clauses 2 and 3 misattribute the evaluator's exit code.** Lines 82–87 treat any non-`0` `--evaluator-exit` as "build failed" and "tests failed". But in this repo the evaluator's non-zero exits encode *task-completion* verdicts — exit 20 = new dependency, exit 21 = unrelated production files changed (stated in `repair-limit.sh:31` and `protected-paths.yaml:4-5`). A run that failed for "unrelated files changed" and whose build/tests actually passed is reported as `FAIL 2. build passed` and `FAIL 3. required tests passed` — two false FAILs. The `TWO LINES FROM ONE INSTRUMENT` note (line 175) confesses the two clauses share one signal but does not confess that the signal does not carry build/test information at all.
- **`XXX` false positive.** Line 103 greps added lines for `TODO\|FIXME\|XXX\|not implemented\|NotImplemented`. `XXX` is a common legitimate marker (e.g. `// XXX: see ticket 123`, or a URL-encoded placeholder in a fixture). A run that adds such a line fails clause 5 and exits 1 despite no stub being left.
**Layer of the implied fix:** L2 — the matcher and the evaluator-exit interpretation both execute; the fix is to make them match the deny-list semantics and the exit-code semantics they claim.
**Anchor:** `case "$f" in ${pat}) HITS="$HITS $f" ;; esac`

### tools/verify-run-state-checker.sh
**Verdict:** no finding
**Failure:** n/a — the fixture expectations correctly mirror the current checker. Note only that it is the third hardcoded copy of the 3/7 constants (lines 74, 98, 109, 111 bake in "4 is above", "3 and 7 are the boundary"), so it inherits the drift defect reported under `check-run-state.sh` rather than introducing its own.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### tools/verify-completion-contract-checker.sh
**Verdict:** finding
**Failure:** The fixture set proves clause 6 only through the basename path. The single clause-6 FAIL fixture (lines 77–81) changes `service/pom.xml`, which matches `**/pom.xml` via the `'**/'*` basename branch — the *working* half of the matcher. None of the five directory-glob patterns (`.github/**`, `infra/**`, `deploy/**`, `charts/**`, `k8s/**`) is ever exercised, so the under-match reported under `check-completion-contract.sh` is invisible to this suite. Concretely: a reviewer who reads only this green fixture set concludes clause 6 is proven to refuse forbidden files, when in fact `infra/terraform/main.tf` passes clause 6 unchecked. The suite's headline claim — "IT REFUSES — each decidable clause driven to FAIL" — is true of every clause *except the part of clause 6 that is broken*, and nothing in the file marks that gap. The `**/pom.xml` case is the easy one; the nested-directory cases are precisely where the checker is wrong, and they are the ones the fixtures skip.
**Layer of the implied fix:** L2 — adding a fixture that changes `infra/terraform/main.tf` and asserts clause 6 FAILs would execute and immediately expose the matcher bug.
**Anchor:** `ok "clause 6 FAILS on a deny-list path" "FAIL"`

### Cross-cutting
- **No scoring category duplicates a pass/fail gate** — these four are not a rubric; there is no scoring ladder to overlap a gate. The nearest analogue is that clauses 2 and 3 of the completion contract are themselves a duplication (two lines from one evaluator exit code), which the checker does flag but does not correct.
- **The two sections that would diverge most between reviewers:** `check-completion-contract.sh` clause 6, by a wide margin — one reviewer reads the `18 deny pattern(s) read` PASS line and the green fixture set and concludes the deny list is enforced; another reads the `case "$f" in ${pat})` matching and sees that five of eighteen patterns match nothing deeper than one path component. That is a full PASS-vs-FAIL divergence on the single clause the artifact calls itself authoritative on. The constant-drift question in `check-run-state.sh` is a smaller, loud-failing divergence.
- **What the artifact did not say that it needed to say:** `check-completion-contract.sh` never states what the evaluator's exit code actually *means* in this repo, so its claim that "the evaluator is the registered instrument for both clauses [build and tests]" (lines 77–79) reads as fact when the code it is built beside (repair-limit.sh, protected-paths.yaml) documents those exits as dependency/file-scope verdicts. It also never states the matching semantics it intends for `**` (recursive vs single-level), which is the single decision the clause-6 bug hinges on and is left implicit in a `case` glob.
