#!/usr/bin/env bash
#
# corpus-access-census.sh — READ-ONLY. How did each treated run of a B9 batch touch the corpus?
#
# WHY THIS EXISTS. E-022/E-023 register `H` as "treated runs whose knowledge log is non-empty",
# and the log is written by `.ai/knowledge/router.sh` and by nothing else. So `H` counts ROUTER
# INVOCATIONS. It does not count a run that opened `.ai/knowledge/summaries/*.md` with the Read
# tool, or `cat`-ed it, or read `index.yaml` and followed the path by hand. Those runs consulted
# the corpus and score `H = 0`, indistinguishable in the decision rule from a run that ignored
# the instruction entirely. This script measures that gap on runs already on disk. It moves no
# registered variable, re-scores nothing, and computes no verdict.
#
# THE DETECTOR EXCLUDES THE HARNESS'S OWN OUTPUT BY SHAPE, NOT BY BLACKLIST. run-agent.sh prints
# `customization installed from <dir>` and `claude args: ... Bash(.ai/knowledge/router.sh:*)` and
# echoes the overlay's file list, so a plain `grep router.sh` counts the harness on every run —
# the defect run-b9-batch.sh already records twice on one line. Every count below is anchored to
# a stream-json tool_use envelope (`"name":"Bash","input":{"command":"` /
# `"name":"Read","input":{"file_path":"`), which the harness never emits.
#
# EXIT 0 always on a readable batch; 2 on a missing batch directory, 3 on a batch with no
# treated logs. Proved by tools/verify-corpus-access-census.sh.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 2
BATCH="${1:-}"
[[ -n "$BATCH" ]] || { echo "usage: corpus-access-census.sh <batch-tag-or-dir>" >&2; exit 2; }
DIR="$BATCH"; [[ -d "$DIR" ]] || DIR="evidence/b09/batch-$BATCH"
[[ -d "$DIR" ]] || { echo "census: no such batch directory: $DIR" >&2; exit 2; }
shopt -s nullglob
LOGS=("$DIR"/*-treated.log)
[[ ${#LOGS[@]} -gt 0 ]] || { echo "census: $DIR holds no *-treated.log" >&2; exit 3; }

# One tool_use envelope per count. `-o | wc -l` and never `grep -c`: two tool calls can share one
# stream-json line, and grep -c would count that line once.
n_of() { /usr/bin/grep -ao "$1" "$2" 2>/dev/null | /usr/bin/wc -l | tr -d ' '; }

printf 'log\trouter_exec\tindex_read\tsummary_read\tdetails_read\tcorpus_cat\tany_direct\tclassification\n'
for L in "${LOGS[@]}"; do
  bash_cmd='"name":"Bash","input":{"command":"[^"]*'
  read_fp='"name":"Read","input":{"file_path":"[^"]*'
  rx=$(n_of "${bash_cmd}router\.sh" "$L")
  ir=$(( $(n_of "${read_fp}\.ai/knowledge/index\.yaml" "$L") ))
  sr=$(( $(n_of "${read_fp}\.ai/knowledge/summaries/" "$L") ))
  dr=$(( $(n_of "${read_fp}\.ai/knowledge/documents/" "$L") ))
  cc=$(( $(n_of "${bash_cmd}\(cat\|head\|tail\|less\|sed\|awk\|grep\)[^\"]*\.ai/knowledge/" "$L") ))
  direct=$(( ir + sr + dr + cc ))
  if   [[ "$rx" -gt 0 && "$direct" -gt 0 ]]; then cls="router+direct"
  elif [[ "$rx" -gt 0 ]];                    then cls="router-only"
  elif [[ "$direct" -gt 0 ]];                then cls="DIRECT-ONLY-invisible-to-H"
  else                                            cls="no-contact"
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(basename "$L" .log)" "$rx" "$ir" "$sr" "$dr" "$cc" "$direct" "$cls"
done
exit 0
