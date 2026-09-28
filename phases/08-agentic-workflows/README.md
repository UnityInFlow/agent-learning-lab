# Phase 8 — Unattended agents: event- and schedule-triggered (gh-aw)

> **Renamed.** "Agentic workflows" here means GitHub's `gh-aw` — agents triggered by events
> and schedules with no human present. Designing an analyze → plan → execute pipeline is a
> different subject: [Phase 4B](../04b-orchestration/).

**Guardrail layer: L1 for the credential, L2 for everything that inspects the content — and
the L2 that is supposed to stop prompt injection is judged by a language model**
· [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** 🔶 **OPEN at §0 boundary 1 — extract only, labs deferred by the autonomous run**
(stop 23, 2026-09-27) · **Depends on:** Phase 7

> **Scope of this stop.** The spine's row `22–23` is *"Phases 7 and 8 (◇): extract only, as
> stop 7"* ([`LEARNING-PATH.md`](../../LEARNING-PATH.md) line 103), and §4 of the run prompt
> makes a Track A stop the loop **minus steps 3–10** unless the lab runs the benchmark. This
> one does not. **`n = 0` runs. No experiment file, no registered prediction, no benchmark run,
> no overlay, no dollar spent on the agent under test.** Nothing below is a claim about the
> agent under test; every claim is a claim about what seven documentation pages said on
> 2026-09-27, quoted so a stranger can check it against the page.
>
> Labs 8.1, 8.2, 8.3 and 8.4 are **deferred, not abandoned** — each is marked below with what
> it still owes. Stop 7 is the original precedent and stop 22 the nearest; both closed at
> `n = 0` and **neither was a shortfall**, because the spine registers a ◇ stop as required
> reading and extract only.
>
> Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-27

## Goal

Move from *human initiates every agent run* to *event or schedule initiates the agent*.

**This is a major risk transition.** Everything you learned about approval prompts stops
applying, because there is nobody to prompt.

## Layer labels — §4 step 2, applied in order

The rule is the workspace `CLAUDE.md`'s, applied **in order**, stopping at the first yes:
(1) can the bad value still be written down after the fix? if no → **L1**; (2) does something
*execute* and reject it? name the thing that runs → **L2**; (3) otherwise → **L3**.

**Read stop 22's correction before reading this table.** At stop 22 I labelled a
digest-comparing installer **L1 in six places**, and the §4a review was right to reject it. A
wrong digest *can* still be written down, so step 1 answers **yes** and the rule falls through
to step 2 — an installer that compares and refuses is **L2**. **L1 requires that the bad value
cannot be expressed at all**, which is why a lockfile is L1 and a checksum check is not. The
table below is written with that correction applied, and **only one row survives step 1.**

> **And the §4a review of this stop caught the same error again, in the `staged: true` row.**
> I had it as **L1** on the grounds that *"the write steps do not run at all"*. Applied in
> order: **the bad value can still be written down** — the agent still emits a valid write
> request into the structured output — and then *"Every write operation is **skipped**"*, which
> is something executing and declining to act. That is **L2**. Whether `staged: true` omits the
> write-capable job from the generated workflow (L1) or generates it and suppresses it (L2) is
> **not determined by the page**, and a label resting on an undetermined mechanism is not L1.
> Relabelled below. **Two stops in a row, the same mistake, caught by the same reviewer and not
> by me** — which is the argument for the review, and an argument that `GUARDRAILS.md` needs a
> worked `staged`-shaped example rather than another warning.
> *(Corrected 2026-09-27 from `findings/opencode/review-README-20260927T201538Z.md`, codex,
> 2 of 2 runs.)*

### The subject — what gh-aw's controls are

| Control | Bad value it targets | Can that value still be written? | The thing that executes | Layer |
|---|---|---|---|---|
| **Safe-output separation** — agent job runs with `contents: read` and requests actions as structured output | the agent writing to the repository | **No.** The process holds no credential that can express a write; there is no rejection step because there is nothing to reject | — | **L1** |
| **`staged: true`** — *"Every write operation is skipped"* | any write during a preview run | **Yes** — the agent still emits a valid write request into the structured output; what changes is whether it is acted on | the staged branch of the compiled workflow, which *"skips"* each write operation | **L2** *(was L1 until the §4a review; see the note above)*. Still a preview mode and not a production control — but policed, not removed |
| **Threat detection** | a malicious issue body / patch reaching a write handler | **Yes** — it is already in the output artifact | the threat-detection job: *"the workflow fails and safe outputs are blocked"* | **L2** — and the judge is a model (below), which is the weakest L2 in this project's model |
| **Protected files** | a patch touching `package.json`, `.github/workflows/*`, `CLAUDE.md`, `.claude/settings.json` | **Yes** | *"a static, rule-based protection layer"*; with `protected-files: blocked` the safe output *"fails with an error message"* | **L2** — the strongest L2 on the page, because it is rule-based, not model-based |
| **`roles:`** exact-match allowlist on the trigger | an outside actor starting an unattended agent | **Yes** — anyone can still comment | the activation job's role check | **L2** |
| **`max:` per output type** (`create-issue` max 1, `add-labels` max 3, …) | a flood of writes from one run | **Yes** | the safe-output handler's per-operation cap | **L2** |
| **`stop-after:`** | a scheduled agent running for ever | **Yes** — the cron line stays in the file | *"Automatically disable workflow triggering after a deadline"* | **L2** |
| **`hypothesis:`** in an experiment's frontmatter | a hypothesis invented after the data | **Yes** — it is a free-text string and nothing parses it | nothing | **L3** |
| **`decision: {minimum_effect, confidence}`** + `min_samples:` | a winner declared on noise | **Yes** | `gh aw experiments analyze`, which returns `PROMOTE / REJECT / INCONCLUSIVE / EXTEND` | **L2 over the verdict, L3 over the run** — nothing stops a run, and *"It does not promote a variant, edit the workflow, or change traffic"* |
| **The `.md` → `.lock.yml` compile step** | a reviewer approving a source file that is not what executes | **Yes** — both files are committed and only the lock file runs | nothing documented on the *Creating workflows* page: `grep -i` over the fetched page for `stale`, `out of date`, `recompile`, `--verify` returns **nothing on all four** | **L3** — and this is the sharpest finding of the stop |

### This stop's own artifacts

| Artifact | Layer | Why |
|---|---|---|
| This extract, and every quote in it | **L3** | Words a reader chooses to believe. That is the correct answer for a ◇ stop and not a gap |
| The `- [x] ✅` ticks in *Verified reading* | **L3** | A tick is a claim about my own diligence |
| `./tools/check-links.sh` over the two new `SOURCES.md` rows | **L2** | It executes, calls each URL with `curl`, and returns a counted result and an exit code: **`ok=73 moved=11 blocked=2 unverified=0 broken=0`, exit 0** |
| The verbatim-quote verification (below) | **L2** | A script fetches each page and prints `FOUND` / `ABSENT` per sentence; it found one of this workbook's own inherited quotes **ABSENT** |
| The spine's `**L1**` label for Phase 8 | **L3, and now qualified** | It is right about the credential and wrong about everything that inspects content. The label was written before the pages were read |

**The proof column of every row in the first table is L3 at this stop**, because `n = 0`: I
*read* that the threat-detection job blocks safe outputs, I did not watch one block anything.
**Exactly one subject row is L1** — the safe-output separation — and everything else on these
pages either executes and refuses (L2) or is words (L3).
Three things at this stop have an L2 proof and they are all in the second table. Saying that
plainly is §5's requirement, not a shortfall of it.

## Verified reading

**Seven pages, all read fresh 2026-09-27 by the autonomous run.** The scaffold listed five;
two more were added at this stop because two exit-gate clauses — *schedule/event attack
surface* and the injection half of *safe-output separation* — cannot be answered from the five.
All seven are in [`SOURCES.md`](../../SOURCES.md) under *Agentic workflows (gh-aw)*.

- [x] ✅ [gh-aw home](https://github.github.com/gh-aw/) — the *"Public Preview"* wording the scaffold quoted is **gone**; see the re-verification below
- [x] ✅ [Creating workflows](https://github.github.com/gh-aw/setup/creating-workflows/)
- [x] ✅ [Safe outputs](https://github.github.com/gh-aw/reference/safe-outputs/)
- [x] ✅ [Permissions](https://github.github.com/gh-aw/reference/permissions/)
- [x] ✅ [A/B experiments](https://github.github.com/gh-aw/experimental/experiments/)
- [x] ✅ [Threat detection](https://github.github.com/gh-aw/reference/threat-detection/) — **added at this stop**
- [x] ✅ [Triggers](https://github.github.com/gh-aw/reference/triggers/) — **added at this stop**

`./tools/check-links.sh`, re-run after the two new rows were added — and re-run again at §0
boundary 2, with the output kept at `evidence/p08/check-links-20260927T2014Z-boundary2.txt`
rather than cited by a redacted minute. *(The §4a review was right that `19:2xZ` identifies no
execution. Fixed by citing the artefact.)*
**`ok=73 moved=11 blocked=2 unverified=0 broken=0`, exit 0** — two more `ok` than stop 22's
71, which is the two new rows and nothing else. **Neither new URL redirected**: all seven were
checked with `curl -o /dev/null -w '%{http_code} %{url_effective}' -L` before they were read,
and all seven returned `200` at the URL as written.

> **That curl check was run deliberately and it is the only reason the ✅ marks above are
> honest.** Stop 22 learned that **`WebFetch` follows a redirect silently** and hands back the
> content as though the URL resolved, so a subagent reports "resolved directly" for a page that
> moved. `check-links.sh` uses `curl` and reports the hop. **A ✅ from a fetch is not a ✅** —
> so at this stop the status code was taken from `curl` first and the reading second.

## The architecture that matters

```
event → read-only agent job → structured requested output
      → safe-output validation / threat checks → separate scoped write job
```

**The agent should not simply receive a broad write token.** The separation between the job
that thinks and the job that writes is the whole design.

---

## Extract — the 2026-08-09 read, kept verbatim

From the gh-aw safe-outputs reference, read 2026-08-09. Quotes verbatim.

> **This section is the scaffold's, and it is kept exactly as it was written.** One of its
> display quotes is no longer in the page it cites and one of its notes is no longer true; both
> are recorded in *Extract — re-verification 2026-09-27* below rather than corrected here.
> Overwriting a dated reading destroys the only evidence that anything drifted.
> *(Stop 23, 2026-09-27, Opus 5.)*

### The whole idea in one sentence

> "**Safe outputs enforce security through separation: agents run read-only and request
> actions via structured output, while separate permission-controlled jobs execute those
> requests.**"

### Two phases, two permission sets

| Phase | Permissions | Does |
|---|---|---|
| **Agent job** | minimal — typically `contents: read`, `issues: read` | analyses, produces a **structured request** |
| **Write job** | elevated — `issues: write`, `contents: write` | validates the request, then executes it |

> "**The agent never receives write tokens directly.**"

This is the **structural** guardrail from [`GUARDRAILS.md`](../../GUARDRAILS.md) in its purest
form. There is no detection step to evade — a compromised agent cannot write, because the
process it runs in has no write credential. Compare that with a hook, which must correctly
recognise the bad action first.

### What it buys

> "This provides **least privilege, defense against prompt injection, auditability, and
> controlled limits per operation.**"

Four properties from one architectural decision. That ratio is what makes structural
guardrails worth reaching for before deterministic ones.

### The output types are a closed set

Issues and discussions (`create-issue`, `update-issue`, `close-issue`, …), pull requests
(`create-pull-request`, `create-pull-request-review-comment`, …), labels and assignment
(`add-labels`, `add-reviewer`, `assign-milestone`, …), projects and releases, security
(`create-code-scanning-alert`, `create-check-run`), plus system types `noop`,
`missing-tool`, `missing-data`.

**A closed vocabulary is itself the control.** The agent cannot request an operation that has
no handler — so the attack surface is the list, not "anything the token permits."

### Sanitisation

`allowed-domains` and `allowed-github-references` restrict which URLs and references may
appear in output; `max-bot-mentions` and `mentions` filtering limit spam and manipulation.

> Note what this defends against: the agent writing something *user-facing* that contains an
> attacker's link. Output is an injection vector in both directions.

### Take this pattern back to Track B

The read-only-then-scoped-write split is not gh-aw-specific. It is the shape your backend
agent should have at B10 and B13: the agent proposes a diff; something else with different
credentials applies it. `read-only → sandboxed write → branch → PR → human review` is the
same idea at a different scale.

---

---

## Extract — re-verification 2026-09-27: what drifted in 49 days

The extract above was written from the pages as they read on **2026-08-09**. It is kept
verbatim; nothing in it is edited. Everything below is a fresh read, 49 days later, and it
changes three of the things the August extract leaned on.

**How the check was run, so a stranger can re-run it — and it is committed, not described.**
[`evidence/p08/verify-quotes.sh`](../../evidence/p08/verify-quotes.sh) fetches each of the seven
pages with `curl`, strips tags, collapses whitespace, and then searches with `grep -F` for the
**29 sentences this workbook quotes**, printing `FOUND` or `ABSENT` per sentence. Registered exit
codes: `0` all found, `2` at least one absent, `3` a page could not be fetched, `4` bad usage.
ShellCheck clean.

**It has been shown to refuse**, which is the only reason to believe it when it accepts:
[`evidence/p08/verify-quote-checker.sh`](../../evidence/p08/verify-quote-checker.sh) is its
fixture set — **16 cases, 16 passed, exit 0** after two §4a rounds added six (10 before them) —
covering all four exit codes, including a fixture
with exactly one quote deleted (`exit 2`, `absent=1`) and a quote containing `!==` matched
literally rather than as a regex. **Case B was then re-derived by hand**: 29 `<p>` lines in, the
first quote stripped, 28 out, and the one `ABSENT` line names the quote that was removed.

The live run over the network is
[`evidence/p08/quote-verification-20260927T194029Z.txt`](../../evidence/p08/quote-verification-20260927T194029Z.txt):
**`found=28 absent=1`, exit 2.** That exit 2 is this section's headline and the single absent
line is quoted below.

That is an **L2 proof of quoting** — something executes and returns a per-sentence verdict — and
it is a proof of nothing whatever about the agent under test.

### 1. The boldest sentence in the August extract is not on the page

The August extract quotes, as a display quote and in bold:

> "**The agent never receives write tokens directly.**"

**That sentence is `ABSENT` from the safe-outputs page on 2026-09-27.** The page's equivalent
sentence today is:

> "all without giving the agentic portion of the workflow any write permissions"

The claim survives the rewording; the quotation does not. Two of the August extract's other
quotes were re-checked and **both are still `FOUND` verbatim**: *"Safe outputs enforce security
through separation: agents run read-only and request actions via structured output, while
separate permission-controlled jobs execute those requests"* and *"least privilege, defense
against prompt injection, auditability, and controlled limits per operation"*. So this is one
sentence, not a rewritten page.

**What it is evidence of, stated narrowly:** a verbatim quote in this project's own extract went
stale in seven weeks and nothing executed to catch it. `check-links.sh` proves a URL resolves;
**no tool here proves a quotation is still in the document it cites.** That is an instrument
this project does not have, and it belongs in `author_notes`, not in this stop.

### 2. `Public Preview` is gone from the home page

The scaffold's note on the home row reads *"**Public Preview.** Pin versions, revalidate every
cohort"*. The fetched home page (106 072 bytes) contains **no case-insensitive match for
`public preview`, and none for `experimental` either**; its `<title>` is `Home | GitHub Agentic
Workflows` and its tagline is now:

> "Intelligent automation for GitHub. Run the coding agents you know and love, with strong
> guardrails and cost controls, in GitHub Actions."

**Read this carefully rather than as good news.** *Public Preview* disappearing from a landing
page is not a statement that the feature is now stable — the A/B experiments page still says
*"**A/B Experiments is an experimental feature.**"*, and the safe-outputs page marks 20-odd
output types `experimental` inline. The stability warning moved **from the front door to the
individual rows**, which means a reader who checks the home page for maturity now gets a
cheerful answer and a reader who checks the row they are about to use gets the truth. The
scaffold's *revalidate every cohort* advice is therefore **more** necessary than when it was
written, not less.

### 3. The closed vocabulary grew, and membership is the whole control

The August extract's sharpest idea is this one, and it is worth quoting from our own file:

> "**A closed vocabulary is itself the control.** The agent cannot request an operation that
> has no handler — so the attack surface is the list, not 'anything the token permits.'"

That reasoning is sound and the list has roughly doubled. Types present on 2026-09-27 that the
August extract does not mention include:

| Output type | What the page says it does | Why it matters here |
|---|---|---|
| `merge-pull-request` | *"Merge pull requests after policy gates pass (max: 1, experimental)"* | merge is now inside the vocabulary |
| `approve-workflow-run` | *"Approve a pending workflow run in the 'action required' state (max: 1, experimental)"* | approval is now inside the vocabulary |
| `push-to-pull-request-branch` | *"Push changes to PR branch (default max: 1, configurable; cross-repo supported via `target-repo` when the target repository is checked out)"* | a write to a branch, and a cross-repo one |
| `dispatch-workflow` / `call-workflow` / `dispatch-repository` | *"Trigger other workflows with inputs (max: 3, same-repo only)"* | the agent can start something else that has its own permissions |
| `create-agent-session` | *"Create Copilot coding agent sessions (max: 1)"* | the agent can start another agent |
| `jira-*`, `linear-*`, `ado-*` | create / update / comment on issues and work items, each `experimental` | writes that leave GitHub entirely |

**The conclusion is not "gh-aw got less safe."** The mechanism is unchanged and the separation
still holds: each of these runs in a separate job with its own scoped credential, and
`approve-workflow-run` and `merge-pull-request` are both marked `experimental` and are opt-in
per workflow. The conclusion is the sentence the August extract was one step away from:

> **A closed vocabulary bounds the attack surface exactly as tightly as its membership, and the
> membership is the vendor's to change between two readings of the same page.** An L1 control
> whose scope is a list maintained by someone else is an L1 control with an L3 perimeter.

For this project that is a concrete rule and not a musing: **if a gh-aw workflow is ever
adopted here, the `safe-outputs:` block must enumerate the types it wants rather than inherit a
default**, and the enumerated list belongs in a contract a review reads — because a type added
upstream needs no action by us to become available to a handler we already enabled.

> **That sentence is now scoped, because the §4a review found it claiming more than was read.**
> What the pages establish is that *the documented vocabulary* grew with no action by anyone
> here. Whether a newly added type reaches an **already-compiled** `.lock.yml` without a
> recompile is **not determined by anything I read** — and the compile step is a reason to think
> it may not. The perimeter claim holds about the vocabulary a reader of the docs inherits and is
> **unmeasured** about a workflow already committed. Naming that boundary is the point: a claim
> whose scope exceeds its evidence is this project's house failure mode.

### 4. The default is read-only, and the default is also one issue

The permissions page carries the whole L1 claim in one sentence, `FOUND` verbatim:

> "GitHub Agentic Workflows uses read-only permissions by default for security, with write
> operations handled through safe outputs."

The safe-outputs page then says, also `FOUND` verbatim:

> "When no `safe-outputs:` section is present (or when only system types are configured),
> `create-issue` is automatically enabled with conservative defaults (`max: 1`, labels and
> title-prefix set to the workflow ID). To opt out, add an explicit `safe-outputs:` section with
> the outputs you want."

Both are true and they are about different things. **The agent job is read-only; the workflow is
not.** A workflow with no `safe-outputs:` block at all can still create one issue per run,
through the separate job, with the separation intact. So the exit-gate clause *"read-only
default"* needs its subject named or it is false — and the clause as the scaffold wrote it does
not name one. **Filed as a correction to this phase's own exit gate**, answered at boundary 2.

Note also what the permissions page does **not** contain. A search for `do not grant`,
`avoid granting`, `never grant`, `warning`, `caution`, `should not`, `conflict` and `refuse`
returns **`ABSENT` on every one**. Nothing on that page tells a reader not to write
`contents: write` on the agent job while keeping the `safe-outputs:` block, and nothing says
that combination is flagged. The architecture is L1 **when it is configured that way**; the
configuration is L3.

> **One word cuts the other way and it is worth having.** `rejected` *is* `FOUND` on the page —
> exactly once, and about something else: *"`id-token: read` is not a valid permission and will
> be rejected at compile time."* So **`gh aw compile` does validate the permissions block and
> does refuse at least one value** — there is a real L2 sitting in the compiler. It simply does
> not police the combination that would dissolve the L1. Finding the one `FOUND` inside a set of
> absences is the difference between *"the page says nothing that executes"* and *"the page
> shows a validator that exists and stops somewhere else"*, and only the second is true.

## Extract — the injection defence: a job that executes, judged by a model

This is the page the scaffold's five did not include, and Lab 8.3 — the prompt-injection
fixture — cannot be designed without it. Every quote below is `FOUND` verbatim on 2026-09-27.

**Where it sits in the pipeline.** The page's own diagram is `Agentic Job → Threat Detection Job
→ Safe Output Jobs`, the last annotated *"(Write permissions, only if safe)"*. Its purpose:

> "analyze agent output and code changes for potential security issues before they are applied"

**It is on by default** — *"Threat detection is automatically enabled when safe outputs are
configured"* — and what it detects is named: *"prompt injection (malicious instructions
manipulating AI behavior)"*, secret leaks, and malicious patches.

**It blocks, and it fails closed.** Two sentences carry this:

> "If any threat is detected (`true`), the workflow fails and safe outputs are blocked."

> "If the detection process itself fails (e.g., network issues, tool errors), the workflow stops
> and safe outputs are not applied. This fail-safe approach prevents potentially malicious
> content from being processed."

**Failing closed on its own error is a real design decision and deserves the credit**: the
common alternative is a detector that waves content through when it cannot run, which is the
house failure mode of this whole project — a control reporting success over a smaller scope than
it claims. This one reports failure.

**And now the sentence that decides the layer:**

> "By default, threat detection uses the same AI engine as your main workflow to analyze output
> for security threats."

Apply the rule in order. Can a malicious issue body still be written down? **Yes** — it is
already in the output artifact. Does something execute and reject it? **Yes, a job.** So it is
**L2**, and `blocked` is a real verdict, not advice. But its decision procedure is a language
model — and by default *the same engine* that produced the output being judged. **A model
asked whether a model was manipulated is the weakest L2 this project has catalogued**, because
the thing it must detect is the thing it is made of. The page names no false-negative rate and
no limitation: `false negative` is `ABSENT`.

**Three ways out, all documented, and one is not a model.**

| Route | The page's words | Layer of the mechanism |
|---|---|---|
| `steps:` / `post-steps:` — *"Custom Detection Steps"* | *"Add specialized security scanning tools alongside or instead of AI detection"*, with a LlamaGuard example | **L2**, and deterministic if the step is |
| *"Combined AI and Custom Detection"* | both lanes on one output | **L2** |
| **Protected files** | *"a **static, rule-based** protection layer"* | **L2**, the only rule-based control on the page |

### Protected files — the one lane with no model in it

> "An AI agent operating in a repository can be tricked (through prompt injection or
> misconfigured tasks) into modifying: Dependency manifests (`package.json`, `go.mod`,
> `requirements.txt`, `Gemfile`, `pom.xml`, etc.) … CI/CD configuration
> (`.github/workflows/*.yml`, `.github/dependabot.yml`, etc.) … Agent instruction files
> (`AGENTS.md`, `CLAUDE.md`, `.claude/settings.json`, `.agents/`, etc.) — redirecting the AI
> agent's behavior on subsequent runs."

**Read that third line against this repository.** The vendor's own threat model names
`CLAUDE.md` and `.claude/settings.json` as the files whose modification redirects the agent on
*subsequent* runs — which is precisely the delivery channel every treatment in Track B uses
(`customization.instructionsHash` over an overlay `CLAUDE.md`, author decision 10.1). The
instrument this project trusts to prove a treatment arrived is, from gh-aw's point of view, a
supply-chain target. Nothing to fix here; it is the sharpest available argument for why the
per-run hash matters and why a measured overlay is never edited.

**Enabled by default, and the escape hatch is graded:** protection is on for
`create-pull-request` and `push-to-pull-request-branch`, and the failure message is concrete —
*"Cannot create pull request: patch modifies protected files (package.json)."* The
`protected-files:` field takes four values, and the default is the interesting one:

| Value | Behaviour, quoted |
|---|---|
| `request_review` **(default)** | *"Create the pull request and submit a REQUEST_CHANGES review listing the protected files. A human reviewer must approve before merge."* |
| `blocked` | *"Hard-block: the safe output fails with an error message"* |
| `allowed` | *"No restriction — all protected file changes are permitted"* |
| `fallback-to-issue` | *"Create a review issue instead of a PR / push, so a human can inspect and apply the changes manually"* |

**The default routes to a human rather than refusing**, which is an L2 that terminates in L3 —
the review still has to happen and be read. `blocked` is the L2 that terminates in itself. A
project that wants the guarantee has to choose the non-default value, and that is the same shape
as stop 22's `strictKnownMarketplaces` finding: the strict option exists and is not the default.

## Extract — who is allowed to start an unattended agent

The second page added at this stop, and the only source that answers the exit-gate clause
*schedule/event attack surface*.

**The trigger set is wide**: `workflow_dispatch:`, `schedule:` (*"human-friendly expressions or
cron syntax"*), `issues:`, `pull_request:`, `pull_request_target:`, `issue_comment:`,
`pull_request_review_comment:`, `discussion_comment:`, `workflow_run:`, `deployment_status:`,
`repository_dispatch:` (*"Trigger a workflow from outside GitHub using a single authenticated API
call"*), plus `slash_command:` and `label_command:`.

**The control on who may trigger is `roles:`, and its semantics are a trap worth naming — but it
only reaches a trigger that HAS an actor, and the §4a review caught me treating it as though it
reached all thirteen.** A `schedule:` trigger has no actor whose repository role could be
exact-matched, and `repository_dispatch:` authenticates an API caller rather than presenting a
repository role in the same sense. The trigger set therefore divides: **actor-originated triggers
are role-gated; the scheduled path is not gated by `roles:` at all** — which makes the surface
*larger* than the original sentence implied, not smaller. Which trigger classes execute the role
check is **not stated on the page**, and that absence is itself the finding.
*(Scoped 2026-09-27 from the §4a review, 2 of 2 runs.)*

> "Controls who can trigger agentic workflows using an exact-match allowlist against the actor's
> repository role. Defaults to `[admin, maintainer, write]`."

> "**Exact match, not a minimum threshold.** `roles` is an allowlist, not a privilege threshold.
> Setting `roles: [write]` will reject actors with `admin` or `maintainer` roles because
> `admin !== write`."

**A field that looks like a floor and is a set.** Someone tightening a workflow by writing
`roles: [write]` locks out the admins — the failure is loud and therefore survivable. The
dangerous direction is the documented opposite: the page's own example comments
`# Default; use \`all\` to allow any user (! caution)`. **This is the same reversal stop 7 found
between `tools:` and `allowed-tools:`** — one narrows, the other pre-approves, and the names do
not tell you which. Third occurrence in this project of *a permission field whose direction must
be read, not assumed*.

**Forks are blocked by default**: *"Pull request workflows block forks by default for security.
Use the `forks:` field to allow specific fork patterns"*, and on `pull_request_target:` — *"Use
this only when the workflow needs write-capable repository context, and avoid checking out
untrusted fork code."*

**And the phase's own noise-kill rule exists upstream as something that executes.** The
scaffold's rule is *"If an unattended workflow generates ignored or noisy output for two
consecutive weeks: disable → analyze → redesign → re-evaluate"* — **L3, words a human reads.**
gh-aw ships `stop-after:`:

> "Automatically disable workflow triggering after a deadline to control costs… Accepts absolute
> dates (`YYYY-MM-DD`, `MM/DD/YYYY`, `DD/MM/YYYY`, `January 2 2006`, `1st June 2025`, ISO 8601)
> or relative deltas (`+7d`, `+25h`, `+1d12h30m`)."

**That is the L3 rule converted to L2 by the vendor, and it is the single most portable thing on
these seven pages.** A deadline written when the workflow is created, before anyone is invested
in its output, is a threshold registered before the data — which is this project's central
discipline arriving from the outside. What it does *not* do is judge usefulness; it expires. The
analyze → redesign half stays L3 and stays ours.

## Extract — the vendor now ships the registration discipline this project does by hand

The A/B experiments page in August was a line in a reading list. It now describes an experiment
registry inside the workflow file, and it deserves reading against `templates/experiment.md`
rather than as a feature list. Every string below is `FOUND` verbatim.

Declaration, in frontmatter:

```yaml
experiments:
  prompt_style:
    variants: [concise, detailed]
    description: "Test whether a concise prompt reduces cost without quality loss"
    hypothesis: "H0: no change in aic. H1: concise reduces AIC by >=15%"
    metric: eval:focused
    secondary_metrics: [duration_ms, discussion_word_count]
    guardrail_metrics:
      - name: success_rate
        threshold: ">=0.95"
    min_samples: 25
```

**Four things here this project built by hand, and one it did not.**

| gh-aw field | This project's equivalent | Layer, applied in order |
|---|---|---|
| `hypothesis:` | the prediction commit, timestamped before the first run (§4 step 3) | **L3 there, L3 here.** It is a free-text string; nothing parses `H1: … >=15%`. **A hypothesis field does not make prediction-before-run enforceable — the commit timestamp is what does that, and gh-aw has no equivalent** |
| `min_samples: 25` | `n ≥ 5`, and §5's *"nothing from `n < 5` is stated as a property"* | **L2 over the verdict.** *"Only usable observations count toward `min_samples`"*, and below it the decision returns `EXTEND` |
| `guardrail_metrics` with `threshold` | B13's seven clauses, and *"efficiency improvements are rejected when quality declines"* | **L2 over the verdict** |
| `decision: {minimum_effect, confidence}`, `analysis_type: mann_whitney` | the MDE table and the decision rule registered before the batch | **L2 over the verdict** |
| — | the concurrent control, interleaved | **absent upstream.** See randomisation below |

**The verdict vocabulary is nearly ours.** `gh aw experiments analyze` returns:

> "**PROMOTE** The candidate has sufficient statistical evidence, exceeds the practical-effect
> threshold, and passes all guardrails. **REJECT** The candidate materially regresses or fails a
> mandatory guardrail. **INCONCLUSIVE** Minimum samples exist, but the evidence or practical
> effect does not establish a winner. … **EXTEND** means that evidence collection or computation
> is incomplete."

Track B's rows are void / not detectable / reject / improved. `INCONCLUSIVE` is `NOT DETECTABLE`
(stop 11's verdict) and `EXTEND` is `n` too small. **Two independent designs converged on four
rows and on the distinction that matters most — "we could not tell" is not "no difference".**

**Two sentences that are better than most of this project's own prose on the subject:**

> "Statistical significance alone does not override `minimum_effect`."

> "Assignment identifies the treatment (`control` or `candidate`); it is not an outcome."

**The second one is where the upstream instrument stops, and it is the same wall this project has
hit three times.** The assignment ledger records *which variant a run was assigned*. It does not
record that the variant **reached the model**. That is exactly position 9's finding — a `tools:`
file *"is not the treatment until its `init` record says so"*, after the runtime silently
rewrote the list — and exactly author decision 11 item 9, which had to name four non-hash
delivery conditions because `run-agent.sh` hashes one agent file out of four. **gh-aw's ledger is
L2 for attribution and L3 for delivery**, and a project adopting it would still have to build
the delivery proof itself.

**And the one place the upstream design is weaker than ours, stated plainly:**

> "By default, gh-aw chooses the least-used variant on each run… Over time, this keeps usage
> roughly balanced across variants."

**Balanced assignment is not randomisation.** Deterministically picking the least-used variant
makes arm membership a function of run order — **to the extent the page defines it: the
tie-breaking rule between two equally used variants is not documented, so whether run 1 always
lands in the same arm is unstated, and only the existence of the confound follows, not its
exact shape** *(scoped from the §4a review)* — so anything that drifts with time — a model
update, a rate limit, a repository that got bigger — lands unevenly and is indistinguishable
from the treatment. This project's mitigation is interleaving with a **concurrent** control,
which has the same weakness and at least keeps the arms in the same time window; `min_samples:
25` over a `start_date`/`end_date` range does not. **A reader of this project should not adopt
the upstream assignment rule as if it were an improvement on the concurrent control.** It is a
different trade with the same flaw, and it is the reason arm C of E-004 and the fourth cell of
decision 10.1 had to exist at all.

Finally, what the page does **not** report: cost or token usage per variant is `ABSENT` as a
metric name, though `aic` (AI credits) appears as a primary metric and detection has its own
budget (`GH_AW_DEFAULT_DETECTION_MAX_AI_CREDITS`, default `400`). **A threat-detection pass is
itself a metered model call**, so an injection defence has a running cost per protected write —
worth knowing before Lab 8.3 is costed.

## Extract — the compile step, and the only L3 that should frighten anyone

> "A GitHub Agentic Workflows source is a Markdown file in `.github/workflows/`"

> "The `gh aw compile` command turns this source into the `.lock.yml` GitHub Actions workflow"

> "Add, commit and push the workflow file and its lock file to your repository."

> **Disputed §4a finding, recorded with its reason.** The review asked for a stated pass/fail
> correspondence check between `.md` and `.lock.yml`, on the scenario of a reviewer inspecting
> only the source. **That scenario is the hazard this section reports, not a divergence about
> what the section says** — the finding restates the conclusion as though it were an omission.
> Supplying such a check would be building an instrument for a workflow this project does not
> run, which §6 forbids at this stop. The absence stays the finding. *(Disputed 2026-09-27.)*

**Two committed files, one of which executes.** The `.md` is what a human reviews — the prompt,
the `permissions:` block, the `safe-outputs:` list, the `roles:` allowlist. The `.lock.yml` is
what GitHub Actions runs. A repository can therefore hold a source file whose
`permissions: contents: read` a reviewer approves, beside a lock file compiled from an earlier
version that says something else, and **every quoted control in this extract lives in the file
that is not the one being read.**

Searched on the *Creating workflows* page for a mechanism that catches this: `stale`,
`out of date`, `out-of-date`, `recompile`, `--verify` and `check that the lock` are **`ABSENT`,
all six**. That is a scoped claim about one page — a `gh aw compile --check` may exist elsewhere
in the CLI and a CI job recompiling and diffing is trivial to write — but **as documented on the
page that tells a newcomer how to create a workflow, the correspondence between the reviewed
artifact and the executed artifact is L3.**

**This project has already paid for exactly this mistake once and the receipt is in the
workspace `CLAUDE.md`.** Position 9: a `tools:` list reading `Read, Grep, Glob, Bash` was
*delivered to the model* as `["Read", "Bash"]` on 10 of 10 runs — the file a human read was not
the configuration that ran, and it took an `init`-record probe to see it, which is now mandatory
before any B step registers an allowlist. **`.md` → `.lock.yml` is the same gap with a build
step in the middle.** If a gh-aw workflow is ever adopted here, the read-back is not optional and
the artifact to read back is the lock file.

## Take this pattern back to Track B — what actually ports

The August extract's version of this section still holds and is kept above. What the fresh read
adds, as a ranked list — most portable first:

1. **`stop-after:` as a shape, not as a feature.** An expiry written at creation time, before
   anyone is attached to the output. The lab equivalent costs nothing: a registered end date on
   any always-on instrument. **L2 upstream, L3 here, and the conversion is cheap.**
2. **Fail-closed on the detector's own failure.** *"If the detection process itself fails … the
   workflow stops"*. This project's scorers do the opposite in one documented place — `curl`
   returning `000` in `check-links.sh` *"degrades to a non-fatal `unverified`"* (`author_notes`,
   carried for weeks). Same decision, opposite default — and **gh-aw's is the right one for a
   check whose output gates a claim**, which is the qualification the §4a review correctly
   demanded. A detector that cannot run must not let a write through. A *reachability* check that
   degrades an unreachable host to `unverified` is defensible precisely because nothing gates on
   it. So the portable rule is narrower than "fail closed": **a check whose result is quoted as
   evidence must fail closed; a check that only reports may degrade.** By that rule
   `verify-quotes.sh` must fail closed — and it does, observed live rather than argued: exit 3 at
   `evidence/p08/quote-verification-20260928T0000Z-fetch-timeout-exit3.txt` when one page timed
   out at boundary 2.
3. **Enumerate the vocabulary; never inherit the default set.** §3's *"one variable"* rule has an
   analogue: a capability list that someone else can extend is not a fixed variable.
4. **`INCONCLUSIVE` vs `EXTEND` as separate rows.** Track B collapses both into
   `NOT DETECTABLE`. Stop 11 and stop 17a would both read more honestly as *"the engine could
   adjudicate and no winner emerged"* versus *"the population was too small to adjudicate"*,
   and E-016 at `n = 7` is precisely the second. **Worth a follow-up in `author_notes`, not a
   change to a closed decision rule.**
5. **What does not port, and must be said:** gh-aw's `hypothesis:` field. Pointing at a frontmatter
   string as the registration would be a **downgrade** from a git commit whose timestamp precedes
   the first run's `startedAt` — the one control in this project that a stranger can re-derive
   from two independent records. §4 step 3 stays exactly as it is.

---

## Predict before you run

> **No prediction is registered at this stop, and that is the rule, not an omission.** A ◇ stop
> runs nothing, and §4 step 3 registers a prediction *before a run* — a prediction with no run
> measures nothing, and writing one here would put an unfalsifiable number on the record. The
> three questions below stay as the scaffold wrote them: they are **the predictions Lab 8.1 owes
> when it is run**, not predictions this stop makes. *(Stop 23, 2026-09-27, Opus 5.)*
>
> One of them is now answerable in advance from the reading and it is worth saying which:
> question 3, *run cost per useful finding*, has a term the scaffold could not have known about
> — a threat-detection pass is itself a metered model call with its own credit budget
> (`GH_AW_DEFAULT_DETECTION_MAX_AI_CREDITS`, default `400`), so the denominator of any
> cost-per-finding figure includes the cost of the injection defence, on every run, whether or
> not anything was found.

1. What fraction of a daily drift report will be genuinely actionable in week one? Week
   three?
2. What does your workflow do with an issue body containing adversarial instructions?
3. What is the run cost per useful finding?

## Lab 8.1 — Read-only scheduled report · **DEFERRED**

First unattended workflow: a daily standards-drift report. Artifact or staged result, **no
repository mutation**.

Measure: useful finding rate · false positive rate · run cost · runtime · duplicate/noise
rate.

> **What it still owes.** A `.md` workflow plus its committed `.lock.yml`, five scheduled runs,
> and a hand-scored actionable/noise split — plus the one thing the reading says cannot be
> skipped: **the read-back must be of the lock file, not the source.** `stop-after:` set at
> creation, before anyone is attached to the output. It needs no benchmark run and no dollar of
> the agent under test, so it is deferred on **session budget**, not on a blocker.

## Lab 8.2 — Safe output in staged mode · **DEFERRED**

A workflow proposing an issue/PR, run staged/preview first. Inspect: agent job permissions ·
downstream write permissions · structured output · sanitization · final action.

> **What it still owes**, and the reading has sharpened it: the inspection list above is
> incomplete. Add **(a)** whether the `safe-outputs:` block enumerates its types or inherits the
> default `create-issue` (`max: 1`), and **(b)** the `protected-files:` value in force, because
> the default `request_review` routes to a human and only `blocked` refuses. Staged mode is the
> one **L1** here — *"Every write operation is skipped"* — so this lab measures an architecture
> with the capability removed, which is the correct order and Phase 5A's lesson.

## Lab 8.3 — Prompt injection fixture · **DEFERRED**

A test issue body with adversarial instructions. Expected: it must not directly obtain write
capability; safe outputs and policy limit blast radius; security detections fire.

> **What it still owes, and this is the lab the extract changed most.** *"Security detections
> fire"* is not one outcome but two, at two different layers, and they must be recorded
> separately:
> **(a)** the agent does not obtain write capability — **L1**, and it holds whether or not the
> injection succeeds, because the credential does not exist; and
> **(b)** threat detection classifies the output as a threat — **L2 with a model as its judge**,
> *"the same AI engine as your main workflow"*, so a miss here is expected some fraction of the
> time and the fixture must be run **more than once** to say anything at all about the rate.
> A single run that gets blocked proves (a) and proves nothing about (b). Also register the
> **fail-closed** path — kill the detector's network and confirm the workflow stops — because
> that is the one guarantee on the page that does not depend on the model's judgement.

## Lab 8.4 — A/B experiment · **DEFERRED**

One variant: concise prompt vs detailed prompt.

> Concise variant reduces AI units/tokens by ≥15% while keeping evaluation score above 0.9.

Multiple runs. This is where controlled experiments beat preference — and where the
lessons from Phase 1 about *registering the bar before you see the data* pay off.

> **What it still owes.** The bar above (`≥15 %`, score `>0.9`) maps onto `decision:
> {minimum_effect: 0.15}` and a `guardrail_metrics` threshold almost exactly, and `min_samples:
> 25` is the upstream `n`. **Two things must not be adopted with the feature**, and both are in
> the extract: the `hypothesis:` string is not a registration — the prediction still goes in a
> **git commit whose timestamp precedes the first run's `startedAt`** — and *"gh-aw chooses the
> least-used variant on each run"* is **balanced assignment, not randomisation**, so arm
> membership is a function of run order and drifts with anything else that does. Run it with a
> concurrent control or do not claim a comparison.

## Debts the deferred labs owe before they run — registered by the §4a review, 2026-09-27

The review read the four DEFERRED labs and the noise-kill rule as though they were about to be
run, and found each one underspecified in a way that lets two competent reviewers reach opposite
verdicts from the same data. **None of these is fixed here** — designing a deferred lab's decision
rule at this stop would be creating a future step's artifact, which §6 forbids. They are recorded
so the lab cannot be run without answering them, which is the whole function of writing a debt
down.

| Lab / rule | What is undefined | Why it decides the result |
|---|---|---|
| **Lab 8.1** — hand-scored actionable/noise split | the **denominator**: per emitted item or per unique item after de-duplication | five reports with 20 items, 3 duplicates, gives two different useful-finding rates from one run ledger |
| **Lab 8.2** — staged mode | the **pass criterion**: is "no mutation occurred" enough, or must the production handler be shown to reject a disallowed request? | identical output yields opposite lab verdicts |
| **Lab 8.3** — injection fixture | the **repetition count and decision threshold**: "more than once" spans 2 runs and 100 runs | 1 detection in 2 vs 40 in 100 are materially different claims about the miss rate; at `n < 5` §5 forbids stating either as a property |
| **Lab 8.4** — A/B | the **boundary operator** on `above 0.9` (`>` or `>=`), and whether counterbalancing is required as well as concurrency | a variant scoring exactly `0.900` is promoted by one reading and rejected by the other; and a concurrent control still leaves treatment confounded with order if the candidate always follows the control |
| **The noise kill rule** | `ignored`, `noisy`, the **threshold**, the denominator and the **named observer** | nine ignored of ten for two weeks is "disable" to one reader and "keep" to another |

**Lab 8.4's debt is the one that generalises past this phase**, and it is the same argument
`author_notes` already carries about `INCONCLUSIVE` vs `EXTEND`: interleaving gives a concurrent
control and **does not by itself give exchangeable arms**. Every interleaved batch in this track —
E-007, E-011, E-013, E-016 — inherits that, and it is a question for the author about the decision
rule, not a defect in any closed stop. *(Registered, not fixed, 2026-09-27.)*

## The noise kill rule

If an unattended workflow generates ignored or noisy output for two consecutive weeks:

```
disable → analyze → redesign → re-evaluate
```

**Do not preserve automation because "AI-first".**

> **Half of this rule now exists upstream as something that executes, and it is the most
> portable thing on the seven pages.** `stop-after:` — *"Automatically disable workflow
> triggering after a deadline to control costs"* — is the `disable` step as **L2**, and it is set
> at creation time, before anyone is invested in the output. The rule as written here is **L3**:
> words a human reads and chooses to follow, with nothing that executes and no two-week timer
> anywhere. The `analyze → redesign → re-evaluate` half stays L3 and stays ours, because nothing
> upstream judges whether output was *useful*. **A deadline is not a quality gate; it is a
> deadline** — and it is still better than a rule that depends on somebody remembering.
> *(Stop 23, 2026-09-27, Opus 5.)*

## Learning — §4 step 11

The six keys of `build/README.md#after-every-step`, in that order and with no others.

```yaml
learning:
  what_was_added: >
    No agent capability and no benchmark run. What was added is a re-verification of a
    49-day-old extract against the live pages, and one instrument that executes:
    evidence/p08/verify-quotes.sh — 29 registered sentences over the seven Verified-reading
    pages, fetched over the network, printed FOUND or ABSENT, with four registered exit codes
    and a 16-case fixture set (evidence/p08/verify-quote-checker.sh) — 10 cases before the §4a
    review of this stop found FIVE defects in the checker across two rounds, and six more cases
    were added to prove the fixes refuse. Plus two SOURCES.md rows
    (threat-detection, triggers) and five dated extract sections beside the August text, which
    is kept verbatim.
  why_it_exists: >
    Because check-links.sh proves a URL RESOLVES and nothing here proved a QUOTATION still
    appears in the page it resolves to. This workbook's own August extract carries, as a bold
    display quote, "The agent never receives write tokens directly" — and that sentence is not
    on the page it cites. The claim survived a rewording; the quotation did not. A verbatim
    quote in this project's own extract went stale in 49 days and nothing executed to catch it.
  observed_effect: >
    The instrument failed on our own workbook on its first live run: found=28 absent=1, exit 2,
    and the single ABSENT line is our own August sentence. Re-run at boundary 2 over the network:
    found=28 absent=1, exit 2, same sentence. Two other August quotes were re-checked and are
    still verbatim, so this is ONE SENTENCE, not a rewritten page. Four further findings of
    record, each verified FOUND before it was written down: the safe-output vocabulary roughly
    doubled and now contains merge-pull-request and approve-workflow-run; the injection defence
    is L2 and its judge is a language model; `roles:` is an exact-match allowlist and not a
    privilege threshold; and `.md` -> `.lock.yml` means the file a human reviews is not the file
    that executes.
  unexpected_effect: >
    Two, both cutting against a conclusion that was easier to write. (1) The absences were
    checked rather than asserted, and one FOUND turned up inside them: "id-token: read is not a
    valid permission and will be rejected at compile time" — so `gh aw compile` DOES validate the
    permissions block and DOES refuse at least one value. "The page says nothing that executes"
    would have been false. (2) The threat detector FAILS CLOSED on its own failure — "If the
    detection process itself fails ... the workflow stops and safe outputs are not applied" —
    which is the opposite of this project's own check-links.sh degrading a curl `000` to a
    non-fatal `unverified`. Same decision, opposite default, and theirs is the right one.
  keep_or_remove: >
    KEEP evidence/p08/verify-quotes.sh, scoped to this phase only. It is the one artefact of this
    stop with an L2 proof — but it earned that only after its own review found FOUR defects in it,
    every one of which reported a FAILURE TO FETCH as DOCUMENTATION DRIFT. One empty cached page or
    one typo and the pre-fix script printed nine quotations as stale. The instrument built to catch
    a stale claim would have manufactured louder versions of the same claim, and nothing would have
    contradicted it. KEEP the fixed script: 16 of 16 fixtures over all four exit
    codes, including one fixture with exactly one quote deleted (exit 2, absent=1) and one quote
    containing `!==` matched literally rather than as a regex; case B re-derived by hand. A
    general, repo-wide quote checker is REFUSED at this stop and sits in author_notes — §6 forbids
    a future step's artefacts and a repo-wide instrument is not stop 23's. REMOVE nothing: no rule,
    hook, skill or overlay was added, so there is nothing whose no-effect could be measured.
  next_question: >
    Does a quotation-staleness check belong on every extract in this repository, and if so what is
    its registered cadence and its expiry? gh-aw's own answer to the second half is `stop-after:`,
    an expiry written at creation time before anyone is attached to the output — the most portable
    thing on these seven pages, and the one this project could adopt for nothing.
```

**What problem did it solve, and what evidence supports keeping it** — the two scaffold
questions not covered by a key above. The problem: an extract is L3 by construction, and this
project had no way to tell a stale quotation from a current one short of a human re-reading
seven pages. The evidence: the instrument's first live run found a defect in the workbook that
commissioned it, and its fixture set proves it refuses — **16 of 16 over four exit codes** after
two §4a rounds added six cases (see the review section below). **The new cost:** **seven**
network fetches per invocation — one per page in `PAGES`, not one per sentence — plus a
registered list of 29 sentences that must be edited whenever the extract is, which is a
maintenance burden a repo-wide version would multiply; that is the argument for keeping it
phase-scoped until someone measures the burden.

> **`29 network fetches per invocation` was simply wrong, by a factor of four, and the §4a review
> caught it in 2 of 2 runs.** The loop is `for entry in "${PAGES[@]}"` with one `curl` per entry
> (`evidence/p08/verify-quotes.sh:87,97`) and `PAGES` holds **seven** URLs; the 29 is the
> sentence count, searched locally in the stripped text. Re-derived by hand off the script and
> off the live output, whose `[tag]` values resolve to six distinct pages plus `home`, which
> carries no registered sentence. *(Fixed 2026-09-27.)*

## Validation — §5, at §0 boundary 2, 2026-09-27

**`n = 0` runs.** This is the registration, not a shortfall: §3's itinerary row `22-23` reads
*"Phases 7 and 8 (◇): extract only, as stop 7"*, and §4 makes a Track A stop the loop **minus
steps 3–10** when the lab runs no benchmark. No experiment file, no prediction, no overlay, no
dollar spent on the agent under test at this stop. Verified, not asserted: over all **740** runs
on the API, the count of runs whose `experimentKey` matches `p08|stop23|PHASE-8|B8-agentic` is
**0** (`curl -fsS http://127.0.0.1:8081/api/runs | jq '[.[] | select((.experimentKey // "") |
test("p08|stop23|PHASE-8|B8-agentic";"i"))] | length'`, run at boundary 2, **exit status 0 on
both stages**, and the `740` is the same call's `jq length`). The pinned model was touched only
by the §0a row-6b isolation probe, run `a74ac5fe-605a-4607-84f7-de67082ddbd9`, whose key is
`preflight-*` and which enters no comparison.

> **The §4a review attacked this derivation twice and one attack is answered, not fixed.** Run 1
> asked what happens if the API is down: `curl -fsS` fails, `jq` gets empty input and errors, and
> the pipeline does not print `0` — so the failure mode is a visible error, not a false zero; the
> status is recorded above to close it. Run 2 argued the regex is **broader** than the stop's key
> set and could count an unrelated `p08-old`. **That is a reason the result is stronger, not
> weaker: a superset that matches nothing proves the subset matches nothing.** Had it returned a
> non-zero count I would have had to inspect each match before claiming anything — which is why
> the pattern is deliberately loose. Recorded as a **dispute**, with the reasoning, per §4a step 2.

**Independence check: there are no arms to be independent of.** A one-variable comparison needs
two populations and this stop has none. Nothing in this workbook is a claim about
`claude-haiku-4-5-20251001`; every subject row is a claim about seven vendor documentation pages,
and the proof column says so.

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| `Human-triggered vs unattended risk` | `phases/08-agentic-workflows/README.md:405-452`; the trigger set and `roles:` quotes, each verified `FOUND` by `evidence/p08/verify-quotes.sh`; live output `evidence/p08/quote-verification-20260927T194029Z.txt` | **L2 that the sentences are on the pages** (a script fetches and matches); **L3 that the risk transition behaves as described** — `n = 0`, nothing was watched | `./evidence/p08/verify-quotes.sh` → expect `found=28 absent=1`, exit 2. Then read the section and compare each quoted sentence with the `FOUND` lines |
| `Read-only default` — **answered `qualified`, not `yes`** | `phases/08-agentic-workflows/README.md:288-312`; two verbatim quotes, both `FOUND`: *"uses read-only permissions by default"* (permissions page) and *"`create-issue` is automatically enabled with conservative defaults (`max: 1` …)"* (safe-outputs page) | **L2** that both sentences exist; **L3** that the combination is safe | Run the script; both sentences appear in its `FOUND` list. The clause is false without its subject: the **agent job** is read-only, the **workflow** is not |
| `Safe-output separation` | `phases/08-agentic-workflows/README.md:48-50` (layer table row) and `:133-154` (the August extract, kept verbatim) | **L3.** The control is **L1** — the agent's process holds no credential that can express a write — but the *proof* is a reading. I read that the jobs are separated; I did not watch a write be refused | Read the safe-outputs page at the URL in `SOURCES.md` and confirm the two-job split. To move this row to L2 someone must run Lab 8.2 (`staged: true`), which is **DEFERRED** |
| `Schedule/event attack surface` | `phases/08-agentic-workflows/README.md:405-452`; thirteen trigger types, `roles:` exact-match, *"Pull request workflows block forks by default"*, `stop-after:` — all `FOUND` | **L2** that the sentences are on the page; **L3** that the surface is bounded | Run the script, then count the trigger types in the section against the triggers page |
| `Why auto-merge should not be the first target` | `phases/08-agentic-workflows/README.md:255-287`; `merge-pull-request`, `approve-workflow-run` and `push-to-pull-request-branch` are now **in** the closed vocabulary, each marked `experimental` | **L3.** It is an argument, not a measurement — but a sharper one than the scaffold could make, because auto-merge is no longer hypothetical | Read the safe-outputs page's output-type list and find the three names. The August extract does not contain them |
| `Was this the agent, or the harness?` (§4 step 11) | **Neither.** `n = 0` runs; the run count for this stop's keys is `0` of `740` on the API | **L2** — a counted query over the run store, not a claim | The `jq` one-liner above. An empty result is the whole answer |
| Instrument: `./tools/check-links.sh` over the two new `SOURCES.md` rows | re-run at boundary 2: `ok=73 moved=11 blocked=2 unverified=0 broken=0`, **exit 0** | **L2** | `cd agent-learning-lab && ./tools/check-links.sh`. Two more `ok` than stop 22's 71 — the two new rows and nothing else |
| Instrument: `./evidence/p08/verify-quotes.sh`, live over the network | **after** the four §4a fixes: `found=28 absent=1`, **exit 2**, same absent sentence — `[safe] The agent never receives write tokens directly`, this workbook's own August quote (`evidence/p08/quote-verification-20260928T0006Z-postfix.txt`). The headline is unchanged by the fix, which is the only reason it may still be stated. Its **fail-closed** path was observed rather than argued: exit 3 on a timed-out page, `evidence/p08/quote-verification-20260928T0000Z-fetch-timeout-exit3.txt` | **L2** | `./evidence/p08/verify-quotes.sh`. **If it returns `29/0` the page changed again and that is a new finding, not a pass** |
| Instrument: `./evidence/p08/verify-quote-checker.sh` (the fixture set) | re-run after both §4a rounds: **`16 passed, 0 failed`**, exit 0, over all four registered exit codes (`evidence/p08/quote-checker-fixtures-20260928T0410Z-16-cases.txt`); case B re-derived by hand, and cases **I, J, K, L and M each proved to REFUSE the pre-fix script** — J and K returned `exit 2, found=20 absent=9`, and L and M returned `exit 2, found=0 absent=29` | **L2** | `./evidence/p08/verify-quote-checker.sh`. To re-derive the refusals: `git show <pre-fix sha>:evidence/p08/verify-quotes.sh` and run cases I/J/K at it. A checker never shown to refuse is indistinguishable from one that refuses nothing |
| The spine's `**L1**` label for Phase 8 (`LEARNING-PATH.md:103`) | `phases/08-agentic-workflows/README.md:35-77` — the layer rule applied **in order**; only **one** of ten subject rows survive step 1 | **L3, and now qualified rather than overwritten** | Apply the workspace `CLAUDE.md` rule in order to each row of the subject table. The label is right about the credential and wrong about everything that inspects content |
| The instrument built at this stop is itself sound | **five** defects found across two §4a rounds and fixed, each with a fixture proving it refuses the pre-fix script; ShellCheck exit 0 on both scripts; the fourth (page chrome) **disputed** and registered as a scoped limitation in the script header | **L2** | `shellcheck evidence/p08/verify-quotes.sh evidence/p08/verify-quote-checker.sh` (expect exit 0), then `./evidence/p08/verify-quote-checker.sh` (expect `16 passed, 0 failed`) |

Every command in the right-hand column was re-run immediately before this section was written,
and its output is the value quoted, not a remembered one.

## Exit gate

Answered at §0 boundary 2, 2026-09-27, from the extract above. `[x]` = answered from the reading;
`[~]` = answered **qualified**, with the qualification stated.

- [x] **Human-triggered vs unattended risk** — the difference is not the trigger, it is that
  `roles:` replaces the approval prompt, and `roles:` is an **exact-match allowlist, not a
  privilege threshold** (*"Setting `roles: [write]` will reject actors with `admin` or
  `maintainer` roles because `admin !== write`"*). Thirteen trigger types can start an agent,
  including `repository_dispatch:` — *"Trigger a workflow from outside GitHub using a single
  authenticated API call"*. Forks are blocked by default. The risk class changes because the only
  thing left between an outside actor and an unattended agent is a set literal whose direction
  must be read rather than assumed — the **third** occurrence of that shape in this project.
- [~] **Read-only default** — **qualified, and the clause as the scaffold wrote it is false
  without a subject.** The **agent job** is read-only by default (*"uses read-only permissions by
  default for security, with write operations handled through safe outputs"*). The **workflow is
  not**: with no `safe-outputs:` block at all, *"`create-issue` is automatically enabled with
  conservative defaults (`max: 1` …)"*. Both sentences are verbatim on their pages and they are
  about different things. Filed as a correction to this phase's own exit gate.
- [x] **Safe-output separation** — the one unambiguous **L1** in the subject table, and the only
  control where step 1 of the layer rule answers *no*: the agent's process holds no credential
  that can express a write, so there is nothing to reject. **It is the ONLY row that survives step 1**
  — `staged: true` was labelled L1 here until the §4a review, and it is **L2**: the write request
  is still expressed and something executes and *skips* it. It is also a preview mode, not a
  production control — Phase 5A's *remove the capability before policing it* shipped as
  *police it in preview*, which is a weaker thing than the August extract implied. Everything that **inspects
  content** is L2 at best: threat detection blocks, and *"By default, threat detection uses the
  same AI engine as your main workflow"* — **a model asked whether a model was manipulated, the
  weakest L2 this project has catalogued**, which nonetheless **fails closed on its own failure**
  and deserves that credit. The only rule-based lane is protected files, whose **default
  (`request_review`) routes to a human rather than refusing**; only `blocked` refuses — the same
  shape as stop 22's `strictKnownMarketplaces`: the strict option exists and is not the default.
- [x] **Schedule/event attack surface** — bounded by three things and nothing else: the trigger
  allowlist, `roles:`, and the closed output vocabulary. **The vocabulary is the whole control and
  its membership is the vendor's**: it roughly doubled in 49 days and now holds
  `merge-pull-request`, `approve-workflow-run`, `push-to-pull-request-branch`,
  `dispatch-workflow` / `call-workflow` / `dispatch-repository`, `create-agent-session` and
  third-party writers (`jira-*`, `linear-*`, `ado-*`). **An L1 control whose scope is a list
  maintained by someone else has an L3 perimeter.** `stop-after:` bounds the surface in *time* and
  is this phase's own noise-kill rule as something that executes.
- [x] **Why auto-merge should not be the first target** — because it is no longer hypothetical and
  that makes the answer sharper, not softer. `merge-pull-request` and `approve-workflow-run` are
  **in** the vocabulary, both `experimental`. The reason to refuse it first is the compile step:
  **`.md` → `.lock.yml` means the file a human reviews is not the file that executes.** Both are
  committed; only the lock file runs; and `stale`, `out of date`, `out-of-date`, `recompile`,
  `--verify` and `check that the lock` are **`ABSENT`, all six**, from the page that teaches
  workflow creation — a scoped claim about **one page**, not about the CLI. An agent that can merge
  its own pull request, behind a review surface that is not the executed artefact, is the one
  combination on these pages with no L1 anywhere in it.
- **Was this the agent, or the harness?** — **neither.** `n = 0` runs: 0 of 740 runs on the API
  carry a stop-23 experiment key. Every finding here is a property of seven documentation pages
  read on 2026-09-27, and the proof column of every subject row says **L3** for that reason.

**One clause of this gate was corrected rather than answered**, and that is recorded as the
result it is: a scaffold written before the pages were read asked for *"read-only default"* as a
yes/no, and the pages answer *"whose default?"*. *(Stop 23, §0 boundary 2, 2026-09-27, Opus 5
(claude-opus-5), autonomously; the author did not review before this was written.)*

## The §4a review — what it found, and what it found in the instrument

Two invocations, `-P codex`, `-n 2` each, run sequentially. **There is no acceptance verdict and
that is recorded as `DID NOT RUN`, not as a pass and not as `UNDECIDED`:** the gate is an
`opencode` route and `lab-acceptance` sits on the provider whose weekly limit has stalled §0a row 2
for ten consecutive sessions. `## Acceptance` in both files reads *"The gate failed to run (opencode
exit 1)"*. Both panels ran clean — `codex ok 62s / 63s` and `codex ok 24s / 25s` — so the findings
are results, not stalls.

- `findings/opencode/review-README-20260927T201538Z.md` — 23 136 bytes, 44 sections, the workbook
- `findings/opencode/review-verify-quotes-20260927T202016Z.md` — 6 555 bytes, 9 sections, the tool

**One family only, so recurrence is `1/1` on every row and `2 of 2 runs` is the honest phrasing for
the four findings both runs raised** — the `staged: true` label, `roles:` on actorless triggers, the
fetch count, and the Commit block. §4a is explicit that recurrence is a detection threshold and not
a truth value, so the single-run findings were dispositioned on their merits, not discounted.

**Every finding is dispositioned above, at the text it concerns**: eight fixed, two disputed in
writing with the reason (the compile-step correspondence check; the deliberately-broad `jq`
pattern), and five registered as debts of the deferred labs. The PR body carries the same list
against the shas.

### The instrument review is the part worth reading, because the instrument was wrong

`verify-quotes.sh` — the one L2 artefact this stop produced, ShellCheck clean, 10 of 10 fixtures —
had **five defects, all of the same shape: a failure to fetch reported as documentation drift.**
That is this project's house failure mode pointed at the tool built to catch it.

| Defect | What it did | Fix | Fixture |
|---|---|---|---|
| `curl` had no `--fail` | a 404 serving a non-empty HTML error page exits 0, gets stripped to real text, and **every quote on that page reports `ABSENT`, exit 2** — claiming drift for a page never read | `curl -fsS` → exit 3 | **I** |
| an empty **cached** page was accepted | `-f` without `-s`: the cache branch reached the matcher and exited 2, while an empty *live* response or *fixture* exits 3. **Same content, two verdicts, decided only by where it came from** | `-s` check → exit 3 | **J** |
| an **undeclared page key** in `QUOTES` | a one-character typo read a file that does not exist, `2>/dev/null` swallowed the error, and the quote printed `ABSENT` — an invalid verifier configuration indistinguishable from real drift | validate every key against `PAGES` → exit 4; `2>/dev/null` removed | **K** |
| `strip` had **no failure guard** *(round 2, the gate's blocking finding)* | a crashing `python3` or one non-UTF-8 byte left an empty `.txt`; the matcher read it and **all 29 quotes printed `ABSENT` at exit 2** — the whole extract declared stale | check `strip`'s status and its output → exit 3 | **L**, **M** |
| `strip` keeps page **chrome** | a sentence deleted from the body but surviving in navigation would still report `FOUND` | **disputed, and registered as a scoped limitation in the script header** — the claim supported is *"the sentence still appears somewhere on the cited page"*, which is the claim a quotation makes; body extraction needs a per-site selector that breaks on the next redesign | — |

**The first three were proved against the pre-fix script, not asserted.** `git show HEAD:` the old
file and run the new cases at it:

```
case I   OLD does not carry --fail
case J   OLD exit 2, found=20 absent=9      (fix expects exit 3)
case K   OLD exit 2, found=20 absent=9      (fix expects exit 4)
```

**One empty cached page, or one typo, and the old checker reported nine quotations as stale
documentation.** It would not have failed; it would have produced a *louder* version of this stop's
headline, and nothing would have contradicted it. That is the same shape as the contamination guard
at stop 8 that would have excluded the treatment arm and reported a null — a control whose failure
looks exactly like a finding.

### Round 2 — the acceptance gate ran, returned `REJECT`, and was right

`findings/opencode/review-verify-quotes-20260928T040312Z.md`. **The gate that had not run in ten
sessions ran here** — `lab-acceptance · minimax-m3` — and blocked on a **fifth** defect of the
same shape, raised independently by both line-level runs as well:

> *"`strip()` has no exit-status check; a Python wrapper crash, missing module, or decode error
> leaves the per-page `.txt` file empty and the loop continues without flagging the failure"* —
> so the reader *"would see exit 2 and conclude 'this sentence is no longer in its cited page'…
> when in fact nothing was verified for that page."*

Correct, and worse than the first four. `set -uo pipefail` does not catch it (`-e` is absent and
the status was never read). Fixed: `strip` failure or empty output → **exit 3**. Fixtures **L**
(a `python3` on `PATH` that exits 1) and **M** (a page with a non-UTF-8 byte →
`UnicodeDecodeError`) prove it, and both **refuse the pre-fix script**:

```
case L   OLD exit 2, found=0 absent=29      (fix expects exit 3)
case M   OLD exit 2, found=0 absent=29      (fix expects exit 3)
```

**One broken interpreter, or one non-UTF-8 byte anywhere in seven pages, and the old checker
reported ALL TWENTY-NINE quotations as stale documentation** — the entire extract declared
fabricated, at exit 2, in the same format as a real finding. The four earlier defects each
manufactured nine; this one manufactures the whole result. **It is the sharpest instance of this
project's house failure mode found so far**, and it was caught by a gate that has been
unavailable for ten sessions and happened to be reachable on this route.

**After both rounds:** ShellCheck clean, **16 of 16 fixtures** over all four registered exit
codes (`evidence/p08/quote-checker-fixtures-20260928T0410Z-16-cases.txt`), and the live run
reproduces **`found=28 absent=1`, exit 2**, same absent sentence
(`evidence/p08/quote-verification-20260928T0415Z-postfix-round2.txt`). The headline of this stop
is therefore unchanged by five fixes to the instrument that produced it — which is the only
reason it may still be stated.

**Round 3 was not run and the loop is closed at two.** §4a caps at three rounds; round 2
produced one blocking finding, it is fixed, and the acceptance gate is a different model from
the line-level pass, so a third round would be a third detection threshold rather than an
answer. Recorded as: **two rounds, five defects, all fixed, one finding disputed in writing.**

**And the fail-closed behaviour was observed rather than argued.** The first post-fix live run hit a
network timeout on the `home` page and returned **exit 3** with `FETCH FAILED`, recorded at
`evidence/p08/quote-verification-20260928T0000Z-fetch-timeout-exit3.txt`. A checker that cannot
reach a page says so instead of reporting drift.

## Commit

**These are the scaffold's deliverables for Labs 8.1–8.4, all four DEFERRED — not files this
stop produced.** The §4a review flagged the ambiguity in 2 of 2 runs and it was real: the
workbook says *"no experiment file"* while this block names one. **What stop 23 actually
committed:** this workbook, two `SOURCES.md` rows, `evidence/p08/verify-quotes.sh`,
`evidence/p08/verify-quote-checker.sh` and the boundary-1/boundary-2 output captures under
`evidence/p08/`. Nothing under `.github/workflows/`, no experiment and no threat-model file
exists, and §6 forbids creating them for a deferred lab. *(Clarified 2026-09-27.)*

```
.github/workflows/<workflow>.md
experiments/B8-agentic-workflows.md
security/unattended-agent-threat-model.md
```
