import subprocess,os,re,glob,hashlib,collections
ids=['e8d881b9-5fb2-406e-947a-d32e107e157a']+[l.strip() for l in open('/tmp/owed-ids.txt') if l.strip()]
base='/var/folders/jr/lwzz65cx5pndqqdgzhnym1pc0000gn/T/observatory-run-'
def cf(p):
    t=open(p).read()
    if 'categories:' not in t: return None
    blk=t[t.find('categories:'):]
    m=re.search(r'-\s*name:\s*"?change-focus"?(.*?)(?=\n\s*-\s*name:|\Z)',blk,re.S)
    return re.search(r'score:\s*(\S+)',m.group(1)).group(1)
rows=[]
for rid in ids:
    w=base+rid
    # the whole main-source change, normalised: drop hunk headers and index lines
    d=subprocess.run(['git','-C',w,'diff','HEAD','--','*/main/*'],capture_output=True,text=True).stdout
    norm='\n'.join(l for l in d.split('\n') if not l.startswith(('index ','@@','--- ','+++ ','diff --git')))
    h=hashlib.sha256(norm.encode()).hexdigest()[:8]
    fs=[p for p in sorted(glob.glob(f'findings/opencode/score-observatory-run-{rid}-*.yaml')) if cf(p)]
    cx=[p for p in sorted(glob.glob(f'findings/codex/score-observatory-run-{rid}-*.yaml')) if cf(p)]
    rows.append((h,rid[:8],cf(fs[-1]),cf(cx[-1]) if cx else '?'))
g=collections.defaultdict(list)
for h,r,o,c in rows: g[h].append((r,o,c))
print(f'{len(rows)} runs fall into {len(g)} distinct main-source diffs\n')
split=0
for h,v in sorted(g.items(), key=lambda kv:-len(kv[1])):
    scores=collections.Counter(x[1] for x in v); cxs=collections.Counter(x[2] for x in v)
    flag=''
    if len(scores)>1: split+=1; flag='  <-- SAME DIFF, DIFFERENT SECOND-READER SCORE'
    print(f'diff {h}  n={len(v):2d}  second reader {dict(scores)}  codex {dict(cxs)}{flag}')
print(f'\ndiff groups where the second reader disagrees with itself: {split}')
