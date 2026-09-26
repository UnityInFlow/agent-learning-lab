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
# THE DETECTOR IS REGISTERED HERE, IN THIS FILE, AT THREE SENSITIVITIES:
#   STRICT — a path with at least one separator AND a source/doc extension
#   LOOSE  — a bare filename with a source/doc extension, no separator required
#   PATHY  — any `a/b`-shaped value with no extension requirement at all, so that an
#            extensionless target — README, Makefile, Dockerfile, LICENSE — cannot hide.
#            §4a round 3 found that a Read of `/repo/README` scored zero under both of the
#            other two, which would have made the null narrower than the header claimed.
#            PATHY is deliberately over-inclusive: it also matches `2026/09/26` and a URL
#            path. That direction is the safe one here — a false POSITIVE makes the null
#            harder to reach, and a false negative would have made it a lie.
# The three are counted and printed SEPARATELY so a caller can tell them apart, and
# verify-retrieval-trace-probe.sh asserts that separation rather than only the exit code.
#
# SCOPE OF A HIT — read this before trusting an exit 3.
# The document-wide scan is deliberately CONSERVATIVE: it reports a hit on ANY string in
# the document, in any event, not only on a Read event. That direction is the safe one for
# the NEGATIVE result this lab exists to establish — zero hits anywhere implies zero hits
# on Read events. It is NOT safe for a positive result, because a hit may sit on a Write,
# a Grep, or a resource attribute. So telemetry mode additionally counts READ-SCOPED hits,
# at TWO scopes, printed on their own lines:
#   read_scoped_any   — any string belonging to a log record whose `tool_name` is `Read`.
#                       Conservative. A zero here is the strong form of the null.
#   read_scoped_pathy — PATHY hits inside such a record, extensionless targets included
#   read_scoped_attr  — only ATTRIBUTE VALUES of such a record, which is where a recorded
#                       target would live. When non-zero, the attribute KEYS carrying the
#                       hits are printed, because "something in the record looks like a
#                       path" and "the attribute naming the file survived" are different
#                       claims and the second is the one that would refute finding 3.
# NEITHER counter asserts that the hit IS the file that was read: a `working_directory`, a
# message body or a prompt fragment can be path-shaped. An exit 3 means "something names a
# file"; the keys tell you what to go and look at. This probe locates, it does not attribute.
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
#   5  nothing could be read: every input was empty, blank, or not JSON — NOT ONE JSON
#      document parsed. The message distinguishes "no content at all" from "content that
#      is not JSON", because the two send a reader to different places.
#      PRECEDENCE, registered: a partially unparsable input is NOT 5. Lines that fail to
#      parse are counted and reported, and the verdict is taken from what did parse — so
#      one malformed file beside one containing a hit is 3, not 5.
#   6  the input parsed but its SHAPE was not recognised — a SCHEMA MISMATCH, never an
#      empty population. Three cases, all of which previously returned a misleading 4:
#        • telemetry: documents parsed but NOT ONE log record was found (e.g. the
#          `resourceLogs` key was renamed)
#        • telemetry: log records found but NOT ONE `tool_name` attribute recognised
#        • records: a JSON object parsed but none of `runs`/`content`/`items`/`data` held
#          an array (the run array moved)
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
# At least one separator, exactly as the header says — a leading `/` counts, so
# `/Foo.kt` matches. §4a round 3 found the previous form silently required a directory
# NAME before the final component, which contradicted the documented definition.
STRICT = re.compile(
    r"(?:^|[\s\"'=(,:])(?:(?:/|\./|\.\./|~/)|(?:[A-Za-z0-9_.+-]+/))"
    r"(?:[A-Za-z0-9_.+-]+/)*[A-Za-z0-9_.+-]+\." + EXT + r"\b")
LOOSE = re.compile(r"\b[A-Za-z0-9_.+-]+\." + EXT + r"\b")
# PATHY: any separator-bearing value. No extension requirement, so an extensionless target
# cannot score zero. Over-inclusive on purpose — see the header.
PATHY = re.compile(r"(?:^|[\s\"'=(,:])(?:/|\./|\.\./|~/)?[A-Za-z0-9_.+-]+/[A-Za-z0-9_.+/-]*"
                   r"[A-Za-z0-9_.+-]")

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
        if not isinstance(a, dict):
            # §4a round 3: a `None` (or any non-dict) inside the attributes array used to
            # raise AttributeError here and exit 1, a code this probe does not register.
            continue
        key = a.get("key")
        val = a.get("value")
        if isinstance(val, dict) and val:
            out[key] = next(iter(val.values()))
        elif isinstance(val, (str, int, float)):
            out[key] = val
    return out


def classify(val):
    """(strict_hit, loose_only_hit) for one string. Mutually exclusive, STRICT first."""
    if STRICT.search(val):
        return True, False
    if LOOSE.search(val):
        return False, True
    return False, False


def pathy(val):
    """Separator-bearing, no extension needed. Counted independently of classify()."""
    return bool(PATHY.search(val))


total_strings = 0
strict_by_key = Counter()
loose_by_key = Counter()
pathy_by_key = Counter()
pathy_examples = defaultdict(list)
examples = defaultdict(list)
read_events = 0
read_scoped_any_strict = 0
read_scoped_any_loose = 0
read_scoped_attr_strict = 0
read_scoped_attr_loose = 0
read_scoped_keys = Counter()
read_scoped_pathy = 0
tool_name_attrs = 0
log_records = 0
run_ids = set()
records = 0
parsed_docs = 0
unparsable = 0
nonobject_lines = 0
records_shape_ok = False
total_bytes = 0
per_file = []

for path in sys.argv[1:]:
    f_batches = f_bad = f_strings = f_reads = f_records = f_nonobj = 0
    f_strict = f_loose = f_pathy = 0
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
                records_shape_ok = True
            elif isinstance(doc, dict):
                # §4a round 3: this used to break on the FIRST list-valued key even when it
                # was empty, so {"runs": [], "content": [ ...real runs... ]} reported zero
                # records. Prefer the first NON-EMPTY list; fall back to an empty one only
                # to record that the shape was recognised.
                for key in ("runs", "content", "items", "data"):
                    if isinstance(doc.get(key), list) and doc[key]:
                        items = doc[key]
                        records_shape_ok = True
                        break
                else:
                    for key in ("runs", "content", "items", "data"):
                        if isinstance(doc.get(key), list):
                            items = doc[key]
                            records_shape_ok = True
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
                    if pathy(val):
                        pathy_by_key[key] += 1
                        f_pathy += 1
                        if len(pathy_examples[key]) < 2:
                            pathy_examples[key].append(val[:90])
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
                if not isinstance(doc, dict):
                    # A valid JSON line that is not an object — `[]`, `"x"`, `3`. Before
                    # this guard the next line raised AttributeError and the probe exited
                    # 1, a code it does not register. Counted as a shape failure.
                    f_nonobj += 1
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
                    if pathy(val):
                        pathy_by_key[key] += 1
                        f_pathy += 1
                        if len(pathy_examples[key]) < 2:
                            pathy_examples[key].append(val[:90])
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
                                # READ-SCOPED, conservative: any string in THIS record
                                for _k, val in strings(lr):
                                    hs, hl = classify(val)
                                    if hs:
                                        read_scoped_any_strict += 1
                                    elif hl:
                                        read_scoped_any_loose += 1
                                    if pathy(val):
                                        read_scoped_pathy += 1
                                # READ-SCOPED, attributed: attribute VALUES only, with the
                                # key that carried the hit, because that is the claim that
                                # would refute finding 3
                                for akey, aval in at.items():
                                    if not isinstance(aval, str):
                                        continue
                                    hs, hl = classify(aval)
                                    if hs:
                                        read_scoped_attr_strict += 1
                                        read_scoped_keys[akey] += 1
                                    elif hl:
                                        read_scoped_attr_loose += 1
                                        read_scoped_keys[akey] += 1
    unparsable += f_bad
    nonobject_lines += f_nonobj
    total_bytes += os.path.getsize(path)
    per_file.append((path, sha256(path), f_batches, f_bad, f_strings,
                     f_reads, f_records, f_strict, f_loose, f_nonobj, f_pathy))

print(f"mode: {MODE}")
for (path, digest, b, bad, st, rd, rc, hs, hl, nonobj, hp) in per_file:
    name = os.path.basename(path)
    if MODE == "telemetry":
        print(f"  {name}  sha256:{digest}  batches={b} unparsable_lines={bad} "
              f"nonobject_lines={nonobj} strings={st} read_events={rd} "
              f"strict={hs} loose={hl} pathy={hp}")
    else:
        print(f"  {name}  sha256:{digest}  records={rc} unparsable={bad} "
              f"strings={st} strict={hs} loose={hl} pathy={hp}")

print(f"population: run_ids={len(run_ids)} "
      + (f"read_events={read_events} log_records={log_records} "
         f"tool_name_attrs={tool_name_attrs}"
         if MODE == "telemetry" else f"records={records}"))
print(f"scanned: string_values={total_strings} parsed_documents={parsed_docs} "
      f"unparsable={unparsable}")
print(f"hits: strict={sum(strict_by_key.values())} loose_only={sum(loose_by_key.values())}")
print(f"pathy: total={sum(pathy_by_key.values())} distinct_keys={len(pathy_by_key)}")
if MODE == "telemetry":
    # These two lines carry ONLY counters and end after them, so an automated check can
    # match the whole line exactly. The explanation is a separate line on purpose — an
    # earlier version appended it here, which forced the verifier into substring matching.
    print(f"read_scoped_any: strict={read_scoped_any_strict} "
          f"loose_only={read_scoped_any_loose}")
    print(f"read_scoped_attr: strict={read_scoped_attr_strict} "
          f"loose_only={read_scoped_attr_loose}")
    print(f"read_scoped_pathy: total={read_scoped_pathy}")
    if read_scoped_keys:
        print("read_scoped_attr keys: "
              + ", ".join(f"{k}={n}" for k, n in read_scoped_keys.most_common(10)))
    print("note: a non-zero read_scoped count means a value in a Read event LOOKS like a "
          "path. It does not assert that value IS the file read.")

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
    if total_bytes == 0 or (unparsable == 0 and nonobject_lines == 0):
        print("verdict: NO CONTENT — every input was empty or blank; nothing was read. "
              "This is not a measurement.")
    elif nonobject_lines and not unparsable:
        print(f"verdict: WRONG SHAPE — {nonobject_lines} line(s) were valid JSON but not "
              "JSON objects, and no object was found. Nothing was scanned.")
    else:
        print(f"verdict: NOT JSON — {unparsable} unparsable line(s), "
              f"{nonobject_lines} non-object line(s), and not one JSON object read.")
    sys.exit(EX_UNPARSABLE)

if MODE == "telemetry" and log_records == 0:
    print("verdict: SCHEMA NOT RECOGNISED — documents parsed but NOT ONE log record was "
          "found under resourceLogs[].scopeLogs[].logRecords[]. This is NOT an empty "
          "population: the probe's schema assumptions are in its header and one of them "
          "no longer holds.")
    sys.exit(EX_SCHEMA)

if MODE == "telemetry" and tool_name_attrs == 0:
    print("verdict: SCHEMA NOT RECOGNISED — log records parsed but no `tool_name` "
          "attribute found in any of them. This is NOT an empty population; the probe's "
          "schema assumptions are in its header and one of them no longer holds.")
    sys.exit(EX_SCHEMA)

if MODE == "records" and not records_shape_ok:
    print("verdict: SCHEMA NOT RECOGNISED — a JSON document parsed, but it is not an "
          "array and none of `runs`/`content`/`items`/`data` holds one. The run array "
          "has moved. This is NOT an empty population.")
    sys.exit(EX_SCHEMA)

population = read_events if MODE == "telemetry" else records
if population == 0:
    unit = "Read events" if MODE == "telemetry" else "run records"
    print(f"verdict: POPULATION EMPTY — zero {unit}. A scan of nothing proves nothing.")
    sys.exit(EX_EMPTY)

if pathy_by_key and not (strict_by_key or loose_by_key):
    print("pathy hits by JSON key: "
          + ", ".join(f"{k}={n}" for k, n in pathy_by_key.most_common(10)))
    for key, _n in pathy_by_key.most_common(3):
        if pathy_examples[key]:
            print(f"  e.g. {key} -> {pathy_examples[key][0]}")
    print("verdict: DETECTOR FIRED UNDER PATHY ONLY — a separator-bearing value exists with "
          "no source/doc extension. PATHY is deliberately over-inclusive (a date or a URL "
          "path matches it), so GO AND LOOK at the keys above before concluding anything.")
    sys.exit(EX_HIT)

if strict_by_key or loose_by_key:
    if MODE == "telemetry" and (read_scoped_attr_strict or read_scoped_attr_loose):
        print("verdict: DETECTOR FIRED ON A READ EVENT'S ATTRIBUTE — go and read the "
              "`read_scoped_attr keys` line. If one of those keys names the file read, "
              "extract finding 3 is refuted; the probe cannot decide that for you.")
    elif MODE == "telemetry" and (read_scoped_any_strict or read_scoped_any_loose):
        print("verdict: DETECTOR FIRED SOMEWHERE IN A READ EVENT, BUT NOT IN AN "
              "ATTRIBUTE VALUE — a body or nested field looks path-shaped. Weaker than "
              "the case above and not evidence that a target was recorded.")
    elif MODE == "telemetry":
        print("verdict: DETECTOR FIRED, BUT NOT ON ANY READ — something in this document "
              "names a file and nothing in any Read event does. This is NOT evidence "
              "that a read was identified.")
    else:
        print("verdict: DETECTOR FIRED — at least one value names a file. Read the `hits "
              "by JSON key` breakdown before attributing it: in records mode "
              "`result.changedFiles[]` is git diff output, i.e. WRITES.")
    sys.exit(EX_HIT)

print("verdict: NO FILE-NAMING VALUE FOUND over a non-empty population, at ANY of the "
      "three sensitivities — including PATHY, which needs no extension.")
sys.exit(EX_CLEAN)
PY
