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
reviewed_utc:    20260929T115705Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: tools/verify-quotes.sh
    sha:  bb1404e980fd
    dirty: false
lab_head:        73b4a5e
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: tools/verify-quotes.sh
  verdict: REJECT
  summary: The verifier carries four silent correctness defects (path traversal in page key, silent truncation of tab-bearing quote values, identical output for live vs cached matches, and an unanchored substring matcher with no enforced length) that could publish wrong FOUND/ABSENT verdicts — exactly the failure mode the script's own header names as the reason it must be a tool, not a copy.
  blocking:
    - reason: The page key has no grammar; a key containing `../` causes curl/cp to write `$TMP/$key.html` outside the mktemp directory, so the EXIT trap does not remove it and two concurrent runs using the same traversal key collide on the same `/tmp/shared.html` between fetch and extraction.
      wrong_action: A second concurrent run silently overwrites the first run's fetched page before it is stripped, so the first run reports FOUND/ABSENT against the second run's content — wrong verdict from a misconfigured manifest, indistinguishable from a real result.
      anchor: "PAGES+=(\"$key|$val\")"
      evidence: tools/verify-quotes.sh:91; tools/verify-quotes.sh:123-124 (mktemp + trap); tools/verify-quotes.sh:142,148,155 (cp/curl into "$TMP/$key.html")
    - reason: The page key is also not protected against `|`, which line 136 splits on (`key=${entry%%|*}; url=${entry#*|}`); a key with an embedded `|` becomes a different key and the URL is whatever sits to its right.
      wrong_action: A typo or hostile manifest key produces a wrong TMP filename and a curl URL like `bar|baz` that exits 3, so a real verifier fault is reported as a fetch failure rather than as exit 4 (bad manifest); reviewers cannot tell the two apart.
      anchor: "key=${entry%%|*}; url=${entry#*|}"
      evidence: tools/verify-quotes.sh:136
    - reason: The two parse sites treat a tab inside the quote value differently. Line 80 (`val=${rest#*	}`) keeps every tab after the first; line 171 (`while IFS=$'\t' read -r key quote`) splits on every tab, so a quote whose sentence contains an embedded tab is silently truncated at the first tab after the key.
      wrong_action: A workbook quotes a sentence copied from a code block or table that contains a tab. The manifest passes line 81's malformed-line check, the value is preserved into `$QUOTES`, then at the matcher the quote is truncated to the pre-tab fragment — a substring of the real sentence either matches spurious text (false FOUND) or fails to match (false ABSENT for the real sentence), and the script's line-81 guard never fires.
      anchor: "val=${rest#*	}"
      evidence: tools/verify-quotes.sh:80 vs tools/verify-quotes.sh:171
    - reason: The `QUOTE_CACHE_DIR` path (lines 64, 143-148) reuses a previously-fetched snapshot and reports the same `FOUND` line and the same exit 0 as a live match, with no provenance in the output to distinguish them.
      wrong_action: An operator re-runs the verifier against yesterday's cache after the page is edited; the sentence is gone live but the cached copy still has it, the script prints FOUND and exits 0, and a workbook citing that run records a citation the script never re-checked against the live page. The header says this script exists to detect documentation drift, and the cache path silently defeats the detection without flagging it.
      anchor: "CACHE=\"${QUOTE_CACHE_DIR:-}\"          # set to re-check against already-fetched pages"
      evidence: tools/verify-quotes.sh:64,143-148,173-174 (matched line is identical for live and cached)
  non_blocking:
    - reason: The `strip` step (lines 126-133) removes `<script>` and `<style>` only and then drops all tags, so text inside CSS-hidden body content (collapsed accordion, `display:none`, `<noscript>`, `aria-hidden` regions) survives to the matcher. The header's REGISTERED LIMITATION names this risk only for chrome (navigation/footer/a11y) and never for hidden body content; the line-level pass flags this as a soft-removal gap.
      evidence: tools/verify-quotes.sh:33-40 (limitation as written), tools/verify-quotes.sh:126-133 (strip)
    - reason: The matcher is an unanchored `grep -qF` (line 173) and the only defense against false FOUND on a deleted-but-still-substring'd sentence is the header's assertion that "these quotes are full sentences, which chrome does not carry"; nothing in the script enforces a minimum length or anchors the match, so the defense is a property of the data the manifest author chooses to supply rather than of the tool.
      evidence: tools/verify-quotes.sh:173, tools/verify-quotes.sh:40 (defense), tools/verify-quotes.sh:81 (parser only checks non-empty)
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 30s |
| ollama-cloud/deepseek-v4-pro | ok | 315s |

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
| REGISTERED LIMITATION | 1/2 | L3 |
| page fetch / strip | 1/2 | L2 |
| quote matching | 1/2 | L3 |
| parse the manifest | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### tools/verify-quotes.sh
**Verdict:** finding
**Failure:** A manifest containing `page\t../shared\thttps://example.test/a` and `quote\t../shared\tSentence A` passes manifest validation. The fetch writes to `$TMP/../shared.html`, outside the directory removed by the EXIT trap. Two concurrent runs using that key can overwrite the same `/tmp/shared.html` between fetch and extraction, so one run may report FOUND or ABSENT using the other run’s page. A key containing `|` also passes validation but is later split at that character, changing both the key and URL. The manifest format gives no key grammar, so competent reviewers can disagree whether these are invalid manifests or supported inputs.
**Layer of the implied fix:** L2
**Anchor:** if [ "$rest" = "$line" ] || [ "$val" = "$rest" ] || [ -z "$key" ] || [ -z "$val" ]; then

### Cross-cutting
**Verdict:** no finding
**Failure:** No scoring categories or pass/fail gates exist, so none are duplicated. Reviewers would diverge most on `tools/verify-quotes.sh`, by one verdict level—finding versus no finding—because the accepted key character set is unspecified. The artifact needed to state and enforce a key grammar that prevents path traversal and collision with the internal `|` delimiter.
**Layer of the implied fix:** n/a
**Anchor:** n/a


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

✱ Grep "QUOTES="\$QUOTES\$key" in tools/verify-quotes.sh · 1 match
✱ Grep "QUOTES|read -r key|grep -qF|printf 'FOUND" in tools/verify-quotes.sh · 18 matches
### WHY THIS IS A TOOL AND NOT A SECOND COPY
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The header is honest about what the script is and what it isn't. It explicitly claims "L2 over the quoting and says nothing whatever about the agent under test," which is an accurate layer statement — the script executes and exits non-zero on a missing quote, so it is genuinely L2 over the quoting, and it correctly disclaims any claim over the agent. No defect here.

### MANIFEST FORMAT / exit codes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The exit-code contract (0/2/3/4) is registered and the distinction between "not found" (2) and "couldn't check" (3) is exactly the right split, and the script consistently honors it. The malformed-manifest rejection logic (lines 79-84) correctly catches missing-tab, missing-key, and missing-value cases with exit 4, never 2. This is the strongest part of the file.

### REGISTERED LIMITATION
**Verdict:** finding
**Failure:** The limitation (lines 33-40) claims the searched text includes only "page CHROME — navigation, footers, accessibility-only elements," and defends the resulting false-FOUND risk with "these quotes are full sentences, which chrome does not carry." But `strip` removes only `<script>` and `<style>` before stripping tags (lines 126-133). It retains text inside CSS-hidden body content: a collapsed accordion panel, a `display:none` tab, a closed `<details>`, a `<noscript>` block, an `aria-hidden` region. Those are **not chrome** — they are body content, and they are exactly where an editor "removes" text without deleting it (the soft-removal pattern this tool exists to detect). A full sentence absolutely lives in a collapsed panel, so the "full sentences don't live in chrome" defense does not reach this case. Concrete scenario: a workbook quotes a sentence that an editor later hides inside a collapsed accordion or moves behind `display:none`. `strip` keeps the text, `grep -qF` finds it, the script prints FOUND and exits 0. The workbook's claim "the sentence still appears on the page" is false — the sentence is not visible — yet the tool certifies it. Two reviewers diverge: one reads "appears somewhere on the cited page" (line 37-38) as "in the DOM, regardless of visibility," the other reads "appears" as "visibly rendered." The limitation's own wording cannot settle this, because it enumerated only *chrome* and never addressed *hidden body content*.
**Layer of the implied fix:** L3
**Anchor:** `the searched text includes page CHROME — navigation, footers, accessibility-only elements. A sentence deleted from the body but surviving in chrome would still report FOUND`

### page fetch / strip
**Verdict:** finding
**Failure:** The `QUOTE_CACHE_DIR` path (lines 64, 143-148) re-verifies against a snapshot fetched at some earlier time, and still reports FOUND and exits 0 without any indication the source was not the live page. The tool's entire purpose is to detect documentation drift, and the cache path silently defeats it. Concrete scenario: run the tool against the live page today (sentence present, FOUND). Tomorrow the sentence is deleted from the page. Re-run with `QUOTE_CACHE_DIR` pointed at today's fetch. The tool copies yesterday's `$SLUG-$key.html`, matches the quote, prints FOUND, exits 0. A workbook citing this run claims the sentence is still on the page, and it is not. Two reviewers diverge: one says "the comment at line 64 says *re-check against already-fetched pages*, so the cache is an explicit feature and the consumer chose it"; the other says "FOUND with no staleness signal is a false pass — the exit code and the FOUND line carry no provenance, so nothing downstream can tell a live match from a stale one." The script is meticulous about false-ABSENT (five defects fixed, all making a failure exit 3 rather than 2) but has no symmetric guard on the false-FOUND side here — a stale FOUND is reported with the same exit 0 as a live FOUND.
**Layer of the implied fix:** L2
**Anchor:** `CACHE="${QUOTE_CACHE_DIR:-}"          # set to re-check against already-fetched pages`

### quote matching
**Verdict:** finding
**Failure:** The matcher is an unanchored substring test, `grep -qF -- "$quote" "$TMP/$key.txt"` (line 173), over one collapsed line of text. The tool's only defense against false FOUND is the limitation's assertion that "these quotes are full sentences" (line 40) — but nothing enforces sentence length anywhere. The manifest `quote` field accepts any string; the parser validates non-empty (line 81) and nothing else. Concrete scenario: a workbook quotes a short phrase — say "the agent" — and the cited page is later edited so the original sentence is gone, but the words "the agent" survive verbatim inside an unrelated surviving sentence. `grep -qF` matches the phrase, FOUND, exit 0, and the workbook's citation is certified intact when the sentence it quoted no longer exists. For a genuinely full sentence this is unlikely; for a two-word quote it is near-certain. The defense is a property of the *data* ("full sentences") that the tool asserts but does not check, so the control's coverage is narrower than the comment claims.
**Layer of the implied fix:** L3
**Anchor:** `these quotes are full sentences, which chrome does not carry`

### parse the manifest
**Verdict:** finding
**Failure:** The two parse sites treat an embedded tab in the quote value differently. Line 80 does `val=${rest#*	}`, which captures everything after the key's tab **including any further tabs** — so a quote value containing a tab is preserved intact through parsing and storage. Line 171 does `while IFS=$'\t' read -r key quote`, which splits on the first tab and **truncates** the quote at the embedded tab, silently dropping the remainder. The manifest format has no escaping mechanism, and line 81's malformed-line check does not detect an embedded tab, so this cannot be caught as exit 4. Concrete scenario: a manifest `quote` line whose sentence was copied from a table or code block and contains a tab. The value parses fine at line 80, survives validation, then at line 171 the quote is truncated to the pre-tab fragment, which either matches spuriously (false FOUND for a fragment) or fails to match (false ABSENT for the real sentence) — same input, two different verdicts depending on which parse site you read. Two reviewers handling this manifest would not agree on whether the quote was verified.
**Layer of the implied fix:** L2
**Anchor:** `val=${rest#*	}` (vs. `while IFS=$'\t' read -r key quote`)

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Not applicable — this is a verification tool, itself a gate, not a scoring rubric. No internal gate is restated by a scoring category.
- Which single section would two reviewers diverge on most, and by how much? The **REGISTERED LIMITATION** (hidden body content) — one reviewer reads "appears somewhere on the cited page" as "in the DOM regardless of visibility" and approves, the other reads "appears" as "visibly rendered" and rejects the control as over-reporting. That is a full verdict flip on the tool's central claim, not a point-cost disagreement.
- What did the artifact not say that it needed to say? Three things. (1) It never states whether "found in a cache" is the same claim as "found on the live page" — the cache path changes what the exit code means and says nothing about it. (2) It enumerates *chrome* as the false-FOUND source but never addresses *hidden body content* (collapsed panels, `display:none`, `noscript`), which is where a full sentence actually lingers after a soft removal, so the "full sentences don't live in chrome" defense answers a question the tool's real failure mode never asked. (3) It asserts the quotes are "full sentences" as a load-bearing defense without ever enforcing or stating a minimum length, leaving the substring matcher's coverage to the manifest author's discipline rather than the tool.
