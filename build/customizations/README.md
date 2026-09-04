# Customization overlays — one directory per version, installed by the runner

`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-03.` The itinerary pre-made the shape
of this decision and left the location to B3. This is the location, and the reason is below.

```
build/customizations/<version>/        # everything the runner copies into the worktree root
```

Installed with `make run-benchmark CUSTOMIZATION=../agent-learning-lab/build/customizations/<version>`,
which becomes `run-agent.sh --customization`. The runner copies the directory's *contents* to
the root of the agent's repository, commits them as a setup commit **before** the agent starts,
and moves the evaluation baseline to that commit — so the overlay is starting state and the
scope guard never blames the agent for a file the harness wrote.

## Why here and not in the observatory or the benchmarks repo

The overlay is **the treatment**, and a treatment is evidence. It belongs in the workbook repo
next to the experiment that registers it and the workbook that reports it, for the same reason
predictions live here: a stranger reading `experiments/E-003-*.md` must be able to open the
exact bytes the model was given without cloning a second repository. The observatory is the
instrument and must not carry the thing being measured; the benchmarks repo is the subject and
would leak the treatment into every run of every experiment, customized or not.

## The rule that makes a version comparable

**A version that has been measured is never edited. A change is a new version.**

Not a convention — the run records point at it. `customization.instructionsHash` is a sha256 of
the instruction file *as installed in the worktree*, recorded per run. Editing
`instructions-v0.1/CLAUDE.md` after runs exist silently splits one experiment key across two
treatments that the record still calls one, and the hash is the only thing that would ever have
shown it. If a rule must change, create `instructions-v0.2/` and register a new comparison.

## What the runner will refuse

It reads `CLAUDE.md` for `claude` and `AGENTS.md` for `codex` / `copilot`, and it **dies** if a
customization installs an instruction file the runtime does not read. That guard exists because
`EXP-BE002-AGENTSMD-V3` installed `AGENTS.md` for Claude Code, hashed it, recorded it on all ten
treatment runs, and compared baseline against baseline. Twenty runs and about $4 to learn that
installing a file proves nothing about whether a model reads it.

**The guard is L2 for the file name and L3 for everything else about the content.** It proves
the runtime reads that filename. It cannot prove a rule inside it changed anything, which is
what the experiment is for.

## `skill-probe-diagnostic/` is not an arm

Added 2026-09-04 for E-004's preflight. It is a **diagnostic overlay**, not a registered arm and
not a version: its description was written to be maximally imperative (*"REQUIRED … You must load
this skill before editing ShipmentController"*) in order to test whether a skill could reach the
model at all. It was used on run `d8be2b5f-9a88-4aa6-8aba-27fffe4de917` under
`EXP-P3-PREFLIGHT`, which is a preflight key and can never join an `n`.

It is kept because it is the evidence for the negative result in
[`evidence/p03/skill-delivery-probe-20260904T072000Z.md`](../../evidence/p03/skill-delivery-probe-20260904T072000Z.md).
**Do not add it to an experiment.** The measured arms are `skill-v0.1` and
`skill-v0.1-misdescribed`, whose bodies are byte-identical and which differ only in `description`.

## `skill-v0.2` and `skill-v0.2-misdescribed` — the same bytes, a different path

Added 2026-09-04. **The `SKILL.md` files are byte-identical to their `v0.1` counterparts**;
what changed is where the overlay installs them:

| version | install path | why |
|---|---|---|
| `skill-v0.1{,-misdescribed}` | `sample-service/.claude/skills/…` | commits without help, but a nested skill is **not** in the `/name` registry at session start |
| `skill-v0.2{,-misdescribed}` | `.claude/skills/…` (worktree root) | registered at session start, so delivery can be proved **without** relying on the activation the experiment is trying to measure |

**Why a new version rather than an edit.** The rule above is that a version which has been
measured is never edited. `v0.1` has no measured runs, but it *was* installed on preflight run
`c090f67e-0003-4c35-8ccf-9572b2584462`, and moving its directory would leave that run's overlay
unreproducible from this repository. `v0.1` therefore stays exactly where it is.

**Why the root path is worth the runner change it needed.** Two reasons, and the first is the
one the §4a gate forced:

1. **The misdescribed arm's delivery proof would otherwise be circular.** Its prediction is that
   the skill does *not* load. At a nested path nothing but an activation can show the skill was
   available to that run, so "it did not load" and "it was never there" are the same observation.
   At the root path `claude -p "/shipment-service-conventions"` in the kept worktree answers the
   question independently of description-driven selection.
2. It removes the confound the nested path forced onto the one-arm prediction, where a miss was a
   joint failure of *the description matched* and *the agent reached `sample-service/` in time*.

The root path is ignored by the benchmarks repo (`.gitignore:19` is `.claude/*`), so the runner
force-adds the overlay's own paths into the setup commit — a disclosed harness move, recorded in
`agent-observatory/runner/run-agent.sh` and proved by `runner/verify-skill-delivery.sh` check F.

**Parity between the two arms is now asserted by something that executes**, not by a sha pasted
into a table once:

```
./tools/check-overlay-parity.sh --allow-differ description \
  build/customizations/skill-v0.2 build/customizations/skill-v0.2-misdescribed
→ body identical: .claude/skills/shipment-service-conventions/SKILL.md sha256:d10a2c3988be520e
→ declared difference: … frontmatter 'description'
→ parity holds; the arms differ only in description
```

It exits 2 on any undeclared difference and **3 when the two arms are identical**, because a
treatment that was never applied looks like a working experiment from every other angle.

Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-04
