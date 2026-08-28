#!/usr/bin/env bash
# The line-level critic, run through a DIFFERENT HARNESS rather than a different model.
#
# `-P` in opencode-review.sh swaps the model inside one agent loop. This swaps the loop:
# codex has its own system prompt, its own tool set, its own idea of what a turn is. That is
# a stronger form of independence than a different model id, and it is the reason to pay for
# a second CLI at all.
#
#   ./tools/codex-critic.sh <out.md> <artifact> [more-artifacts...]
#
# Writes the SAME section format opencode-review.sh's critic produces, so a codex pass drops
# into the panel's recurrence table as one more family with no special case in the table.
#
# TWO CONTROLS THAT MAKE THE COMPARISON MEAN ANYTHING
#
# 1. SAME CONTRACT. The instructions are `.opencode/agent/lab-critic.md` itself, body and
#    all — not a paraphrase. If the two harnesses were given different words, a difference
#    in findings would be the prompt rather than the harness, and the whole point is lost.
#
# 2. SAME EVIDENCE. The artifact is INLINED into the prompt rather than left on disk for
#    codex to go and read. opencode attaches with -f; codex has no -f, and pointing it at a
#    path would hand it a filesystem the opencode critic never had. Inlining is what makes
#    the two evidence sets byte-identical.
#
# ISOLATION, WHICH THIS PROJECT ALREADY LEARNED THE HARD WAY ONCE. B2's note: without
# --isolate-user-settings "you are measuring ~21 local hooks, not the baseline". The same
# applies to a reviewer. --ignore-user-config, --ignore-rules and --ephemeral mean this run
# does not inherit the operator's config, execpolicy rules, or session history. -s read-only
# means the reviewer cannot write, which its contract forbids anyway — this is the L2 version
# of that wish.
#
# THE OUTPUT IS SCHEMA-CONSTRAINED, not requested. --output-schema forces the shape at the
# API rather than asking for it in prose. opencode's critic is asked politely for markdown
# and usually complies; this one cannot do otherwise. That is a real difference between the
# two families and it is registered rather than hidden.
#
# Exit 0 sections written · 1 usage/infrastructure · 2 output present but not the contract.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

# gpt-5.6-codex is refused for a ChatGPT-account login ("not supported when using Codex
# with a ChatGPT account"). gpt-5.6-sol is what this machine's config already selects.
MODEL="${LAB_CODEX_MODEL:-gpt-5.6-sol}"
AGENT=".opencode/agent/lab-critic.md"
SCHEMA="tools/schemas/critic-findings.schema.json"

[ $# -ge 2 ] || { echo "usage: $0 <out.md> <artifact> [more...]" >&2; exit 1; }
out="$1"; shift

[ -r "$AGENT" ]  || { echo "cannot read $AGENT" >&2; exit 1; }
[ -r "$SCHEMA" ] || { echo "cannot read $SCHEMA" >&2; exit 1; }
for f in "$@"; do [ -r "$f" ] || { echo "cannot read artifact: $f" >&2; exit 1; }; done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# The contract, verbatim, minus the YAML frontmatter opencode uses for tool wiring — codex
# has no use for it and it would read as instructions.
#
# awk, not sed: the BSD sed on macOS rejects `1{/^---$/!q}; 1,/^---$/d` and — this is the
# part worth remembering — it FAILED OPEN. The error went to stderr, the redirect created an
# empty file, and the script sent codex a prompt with no contract in it at all. The reviewer
# would have reviewed with no instructions and returned something plausible. The guard below
# is why that cannot happen twice.
awk '
  NR == 1 && $0 == "---" { infm = 1; next }
  infm && $0 == "---"    { infm = 0; next }
  infm                   { next }
  { print }
' "$AGENT" > "$tmp/contract.md"

# An empty contract is not a degraded review, it is a different experiment.
if [ ! -s "$tmp/contract.md" ]; then
  echo "FATAL: the critic contract came out empty after stripping frontmatter." >&2
  echo "Refusing to review without instructions — the result would look like a review." >&2
  exit 1
fi

{
  cat "$tmp/contract.md"
  echo
  echo "## The artifact(s) under review"
  echo
  echo "This is the COMPLETE evidence set. Do not look for other files; work only from what"
  echo "is below. Return one entry per section of the artifact, in the artifact's own order."
  for f in "$@"; do
    echo
    echo "### FILE: $f"
    echo '```'
    cat "$f"
    echo '```'
  done
} > "$tmp/prompt.md"

echo "codex critic — $(basename "${1:-}") with $MODEL ..." >&2

codex exec \
  --model "$MODEL" \
  --sandbox read-only \
  --ephemeral \
  --ignore-user-config \
  --ignore-rules \
  --skip-git-repo-check \
  --color never \
  --output-schema "$SCHEMA" \
  --output-last-message "$tmp/last.json" \
  - < "$tmp/prompt.md" > "$tmp/stdout.log" 2>&1
rc=$?

if [ $rc -ne 0 ]; then
  echo "codex exited $rc — infrastructure, discard. See $tmp/stdout.log" >&2
  sed -n '$p' "$tmp/stdout.log" >&2
  exit 1
fi

# Render the schema-constrained JSON into the section format the panel's recurrence pass
# reads. The conversion is here rather than in the table so the table stays one code path.
python3 - "$tmp/last.json" "$out" <<'PY'
import json, sys
src, dst = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(src))
    sections = data["sections"]
    assert isinstance(sections, list) and sections
except Exception as e:
    sys.stderr.write(f"codex output is not the contract: {e}\n")
    sys.exit(2)

with open(dst, "w") as fh:
    for s in sections:
        fh.write(f"### {s.get('section','(unnamed)')}\n")
        fh.write(f"**Verdict:** {s.get('verdict','no finding')}\n")
        fh.write(f"**Failure:** {s.get('failure','n/a')}\n")
        fh.write(f"**Layer of the implied fix:** {s.get('layer','n/a')}\n")
        fh.write(f"**Anchor:** {s.get('anchor','n/a')}\n\n")
print(f"{len(sections)} section(s)", file=sys.stderr)
PY
prc=$?
[ $prc -eq 0 ] || exit $prc

echo "$out"
