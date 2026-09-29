import json,collections
runs=[("e488ed2e-9f90-4e5b-b7d1-53871b8d2755","a4dc23a3f3c9cefa1de70222adbc1799","trace-e488ed2e-blocked-on-user.json"),
      ("606ab03e-1171-494c-97f1-6dc2f485ba9c","5ee3efacf044c414dcb61961f5d94d1c","trace-606ab03e-replication.json")]
print("Checkbox 2 census - n = 2 runs, both BE-001, claude-code 2.1.284,")
print("headless `claude -p` under --permission-mode acceptEdits (run-agent.sh:838, :883-885).")
print("Both are the two 2026-09-29 §0a row-6b preflight runs. THEY ENTER NO COMPARISON.")
print()
pool=collections.Counter(); pdec=collections.Counter(); psrc=collections.Counter(); pdur=[]
for rid,tid,f in runs:
    d=json.load(open(f)); bs=d.get('batches',d.get('resourceSpans',[]))
    names=collections.Counter(); dec=collections.Counter(); src=collections.Counter(); dur=[]
    tools={}; execs=set()
    for b in bs:
        for ss in b.get('scopeSpans',b.get('instrumentationLibrarySpans',[])):
            for s in ss.get('spans',[]):
                at={a['key']:list(a['value'].values())[0] for a in s.get('attributes',[])}
                n=s['name']; names[n]+=1; pool[n]+=1
                if n=='claude_code.tool': tools[at.get('tool_use_id')]=(at.get('tool_name_safe') or at.get('tool_name'), at.get('bash_argv0'))
                if n=='claude_code.tool.execution': execs.add(at.get('tool_use_id'))
                if n=='claude_code.tool.blocked_on_user':
                    dec[at.get('decision')]+=1; pdec[at.get('decision')]+=1
                    src[at.get('source')]+=1; psrc[at.get('source')]+=1
                    dur.append(int(at.get('duration_ms'))); pdur.append(int(at.get('duration_ms')))
    print(f"=== run {rid}  trace {tid} ===")
    for k,v in sorted(names.items()): print(f"  {v:4d}  {k}")
    print(f"  blocked_on_user decision: {dict(dec)}")
    print(f"  blocked_on_user source:   {dict(src)}")
    dur.sort(); print(f"  duration_ms: n={len(dur)} min={dur[0]} median={dur[len(dur)//2]} max={dur[-1]}")
    miss=[(k,v) for k,v in tools.items() if k not in execs]
    print(f"  tool_use_ids with NO execution span: {len(miss)}")
    for k,v in miss: print(f"     {k}  {v}")
    print()
print("=== POOLED, n = 2 runs ===")
for k,v in sorted(pool.items()): print(f"  {v:4d}  {k}")
print(f"  decision: {dict(pdec)}")
print(f"  source:   {dict(psrc)}")
pdur.sort(); print(f"  duration_ms: n={len(pdur)} min={pdur[0]} median={pdur[len(pdur)//2]} max={pdur[-1]}")
