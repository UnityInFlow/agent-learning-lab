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
reviewed_utc:    20260929T121637Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: tools/verify-quotes.sh
    sha:  7c2fa926f103
    dirty: false
lab_head:        3982fda
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: tools/verify-quotes.sh
  verdict: REJECT
  summary: Internal contradiction between line 137's "Bash 3.2 = no associative array" declaration and the Bash-4-only associative-array syntax at lines 161/197/204/215 silently breaks the documented provenance feature on the documented platform, shipping back the very defect the feature was added to fix.
  blocking:
    - reason: Line 137 names Bash 3.2 as the target and explicitly rejects associative arrays, but lines 161/197/204/215 use `declare -A`, indexed assignment `PAGE_SOURCE["$key"]=`, indexed access `${PAGE_SOURCE[$key]}`, and key-iteration `${!PAGE_SOURCE[@]}` — all Bash 4.0+ features. `set -uo pipefail` (line 43) lacks `-e`, so a `declare -A` failure on Bash 3.2 is non-fatal and the variable is never populated. Line 213 then claims "Every line now carries its source, and so does the summary" — that is the contract this defect breaks.
      wrong_action: A reader runs the script on macOS as the artifact itself documents (Bash 3.2 ships on this machine), sees FOUND/ABSENT lines with empty `[p1:]` source tags and an empty `sources=` summary, and trusts the verification result — not realising the provenance feature (the entire §4a defect-4 fix) has silently degraded to exactly the state it was meant to fix: byte-identical result lines that say nothing about whether the network was touched.
      anchor: "Bash 3.2 ships on this machine, so this is a string membership test and not an associative array."
      evidence: tools/verify-quotes.sh:137 paired with tools/verify-quotes.sh:161,197,204,215
  non_blocking:
    - reason: Whitespace asymmetry — `strip` collapses page whitespace to single spaces (line 158) but `grep -qF -- "$quote"` matches the raw quote (line 203). A manifest quote carrying interior multi-space (a transcribing artifact from PDF/fixed-width copy) reports ABSENT instead of being rejected upfront the way tab-in-value is rejected at lines 104-108. Real defect, but consistent with the literal-string contract in the registered limitation; the L2 fix would be to reject multi-space quotes the same way tabs are rejected.
      evidence: tools/verify-quotes.sh:158,203
    - reason: `sources=` summary iteration order is non-deterministic (associative-array key order); folded into the blocking Bash-version finding rather than a separate defect.
      evidence: tools/verify-quotes.sh:215
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 30s |
| ollama-cloud/deepseek-v4-pro | ok | 514s |

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
| `strip` (html→text) (lines 152–159) | 1/2 | L2 |
| Fetch / cache / fixture loop (lines 161–198) | 1/2 | L1 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### tools/verify-quotes.sh
**Verdict:** finding
**Failure:** Run the same valid manifest on macOS Bash 3.2 and on Bash 5.x. Bash 5.x accepts the associative array and can return a registered result; Bash 3.2 rejects `declare -A`, then the script continues without `set -e` and later fails while using `PAGE_SOURCE`, producing no reliable registered verdict. Thus two reviewers using the explicitly referenced Bash 3.2 environment versus a newer Bash reach different outcomes. The implied fix requires an executable compatibility check under Bash 3.2; prose about supported Bash versions would remain L3.
**Layer of the implied fix:** L2
**Anchor:** “Bash 3.2 ships on this machine” / `declare -A PAGE_SOURCE=()`

### Cross-cutting
**Verdict:** no finding
**Failure:** No scoring categories or pass/fail gates exist to duplicate. The greatest reviewer divergence is in `tools/verify-quotes.sh`: one environment completes with exit 0, 2, 3, or 4, while Bash 3.2 fails before a trustworthy verdict. The artifact needed to state and enforce its minimum Bash version, especially because it simultaneously cites Bash 3.2 compatibility and uses unsupported syntax.
**Layer of the implied fix:** n/a
**Anchor:** n/a


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

→ Read tools/verify-quote-checker.sh
### Header & registered limitation (lines 1–43)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The "REGISTERED LIMITATION" block (lines 33–40) is honest: it states the chrome-inclusion limitation, and it says it was *disputed* rather than fixed, with a reason. Nothing here invites divergent handling.

### Argument parsing & manifest resolution (lines 45–62)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`--manifest` missing/unreadable → 4, manifest resolved before the `cd`, and the `cd` carries `|| exit 4`. Sound.

### Manifest parsing — kinds, keys, values (lines 76–125)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The key-grammar refusal (lines 94–99) and tab-in-value refusal (lines 104–108) are runtime rejections that execute and exit 4 — they are L2 controls, correctly labelled "not a drift result." The malformed-line check (line 81) correctly catches the two-field and no-tab cases.

### Empty-manifest and undeclared-key guards (lines 131–145)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The "nothing to check must not exit 0" guard and the undeclared-page-key membership test are both correct, and the Bash-3.2 note here is the *reason* the next finding exists.

### `strip` (html→text) (lines 152–159)
**Verdict:** finding
**Failure:** The whitespace normalization is applied to only one side of the comparison. `strip` collapses the page to single spaces (`re.sub(r"\s+"," ", …)`), but the manifest quote is matched raw with `grep -qF -- "$quote"`. A manifest line `quote<TAB>p1<TAB>And the  second sentence is here.` (two interior spaces, as a human copying from a PDF or fixed-width layout might produce) yields ABSENT at exit 2 — a false documentation-drift headline — against a page that carries exactly "And the second sentence is here.", because the page is collapsed to one space and the quote is not. Nothing rejects a multi-space quote the way the tab-in-value refusal rejects a tab, so a transcribing artifact is reported as drift. Two reviewers diverge on whether a double-spaced quote "appears on the page": one reads the strip collapse and expects it to match, the other reads `grep -F` literally.
**Layer of the implied fix:** L2 (normalize the quote the same way the page is normalized, or reject quotes containing interior multi-space before matching — either would execute and remove the asymmetry; as written it is L3, a sentence the author has to remember to single-space every quote).
**Anchor:** `sys.stdout.write(re.sub(r"\s+"," ",html.unescape(re.sub(r"<[^>]+>"," ",t))))` paired with `grep -qF -- "$quote" "$TMP/$key.txt"`

### Fetch / cache / fixture loop (lines 161–198)
**Verdict:** finding
**Failure:** The script is internally contradictory about which Bash it targets. The undeclared-key guard (lines 137–138) explicitly says "Bash 3.2 ships on this machine, so this is a string membership test and not an associative array," yet the same script uses `declare -A PAGE_SOURCE=()` (line 161), `PAGE_SOURCE["$key"]="$SOURCE"` (197), `"${PAGE_SOURCE[$key]}"` (204), and `"${!PAGE_SOURCE[@]}"` (215) — all Bash 4+/4.3+ associative-array features. Under `#!/usr/bin/env bash` resolving to a stock-macOS `/bin/bash` (3.2, no Homebrew bash earlier in PATH), `declare -A` fails, `PAGE_SOURCE["$key"]=` writes to a numeric index or errors, and the provenance feature — the entire defect-(4)/case-U fix — silently stops working: FOUND/ABSENT lines print an empty source tag `[p1:]` and the `sources=` summary prints a single bogus entry, while the found/absent verdict stays correct. The checker's case U asserts `sources=p1=fixture` and would fail only on Bash 3.2, passing on Bash 4+, so the suite's own provenance proof is interpreter-dependent. Two reviewers diverge: one trusts the line-137 comment and flags the assoc array, the other assumes `env bash` is modern.
**Layer of the implied fix:** L1 (make the bad state unrepresentable — avoid Bash-4 constructs entirely, consistent with the line-137 decision — or an L2 version guard that executes and exits before any assoc-array use).
**Anchor:** `Bash 3.2 ships on this machine, so this is a string membership test and not an associative array.` (line 137) vs. `declare -A PAGE_SOURCE=()` (line 161)

### Matcher and summary (lines 200–218)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`grep -qF --` protects against leading-`-` quotes; `--` is present; the summary exit logic (0 vs 2) is correct. The summary's iteration order is non-deterministic (associative-array key order) but that does not affect the verdict — it is folded into the Bash-4 finding above, not a separate defect.

### Cross-cutting
- **Duplicate of a pass/fail gate?** No scoring category in this artifact duplicates a pass/fail gate — it *is* a pass/fail gate (exit codes), not a scoring rubric. The closest thing to a duplicated signal is the `sources=` summary re-stating per-line provenance, which is reporting, not gating.
- **Most divergent section:** the fetch/cache/fixture loop's use of `declare -A` against the line-137 "Bash 3.2 ships on this machine" comment. Two reviewers will disagree on whether Bash 3.2 is a supported interpreter by roughly the full weight of the provenance feature — one treats case U as portable, the other treats it as Bash-4-only.
- **What it did not say:** it never states which Bash major version the script actually *requires*, despite making a version-specific choice in one place (line 137) and a contradictory version-specific choice in another (line 161). The script needed a single, named interpreter target — "Bash 4+" or "Bash 3.2-compatible" — and every construct held to it.
