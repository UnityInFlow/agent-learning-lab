## What this changes

<!-- One paragraph. -->

## Which spine position

<!-- e.g. "B1, spine 3" or "Phase 5A, spine 14". If none, say so. -->

## Verification

```
./tools/check-links.sh    →
```

## If this closes a phase

A phase is not done when the file exists. Tick only what is true.

- [ ] The mechanism can be explained — what changed in the agent, not what file was written
- [ ] It was **proven** to load, not assumed. Placing a file is not delivering a treatment
- [ ] Its effect was measured against a baseline
- [ ] It was deliberately broken and the failure mode named
- [ ] Predictions were written down **before** the run, and the ones that were wrong are
      recorded as wrong rather than quietly revised

## Guardrail layer

Which layer does this actually operate at?

- [ ] **L1** — structural. The bad state cannot be represented
- [ ] **L2** — enforced. Something executes and rejects it
- [ ] **L3** — guidance. Words a human reads and chooses to follow

<!-- Most customization is L3. Saying so is not a criticism of the change; claiming L2 for
     something that only reads well is the problem. -->

## Anything a reviewer should disbelieve

<!-- Especially any number that flattered the result. Two of this project's seven harness
     bugs survived review because they made things look good. -->
