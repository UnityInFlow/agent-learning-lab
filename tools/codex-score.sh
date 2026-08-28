#!/usr/bin/env bash
# Independent second scoring, through a DIFFERENT HARNESS from opencode-score.sh.
#
#   ./tools/codex-score.sh benchmark/rubrics/backend-quality.yaml \
#       ../agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/fixtures/good-nested-ifs
#
# WHY THIS EXISTS, AND IT IS NOT REDUNDANCY FOR ITS OWN SAKE.
#
# The scorer is the instrument that produces E-001's actual numbers — the sheet the human
# blind sheet is compared against. Until now it ran only through `opencode run`, and on
# 2026-08-28 `opencode run` hung on five of eight non-interactive calls across three model
# families, with five processes on this machine wedged for up to twelve days, each having
# burned an hour of CPU before it stopped returning. In the panel run that prompted this
# file, BOTH opencode families stalled at the 600s budget and codex was the only one that
# answered. A single point of failure on the instrument that produces the measurement is not
# a maintenance concern; it is the experiment being unable to run.
#
# THE CHOICE IS A REGISTERED VARIABLE, NOT A FALLBACK. Which harness scored a run changes
# what the run means, so this is not something to silently retry into. E-001 records the
# choice before any scoring happens; the provenance header records what actually ran. Never
# mix harnesses within one comparison and then compare the sheets — that measures the
# harnesses, not the rubric.
#
# WHAT IS HELD IDENTICAL TO opencode-score.sh, so the two are comparable at all:
#
#   the contract     .opencode/agent/lab-scorer.md itself, body and all, not a paraphrase
#   the evidence     the rubric and every source file INLINED, exactly the set -f attaches,
#                    including the known-good baseline (E-001 Decision B)
#   the gate filter  the same registry check — this rubric only scores what cleared the gates
#   the boundary     `known-good` scored with no baseline, and the prompt says so
#
# WHAT IS DELIBERATELY DIFFERENT, and is the reason to have it:
#
#   the harness      a different agent loop, system prompt and turn shape
#   the contract's   --output-schema forces the sheet's shape at the API. opencode's scorer
#   enforcement      is ASKED for YAML in prose and usually complies. This one cannot do
#                    otherwise, which makes `null` a value the schema admits rather than a
#                    behaviour the model has to remember
#
# Exit 0 a sheet · 1 usage / infrastructure / not a registered gate-passing target ·
#        2 output present but not the contract.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

MODEL="${LAB_CODEX_MODEL:-gpt-5.6-sol}"
AGENT=".opencode/agent/lab-scorer.md"
SCHEMA="tools/schemas/scorer-sheet.schema.json"
OUTDIR="findings/codex"

if [ $# -ne 2 ]; then
  echo "usage: $0 <rubric.yaml> <implementation-dir>" >&2
  exit 1
fi

RUBRIC="$1"
TARGET="$2"

[ -r "$RUBRIC" ] || { echo "cannot read rubric: $RUBRIC" >&2; exit 1; }
[ -d "$TARGET" ] || { echo "not a directory: $TARGET" >&2; exit 1; }
[ -r "$AGENT" ]  || { echo "cannot read $AGENT" >&2; exit 1; }
[ -r "$SCHEMA" ] || { echo "cannot read $SCHEMA" >&2; exit 1; }
command -v codex >/dev/null 2>&1 || { echo "codex not installed" >&2; exit 1; }

# THE GATE FILTER, identical to opencode-score.sh and for the identical reason: this rubric
# only scores submissions that already cleared every gate, and a score on a gate-failing one
# is a different measurement wearing this one's units. Reads the benchmark's own registry
# rather than keeping a second copy, and fails closed when it cannot.
REGISTRY="${LAB_SCORE_REGISTRY:-$(cd "$TARGET/../.." 2>/dev/null && pwd)/verify-evaluator.sh}"
[ -r "$REGISTRY" ] || {
  echo "cannot read the gate-passing registry: $REGISTRY" >&2
  echo "Refusing to score without it." >&2; exit 1; }
allowed="known-good $(sed -n 's/^QUALITY_VARIANTS=(\(.*\))$/\1/p' "$REGISTRY")"
case " $allowed " in
  *" $(basename "$TARGET") "*) ;;
  *) echo "FATAL: $(basename "$TARGET") is not a registered gate-passing variant." >&2
     echo "Registered: $allowed" >&2; exit 1 ;;
esac

# THE CATEGORY SET, pinned from the rubric rather than trusted from the model. The on-disk
# schema is a SHAPE contract and cannot name categories, because it is handed whichever
# rubric is being scored. So the enforceable part is built per run: names constrained to
# this rubric's, and the count fixed at exactly this rubric's. Before 2026-08-28 the schema
# said `minItems: 1`, no `maxItems`, and `name` a free string — a sheet carrying three of
# four categories validated, classified as `contract`, and landed in findings/ looking
# complete to every reader. A missing cell is not a null cell, and E-001's dependent
# variable is a ratio whose denominator is the cell count.
CATEGORIES="$(sed -n 's/^  - name: *"\{0,1\}\([^"]*\)"\{0,1\} *$/\1/p' "$RUBRIC" | sed 's/[[:space:]]*$//')"
[ -n "$CATEGORIES" ] || {
  echo "FATAL: parsed no categories from $RUBRIC." >&2
  echo "Refusing to score against a rubric whose category set cannot be read." >&2; exit 1; }
NCAT=$(echo "$CATEGORIES" | wc -l | tr -d ' ')

# THE BASELINE, E-001 Decision B, and the same asymmetry recorded rather than hidden:
# `known-good` is the baseline, so when it is the target there is nothing to read a change
# against and its cells see one tree while every other target's see two.
BASELINE="${LAB_SCORE_BASELINE:-$(dirname "$TARGET")/known-good}"
baseline_state="attached"
if [ "$(cd "$TARGET" && pwd)" = "$(cd "$BASELINE" 2>/dev/null && pwd || echo /nonexistent)" ]; then
  BASELINE=""
  baseline_state="none — the target IS the baseline; its cells see one tree, the others see two"
elif [ ! -d "$BASELINE" ]; then
  echo "baseline not found: $BASELINE — E-001 Decision B requires it" >&2
  exit 1
fi

mkdir -p "$OUTDIR"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
stamp=$(date -u +%Y%m%dT%H%M%SZ)
slug=$(basename "$TARGET")
out="$OUTDIR/score-$slug-$stamp.yaml"

# awk, not sed: BSD sed rejects the one-expression frontmatter strip AND fails open, which
# once sent codex a prompt containing no contract at all. The guard is why that is now loud.
PINNED="$tmp/scorer-sheet.pinned.json"
python3 - "$SCHEMA" "$PINNED" "$NCAT" "$CATEGORIES" <<'PIN_EOF' || { echo "FATAL: could not pin the schema to the rubric's categories." >&2; exit 1; }
import json, sys
src, dst, ncat, raw = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
names = [l.strip() for l in raw.splitlines() if l.strip()]
assert len(names) == ncat, "category parse disagreed with itself"
d = json.load(open(src))
cats = d["properties"]["categories"]
cats["minItems"] = cats["maxItems"] = ncat
cats["items"]["properties"]["name"] = {"type": "string", "enum": names}
json.dump(d, open(dst, "w"), indent=2)
PIN_EOF

awk '
  NR == 1 && $0 == "---" { infm = 1; next }
  infm && $0 == "---"    { infm = 0; next }
  infm                   { next }
  { print }
' "$AGENT" > "$tmp/contract.md"
[ -s "$tmp/contract.md" ] || {
  echo "FATAL: the scorer contract came out empty after stripping frontmatter." >&2
  echo "Refusing to score without it — the result would look like a score." >&2; exit 1; }

srcs=()
while IFS= read -r f; do srcs+=("$f"); done < <(find "$TARGET" -type f \
  \( -name '*.kt' -o -name '*.java' -o -name '*.xml' -o -name '*.yaml' -o -name '*.yml' \) | sort)
[ ${#srcs[@]} -gt 0 ] || { echo "no source files under $TARGET" >&2; exit 1; }

base=()
if [ -n "$BASELINE" ]; then
  while IFS= read -r f; do base+=("$f"); done < <(find "$BASELINE" -type f \
    \( -name '*.kt' -o -name '*.java' -o -name '*.xml' -o -name '*.yaml' -o -name '*.yml' \) | sort)
  [ ${#base[@]} -gt 0 ] || { echo "no source files under the baseline $BASELINE" >&2; exit 1; }
fi

{
  cat "$tmp/contract.md"
  echo
  echo "## The rubric"
  echo '```yaml'
  cat "$RUBRIC"
  echo '```'
  echo
  if [ -n "$BASELINE" ]; then
    echo "## The BASELINE submission — the reference, NOT the work under test"
    echo
    echo "Score only the work under test, below. These files are what a change is read against."
    for f in "${base[@]}"; do
      echo; echo "### BASELINE FILE: $f"; echo '```'; cat "$f"; echo '```'
    done
    echo
  else
    echo "## No baseline in this run"
    echo
    echo "The target IS the reference submission. Any category whose anchors require comparing"
    echo "against a baseline is undecidable here — emit score: null with reason: ambiguous"
    echo "rather than scoring it against itself."
    echo
  fi
  echo "## The work under test"
  echo
  echo "These attachments are the COMPLETE evidence set. There is no test runner, no diff, no"
  echo "evaluator output and no other file. Cite filename:line as evidence."
  for f in "${srcs[@]}"; do
    echo; echo "### FILE: $f"; echo '```'; cat "$f"; echo '```'
  done
} > "$tmp/prompt.md"

echo "codex scoring $slug with $MODEL — ${#srcs[@]} source file(s), ${#base[@]} baseline file(s) ..." >&2

{
  echo "# provenance — this block is data, not decoration."
  echo "# The HARNESS is a registered variable, not just the model. A sheet from codex and a"
  echo "# sheet from opencode are not interchangeable, and comparing them measures the"
  echo "# harnesses rather than the rubric."
  echo "provenance:"
  echo "  scorer:         lab-scorer"
  echo "  harness:        codex"
  echo "  codex:          $(codex --version 2>/dev/null | tail -1)"
  echo "  model:          $MODEL"
  echo "  agent_sha:      $(shasum -a 256 "$AGENT" | cut -c1-12)"
  echo "  schema_sha:     $(shasum -a 256 "$SCHEMA" | cut -c1-12)"
  echo "  schema_pinned:  $NCAT categories, names constrained to the rubric's"
  echo "  rubric_path:    $RUBRIC"
  echo "  rubric_sha:     $(shasum -a 256 "$RUBRIC" | cut -c1-12)"
  echo "  target:         $TARGET"
  echo "  baseline:       ${BASELINE:-null}"
  echo "  baseline_state: $baseline_state"
  echo "  scored_utc:     $stamp"
  echo "  session:        fresh    # --ephemeral; independence requires no memory"
  echo "  isolation:      --ignore-user-config --ignore-rules --sandbox read-only"
  echo "---"
} > "$out"

codex exec \
  --model "$MODEL" \
  --sandbox read-only \
  --ephemeral \
  --ignore-user-config \
  --ignore-rules \
  --skip-git-repo-check \
  --color never \
  --output-schema "$PINNED" \
  --output-last-message "$tmp/last.json" \
  - < "$tmp/prompt.md" > "$tmp/stdout.log" 2>&1
rc=$?

if [ $rc -ne 0 ]; then
  echo "codex exited $rc — infrastructure, discard. Tail:" >&2
  tail -3 "$tmp/stdout.log" >&2
  exit 1
fi

# The schema-constrained JSON becomes the YAML sheet the rest of the lab already reads, so
# classify-model-output.sh `score` and every downstream comparison work unchanged.
python3 - "$tmp/last.json" "$out" <<'PY'
import json, sys
src, dst = sys.argv[1], sys.argv[2]
try:
    d = json.load(open(src))
    cats = d["categories"]
    assert isinstance(cats, list) and cats
except Exception as e:
    sys.stderr.write(f"codex output is not the scorer contract: {e}\n")
    sys.exit(2)

def y(v):
    if v is None: return "null"
    if isinstance(v, int): return str(v)
    s = str(v).replace('"', "'")
    return f'"{s}"'

with open(dst, "a") as fh:
    fh.write("scorer: lab-scorer\ncategories:\n")
    for c in cats:
        fh.write(f"  - name: {y(c.get('name'))}\n")
        fh.write(f"    score: {y(c.get('score'))}\n")
        fh.write(f"    anchor_level: {y(c.get('anchor_level'))}\n")
        fh.write(f"    reason: {y(c.get('reason'))}\n")
        fh.write(f"    evidence: {y(c.get('evidence'))}\n")
    amb = d.get("ambiguous_categories") or [n for n in
          (c.get("name") for c in cats if c.get("score") is None) if n]
    fh.write("ambiguous_categories: [" + ", ".join(y(a) for a in amb) + "]\n")
nulls = sum(1 for c in cats if c.get("score") is None)
print(f"{len(cats)} categories, {nulls} null", file=sys.stderr)
PY
prc=$?
[ $prc -eq 0 ] || exit $prc

# The schema constrains what codex may EMIT; this checks what actually landed on disk, and
# the two are not the same guarantee — the sheet is rendered by the block above, and a
# renderer that dropped a category would satisfy the schema and still write a short sheet.
if ! ./tools/check-sheet-categories.sh "$RUBRIC" "$out" >/dev/null; then
  ./tools/check-sheet-categories.sh "$RUBRIC" "$out" >&2
  echo "The sheet is NOT the contract: its category set is not the rubric's. A category" >&2
  echo "that never appears is an absence, not a null, and nothing downstream can tell the" >&2
  echo "two apart. See $out" >&2
  exit 2
fi

echo "$out"
