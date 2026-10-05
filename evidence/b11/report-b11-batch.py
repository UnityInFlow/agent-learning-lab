#!/usr/bin/env python3
"""B11 (stop 26) §4 step 8 report — per task, per arm, median and range, never a mean alone.

Why this exists beside `make baseline-report`: the batch driver gives BOTH arms of a task the
SAME experimentKey (run-b11-batch.sh:363) and distinguishes them by `--variant`. The
observatory's `baseline-report.py` is a single-arm reporter keyed on experimentKey, so it
pools the two arms of a task and cannot produce the per-arm medians E-026/E-027's decision
rule is written against. Both are run at step 8: the pooled one because §4 step 8 names it,
this one because the decision rule needs the split.

Inputs, all on disk or on the API, nothing re-run:
  manifest.tsv      run_id -> (task, arm, seq) and the per-run delivery columns
  codex-sheets.tsv  run_id -> the registered sheet for that run
  the API           /api/runs/<id> for the token, cost, call, duration and evaluator fields
  the sheets        the four rubric category scores, read BY NAME and never by position

Independence check, not a flag read: `variant` on the API record must agree with `arm` in the
manifest on every row, and `instructionsHash` must take exactly one value per arm.

Usage:  report-b11-batch.py <batch-dir> <out-dir> [--api http://127.0.0.1:8081]
Exit:   0 ok; 2 a consistency check failed (the numbers are NOT written); 3 bad usage.
"""
import json
import os
import sys
import urllib.request

ARM_VARIANT = {"treated": "agent-v1.2-efficiency", "control": "agent-v1.1"}
CATS = ["architecture-consistency", "maintainability", "test-quality", "change-focus"]


def die(msg, code=2):
    print(f"FAIL: {msg}", file=sys.stderr)
    sys.exit(code)


def median(xs):
    """Median of a list, None when empty. Even n -> mean of the two middle values."""
    v = sorted(x for x in xs if x is not None)
    if not v:
        return None
    m = len(v) // 2
    return v[m] if len(v) % 2 else (v[m - 1] + v[m]) / 2


def fmt(x):
    if x is None:
        return "null"
    if isinstance(x, float):
        return f"{x:.6f}".rstrip("0").rstrip(".") if abs(x) < 1000 else f"{x:.1f}"
    return str(x)


def rng(xs):
    v = [x for x in xs if x is not None]
    return (min(v), max(v)) if v else (None, None)


def read_manifest(path):
    rows, hdr = [], None
    with open(path) as fh:
        for line in fh:
            line = line.rstrip("\n")
            if line.startswith("#") or not line.strip():
                continue
            parts = line.split("\t")
            if hdr is None:
                hdr = parts
                continue
            rows.append(dict(zip(hdr, parts)))
    return rows


def read_sheet(path):
    """Return {category_name: score} read BY NAME, plus the sheet's rubric_sha.

    A missing cell and a null cell are different things here (§6): an absent `score:` key
    raises, a literal `null` is carried through as None.
    """
    rubric_sha, cats, name = None, {}, None
    with open(path) as fh:
        for raw in fh:
            s = raw.strip()
            if s.startswith("rubric_sha:"):
                rubric_sha = s.split(":", 1)[1].strip()
            elif s.startswith("- name:"):
                name = s.split(":", 1)[1].strip().strip('"').strip("'")
            elif s.startswith("score:") and name is not None:
                v = s.split(":", 1)[1].strip()
                cats[name] = None if v == "null" else int(v)
                name = None
    return rubric_sha, cats


def main():
    if len(sys.argv) < 3:
        die(__doc__, 3)
    batch, out = sys.argv[1], sys.argv[2]
    api = "http://127.0.0.1:8081"
    if "--api" in sys.argv:
        api = sys.argv[sys.argv.index("--api") + 1]
    os.makedirs(out, exist_ok=True)

    man = read_manifest(os.path.join(batch, "manifest.tsv"))
    if len(man) != 40:
        die(f"manifest has {len(man)} data rows, expected 40")
    sheets = {r["run_id"]: r for r in read_manifest(os.path.join(batch, "codex-sheets.tsv"))}
    # batch dir is <lab>/evidence/b11/batch-<tag>; sheet paths in the tsv are lab-relative.
    lab = os.path.abspath(os.path.join(batch, "..", "..", ".."))

    per, problems = [], []
    for r in man:
        rid = r["run_id"]
        with urllib.request.urlopen(f"{api}/api/runs/{rid}", timeout=30) as fh:
            rec = json.load(fh)
        eff, beh = rec.get("efficiency") or {}, rec.get("behavior") or {}
        cust, ev = rec.get("customization") or {}, rec.get("evaluation") or {}

        if rec.get("variant") != ARM_VARIANT[r["arm"]]:
            problems.append(f"{rid}: arm={r['arm']} but API variant={rec.get('variant')!r}")
        if rec.get("benchmarkId") != r["task"]:
            problems.append(f"{rid}: task={r['task']} but API benchmarkId={rec.get('benchmarkId')!r}")
        if cust.get("instructionsHash") != r["instr_hash"]:
            problems.append(f"{rid}: instructionsHash API/manifest disagree")

        sheet_sha = sheet_cats = None
        if rid in sheets and sheets[rid]["sheet"] not in ("", "none"):
            sheet_sha, sheet_cats = read_sheet(os.path.join(lab, sheets[rid]["sheet"]))
        else:
            problems.append(f"{rid}: no registered sheet row")

        it, ct, cc = eff.get("inputTokens"), eff.get("cachedTokens"), eff.get("cacheCreationTokens")
        ctx = None if None in (it, ct, cc) else it + ct + cc
        per.append({
            "task": r["task"], "arm": r["arm"], "seq": r["seq"], "run_id": rid,
            "runtime_ver": r["runtime_ver"], "instr_hash": r["instr_hash"],
            "ctx_total": ctx, "inputTokens": it, "cachedTokens": ct,
            "cacheCreationTokens": cc, "outputTokens": eff.get("outputTokens"),
            "estimatedCost": eff.get("estimatedCost"), "durationMs": eff.get("durationMs"),
            "modelCalls": beh.get("modelCalls"), "toolCalls": beh.get("toolCalls"),
            "eval_exit": ev.get("exitCode"), "rubric_sha": sheet_sha,
            **{f"cat_{c}": (sheet_cats or {}).get(c, "MISSING") for c in CATS},
        })

    for p in per:
        for c in CATS:
            if p[f"cat_{c}"] == "MISSING":
                problems.append(f"{p['run_id']}: sheet is missing category {c}")
    if problems:
        with open(os.path.join(out, "CONSISTENCY-FAILURES.txt"), "w") as fh:
            fh.write("\n".join(problems) + "\n")
        die(f"{len(problems)} consistency problem(s); see CONSISTENCY-FAILURES.txt")

    cols = list(per[0].keys())
    with open(os.path.join(out, "per-run.tsv"), "w") as fh:
        fh.write("\t".join(cols) + "\n")
        for p in per:
            fh.write("\t".join(fmt(p[c]) for c in cols) + "\n")

    metrics = ["ctx_total", "inputTokens", "cachedTokens", "cacheCreationTokens",
               "outputTokens", "estimatedCost", "durationMs", "modelCalls", "toolCalls"]
    lines = ["# B11 step-8 per-arm report. Median and range, never a mean alone.",
             "# Generated by evidence/b11/report-b11-batch.py from the manifest, the API and the",
             "# 40 registered codex sheets. Re-derive by re-running it against the same batch dir.",
             ""]
    summary = {}
    for task in ("BE-003", "BE-004"):
        lines.append(f"## {task}")
        lines.append("")
        lines.append("| metric | control median | control range | treated median | treated range | delta of medians | delta % |")
        lines.append("|---|---|---|---|---|---|---|")
        arms = {a: [p for p in per if p["task"] == task and p["arm"] == a] for a in ("control", "treated")}
        summary[task] = {"n": {a: len(v) for a, v in arms.items()}}
        for m in metrics + [f"cat_{c}" for c in CATS]:
            med, rr = {}, {}
            for a in ("control", "treated"):
                vals = [p[m] for p in arms[a]]
                med[a], rr[a] = median(vals), rng(vals)
            d = None if None in (med["control"], med["treated"]) else med["treated"] - med["control"]
            dp = None if not med["control"] or d is None else 100.0 * d / med["control"]
            lines.append("| {} | {} | {}–{} | {} | {}–{} | {} | {} |".format(
                m, fmt(med["control"]), fmt(rr["control"][0]), fmt(rr["control"][1]),
                fmt(med["treated"]), fmt(rr["treated"][0]), fmt(rr["treated"][1]),
                fmt(d), "null" if dp is None else f"{dp:+.2f}%"))
            summary[task][m] = {"control_median": med["control"], "treated_median": med["treated"],
                                "delta": d, "delta_pct": dp,
                                "control_range": rr["control"], "treated_range": rr["treated"]}
        for a in ("control", "treated"):
            ok = sum(1 for p in arms[a] if p["eval_exit"] == 0)
            lines.append("")
            lines.append(f"- {a}: evaluator exit 0 on **{ok} of {len(arms[a])}**")
            summary[task][f"acceptance_{a}"] = [ok, len(arms[a])]
            hs = sorted({p["instr_hash"] for p in arms[a]})
            vs = sorted({p["runtime_ver"] for p in arms[a]})
            shas = sorted({p["rubric_sha"] for p in arms[a]})
            lines.append(f"- {a}: instructionsHash values = {hs}")
            lines.append(f"- {a}: runtime versions = {vs}")
            lines.append(f"- {a}: rubric_sha on its sheets = {shas}")
            summary[task][f"runtime_versions_{a}"] = vs
            summary[task][f"rubric_sha_{a}"] = shas
        lines.append("")
    with open(os.path.join(out, "REPORT.md"), "w") as fh:
        fh.write("\n".join(lines) + "\n")
    with open(os.path.join(out, "summary.json"), "w") as fh:
        json.dump(summary, fh, indent=2, sort_keys=True)
    print(f"ok: 40 runs, 0 consistency problems, wrote per-run.tsv, REPORT.md, summary.json to {out}")


if __name__ == "__main__":
    main()
