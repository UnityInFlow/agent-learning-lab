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
#   - a path must carry the same PERMISSION BITS in both arms       (§4a round 3, 2/2 — git
#     records the mode, so `chmod +x` on one arm is a second difference the setup commits carry
#     while a byte comparison stays green)
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
    # CRLF is normalised for the FRONTMATTER SCAN ONLY, so a valid CRLF file is not reported
    # as a whole-file body difference (§4a round 3). The body comparison below still runs on
    # the ORIGINAL bytes, so a genuine line-ending difference between the arms is still a
    # difference — which is the point.
    probe = raw.replace(b"\r\n", b"\n")
    if not probe.startswith(b"---\n"):
        return [], raw
    end = probe.find(b"\n---\n", 3)
    if end == -1:
        return [], raw
    head = probe[4:end + 1].decode("utf-8", "replace")
    # Body is taken from the original bytes by matching the same marker there.
    real_end = raw.find(b"---", raw.find(b"---") + 3)
    body_start = raw.find(b"\n", real_end) + 1
    return head.splitlines(), raw[body_start:]

def key_of(line):
    return line.split(":", 1)[0].strip() if ":" in line else line.strip()

def frontmatter_class(rel):
    """Which frontmatter-bearing class this path is, or None for an opaque file.

    ADDED 2026-09-04 at spine stop 9. Until then this script recognised SKILL.md and nothing
    else, so an agent overlay -- `.claude/agents/*.md`, the customization class Phase 4A is
    about -- fell into the opaque branch and was reported as `non-skill file differs`, exit 2,
    *whether or not the declared key was the one that differed*. It refused a correct parity
    claim and an incorrect one identically, which makes it unusable as a control for this class
    rather than wrong about it. It failed CLOSED, which is why this is a gap and not a defect.

    The list is deliberately an ALLOWLIST OF PATHS, not "any file starting with ---". Sniffing
    for a leading `---` would silently promote arbitrary files into the frontmatter branch,
    where a difference can be EXCUSED by --allow-differ; an unrecognised file must keep
    failing on any byte difference. This project has now paid four times for a classifier whose
    default bucket was the permissive one (tools/skill-activation.sh, three rounds; the
    runner's contamination guard, once). The default here stays `None`.
    """
    base = os.path.basename(rel)
    parts = rel.replace(os.sep, "/").split("/")
    if base == "SKILL.md":
        return "SKILL.md"
    if ".claude" in parts and "agents" in parts and base.endswith(".md"):
        return "agent"
    if ".github" in parts and "agents" in parts and base.endswith(".agent.md"):
        return "agent"
    return None

fa, fb = rel_files(A), rel_files(B)
problems = []
if fa != fb:
    for p in sorted(fa - fb):
        problems.append(f"only in {A}: {p}")
    for p in sorted(fb - fa):
        problems.append(f"only in {B}: {p}")

declared_seen = set()
unapplied = []
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
    ma, mb = os.stat(pa).st_mode & 0o777, os.stat(pb).st_mode & 0o777
    if ma != mb:
        problems.append(f"file mode differs: {rel} ({ma:04o} vs {mb:04o})")

    ra = open(pa, "rb").read()
    rb = open(pb, "rb").read()
    kind = frontmatter_class(rel)
    if kind is None:
        if ra != rb:
            problems.append(f"non-skill file differs: {rel}")
        continue

    lines_a, bodya = split_front(ra)
    lines_b, bodyb = split_front(rb)
    if bodya != bodyb:
        ha = hashlib.sha256(bodya).hexdigest()[:16]
        hb = hashlib.sha256(bodyb).hexdigest()[:16]
        problems.append(f"{kind} BODY differs: {rel} ({ha} vs {hb})")
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
    # §4a round 3: `declared_seen` was global, so with TWO SKILL.md files a difference in the
    # first satisfied the allowance for both and an UNAPPLIED treatment in the second passed
    # silently. Every SKILL.md must carry every declared difference itself.
    missing_here = allow - here
    if missing_here:
        unapplied.append((rel, sorted(missing_here)))

if problems:
    print("check-overlay-parity: the arms differ by more than the declared variable:",
          file=sys.stderr)
    for p in problems:
        print(f"  {p}", file=sys.stderr)
    sys.exit(2)

# A real difference outranks a missing one: exit 2 has already fired above if there was one.
# Exit 3 is reserved for "every declared difference is absent SOMEWHERE", which is the case
# that looks like a working experiment from every other angle.
if unapplied:
    print("check-overlay-parity: declared-differ key(s) are IDENTICAL in both arms:",
          file=sys.stderr)
    for rel, keys in unapplied:
        print(f"  {rel}: {', '.join(keys)}", file=sys.stderr)
    print("  The treatment is not applied there. This looks like a working experiment from "
          "every other angle.", file=sys.stderr)
    sys.exit(3)

print(f"check-overlay-parity: parity holds; the arms differ only in {', '.join(sorted(allow))}")
sys.exit(0)
PY
