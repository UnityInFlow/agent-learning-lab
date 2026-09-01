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

# TWO WAYS IN, ONE INVARIANT. Path A scores a benchmark FIXTURE and proves it cleared the
# gates by name, from the benchmarks registry. Path B scores an observatory RUN and proves
# the same thing from the evaluator's recorded verdict. B2's output has no fixture name, and
# the rubric still may not score a submission that failed a gate — so the proof changes and
# the invariant does not. DECISION D, 2026-08-28; see build/README.md#b2.
#
# Path B takes --run-id, NEVER a directory plus a "this passed" flag. A flag is a promise by
# the caller, which is Layer 3 wearing Layer 2's clothes, and `--dir X --run-id Y` lets the
# two disagree. Resolving the directory FROM the id makes the mismatch unrepresentable.
MODE=fixture
RUN_ID=""
OBS_API="${LAB_OBSERVATORY_API:-http://localhost:8081}"

if [ $# -eq 3 ] && [ "$2" = "--run-id" ]; then
  MODE=run; RUBRIC="$1"; RUN_ID="$3"; TARGET=""
elif [ $# -eq 2 ]; then
  RUBRIC="$1"; TARGET="$2"
else
  echo "usage: $0 <rubric.yaml> <implementation-dir>" >&2
  echo "       $0 <rubric.yaml> --run-id <observatory-run-id>" >&2
  exit 1
fi

[ -r "$RUBRIC" ] || { echo "cannot read rubric: $RUBRIC" >&2; exit 1; }

if [ "$MODE" = run ]; then
  # The runner names the worktree after the run id, so the directory is derived rather than
  # supplied and cannot disagree with the record fetched below.
  TARGET="${TMPDIR:-/tmp}/observatory-run-${RUN_ID}"
  [ -d "$TARGET" ] || {
    echo "no worktree at $TARGET" >&2
    echo "run-agent.sh deletes the worktree at step 12 unless it was given --keep." >&2
    echo "A run scored from a deleted worktree is not something this can reconstruct." >&2; exit 1; }
  [ -d "$TARGET/.git" ] || { echo "$TARGET is not a git worktree; cannot derive what changed" >&2; exit 1; }
fi

[ -d "$TARGET" ] || { echo "not a directory: $TARGET" >&2; exit 1; }
[ -r "$AGENT" ]  || { echo "cannot read $AGENT" >&2; exit 1; }
[ -r "$SCHEMA" ] || { echo "cannot read $SCHEMA" >&2; exit 1; }
command -v codex >/dev/null 2>&1 || { echo "codex not installed" >&2; exit 1; }

# THE GATE FILTER, identical to opencode-score.sh and for the identical reason: this rubric
# only scores submissions that already cleared every gate, and a score on a gate-failing one
# is a different measurement wearing this one's units. Reads the benchmark's own registry
# rather than keeping a second copy, and fails closed when it cannot.
EVAL_EXIT=""
if [ "$MODE" = fixture ]; then
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
else
  # PATH B. The evaluator already decided this; the scorer verifies the record rather than
  # re-deciding, and refuses when there is no record at all. Fetching and deciding are split
  # so the decision is testable without a live API — see verify-run-gate-checker.sh.
  rundoc="$(mktemp)"
  curl -fsS "${OBS_API}/api/runs/${RUN_ID}" -o "$rundoc" 2>/dev/null || {
    rm -f "$rundoc"
    echo "cannot read run ${RUN_ID} from ${OBS_API}" >&2
    echo "Set LAB_OBSERVATORY_API if the API is elsewhere. Refusing to score a run whose" >&2
    echo "gate result cannot be established." >&2; exit 1; }
  # Once, not twice, and reported against the RUN rather than the temp file it landed in:
  # a refusal naming /tmp/tmp.0k9HO4 tells the reader nothing about which run was refused.
  gate_out="$(./tools/check-run-gate.sh "$rundoc" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "$gate_out" | sed "s|$rundoc|run ${RUN_ID} at ${OBS_API}|g" >&2
    rm -f "$rundoc"; exit "$rc"
  fi
  EVAL_EXIT="$(jq -r '(.evaluation // .).exitCode' "$rundoc" 2>/dev/null)"
  rm -f "$rundoc"
fi

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
if [ "$MODE" = run ]; then
  # DECISION D. A B1 fixture is "the files that DIFFER from a clean baseline, in full" — the
  # benchmarks repo's own definition. A run's diff is the same object, so B2 attaches the
  # files the agent changed, in full, against those same files as they were BEFORE the agent
  # ran. Same rule as B1, applied to a run: B1 and B2 sheets stay comparable by construction
  # rather than by a caveat someone has to remember.
  #
  # NOT the whole worktree, and the reason is not tidiness. sample-service already ships
  # ShipmentControllerTest.kt, so attaching all 25 files would put a test file among the
  # attachments on EVERY run — and `test-quality`'s precondition ("no file under src/test/
  # among the attachments -> null") could then never fire. Decision A would be silently
  # disabled between B1 and B2 while the sheet kept reporting the same units.
  BASELINE=""
  baseline_state="pre-agent HEAD of the changed files (Decision D); new files have no baseline side"
else
  BASELINE="${LAB_SCORE_BASELINE:-$(dirname "$TARGET")/known-good}"
  baseline_state="attached"
  if [ "$(cd "$TARGET" && pwd)" = "$(cd "$BASELINE" 2>/dev/null && pwd || echo /nonexistent)" ]; then
    BASELINE=""
    baseline_state="none — the target IS the baseline; its cells see one tree, the others see two"
  elif [ ! -d "$BASELINE" ]; then
    echo "baseline not found: $BASELINE — E-001 Decision B requires it" >&2
    exit 1
  fi
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
base=()

if [ "$MODE" = run ]; then
  # Tracked modifications plus new untracked files. run-agent.sh builds the agent's repo with
  # git archive + git init and asserts a single commit, so HEAD is unambiguously the
  # pre-agent state and "changed" needs no further definition.
  changed=$( { git -C "$TARGET" diff --name-only HEAD;
               git -C "$TARGET" ls-files --others --exclude-standard; } 2>/dev/null \
             | grep -E '\.(kt|java|xml|ya?ml)$' | sort -u )
  [ -n "$changed" ] || {
    echo "the agent changed no source file in $TARGET" >&2
    echo "There is no submission to score. That is a result about the run, and the" >&2
    echo "evaluator will have recorded it — it is not a scoring failure." >&2; exit 1; }
  mkdir -p "$tmp/baseline"
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    srcs+=("$TARGET/$rel")
    # A file the agent CREATED has no pre-agent side. Absent from the baseline set is the
    # honest representation of that; inventing an empty file would read as "it existed and
    # was blank", which is a different claim.
    if git -C "$TARGET" cat-file -e "HEAD:$rel" 2>/dev/null; then
      dst="$tmp/baseline/$rel"; mkdir -p "$(dirname "$dst")"
      git -C "$TARGET" show "HEAD:$rel" > "$dst" 2>/dev/null && base+=("$dst")
    fi
  done <<< "$changed"
else
  while IFS= read -r f; do srcs+=("$f"); done < <(find "$TARGET" -type f \
    \( -name '*.kt' -o -name '*.java' -o -name '*.xml' -o -name '*.yaml' -o -name '*.yml' \) | sort)
  [ ${#srcs[@]} -gt 0 ] || { echo "no source files under $TARGET" >&2; exit 1; }

  if [ -n "$BASELINE" ]; then
    while IFS= read -r f; do base+=("$f"); done < <(find "$BASELINE" -type f \
      \( -name '*.kt' -o -name '*.java' -o -name '*.xml' -o -name '*.yaml' -o -name '*.yml' \) | sort)
    [ ${#base[@]} -gt 0 ] || { echo "no source files under the baseline $BASELINE" >&2; exit 1; }
  fi
fi

{
  cat "$tmp/contract.md"
  echo
  echo "## The rubric"
  echo '```yaml'
  cat "$RUBRIC"
  echo '```'
  echo
  if [ ${#base[@]} -gt 0 ]; then
    echo "## The BASELINE submission — the reference, NOT the work under test"
    echo
    echo "Score only the work under test, below. These files are what a change is read against."
    for f in "${base[@]}"; do
      echo; echo "### BASELINE FILE: $f"; echo '```'; cat "$f"; echo '```'
    done
    echo
  elif [ "$MODE" = run ]; then
    echo "## No baseline in this run — every changed file is NEW"
    echo
    echo "The agent created every file below; none existed before it ran, so there is no"
    echo "earlier version to read a change against. Any category whose anchors require"
    echo "comparing against a baseline is undecidable here — emit score: null with"
    echo "reason: ambiguous rather than inventing one."
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

# Assemble and stop. B2 needs to inspect the exact evidence set before committing five runs
# to it, and "read the script and imagine the prompt" is how an attachment-set mistake
# survives to the batch. Not a gate bypass: it produces no sheet and exits 3.
if [ -n "${LAB_SCORE_DRY_RUN:-}" ]; then
  cp "$tmp/prompt.md" "${LAB_SCORE_DRY_RUN}" 2>/dev/null || cp "$tmp/prompt.md" ./score-prompt-dry-run.md
  echo "DRY RUN — prompt written, nothing scored. ${#srcs[@]} file(s) under test, ${#base[@]} baseline." >&2
  rm -f "$out"
  exit 3
fi

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
  echo "  mode:           $MODE"
  if [ "$MODE" = run ]; then
    echo "  run_id:         $RUN_ID"
    echo "  evaluator_exit: $EVAL_EXIT"
    echo "  observatory:    ${OBS_API}/api/runs/${RUN_ID}"
    echo "  attachments:    ${#srcs[@]} changed file(s), ${#base[@]} with a pre-agent side (Decision D)"
  fi
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
