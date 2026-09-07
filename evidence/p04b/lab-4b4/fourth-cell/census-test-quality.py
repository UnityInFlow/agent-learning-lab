#!/usr/bin/env python3
import os
import re
import sys
from pathlib import Path
from collections import defaultdict
from datetime import datetime
from urllib.request import urlopen
from urllib.error import URLError
import json

# Try to import yaml
try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False

BASE_DIR = Path("/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab")
FINDINGS_DIR = BASE_DIR / "findings" / "codex"
API_URL = "http://127.0.0.1:18081/api/runs"
TIMEOUT = 10

# Collect all run files with their timestamps
runs_by_id = {}  # run_id -> (sheet_path, mtime, tq_score)
fixture_count = 0
total_count = 0

# Step 1: Collect all scoring sheets
for sheet_file in sorted(FINDINGS_DIR.glob("score-*.yaml")):
    total_count += 1
    mtime = sheet_file.stat().st_mtime
    run_id = None
    tq_score = None
    
    # Parse the file to extract run_id and test-quality score
    try:
        if HAS_YAML:
            with open(sheet_file, 'r') as f:
                docs = list(yaml.safe_load_all(f))
                if len(docs) >= 1:
                    provenance = docs[0].get('provenance', {})
                    run_id = provenance.get('run_id')
                    
                    # Get test-quality from second doc if available
                    if len(docs) >= 2:
                        scorer_doc = docs[1]
                        categories = scorer_doc.get('categories', [])
                        for cat in categories:
                            if cat.get('name') == 'test-quality':
                                tq_score = cat.get('score')
                                break
        else:
            # Fallback regex parsing
            with open(sheet_file, 'r') as f:
                content = f.read()
            
            # Extract run_id and mode
            run_id_match = re.search(r'run_id:\s*([a-f0-9\-]+)', content)
            run_id = run_id_match.group(1) if run_id_match else None
            
            mode_match = re.search(r'mode:\s*(\w+)', content)
            mode = mode_match.group(1) if mode_match else None
            
            if not run_id or mode != 'run':
                if not run_id:
                    fixture_count += 1
                continue
            
            # Extract test-quality score
            tq_match = re.search(r'- name:\s*"?test-quality"?\s+score:\s*(\d+|null)', content)
            tq_score = None
            if tq_match:
                score_str = tq_match.group(1)
                tq_score = None if score_str == 'null' else int(score_str)
        
        # Check if this is a run (has run_id)
        if not run_id:
            fixture_count += 1
            continue
        
        # Store or update if this is newer
        if run_id not in runs_by_id or mtime > runs_by_id[run_id][1]:
            runs_by_id[run_id] = (sheet_file, mtime, tq_score)
    
    except Exception as e:
        print(f"Error parsing {sheet_file}: {e}", file=sys.stderr)
        fixture_count += 1

duplicate_count = total_count - fixture_count - len(runs_by_id)

# Step 2: Fetch API data for each run
api_available = True
run_data = {}  # run_id -> {experimentKey, variant, benchmarkId, model, tq_score}

print("Fetching run data from API...", file=sys.stderr)

for run_id in sorted(runs_by_id.keys()):
    sheet_path, mtime, tq_score = runs_by_id[run_id]
    
    try:
        url = f"{API_URL}/{run_id}"
        with urlopen(url, timeout=TIMEOUT) as response:
            api_response = json.loads(response.read().decode())
        
        # Extract fields
        exp_key = api_response.get('experimentKey')
        variant = api_response.get('variant')
        benchmark_id = api_response.get('benchmarkId')
        
        # Model can be at runtime.model or top-level model
        model = api_response.get('runtime', {}).get('model')
        if not model:
            model = api_response.get('model')
        
        run_data[run_id] = {
            'experimentKey': exp_key,
            'variant': variant,
            'benchmarkId': benchmark_id,
            'model': model,
            'tq_score': tq_score,
            'sheet_path': sheet_path
        }
    
    except URLError as e:
        if api_available:
            print(f"API unreachable: {e}", file=sys.stderr)
            api_available = False
    except Exception as e:
        print(f"Error fetching {run_id}: {e}", file=sys.stderr)

# Step 3: Group and tabulate
if api_available and run_data:
    # Group by (experimentKey, variant, benchmarkId, model)
    groups = defaultdict(lambda: {'n_runs': 0, 'tq_0': 0, 'tq_1': 0, 'tq_2': 0, 'tq_null': 0, 'tq_2_runs': []})
    
    for run_id, data in run_data.items():
        key = (data['experimentKey'], data['variant'], data['benchmarkId'], data['model'])
        groups[key]['n_runs'] += 1
        
        tq = data['tq_score']
        if tq == 0:
            groups[key]['tq_0'] += 1
        elif tq == 1:
            groups[key]['tq_1'] += 1
        elif tq == 2:
            groups[key]['tq_2'] += 1
            groups[key]['tq_2_runs'].append(run_id[:8])
        else:
            groups[key]['tq_null'] += 1
    
    # Print table header
    print("experimentKey | variant | benchmarkId | model | n runs | tq=0 | tq=1 | tq=2 | tq=null | run ids with tq=2")
    print("-" * 150)
    
    # Print rows sorted
    for (exp_key, variant, bench_id, model) in sorted(groups.keys()):
        group = groups[(exp_key, variant, bench_id, model)]
        run_ids_str = ",".join(group['tq_2_runs']) if group['tq_2_runs'] else ""
        print(f"{exp_key or ''} | {variant or ''} | {bench_id or ''} | {model or ''} | {group['n_runs']} | {group['tq_0']} | {group['tq_1']} | {group['tq_2']} | {group['tq_null']} | {run_ids_str}")
else:
    # Print per-run fallback
    if not api_available:
        print("API unreachable at http://127.0.0.1:18081", file=sys.stderr)
    
    print("run_id | sheet file | tq score", file=sys.stdout)
    print("-" * 80, file=sys.stdout)
    
    for run_id in sorted(run_data.keys()):
        data = run_data[run_id]
        sheet_name = data['sheet_path'].name
        tq = data['tq_score']
        print(f"{run_id} | {sheet_name} | {tq}")

# Step 4: Print notes
print(f"\n(a) {total_count} total sheets; {fixture_count} fixtures; {duplicate_count} duplicates", file=sys.stderr)
print(f"(b) experimentKey, variant, benchmarkId, model (from runtime.model or top-level model)", file=sys.stderr)
print(f"(c) /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/27119827-25dd-4a71-831c-4ba43267f578/scratchpad/tq.py", file=sys.stderr)

