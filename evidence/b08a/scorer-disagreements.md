# The three scorer disagreements, resolved at the diff — §4 step 7's last clause

> *"Where the harnesses disagree, go to the diff and say which fact was wrong."* — §4 step 7

`Adjudicated by Opus 5 (claude-opus-5), autonomous, 2026-09-25.` **No sheet is edited and no registered
number is changed.** Decision C makes codex the registered scorer and opencode the second reader and **not a
vote**, so `evidence/b08a/sheets-codex.tsv` remains the source of E-020's numbers. What follows is the
required statement of which fact was wrong, and it does not all go one way.

## The comparison

**30 measured cells** (`architecture-consistency`, `maintainability`, `test-quality` × 10 gate-passing
runs; `change-focus` is unmeasured and excluded). **27 exact.** `maintainability` agrees 10 of 10 at 0 and
`test-quality` 10 of 10 at 1. **All three disagreements are on `architecture-consistency`, all on treated
runs, and all are codex-lower** — which looked systematic until each was taken to the code.

Four of the ten second-reader calls first returned **header-only** artifacts (exit 2, zero categories) — a
stall, not a finding (§6). Each was retried **once**, all four retries returned four categories, and **both
files are kept**.

## The discriminating fact is one line, and it is the same line in all three cases

**Does a repository save persist the recomputed fulfilment, or null it?** Anchor 0 (ii) fires when an
order-side fulfilment value *"is WRITTEN on a path that changes what it should be"*, and names the
quantity-amendment path as *"a FOURTH write site"* — adding, in its own words, that *"a copy written at only
some of them is this anchor, not the residual."*

| run | codex (registered) | opencode (second reader) | **the facts** | which fact was wrong |
|---|---|---|---|---|
| `53af3571` | **0** | **1** | **1** | **codex.** `order/OrderRepository.kt:17` is `store[order.orderId] = order.copy(fulfilment = null)` — **every save strips the field.** So there is no write site at all: not in the shipment package, not at the amendment path. Anchor 0 cannot fire. Anchor 2 (ii) still fails because `Order.kt:17` declares the field, so the value is the residual, **1** |
| `e3ca68c8` | **0** | 1 | **0** | **opencode.** `order/OrderController.kt:167-170` re-derives fulfilment against the new quantity **and saves it**. That is exactly the fourth write site anchor 0 (ii) names, so anchor 0 fires. The objection "but the shipment package never writes it" is the one the anchor's own sentence forecloses |
| `275d4cac` | **0** | 1 | **0** | **opencode.** Same line, same fact: `order/OrderController.kt:157-159` persists the re-derived value |

**The registered scorer is right on two of the three and wrong on one.** Together with the hand re-read —
`be4a6a94`, where the hand reading, codex and the second reader all say **1** — **codex is correct on 3 of
the 4 cells that have been independently checked.** That is the concordance statement this stop can make,
and it is `n = 4`, so it is true of those four cells and is not a property of the harness.

## What it does to P1, and P1 is refuted under every reading

| reading | treated median (n = 7) | control median (n = 3) |
|---|---|---|
| **codex, the registered scorer — the number of record** | **0** — `[0,0,0,0,1,1,1]` | **0** — `[0,0,1]` |
| second reader alone | 1 — `[0,1,1,1,1,1,1]` | 0 — `[0,0,1]` |
| **adjudicated at the diff** (53af3571 → 1, e3ca68c8 → 0, 275d4cac → 0) | **1** — `[0,0,0,1,1,1,1]` | **0** — `[0,0,1]` |
| **P1 predicted** | **2** | 0 |

**P1 is refuted under all three.** The registered number is 0 against 0 and stays 0 against 0; the most
favourable reading available reaches 1 against 0, which is still a full step short of the registered
prediction, on a control arm of `n = 3`. **The verdict on the registered outcome does not depend on which
harness is believed**, and that is worth more than either number alone.

## And the two instruments are measuring different things again

`275d4cac` is **RIGHT** under the shape rule and **anchor 0** under the rubric, with no contradiction: the
shape rule asks whether a **read path** trusts a stored copy (all three recompute — RIGHT), and anchor 0 (ii)
asks whether a **write site** persists one (the amendment path does — 0). Both instruments are correct on
their own terms about the same code. This is the third place in this stop where two instruments diverge
because they were built to ask different questions, and it is the reason the exit gate has to name which
question it is answering.
