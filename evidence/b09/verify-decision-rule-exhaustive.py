#!/usr/bin/env python3
"""Prove that E-022's and E-023's decision rules reach a row for every possible result.

Both experiment files claim their rows are "exhaustive ... checked by enumeration before this
file was committed". This script IS that check, so the claim is L2 rather than L3.

The template's own warning is the reason it exists: *"Write them, then find the combination that
reaches no row — if one exists, the rule is broken and you will discover it while holding data
you cannot label."* E-003 shipped with a REJECT row that could never fire.

Exit 0  every combination reaches exactly one verdict row, and every verdict is reachable
Exit 1  at least one combination reaches no row  (the rule is broken)
Exit 2  a verdict row can never fire            (the rule has a dead row)

Run: python3 evidence/b09/verify-decision-rule-exhaustive.py
"""
import sys

BE003_VERDICTS = {"VOID", "KEEP", "INCONCLUSIVE-hist-only", "REJECT"}
BE004_VERDICTS = {"NOT-COMPUTED", "VOID", "KEEP", "INCONCLUSIVE-control-moved",
                  "INCONCLUSIVE-floor-only", "REJECT"}


def be003(M, H):
    """E-022 rows 0-3. M = treated anchor-2 count, H = runs with a non-empty router log."""
    if H <= 2:
        return "VOID"
    if M >= 8:
        return "KEEP"
    if M in (6, 7):
        return "INCONCLUSIVE-hist-only"
    if M <= 5:
        return "REJECT"
    return None


def be004(M, H, nt, nc, fisher_le_05):
    """E-023 rows 0-5. nt / nc = scored populations; fisher_le_05 = Fisher(M,C) <= 0.05."""
    if nt < 7 or nc < 7:
        return "NOT-COMPUTED"
    if H <= 2:
        return "VOID"
    if M >= 5:
        return "KEEP" if fisher_le_05 else "INCONCLUSIVE-control-moved"
    if M in (3, 4):
        return "INCONCLUSIVE-floor-only"
    if M <= 2:
        return "REJECT"
    return None


def main():
    gaps = []
    reached3, reached4 = set(), set()

    for M in range(0, 11):
        for H in range(0, 11):
            v = be003(M, H)
            if v is None:
                gaps.append(f"E-022  M={M} H={H}")
            else:
                reached3.add(v)

    for nt in range(0, 11):
        for nc in range(0, 11):
            for M in range(0, nt + 1):
                for H in range(0, nt + 1):
                    for f in (True, False):
                        v = be004(M, H, nt, nc, f)
                        if v is None:
                            gaps.append(f"E-023  nt={nt} nc={nc} M={M} H={H} fisher_le={f}")
                        else:
                            reached4.add(v)

    if gaps:
        print(f"BROKEN: {len(gaps)} combination(s) reach no row. First five:")
        for g in gaps[:5]:
            print("  " + g)
        return 1

    dead = (BE003_VERDICTS - reached3) | (BE004_VERDICTS - reached4)
    if dead:
        print("DEAD ROW(S): " + ", ".join(sorted(dead)) + " can never fire.")
        return 2

    print("E-022: 121 combinations, 0 gaps, verdicts reachable = "
          + ", ".join(sorted(reached3)))
    print("E-023: every (nt,nc,M,H,fisher) combination, 0 gaps, verdicts reachable = "
          + ", ".join(sorted(reached4)))
    print("Both rules are exhaustive and neither has a dead row.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
