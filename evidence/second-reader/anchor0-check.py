import subprocess, os, re
ids=['e8d881b9-5fb2-406e-947a-d32e107e157a']+[l.strip() for l in open('/tmp/owed-ids.txt') if l.strip()]
base='/var/folders/jr/lwzz65cx5pndqqdgzhnym1pc0000gn/T/observatory-run-'
F='sample-service/src/main/kotlin/com/unityinflow/sample/shipment/ShipmentController.kt'
UNNAMED=('create','getById','list')
def method_ranges(text):
    """baseline line ranges (1-based, inclusive) of each unnamed method, from its @-annotation
    line through the last line before the next annotation/decl or EOF."""
    lines=text.split('\n'); marks=[]
    for i,l in enumerate(lines):
        m=re.match(r'\s*fun (\w+)\(', l)
        if m: marks.append((i, m.group(1)))
    out={}
    for j,(i,name) in enumerate(marks):
        start=i
        # walk back over annotation lines
        while start>0 and lines[start-1].strip().startswith('@'): start-=1
        end=(marks[j+1][0]-1) if j+1<len(marks) else len(lines)-1
        # trim trailing blanks / closing brace
        while end>start and lines[end].strip() in ('','}'): end-=1
        out[name]=(start+1,end+1)
    return out
summary={'anchor0_holds':0,'one_method':0,'none':0}
detail=[]
for rid in ids:
    w=base+rid
    if not os.path.isdir(w): detail.append((rid[:8],'WORKTREE MISSING')); continue
    baseline=subprocess.run(['git','-C',w,'show','HEAD:'+F],capture_output=True,text=True).stdout
    rng=method_ranges(baseline)
    d=subprocess.run(['git','-C',w,'diff','HEAD','-U0','--',F],capture_output=True,text=True).stdout
    touched=set()
    for h in re.finditer(r'^@@ -(\d+)(?:,(\d+))? \+', d, re.M):
        s=int(h.group(1)); n=int(h.group(2) or 1)
        if n==0: continue           # pure insertion, touches no baseline line
        for name in UNNAMED:
            a,b=rng[name]
            if s<=b and s+n-1>=a: touched.add(name)
    k=len(touched)
    if k>=2: summary['anchor0_holds']+=1
    elif k==1: summary['one_method']+=1
    else: summary['none']+=1
    detail.append((rid[:8], sorted(touched) or 'no unnamed method touched'))
print('runs checked:', len(ids))
print('anchor 0 holds (2+ unnamed methods differ):', summary['anchor0_holds'])
print('exactly one unnamed method differs      :', summary['one_method'])
print('no unnamed method differs               :', summary['none'])
seen=set()
for r,t in detail:
    if str(t) not in seen: seen.add(str(t)); print('  example', r, t)
