#!/usr/bin/env python3
"""THE NEGATIVE CONTROL. Not a tool — do not score a run with this.

    ./tools/naive-phase-checker.py <transcript.jsonl>

This is the phase checker a reasonable person writes first: concatenate the assistant text,
grep for the six markers, pass if all six are there. It is committed for one reason — the
claim "check-phase-contract.py catches what a text-only checker misses" is worth nothing
unless the text-only checker is a fixed, runnable file rather than a description.

That gap was found by a validator: findings/track-b-validation-2026-09-07-2.md (pass 18,
claude-fable-5-1) §2.2. The lab commit that introduced the real checker registered
`10 of 11 fixtures reject it` from a scratch file that no longer existed, so nobody could
reproduce the number, and the validator's own rewrite scored a different split — a difference
between two uncommitted naive checkers, which is exactly the ambiguity a committed control
removes. `RUNNER_UNDER_TEST` already gives verify-agent-delivery.sh this property; this file
gives it to verify-phase-contract-checker.sh.

The point it demonstrates, on fixture C: a run that edits the repository in turn two and
prints all six markers in its closing message comes back PASS (6 of 6 markers) here, and
`code was written before DESIGN` from the real checker. Same transcript, opposite verdicts.

Exit 0 six markers found · 2 fewer than six · 3 the input is not readable as a transcript.
"""
import json
import sys

PHASES = ["ANALYSIS", "DESIGN", "IMPLEMENTATION", "VERIFICATION", "REVIEW", "DONE"]


def main():
    if len(sys.argv) != 2:
        print("usage: naive-phase-checker.py <transcript.jsonl>", file=sys.stderr)
        return 3
    text = []
    try:
        fh = open(sys.argv[1], encoding="utf-8")
    except OSError as exc:
        print("naive: UNUSABLE — %s" % exc)
        return 3
    with fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                print("naive: UNUSABLE — not stream-json")
                return 3
            if not isinstance(obj, dict) or obj.get("type") != "assistant":
                continue
            content = (obj.get("message") or {}).get("content") or []
            if isinstance(content, str):
                content = [{"type": "text", "text": content}]
            for block in content:
                if isinstance(block, dict) and block.get("type") == "text":
                    text.append(block.get("text") or "")

    body = "\n".join(text)
    missing = [p for p in PHASES if "<<PHASE:%s>>" % p not in body]
    print("naive: %s (%d of 6 markers)%s"
          % ("FAIL" if missing else "PASS", 6 - len(missing),
             (" missing: " + ", ".join(missing)) if missing else ""))
    return 2 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
