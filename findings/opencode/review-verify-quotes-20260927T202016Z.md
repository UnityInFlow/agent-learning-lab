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
reviewed_utc:    20260927T202016Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/p08/verify-quotes.sh
    sha:  58a5dc5ea1de
    dirty: false
lab_head:        1bb0ffb
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Acceptance

The gate failed to run (opencode exit 1).
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 24s |
| codex | ok | 25s |

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
| Exit codes | 1/1 | L2 |
| QUOTES | 1/1 | L2 |
| strip | 1/1 | L2 |
| CACHE | 1/1 | L2 |


---

## Run 1 of 2 — codex

### evidence/p08/verify-quotes.sh
**Verdict:** finding
**Failure:** If a documentation URL returns HTTP 404 with a non-empty HTML error page, `curl -sS -m 40 -L` exits successfully because `--fail`/`--fail-with-body` is absent. The script then reports every affected quotation as `ABSENT` and exits 2, while another reviewer following the declared exit-code contract classifies the page as not fetched and expects exit 3. A second instance occurs when `$CACHE/ghaw-$key.html` exists but is empty: the cached path reaches quote matching and exits 2, whereas an empty live response is explicitly rejected with exit 3.
**Layer of the implied fix:** L2
**Anchor:** curl -sS -m 40 -L "$url" -o "$TMP/$key.html" || { echo "FETCH FAILED $key $url" >&2; exit 3; }

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates a pass/fail gate because this artifact has no scoring categories. The exit-code section is where two reviewers would diverge most: for the same non-empty HTTP 404 response, one will assign exit 2 from the observed implementation and another exit 3 from the stated contract—a one-category disagreement. The artifact needed to say whether HTTP error responses and empty cached pages count as fetch failures; its live-fetch and cache paths currently answer the empty-page case differently.
**Layer of the implied fix:** L2
**Anchor:** 3  a page could not be fetched (nothing was proved either way)


---

## Run 2 of 2 — codex

### Exit codes
**Verdict:** finding
**Failure:** If a cited URL returns HTTP 404 with a non-empty HTML error body, `curl -sS -m 40 -L` exits 0 because `-f` is absent. The script then reports every quote for that page as `ABSENT` and exits 2, while a reviewer following the stated contract would classify the page as not fetched and expect exit 3. Thus the same input is classified as quotation drift by the script and as an unprovable fetch by a competent reviewer.
**Layer of the implied fix:** L2
**Anchor:** 3  a page could not be fetched (nothing was proved either way)

### PAGES
**Verdict:** no finding
**Failure:** No concrete failure scenario found for the declared key-to-URL mapping in the supplied evidence.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### QUOTES
**Verdict:** finding
**Failure:** Change one quote row from `safe\tEvery write operation is skipped` to `saf\tEvery write operation is skipped`. The undeclared page key makes `$TMP/saf.txt` unreadable, but stderr is discarded and the script reports the quotation as absent, exiting 2. One reviewer would diagnose documentation drift; another would diagnose an invalid verifier configuration. No executed check rejects the unknown key.
**Layer of the implied fix:** L2
**Anchor:** if grep -qF -- "$quote" "$TMP/$key.txt" 2>/dev/null; then

### strip
**Verdict:** finding
**Failure:** If the quoted phrase appears only in page chrome, such as a navigation menu or accessibility-only element, while being removed from the cited documentation body, `strip` retains that text and `grep` reports `FOUND`. The script therefore answers that the workbook quotation still appears even though a reviewer checking the page's substantive content would mark it absent.
**Layer of the implied fix:** L2
**Anchor:** sys.stdout.write(re.sub(r"\s+"," ",html.unescape(re.sub(r"<[^>]+>"," ",t))))

### CACHE
**Verdict:** finding
**Failure:** Set `QUOTE_CACHE_DIR` to a directory containing an empty `ghaw-safe.html`. The cache branch accepts the file because it checks only `-f`; stripping produces empty text, all safe-page quotes become `ABSENT`, and the script exits 2. The equivalent empty live response or empty fixture exits 3, so identical empty page content receives two different classifications depending only on its source.
**Layer of the implied fix:** L2
**Anchor:** elif [ -n "$CACHE" ] && [ -f "$CACHE/ghaw-$key.html" ]; then cp "$CACHE/ghaw-$key.html" "$TMP/$key.html"

### FIXTURE
**Verdict:** no finding
**Failure:** No concrete failure scenario found in the supplied fixture readability and emptiness checks.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category or pass/fail scoring gate exists, so there is no duplication to name. Reviewers would diverge most on `strip`: for a phrase present only in navigation, one can count literal presence anywhere in the fetched page while another can require presence in the documentation body, producing FOUND versus ABSENT and potentially exit 0 versus 2. The artifact needed to define which page regions count as evidence and to validate that every quote key names a declared page before checking content.
**Layer of the implied fix:** L2
**Anchor:** prove that every sentence phases/08-agentic-workflows/README.md quotes is still in the page it cites

