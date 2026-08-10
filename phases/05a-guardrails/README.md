# Phase 5A — Guardrails: hooks, policies, and enforcement

**Guardrail layer: L2 — runtime control.** This is where you build them.
**Status:** ⬜ Not started · **Depends on:** Phase 4A · **Reference:** [`GUARDRAILS.md`](../../GUARDRAILS.md)

## Goal

Set up a working guardrail set, and learn to judge one.

> **Instructions influence. Hooks intercept. External controls enforce.**

Read [`GUARDRAILS.md`](../../GUARDRAILS.md) before the first lab. This phase builds what
that document describes; it does not repeat it.

## Verified reading

- [ ] ✅ [Copilot — Hooks reference](https://docs.github.com/en/copilot/reference/hooks-reference)
  > *What can `preToolUse` actually stop, and what happens when it times out?*
- [ ] ✅ [Claude Code — Hooks](https://code.claude.com/docs/en/hooks)
  > *Which lifecycle events exist, and which of them can deny?*
- [ ] ✅ [Claude Code — IAM](https://code.claude.com/docs/en/iam)
  > *Permission precedence — which settings file wins on a given run?*
- [ ] ✅ [Claude Code — Sandboxing](https://code.claude.com/docs/en/sandboxing)
  > *When is L2 not enough, and what does moving to L1 cost?*
- [ ] Codex hooks — current Codex docs. **Revalidate event names before every lab**

## Current Copilot behavior

Repository hooks: `.github/hooks/*.json` — **not** `.github/hooks/my-hook/`.
CLI policy hooks (Linux/macOS): `/etc/github-copilot/policy.d/*.json`.

- `preToolUse` can allow/deny
- command hook errors for `preToolUse` can **fail closed**
- **timeouts fail open** — including policy hooks
- HTTP hook errors/timeouts can fall through

**Therefore hooks are not your only boundary.** Write that on the whiteboard before Lab 5A.3.

---

## Extract

From the Claude Code hooks reference, read 2026-08-09. Quotes verbatim.

### Exit codes — the whole control model

| Exit | Effect |
|---|---:|
| **0** | stdout parsed as JSON. **Action proceeds** unless the JSON carries a blocking decision. stderr goes to the debug log only — Claude never sees it |
| **2** | **Blocking.** stdout and JSON ignored; **stderr is fed back to Claude as an error message** |
| anything else | **Non-blocking error. The action proceeds.** Transcript shows a `hook error` notice |

> **Read that third row twice.** A hook that crashes with exit 1 does not block — it lets the
> action through and prints a notice. Your denylist hook fails open on a typo. This is the
> mechanism behind Lab 5A.5, and it is why "we have a hook" is not an answer to "what stops
> this?"

Exit 2's meaning is per-event: `PreToolUse` blocks the tool call, `UserPromptSubmit` rejects
the prompt, `PermissionRequest` denies it, `PostToolUse` merely shows stderr **because the
tool already ran**. `PermissionDenied` and `StopFailure` ignore the exit code entirely.

### Structured decisions

Choose exit codes **or** JSON, not both — JSON is only processed on exit 0.

```json
{ "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",          // allow · deny · ask · defer
    "permissionDecisionReason": "Database writes not allowed",
    "updatedInput": { }                    // you can rewrite the tool input
} }
```

`updatedInput` is worth noticing: a hook can **modify** a call rather than only permit or
refuse it. That is a third option most guardrail designs never consider.

### Timeouts — the numbers

| Hook type | Default |
|---|---|
| `command`, `http`, `mcp_tool` | **600 s** (`UserPromptSubmit` → 30 s, `MessageDisplay` → 10 s) |
| `prompt` | 30 s |
| `agent` | 60 s |
| `SessionEnd` | shared **1.5 s** budget across all of them |

600 seconds is a long time to hang a tool call. Set `timeout` explicitly.

### The event you actually want — `InstructionsLoaded`

> "Fires when a `CLAUDE.md` or `.claude/rules/*.md` file is loaded."
>
> "Use the `InstructionsLoaded` hook to log exactly which instruction files are loaded, when
> they load, and why."

**This is the preflight assertion `agent-observatory` #36 needs.** Phase 1's experiment failed
because nobody could prove the treatment entered context. This event proves it, per run, and
its matcher tells you *why* it loaded — `session_start`, `nested_traversal`,
`path_glob_match`, `include`, `compact`.

Also relevant to #35: `ConfigChange` matches on `user_settings`, `project_settings`,
`local_settings`, `policy_settings`, `skills` — an environment-drift detector.

### Security facts worth knowing

- **Hooks run with your permissions**, in the current directory, with Claude Code's
  environment. Full filesystem access.
- **Hooks fire inside subagents too**, from settings, managed policy and plugins.
- Claude Code **strips `OTEL_*` exporter variables from every subprocess it spawns**,
  including hooks — deliberate, to prevent telemetry leakage. Worth knowing before you
  wonder why your hook cannot see the collector config.
- Enterprise: `allowManagedHooksOnly` blocks user, project and plugin hooks;
  `disableAllHooks` at user/project/local level **cannot** disable managed hooks.
- `allowedHttpHookUrls` and `httpHookAllowedEnvVars` restrict HTTP hooks — because an HTTP
  hook with header interpolation is an exfiltration channel.

---

## Predict before you run

1. What happens to a denied command — does the agent retry, route around it, or stop?
2. What is your hook's false-positive rate on *legitimate* commands?
3. What does the agent do when the hook times out? What does your evaluator record?

---

## The setup sequence

Build in this order. Each step is a different **kind** of guardrail, strongest first.

### Lab 5A.1 — Structural first

Before writing a single hook, remove a capability instead of policing it.

Pick one dangerous action your agent can currently take and make it **impossible**:

- run with no network, and confirm an exfiltration attempt cannot complete
- run against a branch it has no permission to push to
- run with `-s read-only` (Codex) or a devcontainer (Claude) so writes cannot happen at all

> A capability removed needs no detection, no test, no false-positive budget, and cannot be
> evaded. Do this before anything below, and note how many of your planned hooks it made
> unnecessary.

### Lab 5A.2 — Deterministic policy as code

Write the machine-readable rules. From the business case, start with two:

```yaml
# policies/protected-paths.yaml
protected:
  - .github/**
  - infra/**
  - "**/*.sql"
```

```yaml
# policies/command-policy.yaml
denied:
  - "rm -rf"
  - "git push --force"
  - "curl * | sh"
```

Then a check that reads them and exits non-zero. **Structured rules are testable; prose is
not.**

### Lab 5A.3 — Audit hook

Post-tool hook recording metadata only:

```json
{ "timestamp": "…", "sessionId": "…", "tool": "…", "outcome": "…" }
```

**Do not log secrets or complete tool payloads.** An audit hook that captures full tool
arguments is a source-code and prompt exfiltration channel you built yourself — and it is
Layer 3 data sitting in a Layer 1 blast radius.

### Lab 5A.4 — Blocking hook

Harmless training denylist, e.g. `rm -rf training-protected/`.

Demonstrate both, back to back:

1. an instruction saying "do not run it" — and watch it get run
2. a hook that actually blocks it

**The contrast is the lesson.** Same model, same task, two layers.

### Lab 5A.5 — Hook timeout failure — mandatory

A deliberately slow `preToolUse` hook, past its timeout. Observe the documented fail-open.

> **Mandatory.** Skip it and you will believe hooks form a perfect perimeter. They do not,
> and the failure mode is silent.

Then ask: how would you *notice* this in production? If the answer is "we wouldn't," that
is the finding.

### Lab 5A.6 — Test the guardrails

They are code. Five inputs, deterministic outputs:

```
safe command · forbidden command · malformed payload · hook crash · timeout
```

Now measure what matters — on a corpus of **legitimate** commands:

```
false-positive rate    ← the number that decides whether it survives a team
false-negative rate    ← the number that decides whether it was worth building
duration               ← added to every tool call
```

### Lab 5A.7 — Review your own set

Run the six questions from [`GUARDRAILS.md`](../../GUARDRAILS.md#reviewing-a-guardrail)
against everything you built. Any "no" is a finding, and findings go in `findings/`.

---

## Metrics

Per control: invocation count · block count · false positives · false negatives ·
duration · error count · timeout count.

Plus the compliance metrics from the business case — these are guardrail telemetry:

```
workflow phases skipped · forbidden command attempts · protected file attempts
unauthorized dependency attempts · verification skipped · missing approval
```

## Exit gate

- [ ] Why hooks are code and require tests
- [ ] `preToolUse` vs `postToolUse`
- [ ] Fail-open vs fail-closed, and which of mine are which **by choice**
- [ ] Repository hooks vs admin policy
- [ ] Why external OS/network/repository controls still matter
- [ ] **Which capability I removed in 5A.1, and how many hooks that made unnecessary**
- [ ] **My false-positive rate — as a number**
- [ ] **What my evaluator records when a guardrail blocks a run**

That last one is harness bug #7. Phase 5B is where you fix it.

## Commit

```
.github/hooks/security.json · policies/*.yaml · scripts/hooks/ · hook tests
findings/B5-guardrails.md
```

---

## Note from our environment

Claude runs on this machine load **~21 hooks** from user and project settings. For any
benchmark that is 21 uncontrolled interventions — run controlled experiments with
`--setting-sources project`,
and treat hooks as a *registered treatment dimension* when you do want them. See
`agent-observatory` #35.
