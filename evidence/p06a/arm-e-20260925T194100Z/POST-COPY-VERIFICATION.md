# Arm E's null is not spurious — the post-copy probe was verified, by hand, on disk

`Recorded by Opus 5 (claude-opus-5), autonomously, 2026-09-25T20:16Z, at §4 step 13a.`

## Why this file exists

`findings/opencode/review-run-mcp-strict-above-e-20260925T200106Z.md` (L2, 1/1) found that
the driver's `sed` substitution of `__PROBE_SERVER_PATH__` **is never verified**, and that
*"silent template drift would yield a false DF5 confirmation."*

**The finding is correct and it is the one that matters most at this stop**, because **DF5 is a
negative result**: arm E concludes *the probe did not load*. If the `.mcp.json` had pointed at a
path that did not exist, the probe would not have loaded **for the wrong reason**, DF5 would have
"held" spuriously, and the stop's Decision — that `--strict-mcp-config` is L2 on both placements —
would rest on a broken instrument. That is this project's house failure mode exactly: a control
reporting success over a scope smaller than it claims.

The same reasoning does **not** apply to arms A, D, D2 and D3, whose results are *positive*: a
delivered tool is itself proof the server was reachable.

## The five checks, run against the throwaway tree after the arm completed

| # | Check | Result |
|---|---|---|
| 1 | Does `parent/.mcp.json` still contain the `__PROBE_SERVER_PATH__` placeholder? | **No** — substituted, no placeholder remains |
| 2 | Does the absolute path it names exist and is it non-empty? | **Yes** — `/tmp/stop18-mcp-strict-above-20260925T194100Z/probe_server.py`, 3.8 kB |
| 3 | **Does that exact post-copy file answer the MCP handshake?** Not the fixture — the file `claude` was pointed at. | **Yes** — `initialize` + `tools/list` piped into it return `probe_marker` |
| 4 | Is arm E's config identical in shape to arm D's, which delivered 5 of 5? | **Yes** — `diff` with the absolute path normalised is empty |
| 5 | Exactly one `result` record per stream? (the `jq … \| tail -1` finding) | **Yes** — 1 on each of the 5 streams |

Check 3 is the one that closes it. **The server arm E's `.mcp.json` points at is live and
answers**, so the absence of `mcp__stop18probe__` from all five `init` records is a property of
`--strict-mcp-config` and not of a broken probe.

## What is NOT closed by this file

The driver still does not perform check 1–3 **itself**, so a *future* invocation could drift
without anything noticing. The finding is accepted as a real design defect and the fix — asserting
the substitution and handshaking the post-copy file inside the driver — is **not applied here**,
because this driver produced a measured arm and §4 step 12 forbids rewriting evidence. Any later
step reusing this probe should add it before the first run rather than after.
