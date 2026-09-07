import glob, re, json, sys, collections
base='/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/'
def parse(path):
    txt=open(path).read()
    if 'categories:' not in txt: return None
    cats={}
    name=None
    for line in txt.splitlines():
        m=re.match(r'\s*-\s*name:\s*(\S+)', line)
        if m: name=m.group(1).strip(chr(34)+chr(39)); continue
        m=re.match(r'\s*score:\s*(\S+)', line)
        if m and name:
            v=m.group(1)
            cats[name]= None if v=='null' else int(v)
            name=None
    sha=re.search(r'rubric_sha:\s*(\S+)', txt)
    return cats, (sha.group(1) if sha else None)
ids=[l.strip() for l in open('/tmp/owed-ids.txt') if l.strip()]
ids=['e8d881b9-5fb2-406e-947a-d32e107e157a']+ids
rows=[]
for rid in ids:
    op=[p for p in sorted(glob.glob(base+f'findings/opencode/score-observatory-run-{rid}-*.yaml')) if parse(p)]
    cx=[p for p in sorted(glob.glob(base+f'findings/codex/score-observatory-run-{rid}-*.yaml')) if parse(p)]
    if not op or not cx:
        rows.append((rid,'MISSING', 'op' if not op else '', 'cx' if not cx else '')); continue
    o,osha=parse(op[-1]); c,csha=parse(cx[-1])
    rows.append((rid,'ok',o,c,osha,csha))
agree=collections.Counter(); total=collections.Counter(); diffs=[]
for r in rows:
    if r[1]!='ok': print('MISSING', r[0], r[2], r[3]); continue
    _,_,o,c,osha,csha=r
    for k in set(o)|set(c):
        total[k]+=1
        if o.get(k)==c.get(k): agree[k]+=1
        else: diffs.append((r[0][:8],k,o.get(k),c.get(k)))
    if osha!=csha: print('RUBRIC SHA MISMATCH', r[0][:8], osha, csha)
print('cells compared:', sum(total.values()), 'exact:', sum(agree.values()))
for k in sorted(total): print(f'  {k}: {agree[k]}/{total[k]}')
print('disagreements:', len(diffs))
for d in diffs: print('  ', d[0], d[1], 'opencode=',d[2], 'codex=',d[3])
