Review the attached scoring rubric. You are a critic, not an editor.

CONTEXT YOU NEED
The rubric scores backend implementations of one benchmark task, BE-003: add
`POST /shipments/{id}/confirm` to a Kotlin + Spring Boot service. Confirming a CREATED
shipment moves it to CONFIRMED; confirming an already-CONFIRMED one must SUCCEED and change
nothing (a retry must not fail); CANCELLED is refused 409; unknown id is refused 404. No new
dependencies, no changes outside the shipment feature.

A separate deterministic script already decides PASS/FAIL — build, existing tests, a
functional acceptance suite, an error-contract suite, a dependency guard, a changed-file
guard. Those are GATES. This rubric is NOT supposed to re-ask their question. It scores how
well the work was done among submissions that already passed.

The rubric is applied by an LLM that receives ONLY the implementation source files. It
cannot run tests, cannot see a git diff, and cannot read the evaluator's output.

WHAT TO CHECK, per category, in the rubric's own order:

1. DECIDABILITY. Can this anchor be evaluated from source files alone? Anchors that require
   running a test, reading a diff, or knowing an exit code CANNOT be, and are the specific
   defect that motivated this review. Name each one you find.
2. SEPARATION. Give a concrete implementation that two competent reviewers would score
   differently under this anchor. Quote the anchor text that permits the disagreement. If no
   such implementation exists, say "no finding" — that is a valid verdict and you are not
   expected to find fault everywhere.
3. GATE DUPLICATION. Does this category re-decide something the deterministic evaluator
   already decides pass/fail?
4. WEIGHT COHERENCE. The weights are 25/20/15/15/10/10/5. Is any category carrying weight
   disproportionate to how reliably it can be scored?

RULES
- Every finding needs a concrete failure: a specific implementation and the divergent
  outcomes. A finding you cannot attach one to is not a finding.
- Do NOT rewrite the rubric and do NOT supply replacement anchor text. Say what is wrong and
  what it causes. Someone is learning by writing this; handing them the answer destroys that.
- Default to "this is ambiguous" when unsure whether two readers would agree.
- No praise, no summary of the rubric back to me, nothing after the findings.

OUTPUT
Markdown. For each category: name, verdict (finding | no finding), the failure scenario, and
a verbatim quote of the anchor at fault. Then three closing lines: which category two
reviewers would diverge on most and by how much; which anchors are undecidable from source;
what the rubric does not say that it needed to say.
