# opencode review — verify-quotes

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
reviewed_utc:    20260929T143000Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: tools/verify-quotes.sh
    sha:  7b8eebaadddc
    dirty: false
lab_head:        e20d7b9
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: tools/verify-quotes.sh
  verdict: REJECT
  summary: Two scope/claim mismatches let the verifier return wrong results in plausible workflows: the cache key is bound to (manifest basename, page key) but not to URL, and the strip regexes for <script>/<style> are case-sensitive lowercase while the artifact claims generic removal.
  blocking:
    - reason: The cache filename is "$SLUG-$key.html" — keyed on manifest basename plus page key but NOT on the declared URL — so two manifests sharing basename + key but declaring different URLs collide. The second manifest reads the first's cached page and reports "sources=docs=cached" for a URL it never fetched.
      wrong_action: A reviewer reusing QUOTE_CACHE_DIR across phases (or simply between two manifests named the same, both using page key `docs`) would record "verified against manifest B's URL" for manifest B when the cached content came from manifest A's URL; the `sources=…=cached` line carries no URL provenance, so the wrong-URL verdict is silent.
      anchor: "SLUG=$(basename \"$MANIFEST\"); SLUG=${SLUG%.tsv}" combined with "[ -f \"$CACHE/$SLUG-$key.html\" ]"
      evidence: tools/verify-quotes.sh:66,178
    - reason: The strip function's regexes for <script> and <style> are case-sensitive lowercase only — a `<SCRIPT>` block survives stripping, and the matcher reports FOUND for sentences that exist only in uppercase-script content. The artifact's REGISTERED LIMITATION explicitly states "strip removes <script> and <style>", so the reader's expectation matches the claim.
      wrong_action: A reviewer constructing a fixture to prove "script content is excluded from the searched text" — e.g. `<SCRIPT>const evidence = "The quoted sentence.";</SCRIPT>` with the page's visible body never containing the sentence, and a manifest quoting "The quoted sentence." — expects ABSENT (because the limitation says script is removed) and gets FOUND; they trust the result. The project has explicitly named this failure shape (a control that reports over a smaller scope than it claims) as the one that has already cost it something.
      anchor: "t=re.sub(r\"<script.*?</script>\",\"\",t,flags=re.S)"
      evidence: tools/verify-quotes.sh:156
  non_blocking:
    - reason: Strip normalises whitespace to a single ASCII space (`re.sub(r"\s+"," ", …)`) and inserts a space per removed tag, but the matcher searches the manifest quote raw (`grep -qF -- "$quote"`). A quote carrying any non-canonical whitespace (double space, leading/trailing space, line break, or — for `<em>foo</em><strong>bar</strong>`-shaped markup — a space between adjacent tags the rendered browser shows without one) reports ABSENT for a present sentence. Real but usability-level: the reviewer re-quotes in stripped form and re-runs; the verifier is not silently wrong, just unforgiving.
      evidence: tools/verify-quotes.sh:158,217
  disputed:
    - finding: deepseek-v4-pro's leading-space injection in QUOTES construction (line 120) — `$quote` carries a leading space from a literal space between `$key\t` and `$val`, causing a quote that is the first text node on the cited page to report ABSENT.
 why: The premise that stripped text has "no leading space" is wrong for any fetched HTML page. The tag-replacement step `re.sub(r"<[^>]+>"," ",t)` inserts one space per tag, so the leading tags of every HTML document (`<!DOCTYPE>`, `<html>`, `<head>`, `<body>`, etc.) yield collapsed whitespace at the start of the stripped line. Even if the leading-space bug exists in the QUOTES string, the matcher would still find the quote, because the surrounding whitespace from tag removal covers it. The defect, if it exists, is masked in the documented use case, so the finding's stated impact does not survive against the text.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 47s |
| ollama-cloud/deepseek-v4-pro | ok | 138s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

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
| tools/verify-quotes.sh | 1/2 | L2 |
| Manifest parse and quote storage (`QUOTES` construction, line 120) | 1/2 | L1 |
| `strip()` and the matcher's whitespace contract (lines 152–159 vs 217) | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### tools/verify-quotes.sh
**Verdict:** finding
**Failure:** Given a fixture containing `<SCRIPT>const evidence = "The quoted sentence.";</SCRIPT>` with no occurrence of that sentence in rendered page text, and a manifest quoting `The quoted sentence.`, `strip` leaves the uppercase script contents because its regular expression is case-sensitive. The matcher reports `FOUND` and exits 0; a reviewer relying on the stated removal of `<script>` content would expect `ABSENT` and exit 2. The cache design also permits a wrong-page result: two manifests named `quotes.tsv`, both using key `docs` but declaring different URLs, resolve the same cache filename `quotes-docs.html`; the second run can verify the first page while reporting `sources=docs=cached`.
**Layer of the implied fix:** L2
**Anchor:** t=re.sub(r"<script.*?</script>","",t,flags=re.S)

### Cross-cutting
**Verdict:** no finding
**Failure:** No scoring category exists, so none duplicates a pass/fail gate. Reviewers would diverge most on `REGISTERED LIMITATION`: with the uppercase-`SCRIPT` fixture, one would accept exit 0 under “somewhere on the cited page,” while another would require exit 2 because script content was said to be removed—a full binary verdict and exit-code divergence. The artifact needed to state that script/style removal is case-sensitive and that cached content is selected by manifest basename plus page key without binding it to the declared URL.
**Layer of the implied fix:** n/a
**Anchor:** n/a


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### Manifest parse and quote storage (`QUOTES` construction, line 120)
**Verdict:** finding
**Failure:** The stored quote is `key` TAB **space** `val` — the literal space after the tab is part of the quote string, not a separator. The matcher at line 215 splits on tab, so `$quote` becomes `" val"` with a **leading space**, and `grep -qF -- "$quote"` searches for the sentence *preceded by a space*. `strip()` (lines 156–158) collapses the page to one line of single-space-separated text, which has **no leading space**. So a quote that is the *first* text node on the cited page (a `<h1>`, the opening sentence, anything before any other content) will report `ABSENT` and exit 2 — false documentation drift — even though the sentence is present verbatim. It passes in most cases only because ordinary sentences are preceded by another word and hence a space; the defect is masked everywhere except position zero of the stripped text.
**Layer of the implied fix:** L1 — the bad value (a quote that silently carries an injected leading space) becomes unrepresentable if the space is removed from the construction; nothing needs to execute.
**Anchor:** `QUOTES="$QUOTES$key	$val` followed by a newline (line 120) — the space between the tab and `$val`.

### `strip()` and the matcher's whitespace contract (lines 152–159 vs 217)
**Verdict:** finding
**Failure:** The page text is normalized — `re.sub(r"\s+"," ",…)` collapses every whitespace run to a single ASCII space, and tag removal *inserts* a space per tag. The manifest quote is matched **raw**, with no normalization. Two concrete divergences: (a) a transcribed quote carrying any run of whitespace other than a single space (double space, a trailing space from copy, a hard line break that survived into the TSV) will never equal the normalized page text, so a present sentence reports `ABSENT` and exit 2; (b) a sentence whose words are separated in the source by tags *without* whitespace — `<em>foo</em><strong>bar</strong>` renders `foobar`, but strip yields `foo bar` — so the fixed-string match finds `foo bar` on the page while the workbook's quote (if it reads `foo bar`) matches, or fails, depending on which of the two the author copied. Nothing validates that a quote is already in single-space canonical form, so the same instrument accepts quotes that can only ever fail and rejects ones the page actually renders.
**Layer of the implied fix:** L2 — the quote must be run through the same collapse/trim before matching, or a parse-time check must reject non-canonical quotes and exit 4; either is an executing check, not a note.
**Anchor:** `sys.stdout.write(re.sub(r"\s+"," ",html.unescape(re.sub(r"<[^>]+>"," ",t))))` (line 158) against `grep -qF -- "$quote" "$TMP/$key.txt"` (line 217).

### Fetch/source loop (lines 168–212)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Key/URL validation (lines 85–124)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exit-code discipline and empty-manifest guards (lines 127–145)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? This artifact is an instrument, not a rubric — it has no scoring categories, so no duplication. Its exit codes (0/2/3/4) are deliberately partitioned and `verify-quote-checker.sh` is asserted to prove each, but that checker is not the artifact under review here.
- Which single section would two reviewers diverge on most, and by how much? The leading-space bug (line 120): one reviewer who only reads the header's *"must reproduce its live numbers exactly"* and runs it against a manifest whose quotes all sit mid-page would see a green result and report no finding; a reviewer who constructs a page whose quoted sentence is the first text node sees a hard `ABSENT`/exit 2. Divergence is binary (found/not-found), driven entirely by whether the test page has a leading sentence.
- What did the artifact not say that it needed to say? It never states the whitespace contract its matcher imposes — that a quote must be exactly the single-space-collapsed form of the page text, with no leading/trailing whitespace, and that the script itself prepends a space. The header's registered limitation covers *chrome*, not the quote-normalization asymmetry, so a reader has no way to learn that a faithful quote can still fail for whitespace reasons.
