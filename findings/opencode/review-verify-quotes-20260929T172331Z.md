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
reviewed_utc:    20260929T172331Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: tools/verify-quotes.sh
    sha:  77c653db5e9f
    dirty: false
lab_head:        0621d6a
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: tools/verify-quotes.sh
  verdict: REJECT
  summary: A declared-but-unreferenced page that fails to fetch sinks the whole manifest with exit 3, so one orphan URL silently turns a manifest that would have reported `found=N absent=M` into "nothing proved either way" — the script's exit-code contract is broken by the implementation.
  blocking:
    - reason: The page loop fetches every declared page fail-fast (line 207 → exit 3) but the manifest validator (lines 131–132, 139–145) only checks the inverse — "every quote names a declared page". There is no symmetric check that every declared page is referenced by at least one quote, and no skip path. Adding a context/see-also page whose URL later404s therefore changes the run from "verified all real quotes" to exit 3 with nothing reported, indistinguishable from a fetch failure on a page that actually carries the drift signal.
      wrong_action: A downstream checker (or a human reading the exit code) sees `exit 3` and concludes "the verifier could not fetch the page whose drift I was checking." In the orphan case the verifier never even attempted the relevant pages, so the N previously verified quotes are lost behind an exit code whose documented meaning ("nothing was proved either way") is only literally true because the run aborted before proving anything.
      anchor: "for entry in "${PAGES[@]}"; do" / "curl -fsS -m 40 -L "$url" -o "$TMP/$key.html" || { echo "FETCH FAILED $key $url" >&2; exit 3; }"
      evidence: tools/verify-quotes.sh:175, tools/verify-quotes.sh:207, tools/verify-quotes.sh:131-132, tools/verify-quotes.sh:139-145
  non_blocking:
    - reason: The `strip` regex `<[^>]+>` (line 164) stops at the first `>` inside an attribute value, so a sentence that lives only inside `title="..."` / `aria-label="..."` survives tag removal. The documented contract at line 37 ("the quoted sentence still appears somewhere on the cited page") is satisfied literally — attribute text is on the page — but the in-code claim at line 158 ("one long line of text") and the registered limitation at lines 33–40 (chrome only) do not cover this class. A reviewer expecting "visible body text" is misled; a reviewer accepting the loose contract is not.
      evidence: tools/verify-quotes.sh:164, tools/verify-quotes.sh:33-40, tools/verify-quotes.sh:158
    - reason: `grep -qF -- "$quote"` is a literal substring test (line 244) against text that has been whitespace-collapsed by `strip()`. A quote transcribed without its terminal period — or a clause embedded in a longer surviving sentence — reports FOUND even when the original sentence was rephrased. The script's stated claim is "appears somewhere on the cited page", which a substring match satisfies, so this is consistent with the contract; it is also the direction that suppresses drift rather than inflates it, opposite to the script's stated worry. Worth tightening if the workbook later wants sentence-boundary matching.
      evidence: tools/verify-quotes.sh:244, tools/verify-quotes.sh:37
    - reason: Exit code 3 is documented as "a page could not be fetched, read, or converted to text" (lines 27–31) but is also produced by `TMP=$(mktemp -d) || exit 3` (line 149), `cp "$FIXTURE"`-style local environment failures (lines 192–194), and `strip` failures (lines 217–220) — none of which involve a page. The documented contract literally covers "fetched, read, or converted", which is broad enough to absorb all of these as "nothing was proved either way", and stderr disambiguates. A checker that keys only on the exit code cannot tell a network failure from a broken scratch directory; the script never states that these are deliberately the same bucket.
      evidence: tools/verify-quotes.sh:27-31, tools/verify-quotes.sh:149, tools/verify-quotes.sh:192-194, tools/verify-quotes.sh:217-220
  disputed:
    - finding: "the matcher loop ... substring vs sentence" (deepseek-v4-pro, matcher-loop finding)
      why: The artifact's own claim at line 37 is "the quoted sentence still appears somewhere on the cited page", and the matcher satisfies that claim by substring. I cannot name a wrong action a faithful reader would take that the artifact's own contract does not already license; the finding reads as a contract-tightening request, not a defect against what the artifact claims.
    - finding: "Cross-cutting: the artifact does not specify whether text surviving from HTML attributes, comments, or malformed markup counts as appearing on the page" (codex panel, cross-cutting)
      why: The artifact does specify this — line 37 says "somewhere on the cited page", and the registered limitation at lines 33–40 disclaims chrome as the boundary. Attribute/comment/malformed-markup text is, in the artifact's stated contract, still on the page. The finding's premise that the contract is silent here is not borne out by lines 33–40 +37 read together; what the contract excludes is body-region specificity, not markup-class specificity.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 56s |
| ollama-cloud/deepseek-v4-pro | ok | 135s |

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
| page fetch loop (lines 167–222) | 1/2 | L2 |
| matcher loop (lines 225–249) | 1/2 | L2 |
| exit-code taxonomy (lines 27–31, and `mktemp`/`strip`/`fixture` failure sites) | 1/2 | L2 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### tools/verify-quotes.sh
**Verdict:** finding
**Failure:** Use a page containing `<div title="ignore > A cited sentence survives.">unrelated</div>` and a manifest quoting `A cited sentence survives.` The tag-removal regex stops at the `>` inside the quoted attribute, leaving the sentence in extracted text and reporting FOUND even though it appears only inside markup. A reviewer treating “page” as raw HTML accepts this; a reviewer relying on the stated removal of all tags rejects it.
**Layer of the implied fix:** L2
**Anchor:** `strip` removes <script> and <style> and then all tags

### Cross-cutting
**Verdict:** no finding
**Failure:** No scoring category exists, so none duplicates a pass/fail gate. Reviewers would diverge most on the registered limitation: one would classify attribute residue as permitted “somewhere on the cited page,” while another would classify it as content the stated tag stripping excludes—a one-verdict difference between accept and finding. The artifact does not specify whether text surviving from HTML attributes, comments, or malformed markup counts as appearing on the page.
**Layer of the implied fix:** n/a
**Anchor:** n/a


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

The artifact is a bash script, not a keyed document, so I've used its own comment-banner sections as the headings. Findings below are limited to what carries a concrete failure scenario.

### header / registered limitation
**Verdict:** no finding
**Failure:** n/a — the limitation (chrome survives the strip) is stated, scoped, and disputed on the record rather than silently claimed away. The claim it ultimately supports ("the sentence appears *somewhere* on the page") is deliberately narrower than a region check, which is honest.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### manifest parsing (key/kind dispatch, lines 68–132)
**Verdict:** no finding
**Failure:** n/a — the parse rejections (malformed line, illegal key, tab-in-value, duplicate page key, unknown kind, empty manifest, undeclared page key) all map to exit 4 and are stated to be misconfiguration, never drift. Each is a concrete "bad value still writable → rejected" path.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### page fetch loop (lines 167–222)
**Verdict:** finding
**Failure:** a manifest declares a page that no quote references (a leftover `page` line), and that page's URL is dead. The loop iterates *every* declared page (`for entry in "${PAGES[@]}"`), `curl` fails on the orphan page, and the script `exit 3`s — reporting "nothing was proved either way" for the *entire* manifest — even though every other page's quotes were present and would have returned 0. Line 131 only rejects a manifest with zero pages; nothing rejects a page with zero quotes, and nothing lets a quote-less page be skipped rather than sink the run. Two reviewers diverge on whether the orphan declaration is the author's error or the tool's: the manifest is well-formed under every validation the script performs, so the tool admits it and then lets one dead URL mask N verified quotes.
**Layer of the implied fix:** L2 — a validation (or a skip) that executes and refuses the bad state (a page contributing no quote) would have to be added; as written the guard does not exist and the failure is a silent exit-code swap.
**Anchor:** `for entry in "${PAGES[@]}"; do` / `curl -fsS -m 40 -L "$url" -o "$TMP/$key.html" || { echo "FETCH FAILED $key $url" >&2; exit 3; }`

### matcher loop (lines 225–249)
**Verdict:** finding
**Failure:** `grep -qF -- "$quote"` is a raw substring test, but the script's own claim at line 37 is "the quoted *sentence* still appears somewhere on the cited page." A quote with no trailing punctuation, or a mid-sentence clause, matches inside a *different*, longer sentence. Concrete case: manifest quote `The system must reject invalid input` (transcribed without its period), and the page body was edited from "…must reject invalid input." to "…must reject invalid input before processing." The original sentence is gone — drift has occurred — but `grep -F` finds the quote as a substring of the surviving sentence and reports FOUND. This suppresses a real staleness signal, the direction the script otherwise guards hardest against. It is not covered by the chrome limitation at lines 33–40 (that is about navigation/footer text, not body substring), and it is precisely the house failure mode the file cites repeatedly: a control reporting over a scope larger than it enforces.
**Layer of the implied fix:** L2 — the matcher is executed code; tightening it to boundary- or sentence-aware matching changes what the control proves, not a prose note.
**Anchor:** `grep -qF -- "$quote" "$TMP/$key.txt"` (claim at line 37: "the quoted sentence still appears somewhere on the cited page")

### exit-code taxonomy (lines 27–31, and `mktemp`/`strip`/`fixture` failure sites)
**Verdict:** finding
**Failure:** the documented exit codes are 0 / 2 / 3 / 4, with 3 described as "a page could not be fetched, read, or converted to text." But `TMP=$(mktemp -d) || exit 3` (line 149) returns 3 on a local environment failure where *no page was ever touched*. A downstream reader of the exit code — or the checker that re-proves these codes — cannot distinguish "a page failed to fetch" from "the tool could not even create its scratch directory." Two reviewers of an exit-3 result conclude a fetch failed when in fact nothing ran. Minor, but it is the same "confident wrong answer" shape the file keeps identifying.
**Layer of the implied fix:** L2 — a distinct internal-error code (or routing mktemp failure to exit 4) is an executed-code change; as written the exit code's meaning is overloaded.
**Anchor:** `TMP=$(mktemp -d) || exit 3`

### Cross-cutting
- **Duplicate pass/fail gate:** none. This is a tool, not a rubric — there is no scoring category restating a gate. The exit-code contract and the separate `verify-quote-checker.sh` are not attached, so I cannot compare them; flagged as skipped rather than asserted.
- **Most divergent section:** the matcher loop. "Does the sentence appear" vs "does the string appear as a substring" is the one place two faithful readers would land on opposite verdicts for the same page edit, and it is costed directly in the drift signal (false FOUND vs true ABSENT).
- **What it did not say:** the exit-code taxonomy has no distinct "internal error" code; `mktemp`, `strip`, and fixture-readability failures all collapse into exit 3, whose documented meaning is "a page could not be fetched, read, or converted." A reader of exit 3 cannot tell a network failure from a broken local environment, and the script never states that these are the same bucket by design.
