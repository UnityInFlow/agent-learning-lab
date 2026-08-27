# opencode review — E-001-rubric-null-rate

```yaml
reviewer:        lab-critic
model:           ollama-cloud/deepseek-v4-pro          # registered variable — do not change mid-experiment
opencode:        1.18.21
agent_sha:       5ae27fa4d5e2
reviewed_utc:    20260827T090100Z
runs:            2           # independent sessions; findings unioned below
artifacts:
  - path: experiments/E-001-rubric-null-rate.md
    sha:  c30edb033237
  - path: experiments/E-001-prediction-worksheet.md
    sha:  463d76622273
lab_head:        8aa29db
lab_dirty:       true
```

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| Predictions | 2/2 | L3 |
| Runs | 2/2 | L3 |
| Minimum detectable effect | 2/2 | L3 |
| Decision rule | 2/2 | L3 |
| The grid — 24 cells | 1/2 | L3 |
| Two decisions that move whole rows before you count | 1/2 | L2 |
| Independent variable | 1/2 | L3 |
| How the treatment is delivered — and proved | 1/2 | L3 |


---

## Run 1 of 2


> lab-critic · deepseek-v4-pro

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The question cleanly separates the two failure modes (undecidable vs constant) and names them as distinct. This is the strongest part of the record.

### Hypothesis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty TODO, but the status block already declares the experiment blocked on it. Not a hidden defect — it is the stated reason the run is blocked.

### Evidence already on file
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The three "constrain the answer" bullets (change-focus has no diff, test-quality has no tests, labels still in fixtures) are the correct pre-prediction reasoning. The `change-focus` and `test-quality` bullets are what the worksheet later operationalizes.

### Predictions
**Verdict:** finding
**Failure:** The three numbered predictions are empty TODOs, and the record's own status block says "Predictions below are empty. Do not run." But the worksheet (`E-001-prediction-worksheet.md`) is simultaneously deriving those numbers against the **current** fixture set, which the record itself flags as contaminated and not-to-be-run-against. Two reviewers: one fills the grid now against fixtures whose KDoc blocks state the answer, the other waits for benchmarks#20 to land and fills it against the cleaned fixtures. They produce different null-rate and discrimination predictions, because decidability of each cell depends on what the scorer can read. The prediction is being derived against a moving target while the record claims it is blocked.
**Layer of the implied fix:** L3
**Anchor:** "Do not run against the current fixtures at all"

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

"One thing" — each fixture differs on exactly one dimension — is the correct isolation claim, and it is what makes an observed gap attributable.

### How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The "Preflight assertion" row correctly classifies the agent definition as L3 and the script guard as L2. That is the layer model applied correctly, not flattered.

### Controlled variables
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Two items unchecked (`rubric sha`, `blind scores recorded`) are acknowledged as pending, consistent with the blocked status.

### Runs
**Verdict:** finding
**Failure:** "Repetitions per fixture: ____ · Total: ____" is blank, with a TODO asking whether one run per fixture is enough. The record's own evidence (critic disagreed with itself 2/12 at temperature 0) establishes that a single run is a lower bound, not a value. With no registered repetition count, two reviewers run different sample sizes — one does 1× per fixture (6 runs), another 3× (18 runs) — and the null rate and discrimination results are not comparable across them. The MDE and decision rule both depend on a sample size that is unregistered.
**Layer of the implied fix:** L3
**Anchor:** "Repetitions per fixture: ____ · Total: ____"

### Minimum detectable effect
**Verdict:** finding
**Failure:** The MDE table is empty, and the TODO explicitly defers the one number the decision rule needs: "decide what gap you would call a real difference rather than noise." The decision rule (once filled) says "each fixture scores below known-good on its own dimension," but "below" has no registered magnitude. Two reviewers: one treats a 1-point gap on a 0–2 scale as a real difference, another treats it as noise. They reach opposite KEEP/REJECT verdicts on the same observed data. Separately, the secondary outcome names "20 cells" while the Predictions section names "24 cells" — the null-rate denominator is contradicted within the same document.
**Layer of the implied fix:** L3
**Anchor:** "secondary: null rate across the 20 cells"

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Correctly states there is no deterministic evaluator by design, and why. This is the honest framing the experiment needs.

### Exclusions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Registered exclusions are reasonable. Note only: the "cites a file not in the attachment set" exclusion is defined against the fixture-only attachment set, but decision B in the worksheet later adds `known-good` as a baseline — the definition of "the attachment set" is now ambiguous (fixture-only vs fixture+baseline). Minor, folded into the baseline finding below.

### Decision rule
**Verdict:** finding
**Failure:** The decision rule is an empty TODO with a "suggested shape, not an answer." The entire experiment contract is "registered before data," and the decision rule is the thing that converts results into a verdict. With it empty, two reviewers apply different thresholds to the same observed null rate and score gap. The suggested shape itself contains the divergence: "INCONCLUSIVE if nulls are concentrated in one category" — but "concentrated" is undefined, and the worksheet's decision A already guarantees 4 of 24 nulls are concentrated in `test-quality`. One reviewer reads that as INCONCLUSIVE (a category defect), another reads it as expected and proceeds to KEEP/REJECT. The rule that would settle this is not registered.
**Layer of the implied fix:** L3
**Anchor:** "Registered before data. What result produces KEEP / REJECT / INCONCLUSIVE?"

### The procedure, from #21
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The four-step procedure (critique rubric, blind self-score, run scorer, compare) is sound and the blind step is correctly placed before any scorer output.

### Observed telemetry
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder, filled post-run.

### Results
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder. The "median and p25/p75, never an average alone" instruction is correct for a non-deterministic instrument.

### Which predictions held
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder.

### Failure analysis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder.

### Sanity checks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder. The three checks (dramatic number explained, flattering number disbelieved twice, suspicious agreement) are the right ones for this instrument.

### Decision
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder.

### Follow-up
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty placeholder.

---

### The question for every cell
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The per-cell decidability question ("can I cite `path:line` for the answer?") is the correct test, and it matches the lab's own anchor test.

### What each fixture actually hands the scorer
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The fixture table is accurate and is the load-bearing input to the grid.

### The grid — 24 cells
**Verdict:** finding
**Failure:** The grid marks the four no-test `test-quality` cells as "**N** — no test file" and the `known-good` `change-focus` cell as "*degenerate — see note*". The note then leaves the degenerate cell unresolved: "Decide whether that cell is a 2, omitted, or `known-good` is scored without a baseline. It is one cell, but it changes the denominator." The main record commits to 24 cells ("known-good is the reference... so it is scored too"), but decision B (attach `known-good` as baseline) makes `known-good`'s `change-focus` "trivially 2" — scoring it against itself. Two reviewers: one counts 24 cells with that cell a constant 2 (carrying no information), another omits it (23 cells) or scores `known-good` without a baseline. The null-rate denominator and the "constant category" check both depend on this unresolved cell.
**Layer of the implied fix:** L3
**Anchor:** "It is one cell, but it changes the denominator."

### Two decisions that move whole rows before you count
**Verdict:** finding
**Failure:** Decision A asserts the `test-quality` precondition produces a *guaranteed* null: "the scorer emits `null`, not `0`" and "4 of 24 cells are guaranteed nulls." But the precondition is a YAML note read by an LLM scorer. Nothing executes to reject a non-null score. A scorer can emit `0` on a no-test fixture (asserting "the tests are bad") and nothing stops it — the worksheet's own wording ("the honest value is `null`", "it should") is the tell that this is guidance, not enforcement. Two runs on the same no-test fixture can produce `null` vs `0`, and the null-rate prediction that counts these four cells as "guaranteed nulls" is then wrong. The "guaranteed" is a prediction about LLM behavior dressed up as a control.
**Layer of the implied fix:** L2
**Anchor:** "the scorer emits `null`, not `0`"

### Prediction 2 — discrimination
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The four pair/dimension rows are the right discrimination questions, and the "which category will be constant across all six" question is the correct one to foreground, since constant is the failure that hid behind undecidable last time.

### Prediction 3 — agreement with your blind scores
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Correctly flags that the scorer's bias (under-report vs over-report) is a separate question from the critic's, and that this is where it gets caught.

### The mechanism
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty, but the instruction ("a hypothesis without a mechanism cannot be interestingly wrong") is the right one. The mechanisms are, however, absent — which is the same unregistered state as the Predictions section.

---

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `test-quality`'s score-2 anchor — "calls confirm twice and compares; asserts the error envelope; re-reads the shipment" — reads like it could be exactly what `evaluator.sh` checks for the gate. If a gate already requires "confirm called twice and the envelope asserted," then every gate-passing fixture scores 2 on `test-quality` and the category is constant across the population — the exact failure the experiment exists to detect, reintroduced through an anchor that restates a gate. The record dropped `functional-correctness` and `requirement-completeness` for this reason but did not check whether `test-quality`'s top anchor smuggled a gate back in.
- **Which single section would two reviewers diverge on most, and by how much?** The null-rate denominator. The document says "24 cells" in Predictions and "20 cells" in the MDE table, and the worksheet's degenerate-cell note says the denominator is unresolved. Two reviewers computing the null rate get 20, 23, or 24 as the denominator — a spread of up to 4 cells, which on a 24-cell grid is a ~17% swing in the headline number before any scoring happens.
- **What did the artifact not say that it needed to say?** It never registered the repetition count, the MDE magnitude, or the decision-rule thresholds — the three numbers that turn results into a verdict. It also never stated whether the `test-quality` precondition is enforced or merely guidance, while asserting the resulting nulls are "guaranteed." And it left the `known-good` `change-focus` cell (scored against itself once the baseline is attached) unresolved, which changes the denominator the whole experiment is read against.

---

## Run 2 of 2


> lab-critic · deepseek-v4-pro

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The two failure modes (undecidable vs constant) are cleanly separated and each is given a distinct observable signature. Nothing here is ambiguous.

### Hypothesis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design — the status block at the top flags it as the blocker. The "Evidence already on file" table is the strongest part of the document and correctly distinguishes recorded observation from forecast.

### Predictions
**Verdict:** finding
**Failure:** Prediction 1 fixes the denominator at "4 categories × 6 fixtures = 24 cells," but the worksheet (`E-001-prediction-worksheet.md`, lines 49–51) explicitly leaves the `known-good` × `change-focus` cell undecided — "a 2, omitted, or `known-good` is scored without a baseline" — and warns "it changes the denominator." Two reviewers computing the null rate from the same results will produce different numbers: one counts 24 cells, another 23 (omitting the degenerate cell), a third counts 24 but scores the degenerate cell as a tautological 2. The null-rate prediction is therefore not a single falsifiable number; it is three numbers depending on an unresolved decision.
**Layer of the implied fix:** L3
**Anchor:** "Of the 4 categories × 6 fixtures = **24 cells**, how many come back `null`?"

### Independent variable
**Verdict:** finding
**Failure:** The section asserts "Each of the five fixtures differs from `known-good` on exactly one dimension." The worksheet's own fixture table (lines 25–32) confirms this for four fixtures but does not state whether `good-strong-tests`' production code is character-identical to `known-good` — it only describes the test differences ("tests call confirm twice, assert the envelope, re-read the shipment"). If `good-strong-tests` also changes production code, it differs on two dimensions and the "one candidate cause" property that the whole experiment leans on (line 91) is false for that fixture. Two reviewers cannot resolve this from the artifact; one has to go read the fixture.
**Layer of the implied fix:** L3
**Anchor:** "Each of the five fixtures differs from `known-good` on exactly one dimension, which is the property benchmarks#10 was built to provide"

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The mechanism row lists "the rubric and the changed source files attached," but worksheet decision B (lines 80–89) mandates that `opencode-score.sh` also attach the `known-good` tree as a baseline so `change-focus` has a diff to score. A reviewer following this document runs without the baseline; `change-focus` has no diff and nulls; the result contradicts prediction 2, which assumes the baseline is present. The two documents describe different attachment sets, and the experiment record does not reflect its own worksheet's decision.
**Layer of the implied fix:** L3
**Anchor:** "`opencode run --agent lab-scorer -m <model>` with the rubric and the changed source files attached"

### Controlled variables
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The two unchecked items (rubric sha, blind scores) are consistent with the "blocked and unregistered" status and are explicitly marked pending. The model-pin note correctly identifies `LAB_REVIEW_MODEL` as an override risk.

### Runs
**Verdict:** finding
**Failure:** Repetitions are blank, and the TODO ("decide whether one run per fixture is enough") is unresolved. The document's own evidence (line 42, restated at line 125) establishes that a single temperature-0 run under-reports — the critic flipped 2 of 12 section-runs, both flips real. With no repetition count registered, a single run per fixture is a lower bound, and two reviewers will disagree on whether the observed scores are trustworthy: one treats a single run as the value, the other treats it as a floor. The experiment's central claim (does the rubric discriminate?) is unmeasurable at n=1, and the artifact says so without resolving it.
**Layer of the implied fix:** L3
**Anchor:** "Repetitions per fixture: ____ · Total: ____"

### Minimum detectable effect
**Verdict:** finding
**Failure:** The MDE table is empty. The decision rule (line 163) is declared "Registered before data," but the score-gap threshold it depends on is undefined. The TODO (line 136) explains the arithmetic ("one category moving by 1 point moves the normalised total by a fixed amount") but never fills the number. Two reviewers reading the same observed gap will disagree on whether it is a real difference or noise, because the threshold that would settle it was never registered.
**Layer of the implied fix:** L3
**Anchor:** "primary: score gap between a fixture and `known-good` on its own dimension | | |"

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The "no deterministic evaluator, by design" framing is correct and is the point of the experiment.

### Exclusions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The three exclusions are registered before data and are coherent. The "evidence cites a file not in the attachment set" exclusion remains valid under decision B, since the baseline files are now legitimately in the set.

### Decision rule
**Verdict:** finding
**Failure:** The INCONCLUSIVE branch fires on "nulls concentrated in one category." Worksheet decision A (lines 60–78) guarantees exactly that: 4 of 24 cells are nulls, all concentrated in `test-quality`, by design — absence of a test file is a precondition, not an anchor defect. After any run, a reviewer applying the rule literally flags `test-quality` as a defective category, while a reviewer who knows decision A reads the same nulls as by-design. The rule cannot distinguish "designed nulls" from "broken anchors," so the experiment's own decision procedure will always produce INCONCLUSIVE for `test-quality` regardless of whether its anchors are good.
**Layer of the implied fix:** L3
**Anchor:** "INCONCLUSIVE if nulls are concentrated in one category — that is a defect in that category's anchors, not a verdict on the rubric"

### The procedure, from #21
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The four-step procedure is sound and the blind-scoring step is correctly placed before any scorer output.

### Observed telemetry
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section, nothing to review while the experiment is blocked.

### Results
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section.

### Which predictions held
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section.

### Failure analysis
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section.

### Sanity checks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The three checks are pre-registered and the "disbelieve flattering numbers twice" check is the right instinct for this instrument.

### Decision
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section.

### Follow-up
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section.

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** Not directly — `functional-correctness` and `requirement-completeness` were already dropped and the gates own them. But `test-quality`'s precondition ("no test file → null") is a gate-shaped check sitting inside a scoring category: it nulls 4 of 6 gate-passing fixtures, leaving 25% of the weight resting on a single pair (`good-strong-tests` vs `good-weak-tests`). That is not a gate duplication, but it is a weight-concentration defect the decision rule is structurally unable to flag (see the Decision rule finding).
- **Which single section would two reviewers diverge on most, and by how much?** The Decision rule, by a full verdict — one reviewer flags `test-quality` as a defective category (applying the INCONCLUSIVE branch literally), the other reads the same nulls as by-design (knowing decision A). The divergence is binary, not a matter of degree, because the rule's trigger condition is guaranteed to fire.
- **What did the artifact not say that it needed to say?** Four things: (1) the repetition count, which its own evidence says is load-bearing; (2) the MDE numbers, without which the decision rule's threshold is undefined; (3) the resolution of the degenerate `known-good` × `change-focus` cell, which changes the null-rate denominator; and (4) whether `good-strong-tests`' production code is character-identical to `known-good`, which the "one dimension" claim depends on and the worksheet never states.
