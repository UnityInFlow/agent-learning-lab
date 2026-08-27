#!/usr/bin/env bash
# Reject a run record that states a usage number without saying where it came from.
#
# The rule this enforces is P7 — "unknown data remains unknown". Every value in
# `efficiency:` carries its own provenance, so a gap is a `null` that reads as a gap
# rather than a zero that reads as a very efficient run:
#
#   inputTokens: { value: 12400, source: provider,        estimated: false }   # Level A
#   inputTokens: { value: 11950, source: local-tokenizer, estimated: true  }   # Level B
#   inputTokens: { value: null,  source: null,            estimated: null  }   # Level C
#
# Writing that shape into `templates/run-record.yaml` is Layer 3 — a template constrains
# nothing on its own, and `inputTokens: 12400` stays writable. This script is the Layer 2
# version: it executes, and it rejects.
#
#   ./tools/validate-run-record.sh                        # the template
#   ./tools/validate-run-record.sh runs/**/record.yaml    # real records
#
# Exit 0 valid · 1 usage or read error · 2 at least one record is invalid.

set -uo pipefail
# `|| exit` matters: without it a failed cd validates whatever run-record.yaml happens to
# be in the caller's directory and reports a pass for a file nobody asked about.
cd "$(dirname "$0")/.." || exit 1

files=("$@")
[ $# -eq 0 ] && files=(templates/run-record.yaml)

for f in "${files[@]}"; do
  [ -r "$f" ] || { echo "cannot read: $f" >&2; exit 1; }
done

python3 - "${files[@]}" <<'PY'
import sys

try:
    import yaml
except ImportError:
    print("PyYAML is required: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

# Every value the business case calls a usage measurement. `durationMs` is wall clock the
# runner owns and always knows, so it is not in here.
USAGE = ("inputTokens", "outputTokens", "cachedInputTokens", "cacheCreationTokens", "cost")

# source -> what `estimated` must be. A provider-reported number that claims to be an
# estimate, or a tokenizer guess that claims not to be, is a mislabelled measurement level.
SOURCE_ESTIMATED = {"provider": False, "local-tokenizer": True, "derived": True}

def check(path):
    errs = []
    try:
        doc = yaml.safe_load(open(path)) or {}
    except yaml.YAMLError as e:
        return [f"does not parse: {e}"]
    if not isinstance(doc, dict):
        return ["top level is not a mapping"]

    eff = doc.get("efficiency")
    if eff is None:
        return ["no `efficiency:` block"]
    if not isinstance(eff, dict):
        return ["`efficiency:` is not a mapping"]

    for key in USAGE:
        if key not in eff:
            errs.append(f"efficiency.{key} is missing")
            continue
        v = eff[key]

        # The failure this whole script exists for: a bare number with no provenance.
        if not isinstance(v, dict):
            shown = "empty" if v is None else repr(v)
            errs.append(
                f"efficiency.{key} is {shown}, not a provenance mapping — "
                f"use {{ value: null, source: null, estimated: null }} when it is unknown"
            )
            continue

        missing = [k for k in ("value", "source", "estimated") if k not in v]
        if missing:
            errs.append(f"efficiency.{key} is missing {', '.join(missing)}")
            continue

        value, source, estimated = v["value"], v["source"], v["estimated"]

        if value is None:
            # Level C. An unknown value may not smuggle in a source or a confidence.
            if source is not None or estimated is not None:
                errs.append(
                    f"efficiency.{key} has value: null but source={source!r} "
                    f"estimated={estimated!r} — an absent measurement has no provenance"
                )
            continue

        if not isinstance(value, (int, float)) or isinstance(value, bool):
            errs.append(f"efficiency.{key}.value is {value!r}, not a number or null")
        if source is None:
            errs.append(f"efficiency.{key} states {value!r} with source: null — where did it come from?")
        elif source not in SOURCE_ESTIMATED:
            errs.append(
                f"efficiency.{key}.source is {source!r}; expected one of "
                f"{', '.join(sorted(SOURCE_ESTIMATED))}"
            )
        elif estimated is not SOURCE_ESTIMATED[source]:
            errs.append(
                f"efficiency.{key} is source: {source} but estimated: {estimated!r} — "
                f"expected {SOURCE_ESTIMATED[source]}"
            )
        elif not isinstance(estimated, bool):
            errs.append(f"efficiency.{key}.estimated is {estimated!r}, not a boolean")

    # A record that reports every counter as zero and says nothing about whether telemetry
    # arrived is the BehaviorDto failure in a different file.
    m = doc.get("measurement")
    if isinstance(m, dict) and "telemetryComplete" not in m:
        errs.append("measurement.telemetryComplete is missing — a gap must not read as a zero")

    return errs

bad = 0
for path in sys.argv[1:]:
    errs = check(path)
    if errs:
        bad = 1
        print(f"INVALID  {path}")
        for e in errs:
            print(f"    {e}")
    else:
        print(f"ok       {path}")
sys.exit(2 if bad else 0)
PY
