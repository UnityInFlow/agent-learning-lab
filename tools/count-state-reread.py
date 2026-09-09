#!/usr/bin/env python3
"""Count runs whose test file re-reads persisted state through a SEPARATE get(...) after a
mutating confirm call. This is E-012's P3 -- the behaviour underneath the rubric's verdict, not
the verdict itself.

WHY THE PATTERN IS WHAT IT IS. The first version matched only a literal `/confirm` on the call
line. Run a1af25c1 extracts a helper --

    private fun confirmShipment(shipmentId: String) = post("/shipments/$shipmentId/confirm")

-- so its call sites read `confirmShipment("S-4")` and the literal appears only at the helper's
definition. That version counted the run as `no` while the registered sheet scored it 2, and the
file settled it: `get("/shipments/S-4")` at :101 follows `confirmShipment("S-4")` at :95. The
counter was wrong and the sheet was right. Helper call sites are matched here.

Usage: count-state-reread.py <manifest.tsv> <relative/path/to/TestFile.kt>
Exit 0 always; the counts are the output.
"""
import re, sys

def main() -> int:
    manifest, rel = sys.argv[1], sys.argv[2]
    rows = [l.rstrip("\n").split("\t") for l in open(manifest) if l[:1].isdigit()]
    # a mutating call: the literal route, OR a helper whose name contains confirm/cancel and is
    # invoked (not defined -- `fun ` on the line means it is the definition).
    mut = re.compile(r'/(?:confirm|cancel)\b|(?<!fun )\b(?:confirmShipment|cancelOrder|confirm|cancel)\s*\(\s*"')
    get = re.compile(r'get\("/[a-z]+/[^"]+"\)')
    out: dict[str, list[tuple[str, str]]] = {}
    for row in rows:
        seq, arm, _rid, _ex, wt = row[0], row[1], row[2], row[3], row[4]
        try:
            lines = open(f"{wt}/{rel}").read().split("\n")
        except OSError:
            out.setdefault(arm, []).append((seq, "NOFILE"))
            continue
        muts = [i for i, l in enumerate(lines) if mut.search(l) and " fun " not in l]
        gets = [i for i, l in enumerate(lines) if get.search(l)]
        hit = any(any(0 < g - m <= 12 for m in muts) for g in gets)
        out.setdefault(arm, []).append((seq, "YES" if hit else "no"))
    for arm in ("treated", "control"):
        v = out.get(arm, [])
        yes = sum(1 for _, h in v if h == "YES")
        print(f"{arm}: " + " ".join(f"{s}:{h}" for s, h in v) + f"  -> {yes} of {len(v)}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
