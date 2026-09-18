#!/usr/bin/env python3
"""MUTANT (all-statuses) of tools/render-spine-status.py; verify-render-spine-status.sh must fail on it.

Render the spine status paragraph from a Track B state file.

The workspace CLAUDE.md status paragraph has gone stale three times because it is written by
hand; its own text says it "should be generated from TRACK-B-STATE.md". This prints that
paragraph to stdout and writes nothing. Wiring it into CLAUDE.md is the author's call.

    python3 tools/render-spine-status.py TRACK-B-STATE.md

Reads the first `status:` line. The comment is the text after the first `#`, cut at the first
`SUPERSEDED, kept not deleted`: nothing after that marker is ever printed, because it is the
history of halts that no longer hold. Refuses (stderr, empty stdout, exit 1) a missing file, a
file with no `status:` line, and a status word other than running, blocked or done.
"""
import os
import re
import subprocess
import sys

WORDS = ("running", "blocked", "done")
MARKER = "SUPERSEDED, kept not deleted"
STATUS_LINE = re.compile(r"^status:\s*(\S+)")


def refuse(msg):
    print(f"render-spine-status: {msg}", file=sys.stderr)
    sys.exit(1)


def provenance(path):
    directory = os.path.dirname(os.path.abspath(path))
    try:
        out = subprocess.run(
            ["git", "-C", directory, "log", "-1", "--format=%h", "--", os.path.abspath(path)],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return "uncommitted"
    return out or "uncommitted"


def main(argv):
    if len(argv) != 2:
        refuse("usage: render-spine-status.py <state-file>")
    path = argv[1]
    try:
        with open(path, encoding="utf-8") as f:
            lines = f.read().splitlines()
    except OSError as e:
        refuse(f"cannot read {path}: {e.strerror}")

    line = next((l for l in lines if STATUS_LINE.match(l)), None)
    if line is None:
        refuse(f"{path} has no 'status:' line")
    word = STATUS_LINE.match(line).group(1)
    if word not in WORDS:
        refuse(f"{path} has status '{word}', expected one of {', '.join(WORDS)}")

    comment = line.split("#", 1)[1] if "#" in line else ""
    comment = comment.split(MARKER, 1)[0].strip()

    parts = [f"**Status: {word}**" + (f" — {comment}" if comment else "")]
    parts += [f"**Status: {w}**" for w in WORDS if w != word]  # MUTANT: every word
    parts.append(f"*Generated from `{path}` at {provenance(path)}.*")
    print("\n\n".join(parts))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
