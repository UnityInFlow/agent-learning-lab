# B7 — Deterministic verification and policies

**Track A first:** [Phase 5A](../05a-guardrails/) · **Layer 2 — real enforcement**
**Version:** **v1.0 closes here**
**Spine position:** 15 of 28 · after [Phase 5A](../05a-guardrails/) · before [Phase 5B](../05b-verification-selfhealing/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b7).
> Everything else is yours to fill.

---

## Goal

<!-- TODO. Note this is the first step that builds a real Layer 2 control.
     Everything in v1.0 before it was guidance. -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §10.11 scripts/verify.sh
     BUSINESS-REQUIREMENTS §10.10 policies/*.yaml
     BUSINESS-REQUIREMENTS FR-006 deterministic verification
     BUSINESS-REQUIREMENTS FR-012 policy enforcement
     BUSINESS-REQUIREMENTS Risk: hooks become difficult to maintain -->

### External — the technique

<!-- TODO: e.g. ArchUnit for architecture tests, Maven enforcer for
     dependency policy. Add to ../../SOURCES.md. -->

## Extract

<!-- TODO -->

## Build

**Build:** one verification entry point, and policy as code.

```bash
scripts/verify.sh          # compile · unit · integration · format · static analysis
                           # architecture tests · forbidden-change check
                           # stage-structured output, machine-readable exit code
```

```yaml
policies/protected-paths.yaml       policies/command-policy.yaml
policies/allowed-dependencies.yaml  policies/database-policy.yaml
```

**Do 5A.1 first — remove a capability before policing it.** Every hook you avoid writing is a
hook you never have to test, tune, or explain a false positive for.

## Predict before you run

<!-- TODO: predict the false-positive rate on legitimate commands before
     you measure it. The gate requires the number either way. -->

## Lab B7.1 — measure against B6, and close v1.0 against B2

<!-- TODO: two comparisons here. The step comparison (vs B6) and the
     version comparison (v1.0 vs the B2 baseline) — the first thing in
     this project that answers the business question end to end. -->

## Deliberate failure

<!-- TODO: commit an intentional violation of each policy and prove the
     check catches it. A policy never tested against a violation is a
     policy you are trusting, not enforcing. -->

## Exit gate

**From the build track:** one command, one exit code · intentional violations tested ·
false-positive rate measured on legitimate commands · policy events recorded.

**Plus, for this to count as a learned phase:**

<!-- TODO: v1.0 vs B2 — state the result even if it is unfavourable.
     §17's promotion rules apply from here on. -->

## Commit

<!-- TODO -->
