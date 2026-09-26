#!/usr/bin/env bash
# retrieval-trace-probe.sh — can this instrument name what a run READ?
#
# Spine stop 19, Phase 6B, Lab 6B.6. Read-only. Invokes no model and costs nothing.
#
# It scans one of two stages of the observatory pipeline for a value from which the
# identity of a file could be recovered, and reports what it found. It does NOT judge:
# a hit in `result.changedFiles` is expected (that field records writes) and a hit in
# telemetry would refute extract finding 3.
#
# THE DETECTOR IS REGISTERED HERE, IN THIS FILE, AT TWO SENSITIVITIES:
#   STRICT — a path with at least one separator and a source/doc extension
#   LOOSE  — a bare filename with a source/doc extension, no separator required
# LOOSE exists so that a null cannot be an artefact of STRICT being too strict.
#
# Usage:  retrieval-trace-probe.sh telemetry <events.jsonl> [more.jsonl ...]
#         retrieval-trace-probe.sh records   <runs.json>
#
# Registered exit codes — every one is proved by a fixture in
# evidence/p06b/verify-retrieval-trace-probe.sh:
#   0  scan completed, population NON-EMPTY, and NO value matched either sensitivity
#   3  scan completed and at least one value matched (the detector fired)
#   4  population EMPTY for this mode (telemetry: zero Read events; records: zero
#      records). A scan of nothing proves nothing, and this code exists so that
#      "found no path" can never be returned by a run that looked at nothing.
#   5  input present but unparsable: no JSON object could be read from any line
#   2  usage error, unknown mode, or an input file that does not exist
set -uo pipefail

PROG=${0##*/}

usage() {
  printf 'usage: %s telemetry <events.jsonl> [more.jsonl ...]\n' "$PROG" >&2
  printf '       %s records   <runs.json>\n' "$PROG" >&2
}

if [[ $# -lt 2 ]]; then
  usage
  exit 2
fi

MODE=$1
shift

case "$MODE" in
  telemetry | records) ;;
  *)
    printf '%s: unknown mode %q\n' "$PROG" "$MODE" >&2
    usage
    exit 2
    ;;
esac

if [[ "$MODE" == records && $# -ne 1 ]]; then
  printf '%s: records mode takes exactly one input file\n' "$PROG" >&2
  exit 2
fi

for f in "$@"; do
  if [[ ! -f "$f" ]]; then
    printf '%s: no such input file: %s\n' "$PROG" "$f" >&2
    exit 2
  fi
done

MODE="$MODE" python3 - "$@" <<'PY'
import hashlib
import json
import os
import re
import sys
from collections import Counter, defaultdict

MODE = os.environ["MODE"]
EXT = (r"(?:kt|kts|py|md|sh|ya?ml|json|jsonl|ts|tsx|js|jsx|java|txt|sql|toml|xml"
       r"|gradle|properties|html|csv)")
STRICT = re.compile(
    r"(?:^|[\s\"'=(,:])(?:/|\./|\.\./|~/)?(?:[A-Za-z0-9_.+-]+/)+[A-Za-z0-9_.+-]+\." + EXT + r"\b")
LOOSE = re.compile(r"\b[A-Za-z0-9_.+-]+\." + EXT + r"\b")

EX_CLEAN, EX_HIT, EX_EMPTY, EX_UNPARSABLE = 0, 3, 4, 5


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()[:16]


def strings(obj, path=""):
    """Every string value in the document, with the JSON key path that holds it."""
    if isinstance(obj, dict):
        for k, v in obj.items():
            yield from strings(v, f"{path}.{k}" if path else k)
    elif isinstance(obj, list):
        for v in obj:
            yield from strings(v, path + "[]")
    elif isinstance(obj, str):
        yield path, obj


def attrs_of(node):
    out = {}
    for a in node.get("attributes", []) or []:
        val = a.get("value")
        if isinstance(val, dict) and val:
            out[a.get("key")] = next(iter(val.values()))
    return out


total_strings = 0
strict_by_key = Counter()
loose_by_key = Counter()
examples = defaultdict(list)
read_events = 0
run_ids = set()
records = 0
batches = 0
parsed_docs = 0
unparsable = 0
per_file = []

for path in sys.argv[1:]:
    f_batches = f_bad = f_strings = f_reads = f_records = 0
    f_strict = f_loose = 0
    with open(path) as fh:
        if MODE == "records":
            try:
                doc = json.load(fh)
                parsed_docs += 1
            except Exception:
                doc, f_bad = None, 1
            items = []
            if isinstance(doc, list):
                items = doc
            elif isinstance(doc, dict):
                for key in ("runs", "content", "items", "data"):
                    if isinstance(doc.get(key), list):
                        items = doc[key]
                        break
            for rec in items:
                f_records += 1
                records += 1
                if isinstance(rec, dict) and rec.get("runId"):
                    run_ids.add(rec["runId"])
                for key, val in strings(rec):
                    f_strings += 1
                    total_strings += 1
                    if STRICT.search(val):
                        strict_by_key[key] += 1
                        f_strict += 1
                        if len(examples[key]) < 2:
                            examples[key].append(val[:90])
                    elif LOOSE.search(val):
                        loose_by_key[key] += 1
                        f_loose += 1
            if f_records:
                f_batches = 1
        else:
            for line in fh:
                if not line.strip():
                    continue
                try:
                    doc = json.loads(line)
                except Exception:
                    f_bad += 1
                    continue
                f_batches += 1
                batches += 1
                parsed_docs += 1
                for key, val in strings(doc):
                    f_strings += 1
                    total_strings += 1
                    if STRICT.search(val):
                        strict_by_key[key] += 1
                        f_strict += 1
                        if len(examples[key]) < 2:
                            examples[key].append(val[:90])
                    elif LOOSE.search(val):
                        loose_by_key[key] += 1
                        f_loose += 1
                for rl in doc.get("resourceLogs", []) or []:
                    for sl in rl.get("scopeLogs", []) or []:
                        for lr in sl.get("logRecords", []) or []:
                            at = attrs_of(lr)
                            if at.get("observatory.run.id"):
                                run_ids.add(at["observatory.run.id"])
                            if at.get("tool_name") == "Read":
                                f_reads += 1
                                read_events += 1
    unparsable += f_bad
    per_file.append((path, sha256(path), f_batches, f_bad, f_strings,
                     f_reads, f_records, f_strict, f_loose))

print(f"mode: {MODE}")
for (path, digest, b, bad, st, rd, rc, hs, hl) in per_file:
    name = os.path.basename(path)
    if MODE == "telemetry":
        print(f"  {name}  sha256:{digest}  batches={b} unparsable={bad} "
              f"strings={st} read_events={rd} strict={hs} loose={hl}")
    else:
        print(f"  {name}  sha256:{digest}  records={rc} unparsable={bad} "
              f"strings={st} strict={hs} loose={hl}")

print(f"population: run_ids={len(run_ids)} "
      + (f"read_events={read_events}" if MODE == "telemetry" else f"records={records}"))
print(f"scanned: string_values={total_strings}")
print(f"hits: strict={sum(strict_by_key.values())} loose_only={sum(loose_by_key.values())}")

if strict_by_key or loose_by_key:
    print("hits by JSON key:")
    for key, n in strict_by_key.most_common(10):
        ex = examples[key][0] if examples[key] else ""
        print(f"  strict {n:7d}  {key}   e.g. {ex}")
    for key, n in loose_by_key.most_common(10):
        print(f"  loose  {n:7d}  {key}")

population = read_events if MODE == "telemetry" else records
if population == 0:
    if parsed_docs == 0:
        print("verdict: input unparsable — no JSON document read from any input")
        sys.exit(EX_UNPARSABLE)
    unit = "Read events" if MODE == "telemetry" else "run records"
    print(f"verdict: POPULATION EMPTY — zero {unit}. A scan of nothing proves nothing.")
    sys.exit(EX_EMPTY)

if strict_by_key or loose_by_key:
    print("verdict: DETECTOR FIRED — at least one value names a file.")
    sys.exit(EX_HIT)

print("verdict: NO FILE-NAMING VALUE FOUND over a non-empty population.")
sys.exit(EX_CLEAN)
PY
