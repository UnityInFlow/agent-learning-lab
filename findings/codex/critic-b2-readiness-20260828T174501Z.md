### Part 1 — What is already true
**Verdict:** finding
**Failure:** With the UI process stopped but the Make recipe unchanged, `make urls` still prints UI port 5174. One reviewer marks the ports precondition met because the documented command succeeds; another checks connectivity and marks it unmet. The table therefore treats configuration output as proof of reachability.
**Layer of the implied fix:** L2
**Anchor:** | Ports | API 8081, UI 5174, Tempo 3200, Grafana 3001 | `make urls` |

### Part 2 — The observatory already holds 172 runs, and none of them can be used
**Verdict:** finding
**Failure:** A reviewer estimating historical BE-003 pass frequency can use the ten exit-0 and seven F13 records without scoring their deleted worktrees, while a reviewer applying “none of them can be used” discards those records entirely. The absolute claim conflates unusable for Decision D scoring with unusable for every analysis.
**Layer of the implied fix:** L3
**Anchor:** ## Part 2 — The observatory already holds 172 runs, and none of them can be used

### Part 3 — The codex arm is not isolated, not pinned, and would record a model it never used
**Verdict:** finding
**Failure:** Start with an empty `CODEX_HOME`, then create `CODEX_HOME/AGENTS.md` before invoking Codex. The contaminated instructions can still be written down and loaded, so two reviewers applying the stated layer model diverge: this artifact calls the environment choice L1, while the supplied L1 test says it is not structural unless that bad state is unrepresentable.
**Layer of the implied fix:** L1
**Anchor:** The `CODEX_HOME` variant is the L1 answer and should be preferred if the test says the flag is not enough.

### Part 4 — The Copilot arm may not need to wait
**Verdict:** finding
**Failure:** Suppose the quota counter is replenished or another process consumes quota between the before and after reads. A single run can leave `quota_remaining` unchanged even though the model charged one premium interaction, or show a decrease unrelated to that run. One reviewer proceeds with the Copilot arm; another retains the deferral because the proposed observation does not uniquely establish the cause.
**Layer of the implied fix:** L3
**Anchor:** a single `copilot --model gpt-5.4-mini` run, with `gh api /copilot_internal/user` read before and after, proving `quota_remaining` did not move

### Part 5 — The preconditions the runbook names that are NOT met
**Verdict:** finding
**Failure:** An operator reads “on one run” and rehearses only the Claude arm; another interprets the rehearsal as one run for every intended arm, consistent with Part 6. The first operator can begin the batch without ever exercising Codex isolation, provenance, or attachment behavior.
**Layer of the implied fix:** L3
**Anchor:** run the harness rehearsal now, on one run, and hold the five-run batch until the two arms are at parity

### Part 6 — What must be true before the five-run batch, in order
**Verdict:** finding
**Failure:** Use a task that does not trigger any visible behavior from the global `AGENTS.md`. After a run with `--ignore-user-config`, one reviewer declares the question answered because no RTK-routed command appears; another refuses because absence of observable RTK behavior does not prove the file was not loaded. The required test has no stated observable or acceptance condition.
**Layer of the implied fix:** L2
**Anchor:** the `--ignore-user-config` / `AGENTS.md` question answered by test rather than by reading the help text

### Part 7 — Known, and deliberately not fixed here
**Verdict:** finding
**Failure:** Run `N=5` with three benchmark invocations failing before records are created. The recipe prints five banners and exits 0; an operator or automation that trusts the exit status advances with only two observations, while a reviewer who manually counts the comparison output blocks the phase. This produces a baseline with the wrong sample size.
**Layer of the implied fix:** L2
**Anchor:** `$(MAKE) run-benchmark || true` in the loop means a batch of five where three died prints five banners and exits 0.

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is present, so none duplicates a pass/fail gate. Part 4 is the section most likely to produce reviewer divergence: the same unchanged quota counter can yield opposite go/no-go decisions, effectively the full binary decision range. The artifact needed explicit, observable acceptance criteria for the isolation and quota experiments, plus an executed rejection when a batch produces fewer than N valid run records.
**Layer of the implied fix:** n/a
**Anchor:** n/a

