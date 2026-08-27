#!/usr/bin/env bash
# Adversarial review of a lab artifact by a second, non-Claude model.
#
# The point is independence. Claude wrote nothing here and neither did you — the reviewer
# is a different model family (opencode-go / ollama-cloud are the authenticated providers),
# so its disagreement is not correlated with the author's blind spots.
#
# TWO MODELS, TWO JOBS. Finding and deciding are different, and running both on one model
# means one set of blind spots covers both:
#
#   line-level   lab-critic      glm-5.2      every section, every finding bound to a
#                                             concrete failure scenario — as today
#   acceptance   lab-acceptance  minimax-m3   one verdict on the whole artifact: is this
#                                             ready to leave the machine
#
# The acceptance pass reads the artifact AND the line-level findings. It does not re-find;
# it decides, and it may dispute a line-level finding it cannot substantiate.
#
#   ./tools/opencode-review.sh benchmark/rubrics/backend-quality.yaml
#   ./tools/opencode-review.sh -n 3 benchmark/rubrics/backend-quality.yaml
#   ./tools/opencode-review.sh -A rubric.yaml          # line-level only, no gate
#   LAB_REVIEW_MODEL=ollama-cloud/kimi-k2.6 ./tools/opencode-review.sh rubric.yaml
#   LAB_ACCEPT_MODEL=ollama-cloud/deepseek-v4-pro ./tools/opencode-review.sh rubric.yaml
#
# Writes findings/opencode/review-<artifact>-<timestamp>.md with a provenance header.
#
# WHY -n EXISTS. Two runs of the same reviewer at temperature 0 over the same artifact
# disagreed on 2 of 12 sections, and both flips were `no finding` -> a real, L1-classified
# finding the earlier run had missed. The reviewer under-reports; it does not hallucinate.
# So a single run is a LOWER BOUND on findings, and -n unions across runs.
#
# The recurrence column is the point. A section flagged 3/3 is solid. One flagged 1/3 is
# still worth reading — that is where the two L1 findings lived — but you now know it is
# near the reviewer's detection threshold rather than treating it as equally certain.
#
# Both models are registered variables. Changing either mid-experiment invalidates every
# comparison that spans the change — the header records both so you can prove you did not.
# Every finding on file before 2026-08-27 was deepseek-v4-pro doing BOTH jobs; nothing after
# this change is comparable to those without a re-run.
#
# THE GATE IS ADVISORY BY DEFAULT. A REJECT verdict is recorded and printed; the script
# still exits 0, because the hook that calls it must never fail a push. That makes it L3 —
# words someone reads. LAB_ACCEPT_STRICT=1 is the L2 version: REJECT exits 3.
#
# Exit 1 if opencode fails or no artifact was given. Exit 3 on REJECT under
# LAB_ACCEPT_STRICT=1.

set -uo pipefail
# `|| exit` matters here: without it a failed cd runs the review from the caller's
# directory, resolving artifact paths against the wrong tree and stamping the wrong shas.
cd "$(dirname "$0")/.." || exit 1

MODEL="${LAB_REVIEW_MODEL:-ollama-cloud/glm-5.2}"
ACCEPT_MODEL="${LAB_ACCEPT_MODEL:-ollama-cloud/minimax-m3}"
ACCEPT=1
OUTDIR="findings/opencode"
RUNS=1

while getopts "n:A" opt; do
  case "$opt" in
    n) RUNS="$OPTARG" ;;
    A) ACCEPT=0 ;;
    *) echo "usage: $0 [-n runs] [-A] <artifact> [more-artifacts...]" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

case "$RUNS" in
  ''|*[!0-9]*) echo "-n must be a positive integer" >&2; exit 1 ;;
  0) echo "-n must be at least 1" >&2; exit 1 ;;
esac

if [ $# -eq 0 ]; then
  echo "usage: $0 [-n runs] [-A] <artifact> [more-artifacts...]" >&2
  exit 1
fi

for f in "$@"; do
  [ -r "$f" ] || { echo "cannot read: $f" >&2; exit 1; }
done

mkdir -p "$OUTDIR"
stamp=$(date -u +%Y%m%dT%H%M%SZ)
slug=$(basename "$1" | sed 's/\.[^.]*$//')
out="$OUTDIR/review-$slug-$stamp.md"

attach=()
for f in "$@"; do attach+=(-f "$f"); done

{
  echo "# opencode review — $slug"
  echo
  echo '```yaml'
  echo "line_level:"
  echo "  agent:         lab-critic"
  echo "  model:         $MODEL          # registered variable — do not change mid-experiment"
  echo "  agent_sha:     $(shasum -a 256 .opencode/agent/lab-critic.md | cut -c1-12)"
  if [ "$ACCEPT" = 1 ]; then
    echo "acceptance:"
    echo "  agent:         lab-acceptance"
    echo "  model:         $ACCEPT_MODEL"
    echo "  agent_sha:     $(shasum -a 256 .opencode/agent/lab-acceptance.md 2>/dev/null | cut -c1-12)"
    echo "  strict:        $([ "${LAB_ACCEPT_STRICT:-0}" = 1 ] && echo true || echo false)"
  else
    echo "acceptance:      skipped    # -A"
  fi
  echo "opencode:        $(opencode --version 2>/dev/null | tail -1)"
  echo "reviewed_utc:    $stamp"
  echo "runs:            $RUNS           # independent sessions; findings unioned below"
  echo "artifacts:"
  for f in "$@"; do
    echo "  - path: $f"
    echo "    sha:  $(shasum -a 256 "$f" | cut -c1-12)"
  done
  echo "lab_head:        $(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
  echo "lab_dirty:       $([ -n "$(git status --porcelain 2>/dev/null)" ] && echo true || echo false)"
  echo '```'
  echo
} > "$out"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

for i in $(seq 1 "$RUNS"); do
  echo "review $i/$RUNS — $slug with $MODEL ..." >&2

  # Fresh session every iteration — never --continue. A reviewer that remembers its last
  # pass is not an independent second look, and the recurrence count below would be a lie.
  #
  # The prompt must precede -f: opencode's -f is a yargs array flag and will otherwise
  # swallow the message as a filename.
  opencode run --agent lab-critic -m "$MODEL" \
    "Review the attached artifact(s) against your output contract. Work through every
     section in the artifact's own order. Remember: a finding needs a concrete failure
     scenario, 'no finding' is a valid verdict, and you must not supply replacement text." \
    "${attach[@]}" 2>&1 | sed $'s/\x1b\\[[0-9;]*m//g' > "$tmpdir/run-$i.md"

  # PIPESTATUS must be read FIRST — it is only valid immediately after the pipeline, and
  # any command in between (a grep, an echo) resets it.
  rc=${PIPESTATUS[0]}

  # opencode treats a missing agent as a warning and still exits 0. Fatal here: findings
  # from the default full-tool agent look identical to contract-compliant ones.
  if grep -q "Falling back to default agent" "$tmpdir/run-$i.md"; then
    echo "FATAL: lab-critic was not loaded; opencode fell back to the default agent." >&2
    exit 1
  fi

  if [ "$rc" -ne 0 ]; then
    cat "$tmpdir/run-$i.md" >> "$out"
    echo "opencode exited $rc on run $i — see $out" >&2
    exit 1
  fi
done

# Recurrence table. A section counts as flagged in a run if that run gave it a `finding`
# verdict. Sections are matched on their heading text, so a run that decomposes the
# artifact differently (one did — it split `evaluation` in two) shows up as its own row
# rather than being silently merged into a neighbour.
{
  echo "## Recurrence across $RUNS run(s)"
  echo
  echo "How many independent runs flagged each section. Low recurrence is a detection-threshold"
  echo "signal, not a falsity signal — read those findings, do not discount them."
  echo
  echo "| Section | Flagged | Layer of implied fix |"
  echo "|---|---|---|"
  awk '
    /^### /   { sec = substr($0, 5); next }
    /^\*\*Verdict:\*\* *finding/ { if (sec != "") { hit[sec]++; if (!(sec in seen)) { order[++n] = sec; seen[sec] = 1 } } next }
    /^\*\*Layer of the implied fix:\*\*/ {
      if (sec != "" && sec in seen && !(sec in layer)) {
        l = $0; sub(/^\*\*Layer of the implied fix:\*\* */, "", l)
        # Keep only the layer token. The model sometimes appends its reasoning to the
        # line, which would blow the column out to a paragraph.
        layer[sec] = (match(l, /L[123]/) ? substr(l, RSTART, 2) : "n/a")
      }
    }
    END { for (i = 1; i <= n; i++) printf "| %s | %d/%s | %s |\n", order[i], hit[order[i]], RUNSN, (order[i] in layer ? layer[order[i]] : "—") }
  ' RUNSN="$RUNS" "$tmpdir"/run-*.md
  echo
} > "$tmpdir/body.md"

for i in $(seq 1 "$RUNS"); do
  { echo; echo "---"; echo; echo "## Run $i of $RUNS"; echo; cat "$tmpdir/run-$i.md"; } >> "$tmpdir/body.md"
done

# --- the acceptance pass -----------------------------------------------------------------
#
# A different model, a different job. It reads the artifact AND the line-level findings, and
# returns one verdict. Deliberately NOT given the recurrence table: how often a finding
# recurred is a fact about the line-level model's detection threshold, and a gate that
# weights findings by how often one model repeated itself is measuring that model, not the
# artifact.
verdict="not run"
if [ "$ACCEPT" = 1 ]; then
  if [ ! -r .opencode/agent/lab-acceptance.md ]; then
    echo "lab-acceptance agent is missing; skipping the gate" >&2
  else
    echo "acceptance — $slug with $ACCEPT_MODEL ..." >&2
    findings="$tmpdir/line-level-findings.md"
    cat "$tmpdir"/run-*.md > "$findings"

    opencode run --agent lab-acceptance -m "$ACCEPT_MODEL" \
      "Decide whether the attached artifact is ready to leave the machine. One of the
       attachments, line-level-findings.md, is what a different model reported against it
       section by section — treat it as evidence, not as a verdict, and dispute anything you
       cannot substantiate from the artifact itself. YAML only, per your output contract." \
      "${attach[@]}" -f "$findings" 2>&1 | sed $'s/\x1b\\[[0-9;]*m//g' > "$tmpdir/accept.md"
    arc=${PIPESTATUS[0]}

    if grep -q "Falling back to default agent" "$tmpdir/accept.md"; then
      echo "FATAL: lab-acceptance was not loaded; opencode fell back to the default agent." >&2
      exit 1
    fi
    if [ "$arc" -ne 0 ]; then
      echo "opencode exited $arc on the acceptance pass — line-level findings kept" >&2
      printf '\n## Acceptance\n\nThe gate failed to run (opencode exit %s).\n' "$arc" >> "$out"
    else
      # The verdict, for the caller. Absent means the model broke its own contract, which is
      # a finding about the gate rather than a pass.
      verdict=$(grep -m1 -E '^[[:space:]]*verdict:' "$tmpdir/accept.md" \
                 | sed 's/.*verdict:[[:space:]]*//' | tr -d '\r' | awk '{print $1}')
      [ -n "$verdict" ] || verdict="NO VERDICT"
      { echo "## Acceptance — $verdict"
        echo
        echo "The gate. A different model from the line-level pass, deciding rather than finding."
        echo
        cat "$tmpdir/accept.md"
      } >> "$out"
    fi
  fi
fi

cat "$tmpdir/body.md" >> "$out"

echo "$out"
[ "$verdict" = "REJECT" ] && echo "acceptance: REJECT — see $out" >&2

if [ "${LAB_ACCEPT_STRICT:-0}" = 1 ] && [ "$verdict" = "REJECT" ]; then
  exit 3
fi
exit 0
