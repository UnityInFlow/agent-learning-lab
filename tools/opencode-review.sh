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
#   ./tools/opencode-review.sh -P deepseek-v4-pro,qwen3.7-max,gpt-oss:120b rubric.yaml
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

PANEL=""

while getopts "n:P:A" opt; do
  case "$opt" in
    n) RUNS="$OPTARG" ;;
    P) PANEL="$OPTARG" ;;
    A) ACCEPT=0 ;;
    *) echo "usage: $0 [-n runs] [-P m1,m2,...] [-A] <artifact> [more...]" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

case "$RUNS" in
  ''|*[!0-9]*) echo "-n must be a positive integer" >&2; exit 1 ;;
  0) echo "-n must be at least 1" >&2; exit 1 ;;
esac

# THE PANEL. -n and -P measure different things and are deliberately separate knobs.
#
#   -n  the SAME model, N times. Measures that model's detection threshold: two runs at
#       temperature 0 disagreed on 2 of 12 sections, both flips real findings the earlier
#       run missed. Tells you how much one lens under-reports.
#   -P  DIFFERENT families, once each. Measures the artifact. On 2026-08-28 glm-5.2 found
#       ladder gaps and undecidable evidence on the BE-003 rubric; deepseek-v4-pro found
#       four textual ambiguities in the same file. Neither found the other's. One model run
#       twice would never have produced both lists.
#
# They compose: -n 2 -P a,b runs four passes. The recurrence column counts DISTINCT
# FAMILIES, never repeats of one, so a section flagged twice by the same model still counts
# once — otherwise a chatty model would outvote a panel.
# PREFLIGHT, BEFORE ANY RUN IS PAID FOR. The first panel run died on its SECOND model: a
# bare `qwen3.7-max` was prefixed with the default provider, `ollama-cloud/qwen3.7-max` does
# not exist (qwen lives on opencode-go), opencode exited 1 — after the first family had
# already been run in full. A typo in the fifth name should not cost four runs.
#
# So the list is resolved and checked against `opencode models` up front, and a bare name
# resolves to whichever provider actually HAS it rather than to a guess.
avail="$(opencode models 2>/dev/null)"
[ -n "$avail" ] || { echo "cannot list models — is opencode authenticated?" >&2; exit 1; }

# Prints the fully-qualified id, or nothing. Never guesses: an ambiguous bare name is an
# error, because silently picking a provider is how a run gets attributed to the wrong one.
resolve_model() {
  local m="$1" pref hits n
  case "$m" in
    */*) printf '%s\n' "$avail" | grep -qxF "$m" && printf '%s\n' "$m"; return ;;
  esac
  pref="${LAB_PANEL_PROVIDER:-ollama-cloud}/$m"
  if printf '%s\n' "$avail" | grep -qxF "$pref"; then printf '%s\n' "$pref"; return; fi
  # Exact suffix match through awk rather than a regex, so `.` and `:` in a model name are
  # not quietly treated as metacharacters.
  hits="$(printf '%s\n' "$avail" | awk -F/ -v m="$m" 'NF == 2 && $2 == m { print }')"
  n="$(printf '%s\n' "$hits" | grep -c .)"
  [ "$n" = 1 ] && printf '%s\n' "$hits"
}

MODELS=()
if [ -n "$PANEL" ]; then
  IFS=',' read -r -a panel_arr <<< "$PANEL"
  bad=0
  for m in "${panel_arr[@]}"; do
    m="$(echo "$m" | tr -d '[:space:]')"
    [ -n "$m" ] || continue
    r="$(resolve_model "$m")"
    if [ -z "$r" ]; then
      echo "-P: cannot resolve '$m'" >&2
      printf '%s\n' "$avail" | grep -F -- "$m" | sed 's/^/    did you mean: /' >&2 || true
      bad=1
      continue
    fi
    for _ in $(seq 1 "$RUNS"); do MODELS+=("$r"); done
  done
  [ "$bad" = 0 ] || { echo "Refusing to start: a panel that loses a family part-way is not the panel you registered." >&2; exit 1; }
  [ ${#MODELS[@]} -gt 0 ] || { echo "-P listed no usable models" >&2; exit 1; }
else
  printf '%s\n' "$avail" | grep -qxF "$MODEL" || { echo "unknown model: $MODEL" >&2; exit 1; }
  for _ in $(seq 1 "$RUNS"); do MODELS+=("$MODEL"); done
fi
TOTAL=${#MODELS[@]}

# Distinct families, for the denominator and the header.
FAMILIES=()
for m in "${MODELS[@]}"; do
  case " ${FAMILIES[*]} " in *" $m "*) ;; *) FAMILIES+=("$m") ;; esac
done
NFAM=${#FAMILIES[@]}

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
  echo "  model:         ${MODELS[0]}          # registered variable — do not change mid-experiment"
  echo "  agent_sha:     $(shasum -a 256 .opencode/agent/lab-critic.md | cut -c1-12)"
  if [ "$NFAM" -gt 1 ]; then
    echo "  panel:         # every family is a registered variable; changing the set"
    for m in "${FAMILIES[@]}"; do echo "    - $m"; done
  fi
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
  echo "runs:            $TOTAL           # independent sessions; findings unioned below"
  echo "families:        $NFAM           # distinct models; the recurrence denominator"
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

for i in $(seq 1 "$TOTAL"); do
  run_model="${MODELS[$((i - 1))]}"
  # The slug carries the model into the filename so the recurrence pass can attribute a
  # finding to a family without a side-channel index that could drift out of step.
  run_slug="$(echo "$run_model" | tr '/:.' '___')"
  echo "review $i/$TOTAL — $slug with $run_model ..." >&2

  # Fresh session every iteration — never --continue. A reviewer that remembers its last
  # pass is not an independent second look, and the recurrence count below would be a lie.
  #
  # The prompt must precede -f: opencode's -f is a yargs array flag and will otherwise
  # swallow the message as a filename.
  opencode run --agent lab-critic -m "$run_model" \
    "Review the attached artifact(s) against your output contract. Work through every
     section in the artifact's own order. Remember: a finding needs a concrete failure
     scenario, 'no finding' is a valid verdict, and you must not supply replacement text." \
    "${attach[@]}" 2>&1 | sed $'s/\x1b\\[[0-9;]*m//g' > "$tmpdir/run-$i@$run_slug.md"

  # PIPESTATUS must be read FIRST — it is only valid immediately after the pipeline, and
  # any command in between (a grep, an echo) resets it.
  rc=${PIPESTATUS[0]}

  # opencode exiting non-zero is the one unambiguous infrastructure failure — the process
  # did not complete, so there is nothing to classify.
  if [ "$rc" -ne 0 ]; then
    cat "$tmpdir/run-$i@$run_slug.md" >> "$out"
    echo "opencode exited $rc on run $i — infrastructure, discard. See $out" >&2
    exit 1
  fi

  # Everything else is a question about what the CRITIC did, and it has more than one
  # answer. Until 2026-08-27 this script asked only whether the agent had been loaded: an
  # opencode that exited 0 having produced nothing left a provenance header, an empty
  # recurrence table and exit 0 — a review that reported success while finding nothing,
  # which is the failure the scorer's classifier exists to stop, one script over.
  class="$(./tools/classify-model-output.sh critic "$tmpdir/run-$i@$run_slug.md")"
  cls=$?
  case $cls in
    0) ;;   # sections with verdicts. Under-reporting is invisible here; that is what -n is for.
    4) echo "FATAL [$class]: lab-critic was not loaded; opencode fell back to the default agent." >&2
       echo "Findings from the default full-tool agent look identical to contract-compliant" >&2
       echo "ones. Infrastructure — discard." >&2
       exit 4 ;;
    3) echo "EMPTY [$class]: run $i produced nothing." >&2
       echo "Ambiguous: an empty turn, or the critic having nothing it could say about this" >&2
       echo "artifact. The file cannot tell you which. Re-run ONCE on the same artifact; a" >&2
       echo "repeat is a finding about the critic and must be recorded, not discarded." >&2
       exit 3 ;;
    *) echo "OFF CONTRACT [$class]: run $i produced output that is not the section format —" >&2
       echo "prose, a refusal, a summary. That is what this model did with this artifact, so" >&2
       echo "it is evidence. Read $tmpdir/run-$i@$run_slug.md before re-running." >&2
       cat "$tmpdir/run-$i@$run_slug.md" >> "$out"
       exit 2 ;;
  esac
done

# Recurrence table. A section counts as flagged in a run if that run gave it a `finding`
# verdict. Sections are matched on their heading text, so a run that decomposes the
# artifact differently (one did — it split `evaluation` in two) shows up as its own row
# rather than being silently merged into a neighbour.
{
  if [ "$NFAM" -gt 1 ]; then
    echo "## Recurrence across $NFAM independent families ($TOTAL run(s))"
    echo
    echo "How many DIFFERENT model families flagged each section — not how often one model"
    echo "repeated itself. A section flagged twice by the same family counts once, so a chatty"
    echo "model cannot outvote the panel."
    echo
    echo "**1/$NFAM is not weak evidence.** Families find different classes of defect: on"
    echo "2026-08-28, glm-5.2 found gaps in the anchor ladder and an anchor citing evidence that"
    echo "is not attached, while deepseek-v4-pro found four textual ambiguities in the same file."
    echo "Neither saw the other's list. A 1/$NFAM row is one lens holding something the others do"
    echo "not — read it first, not last."
  else
    echo "## Recurrence across $TOTAL run(s)"
    echo
    echo "How many independent runs flagged each section. Low recurrence is a detection-threshold"
    echo "signal, not a falsity signal — read those findings, do not discount them."
    echo
    echo "One family only. -P runs a panel of different models instead, which measures the"
    echo "artifact rather than this model's detection threshold."
  fi
  echo
  echo "| Section | Families | Layer of implied fix |"
  echo "|---|---|---|"
  awk '
    # The model is in the filename after @, so attribution needs no side-channel index
    # that could drift out of step with the run order.
    FNR == 1 { fam = FILENAME; sub(/.*@/, "", fam); sub(/\.md$/, "", fam); sec = "" }
    /^### /   { sec = substr($0, 5); next }
    /^\*\*Verdict:\*\* *finding/ {
      if (sec != "") {
        # Once per FAMILY, not once per run: two flags from one model are one lens.
        if (!((sec SUBSEP fam) in byfam)) { byfam[sec, fam] = 1; hit[sec]++ }
        if (!(sec in seen)) { order[++n] = sec; seen[sec] = 1 }
      }
      next
    }
    /^\*\*Layer of the implied fix:\*\*/ {
      if (sec != "" && sec in seen && !(sec in layer)) {
        l = $0; sub(/^\*\*Layer of the implied fix:\*\* */, "", l)
        # Keep only the layer token. The model sometimes appends its reasoning to the
        # line, which would blow the column out to a paragraph.
        layer[sec] = (match(l, /L[123]/) ? substr(l, RSTART, 2) : "n/a")
      }
    }
    END { for (i = 1; i <= n; i++) printf "| %s | %d/%s | %s |\n", order[i], hit[order[i]], NFAMN, (order[i] in layer ? layer[order[i]] : "—") }
  ' NFAMN="$NFAM" "$tmpdir"/run-*.md
  echo
} > "$tmpdir/body.md"

for i in $(seq 1 "$TOTAL"); do
  m="${MODELS[$((i - 1))]}"
  f="$tmpdir/run-$i@$(echo "$m" | tr '/:.' '___').md"
  { echo; echo "---"; echo; echo "## Run $i of $TOTAL — $m"; echo; cat "$f"; } >> "$tmpdir/body.md"
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

    if [ "$arc" -ne 0 ]; then
      echo "opencode exited $arc on the acceptance pass — line-level findings kept" >&2
      printf '\n## Acceptance\n\nThe gate failed to run (opencode exit %s).\n' "$arc" >> "$out"
      acls=1
    else
      aclass="$(./tools/classify-model-output.sh acceptance "$tmpdir/accept.md")"
      acls=$?
    fi

    if [ "$acls" = 4 ]; then
      echo "FATAL [$aclass]: lab-acceptance was not loaded; opencode fell back to the default agent." >&2
      exit 4
    fi

    # A gate that did not produce a verdict has not passed anything. Recorded as what it
    # was, rather than left to be read as a quiet approval.
    if [ "$acls" = 3 ] || [ "$acls" = 2 ]; then
      echo "GATE DID NOT DECIDE [$aclass]: the acceptance pass produced no verdict." >&2
      echo "That is a finding about the gate, not a pass. Line-level findings kept." >&2
      { printf '\n## Acceptance — NO VERDICT (%s)\n\n' "$aclass"
        echo "The gate broke its own output contract. This is not an ACCEPT."
        echo
        cat "$tmpdir/accept.md"
      } >> "$out"
      verdict="NO VERDICT"
    fi

    if [ "$acls" = 0 ]; then
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
