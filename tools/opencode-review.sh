#!/usr/bin/env bash
# Adversarial review of a lab artifact by a second, non-Claude model.
#
# The point is independence. Claude wrote nothing here and neither did you — the reviewer
# is a different model family (opencode-go / ollama-cloud are the authenticated providers),
# so its disagreement is not correlated with the author's blind spots.
#
#   ./tools/opencode-review.sh benchmark/rubrics/backend-quality.yaml
#   ./tools/opencode-review.sh -n 3 benchmark/rubrics/backend-quality.yaml
#   LAB_REVIEW_MODEL=ollama-cloud/kimi-k2.6 ./tools/opencode-review.sh rubric.yaml
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
# The reviewer model is a registered variable. Changing it mid-experiment invalidates
# every comparison that spans the change — the header exists so you can prove you did not.
# Exit 1 if opencode fails or no artifact was given.

set -uo pipefail
cd "$(dirname "$0")/.."

MODEL="${LAB_REVIEW_MODEL:-ollama-cloud/deepseek-v4-pro}"
OUTDIR="findings/opencode"
RUNS=1

while getopts "n:" opt; do
  case "$opt" in
    n) RUNS="$OPTARG" ;;
    *) echo "usage: $0 [-n runs] <artifact> [more-artifacts...]" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

case "$RUNS" in
  ''|*[!0-9]*) echo "-n must be a positive integer" >&2; exit 1 ;;
  0) echo "-n must be at least 1" >&2; exit 1 ;;
esac

if [ $# -eq 0 ]; then
  echo "usage: $0 [-n runs] <artifact> [more-artifacts...]" >&2
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
  echo "reviewer:        lab-critic"
  echo "model:           $MODEL          # registered variable — do not change mid-experiment"
  echo "opencode:        $(opencode --version 2>/dev/null | tail -1)"
  echo "agent_sha:       $(shasum -a 256 .opencode/agent/lab-critic.md | cut -c1-12)"
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

  rc=${PIPESTATUS[0]}
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
} >> "$out"

for i in $(seq 1 "$RUNS"); do
  { echo; echo "---"; echo; echo "## Run $i of $RUNS"; echo; cat "$tmpdir/run-$i.md"; } >> "$out"
done

echo "$out"
