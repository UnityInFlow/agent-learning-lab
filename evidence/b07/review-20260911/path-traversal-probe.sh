#!/usr/bin/env bash
#
# path-traversal-probe — reproduces §4a round 1's one CONFIRMED defect in the registered
# verify-v1.0 gate. READ-ONLY with respect to the registered artefact: it copies the policy
# into a scratch root and invokes the registered policy-gate.sh in place, never editing it.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
cd "$HERE/../../.." || exit 1   # evidence/b07/review-<date> -> the lab root
GATE="$PWD/build/customizations/verify-v1.0/.ai/hooks/policy-gate.sh"
POL="$PWD/build/customizations/verify-v1.0/.ai/policies/protected-paths.yaml"
tv="$(mktemp -d)" || exit 1
mkdir -p "$tv/.ai/policies" && cp "$POL" "$tv/.ai/policies/"
export CLAUDE_PROJECT_DIR="$tv" POLICY_EVENT_LOG="$tv/log.jsonl"
printf '%-42s %-8s %s\n' PATH EXIT MEANING
for p in ".github/workflows/ci.yml" "sub/../.github/workflows/ci.yml" \
         "infra/main.tf" "src/x/../../infra/main.tf" \
         "pom.xml" "sub/../pom.xml"; do
  echo "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$p\"}}" | bash "$GATE" >/dev/null 2>&1
  rc=$?
  printf '%-42s %-8s %s\n' "$p" "$rc" "$([[ $rc -eq 2 ]] && echo DENIED || echo ALLOWED)"
done
rm -rf "$tv"
