#!/usr/bin/env bash
# retrieval-trace-probe.sh — can this instrument name what a run READ?
#
# Spine stop 19, Phase 6B, Lab 6B.6. Read-only. Invokes no model and costs nothing.
#
# It scans one of two stages of the observatory pipeline for a value from which the
# identity of a file could be recovered, and reports what it found. It does NOT judge:
# a hit in `result.changedFiles` is expected (that field records writes) and a hit on a
# Read event would refute extract finding 3.
#
# THE DETECTOR IS REGISTERED HERE, IN THIS FILE, AT TWO SENSITIVITIES:
#   STRICT — a path with at least one separator and a source/doc extension
#   LOOSE  — a bare filename with a source/doc extension, no separator required
# LOOSE exists so that a null cannot be an artefact of STRICT being too strict. The two
# are counted and printed SEPARATELY so a caller can tell them apart, and
# verify-retrieval-trace-probe.sh asserts that separation rather than only the exit code.
#
# SCOPE OF A HIT — read this before trusting an exit 3.
# The document-wide scan is deliberately CONSERVATIVE: it reports a hit on ANY string in
# the document, in any event, not only on a Read event. That direction is the safe one for
# the NEGATIVE result this lab exists to establish — zero hits anywhere implies zero hits
# on Read events. It is NOT safe for a positive result, because a hit may sit on a Write,
# a Grep, or a resource attribute. So telemetry mode additionally counts
# READ-SCOPED hits — hits on strings belonging to a log record whose `tool_name` is
# `Read` — and prints them on their own line. An exit 3 means "something in this document
# names a file"; only a non-zero read_scoped count means "a READ was identified".
#
# SCHEMA THIS PROBE ASSUMES, stated because nothing in a synthetic fixture can catch a
# wrong assumption (this is why exit 6 exists):
#   • telemetry input is one OTLP JSON object per line, with
#     resourceLogs[].scopeLogs[].logRecords[]
#   • a log record's attributes are `[{key: <name>, value: {<type>: <value>}}]` — a
#     NESTED single-key dict, not a flat string
#   • the tool name lives under the attribute key `tool_name`
#   • the run id lives under the attribute key `observatory.run.id`
#   • records input is a JSON array, or an object with a `runs`/`content`/`items`/`data`
#     array, whose members carry `runId`
# If telemetry input parses and contains log records but NOT ONE `tool_name` attribute is
# recognised, the schema has moved and the probe exits 6 rather than reporting an empty
# population — because "zero reads" and "I cannot read this format" are different answers.
#
# Usage:  retrieval-trace-probe.sh telemetry <events.jsonl> [more.jsonl ...]
#         retrieval-trace-probe.sh records   <runs.json>
#
# REGISTERED-EXIT-CODES: 0 2 3 4 5 6
#   (this line is machine-read by verify-retrieval-trace-probe.sh, which fails if the set
#    it exercises differs from the set declared here — so a new code cannot be added
#    without a case demanding it)
#
#   0  scan completed, population NON-EMPTY, and NO value matched either sensitivity
#   3  scan completed and at least one value matched somewhere in the document. Read the
#      `read_scoped` line before concluding a READ was identified.
#   4  population EMPTY for this mode (telemetry: zero Read events among recognised tool
#      events; records: zero records). A scan of nothing proves nothing, and this code
#      exists so that "found no path" can never be returned by a run that looked at
#      nothing.
#   5  input present but unparsable: NOT ONE JSON document could be read from any input.
#      PRECEDENCE, registered: a partially unparsable input is NOT 5. Lines that fail to
#      parse are counted and reported, and the verdict is taken from what did parse — so
#      one malformed file beside one containing a hit is 3, not 5.
#   6  telemetry input parsed and holds log records, but no `tool_name` attribute was
#      recognised in any of them: a SCHEMA MISMATCH, not an empty population.
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

EX_CLEAN, EX_HIT, EX_EMPTY, EX_UNPARSABLE, EX_SCHEMA = 0, 3, 4, 5, 6


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
    """Attribute list -> dict. Assumes the nested {key, value:{<type>: v}} OTLP shape;
    a flat string value is also accepted so a format change shows up as a recognised
    tool_name rather than as a silent zero."""
    out = {}
    for a in node.get("attributes", []) or []:
        key = a.get("key")
        val = a.get("value")
        if isinstance(val, dict) and val:
            out[key] = next(iter(val.values()))
        elif isinstance(val, (str, int, float)):
            out[key] = val
    return out


def classify(val):
    """(strict_hit, loose_only_hit) for one string."""
    if STRICT.search(val):
        return True, False
    if LOOSE.search(val):
        return False, True
    return False, False


total_strings = 0
strict_by_key = Counter()
loose_by_key = Counter()
examples = defaultdict(list)
read_events = 0
read_scoped_strict = 0
read_scoped_loose = 0
tool_name_attrs = 0
log_records = 0
run_ids = set()
records = 0
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
                    hs, hl = classify(val)
                    if hs:
                        strict_by_key[key] += 1
                        f_strict += 1
                        if len(examples[key]) < 2:
                            examples[key].append(val[:90])
                    elif hl:
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
                parsed_docs += 1
                for key, val in strings(doc):
                    f_strings += 1
                    total_strings += 1
                    hs, hl = classify(val)
                    if hs:
                        strict_by_key[key] += 1
                        f_strict += 1
                        if len(examples[key]) < 2:
                            examples[key].append(val[:90])
                    elif hl:
                        loose_by_key[key] += 1
                        f_loose += 1
                for rl in doc.get("resourceLogs", []) or []:
                    for sl in rl.get("scopeLogs", []) or []:
                        for lr in sl.get("logRecords", []) or []:
                            log_records += 1
                            at = attrs_of(lr)
                            if "tool_name" in at:
                                tool_name_attrs += 1
                            if at.get("observatory.run.id"):
                                run_ids.add(at["observatory.run.id"])
                            if at.get("tool_name") == "Read":
                                f_reads += 1
                                read_events += 1
                                # READ-SCOPED: only strings belonging to THIS record
                                for _k, val in strings(lr):
                                    hs, hl = classify(val)
                                    if hs:
                                        read_scoped_strict += 1
                                    elif hl:
                                        read_scoped_loose += 1
    unparsable += f_bad
    per_file.append((path, sha256(path), f_batches, f_bad, f_strings,
                     f_reads, f_records, f_strict, f_loose))

print(f"mode: {MODE}")
for (path, digest, b, bad, st, rd, rc, hs, hl) in per_file:
    name = os.path.basename(path)
    if MODE == "telemetry":
        print(f"  {name}  sha256:{digest}  batches={b} unparsable_lines={bad} "
              f"strings={st} read_events={rd} strict={hs} loose={hl}")
    else:
        print(f"  {name}  sha256:{digest}  records={rc} unparsable={bad} "
              f"strings={st} strict={hs} loose={hl}")

print(f"population: run_ids={len(run_ids)} "
      + (f"read_events={read_events} log_records={log_records} "
         f"tool_name_attrs={tool_name_attrs}"
         if MODE == "telemetry" else f"records={records}"))
print(f"scanned: string_values={total_strings} parsed_documents={parsed_docs} "
      f"unparsable={unparsable}")
print(f"hits: strict={sum(strict_by_key.values())} loose_only={sum(loose_by_key.values())}")
if MODE == "telemetry":
    print(f"read_scoped: strict={read_scoped_strict} loose_only={read_scoped_loose}"
          "   <- ONLY a non-zero value here means a READ was identified")

distinct = len(strict_by_key) + len(loose_by_key)
if strict_by_key or loose_by_key:
    print(f"hits by JSON key: {distinct} distinct key(s); showing up to 10 per sensitivity")
    for key, n in strict_by_key.most_common(10):
        ex = examples[key][0] if examples[key] else ""
        print(f"  strict {n:7d}  {key}   e.g. {ex}")
    for key, n in loose_by_key.most_common(10):
        print(f"  loose  {n:7d}  {key}")
    if len(strict_by_key) > 10 or len(loose_by_key) > 10:
        print("  *** TRUNCATED — the counts above the line are complete, this listing is not")

# --- verdict. Precedence is registered in the header and is: unparsable-everything,
# --- then schema mismatch, then empty population, then detection, then clean.
if parsed_docs == 0:
    print("verdict: INPUT UNPARSABLE — not one JSON document read from any input")
    sys.exit(EX_UNPARSABLE)

if MODE == "telemetry" and log_records > 0 and tool_name_attrs == 0:
    print("verdict: SCHEMA NOT RECOGNISED — log records parsed but no `tool_name` "
          "attribute found in any of them. This is NOT an empty population; the probe's "
          "schema assumptions are in its header and one of them no longer holds.")
    sys.exit(EX_SCHEMA)

population = read_events if MODE == "telemetry" else records
if population == 0:
    unit = "Read events" if MODE == "telemetry" else "run records"
    print(f"verdict: POPULATION EMPTY — zero {unit}. A scan of nothing proves nothing.")
    sys.exit(EX_EMPTY)

if strict_by_key or loose_by_key:
    if MODE == "telemetry" and (read_scoped_strict or read_scoped_loose):
        print("verdict: DETECTOR FIRED, AND ON A READ — a value on a Read event names a "
              "file. This would refute extract finding 3.")
    elif MODE == "telemetry":
        print("verdict: DETECTOR FIRED, BUT NOT ON ANY READ — something in this document "
              "names a file and no Read event does. Read the read_scoped line above; this "
              "is NOT evidence that a read was identified.")
    else:
        print("verdict: DETECTOR FIRED — at least one value names a file. Read the `hits "
              "by JSON key` breakdown before attributing it: in records mode "
              "`result.changedFiles[]` is git diff output, i.e. WRITES.")
    sys.exit(EX_HIT)

print("verdict: NO FILE-NAMING VALUE FOUND over a non-empty population.")
sys.exit(EX_CLEAN)
PY
