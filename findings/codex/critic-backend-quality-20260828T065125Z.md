### architecture-consistency
**Verdict:** finding
**Failure:** A submission uses `check(shipment.status == ShipmentStatus.PENDING)` before the success response, so an invalid state throws `IllegalStateException`, while its explicit missing-shipment branch throws the baseline `ResourceNotFoundException`. One reviewer can treat the `check` failure as a “state refusal” and score 1; another can reserve “refusal” for explicit controller response branches and score 2. The rubric never defines which thrown failures count as refusals.
**Layer of the implied fix:** L3
**Anchor:** “Every refusal throws an `ApiException` subclass that ALREADY EXISTS IN THE ATTACHED BASELINE”

### maintainability
**Verdict:** no finding
**Failure:** The precedence rule resolves unmatched constructs to 1, and the 0 and 2 conditions are distinguishable from the attached source plus the stated gate-passing precondition. No concrete passing submission was found for which the written conditions yield different scores.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### test-quality
**Verdict:** no finding
**Failure:** The precondition, ordered 0/2/residual rule, and three conjunctive score-2 clauses determine the result for concrete test files, including zero-assertion and status-only cases. No concrete test attachment was found for which two scores satisfy the written rule.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### change-focus
**Verdict:** finding
**Failure:** The baseline explicitly imports `ConflictException`; the submission replaces that line with `import com.unityinflow.sample.api.*`, and only `confirm` uses a symbol supplied by that package. One reviewer can call the wildcard an import `confirm` requires and score 2 because all unnamed methods remain identical. Another can treat the wildcard as an out-of-scope import change exposing unrelated names and score 1. “Imports it requires” does not decide whether necessity is evaluated per import declaration or per imported symbol.
**Layer of the implied fix:** L3
**Anchor:** “Only `confirm`, and the imports it requires, differ.”

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates a stated pass/fail gate: maintainability rewards future exhaustiveness, while the compilation gate only establishes that the current submission compiles. The largest expected reviewer divergence is `change-focus`, by 1 point on its 0–2 scale (7.5 points in the normalized total when all categories score), using the wildcard-import diff above. The artifact needed to define what constitutes a refusal and what makes an import required; without those boundaries, architecture-consistency and change-focus admit the concrete divergent scores reported above.
**Layer of the implied fix:** L3
**Anchor:** “Every refusal throws” / “the imports it requires”

