#!/usr/bin/env bash
# population-overlap.sh — intersect the run-record population with the telemetry
# population, because the difference of two population SIZES is a net and never a
# count of the missing members. Stop 19, Lab 6B.6's §5 independence row, which
# first carried that inference and was wrong.
#
# Usage: population-overlap.sh <runs-snapshot.json> <telemetry-dir>
# Exit 0 on success, 2 on usage error.
set -uo pipefail

if [[ $# -ne 2 ]]; then
  printf 'usage: %s <runs-snapshot.json> <telemetry-dir>\n' "${0##*/}" >&2
  exit 2
fi

if [[ ! -f "$1" ]]; then
  printf '%s: no such file: %s\n' "${0##*/}" "$1" >&2
  exit 2
fi

if [[ ! -d "$2" ]]; then
  printf '%s: no such directory: %s\n' "${0##*/}" "$2" >&2
  exit 2
fi

python3 - "$1" "$2" <<'PY'
import json
import os
import sys

snap, base = sys.argv[1], sys.argv[2]
doc = json.load(open(snap))
items = doc if isinstance(doc, list) else doc.get("runs", [])
records = {r["runId"] for r in items if isinstance(r, dict) and r.get("runId")}

telemetry = set()
files = sorted(f for f in os.listdir(base) if f.startswith("events") and f.endswith(".jsonl"))
for fn in files:
    with open(os.path.join(base, fn)) as fh:
        for line in fh:
            try:
                d = json.loads(line)
            except Exception:
                continue
            for rl in d.get("resourceLogs", []) or []:
                for sl in rl.get("scopeLogs", []) or []:
                    for lr in sl.get("logRecords", []) or []:
                        for a in lr.get("attributes", []) or []:
                            if a.get("key") == "observatory.run.id" and a.get("value"):
                                telemetry.add(next(iter(a["value"].values())))

print("telemetry files:", ", ".join(files))
print(f"records: {len(records)}")
print(f"telemetry run ids: {len(telemetry)}")
print(f"intersection: {len(records & telemetry)}")
print(f"records with NO telemetry on disk: {len(records - telemetry)}")
print(f"telemetry run ids with NO record: {len(telemetry - records)}")
print(f"naive difference of sizes (a NET, not a count): {len(records) - len(telemetry)}")
PY
