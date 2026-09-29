# Run state, repair limits, the completion contract, and the retrieval budget

This file is **L3**. Nothing here executes, and nothing here is a boundary — it is text you
read and choose to follow. The two things at this version that *do* execute are hooks, and
they are described below so that you know what will happen to you, not so that you can rely
on this file to stop you.

## Repair limits — these are enforced, and not by this file

A `PreToolUse` hook fingerprints every `Bash` command you run.

- **The same failing command may be attempted at most 3 times.** The 4th identical attempt is
  refused before it runs.
- **A run has at most 7 repeat attempts in total** across all commands.
- A command that **succeeds** clears its own counter, so ordinary repeated work — running the
  test suite several times as you go — is never what exhausts the budget. Only re-running the
  same thing without fixing it is.

When you are refused you will be told which limit fired. **Do not try to route around it.**
Change the command, fix the cause, or stop and report what is blocking you and what you have
already tried. A run that stops with a clear account of what it could not do is a better
result than a run that spends its budget retrying.

## Run state

The hooks maintain a run-state file with the schema documented at `.agent/run-state.json`:
the phase, the goal, the affected files, the last attempt, the per-fingerprint and total
repair counters, any blocks, and a `handoff` block. **You do not have to write it and you
should not try to** — it is written for you, and it exists partly so that the counters above
survive an interruption.

The `handoff` block is **reserved and unused at this version**. It is present so that a later
step has somewhere to put from-agent, to-agent, what was delivered and what remains. Nothing
reads it today. Leave it alone.

## The completion contract

Before you report the task done, satisfy all seven of these. They are the seven clauses of
`.ai/core/completion-contract.md` in the requirements this version is built from, not a list
invented here. They are checked **after** the run by a script, not during it by a hook — so
this is a contract you keep, not a gate that catches you.

1. **Acceptance criteria mapped to implementation.** Every criterion in the ticket is
   addressed, and you can point at the change that addresses it.
2. **Build passed.** Not "should pass" — you ran it and it passed.
3. **Required tests passed.** All of them, not only the ones you touched, and the new
   behaviour has a test that would fail against the old code.
4. **Static analysis passed**, where the project runs any.
5. **No critical findings left open** — no stub returning null, no commented-out branch
   standing in for a decision, no `TODO` holding the place of work you were asked to do.
6. **No forbidden files changed.** Nothing outside the task's scope: not build files, not
   lockfiles, not config you found untidy, not formatting.
7. **A final summary generated** — what you changed, which criteria it satisfies, and what you
   did not do.

**Report `DONE` only when all seven hold.** If one does not, report what you did and which
clause fails. Saying so costs you nothing here and is the single most useful thing you can do
for whoever reads the result. **An honest partial result is reportable; a partial result
described as complete is the failure this contract exists to prevent.**

---

# v1.2 — efficiency

Everything above is v1.1 and is unchanged, byte for byte. Everything below is new at this
version. **Three of the five things below EXECUTE and two do not**, and which is which is said
plainly, because a sentence that looks like a boundary and is not one is worse than no sentence:
you would trust it.

## What executes, and what it will do to you

**1. The retrieval budget.** A `PreToolUse` hook counts your `Grep`/`Glob` calls and the distinct
files you `Read` **before your first edit**, against the limits in
`.ai/policies/retrieval-budget.yaml`:

- **at most 5 searches before you write anything.** The 6th is refused.
- **at most 15 distinct files opened before you write anything.** The 16th new file is refused;
  re-reading one you have already opened is not counted again.
- **no unbounded read of a log-shaped file, ever** — `*.log`, `*.jsonl`, anything under `logs/`
  or `surefire-reports/`. Pass a `limit`, or grep it.

After your first `Edit` or `Write` the first two limits stop applying. **There is no override.**
If you hit one, the honest move is the one the limit is pointing at: you have enough to start.

**2. The file-summary cache.** A `sha256` of every file you read is kept. If you `Read` the same
file again and **its hash has not changed, the read is refused** and you are told the size, the
line count and when you read it. Nothing has changed, so the second read would hand you what you
already have. If the file *has* changed, the cached entry is thrown away rather than reused and
the read goes through — a stale summary is never served.

**3. Command deduplication.** A `PreToolUse` hook on `Bash` fingerprints your command and the
current state of the code. **The same command, run again with no change to the code, is refused.**
Change one line and it is available again immediately. This is stricter than the repair limit
above, and on purpose: attempts 2 and 3 at an unchanged command are the waste this version exists
to remove.

**None of the three is negotiable and none of them is a judgement about your work.** They are
arithmetic. When one fires you will be told which and why. **Do not try to route around it** — a
refused search answered by fifteen single-file reads is the same waste with more steps, and the
file counter sees it.

## What does not execute — two things you are asked, not made, to do

**4. Classify the task first.** Run this once, before you plan:

```
.ai/efficiency/classify-task.sh <the ticket file>
```

It writes a task type — api / jpa / kafka / cache / security / build / test-only / migration —
and that type names the verification profile below. **Nothing enforces this.** A run that skips it
proceeds and is refused nothing.

**5. Verify with the smallest sufficient sequence, chosen by that type.** Not every change needs
every check, and running all of them on every change is the waste this step is named after.

| task type | the smallest sufficient sequence, in order |
|---|---|
| `api` | compile · the controller's own test class · the full module test run once at the end |
| `jpa` | compile · the repository/entity test class · the full module test run once at the end |
| `kafka` | compile · the producer/consumer test class · the full module test run once at the end |
| `cache` | compile · the cache's test class · the full module test run once at the end |
| `security` | compile · the affected test class · the full module test run once at the end |
| `build` | the build itself · then the full module test run once |
| `test-only` | the new or changed test class · then the full module test run once |
| `migration` | compile · the migration's own test · the full module test run once at the end |

**The final full run is not optional in any row.** The point is not to verify less; it is to stop
verifying the same thing four times on the way there. The completion contract above is unchanged:
clause 2 and clause 3 still mean you ran the build and all the tests and they passed.

**This section is L3 and is worth being honest about.** It could be made to execute — a hook that
refused a test command outside the profile — and it deliberately is not, because such a hook would
be able to fail a run that had solved the ticket. That would change what the benchmark measures,
which is not a decision available at this step.

## Where the numbers and the profiles actually live

- `.ai/policies/retrieval-budget.yaml` — the four limits, and which of them is enforced by a hook
  and which is not. The hook reads this file; it does not carry its own copy of the numbers.
- `.ai/core/context-policy.md` — why the budget exists, in one page.
- `.ai/efficiency/verification-profiles.yaml` — the same table as above, as data.
