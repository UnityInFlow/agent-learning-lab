#!/usr/bin/env python3
"""detach — run a command in its OWN process session, and record that it did.

WHY THIS FILE EXISTS. A benchmark batch is a child of the claude session that launches it, and §0's
phase-boundary rule *requires* that session to end. On 2026-09-26 that killed two B9 batches: the
second at 17:45:01Z, after four pairs, with a fifth run complete and unrowed. The EXIT trap had
fired, so it was a signal and not a crash.

macOS ships no setsid(1). os.setsid() is the same call. After it, this process is a session leader
in a new process group, so a group signal aimed at the launching shell's group cannot reach it or
the command it runs.

The first three lines of the log are the PROOF, not a claim: pid, pgid and sid, printed from the
detached process itself. If sid == pid the detach happened; if it does not, it did not, and the
caller must not believe the launch survived a boundary.

Usage: detach.py <logfile> <cmd> [args...]
"""
import datetime
import os
import subprocess
import sys

if len(sys.argv) < 3:
    sys.stderr.write("usage: detach.py <logfile> <cmd> [args...]\n")
    sys.exit(2)

logfile, cmd = sys.argv[1], sys.argv[2:]

try:
    os.setsid()
except OSError as exc:  # already a session leader, or job control put us in our own group
    sys.stderr.write("detach: setsid failed (%s) — NOT detached, refusing to launch\n" % exc)
    sys.exit(3)

with open(logfile, "ab", buffering=0) as fh:
    started = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    fh.write(("=== detached launch %s\n" % started).encode())
    fh.write(("=== pid=%d pgid=%d sid=%d  (sid == pid means the detach happened)\n"
              % (os.getpid(), os.getpgid(0), os.getsid(0))).encode())
    fh.write(("=== cmd: %s\n" % " ".join(cmd)).encode())
    fh.flush()
    rc = subprocess.run(cmd, stdout=fh, stderr=subprocess.STDOUT, check=False).returncode
    ended = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    fh.write(("=== exit %d at %s\n" % (rc, ended)).encode())
sys.exit(rc)
