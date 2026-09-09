#!/usr/bin/env bash
# Prove count-state-reread.py separates the four shapes it must, one fixture each.
#
# It decides E-012/E-013's P3, so it is not a report-only helper: a counter that has never been
# shown to say `no` is indistinguishable from one that always says YES. Its first version said
# `no` to a run the registered sheet scored 2 (helper call sites), which is fixture C.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
REL="sample-service/src/test/kotlin/T.kt"
pass=0; fail=0

mk() { # mk <name> <body>
  mkdir -p "$TMP/$1/$(dirname "$REL")"; printf '%s\n' "$2" > "$TMP/$1/$REL"
}
mk A '    fun t() {
        mockMvc.perform(post("/shipments/S-1/confirm")).andExpect(status().isOk)
        mockMvc.perform(get("/shipments/S-1")).andExpect(status().isOk)
    }'
mk B '    fun t() {
        mockMvc.perform(post("/shipments/S-1/confirm")).andExpect(status().isOk)
        mockMvc.perform(post("/shipments/S-1/confirm")).andExpect(status().isOk)
    }'
# shellcheck disable=SC2016  # the Kotlin fixture must contain a literal $id, not an expansion
mk C '    private fun confirmShipment(id: String) = post("/shipments/$id/confirm")
    fun t() {
        mockMvc.perform(confirmShipment("S-4")).andExpect(status().isOk)
        mockMvc.perform(get("/shipments/S-4")).andExpect(status().isOk)
    }'
mk D '    fun t() {
        mockMvc.perform(get("/shipments/S-1")).andExpect(status().isOk)
        mockMvc.perform(post("/shipments/S-1/confirm")).andExpect(status().isOk)
    }'

MAN="$TMP/manifest.tsv"
{
  printf 'seq\tarm\trun\texit\twt\n'
  printf '01\ttreated\tr1\t0\t%s\n' "$TMP/A"
  printf '02\ttreated\tr2\t0\t%s\n' "$TMP/B"
  printf '03\ttreated\tr3\t0\t%s\n' "$TMP/C"
  printf '04\ttreated\tr4\t0\t%s\n' "$TMP/D"
  printf '01\tcontrol\tr5\t0\t%s\n' "$TMP/nonexistent"
} > "$MAN"

out="$(./tools/count-state-reread.py "$MAN" "$REL")"
echo "$out"
check() {
  local name="$1" want="$2"
  if grep -qF -e "$want" <<<"$out"; then echo "  ok   — $name"; pass=$((pass+1))
  else echo "  FAIL — $name: expected '$want'"; fail=$((fail+1)); fi
}
check "A: get after a literal /confirm is a re-read"        "01:YES"
check "B: a second confirm with no get is NOT a re-read"     "02:no"
check "C: get after a HELPER call site is a re-read"         "03:YES"
check "D: a get BEFORE the confirm is not a re-read"         "04:no"
check "E: a missing worktree is NOFILE, not a silent no"     "01:NOFILE"
check "treated tally is 2 of 4"                              "-> 2 of 4"

echo ""
echo "verify-count-state-reread: $pass passed, $fail failed"
[[ "$fail" == "0" ]] || exit 1
