# opencode review — verify-quote-checker

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/glm-5.2          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260929T120325Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: tools/verify-quote-checker.sh
    sha:  e862fc62ee87
    dirty: false
lab_head:        0fdf96c
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: tools/verify-quote-checker.sh
  verdict: REJECT
  summary: Three test cases carry defects that fire on macOS — the platform this lab runs on. Cases K, L, and M determinately fail for harness-side reasons on this machine, and Case I's server-startup race means the test may pass without ever exercising the 404-with-body path it claims to prove. A reader cannot distinguish those outcomes from real checker defects.
  blocking:
    - reason: "Case K constructs the typo fixture with `sed 's/^quote\\tp1\\t/quote\\tp2\\t/'` using `\\t` as a regex tab. BSD sed (macOS default) treats it as the literal four characters `\\t`, the substitution never matches the tab-separated manifest line, `$TMP/typo.tsv` is byte-identical to `$GOOD`, and the checker exits 0 — not 4."
      wrong_action: "A reader on this machine sees `FAIL K undeclared page key expected 4, got 0`, concludes the checker wrongly accepts undeclared page keys, and debugs the wrong component."
      anchor: "sed 's/^quote\\tp1\\t/quote\\tp2\\t/' \"$GOOD\" > \"$TMP/typo.tsv\""
      evidence: tools/verify-quote-checker.sh:120
    - reason: "Cases L and M match the checker's output with `grep -q \"STRIP FAILED\\|STRIP PRODUCED NO TEXT\"`. BSD grep does not extend BRE with `\\|` — it searches for the literal string `STRIP FAILED\\|STRIP PRODUCED NO TEXT` (backslash-pipe-backslash and all). The checker emits either `STRIP FAILED` or `STRIP PRODUCED NO TEXT` separately, never that combined literal, so the `names` assertion fails spuriously on every macOS run."
      wrong_action: "A reader sees `FAIL L did not name …` and `FAIL M did not name …`, concludes the strip interpreter emitted no error message — when the strip step actually did fail and the checker did name it correctly. The exit-code `check` calls for L and M would still pass; only the content check is wrong."
      anchor: "names \"L\" \"$TMP/l.out\" \"STRIP FAILED\\|STRIP PRODUCED NO TEXT\""
      evidence: tools/verify-quote-checker.sh:133
    - reason: "Case I starts a Python HTTP server in the background, waits up to 3 seconds (10 × 0.3s) for it to listen, then drives the checker against a manifest URL. The `check` and `names` assertions both look for the generic `FETCH FAILED` exit 3, which is also what `connection refused` produces when the server has not started. A checker that wrongly treats 404-with-body as drift (exit 2) but connection-refused as fetch-failure (exit 3) passes Case I on a slow or loaded machine without ever exercising the 404 path. The test cannot distinguish the scenario it names from the one it actually exercises."
      wrong_action: "A reader trusts Case I as proof that 404-with-body is treated as fetch-failure rather than drift, and ships a checker that misclassifies non-empty error pages as documentation drift — the very defect stop 23's §4a review found."
      anchor: "for _ in 1 2 3 4 5 6 7 8 9 10; do nc -z 127.0.0.1 \"$PORT\" 2>/dev/null && break; sleep 0.3; done"
      evidence: tools/verify-quote-checker.sh:101
  non_blocking:
    - reason: "The script depends on `nc`, `python3`, `sed`, and `grep` but checks for none of them and documents none of them in the header. A missing `nc` makes the port-selection loop at line 84 silently pick the first candidate (8099) and the wait loop at line 101 silently time out — the same \"confident wrong answer\" shape the lab's CLAUDE.md flags for `pgrep` and `ls -t`."
      evidence: tools/verify-quote-checker.sh:84,99,101
    - reason: "The header names the checker, the stop, the author, and the date, but does not document which platform's `sed`/`grep` semantics the fixtures rely on. The `printf '\\t'` calls (portable) sit alongside `sed '\\t'` and `grep '\\|'` (not portable) with nothing in the file flagging the difference."
      evidence: tools/verify-quote-checker.sh:1-13
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 217s |
| ollama-cloud/glm-5.2 | ok | 213s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| I-M — the five shapes the §4a review found in stop 23's ancestor | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### verify-quote-checker.sh — prove tools/verify-quotes.sh returns each of its registered exit codes, and prove it REFUSES the five failure shapes the §4a review found in stop 23's hardcoded ancestor plus one new shape this generalisation introduced.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### set -uo pipefail / cd / helpers
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### A local page carrying exactly the two sentences the good manifest quotes.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### A — every quote present. Also proves whitespace collapsing
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### B — one quote absent is exit 2
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### C, D — a fixture that proves nothing about a quote is exit 3
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### E, F, G, H — usage and manifest trust
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### I-M — the five shapes the §4a review found in stop 23's ancestor
**Verdict:** finding
**Failure:** Two portability defects in the fixture-construction and assertion code, both deterministic on macOS (the platform this runs on), both producing false FAILs from the test harness itself — not from the checker under test.

**Case K (line 120):** `sed 's/^quote\tp1\t/quote\tp2\t/' "$GOOD"` uses `\t` inside single quotes. BSD `sed` (macOS) does not interpret `\t` as a tab in BRE patterns — it treats it as the literal characters backslash-t. The manifest lines contain real tabs (produced by `printf '\t'`), so the substitution never matches. `$TMP/typo.tsv` becomes a byte-identical copy of `$GOOD`: the quote still references page key `p1`, the checker finds every quote, exits 0, and the `check` on line 122 reports `FAIL K undeclared page key expected 4, got 0`. The test fails for the wrong reason — the checker may correctly reject undeclared page keys, but this fixture never exercises that path.

**Cases L and M (lines 133, 139):** `names "L" "$TMP/l.out" "STRIP FAILED\|STRIP PRODUCED NO TEXT"` passes `\|` as a BRE alternation to `grep -q`. GNU grep extends BRE to treat `\|` as alternation; BSD grep (macOS) does not — it searches for the literal string `STRIP FAILED|STRIP PRODUCED NO TEXT` (pipe character and all), which never appears in the checker's output. Both `names` calls fail spuriously: `FAIL L did not name …`, `FAIL M did not name …`, even when the checker emitted exactly the string the test intended to match. The `check` calls (exit-code assertions) for L and M are unaffected and would still pass.

A reviewer on Linux would see all five cases pass. A reviewer on macOS would see K, L, and M fail — three false negatives from the harness, masking whether the checker itself is correct.
**Layer of the implied fix:** L3
**Anchor:** `sed 's/^quote\tp1\t/quote\tp2\t/' "$GOOD" > "$TMP/typo.tsv"` and `names "L" "$TMP/l.out" "STRIP FAILED\|STRIP PRODUCED NO TEXT"`

### N-P — the shape the MANIFEST added
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Q — --list prints the quote table and fetches nothing
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Final tally
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Not applicable — this is a test harness, not a rubric. No exit-code assertion restates a `names` assertion; they test different properties (exit code vs. output content) and a `check` pass with a `names` fail is a meaningful signal, not a duplicate.
- Which single section would you expect two reviewers to diverge on most, and by how much? The I-M section, by a full pass/fail split. A reviewer running on Linux sees 5/5 green; a reviewer on macOS sees 3/5 red (K, L, M). The disagreement is not about judgment — it is about whether `\t` in BSD sed and `\|` in BSD grep are interpreted as the author intended. One reviewer who knows BSD grep does not extend BRE with `\|` calls it a defect; one who assumes GNU semantics everywhere calls it fine. That is the ambiguity.
- What did the artifact not say that it needed to say? It does not state which `sed` or `grep` implementation it targets. The header names the checker, the stop, the author, and the date — but not the platform whose tools it depends on. The `printf '\t'` calls (which work everywhere) sit alongside `sed '\t'` and `grep '\|'` (which do not), and nothing in the file flags the difference.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

er.sh — prove tools/verify-quotes.sh returns each of its registered exit codes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### set -uo pipefail
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### A local page carrying exactly the two sentences the good manifest quotes.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### A — every quote present
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### E, F, G, H — usage and manifest trust
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### I-M — the five shapes the §4a review found in stop 23's ancestor
**Verdict:** finding
**Failure:** Case I starts a Python HTTP server in the background and waits up to 3 seconds (10 × 0.3s) for it to listen. If the server has not started when the checker runs — slow CI, cold Python import, loaded machine — the checker gets `connection refused`, not `404 with body`. Both produce exit 3 and the string `FETCH FAILED`, which is all the test checks. A checker with a bug that treats `404 with body` as exit 2 (drift) but `connection refused` as exit 3 (fetch failed) would pass this test every time on a slow machine, and the 404-specific behaviour the test claims to prove would never be exercised. The `names` check for `FETCH FAILED` makes this worse, not better: it confirms the generic message, not the 404-specific one. Two reviewers would disagree on whether 3 seconds is sufficient and whether the test proves what its comment claims.

Case K compounds this with a portability defect: `sed 's/^quote\tp1\t/quote\tp2\t/'` relies on sed interpreting `\t` as a tab. GNU sed does; BSD sed (macOS default) does not — it treats `\t` as a literal `t`, the substitution does not match the tab-separated manifest line, the output file is identical to the input, the checker runs with the original manifest, exits 0, and the test fails (expected 4). On the macOS platform this repository runs on, case K can fail not because the checker is broken but because the fixture is wrong.

Case M assumes the strip interpreter uses strict UTF-8 decoding. A checker that reads with `errors='replace'` would parse the Latin-1 page successfully, not find the quote, and exit 2 (drift) — the test expects 3 and fails. Whether that is a checker bug or a test that over-specifies the implementation depends on whether you believe non-UTF-8 input should be fatal.
**Layer of the implied fix:** L2
**Anchor:** `# I — an HTTP error status with a NON-EMPTY body must be exit 3 (not fetched), never exit 2.`

### N-P — the shape the MANIFEST added
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Q — --list prints the quote table and fetches nothing
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Not applicable — this is a verification script, not a scoring rubric. The `check` and `names` functions complement each other (exit code vs. output text), but in Case I the `names` pattern (`FETCH FAILED`) is too generic to distinguish the scenario the test claims from the one it actually exercises, so the complement is illusory there.
- Which single section would two reviewers diverge on most, and by how much? Cases I-M, by a full point on "does this prove what it claims." Case I's server-startup race means the test can pass without exercising the 404-with-body path at all. One reviewer reads the comment and trusts the fixture; the other traces the wait loop and realises the server may not be up. Case K's `\t`-in-sed portability issue is a binary disagreement that depends on which sed the reviewer has in mind.
- What did the artifact not say that it needed to say? The script depends on `nc`, `python3`, and `sed` but never checks for their existence or documents the requirement. A missing `nc` makes the port-selection loop in Case I silently pick the first candidate and the wait loop silently time out — the same "confident wrong answer" shape the lab's own CLAUDE.md warns about for `pgrep` and `ls -t`.
