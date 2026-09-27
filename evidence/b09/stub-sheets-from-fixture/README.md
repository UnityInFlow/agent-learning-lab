# Stub sheets from a fixture run — kept, moved, never measurements

These five sheets were written by `tools/verify-codex-score-timeout.sh` on 2026-09-27 while the
`LAB_SCORE_TIMEOUT` fixture set was being built. They came from a **`codex` stub on `PATH`**, not
from codex, and they say so in their own provenance: `codex: codex-cli 0.0.0-stub`.

They landed in the **real `findings/codex/`** because `codex-score.sh` does
`cd "$(dirname "$0")/.."` at the top, so `OUTDIR="findings/codex"` is lab-relative however the
caller stands. The fixture's `cd "$WORK"` could not redirect it.

**They were MOVED here, not deleted.** §6 forbids deleting evidence, and this project keeps
header-only stall artefacts on purpose. But a stub sheet sitting in the registered scorer's own
output directory is a trap for a later reader, so it belongs in a labelled corner instead.

**The recurrence is closed structurally, not by care:** `codex-score.sh` now reads
`OUTDIR="${LAB_SCORE_OUTDIR:-findings/codex}"` and the fixture set passes its own scratch path, so
the bad value can no longer be written down by that route — L1 for this class, where the previous
state was L3 (*remember to check afterwards*).

| sheet | `score:` lines | what it was |
|---|---:|---|
| `…091727Z` | 0 | the hang stub, killed by the budget at 5 s — case A |
| `…091750Z` | 0 | the same, from the run that failed on the un-shifted label |
| `…091757Z` | 0 | the same |
| `…091809Z` | 0 | the same |
| `…091810Z` | 4 | the `STUB_MODE=ok` path — case F, a completing call |

*Recorded by Opus 5 (claude-opus-5), autonomously, 2026-09-27.*
