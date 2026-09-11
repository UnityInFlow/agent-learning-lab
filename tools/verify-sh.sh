#!/usr/bin/env bash
#
# verify-sh — B7's one deterministic verification entry point.
#
#   BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS §10.11: "One deterministic verification entry
#   point ... Measure: exit code, duration, failing stage, and retry count."
#   FR-006: "one verification command with a machine-readable success/failure result."
#
# WHAT THIS IS NOT, and the distinction is the whole of B7's honesty:
#
#   It is NOT delivered to the agent. `run-agent.sh:761` pre-approves `Bash(./mvnw:*)` and
#   `Bash(mvn:*)` and NOTHING ELSE, so an agent told to run this would be refused by Claude
#   Code's own approval gate -- the gate stop 14 measured refusing 12-20 Bash commands per
#   run. An arm built that way would measure the approval gate and report it as a
#   verification result. It is run BY THE HARNESS, over a kept worktree, AFTER the run, on
#   BOTH arms alike. See phases/b07-verification-policies/README.md, "The one design
#   decision that is mine".
#
#   It is NOT a second evaluator. It decides nothing. It runs the subset of the evaluator's
#   checks that an agent could in principle have run for itself, IN THE EVALUATOR'S OWN
#   EXIT-CODE UNITS, so that "the agent could have known" and "the evaluator found out" are
#   directly comparable. The interesting number this produces is how often the two DISAGREE.
#
# EXIT CODES -- deliberately the evaluator's own mapping, not a new one. §7 forbids changing
# what the evaluator measures; adopting its units in a new script changes nothing about it.
#   0   every stage passed
#   10  build failure                       (evaluator F04)
#   11  tests failed                        (evaluator F05)
#   20  new dependency introduced           (evaluator F07)
#   21  unrelated production files changed  (evaluator F07)
#   30  verify-sh's OWN infrastructure failure -- never the submission's fault
#
# Stages run in the evaluator's priority order and STOP AT THE FIRST FAILURE, because a
# submission that does not compile has no meaningful test result and reporting one would be
# an instrument inventing data.
#
# Usage:
#   tools/verify-sh.sh --worktree <dir> [--task BE-003|BE-004] [--baseline <sha>]
#                      [--service <dir>] [--json <out>] [--quiet]
set -uo pipefail

VERSION="1.0.0"
WORKTREE=""; TASK=""; BASELINE=""; SERVICE=""; JSON_OUT=""; QUIET=false
BENCH_ROOT="${VERIFY_BENCH_ROOT:-}"

die() { printf 'verify-sh: %s\n' "$1" >&2; finish 30 "infrastructure" "$1"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --worktree) WORKTREE="$2"; shift 2 ;;
    --task)     TASK="$2";     shift 2 ;;
    --baseline) BASELINE="$2"; shift 2 ;;
    --service)  SERVICE="$2";  shift 2 ;;
    --json)     JSON_OUT="$2"; shift 2 ;;
    --quiet)    QUIET=true;    shift ;;
    --version)  echo "verify-sh $VERSION"; exit 0 ;;
    -h|--help)  sed -n '2,40p' "$0"; exit 0 ;;
    *) printf 'verify-sh: unknown argument: %s\n' "$1" >&2; exit 30 ;;
  esac
done

STAGES_JSON=""; STARTED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
say() { [[ "$QUIET" == true ]] || printf '  %-12s %s\n' "$1" "$2"; }

add_stage() {  # add_stage <name> <status> <exitCode> <durationMs> <detail>
  local sep=""; [[ -n "$STAGES_JSON" ]] && sep=","
  STAGES_JSON="${STAGES_JSON}${sep}$(jq -nc \
      --arg n "$1" --arg s "$2" --argjson c "$3" --argjson d "$4" --arg t "$5" \
      '{name:$n,status:$s,exitCode:$c,durationMs:$d,detail:$t}')"
}

finish() {  # finish <exitCode> <failingStage> <detail>
  if [[ -n "$JSON_OUT" ]] && command -v jq >/dev/null 2>&1; then
    jq -n --arg v "$VERSION" --arg task "$TASK" --arg wt "$WORKTREE" --arg base "$BASELINE" \
          --arg started "$STARTED_AT" --arg finished "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
          --argjson code "$1" --arg failing "$2" --arg detail "$3" \
          --argjson stages "[${STAGES_JSON}]" \
      '{verifyShVersion:$v,task:$task,worktree:$wt,baseline:$base,
        startedAt:$started,finishedAt:$finished,
        exitCode:$code,failingStage:(if $failing=="" then null else $failing end),
        detail:(if $detail=="" then null else $detail end),stages:$stages}' \
      > "$JSON_OUT" 2>/dev/null || true
  fi
  exit "$1"
}

now_ms() { python3 -c 'import time;print(int(time.time()*1000))'; }

command -v jq   >/dev/null 2>&1 || { echo "verify-sh: jq not on PATH" >&2; exit 30; }
command -v git  >/dev/null 2>&1 || { echo "verify-sh: git not on PATH" >&2; exit 30; }

[[ -n "$WORKTREE" ]] || die "--worktree is required"
[[ -d "$WORKTREE" ]] || die "worktree not found: $WORKTREE"
WORKTREE="$(cd "$WORKTREE" && pwd)" || die "cannot resolve worktree"

[[ -n "$SERVICE" ]] || SERVICE="${WORKTREE}/sample-service"
[[ -d "$SERVICE" ]] || die "service directory not found: $SERVICE (pass --service)"

REPO_ROOT="$(git -C "$SERVICE" rev-parse --show-toplevel 2>/dev/null)" \
  || die "$SERVICE is not inside a git repository"
SERVICE_REL="$(git -C "$SERVICE" rev-parse --show-prefix 2>/dev/null)" || die "cannot compute service prefix"
SERVICE_REL="${SERVICE_REL%/}"
[[ -n "$SERVICE_REL" ]] || die "service directory must not be the repository root"

# The baseline is the run's SETUP commit -- the state before the agent touched anything.
# Default to the first parent of HEAD only when there is exactly one commit after setup;
# otherwise the caller must say, because guessing a baseline silently changes every
# diff-based verdict below.
if [[ -z "$BASELINE" ]]; then
  BASELINE="$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null)" || die "cannot resolve HEAD"
fi
git -C "$REPO_ROOT" cat-file -e "${BASELINE}^{commit}" 2>/dev/null || die "baseline commit not found: $BASELINE"

# ---------------------------------------------------------------------------
# Stage 0: manifest -- is the ENFORCED allow-list the DECLARED one?
# ---------------------------------------------------------------------------
# The evaluator hardcodes ALLOWED_PRODUCTION_PREFIXES with the comment "Kept in sync with
# benchmark.yaml". That comment is the entire synchronisation mechanism: it is L3, it
# executes nothing, and the two files do not even agree on the KEY NAME -- BE-003 declares
# `allowed_production_paths` and BE-004 declares `allowed_production_prefixes`. This stage
# is the L2 version of that comment. It reads the enforced array out of the evaluator that
# actually decides, so nothing here is a third copy of the rules.
if [[ -n "$TASK" ]]; then
  [[ -n "$BENCH_ROOT" ]] || BENCH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../agent-observatory-benchmarks" 2>/dev/null && pwd)" || true
  TASK_DIR=""
  if [[ -n "$BENCH_ROOT" && -d "$BENCH_ROOT/tasks" ]]; then
    TASK_DIR="$(find "$BENCH_ROOT/tasks" -maxdepth 1 -type d -name "${TASK}-*" | head -1)"
  fi
  [[ -n "$TASK_DIR" ]] || die "cannot locate task directory for $TASK under ${BENCH_ROOT:-<unset>}"
  EVAL_SH="$TASK_DIR/evaluator.sh"; BENCH_YAML="$TASK_DIR/benchmark.yaml"
  [[ -r "$EVAL_SH"    ]] || die "evaluator not readable: $EVAL_SH"
  [[ -r "$BENCH_YAML" ]] || die "benchmark.yaml not readable: $BENCH_YAML"

  t0="$(now_ms)"
  ENFORCED="$(sed -n '/^ALLOWED_PRODUCTION_PREFIXES=(/,/^)/p' "$EVAL_SH" \
              | sed -n 's|^  *"\${SERVICE_REL}/\(.*\)"$|\1|p' | LC_ALL=C sort)"
  [[ -n "$ENFORCED" ]] || die "could not parse ALLOWED_PRODUCTION_PREFIXES out of $EVAL_SH"
  # BOTH key names start `allowed_production_p`, which is deliberate here rather than lazy:
  # BSD sed (this machine's /usr/bin/sed) does NOT support `\|` alternation in a BRE, and the
  # first version of this line used it. It matched nothing, printed nothing, and reported
  # "benchmark.yaml declares no allow-list" for BOTH tasks -- a check silently answering over
  # an empty set while looking like it had run. Caught by hand-running the parse against the
  # files before trusting its verdict, which is why §5 asks for exactly that.
  DECLARED="$(sed -n '/^allowed_production_p/,/^[a-z#]/p' "$BENCH_YAML" \
              | sed -n 's|^  *- *||p' | sed 's|^sample-service/||' | LC_ALL=C sort)"
  t1="$(now_ms)"
  if [[ -z "$DECLARED" ]]; then
    add_stage manifest warn 0 "$((t1-t0))" "benchmark.yaml declares no allow-list under either key name"
    say manifest "WARN  benchmark.yaml declares no allow-list"
  elif [[ "$ENFORCED" == "$DECLARED" ]]; then
    add_stage manifest pass 0 "$((t1-t0))" "declared == enforced ($(printf '%s\n' "$ENFORCED" | grep -c .) prefixes)"
    say manifest "PASS  declared == enforced"
  else
    add_stage manifest warn 0 "$((t1-t0))" "declared != enforced; the evaluator's array is what decides"
    say manifest "WARN  declared != enforced (evaluator wins)"
  fi
fi

# ---------------------------------------------------------------------------
# Stage 1: build -> 10
# ---------------------------------------------------------------------------
t0="$(now_ms)"
if ( cd "$SERVICE" && ./mvnw -B -q -DskipTests package >/tmp/verify-sh-build.$$.log 2>&1 ); then
  t1="$(now_ms)"; add_stage build pass 0 "$((t1-t0))" ""; say build "PASS"
else
  t1="$(now_ms)"; add_stage build fail 10 "$((t1-t0))" "see /tmp/verify-sh-build.$$.log"
  say build "FAIL  exit 10"; finish 10 build "build failed"
fi

# ---------------------------------------------------------------------------
# Stage 2: test -> 11
# ---------------------------------------------------------------------------
# The agent's OWN suite, which is the point: this is the check the task instructs the agent
# to run ("Run ./mvnw test from sample-service/ to verify your work before finishing").
# It is NOT the evaluator's acceptance suites -- those are evaluator-owned, live outside the
# worktree, and are exactly the failure class (exit 12) that nothing runnable here can see.
t0="$(now_ms)"
if ( cd "$SERVICE" && ./mvnw -B -q test >/tmp/verify-sh-test.$$.log 2>&1 ); then
  t1="$(now_ms)"; add_stage test pass 0 "$((t1-t0))" ""; say test "PASS"
else
  t1="$(now_ms)"; add_stage test fail 11 "$((t1-t0))" "see /tmp/verify-sh-test.$$.log"
  say test "FAIL  exit 11"; finish 11 test "tests failed"
fi

# ---------------------------------------------------------------------------
# Stage 3: deps -> 20   (same artifactId comparison the evaluator makes)
# ---------------------------------------------------------------------------
t0="$(now_ms)"
deps_of() { grep -oE '<artifactId>[^<]+</artifactId>' | sed -E 's|</?artifactId>||g' | LC_ALL=C sort; }
BASE_DEPS="$(git -C "$REPO_ROOT" show "${BASELINE}:${SERVICE_REL}/pom.xml" 2>/dev/null | deps_of || true)"
[[ -n "$BASE_DEPS" ]] || die "cannot read baseline pom at ${BASELINE}:${SERVICE_REL}/pom.xml"
CURR_DEPS="$(deps_of < "${SERVICE}/pom.xml" || true)"
NEW_DEPS="$(comm -13 <(printf '%s\n' "$BASE_DEPS") <(printf '%s\n' "$CURR_DEPS") | grep -c . || true)"
t1="$(now_ms)"
if [[ "$NEW_DEPS" -eq 0 ]]; then
  add_stage deps pass 0 "$((t1-t0))" ""; say deps "PASS"
else
  add_stage deps fail 20 "$((t1-t0))" "+${NEW_DEPS} new artifactId(s)"
  say deps "FAIL  exit 20 (+${NEW_DEPS})"; finish 20 deps "new dependency introduced"
fi

# ---------------------------------------------------------------------------
# Stage 4: scope -> 21   (same IGNORE_RE and same prefixes the evaluator uses)
# ---------------------------------------------------------------------------
t0="$(now_ms)"
IGNORE_RE='(^|/)(target/|\.mvn/|\.git/|\.ai/|\.claude/)|\.(log|class|jar)$|^(run|evaluation)\.json$'
CHANGED="$( { git -C "$REPO_ROOT" diff --name-only "$BASELINE" -- . 2>/dev/null || true
              git -C "$REPO_ROOT" ls-files --others --exclude-standard 2>/dev/null || true
            } | LC_ALL=C sort -u | grep -vE "$IGNORE_RE" || true )"
UNRELATED=""
if [[ -n "${ENFORCED:-}" ]]; then
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    case "$f" in "${SERVICE_REL}/src/test/"*) continue ;; esac
    ok=false
    while IFS= read -r p; do
      [[ -z "$p" ]] && continue
      case "$f" in "${SERVICE_REL}/${p}"*) ok=true; break ;; esac
    done <<< "$ENFORCED"
    [[ "$ok" == false ]] && UNRELATED="${UNRELATED}${f}"$'\n'
  done <<< "$CHANGED"
else
  add_stage scope skip 0 0 "no --task, so no allow-list to check against"
  say scope "SKIP  no --task given"
  finish 0 "" ""
fi
UNRELATED_COUNT="$(printf '%s' "$UNRELATED" | grep -c . || true)"
t1="$(now_ms)"
if [[ "$UNRELATED_COUNT" -eq 0 ]]; then
  add_stage scope pass 0 "$((t1-t0))" ""; say scope "PASS"
else
  add_stage scope fail 21 "$((t1-t0))" "$(printf '%s' "$UNRELATED" | tr '\n' ' ')"
  say scope "FAIL  exit 21 (${UNRELATED_COUNT} unrelated)"; finish 21 scope "unrelated production files changed"
fi

finish 0 "" ""
