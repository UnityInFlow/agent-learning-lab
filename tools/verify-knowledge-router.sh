#!/usr/bin/env bash
#
# verify-knowledge-router — the fixture set for v1.2's knowledge router.
#
# WHY IT EXISTS, in the words §4 step 4 puts it in: *a control that has never been shown to
# reject anything is indistinguishable from one that rejects nothing.* The router is the one
# executing artifact of spine stop 20 and the source of the experiment's delivery proof
# (decision-rule row 0). Every exit code it documents is driven here against a synthetic index,
# on the real script, with no benchmark run and no model call.
#
# THE CASES, and each one is a condition the router claims to distinguish:
#   A  hit, single topic                                 -> 0, two paths, log status=hit
#   B  hit, query in CAPS (matching is case-insensitive)  -> 0
#   C  hit on a MULTI-WORD trigger                       -> 0
#   D  miss                                              -> 2, nothing on stdout, log status=miss
#   E  no query at all                                   -> 1, log status=usage
#   F  index file missing                                -> 3
#   G  index present, no `topics:` key                   -> 3
#   H  `topics:` present, zero topics parsed             -> 3
#   I  matched topic has no `details:` key               -> 3
#   J  summary path names a file that does not exist     -> 4
#   K  details path names a file that does not exist     -> 4
#   L  two topics match the same query                   -> 5
#   M  the log is appended on EVERY outcome              -> one line per invocation above
#   N  THE SHIPPED INDEX answers the query the overlay's CLAUDE.md tells the agent to ask,
#      and both paths it prints exist                    -> 0
#   O  THE VERIFIER IS SHOWN TO REFUSE: a deliberately broken copy of the router (miss made to
#      exit 0) must FAIL case D. If it passes, these assertions are not checking anything.
#
# Usage: tools/verify-knowledge-router.sh
# Exit:  0 every case behaved as specified; 1 a case failed.
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
LAB="$PWD"
ROUTER="$LAB/build/customizations/agent-v1.2-knowledge/.ai/knowledge/router.sh"
SHIPPED_INDEX="$LAB/build/customizations/agent-v1.2-knowledge/.ai/knowledge/index.yaml"
[[ -x "$ROUTER" ]] || { echo "verify-knowledge-router: $ROUTER is not executable" >&2; exit 1; }

WORK="$(mktemp -d)" || exit 1
trap 'rm -rf "$WORK"' EXIT
PASS=0; FAIL=0
LOG="$WORK/knowledge-log.jsonl"

expect() {  # expect <rc> <label>   — uses $RC from the last run
  if [[ "$RC" -eq "$1" ]]; then ok "$2"; else bad "$2" "rc=$RC (wanted $1)"; fi
}

ok()   { PASS=$((PASS+1)); printf '  ok    %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL  %s — %s\n' "$1" "$2"; }

# run <index> <query...>   — stdout in OUT, rc in RC, stderr left in $WORK/err
run() {
  local idx="$1"; shift
  OUT="$( KNOWLEDGE_INDEX="$idx" KNOWLEDGE_EVENT_LOG="$LOG" "$ROUTER" "$@" 2>"$WORK/err" )"
  RC=$?
}

# --- the synthetic corpora -------------------------------------------------------------
mk_good() {  # a well-formed one-topic index with both documents present
  local d="$WORK/good"; mkdir -p "$d/summaries" "$d/documents"
  printf 'summary body\n' > "$d/summaries/t.md"
  printf 'details body\n' > "$d/documents/t.md"
  cat > "$d/index.yaml" <<'Y'
topics:
  alpha:
    triggers:
      - widget
      - spinning plate
    summary: summaries/t.md
    details: documents/t.md
Y
  echo "$d/index.yaml"
}
mk_two() {  # two topics sharing a trigger the query will hit
  local d="$WORK/two"; mkdir -p "$d/summaries" "$d/documents"
  printf 'a\n' > "$d/summaries/t.md"; printf 'b\n' > "$d/documents/t.md"
  cat > "$d/index.yaml" <<'Y'
topics:
  alpha:
    triggers:
      - widget
    summary: summaries/t.md
    details: documents/t.md
  beta:
    triggers:
      - widget
    summary: summaries/t.md
    details: documents/t.md
Y
  echo "$d/index.yaml"
}
mk_plain() {  # <name> <body> — an index file with arbitrary contents
  local d="$WORK/$1"; mkdir -p "$d"; printf '%s' "$2" > "$d/index.yaml"; echo "$d/index.yaml"
}
mk_nodetails() {
  local d="$WORK/nodet"; mkdir -p "$d/summaries"; printf 'a\n' > "$d/summaries/t.md"
  cat > "$d/index.yaml" <<'Y'
topics:
  alpha:
    triggers:
      - widget
    summary: summaries/t.md
Y
  echo "$d/index.yaml"
}
mk_missing() {  # <which> — a topic whose summary or details path does not exist
  local d="$WORK/missing-$1"; mkdir -p "$d/summaries" "$d/documents"
  if [[ "$1" == "summary" ]]; then printf 'b\n' > "$d/documents/t.md"
  else printf 'a\n' > "$d/summaries/t.md"; fi
  cat > "$d/index.yaml" <<'Y'
topics:
  alpha:
    triggers:
      - widget
    summary: summaries/t.md
    details: documents/t.md
Y
  echo "$d/index.yaml"
}

echo "verify-knowledge-router: 15 cases against $ROUTER"
GOOD="$(mk_good)"

# A — hit
run "$GOOD" "I need a widget"
if [[ "$RC" -eq 0 ]] && [[ "$(printf '%s\n' "$OUT" | wc -l | tr -d ' ')" == "2" ]] \
   && printf '%s' "$OUT" | grep -q 'summaries/t.md' && printf '%s' "$OUT" | grep -q 'documents/t.md'; then
  ok "A hit -> 0 with summary then details"
else bad "A hit" "rc=$RC out=[$OUT]"; fi
# the ORDER is part of the contract: summary first, details second
if [[ "$(printf '%s\n' "$OUT" | head -1)" == *"summaries/t.md" ]]; then ok "A order: summary printed first"
else bad "A order" "first line was [$(printf '%s\n' "$OUT" | head -1)]"; fi

# B — case-insensitive
run "$GOOD" "I NEED A WIDGET"
expect 0 "B hit on an upper-case query -> 0"

# C — multi-word trigger
run "$GOOD" "this is a spinning plate problem"
expect 0 "C hit on a multi-word trigger -> 0"

# D — miss
run "$GOOD" "how do I write a Dockerfile"
if [[ "$RC" -eq 2 && -z "$OUT" ]]; then ok "D miss -> 2 with empty stdout"
else bad "D miss" "rc=$RC out=[$OUT]"; fi

# E — usage
run "$GOOD"
expect 1 "E no query -> 1"

# F — index missing
run "$WORK/does-not-exist/index.yaml" "widget"
expect 3 "F index file missing -> 3"

# G — no topics: key
run "$(mk_plain notopics 'something: else
')" "widget"
expect 3 "G no topics: key -> 3"

# H — topics: present, zero topics
run "$(mk_plain empty 'topics:
')" "widget"
expect 3 "H zero topics parsed -> 3"

# I — matched topic has no details:
run "$(mk_nodetails)" "widget"
expect 3 "I topic without a details: key -> 3"

# J / K — a path that is not readable
run "$(mk_missing summary)" "widget"
expect 4 "J summary file absent -> 4"
run "$(mk_missing details)" "widget"
expect 4 "K details file absent -> 4"

# L — two topics match
run "$(mk_two)" "widget"
if [[ "$RC" -eq 5 && -z "$OUT" ]]; then ok "L two topics match -> 5 with empty stdout"
else bad "L ambiguous" "rc=$RC out=[$OUT]"; fi

# M — the log carries one line per invocation, whatever the outcome.
# TWELVE, counted rather than summed: A B C D E F G H I J K L each invoke the router once,
# `A order` re-reads A's stdout without invoking, and case N runs AFTER this check. The first
# version of this line said 13 and failed on its own arithmetic, which is the method lesson
# stop 19 recorded and the reason the number is derived here in writing.
EXPECT_LINES=12
LINES="$(grep -c . "$LOG" 2>/dev/null || echo 0)"
if [[ "$LINES" -eq "$EXPECT_LINES" ]]; then ok "M log has one line per invocation ($EXPECT_LINES)"
else bad "M log line count" "expected $EXPECT_LINES, got $LINES"; fi
if jq -e . "$LOG" >/dev/null 2>&1; then ok "M every log line is valid JSON"
else bad "M log JSON" "jq rejected a line"; fi
for s in hit miss usage malformed unreadable ambiguous; do
  grep -q "\"status\":\"$s\"" "$LOG" || bad "M status=$s never logged" "absent from $LOG"
done
ok "M all six statuses appear in the log"

# N — THE SHIPPED INDEX, with the query the overlay's own CLAUDE.md tells the agent to ask
run "$SHIPPED_INDEX" "I am about to branch on a status enum"
if [[ "$RC" -eq 0 ]]; then
  miss=0
  while IFS= read -r p; do [[ -r "$p" ]] || { miss=1; echo "    unreadable: $p"; }; done <<<"$OUT"
  if [[ "$miss" -eq 0 ]]; then ok "N the shipped index answers and both paths exist"
  else bad "N shipped corpus" "a printed path is not readable"; fi
else bad "N shipped index" "rc=$RC on the registered query"; fi

# O — THE VERIFIER IS SHOWN TO REFUSE. A broken router that returns 0 on a miss must make
# case D fail; if case D still passes, these assertions test nothing.
BROKEN="$WORK/broken-router.sh"
sed 's/^  exit 2$/  exit 0/' "$ROUTER" > "$BROKEN" && chmod +x "$BROKEN"
if ! grep -q 'emit miss' "$BROKEN"; then bad "O mutant" "the mutation did not land"; else
  bout="$( KNOWLEDGE_INDEX="$GOOD" KNOWLEDGE_EVENT_LOG="$WORK/broken.jsonl" "$BROKEN" "how do I write a Dockerfile" 2>/dev/null )"
  brc=$?
  if [[ "$brc" -eq 2 ]]; then bad "O refusal" "the mutant still exits 2 — the mutation was inert"
  elif [[ "$brc" -eq 0 && -z "$bout" ]]; then ok "O the mutant exits 0 on a miss, so case D would FAIL — the assertion bites"
  else bad "O refusal" "mutant rc=$brc out=[$bout]"; fi
fi

echo ""
echo "verify-knowledge-router: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] || exit 1
exit 0
