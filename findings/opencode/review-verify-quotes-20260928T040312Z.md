# opencode review — verify-quotes

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260928T040312Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p08/verify-quotes.sh
    sha:  f2731486a4c4
    dirty: false
lab_head:        f7b1e42
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/p08/verify-quotes.sh
  verdict: REJECT
  summary: The HTML-to-text extraction step has no failure guard — a Python wrapper that exits non-zero or raises UnicodeDecodeError on a non-UTF-8 byte leaves empty .txt files and the script proceeds to exit 2 ("drift"), violating the documented exit code 3 reserved for "nothing was proved either way."
  blocking:
    - reason: strip() has no exit-status check; a Python wrapper crash, missing module, or decode error leaves the per-page .txt file empty and the loop continues without flagging the failure
      wrong_action: A reader running the script would see exit 2 and conclude "this sentence is no longer in its cited page" — and re-extract or open a drift ticket — when in fact nothing was verified for that page
      anchor: "strip < \"$TMP/$key.html\" > \"$TMP/$key.txt\""
      evidence: evidence/p08/verify-quotes.sh:122
    - reason: The script's documented contract reserves exit 3 for "a page could not be fetched (nothing was proved either way)" but the strip failure path is wired to exit 2 ("at least one quote was not found"), so a processing failure is indistinguishable from a genuine absence
      wrong_action: A consumer of the script that uses the exit code to choose between "proved drift" (2) and "no verdict" (3) would mis-classify a strip-side failure as documentation drift
      anchor: "3  a page could not be fetched (nothing was proved either way)"
      evidence: evidence/p08/verify-quotes.sh:14-16
  non_blocking:
    - reason: The REGISTERED LIMITATION block enumerates the chrome-matching scope but does not list the silent-strip-failure mode; once the guard is fixed, that paragraph should be extended so readers do not infer a stronger claim than the script actually supports evidence: evidence/p08/verify-quotes.sh:18-26
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 953s |
| codex | ok | 28s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| evidence/p08/verify-quotes.sh | 1/1 | L2 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 2 — codex

### evidence/p08/verify-quotes.sh
**Verdict:** finding
**Failure:** Specific input: run the script with `python3` present on PATH but terminating non-zero, such as a wrapper that exits 1. Each `strip < "$TMP/$key.html" > "$TMP/$key.txt"` invocation fails, but `set -uo pipefail` does not stop execution because `-e` is absent and the return status is never checked. The matcher then reads empty text files, reports every quotation `ABSENT`, and exits 2, falsely classifying an internal processing failure as documentation drift. One reviewer can treat exit 2 as proven quote absence; another, noticing the Python failures on stderr, can conclude nothing was proved.
**Layer of the implied fix:** L2
**Anchor:** strip < "$TMP/$key.html" > "$TMP/$key.txt"

### Cross-cutting
**Verdict:** no finding
**Failure:** No scoring category or pass/fail gate is defined, so none can duplicate another. Reviewers are most likely to diverge on `REGISTERED LIMITATION`: one may accept page-wide matching while another rejects chrome-only matches; the divergence is one binary verdict, FOUND versus unsupported. The artifact needed to state or enforce how a `strip` execution failure is classified; currently only fetch, empty-page, usage, and quote-absence outcomes are defined.
**Layer of the implied fix:** n/a
**Anchor:** n/a


---

## Run 2 of 2 — codex

### evidence/p08/verify-quotes.sh
**Verdict:** finding
**Failure:** A fetched or cached page contains a non-UTF-8 byte, so Python raises UnicodeDecodeError in strip. Because the script does not check strip's exit status, it continues with an empty or partial .txt file, reports the page's quotations as ABSENT, and exits 2 for documentation drift. One reviewer therefore treats the result as a disproved quotation, while another recognizes that processing failed and nothing was proved—the condition assigned exit 3 by the script's own contract.
**Layer of the implied fix:** L2
**Anchor:** strip < "$TMP/$key.html" > "$TMP/$key.txt"

### Cross-cutting
**Verdict:** finding
**Failure:** There are no scoring categories or pass/fail gates to compare. Reviewers would diverge most on the exit-code contract: for the non-UTF-8 page above, the implementation returns 2 while the documented meaning of exit 3 implies that a page-processing failure proves nothing; the divergence is one full verdict class. The artifact needed to state and enforce how HTML decoding or normalization failures are classified.
**Layer of the implied fix:** L2
**Anchor:** 3  a page could not be fetched (nothing was proved either way)

