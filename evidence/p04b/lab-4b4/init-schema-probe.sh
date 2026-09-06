#!/usr/bin/env bash
# E-007 / Lab 4B.4 — author decision 8 applied to BOTH agent files of an orchestrator/worker
# overlay, BEFORE the prediction commit. Off the observatory: plain `claude -p` in scratch
# worktrees, no run records, enters no comparison (author decision 6's capability-probe class).
#
#   ./evidence/p04b/lab-4b4/init-schema-probe.sh            # 3 reps x 2 variants
#   REPS=1 ./evidence/p04b/lab-4b4/init-schema-probe.sh     # smoke
#
# WHAT IT OBSERVES, per run:
#   1. the main session's delivered `init.tools` (the `--agent orchestrator` overlay's pool)
#   2. whether probe.txt exists afterwards containing `ok` — i.e. whether SOMETHING could write
#   3. how many `Task` tool_use blocks the stream carries — i.e. whether delegation happened
#   4. every tool name and every `model` value that appears in the stream, so a worker tool call
#      or a worker model is recorded if the stream exposes it at all
#
# THE RULE IT DECIDES (workbook §4 step 2): P1 is the treatment iff on 3 of 3 P1 runs the parent's
# pool lacks Edit/Write/Bash AND probe.txt was written. Otherwise P2.
#
# The flag set is run-agent.sh's claude arm VERBATIM (runner/run-agent.sh:603-620 on 2026-09-06:
# --permission-mode acceptEdits, --strict-mcp-config, --allowedTools, --disable-slash-commands,
# --setting-sources project, --model) plus --agent, exactly as evidence/b04/init-schema-probe.sh
# did at stop 10. Copying by hand is the weak point; the array is here so a reader can diff it.
set -euo pipefail
cd "$(dirname "$0")" || exit 1
HERE="$(pwd)"
LAB="$(cd "$HERE/../../.." && pwd)"
OUT="${1:-$HERE/probe-$(date -u +%Y%m%dT%H%M%SZ)}"
REPS="${REPS:-3}"
MODEL="claude-haiku-4-5-20251001"
mkdir -p "$OUT"
CLAUDE_FLAGS=(
  --permission-mode acceptEdits
  --strict-mcp-config
  --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
  --disable-slash-commands
  --setting-sources project
  --model "$MODEL"
)
PROMPT='Delegate to the implementer subagent exactly this task, verbatim: "Create a file named probe.txt in the current working directory containing the single word ok." Do not create the file yourself. When the subagent returns, reply with one line in this shape: DELEGATED=<yes|no> FILE=<exists|missing>'
for variant in P1 P2; do
  SRC="$LAB/build/customizations/orchestration-4b4-$variant/.claude"
  [[ -d "$SRC/agents" ]] || { echo "missing overlay: $SRC" >&2; exit 2; }
  for r in $(seq 1 "$REPS"); do
    W="$OUT/wt-$variant-$r"
    mkdir -p "$W"
    cp -R "$SRC" "$W/.claude"
    ( cd "$W" && git init -q . && git add -A && git -c user.name=probe -c user.email=probe@local commit -q -m overlay )
    start=$(date -u +%FT%TZ)
    ( cd "$W" && claude "${CLAUDE_FLAGS[@]}" \
        --agent orchestrator \
        --output-format stream-json --verbose \
        -p "$PROMPT" ) \
      > "$OUT/$variant-$r.jsonl" 2>"$OUT/$variant-$r.err" \
      || echo "probe: $variant-$r exited non-zero — recorded anyway" >&2
    end=$(date -u +%FT%TZ)
    if [[ -f "$W/probe.txt" ]]; then file="exists:$(tr -d '\n' < "$W/probe.txt" | head -c 20)"; else file="missing"; fi
    echo -e "$variant\t$r\t$start\t$end\t$file" >> "$OUT/manifest.tsv"
  done
done
echo "== delivered init.tools and stream observations, per run =="
python3 - "$OUT" <<'PY'
import json,sys,glob,os
out=sys.argv[1]
rows=[]
for f in sorted(glob.glob(os.path.join(out,'*.jsonl'))):
    run=os.path.basename(f)[:-6]
    tools=None; task=0; names=set(); models=set(); final=None
    with open(f) as fh:
        for line in fh:
            try: d=json.loads(line)
            except Exception: continue
            if d.get('type')=='system' and d.get('subtype')=='init':
                tools=d.get('tools')
            m=d.get('message') or {}
            if isinstance(m,dict):
                if m.get('model'): models.add(m['model'])
                for c in (m.get('content') or []) if isinstance(m.get('content'),list) else []:
                    if isinstance(c,dict) and c.get('type')=='tool_use':
                        names.add(c.get('name'));
                        if c.get('name') in ('Task','Agent'): task+=1
            if d.get('type')=='result': final=(d.get('result') or '')[:80].replace('\n',' ')
    parent_can_write = bool(tools) and any(t in tools for t in ('Edit','Write','Bash'))
    rows.append((run, 'NO INIT RECORD' if tools is None else len(tools), parent_can_write, task, sorted(names), sorted(models), final))
    print(f"{run}: n_tools={rows[-1][1]} parent_can_write={parent_can_write} task_calls={task} tools_seen={sorted(names)} models_seen={sorted(models)}")
    print(f"    init.tools={json.dumps(tools)}")
    print(f"    final={final!r}")
with open(os.path.join(out,'summary.tsv'),'w') as s:
    s.write("run\tn_tools\tparent_can_write\ttask_calls\ttools_seen\tmodels_seen\tfinal\n")
    for r in rows: s.write("\t".join(str(x) for x in r)+"\n")
PY
echo "== manifest =="; cat "$OUT/manifest.tsv"
