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
#   - a path must be a symlink in both arms or in neither, and links must point at the same
#     place — FILE links and DIRECTORY links alike  (§4a round 1 at 1/2, round 2 at 2/2)
#   - every non-SKILL.md file must be byte-identical                 (a smuggled second change)
#   - every SKILL.md BODY below the frontmatter must be byte-identical
#   - SKILL.md frontmatter may differ ONLY in lines whose key is named by --allow-differ
#
# FRONTMATTER IS COMPARED AS RAW LINES, NOT AS A PARSED DICT, and that is a correction the
# §4a gate forced. A dict drops every line without a colon — so a `# comment` carrying a
# real difference vanished — and it silently keeps only the LAST of a duplicated key, so an
# overlay with two `description:` lines compared equal on the one that happened to win. A
# duplicated key is now refused outright rather than resolved, because "which one does the
# runtime read" is a question this script has no business guessing.
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
import os, sys, hashlib, collections

A, B = os.environ["A"], os.environ["B"]
allow = set(os.environ.get("ALLOW", "").split())

def rel_files(root):
    # followlinks=False is load-bearing: a symlinked SKILL.md with identical bytes would
    # otherwise read as parity while the two overlays install different things. Links are
    # compared as links below.
    #
    # DIRECTORY symlinks have to be collected explicitly. os.walk puts them in `dirnames`,
    # not `names`, and does not descend into them with followlinks=False — so an earlier
    # version of this function, which read only `names`, could not see them at all. Two
    # overlays whose `.claude/skills` pointed at different directories compared as two
    # EMPTY overlays. §4a round 2, found at 2/2. A link is recorded as an entry in its own
    # right and its target is compared below; nothing is read through it.
    out = set()
    for dirpath, dirnames, names in os.walk(root):
        for d in list(dirnames):
            full = os.path.join(dirpath, d)
            if os.path.islink(full):
                out.add(os.path.relpath(full, root))
                dirnames.remove(d)
        for n in names:
            out.add(os.path.relpath(os.path.join(dirpath, n), root))
    return out

def split_front(raw):
    """Return (frontmatter_raw_lines, body_bytes). No frontmatter -> ([], whole file)."""
    if not raw.startswith(b"---\n"):
        return [], raw
    end = raw.find(b"\n---\n", 3)
    if end == -1:
        return [], raw
    head = raw[4:end + 1].decode("utf-8", "replace")
    return head.splitlines(), raw[end + 5:]

def key_of(line):
    return line.split(":", 1)[0].strip() if ":" in line else line.strip()

fa, fb = rel_files(A), rel_files(B)
problems = []
if fa != fb:
    for p in sorted(fa - fb):
        problems.append(f"only in {A}: {p}")
    for p in sorted(fb - fa):
        problems.append(f"only in {B}: {p}")

declared_seen = set()
for rel in sorted(fa & fb):
    pa, pb = os.path.join(A, rel), os.path.join(B, rel)

    # A symlink and a regular file with the same bytes are not the same overlay. §4a round 1.
    la, lb = os.path.islink(pa), os.path.islink(pb)
    if la != lb:
        problems.append(f"symlink on one side only: {rel} (link in {A if la else B})")
        continue
    if la and lb:
        ta, tb = os.readlink(pa), os.readlink(pb)
        if ta != tb:
            problems.append(f"symlink targets differ: {rel} ({ta} vs {tb})")
        continue

    if os.path.isdir(pa) or os.path.isdir(pb):
        problems.append(f"directory where a file was expected: {rel}")
        continue
    ra = open(pa, "rb").read()
    rb = open(pb, "rb").read()
    if os.path.basename(rel) != "SKILL.md":
        if ra != rb:
            problems.append(f"non-skill file differs: {rel}")
        continue

    lines_a, bodya = split_front(ra)
    lines_b, bodyb = split_front(rb)
    if bodya != bodyb:
        ha = hashlib.sha256(bodya).hexdigest()[:16]
        hb = hashlib.sha256(bodyb).hexdigest()[:16]
        problems.append(f"SKILL.md BODY differs: {rel} ({ha} vs {hb})")
    else:
        print(f"body identical: {rel} sha256:{hashlib.sha256(bodya).hexdigest()[:16]}")

    # A duplicated key is refused, not resolved. Deciding which of two `description:` lines
    # the runtime honours is a guess, and a guess here is exactly the kind of "probably the
    # same" this script exists to refuse.
    for side, lines in ((A, lines_a), (B, lines_b)):
        seen = collections.Counter(key_of(x) for x in lines if ":" in x)
        for k, c in sorted(seen.items()):
            if c > 1:
                problems.append(f"frontmatter key '{k}' appears {c} times in {side}: {rel}")

    # Raw-line comparison. Multiset difference, so a line moved is not a difference but a
    # line changed, added or removed is — including comment lines, which a dict drops.
    ca, cb = collections.Counter(lines_a), collections.Counter(lines_b)
    here = set()
    for line in sorted((ca - cb) + (cb - ca)):
        k = key_of(line)
        if k in allow:
            here.add(k)
            declared_seen.add(k)
        else:
            problems.append(f"frontmatter line differs and its key was not declared: "
                            f"{rel}: {line.strip()!r}")
    for k in sorted(here):
        print(f"declared difference: {rel} frontmatter '{k}'")

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
