#!/usr/bin/env bash
#
# verify-b11-resume-seeding — the fixture set for the two manifest-header defects recorded at
# stop 26 and fixed on 2026-10-05, after the batch closed (§4 step 4 forbids editing a tool while
# a run of it is in flight, and 11 rows of that population came from the unfixed file).
#
# DEFECT 1  the header printed a HARDCODED `# prediction commit ef2c6c0 at 2026-09-26` — which is
#           real, and is STOP 20's prediction commit, carried over when this driver was derived
#           from stop 20's. Now derived from $PREDICTION_COMMIT through git, or explicitly absent.
# DEFECT 2  TREATED_N and ROW0A were re-zeroed at every launch while H1..H5 and the ceiling were
#           seeded from the manifest, so a resumed batch printed `over 9 treated run(s)` above
#           mechanism counts of 20: the counts manifest-wide, the denominator one launch's.
#
# Exercised through the driver's own `B11_RESUME_PLAN_ONLY=1 --resume <tag>` path, which reads a
# manifest and runs nothing. Cases:
#   A  the REAL closed batch manifest .......... TREATED_N=20 ROW0A=0 H1=0 H2=H3=H5=20
# The synthetic tags are 1999 timestamps: --resume validates the TAG SHAPE, so a fixture tag
# must look like a batch tag, and a 1999 one can never collide with a real batch.
#   B  synthetic, 3 treated, one MISSING ....... TREATED_N=3  ROW0A=1
#   C  synthetic, a CONTROL that LEAKED ........ TREATED_N=1  ROW0A=1  (the arm the first fix missed)
#   D  no hardcoded prediction sha survives, and both header branches exist
#   E  a manifest with no header row ........... seeds all zero, no crash
set -uo pipefail
LAB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" || exit 1
cd "$LAB" || exit 1
DRIVER="$LAB/evidence/b11/run-b11-batch.sh"
EVID="$LAB/evidence/b11"
PASS=0; FAIL=0
SCRATCH="${TMPDIR:-/tmp}/b11-reseed-$$"; mkdir -p "$SCRATCH" || exit 1
MADE=()
# Invoked only through the EXIT trap below — shellcheck cannot see that, hence the disable.
# shellcheck disable=SC2329
cleanup() {
  rm -rf "$SCRATCH"
  local t
  for t in "${MADE[@]:-}"; do [[ -n "$t" ]] && rm -rf "$EVID/batch-$t"; done
  return 0
}
trap cleanup EXIT

HDR=$'task\tseq\tarm\trun_id\trc\teval\tf13\tedits\truntime_ver\tmodel\tinstr_hash\tagent_hash\tagents_hash\thooks_hash\tbudget_lines\tbudget_blocks\tcache_lines\tcache_blocks\tcache_stale\tdedup_lines\tdedup_blocks\tclassify\toverlay_files\tmodel_calls\ttool_calls\tcost\tduration_ms\tchanged\tinit_tools\tworktree'

row() {  # row <arm> <seq> <overlay_files>
  printf 'BE-003\t%s\t%s\trid-%s%s\t0\t0\tno\t3\t2.1.285\tclaude-haiku-4-5-20251001\tsha\tsha\tsha\tnull\t11\t0\t15\t0\t0\t7\t0\tABSENT\t%s\t19\t18\t0.1\t95000\t3\tn=4\tNONE\n' \
    "$2" "$1" "$1" "$2" "$3"
}

# The three shas and the `n=` line are what --resume validates before it reads a single row
# (run-b11-batch.sh:241-252), so a fixture manifest has to carry them or the case never reaches the
# seeding it is testing. They are the REGISTERED values of this stop, quoted deliberately.
FIX_AGENT=sha256:b3450564b6f32d6193e8580db766210e
FIX_INSTR_T=sha256:1cb0ea105099353da3e8048b1a923687
FIX_INSTR_C=sha256:a94237242e8c1308fb1d434a06a03463

mk() {  # mk <tag> <body-file>
  local tag="$1" body="$2"
  local d="$EVID/batch-$tag"
  mkdir -p "$d"
  {
    printf '# B11 REGISTERED BATCH %s  n=10 per arm per task, interleaved (author decision 9)\n' "$tag"
    printf '# *** SYNTHETIC FIXTURE MANIFEST, verify-b11-resume-seeding. NOT A BATCH. Deleted on exit.\n'
    printf '# expected agentHash BOTH arms %s; instructionsHash treated %s / control %s\n' \
      "$FIX_AGENT" "$FIX_INSTR_T" "$FIX_INSTR_C"
    cat "$body"
  } > "$d/manifest.tsv"
  MADE+=("$tag")
}

seeds() {  # seeds <tag> -> the seeded line, or empty
  ( B11_RESUME_PLAN_ONLY=1 "$DRIVER" --resume "$1" 2>/dev/null | sed -n 's/^resume-plan: seeded //p' ) || true
}

ck() {  # ck <name> <expected> <actual>
  if [[ "$3" == *"$2"* ]]; then
    PASS=$((PASS+1)); printf '  ok   case %s  %s\n' "$1" "$2"
  else
    FAIL=$((FAIL+1)); printf '  FAIL case %s  expected to contain "%s", got "%s"\n' "$1" "$2" "${3:-<empty>}"
  fi
}

ck A "TREATED_N=20 ROW0A=0 H1=0 H2=20 H3=20 H5=20" "$(seeds 20260930T115342Z)"

{ printf '%s\n' "$HDR"; row treated 01 "8/8"; row treated 02 "6/8 MISSING:.ai/hooks/summary-cache.sh"; row treated 03 "8/8"; } > "$SCRATCH/b.tsv"
mk 19990101T000001Z "$SCRATCH/b.tsv"
ck B "TREATED_N=3 ROW0A=1" "$(seeds 19990101T000001Z)"

{ printf '%s\n' "$HDR"; row treated 01 "8/8"; row control 01 "LEAK-INTO-CONTROL:3"; } > "$SCRATCH/c.tsv"
mk 19990101T000002Z "$SCRATCH/c.tsv"
ck C "TREATED_N=1 ROW0A=1" "$(seeds 19990101T000002Z)"

printf '# nothing but a comment\n' > "$SCRATCH/e.tsv"
mk 19990101T000003Z "$SCRATCH/e.tsv"
ck E "TREATED_N=0 ROW0A=0 H1=0 H2=0 H3=0 H5=0" "$(seeds 19990101T000003Z)"

# Only PRINTF lines count: the fix's own comment quotes the old hardcoded header verbatim, on
# purpose, and a check that failed on the explanation of a defect would be unfixable.
if grep -E "^[[:space:]]*printf" "$DRIVER" | grep -qE "prediction commit [0-9a-f]{7}"; then
  FAIL=$((FAIL+1)); printf '  FAIL case D  a hardcoded prediction sha is still in the driver\n'
else
  PASS=$((PASS+1)); printf '  ok   case D  no hardcoded prediction sha in the driver\n'
fi
if grep -q 'PREDICTION_COMMIT' "$DRIVER" && grep -q 'NOT SUPPLIED to this driver' "$DRIVER"; then
  PASS=$((PASS+1)); printf '  ok   case D  both header branches exist: derived from git, or absent\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case D  the derived/absent branches are not both present\n'
fi

printf 'verify-b11-resume-seeding: %s ok, %s failed.\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]] || exit 1
printf 'verify-b11-resume-seeding: all %s cases behaved as specified.\n' "$PASS"
exit 0
