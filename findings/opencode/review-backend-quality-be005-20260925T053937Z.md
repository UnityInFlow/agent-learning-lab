# opencode review — backend-quality-be005

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
reviewed_utc:    20260925T053937Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: benchmark/rubrics/backend-quality-be005.yaml
    sha:  945817b8c509
    dirty: false
lab_head:        f65c4e5
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: benchmark/rubrics/backend-quality-be005.yaml
  verdict: REJECT
  summary: The PORT NOTE (line 64-65) declares "Every anchor below is decidable from those files alone", but change-focus anchor 2 permits "the `OrderControllerTest` update part 2 asks for" — part 2 is defined in task.md, which the same header says the scorer does not receive. A faithful scorer who trusts the header cannot evaluate the most permissive clause in change-focus's anchor 2, and will either guess or refuse.
  blocking:
    - reason: Change-focus anchor 2's permitted-differences list includes "the `OrderControllerTest` update part 2 asks for", but the header restricts the scorer to changed files + pre-agent versions only and does not name task.md as a source the scorer should consult. The rubric is internally inconsistent on what the scorer can read.
      wrong_action: A scorer reads the header, trusts that anchors are self-contained, encounters a test-file diff, cannot tell whether it is the part-2 update or a gratuitous change, and either guesses at what part 2 asks for (scoring wrong in both directions) or refuses to apply the anchor (collapsing anchor 2 to anchor 1 for any submission with an OrderControllerTest change).
      anchor: "the `OrderControllerTest` update part 2 asks for."
      evidence: benchmark/rubrics/backend-quality-be005.yaml:133
    - reason: The header claim that every anchor is decidable from changed files + pre-agent versions is falsified by the part-2 reference. This is the same defect class that killed v1 (anchors citing inputs the scorer cannot see), and the file's own STATUS paragraph claims it does not regress on that axis.
      wrong_action: A reviewer reading the STATUS block (lines 11-19) trusts that the port has not reintroduced the v1 defect, then the scorer hits the part-2 reference and finds they cannot verify it without task.md. The next reader will not check; they will assume the header is correct.
      anchor: "Every anchor below is decidable from those files alone."
      evidence: benchmark/rubrics/backend-quality-be005.yaml:64-65
  non_blocking:
    - reason: Architecture-consistency anchor 0 (ii) tail clause and the residual's third case disagree about whether storing+deriving is bad. Anchor 0 (ii) fires "when the order's read path ... returns the stored value"; the residual fires when "the ORDER package alone writes and the read path derives anyway". A submission that stores, is written from the shipment package, and is derived at read time falls through both — neither anchor 0 nor the residual's named case classifies it. L3 gap the proof should surface.
      evidence: benchmark/rubrics/backend-quality-be005.yaml:87-89
    - reason: Maintainability anchor 0 says "`if`/`else` ladder nested THREE or more deep"; anchor 2(a) blesses "one `if`/`else if` chain of depth one". The rubric uses both without defining whether `else if` contributes nesting depth. A flat four-branch `else if` ladder could score 0 under anchor 0 (syntactic nesting) and 2 under anchor 2(a) (flat chain) — a full two-point divergence. L3 ambiguity.
      evidence: benchmark/rubrics/backend-quality-be005.yaml:101,103
    - reason: Architecture-consistency anchor 2(i) says "every refusal in the order, shipment AND customer packages throws an `ApiException` subclass". A framework-generated 400 (e.g., Spring `@Min(1)` on a request field) is a refusal the package's submission produces but no application code throws. The anchor does not say whether framework-generated refusals count. L3 ambiguity.
      evidence: benchmark/rubrics/backend-quality-be005.yaml:89
    - reason: Test-quality anchor 1 is labelled "THE RESIDUAL" but is given a positive definition ("Any assertion reads a body or a header, and at least one clause of 2 is absent"). A test that calls `jsonPath(...)` but only asserts a status code does not satisfy "any assertion reads a body" (the call reads, the assertion does not), so anchor 1's positive definition does not fire — yet anchor 0 also does not fire (it requires "none reads a response body"). Such a test falls into a gap. L3 ambiguity in the residual's definition.
      evidence: benchmark/rubrics/backend-quality-be005.yaml:116-117
    - reason: Test-quality anchor 2 clause (e) is predicted unreachable by the PORT NOTE itself ("no fixture's tests call the amendment endpoint, so anchor 2 is predicted unreached"). The unreachability is acknowledged in the artifact and raised in `author_notes` as a recommended eighth fixture. Acknowledged gap, not hidden.
      evidence: benchmark/rubrics/backend-quality-be005.yaml:50-62
    - reason: Change-focus anchor 2 ends "the imports those require BY SYMBOL" — does not define whether an alphabetical reordering of untouched imports, performed by a formatter triggered by adding a required import, is a difference. L3 ambiguity.
      evidence: benchmark/rubrics/backend-quality-be005.yaml:133
  disputed:
    - finding: "the rubric only scores gate-passing submissions, so any anchor restating a gate is a constant across everything it can score" — the line-level reviewer frames test-quality as effectively `null`/0/1 because no fixture reaches anchor 2 clause (e).
      why: This is a sheet-mechanics observation, not a defect in the rubric file. The rubric itself acknowledges the unreachability in the PORT NOTE and records it as a known cost of addition 2. The author's commitment is to surface it via the proof rather than fix it by editing fixtures (which would be the wrong fix per §6).
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 41s |
| ollama-cloud/deepseek-v4-pro | ok | 170s |

Stall budget: 1200s per family (LAB_REVIEW_TIMEOUT).

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
| architecture-consistency | 2/2 | L3 |
| maintainability | 2/2 | L3 |
| test-quality | 2/2 | L3 |
| change-focus | 2/2 | L3 |
| Cross-cutting | 1/2 | L3 |

> **1 of 5 rows were raised by one family only.** Recurrence is counted per HEADING
> TEXT: two families describing one defect under different headings appear as two rows
> of 1/2. Read the solo rows against each other before treating them as separate.


---

## Run 1 of 2 — codex

### architecture-consistency
**Verdict:** finding
**Failure:** A submission adds `@Min(1)` to the quantity request field, so Spring rejects `quantity: 0` before the controller runs, while every explicit controller refusal throws an `ApiException` subclass and all fulfilment logic satisfies clause (ii). One reviewer treats the framework-generated 400 as a “refusal” that violates anchor 2 because no `ApiException` is thrown; another limits “every refusal in the ... packages” to explicit application paths and awards 2. The rubric does not specify how framework-generated validation refusals are classified.
**Layer of the implied fix:** L3
**Anchor:** “every refusal in the order, shipment AND customer packages throws an `ApiException` subclass”

### maintainability
**Verdict:** finding
**Failure:** Consider `if (delivered == quantity) ... else if (allocated == quantity) ... else if (allocated > 0) ... else ...`, with clauses (b) and (c) otherwise satisfied. A reviewer counting AST nesting sees the final branch three levels deep and assigns 0; a reviewer treating an `else if` ladder as one chain of depth one assigns 2. “Nested THREE or more deep” and “chain of depth one” do not define whether `else if` contributes nesting depth, allowing a two-point divergence.
**Layer of the implied fix:** L3
**Anchor:** “the fulfilment-status decision is an `if`/`else` ladder nested THREE or more deep” / “one `if`/`else if` chain of depth one”

### test-quality
**Verdict:** finding
**Failure:** A test amends quantity from 10 to 20, performs a separate `GET /orders/{orderId}`, and asserts only that the returned quantity is 20; it never asserts fulfilment status or any derived allocation result. One reviewer accepts this because clause (e) expressly permits asserting “the quantity it is computed against”; another rejects it because the assertion proves persistence of quantity but not that fulfilment was recomputed. With clauses (a)–(d) present, the same suite scores 2 or 1.
**Layer of the implied fix:** L3
**Anchor:** “its `status` or the quantity it is computed against is asserted to have moved”

### change-focus
**Verdict:** finding
**Failure:** A submission adds a required `ValidationException` import and the formatter alphabetically reorders two untouched existing imports in the same import block; all executable changes are ticket-required. One reviewer treats the reordered lines as part of the permitted imports “BY SYMBOL” and assigns 2. Another treats the order change as “a reordered import no clause needs” and assigns 1. The rubric does not define whether normalization ignores ordering introduced while adding a required import.
**Layer of the implied fix:** L3
**Anchor:** “the imports those require BY SYMBOL” / “a reordered import no clause needs”

### Cross-cutting
**Verdict:** finding
**Failure:** No duplicated pass/fail gate can be named from the complete evidence set because the gates themselves are not included; the rubric only says the fixtures are gate-passing. The greatest expected reviewer divergence is in `maintainability`: the concrete `else if` chain above can receive 0 or 2, a two-point difference on the three-point scale. The artifact needed to define how Kotlin `else if` chains are counted for nesting depth, how framework-generated refusals are classified, whether a quantity-only read-back satisfies amendment coverage, and whether required import edits normalize import ordering.
**Layer of the implied fix:** L3
**Anchor:** “It may NOT be used to score a run until it has been proved on BE-005's SEVEN gate-passing fixtures”


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### architecture-consistency
**Verdict:** finding
**Failure:** A submission where `Order` carries a stored `allocatedCount`; shipment `create`/`deliver`/`cancel` each call `orders.save(...)` to update it; but `GET /orders/{id}` recomputes `allocated` from `shipmentRepository.findByOrderId(orderId)` and never reads the stored field. Reviewer A reads anchor 0 (ii) ("a method in the SHIPMENT package writes it … on a create, confirm, deliver or cancel path") as satisfied → score 0. Reviewer B reads the anchor's tail clause — "Storing and ALSO deriving is (ii) **when** the order's read path returns the stored value" — and concludes that because the read path *derives* rather than returns the stored value, the condition is not met → residual → score 1. The residual itself muddies this further, because its third case ("the ORDER package alone writes and the read path derives anyway") treats "derives anyway" as a *bad* state, while the anchor 0 tail treats "read path returns stored" as the trigger for bad. The two clauses point opposite ways on the same stored+derived fact.
**Layer of the implied fix:** L3
**Anchor:** "Storing and ALSO deriving is (ii) when the order's read path (`GET /orders/{id}` or the list) returns the stored value."

### maintainability
**Verdict:** finding
**Failure:** A submission expresses the four-way status decision as a flat four-branch `if` / `else if` / `else if` / `else` ladder. Reviewer A reads anchor 0's "`if`/`else` ladder nested THREE or more deep" and counts the `else if` nesting syntactically — a 4-branch ladder is 4 levels deep → score 0. Reviewer B reads anchor 2 (a)'s "one `if`/`else if` chain of depth one" as blessing exactly this flat chain → score 2. The anchor 0 trigger and the anchor 2 exemption use two incompatible notions of "nesting depth" (AST nesting vs. flat chain), and neither anchor defines which one counts, so the same code lands a full two scores apart.
**Layer of the implied fix:** L3
**Anchor:** "the fulfilment-status decision is an `if`/`else` ladder nested THREE or more deep"

### test-quality
**Verdict:** finding
**Failure:** A test file uses `jsonPath(response, "$.status")` to read a response body but asserts only `status().isOk` (a status code). Anchor 0 defines its condition as "Every assertion is a status code: **none reads a response body** or a header" — the colon makes "none reads a body" a gloss on "assertion is a status code", but they are not equivalent: this test *reads* a body while *asserting* a status code. Anchor 1's positive definition — "Any assertion **reads a body** or a header" — also fails, because the assertion itself reads no body. The test satisfies neither anchor's stated condition; only anchor 1's residual role catches it. Two reviewers split: one reads "all assertions are status codes → 0", the other reads "a test read a body → not anchor 0 → residual → 1". (The shipped `good-weak-tests` fixture avoids this because its `jsonPath` import is never used, but any gate-passing submission that reads without asserting hits the gap.)
**Layer of the implied fix:** L3
**Anchor:** "Every assertion is a status code: none reads a response body or a header, none re-reads state through a second request."

### change-focus
**Verdict:** finding
**Failure:** Anchor 2's permitted-differences list ends with "the `OrderControllerTest` update part 2 asks for." The header states the scorer receives "the changed files in full plus their pre-agent versions … and nothing else" — task.md (which defines part 2) is not among the attachments, and no comment in this file restates what part 2 asks for. A scorer therefore cannot distinguish a permitted part-2 test update from a gratuitous `OrderControllerTest` change: agent adds a test for the amendment endpoint that part 2 did not require. Reviewer A assumes any `OrderControllerTest` change is "the update part 2 asks for" → anchor 2. Reviewer B knows part 2 is narrower and scores the extra test as an unrequired difference → anchor 0/1. This is the same defect class that killed v1 (anchors citing inputs the scorer cannot see).
**Layer of the implied fix:** L3
**Anchor:** "and the `OrderControllerTest` update part 2 asks for."

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. All four categories (architecture-consistency, maintainability, test-quality, change-focus) are quality dimensions; none restates a gate. The v2 history already dropped functional-correctness and requirement-completeness for exactly that reason, and this port carries none of it back.
- Which single section would two reviewers diverge on most? `test-quality`, by a full point in both directions: it has the reads-without-asserting gap (anchor 0 vs 1), *and* its anchor 2 clause (e) is predicted unreachable — the PORT NOTE itself concedes no fixture's tests call `PUT /orders/{orderId}/quantity`, so `good-strong-tests` lands at 1, not 2, and no cell ever reaches anchor 2. That collapses test-quality's effective scale to `null`/0/1 while the rubric still advertises a reachable 2 and still charges 25 points against it. The self-flagging is honest, but it means the E-011 proof method (the varying variant "scores strictly below every other cell in that column") can only ever demonstrate the 0/1 separation, never the 1/2 one it claims exists.
- What did the artifact not say that it needed to say? (a) It never tells the scorer what part 2 asks for, while change-focus anchor 2 permits "the update part 2 asks for" — the single most load-bearing unanchored reference in the file. (b) It never resolves the stored-vs-derived boundary in architecture-consistency, where anchor 0's tail clause and the residual's third case disagree on whether "derives anyway" is bad. (c) It does not define "nesting depth" for maintainability, despite using both "nested THREE deep" (bad) and "chain of depth one" (good) as opposing thresholds.

Note: `version`, `task`, and `scale` were reviewed and carry no finding — `version: 2-be005` and `task: BE-005-partial-fulfilment` are self-consistent, and `scale: [0, 1, 2]` correctly omits `null`, which the preconditions supply through a separate mechanism (consistent with the established v2/BE-004 design).
