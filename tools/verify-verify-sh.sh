#!/usr/bin/env bash
#
# verify-verify-sh — the fixture set for tools/verify-sh.sh.
#
# Every exit code verify-sh can return gets a case that PRODUCES it. A verification script
# that has only ever been seen to return 0 is indistinguishable from one that always
# returns 0, and this project has already shipped a blocking defect behind ShellCheck-clean
# code with nine green fixtures (tools/check-sheet-categories.sh, 2026-08-28).
#
# Fixtures are BUILT here rather than committed: each is a throwaway git repository with a
# stub `mvnw` whose success is controlled by marker files. That keeps the cases honest --
# verify-sh really does invoke `./mvnw` and really does read its exit status -- without a
# 60-90s Maven build per case, and without six checked-in Kotlin trees that would drift.
#
# Usage: tools/verify-verify-sh.sh        exit 0 if every case returns its registered code
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 30
VERIFY="$PWD/tools/verify-sh.sh"
BENCH="$(cd ../agent-observatory-benchmarks && pwd)" || { echo "benchmarks repo not found" >&2; exit 30; }
export VERIFY_BENCH_ROOT="$BENCH"

PASS=0; FAIL=0; N=0
ok()   { N=$((N+1)); PASS=$((PASS+1)); printf '  ok   %-46s exit %s\n' "$1" "$2"; }
bad()  { N=$((N+1)); FAIL=$((FAIL+1)); printf '  FAIL %-46s expected %s, got %s\n' "$1" "$2" "$3"; }

# build_fixture <dir> — a minimal repo shaped like sample-service, committed as the baseline
build_fixture() {
  local d="$1"
  mkdir -p "$d/sample-service/src/main/kotlin/com/unityinflow/sample/shipment" \
           "$d/sample-service/src/main/kotlin/com/unityinflow/sample/api" \
           "$d/sample-service/src/test/kotlin"
  cat > "$d/sample-service/pom.xml" <<'POM'
<project>
  <artifactId>sample-service</artifactId>
  <dependencies>
    <dependency><artifactId>spring-boot-starter-web</artifactId></dependency>
    <dependency><artifactId>kotlin-stdlib</artifactId></dependency>
  </dependencies>
</project>
POM
  cat > "$d/sample-service/mvnw" <<'MVNW'
#!/usr/bin/env bash
# Stub. Fails the stage whose marker file exists, so a case can produce a real non-zero
# exit from a real invocation without a real Maven build.
for a in "$@"; do
  case "$a" in
    package) [ -f "$(dirname "$0")/FAIL_PACKAGE" ] && exit 1 ;;
    test)    [ -f "$(dirname "$0")/FAIL_TEST" ]    && exit 1 ;;
  esac
done
exit 0
MVNW
  chmod +x "$d/sample-service/mvnw"
  echo 'class Shipment' > "$d/sample-service/src/main/kotlin/com/unityinflow/sample/shipment/Shipment.kt"
  git -C "$d" init -q
  git -C "$d" config user.email v@example.com; git -C "$d" config user.name v
  git -C "$d" add -A >/dev/null; git -C "$d" commit -q -m baseline
  git -C "$d" rev-parse HEAD
}

run_case() {  # run_case <name> <expected-exit> <mutator-function>
  local name="$1" want="$2" mut="$3" d base got
  d="$(mktemp -d)"; base="$(build_fixture "$d")"
  "$mut" "$d"
  "$VERIFY" --worktree "$d" --task BE-003 --baseline "$base" --quiet \
            --json "$d/verify.json" >/dev/null 2>&1
  got=$?
  if [[ "$got" == "$want" ]]; then ok "$name" "$got"; else bad "$name" "$want" "$got"; fi
  # every non-30 case must also have written a parseable JSON summary naming its stage
  if [[ "$want" != 30 && -f "$d/verify.json" ]]; then
    if jq -e '.exitCode != null and (.stages | length) > 0' "$d/verify.json" >/dev/null 2>&1; then
      ok "$name :: json summary is well-formed" 0
    else
      bad "$name :: json summary is well-formed" "well-formed" "malformed"
    fi
  fi
  rm -rf "$d"
}

m_clean()      { :; }
m_solved()     { echo 'fun confirm() {}' >> "$1/sample-service/src/main/kotlin/com/unityinflow/sample/shipment/Shipment.kt"; }
m_test_added() { echo 'class T' > "$1/sample-service/src/test/kotlin/T.kt"; }
m_build_fail() { touch "$1/sample-service/FAIL_PACKAGE"; }
m_test_fail()  { touch "$1/sample-service/FAIL_TEST"; }
m_new_dep()    { sed -i '' 's|</dependencies>|<dependency><artifactId>archunit</artifactId></dependency></dependencies>|' "$1/sample-service/pom.xml"; }
m_out_of_scope(){ mkdir -p "$1/sample-service/src/main/kotlin/com/unityinflow/sample/billing"
                  echo 'class Billing' > "$1/sample-service/src/main/kotlin/com/unityinflow/sample/billing/Billing.kt"; }
m_root_scratch(){ echo scratch > "$1/notes.md"; }
m_ignored_only(){ mkdir -p "$1/sample-service/target"; echo x > "$1/sample-service/target/out.class"
                  echo y > "$1/sample-service/build.log"; }
m_overlay_only(){ mkdir -p "$1/.ai/policies" "$1/.claude"
                  echo '{}' > "$1/.claude/settings.json"; echo 'deny: []' > "$1/.ai/policies/protected-paths.yaml"
                  echo '{"decision":"allow"}' > "$1/.ai/policy-events.jsonl"; }

echo "verify-verify-sh: fixture set for tools/verify-sh.sh"
echo

echo "exit 0 — nothing wrong:"
run_case "clean worktree, no changes"                    0  m_clean
run_case "legitimate change in an allowed prefix"        0  m_solved
run_case "a test file added (always allowed)"            0  m_test_added
run_case "only ignored paths changed (target/, *.log)"   0  m_ignored_only
run_case "only the B7 overlay's own files changed"       0  m_overlay_only

echo
echo "exit 10 — build failure:"
run_case "mvnw package fails"                            10 m_build_fail

echo
echo "exit 11 — tests failed:"
run_case "mvnw test fails, package succeeds"             11 m_test_fail

echo
echo "exit 20 — new dependency:"
run_case "an artifactId added to pom.xml"                20 m_new_dep

echo
echo "exit 21 — unrelated production files:"
run_case "a production file outside every allowed prefix" 21 m_out_of_scope
run_case "a scratch file at the repository root"          21 m_root_scratch

echo
echo "exit 30 — verify-sh's own failure, never the submission's:"
D="$(mktemp -d)"
"$VERIFY" --quiet >/dev/null 2>&1; [[ $? == 30 ]] && ok "no --worktree" 30 || bad "no --worktree" 30 "$?"
"$VERIFY" --worktree /nonexistent-$$ --quiet >/dev/null 2>&1; [[ $? == 30 ]] && ok "worktree does not exist" 30 || bad "worktree does not exist" 30 "$?"
mkdir -p "$D/empty"; "$VERIFY" --worktree "$D/empty" --quiet >/dev/null 2>&1
[[ $? == 30 ]] && ok "no sample-service inside the worktree" 30 || bad "no sample-service inside the worktree" 30 "$?"
B2="$(build_fixture "$D/f")"; "$VERIFY" --worktree "$D/f" --task BE-999 --baseline "$B2" --quiet >/dev/null 2>&1
[[ $? == 30 ]] && ok "unknown --task" 30 || bad "unknown --task" 30 "$?"
"$VERIFY" --worktree "$D/f" --baseline deadbeefdeadbeefdeadbeefdeadbeefdeadbeef --quiet >/dev/null 2>&1
[[ $? == 30 ]] && ok "baseline commit does not exist" 30 || bad "baseline commit does not exist" 30 "$?"
"$VERIFY" --worktree "$D/f" --nonsense --quiet >/dev/null 2>&1
[[ $? == 30 ]] && ok "unknown argument" 30 || bad "unknown argument" 30 "$?"
rm -rf "$D"

echo
echo "manifest stage — declared vs enforced allow-list:"
for T in BE-003 BE-004; do
  D="$(mktemp -d)"; B3="$(build_fixture "$D")"
  "$VERIFY" --worktree "$D" --task "$T" --baseline "$B3" --quiet --json "$D/v.json" >/dev/null 2>&1
  st="$(jq -r '.stages[] | select(.name=="manifest") | .status' "$D/v.json" 2>/dev/null)"
  if [[ "$st" == "pass" ]]; then ok "$T declared == enforced" 0
  else bad "$T declared == enforced" "pass" "${st:-<no manifest stage>}"; fi
  rm -rf "$D"
done

echo
echo "  $PASS of $N cases pass"
[[ "$FAIL" -eq 0 ]] || exit 1
exit 0
