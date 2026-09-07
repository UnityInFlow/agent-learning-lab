import subprocess, glob, os, re
ids="""e8d881b9-5fb2-406e-947a-d32e107e157a 461e2185-c4f1-4b84-b062-e9f950028eac 53597109-19f1-45f5-9e94-3bfa04a54c34
cced62d6-c532-4f31-b1f0-bdfeb62804c9 5d2373f7-bb1b-43a8-a337-68d22d235607 3ff52290-5551-4924-907c-962271ab32be
a06e80c5-6717-4cc8-9d9c-df03df5ee886 2a8a616e-05cb-4926-814a-1b46aab5592e 57a61b29-aacb-4801-afcb-ca0cc7de0452
c7e4d207-cfa6-40ef-b7be-44d73d177bba c0b6721e-e1fe-4387-9e2b-bbd46bb420de a0202230-a05b-4b1e-8b2b-0850432cfd8d
383c915b-0ce1-45ac-8c1b-1ced7c48c7b0 beae5092-71e1-4a2c-bb16-72417e50ba29 b1609bb9-45f0-400a-a2e1-a6b54d4b72a6
9fe27bf1-1e86-49e8-90a0-676b6c438d65 89ea9063-2465-47c4-a3da-3b6b82dbccec 207ff23d-d00b-4b5a-8a5e-8fbb2dcc0061""".split()
base='/var/folders/jr/lwzz65cx5pndqqdgzhnym1pc0000gn/T/observatory-run-'
print(f"{'run':10s} {'files':6s} {'outside-confirm change found':60s}")
ok=0; missing=[]
for rid in ids:
    w=base+rid
    if not os.path.isdir(w): missing.append(rid); print(f"{rid[:8]:10s} WORKTREE MISSING"); continue
    stat=subprocess.run(['git','-C',w,'diff','HEAD','--name-only'],capture_output=True,text=True).stdout.split()
    main=[f for f in stat if '/main/' in f]
    nonctrl=[f for f in main if 'ShipmentController.kt' not in f]
    d=subprocess.run(['git','-C',w,'diff','HEAD','--','*ShipmentController.kt'],capture_output=True,text=True).stdout
    # changed lines that are outside the added confirm block: doc-comment or class-level edits
    removed=[l for l in d.split('\n') if l.startswith('-') and not l.startswith('---')]
    doc=[l for l in removed if l.strip('- ').startswith('*') or 'Baseline' in l or l.strip('- ').startswith('/**')]
    reasons=[]
    if nonctrl: reasons.append('other main file(s): '+','.join(os.path.basename(f) for f in nonctrl))
    if doc: reasons.append(f'{len(doc)} removed doc/class line(s) outside confirm')
    verdict='; '.join(reasons) if reasons else 'NONE FOUND — anchor 2 would hold'
    if reasons: ok+=1
    print(f"{rid[:8]:10s} {len(main):<6d} {verdict[:60]}")
print(f"\n{ok} of {len(ids)-len(missing)} disagreeing runs carry a change outside confirm and its imports")
if missing: print("worktrees missing:", len(missing))
