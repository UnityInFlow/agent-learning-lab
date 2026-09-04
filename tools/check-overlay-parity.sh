#!/usr/bin/env bash
# check-overlay-parity.sh — do two customization overlays differ ONLY where they are allowed to?
#
#   ./tools/check-overlay-parity.sh --allow-differ description <overlay-a> <overlay-b>
#
# WHY THIS EXISTS. E-004's independent variable is one line: the `description:` in a skill's
# frontmatter. Its workbook asserted the bodies were byte-identical by pasting a `shasum` of
# each into a table by hand, once, before the runs. The §4a gate's third round called that
# out and was right: NOTHING EXECUTED. A later edit to either overlay — a fixed typo, a
# reflowed line, an extra convention added to the arm someone happened to be looking at —
# would move a second variable and every check the experiment had would still pass, because
# the check was a sentence about a sha computed on a day that had already gone.
#
# This is the executing version. It compares two overlay directories and fails closed on any
# difference the caller did not declare:
#
#   - the same set of relative paths must exist in both              (a file added to one arm)
#   - every non-SKILL.md file must be byte-identical                 (a smuggled second change)
#   - every SKILL.md BODY below the frontmatter must be byte-identical
#   - SKILL.md frontmatter may differ ONLY in the keys named by --allow-differ
#
# The body comparison is on bytes below the second `---`, so a trailing-whitespace change is
# a difference. That is deliberate: this is the file that decides whether an experiment
# measured one variable or two, and "probably the same" is what it exists to refuse.
#
# Exit codes:
#   0  parity holds under the declared allowance
#   2  a difference outside the allowance — the arms differ by more than one thing
#   3  a declared-differ key is IDENTICAL in both, so the treatment is not applied at all
#   1  usage error
#
# Exit 3 is not pedantry. An experiment whose treatment file was copied and never edited
# looks exactly like a working one from every other angle, and it is the failure Phase 1
# spent twenty runs and ~$4 on.

set -euo pipefail

ALLOW=()
usage() {
  cat >&2 <<'EOF'
usage: check-overlay-parity.sh [--allow-differ KEY]... <overlay-a> <overlay-b>

Exit codes:
  0  parity holds
  2  a difference outside the declared allowance
  3  a declared-differ key is identical in both arms (treatment not applied)
  1  usage error
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --allow-differ) [[ $# -ge 2 ]] || usage; ALLOW+=("$2"); shift 2 ;;
    -h|--help) usage ;;
    *) break ;;
  esac
done
[[ $# -eq 2 ]] || usage
A="$1"; B="$2"
[[ -d "$A" ]] || { echo "check-overlay-parity: not a directory: $A" >&2; exit 1; }
[[ -d "$B" ]] || { echo "check-overlay-parity: not a directory: $B" >&2; exit 1; }

A="$A" B="$B" ALLOW="${ALLOW[*]:-}" python3 <<'PY'
import os, sys, hashlib

A, B = os.environ["A"], os.environ["B"]
allow = set(os.environ.get("ALLOW", "").split())

def rel_files(root):
    out = set()
    for dirpath, _, names in os.walk(root):
        for n in names:
            out.add(os.path.relpath(os.path.join(dirpath, n), root))
    return out

def split_front(raw):
    """Return (frontmatter_dict, body_bytes). No frontmatter -> ({}, whole file)."""
    if not raw.startswith(b"---\n"):
        return {}, raw
    end = raw.find(b"\n---\n", 3)
    if end == -1:
        return {}, raw
    head = raw[4:end + 1].decode("utf-8", "replace")
    body = raw[end + 5:]
    fm = {}
    for line in head.splitlines():
        if ":" in line:
            k, v = line.split(":", 1)
            fm[k.strip()] = v.strip()
    return fm, body

fa, fb = rel_files(A), rel_files(B)
problems = []
if fa != fb:
    for p in sorted(fa - fb):
        problems.append(f"only in {A}: {p}")
    for p in sorted(fb - fa):
        problems.append(f"only in {B}: {p}")

declared_seen = set()
for rel in sorted(fa & fb):
    ra = open(os.path.join(A, rel), "rb").read()
    rb = open(os.path.join(B, rel), "rb").read()
    if os.path.basename(rel) != "SKILL.md":
        if ra != rb:
            problems.append(f"non-skill file differs: {rel}")
        continue
    fma, bodya = split_front(ra)
    fmb, bodyb = split_front(rb)
    if bodya != bodyb:
        ha = hashlib.sha256(bodya).hexdigest()[:16]
        hb = hashlib.sha256(bodyb).hexdigest()[:16]
        problems.append(f"SKILL.md BODY differs: {rel} ({ha} vs {hb})")
    else:
        print(f"body identical: {rel} sha256:{hashlib.sha256(bodya).hexdigest()[:16]}")
    for k in sorted(set(fma) | set(fmb)):
        va, vb = fma.get(k), fmb.get(k)
        if va == vb:
            continue
        if k in allow:
            declared_seen.add(k)
            print(f"declared difference: {rel} frontmatter '{k}'")
        else:
            problems.append(f"frontmatter key '{k}' differs and was not declared: {rel}")

if problems:
    print("check-overlay-parity: the arms differ by more than the declared variable:",
          file=sys.stderr)
    for p in problems:
        print(f"  {p}", file=sys.stderr)
    sys.exit(2)

missing = allow - declared_seen
if missing:
    print("check-overlay-parity: declared-differ key(s) are IDENTICAL in both arms: "
          + ", ".join(sorted(missing)), file=sys.stderr)
    print("  The treatment is not applied. This looks like a working experiment from every "
          "other angle.", file=sys.stderr)
    sys.exit(3)

print(f"check-overlay-parity: parity holds; the arms differ only in {', '.join(sorted(allow))}")
sys.exit(0)
PY
