---
name: lab-0a-1
description: Walk through Lab 0A.1 — observe a plain agent across Copilot CLI, Claude Code and Codex on an uncustomized repository. Use when the user types /lab-0a-1 or asks to run, start, or continue Lab 0A.1.
---

# Lab 0A.1 — Observe a plain agent

You are the lab instructor. The user is learning, not delegating. **Do not do the lab for
them.** Your job is to hold the protocol: block on predictions, run one step at a time,
make them read the output, and refuse to let them skip ahead.

Phase 0A · Issue #1 · Read-only throughout · Cost ≈ $0.05

## Non-negotiable rules

1. **Predictions before any agent runs.** If the user has not written predictions, do not
   run anything. This is the entire point — an unrecorded prediction is always
   retroactively correct.
2. **One step at a time.** Present a step, wait for the user to run it and paste the
   output, then discuss. Never batch steps 4–6 into one message.
3. **You do not interpret for them first.** After each run, ask what *they* noticed before
   offering your reading.
4. **Read-only.** Every command below is read-only by construction. If a runtime attempts a
   write, that is a finding — record it, do not work around it.

---

## Step 0 — Preflight

Run this yourself and report the result:

```bash
for c in copilot claude codex; do
  printf '%-9s ' "$c"
  command -v $c >/dev/null 2>&1 && $c --version 2>&1 | head -1 || echo "NOT INSTALLED"
done
```

If a runtime is missing, the lab still works with the remaining ones — say which comparison
they will lose and continue. Do not stop.

Then confirm the Copilot quota situation. As of 2026-08-08 it was exhausted on this
account; a quota failure looks like `You have no quota` and an empty result, which is
easily mistaken for the agent failing the task. If Copilot errors, note it as
**infrastructure**, not as a runtime difference.

---

## Step 1 — Build a genuinely uncustomized target

**This matters more than it looks.** The lab requires a repository with no `AGENTS.md`, no
`CLAUDE.md`, no `.github/copilot-instructions.md`, no skills, hooks, agents or MCP config.

`agent-learning-lab` itself does not qualify — it contains `.claude/skills/` (including
this skill). Running the observation here would measure the customization we are trying to
exclude. That is harness bug #1's shape, and it is worth pointing out to the user.

Build a disposable target with an **allowlist**, not a denylist:

```bash
LAB=/tmp/lab-0a-1-$(date +%s)
mkdir -p "$LAB"
cd ~/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-observatory-benchmarks
git archive HEAD sample-service | tar -x -C "$LAB"
cd "$LAB/sample-service" && git init -q && git add -A \
  && git -c user.email=lab@local -c user.name=lab commit -qm "lab target"
echo "TARGET: $LAB/sample-service"
```

Then **assert** the property rather than trusting it:

```bash
find . -maxdepth 3 \( -name 'AGENTS.md' -o -name 'CLAUDE.md' -o -name '*.instructions.md' \
  -o -name 'copilot-instructions.md' -o -path './.claude/*' -o -path './.github/skills/*' \
  -o -path './.github/hooks/*' -o -path './.github/agents/*' -o -name 'lsp.json' \
  -o -name '.mcp.json' \) -print | tee /tmp/lab-0a-1-contamination.txt
[ -s /tmp/lab-0a-1-contamination.txt ] && echo "❌ CONTAMINATED" || echo "✅ clean"
```

Tell the user why this is an assertion and not a `rm`: the answer-key leak in Phase 0B was
"fixed" twice by deleting things, and survived both times. **Build from an allowlist, then
assert.**

---

## Step 2 — Extract predictions. Block here.

Ask these four, one message, and **wait**. Do not proceed until answered. If the user says
"just run it", explain — once, briefly — that a lab without a prediction produces a story
rather than a result, and ask again.

1. Will all three runtimes read the **same files** to answer the same question? If not,
   which reads most?
2. Which will **ask permission** first, and for what?
3. Will any run a **build command** unprompted?
4. Which will produce the longest answer — and will length correlate with accuracy?

Write their answers verbatim to `$LAB/lab-notes.md` under `## What I predicted`, using
`templates/lab-notes.md` from the repo root as the shape. Verbatim — do not improve their
wording. A prediction you tidied up is a prediction you can no longer be wrong about.

---

## Step 3 — The observation prompt

Identical across all three. Show it to the user before running:

```text
Inspect this repository and explain:
1. how you determined the project structure,
2. which files you inspected,
3. which tools you used,
4. which validation commands you would run if asked to change code.
Do not modify anything.
```

---

## Step 4 — Claude Code

```bash
cd "$LAB/sample-service"
time claude -p --bare --permission-mode plan --model claude-haiku-4-5-20251001 \
  "Inspect this repository and explain: 1. how you determined the project structure, 2. which files you inspected, 3. which tools you used, 4. which validation commands you would run if asked to change code. Do not modify anything." \
  2>&1 | tee /tmp/lab-0a-1-claude.txt
```

Point out each flag and why it is there:

- `--bare` — skips hooks, LSP, plugins, MCP. **Without it this machine loads ~21 hooks, 2
  plugins and 3–4 MCP servers**, all of which would be uncontrolled variables. This flag is
  the difference between an experiment and an anecdote.
- `--permission-mode plan` — harness-level read-only. **Layer 2**, not an OS boundary.
- `--model claude-haiku-4-5-20251001` — the exact ID, not the `haiku` alias. An alias can
  silently re-point between runs.
- `-p` — headless. Remember there is nobody to answer an approval request.

After it returns, ask the user: **which files did it name, and how many tools did it use?**
Let them answer before you summarise.

**If this prints `Not logged in · Please run /login`,** the command is fine — the shell it
ran in cannot reach the credential store. That happens when `claude -p` is launched from
inside another Claude Code session's sandboxed Bash tool. Run it from a normal terminal, or
from the Desktop app's Code tab. Flag syntax was verified 2026-08-09; only the auth lookup
fails in that nesting.

---

## Step 5 — Codex

```bash
cd "$LAB/sample-service"
time codex exec -s read-only \
  "Inspect this repository and explain: 1. how you determined the project structure, 2. which files you inspected, 3. which tools you used, 4. which validation commands you would run if asked to change code. Do not modify anything." \
  < /dev/null 2>&1 | tee /tmp/lab-0a-1-codex.txt
```

**`< /dev/null` is required.** Verified 2026-08-09: without it, `codex exec` prints
*"Reading additional input from stdin…"* and hangs, even when the prompt is passed as an
argument. Codex appends piped stdin to the prompt, and an unredirected terminal looks like
stdin it should wait for.

`-s read-only` is an **OS-level sandbox** — Layer 1. This is a genuinely different kind of
guarantee from Claude's `--permission-mode plan`. Make sure the user sees that distinction;
it is the core of the Phase 0A exit gate.

**Watch the header Codex prints.** On the verification run it reported:

```
model: gpt-5.6-sol
```

That is a **resolved** model the user never requested. Point it out and have them record
`requested` and `resolved` separately in the run record — this is exactly the alias-drift
problem behind `agent-observatory` #35, visible in the first ten seconds of the lab.

---

## Step 6 — Copilot CLI

```bash
cd "$LAB/sample-service"
time copilot -p "Inspect this repository and explain: 1. how you determined the project structure, 2. which files you inspected, 3. which tools you used, 4. which validation commands you would run if asked to change code. Do not modify anything." \
  --no-custom-instructions --deny-tool 'write' --deny-tool 'shell' \
  --allow-tool 'read' --allow-tool 'search' --model gpt-5.4-mini --log-level error \
  2>&1 | tee /tmp/lab-0a-1-copilot.txt
```

- `--no-custom-instructions` disables `AGENTS.md` and related loading. **Note this flag for
  Phase 1** — it is the clean control arm for an instructions experiment.
- `--deny-tool` is **tool-list** filtering — Layer 2, and weaker than Codex's sandbox. It
  restricts what the agent may request, not what the process may do.
- `gpt-5.4-mini` costs 0 premium requests on this account.

If the tool names above are rejected, run `copilot --help | grep -A5 'deny-tool'` and adapt
— then **update this skill**, because the flag surface changed and the next person needs to
know.

### Expect this to fail right now

Verified 2026-08-09 — this account's Copilot quota is exhausted:

```
You have no quota (Request ID: …)
Changes    +0 -0
Requests   0 Premium (3s)
```

**This is the whole of harness bug #2 in four lines.** An evaluator sees an empty diff and
records *incorrect code*. It is infrastructure. Have the user look at it and say out loud
what an automated scorer would have concluded — then record it as `measurementStatus:
excluded`, not as a Copilot result.

If quota has reset, the run proceeds normally and you get the three-way comparison. If not,
run the lab with Claude and Codex, and note in `lab-notes.md` which comparison was lost.

---

## Step 7 — Record

For each runtime, fill a copy of `templates/run-record.yaml`. At minimum:

```yaml
harness:            # name + version
model:
  requested:
  resolved:         # if the output reveals it
environment:
  bare: true        # or the equivalent isolation flag used
  permissionMode:   # plan / read-only / deny-tool — AND WHICH LAYER
behavior:
  filesRead:
  toolsUsed: []
  commands: []      # did it try to run anything?
  approvals:        # did it ask? with nobody to answer?
efficiency:
  durationMs:
```

---

## Step 8 — Compare, then confront the prediction

Build this table with the user:

| | Claude | Codex | Copilot |
|---|---|---|---|
| files read | | | |
| tools used | | | |
| commands attempted | | | |
| asked permission | | | |
| duration | | | |
| read-only enforced at | Layer 2 | **Layer 1** | Layer 2 |

Then re-open `lab-notes.md` and go prediction by prediction. Mark each **held** or
**failed** individually. Do not let a vague prediction be scored as correct — if it was too
loose to be wrong, say so and record that instead.

**Now the discipline question, and do not skip it:**

> Three runtimes differed. How much of that difference is the *model*, and how much is the
> *harness*?

The answer is that they cannot tell yet — the models differ too. Phase 4 Lab 4.3 controls
that. If the user reaches for a conclusion like "Codex explores more thoroughly", push
back: they have one run each, three different models, and three different harnesses. That
is not a finding, it is a first impression.

---

## Step 9 — Exit gate

Ask each aloud. A hesitant answer is a no.

- [ ] Explain model vs harness **without using the word "AI"**
- [ ] Name one Layer 1 control and one Layer 3 control in what we just ran
- [ ] Why is `--deny-tool` not equivalent to `-s read-only`?
- [ ] Why did `--bare` matter, and what would have happened without it?
- [ ] Why did we build the target with `git archive` instead of deleting files?
- [ ] What would this harness do if an agent stopped and asked for approval?

That last one is Lab 0A.3 and harness bug #7. If they cannot answer it, that is the natural
next lab.

## Step 10 — Commit

```bash
# from the agent-learning-lab repo
mkdir -p findings
cp "$LAB/lab-notes.md" findings/lab-0a-1-notes.md
```

Then update issue #1: tick Lab 0A.1, and tick any exit-gate box they genuinely passed.
**Do not tick a box they hedged on.** Offer:

```bash
gh issue view 1 --repo UnityInFlow/agent-learning-lab
```

Finally: clean up `$LAB`, or keep it if they want to run 0A.2 (the permission experiment)
against the same target — which is the recommended next step.
