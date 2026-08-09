# Phase 5 — Hooks + enforcement

**Status:** ⬜ Not started · **Depends on:** Phase 4

## Goal

Deterministic interception around a nondeterministic agent.

> **Instructions influence. Hooks intercept. External controls enforce.**

## Verified reading

- [ ] ✅ [Copilot — Hooks reference](https://docs.github.com/en/copilot/reference/hooks-reference)
- [ ] ✅ [Claude Code — Hooks](https://code.claude.com/docs/en/hooks)
- [ ] Codex hooks — use the current Codex docs navigation. **Revalidate event names before
      every lab**; this area changes fast

## Current Copilot behavior

Repository hooks live at `.github/hooks/*.json` — **not** `.github/hooks/my-hook/…`.
CLI policy hooks on Linux/macOS: `/etc/github-copilot/policy.d/*.json`.

- `preToolUse` can allow/deny
- command hook errors for `preToolUse` can **fail closed**
- **timeouts fail open** — including policy hooks
- HTTP hook errors/timeouts can fall through

**Therefore hooks are not your only security boundary.**

## Predict before you run

1. What happens to a denied command — does the agent retry, route around, or stop?
2. What is your hook's false-positive rate on legitimate commands?
3. What does the agent do when the hook times out?

## Lab 5.1 — Audit hook

Post-tool hook recording metadata only:

```json
{ "timestamp": "…", "sessionId": "…", "tool": "…", "outcome": "…" }
```

**Do not log secrets or complete tool payloads by default.** An audit hook that captures
full tool arguments is a prompt-and-source-code exfiltration channel you built yourself.

## Lab 5.2 — Block a forbidden shell command

Harmless training denylist, e.g. `rm -rf training-protected/`.

Demonstrate both: (1) an instruction saying "do not run it", (2) a hook that actually
blocks it. **The contrast is the lesson.**

## Lab 5.3 — Hook timeout failure

A deliberately slow `preToolUse` hook, beyond its timeout. Observe Copilot's documented
fail-open behavior.

> **Mandatory.** Without it, students believe hooks form a perfect enforcement perimeter.

## Lab 5.4 — Test the hook itself

Hooks are code. Inputs: safe command · forbidden command · malformed payload · hook crash ·
timeout. Outputs must be deterministic.

## Metrics

invocation count · block count · false positives · false negatives · duration · errors

## Exit gate

- [ ] Why hooks are code and require tests
- [ ] `preToolUse` vs `postToolUse`
- [ ] Fail-open vs fail-closed semantics
- [ ] Repository hooks vs admin policy
- [ ] Why external OS/network/repository controls still matter

## Commit

```
.github/hooks/security.json · scripts/hooks/ · hook tests
experiments/B5-hooks.md
```

---

## Note from our environment

The Claude runs on this machine load **~21 hooks** from user and project settings. If you
are benchmarking anything, that is 21 uncontrolled interventions in your experiment. Run
controlled experiments with `--bare`, and treat hooks as a *registered treatment dimension*
when you do want them — never as ambient background. See `agent-observatory` #35.
