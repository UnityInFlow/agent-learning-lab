# Stop 20 (B9) — §4a review round 1, disposition of every finding

**Panel:** `-P codex`, `-n 2`, union of two runs. The default panel
(`ollama-cloud/glm-5.2 + minimax-m3`) is on a weekly quota limit and produces a ~900-byte
header-only stall; §0a row 2 recorded that this morning and routed the review here, as stop 7 did.

| artifact | findings file | bytes | `## ` sections | exit |
|---|---|---|---|---|
| `experiments/E-022-knowledge-router-BE003.md` | `findings/opencode/review-E-022-knowledge-router-BE003-20260927T091156Z.md` | 24 031 | 5 | 0 |
| `experiments/E-023-knowledge-router-BE004.md` | `findings/opencode/review-E-023-knowledge-router-BE004-20260927T091837Z.md` | 24 735 | 5 | 0 |

**The acceptance gate did not run, and that is structural, not a quota.** Both files' Acceptance
section reads *"The gate failed to run (opencode exit 1)"*. `tools/opencode-review.sh:264` dispatches
codex through `tools/codex-critic.sh`, while the acceptance pass at `:490` always calls
`opencode run --agent lab-acceptance -m $ACCEPT_MODEL`, so `LAB_ACCEPT_MODEL=codex` cannot reach it.
§0a row 2c of 2026-09-26 recorded this. **No `ACCEPT` is claimed here.** §4a's alternative terminal
condition is what this file provides: every line-level finding fixed or disputed in writing.

**Two honest notes before the table.**

1. **The reviewer had Amendment 5.** It was committed at `077bacb`, `2026-09-27T09:11:05Z`; the
   review started at `09:11:56Z`, **51 seconds later**, and its findings cite line `851`, which is
   inside the amendment. So where the review names the `H` ambiguity it is **restating a finding
   already on record, and applying it back to sections written before it** — which is useful, and is
   **not** independent confirmation. Saying otherwise would be the overclaim this project exists to
   catch.
2. **Most of what the review is right about may not be edited.** §4 step 12 and §6: never edit a
   prediction, a decision rule, a result or a registered definition after its run. A finding that is
   *correct about the registered text* is therefore answered with a dated amendment or with this
   file, never by rewriting the text. Each row below says which.

---

## `E-022` — BE-003

| # | finding (severity as the reviewer gave it) | disposition |
|---|---|---|
| 1 | `:26` the instrument cannot decide if retrieval happened; 20 % vs 30 % readings | **FIXED before the review, `077bacb`** — Amendment 5. The review read it and applied it to `:26`; the amendment fixes the scope for every such line at once rather than editing each |
| 2 | `:279` prediction 3's log-non-empty proxy misclassifies run 06 (`H=2` VOID vs `H=3` REJECT) | **FIXED, `077bacb`** — Amendment 5 states the counterfactual verbatim, including that the alternative removes the corpus |
| 3 | `:85` "exactly one thing" is confounded: corpus, router executability and the clause move together | **DISPUTED.** They are one artifact — the *overlay* is the independent variable and `:85`'s table names the file set. §6's one-variable rule is about what differs **between arms**; the four v1.1 files, the agent file, settings and policies are byte-identical and proved so by the driver at `:165-177`. Executability did **not** move in either registered arm: both carry the same `rwxr-xr-x` router. The deliberate failure is the only place it moved, under its own key |
| 4 | `:134` preflight assertion (b) failed at exit 2 and the batch was started anyway | **ALREADY RECORDED** — Amendment 3 is the dated decision, its reasoning and what it costs. The reviewer's *additional* point is real and is **not** fixed: there is no pre-registered precedence rule for a gate overridden by a later amendment. Writing one now would be writing a rule after the event it governs → `author_notes` |
| 5 | `:144` controlled variables says permissions unchanged, but Amendment 2 added an allow rule | **FIXED additively** — Amendment 6 below. The rule was added to **both** arms, so it is controlled rather than confounded, but `:144` as written is wrong and a pointer belongs beside it |
| 6 | `:155` the stated budget omits eight preflight runs, the probes and the orphans | **FIXED additively** — Amendment 6 carries the real count |
| 7 | `:177` MDE says ≥7/10 clears `p=0.0318` but the rule scores `M=6` as INCONCLUSIVE | **DISPUTED as an inconsistency, RECORDED as a wording defect.** The MDE's `p=0.0318` is the **one-arm** test against history; row 2 is the **two-arm** test against the concurrent control. Both are true and `:233` says so in its own cell. The sections do not label which test they mean in every sentence, which is the real defect → Amendment 6 |
| 8 | `:213` no boundary between infra-failure exclusion and a completed run needing reconstruction | **VALID, not fixable here** — the rule is registered. Recorded in Amendment 6 with the one case it was applied to (`413bcf23`) and what a future rule would need |
| 9 | `:233` row 2's "SEPARATED FROM HISTORY" though 6/10 does not clear the historical null | **VALID and it changes nothing: row 2 never fired.** `H = 2` put the verdict on row 0. Recorded in Amendment 6; the row may not be edited |
| 10 | `:288` observed telemetry counts run 06 among non-users | **FIXED, `077bacb`** — Amendment 5, same scope fix |
| 11 | `:359` the table scores all 5 predictions but the prose says 4 are answerable | **DISPUTED.** Prediction 5 (`no other category moves`) is answerable from the sheets regardless of uptake, and is scored HELD; the prose's "four" refers to the four that bear on the treatment's effect. Wording, no factual error → noted in Amendment 6 |
| 12 | `:380` "at most two of five influenced" is false since run 06 may be among the anchor-2 successes | **VALID and FIXED additively** — Amendment 6 states that with contact at 3, the bound is three of five, and that the sentence was written before the census existed |
| 13 | `:401` the sanity check equates "no log" with "no exposure" | **FIXED, `077bacb`** — Amendment 5 |
| 14 | `:231` the Decision does not note the one-run sensitivity | **FIXED, `077bacb`** — Amendment 5 carries the whole counterfactual. The Decision block itself is a registered result and is not edited |
| 15 | `:434` the follow-up reports an unqualified 20 % hit rate | **FIXED, `077bacb`** — Amendment 5 fixes the scope; the workbook's exit gate now states it as a **router** hit rate |
| 16 | `:479` the relocated log path has no freshness check; a stale file could satisfy preflight (b) | **DISPUTED, concretely.** The path is `$TMPDIR/knowledge-log-$(basename "$WORKTREE").jsonl` and a worktree is `observatory-run-<uuid>`. A v4 UUID is unique per run, so the file cannot pre-exist and cannot be shared. Verified: every `knowledge-log-*` name under `$TMPDIR` carries a distinct run uuid. A stale file would need a repeated UUID |
| 17 | `:575` Amendment 2's allow rule could affect a control that creates or executes the router path | **DISPUTED.** `run-b9-batch.sh:178` **refuses outright** if the control overlay has `.ai/knowledge`, at exit 6, and that refusal is in the guard fixture set. `knowledgeHash` is `null` on 20 of 20 controls, checked again this session. A control cannot execute a file it does not have |
| 18 | `:602` Amendment 3 authorises the batch after exit 2 with no stated precedence rule | **same as 4** — recorded, `author_notes` |
| 19 | `:727` Amendment 4 drops a control's 160 s duration "conservatively" with no contamination evidence | **VALID, and it changed no verdict** — duration is excluded from every registered outcome at this stop by §4 step 6. Recorded in Amendment 6 |
| 20 | `:851` the verdict turns on one run's instrumentation omission | **this IS Amendment 5.** The review is quoting the fix back |
| 21 | cross-cutting: `H`-counting ambiguity is the greatest divergence source; no pre-registered exhaustive retrieval-contact definition | **VALID and the most useful thing in the round.** Not fixable retroactively. It is the registered lesson for stop 21 on: **a retrieval-contact definition must be written before the run and must enumerate every mechanism, not name one artifact's log.** → `author_notes` and Amendment 6 |

## `E-023` — BE-004

| # | finding | disposition |
|---|---|---|
| 1 | `:39` a bare `if` with fall-through is scorable 0 or 1; "any movement is unambiguous" does not hold | **VALID, not fixable: the rubric is a registered variable (§7).** Recorded in Amendment 6. It is the same class as `:684` and it bounds what a single scorer's cell means |
| 2 | `:57` prediction 3's two thresholds conflict (7 non-empty vs 4 index-first) | **DISPUTED as a conflict.** They are two clauses of one prediction and both are reported: `≥7/10 non-empty` **and** `≥5/10 index-first`. Both were refuted (1 of 10 and 1 of 10). A prediction with two clauses is not a contradiction |
| 3 | `:74` Amendment 2 adds an allowlist entry to both arms post-registration | **same as E-022 #5** — both arms, so controlled; pointer in Amendment 6 |
| 4 | `:99` an absent treated log and exit 2, and the batch ran anyway | **same as E-022 #4** — Amendment 3 records it; the missing precedence rule → `author_notes` |
| 5 | `:108` controlled variables does not enumerate permissions | **FIXED additively** — Amendment 6 |
| 6 | `:148` the MDE's "holds down to n=7" is calculated only for equal arms | **VALID.** The realised arms were equal (`n_t = n_c = 10`), so nothing here used the unequal case. Recorded in Amendment 6 as a constraint on reuse |
| 7 | `:185` Fisher is not specified one- or two-sided | **VALID and it decided nothing**: the realised value is `1.0000`, identical either way. Recorded in Amendment 6, with the rule for later steps: **state the sidedness in the decision rule** |
| 8 | `:236` the telemetry running total does not map counts to experiments | **VALID, wording** — Amendment 6 |
| 9 | `:264` the median tie-break convention is unregistered | **VALID and it is the sharpest of the E-023 set.** Recorded in Amendment 6; for later steps the convention is registered **before** the batch |
| 10 | `:301` a run influenced by the clause without router use is mislabelled | **FIXED by Amendment 5's scope**, and noted again in Amendment 6 |
| 11 | `:314` the ticket-length mechanism inferred from 1/10 vs 2/10 is consistent with noise | **CONCEDED, and it is right.** Fisher(1/10, 2/10) = 1.0. Amendment 6 marks that sentence as **a conjecture, not a result** |
| 12 | `:338` the sanity check discards any `H=0` treated effect as instrument noise | **VALID** — the clause text itself could lower `test-quality` without any retrieval, which is E-003's question, not this stop's. Amendment 6 says so and names it as unmeasured here |
| 13 | `:366` the disposition and row 1 word the corpus's fate differently | **FIXED additively** — Amendment 6 states the single disposition: **kept in the repository, not promoted, not removed** |
| 14 | `:378` the "noise floor" bar has no sampling distribution or CI | **VALID** — it is one realised difference at `n = 10`, not an estimated floor. Amendment 6 relabels it as **an observed difference, not a bound** |
| 15 | `:423` the log filename can cross-contaminate concurrent runs sharing a basename | **DISPUTED, same reason as E-022 #16** — the basename carries a per-run UUID |
| 16 | `:519` the allow rule can change control behaviour | **DISPUTED, same reason as E-022 #17** — exit 6 refusal plus `knowledgeHash null` on 20 of 20 |
| 17 | `:596` Amendment 3 overrides the gate with no precedence rule | **same as #4** |
| 18 | `:631` Amendment 4's orphan rules live only in E-022 | **FIXED additively** — Amendment 6 carries the pointer that E-023 lacked |
| 19 | `:684` the hand re-read's bare-`if` diff is scorable as 0 or 1 | **same as #1** — registered rubric, recorded. The hand re-read agreed with the sheet, which is what §5 asks; the ambiguity bounds the cell, not the agreement |
| 20 | `:720` contact via an unrecognised mechanism could be misclassified `no-contact`; blind spots unspecified | **VALID and partly FIXED.** The census enumerates four mechanisms (router exec, `Read` of index/summary/details, `cat`-class shell reads) and its fixture set proves each. **Unenumerated mechanisms remain** — an MCP read, a `find -exec`, the model quoting the corpus from an earlier turn — and Amendment 6 lists them as known blind spots rather than leaving them implicit |
| 21 | cross-cutting: `maintainability` doubles as scored category and gate; `H` doubles as outcome and VOID gate | **VALID, structural, and the author's to weigh.** → `author_notes`. It is why `H ≤ 2` reads as *not tested* rather than as a result about routing |

---

**Round 1 terminal state:** 42 findings, **8 fixed before the review by `077bacb`**, **9 fixed
additively by Amendment 6**, **7 disputed with a concrete reason** (never "stylistic"), **13 recorded
as valid-and-unfixable because the text they name is registered**, **5 routed to `author_notes`**.
Some rows appear in two categories; the count is of dispositions, not of rows. **No `ACCEPT` is
claimed** — the gate is structurally unreachable on this panel.

**Round 2 was not run, and the reason is stated rather than skipped:** the only edits round 1
produced are an **additive amendment** to two registered files. Re-reviewing them would re-review
text the first round already read plus one appended section, on a panel whose acceptance gate cannot
run either way. §4a allows *"every remaining line-level finding is disputed in writing"* as the
terminal condition and that is what this file is.

*Written by Opus 5 (claude-opus-5), autonomously, 2026-09-27. The author did not review it.*
