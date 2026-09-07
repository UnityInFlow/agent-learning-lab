#!/usr/bin/env python3
"""Collect the four registered scores from E-008's twenty codex sheets (arm F + control).

    ./collect-sheets.py <findings/codex dir> <manifest.tsv> [<manifest-2.tsv> ...]

E-008's batch is two manifests (pairs 01-05 and 06-10, see the instrument-fault note in the
experiment file); they concatenate here and the assertion is on the registered TWENTY.

Reads only the sheets; asserts every one carries the REGISTERED rubric sha and that all
four categories parse. A sheet that is present but unparseable is an ERROR, not a null:
`null` is a measurement, a missing cell is not (§6). This script exists because the first
extraction pass read one sheet WHILE IT WAS STILL BEING WRITTEN and reported four missing
cells that were in fact scored — a presence check on a FILENAME claiming to be a check on
a sheet.
"""
import re, sys, glob, os, statistics as st

RUBRIC_SHA = '396e1799eb2b'
CATS = ['architecture-consistency', 'maintainability', 'test-quality', 'change-focus']
sheets_dir, manifests = sys.argv[1], sys.argv[2:]

arm = {}
for manifest in manifests:
  for line in open(manifest):
    if line.startswith('#'):
        continue
    p = line.rstrip('\n').split('\t')
    if p[0] == 'seq':
        continue
    arm[p[2]] = p[1]                      # full run id -> F | control
assert len(arm) == 20, f'{len(arm)} run ids across {len(manifests)} manifest(s); registered 20'

rows = []
for rid, a in arm.items():
    fs = sorted(glob.glob(os.path.join(sheets_dir, f'score-observatory-run-{rid}-2026*.yaml')))
    assert fs, f'no sheet for {rid}'
    t = open(fs[-1]).read()               # newest sheet for this run
    sha = re.search(r'rubric_sha:\s*(\S+)', t).group(1)
    assert sha == RUBRIC_SHA, f'{rid}: rubric {sha} is not the registered {RUBRIC_SHA}'
    sc = {}
    for c in CATS:
        m = re.search(r'name:\s*"' + re.escape(c) + r'"\s*\n\s*score:\s*(\S+)', t)
        assert m, f'{rid}: category {c} did not parse from {os.path.basename(fs[-1])}'
        sc[c] = m.group(1).strip()
    rows.append((rid, 'F' if a == 'F' else 'C', sc, os.path.basename(fs[-1])))

assert len(rows) == 20, f'expected 20 sheets, parsed {len(rows)}'
print(f'20 sheets, every one at rubric {RUBRIC_SHA}, every category parsed.\n')
h = f"{'run':9} {'arm':4} " + " ".join(f"{c[:13]:>13}" for c in CATS)
print(h); print('-' * len(h))
for rid, a, sc, _ in sorted(rows, key=lambda r: r[1], reverse=True):
    print(f"{rid[:8]:9} {a:4} " + " ".join(f"{sc[c]:>13}" for c in CATS))
print('\nPER-ARM, n = 10 each (median; nulls counted separately, never as 0). the registered outcome is the COUNT of test-quality == 2 per arm, printed below the raw rows.')
for c in CATS:
    out = f"  {c:26}"
    for a in ('F', 'C'):
        v = [int(sc[c]) for _, aa, sc, _ in rows if aa == a and sc[c] != 'null']
        n = sum(1 for _, aa, sc, _ in rows if aa == a and sc[c] == 'null')
        out += f"   {a}: median {st.median(v):>3} (n={len(v)}, nulls={n})"
    print(out)
print('\nRAW, in manifest order')
for c in CATS:
    for a in ('F', 'C'):
        print(f"  {c:26} {a}: " + ' '.join(sc[c] for _, aa, sc, _ in rows if aa == a))

print('\ntest-quality anchor 2 COUNT per arm (null counted as not-2, reported)')
for a in ('F', 'C'):
    two = sum(1 for _, aa, sc, _ in rows if aa == a and sc['test-quality'] == '2')
    nul = sum(1 for _, aa, sc, _ in rows if aa == a and sc['test-quality'] == 'null')
    print(f"  {a}: anchor 2 on {two} of 10  (nulls {nul})")
