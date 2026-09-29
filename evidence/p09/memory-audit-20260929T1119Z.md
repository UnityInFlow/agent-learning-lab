# Lab 9.4 — audit of this machine's live memory systems, and a staleness count

Spine stop 24 (Phase 9 — Memory), `agent-learning-lab`, autonomous run.
Produced by Opus 5 (claude-opus-5), autonomously, 2026-09-29.

**This file is frozen evidence. It records the corpus AS FOUND, before any correction.**
The corrections applied afterwards are listed at the bottom with their own timestamp, so a
reader can tell the measurement from the repair. Nothing above that line is edited again.

---

## 1. Lab 9.4 as registered

`phases/09-memory/README.md` §"Lab 9.4 — Audit what you already have *(30 min, no code)*"
asks three questions of the three memory systems it says are live on this machine:

> how many of these facts are still true? Which system would you consult first for "why is
> this code like this"? Has anything ever *removed* a stale fact?

Question 1 is the only one of the three that is a number. This lab answers it as a number,
and answers 2 and 3 in prose in `governance/memory-policy.md`.

## 2. The three systems, verified present rather than assumed

| System | Claim in the README | Command | Found |
|---|---|---|---|
| Claude auto memory | `~/.claude/projects/<project>/memory/` | `stat -f '%z %N' <dir>/*.md` | 16 files: `MEMORY.md` (15 lines, 3 788 B) + **15 memory files**, 67 KB total |
| memtrace | `~/.memtrace/` — `embed-cache`, `cortex-store` | `ls ~/.memtrace/` | present, both named subdirectories exist, plus 8 more |
| Observatory Postgres | `postgres:16.6-alpine` | `curl 127.0.0.1:8081/api/runs?limit=1` | up, **742 run records** |

One number the README does not have: this machine carries **354** `~/.claude/projects/*/memory`
directories, of which this project's is one. "Machine-local, not shared" is not an abstraction
here; it is 354 unreconciled stores on one laptop.

## 3. Scope of the count, stated before the count

The audited unit is **the claim each memory advertises in its `MEMORY.md` index line**, not
the full body of each memory file. 15 index lines decompose into **25 individually decidable
assertions**. A memory's body may carry further claims that were not audited; nothing here is
a statement about those.

`n = 25 assertions, 15 memories, 1 corpus, 1 machine.` A property of these twenty-five
sentences, **not** of agent memory in general.

## 4. The table — every assertion, the command that decided it, the verdict

`T` = true and load-bearing · `TO` = true but obsolete · `F-ev` = false, superseded by a
recorded event · `F-rep` = false, does not reproduce as written · `U` = undecidable by command.

| # | Memory | Assertion as the index advertises it | Deciding command | Found | Verdict |
|---|---|---|---|---|---|
| 1 | agent-observatory-project | three repos, each with its own `CLAUDE.md` | `[ -f <d>/CLAUDE.md ]` ×3 | yes, yes, yes; all three are git repos | T |
| 2 | agent-observatory-project | carries an "author-blocked list" | `TRACK-B-STATE.md:8013` | `blocked_on_author: []` — **empty since 2026-09-25** | F-ev |
| 3 | agent-observatory-project | project #2 auto-closes an issue when its card hits Done | — | would require moving a live card to observe; **refused** | U |
| 4 | agent-observatory-project | `$TMPDIR` reaps kept worktrees files-first in ~3 days | `stat -f '%Sm' $TMPDIR/observatory-run-*` | 84 worktrees; oldest is **2 days** old and still holds 97 files. Claim is about day ~3; the corpus is not old enough to decide it | U |
| 5 | agent-observatory-local-ports | port 3000 is taken | `lsof -nP -iTCP:3000 -sTCP:LISTEN` | LISTEN (`com.docke`) | T |
| 6 | agent-observatory-local-ports | port 8080 is taken | same | **FREE at audit time** — but the claim is about a habitual state and one probe cannot refute it | U |
| 7 | agent-observatory-local-ports | port 5173 is taken | same | **FREE at audit time** — same reservation | U |
| 8 | agent-observatory-local-ports | `infra/.env` is gitignored | `git check-ignore -v infra/.env` | `.gitignore:6:infra/.env` | T |
| 9 | user-does-the-doing | the author overrides the instruct-by-default preference often | — | a claim about a person; no command decides it | U |
| 10 | copilot-cheapest-model | `gh api /copilot_internal/user` reads quota without a session | ran it | returns the quota JSON, no session needed. **But the Copilot arm was removed by Decision G**, so the fact is true and serves nothing | TO |
| 11 | rtk-filters-dotfiles-in-opencode | `rtk git diff` returns **empty** for `findings/` | `rtk git diff cb10974~1 cb10974 -- findings/ \| wc -c` | **8 987 bytes of real diff content** (raw `git diff` = 15 255). Not empty | F-rep |
| 12 | rtk-filters-dotfiles-in-opencode | `rtk git diff` returns **empty** for `.claude/` | same against `e33d109` | **2 398 bytes** (raw = 2 533). Not empty | F-rep |
| 13 | track-b-autonomous-run | the run's prompt sha is `ba62c35dbbd2` | `shasum -a 256 ../PROMPT-opus5-track-b.md \| cut -c1-12` | **`a47590a1e61d`** | F-ev |
| 14 | track-b-autonomous-run | one builder at a time, enforced by a pid lock | `TRACK-B-STATE.md` batch-driver entries | the B8 driver holds `evidence/b08/.batch.lock` and refuses a second batch with exit 8 | T |
| 15 | be-004-cancel-order | the decision-9 draft and the BE-004 rubric draft sit at the workspace root | `ls ../AUTHOR-DECISION-9-BE-004.md ../backend-quality-be004.DRAFT.yaml` | both present | T |
| 16 | be-004-cancel-order | author decision 9 is **unadopted** | `PROMPT-opus5-track-b.md` §3; `TRACK-B-STATE.md author_decisions` | **adopted 2026-09-05**, verbatim in §3 | F-ev |
| 17 | observatory-colima-not-default-context | `127.0.0.1:8081` is the live stack, `18081` is refused, context is colima | `curl` both; `docker context show` | `8081=200` (742 runs), `18081=000`, context `colima` | T |
| 18 | memtrace-upgrade-strips-rail-and-pin | the 1.2.0 install is what is running, and the daemon re-wires the hook | `memtrace --version`; count memtrace entries in `~/.claude/settings.json` | 1.2.0 installed (1.2.8 available); **9** memtrace hook references present | T |
| 19 | cmux-node-options-kills-copilot | a stale `NODE_OPTIONS` preload crashes Node CLIs | `echo $NODE_OPTIONS` | **unset** in this session — the trigger condition is absent, so the claim cannot be exercised | U |
| 20 | gh-graphql-hangs-use-rest | `gh api` REST works where GraphQL hangs | `gh api repos/UnityInFlow/agent-learning-lab` | returned in under a second | T |
| 21 | author-decision-11-decomposition | author decision 11 is **unadopted** | `PROMPT-opus5-track-b.md` §3 | **"author decision 11 is ADOPTED"**, and `author_decisions` runs to item 13 | F-ev |
| 22 | gh-project-field-update-wipes-values | updating a project field without passing existing option ids wipes every card's value | — | verifying it **means performing the destructive act on the live board**. Refused | U |
| 23 | be-005-partial-fulfilment | Gate B′ is awaiting author row confirmation | `PROMPT-opus5-track-b.md` §3, stop 17a row | **"every row author-confirmed"**; Gate B′ passed WRONG 4 of 5 at lab `990cef4` | F-ev |
| 24 | be-005-partial-fulfilment | 3 unpushed commits sit on lab `decision-11/gate-b` | `git log --oneline origin/decision-11/gate-b..decision-11/gate-b \| wc -l` | **3** | T |
| 25 | autonomous-run-kit | the kit lives at `~/.claude/autonomous` with `run.sh`, `plan.py`, `ORCHESTRATE.md` | `ls ~/.claude/autonomous` | all three present, plus 17 more entries | T |

## 5. The count

| Verdict | n | share |
|---|---|---|
| **T** — true and load-bearing | 10 | 40 % |
| **TO** — true but obsolete (serves an arm that was removed) | 1 | 4 % |
| **F-ev** — false, superseded by a recorded event | 5 | 20 % |
| **F-rep** — false, does not reproduce as written | 2 | 8 % |
| **U** — undecidable by command | 7 | 28 % |
| | **25** | |

**7 of 25 advertised claims are false today. 11 are true. 7 cannot be decided by running
anything**, and the reason differs per row: two are about a habitual state, two would require
performing the destructive act they warn about, one needs the corpus to be a day older, one is
about a person, and one has no live trigger.

## 6. What executes over this corpus

**Nothing.** Not a narrow check, not a stale one — there is no checker, no schema, no expiry
field and no CI job anywhere that reads these files. Every one of the seven false claims was
found by a human-directed command written for this audit and by nothing else.

This is the sharper half of the comparison with the same stop's extract verification:

| | External-documentation extract (§"Extract re-verified") | This machine's agent memory (Lab 9.4) |
|---|---|---|
| corpus | 8 quotations, 1 page | 25 assertions, 15 memories |
| false today | 5 of 8 | 7 of 25 |
| control that executes | `check-links.sh`, **green** — ok=3 broken=0, exit 0 | **none at all** |
| what the green control proves | every URL resolves | — |
| what it does not | every sentence quoted off those URLs | — |

`check-links.sh` being green while five of eight quotations do not match is an L2 control that
is narrower than a reader assumes. A corpus with **no** control is not the same defect and must
not be reported as one: there is no false assurance here, only absence. The two failure modes
are different, and only the first one lies to you.

## 7. The split reproduces on a second, independent corpus

The extract verification found its five absences split three ways and recorded that a
quotation that was **never right** and a quotation that **went wrong** are byte-identical to
any checker. The same split appears here, on a corpus with no shared authorship, no shared
subject and no shared format:

- **superseded by an event the memory could not know** — 5 of 7 (rows 2, 13, 16, 21, 23). Every
  one duplicates a value that lives authoritatively somewhere else: `blocked_on_author`, the
  prompt sha, `author_decisions`, a gate result. This is the class the README's own closing note
  already named — *"the mitigation that worked was making the memory point at `docs/STATE.md`
  rather than duplicate it — and then `STATE.md` went stale too."*
- **does not reproduce as written** — 2 of 7 (rows 11, 12, `rtk`). Indistinguishable, by any
  command, from a claim that was wrong the day it was written.
- **true but obsolete** — 1 (row 10). Nothing is wrong with it; the thing it serves was deleted.

One corpus is an anecdote. Two independent corpora measured 21 days apart, showing the same
three-way split, is the beginning of a pattern — and the second corpus adds the category the
first could not show, because an external page cannot become *obsolete to you* while staying
true.

## 8. What was decided, and why no instrument was built

§4 step 10 asks for keep / modify / remove per thing, from measurement.

**Not built: a memory-staleness checker in this repository.** The measured justification
exists only for the F-ev class — 5 rows, every one a duplicate of a value that is
machine-checkable. A checker for them is easy to write. It is refused for a reason that is
about controls, not effort: **the corpus is machine-local.** `~/.claude/projects/…/memory/` is
outside both repositories, is not in any CI checkout, and exists in 354 copies on this laptop
alone. A `verify-*.sh` in `agent-learning-lab` that reads it would be green on one machine and
vacuous everywhere else — a control that reports success over a scope smaller than it claims,
which this project has already paid for four times. Building it would add a green check and no
coverage.

**Done instead, and it is the answer to the README's third question.** *"Has anything ever
removed a stale fact?"* — until this lab, **no**. The seven false claims are corrected in the
memory store after this file is frozen. That correction is the first removal this corpus has
had in the 21 days it has existed, and it was triggered by a lab, not by a control.

**Recorded, not fixed:** the mitigation that is repo-ownable is the one the README names and
then reports failing — point at the authority instead of duplicating it. It failed because
`STATE.md` itself went stale. That is the same "no one owns re-validation" problem, one level
up, and it is not solved by another file.

---

## 9. Corrections applied AFTER the measurement — 2026-09-29T11:3xZ

Everything above this line is the corpus as found. Below is what was done to it, recorded
separately so the measurement and the repair are never confused.

All seven `F-ev` / `F-rep` assertions were corrected in place: the `MEMORY.md` index line was
rewritten for each, and a dated `**Corrected 2026-09-29**` paragraph citing this file was
appended to each of the seven memory bodies. Nothing was deleted — the corrections are
additive, so the superseded claim and the reason it was wrong both survive.

| # | Memory | What the correction says now |
|---|---|---|
| 2 | agent-observatory-project | `blocked_on_author` empty since 2026-09-25; read it from `TRACK-B-STATE.md`, not from memory |
| 6, 7 | agent-observatory-local-ports | premise re-probed (3000 LISTEN, 8080 and 5173 free at that moment); conclusion 8081/5174 unchanged; probe, do not assume |
| 11, 12 | rtk-filters-dotfiles-in-opencode | the "returns empty" claim did not reproduce, with both byte counts; the operational caution is kept |
| 13 | track-b-autonomous-run | sha is `a47590a1e61d`; re-compute, never quote |
| 16 | be-004-cancel-order | decision 9 adopted 2026-09-05 |
| 21 | author-decision-11-decomposition | decision 11 adopted; `author_decisions` runs to item 13 |
| 23 | be-005-partial-fulfilment | Gate B′ passed, every row author-confirmed; the 3-unpushed-commits half re-checked and still 3 |

Rows 6 and 7 were classed `U`, not `F`, and were still corrected — because the *reason* they
are undecidable (a habitual state that one probe cannot settle) is itself worth recording where
the next reader will meet it.

**This is the first removal of a stale fact this corpus has had.** It was produced by a lab
running once, by hand, not by anything that executes. Nothing has been added that would catch
the next one.

### One thing the audit found in the lab's own state file, not in the memory store

`TRACK-B-STATE.md`'s current-state header block lists the keys that are still live further
down and says `author_decisions (items 1-12, unchanged)`. **`author_decisions` runs to item
13** — the batch-ceiling rule the author gave on 2026-09-26. The header undercounts by one.
This is the same defect class as row 2 above, in the file the whole run treats as authoritative,
and it is corrected in the same session's state write rather than left for a validator.

## 10. Two of my own numbers were wrong, and both are corrected here rather than rewritten

Found by re-deriving them after §9 was written, before the stop closed. The frozen sections
above are **not** edited; this section supersedes them on these two points only.

**(a) The corpus is 52 days old, not 21.** §8 and the sentence *"the first removal this corpus
has had in the 21 days it has existed"* are wrong. `stat -f '%SB'` gives the oldest memory file
a birth date of **2026-08-08** (`copilot-cheapest-model.md`); the newest is **2026-09-25**. The
corpus is **52 days** old at audit time. The correction makes the finding **stronger, not
weaker** — nothing removed a stale fact from it in fifty-two days, and 7 of 25 claims decayed
over that span rather than over three weeks. The commit message of `2f0044b` carries the wrong
figure and is not rewritten; this is the correction of record.

**(b) The count of per-project memory directories moved during the audit.** `ls -d
~/.claude/projects/*/memory | wc -l` returned **354** at 11:1xZ and **355** at 11:4xZ. Neither
is wrong; the number is a moving target because a new project directory is created by ordinary
use. Every occurrence of "354" should be read as *"354 at 11:1xZ, 355 twenty minutes later"*.
The argument it supports — that a checker in this repository would be green on one machine and
vacuous everywhere else — does not depend on which figure is used.

**Why this section exists in this shape.** §6 forbids overwriting an evidence file. A number I
got wrong is exactly the case where the temptation to edit in place is strongest and the reason
not to is clearest: a reader who finds "52 days" with no trace of "21" cannot tell whether the
measurement or the write-up was repaired. Both are here.

**(c) §7's closing sentence is wrong about *when*.** It reads *"Two independent corpora measured
21 days apart"*. They were measured **on the same day**, 2026-09-29, by the same observer, in the
same session. What differs by weeks is the **age** of the two corpora, not the timing of the two
measurements. The substantive point — that the same three-way split appears in two corpora with
no shared authorship, subject or format — is unaffected, but the independence it claims is
weaker than the sentence implies: **two corpora, one observer, one day** is a pattern worth
looking for again, not a rate.
