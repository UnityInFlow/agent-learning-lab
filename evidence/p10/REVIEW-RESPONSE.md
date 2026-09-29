# §4a review — findings, and what was done with each

Round 1 subjects and files:

| subject | findings file | exit | verdict |
|---|---|---|---|
| `phases/10-production-observability/README.md` | `findings/opencode/review-README-20260929T181214Z.md` | 0 | **REJECT** |
| `evidence/p10/PREDICTION-scrub-scope.md` | `findings/opencode/review-PREDICTION-scrub-scope-20260929T182215Z.md` | 0 | **REJECT** |

Both on the panel `-P codex,deepseek-v4-pro`, 2 runs across 2 independent families. Both files
have real bodies (24 971 and 14 855 bytes, 24 295 and 14 163 below line 20) — neither is a
header-only stall. 11 of 15 rows on the workbook were raised by one family only; recurrence is
a detection threshold, not a truth value, so 1/2 findings are treated as findings.

## A process violation of §4a, stated first because it is mine

**§4a rule 4 says never edit the artifact while its review is running, and I did.** The
workbook review started at `18:12:14Z`; at roughly `18:20Z` I rewrote its checkbox-2 section
(commit `716c7aa`) after a second preflight run refuted the first run's reading. So round 1's
findings are against a version of the workbook that no longer exists in one section.

Handled rather than hidden: **round 2 was run on the final artifact**, and the carry-over of
each round-1 finding is asked for explicitly. The round-1 file is kept, not deleted. The
lesson is the ordinary one — a long review and a live edit do not share an artifact, and the
right move was to copy it aside, which rule 4 says in as many words.

## Workbook — round 1

| # | Finding (section) | Recurrence | Disposition |
|---|---|---|---|
| 1 | **Scrub deletion proven for a log record; the conclusion extends to span and data-point attributes** | **2/2** | **FIXED**, `6e22a9a`. This is the round's best finding and it is the house failure mode turned back on me: I probed the **logs** pipeline and wrote the conclusion as if it covered all three. The claim now reads *"measured scope is the LOGS pipeline's log-record attributes"*, names the traces and metrics pipelines as **expected but unprobed**, and says so as "two probes that were not run" |
| 2 | **"Run produces a trace" rated L2 in the lab and L1 in the §5 table** | **2/2** | **FIXED**, `6e22a9a`. Reconciled to **L1**, with the rule applied in order in the cell: nothing in this repository can hand-write a span into Tempo, so question 1 answers *no* and the rule stops. It had been L2 for *"Tempo returned the trace"* — but a store answering a query is not a thing that rejects a wrong value |
| 3 | **`L1/L2/L3` of the "Three layers" section clashes with the guardrail layers** | **2/2** | **FIXED as a recorded clash, not an edit**, `6e22a9a`. Two unrelated three-level scales share three labels: the author's metric taxonomy (adoption / execution / impact) and the workspace guardrail scale (structural / enforced / guidance). A note now says which is which and that every other "L1/L2/L3" in the file is the guardrail scale. The author's section is not renamed — §6, and it is the author's text |
| 4 | **Extract: `user.id` "Always sent" versus 0 occurrences in the census** | **2/2** (run 2) | **FIXED by reconciliation**, `6e22a9a`. Both are true about different points in the path: *always sent* is what the runtime **emits**, the census is what the collector **writes to disk**, and `user.id` is on the scrub delete list. **The probe is what makes that an observation** rather than an assumption — the same processor removed the planted record-level `user.email`. The note also says why the same reasoning does **not** rescue `user.email`: these runs have no OAuth identity to emit |
| 5 | **Extract: `lines_of_code.count` versus `claude_code.lines_of_code.count`** | **2/2** | **DISPUTED — already stated.** The workbook's second-pass extract gives both spellings side by side at the lines the finding cites and says which the page gives. That is the correction, written as a correction; the finding is reading the first-pass text without its amendment |
| 6 | **§4 step 2 says two Lab 10.0 questions are open; the RUN says all three are answered** | 1/2 | **FIXED**, `6e22a9a`. The row was written at §0 boundary 1, before the run. A dated amendment carries it and the row is not rewritten |
| 7 | **The #48 re-scoping table still calls checkboxes 2 and 3 open** | 1/2 *(same class as #6)* | **FIXED**, `6e22a9a`, with a superseding note above the table. Nothing in the table was wrong when written: it is a reading of the **#48 fix**, and the #48 fix did not answer them. The run did |
| 8 | **Extract: "no runtime's spans supply cost" is false if a vendor attribute exists** | 1/2 | **FIXED by narrowing**, `6e22a9a`. Now *"no **conformant** span carries it"*, with the empirical half stated separately at its own `n`: Claude's spans do not carry it on this stop's two traces, `n = 2` |
| 9 | **Verified reading: the GenAI semconv URL is ticked on HTTP 200 although the live content is a tombstone** | 1/2 | **DISPUTED — already recorded, three times.** The tick carries `⚠️` and the sentence *"Tombstone, already recorded"*; `SOURCES.md` states the precedence rule (*a ✅ is a statement about HTTP, a tombstone is a statement about CONTENT, and the tombstone wins*); the §5 table's first row labels the link check **L2 for "the URLs answer", L3 for "the content is current"** and names the two dead-for-the-reader pages. The finding is right about the world and wrong that the file is silent. It is lab#13's open question and is in `author_notes` |
| 10 | **Goal: "achieved" versus "operating evidence" undefined; no repository-level outcomes** | 1/2 | **DISPUTED — out of this stop's scope, and answered in substance.** The Goal section is the author's first-pass text. The substance is answered in the exit gate: **this chapter can have no L3 engineering-impact metric**, because the agent under test operates on benchmark fixtures and never on a repository whose cycle time or escaped defects could move. That is written into the gate as a structural limit, not a backlog item |

## Prediction file — round 1

**The prediction file is not edited** (§4 step 12: never edit a prediction after its run). Every
disposition below is recorded in `evidence/p10/RESULT-scrub-scope.md` or in the workbook.

| # | Finding | Recurrence | Disposition |
|---|---|---|---|
| 11 | **`user.email` planted twice without distinct values, so the surviving copy's level is ambiguous** | 1/2 | **DISPUTED on the facts, and the document's gap conceded.** The probe **did** use distinct values — `resource-level-<MARK>@…` and `record-level-<MARK>@…` — so the survivor's level is read off the value itself (`evidence/p10/scrub-probe-sent.json`, and the survivor literally reads `resource-level-…`). The finding is correct that the **prediction document** does not say so. Recorded in the workbook and in `RESULT-scrub-scope.md`; the prediction stands unedited |
| 12 | **P1 / P2 cannot show which level was deleted** | 1/2 ×2 | **Same disposition as #11.** Both rest on the same assumed ambiguity, which the payload removes |
| 13 | **P2 says "four keys" but there are three key names in four placements** | 1/2 | **CONCEDED and fixed everywhere except the prediction.** The workbook and the §5 table now read *"four planted **placements** of three key names"* |
| 14 | **P3: grep cannot show the surviving value came via the `OTEL_RESOURCE_ATTRIBUTES` channel** | 1/2 | **CONCEDED and fixed**, `6e22a9a`. The workbook now labels that sentence *"an inference, not a measurement"*: the probe sent a direct OTLP POST and never set the env var. What is measured is that a **resource attribute** survives; that a mis-set env var is one way to create one is read from the specification |
| 15 | **P3 (second family): the comment's claim is about source-code exfiltration, and the probe plants an email** | 1/2 | **PARTLY CONCEDED.** The comment makes both claims in one sentence — it names prompt/response/tool **bodies** and the processor's delete list includes `user.email` explicitly with its own justifying comment. The probe planted `gen_ai.prompt` and `tool.arguments` as well, and both were deleted **at record level**. So the content half was tested too, and the untested half is content **on a resource attribute** — which no runtime is likely to do. Recorded rather than fixed, because the probe did in fact cover it |
| 16 | **P4/P5: a zero could be ingestion, routing or serialization rather than deletion** | 1/2 ×2 | **DISPUTED with the evidence, and the answer added to the workbook**, `6e22a9a`. **The probe carries its own positive control**: the record *arrived*. `events.jsonl` grew by exactly one line carrying the marker, the body and two of the three resource attributes, so ingestion, routing and file serialization all worked **for that record**. The three missing attributes are missing from a record that arrived — removed by a processor, not lost by the pipeline. This is the single best thing the round produced, because it names what makes the result a measurement |
| 17 | **P1 and P2 duplicate one pass/fail determination** | 1/2 | **DISPUTED as design.** §4 step 3 requires every prediction to carry a direction **and** a magnitude. P1 is the direction, P2 is the magnitude of the same mechanism; registering them as one would drop a registered quantity to avoid a redundancy |

## Round 2

Run on the **final** workbook, after every fix above. Result recorded below at the close.

Run on the **final** workbook after every round-1 fix.
`findings/opencode/review-README-20260929T184041Z.md`, exit 0, 24 705 bytes, 24 029 below line
20 — not a stall. **Verdict REJECT** (read off the `## Acceptance — REJECT` heading; `grep -m1`
hits the YAML `acceptance:` key first and is the wrong instrument for this file).

**Carry-over of round 1's five biggest, asked explicitly:** (a) scrub scope **still raised**,
(b) the §4-step-2/RUN inconsistency **gone**, (c) the L1-vs-L2 clash **still raised, in a sharper
form**, (d) the layer-name collision **still raised, down from 2/2 to 1/2**, (e) the `user.id`
point **still raised, and reframed into a finding I had not seen**.

| # | Finding (section) | Recurrence | Disposition |
|---|---|---|---|
| 18 | **The `user.id` census zero is called "the control working", but the probe never planted `user.id`** | **2/2** | **FIXED — this is a retracted overclaim of mine and the round's best finding**, `06c709d`. The probe planted `user.email`, `gen_ai.prompt` and `tool.arguments`. What it proves is that the processor deletes **record-level attributes it is configured to delete**; that `user.id` is on the same list is read off `config.yaml`, and that it is therefore removed is an **inference from configuration, not an observation**. The note now says so and names the deletion of that key as **unprobed**. One more planted placement would settle it and was not sent. *That I wrote "the probe proves" about a key the probe never touched, in a stop whose whole subject is claims made over the wrong scope, is the finding worth keeping.* |
| 19 | **Runtime-written evidence rated L1/L2 although nothing executes to reject a false claim** (§5 table) — and its twin on the trace row | **2/2, in both rounds** | **CONCEDED AND CONVERTED**, `06c709d`. The panel was right and the label argument was the wrong response. Two senses were being collapsed and the table now separates them: **provenance** (can the cited value be hand-written? no — L1) and **correspondence** (does anything execute to prove *this table* quotes it right?). Correspondence **was L3 and is now L2**: `evidence/p10/verify-lab-numbers.py` holds every number the lab asserts, re-derives each from the trace JSONs and the live `events.jsonl`, and exits 2 on mismatch. **Proved to reject**: `--selftest` corrupts one expectation and it exits 2 with `MISMATCH e488ed2e.tool: workbook says 999, sources give 14`. The prose, the layer labels and the interpretation stay L3 — no script reads them, and the table says so |
| 20 | **`lines_of_code.count` versus `claude_code.lines_of_code.count`** | **2/2, in both rounds** | **Round 1's dispute WITHDRAWN and the finding FIXED**, `06c709d`. I disputed it as "already stated"; it was stated in the second-pass extract and **not** where a reader meets the wrong names. An inline pointer now sits in the first-pass metric block. A correction a reader has to find later is not a correction |
| 21 | **The scrub conclusion still extends past the log-record attributes probed** (§4 step 11) | 1/2 *(down from 2/2)* | **FIXED in the remaining place**, `06c709d` — the checkbox-3 narrowing had been applied to the lab section but the learning block and the exit gate still read wider. Both now name the logs pipeline and say the traces/metrics gap is **expected, not measured** |
| 22 | **The "Three layers" taxonomy collides with the guardrail labels** | 1/2 *(down from 2/2)* | **Already handled in round 1** as a recorded clash rather than a rename, and left there. The author's section is the author's, §6 is one step at a time, and the note states which scale every other "L1/L2/L3" in the file belongs to |
| 23 | **The four-commands block mixes two repo-relative path bases** | 1/2 | **FIXED**, `06c709d`. One base, stated — `cd agent-learning-lab` first, and the collector file reached as `../agent-observatory/...` |
| 24 | **The two Exit gate blocks read as a contradiction — 0 of 5 unticked, 4 of 5 answered** | 1/2 | **FIXED with a pointer**, `06c709d`. Same five questions asked once and answered once; the unedited block is kept so a reader sees what was asked before it was answered, and now says so |
| 25 | **Verified reading: dated checkmarks carry no captured version or digest** | 1/2 | **DISPUTED as out of scope, conceded in substance.** This is `lab#13`'s open question — it is in `author_notes` with its argument, and the §5 table already grades the link check **L2 for "the URLs answer", L3 for "the content is current"** while naming the two pages that are dead for a reader. Capturing a digest per source is an instrument that does not exist and is not this stop's to build |
| 26 | **§4 step 2: the raw-byte term count prints 0 and exits 0, so nothing rejects a missing term** | 1/2 | **DISPUTED as out of scope, conceded in substance, and already on record.** It is boundary 1's finding and its own `author_notes` item says the L2 version is a fixture-proved `tools/` helper and that it is **not built**, §6 |
| 27 | **Extract, second pass: no normalization contract maps Copilot `execute_tool` to Claude `tool.blocked_on_user`** | 1/2 | **DISPUTED.** The workbook's Domain model section says *"do not mirror vendor span names into your database"* and names the normalization boundary; writing the actual mapping is Phase 10's dashboard work, which stop 28 owns. Also: this stop's finding is that `tool.blocked_on_user` **does not mean what its name says**, so mapping it to anything before that is resolved would propagate the defect |
| 28 | **Domain model / Dashboards / Experiment policy / Promotion gate / Cross-cutting: "success rate", "one meaningful variable", "approved tolerance", clause 5's sample threshold all undefined** | 1/2 each | **DISPUTED as out of scope, conceded in substance, and this is the phase's own point.** Every one is the author's first-pass prose, and B13's seven clauses are **L3 prose** — which the workbook and `author_notes` both already state, naming the L2 conversion (a gate script that refuses to publish a comparison below a registered `n`) and its owner (**stop 28**). §6 forbids building a future step's artifacts. The panel is describing the gap this stop documented rather than one it introduced |

**Why the round-2 REJECT is not treated as a failure to close.** §4a step 3 permits stopping
*"when every remaining line-level finding is disputed and the gate's own objection is
answered."* The gate's objection across both rounds was finding 19 — evidence labelled L1 with
nothing executing behind it — and it is answered by a checker that runs and is proved to reject,
not by an argument. Every other remaining finding is either fixed above or disputed in writing
with its reason; none is disputed as "stylistic". A third round was nonetheless run, below,
because two 2/2 findings had just been fixed and the honest test of a fix is the instrument, not
my confidence in it.

## Round 3

ROUND3_PLACEHOLDER
