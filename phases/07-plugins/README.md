# Phase 7 — Plugins + controlled distribution

**Guardrail layer: L2 for the managed-settings keys — with two genuine L1 refusals and a
large L3 remainder** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
**Status:** ✅ **Extract only, labs deferred by the autonomous run** (stop 22, 2026-09-27) ·
**Depends on:** Phases 3, 4, 5

> **Scope of this closure.** The spine's stop 22 is *"Phases 7 and 8 (◇): extract only"*
> ([`LEARNING-PATH.md`](../../LEARNING-PATH.md) line 102), and §4 of the run prompt makes a
> Track A stop the loop **minus steps 3–10** unless the lab runs the benchmark. This one does
> not. **`n = 0` runs. No experiment file, no registered prediction, no benchmark run, no
> overlay, no dollar spent on the agent under test.** Nothing below is a claim about the agent
> under test; every claim is a claim about what ten documentation pages said on 2026-09-27,
> quoted so a stranger can check it against the page.
>
> Labs 7.1, 7.2 and 7.3 are **deferred, not abandoned** — each is marked below with what it
> still owes. Stop 7 is the precedent and its lesson is carried deliberately: it closed at
> `n = 0` and **that was not a shortfall**, because the spine registers a ◇ stop as required
> reading and extract only.
>
> Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-27

## Goal

Package only primitives the team already understands.

> **Do not use plugins to hide complexity from beginners.** A plugin that installs an
> abstraction nobody on the team can debug has moved the problem, not solved it.

**This phase has live stakes for the first time, and stop 21 is why.** B10 closed the second
runtime adapter: the customization overlay now exists in two forms, a `CLAUDE.md`-shaped one
for the claude runtime and an `AGENTS.md`-shaped one for codex
([`build/customizations/agent-v1.2-knowledge`](../../build/customizations/) and `-codex`).
Phase 7 is the first stop that asks how *either* of them would reach a second machine. So the
question this extract must answer is not "what is a plugin" in the abstract; it is **whether a
plugin is a delivery mechanism this project could use without losing the per-run delivery
proof every B step depends on.** The answer is in the exit gate and it is a qualified yes on
claude and a no on codex.

## Layer labels — §4 step 2, applied in order

The workspace rule, applied in order and stopping at the first yes, to every artifact stop 22
produced. **For an extract there is usually nothing above L3, and saying that plainly is the
correct answer rather than a gap.**

| Artifact produced at stop 22 | Layer | Applying the rule in order |
|---|---|---|
| This workbook — the extracts and the four exit-gate answers | **L3** | (1) Can a wrong claim still be written here after the fix? Yes — nothing prevents it. (2) Does anything execute and reject it? No. → L3. Words a reader checks against a quoted page |
| The seven new [`SOURCES.md`](../../SOURCES.md) rows | **L2 for "the URL resolves", L3 for everything the row says about the page** | (1) A dead URL can still be written down. (2) **Yes — `check-links.sh` executes, fails closed on a broken link, and is a CI job.** → L2, for that one property only. The prose in the row is L3 |
| The `DEFERRED` markers on Labs 7.1–7.3 | **L3** | Nothing executes that stops a later session running a deferred lab without paying its debts. A marker is words a reader chooses to honour |
| The ✅ → ↪️ re-status | **L2 to detect, L3 to fix** | The checker found it and will find it again on any re-run; **nothing refuses a stale ✅ in the file**, so the correction itself is hand-maintained |
| The three-vendor comparison table | **L3** | A table of quotes. Its blanks say *not stated on the pages read*, which is not the same as absent, and no instrument closes that gap |

**The step's trap: `build/README.md` registers none for this stop, and that is a fact about the
spine, not an omission.** `build/README.md` is the Track B index; stop 22 is a ◇ Track A stop
with **no B counterpart** (`LEARNING-PATH.md` line 102), so it has no build, no gate and no trap
row there — `grep -i 'plugin\|distribut\|supply' build/README.md` returns nothing. The trap
this phase does carry is the scaffold's own, written in its Goal and kept verbatim: *"Do not use
plugins to hide complexity from beginners."* **No layer converts it.** It is an instruction to a
human author about what to package, there is no artifact for a check to run against, and the
only thing this stop can do about it is refuse to build a plugin — which it did, for the
independent reason that §6 forbids a future step's artifacts.

**And the phase header's own label is a mixture, so it is written as one.** *L2 for the
managed-settings keys* — they execute on a machine that receives them, before download and again
at session start, and *"Users can't override them."* *Two genuine L1 refusals* — the `sha256`
archive digest and the `claude-community` commit pin, where the vendor's word is *refuses*.
*A large L3 remainder* — the trust warning, the review checklist, marketplace tier naming, five
of the seven Bank controls, and every control codex documents. **Naming one layer for the phase
would have been a label on the strongest part of it**, which is the specific error
[`GUARDRAILS.md`](../../GUARDRAILS.md) exists to prevent.

## Verified reading

**Ten pages, all read fresh 2026-09-27 by the autonomous run.** The scaffold listed five
items; three of them ("Claude Code — Plugins", "Copilot — About plugins", "Codex plugin
capabilities") have each split into a family of pages since it was written, and the sub-pages
are where every enforceable control lives. All ten are in
[`SOURCES.md`](../../SOURCES.md) under *Plugins & distribution*.

- [x] ✅ [Claude Code — Plugins overview](https://code.claude.com/docs/en/plugins)
- [x] ✅ [Claude Code — Plugin security and trust](https://code.claude.com/docs/en/plugins/security)
- [x] ✅ [Claude Code — Manage plugins for your organization](https://code.claude.com/docs/en/plugins/org)
- [x] ✅ [Claude Code — Install and manage plugins](https://code.claude.com/docs/en/plugins/install)
- [x] ✅ [Codex — Plugins](https://learn.chatgpt.com/docs/plugins)
- [x] ✅ [Codex — Plugin management (enterprise)](https://learn.chatgpt.com/docs/enterprise/plugin-management)
- [x] ✅ [Codex — Build skills](https://learn.chatgpt.com/docs/build-skills) — the redirect target of the old `developers.openai.com/codex/skills`
- [x] ✅ [Copilot — About plugins](https://docs.github.com/en/copilot/concepts/agents/about-plugins)
- [x] ↪️ [Copilot — Enterprise plugin standards](https://docs.github.com/en/copilot/concepts/agents/about-enterprise-plugin-standards) → `…/concepts/enterprise/plugin-standards`
- [x] ✅ [Copilot — Enterprise managed settings](https://docs.github.com/en/copilot/reference/enterprise-administrators/enterprise-managed-settings)

`./tools/check-links.sh`, run 2026-09-27T18:0xZ after these rows were added:
**`ok=71 moved=11 blocked=2 unverified=0 broken=0`, exit 0.** Nothing broken, nothing
unverified.

> **One of those eleven redirects is this phase's own source, and finding it corrected a ✅ to
> a ↪️.** `concepts/agents/about-enterprise-plugin-standards` now redirects to
> `concepts/enterprise/plugin-standards` — the page moved **out of `agents/` and into
> `enterprise/`**, a scope rename, not a slug tidy. The reason it was not caught by the
> reading is the more useful half: **`WebFetch` follows a redirect silently and hands back the
> content as though the URL resolved.** A subagent sent to read that page reported "Resolved
> directly"; `check-links.sh`, which uses `curl` and reports the hop, reported MOVED. **A ✅
> from a fetch is not a ✅. The checker is the thing that executes** — the same distinction
> this project's guardrail model is built on, arriving this time in the reading list.

## Extract — what a Claude Code plugin *is*

Read 2026-09-27 from the [overview](https://code.claude.com/docs/en/plugins).

**The definition, verbatim:** *"A Claude Code plugin is a directory of skills, agents, hooks,
MCP servers, or other components that Claude Code installs and loads as one unit."*

**The manifest is optional, and the path has moved.** *"A plugin is a directory of components,
usually with a manifest. The manifest, a JSON file at `.claude-plugin/plugin.json`, gives the
plugin its name and can add a version, a description, and other metadata."* Two things there
matter and both contradict the scaffold, which was written against Copilot's flat
`plugin.json`:

1. The path is `.claude-plugin/plugin.json`, in a dot-directory, not at the root.
2. **"usually"** — a plugin without a manifest is still a plugin. So *"the manifest declares
   the plugin"* is false, and a control that reads the manifest to decide what a plugin
   contains has a case where there is nothing to read.

**The four component types**, each quoted: *"Skills: `SKILL.md` instructions Claude loads when
relevant, and that you can also run as a command"*; *"Agents: subagent definitions Claude can
delegate to"*; *"Hooks: commands Claude Code runs at points in its lifecycle, such as after
every edit"*; *"MCP servers: tool servers Claude Code connects to while the plugin is
enabled"*.

**A marketplace is a catalog, not a store:** *"A marketplace is a repository or directory with
a `.claude-plugin/marketplace.json` file that lists plugins and where to fetch each one. It's a
catalog, not a hosted store."*

**The cost model is the one Phase 2 already extracted, applied to a bundle.** *"An enabled
plugin is part of every session, not only the sessions where you use it."* For each invocable
component *"the name and description are in Claude's context on every turn so that Claude knows
it exists"*, while *"The full text of a skill or agent loads only when it's used."* That is
precisely stop 7's *discriminability, not context* finding, and a plugin multiplies it: N
components cost N descriptions on every turn whether or not any of them fires.

**Three install scopes**, each writing a different settings file: **user** (`~/.claude/settings.json`),
**project** (`.claude/settings.json`, committed), **local** (`.claude/settings.local.json`).
*"the local setting overrides the project setting, and the project setting overrides the user
setting."*

**And one line that decides whether this project could ever use plugins in its harness:** *"A
cloud session, including one in the browser at claude.ai/code, doesn't load the plugins in your
local settings."* The observatory's runner is a local `claude -p`, so this does not bite here —
but it means a plugin is not a portable answer to *"how does the overlay reach the model"*
across surfaces.

## Extract — why installation is a supply-chain event

Read 2026-09-27 from [Plugin security and trust](https://code.claude.com/docs/en/plugins/security).
This page is one sentence long in substance and the sentence is its first:

> *"A Claude Code plugin you install can execute arbitrary code on your machine with your user
> privileges."*

**The four execution paths, quoted:**

- **Hooks:** *"a plugin's hooks run as shell commands at points in Claude Code's lifecycle"* —
  and *"command hooks execute shell commands with your full user permissions."*
- **MCP and LSP servers:** *"A stdio MCP server runs as a process that Claude Code starts on
  your machine. Claude Code also starts the language servers the plugin declares."*
- **`bin/`:** *"Claude Code adds each enabled plugin's `bin/` directory to the `PATH` of the
  Bash tool's shell, so Claude's Bash commands can run any executable there."*
- **Skills, commands, agents:** *"these enter Claude's context as instructions, so they
  influence what Claude does with the tools it already has."*

**The sandbox does not cover it:** *"Claude Code runs hooks and MCP servers outside the
sandbox."* The permission rules and sandbox *"cover the tool calls Claude makes, not the code a
plugin runs by itself."* **This is the sentence that makes installation a supply-chain event
rather than a configuration change**, and it is a distinction this project has paid for
elsewhere: B7's Layer-2 gate executed on 17 of 17 treated runs, and it executed *inside* the
tool-call path. A plugin hook runs outside it.

**What the vendor says it does not verify**, verbatim from the trust warning every plugin shows
whatever its tier:

> *"Make sure you trust a plugin before installing, updating, or using it. Anthropic does not
> control what MCP servers, files, or other software are included in plugins and cannot verify
> that they will work as intended or that they won't change. See each plugin's homepage for
> more information."*

*"or that they won't change"* is the supply-chain clause, and the page names the mechanism:
*"when auto-update is on for the marketplace you installed a plugin from, Claude Code updates
that plugin in the background, so the files you reviewed can change on disk."* **Review is a
point-in-time act against a moving target.**

**Marketplace tier is provenance of the catalog, not of the contents.** *"A marketplace's name
tells you who publishes the catalog, not what each plugin in it does, so review a plugin before
you install it whichever marketplace it comes from."* The one thing the tier *does* enforce is
name-squatting: *"Claude Code accepts the official and community names only for marketplaces
sourced from `github.com/anthropics/` repositories, so a third-party marketplace can't present
itself as an Anthropic one."*

**Two refusals on this page are L1, and they are the only L1 objects in the whole phase.**
Apply the workspace rule in order — *can the bad value still be written down after the fix?*

1. **Archive digest.** *"when a marketplace entry pins an `archive` source to a `sha256` digest
   and the downloaded file's digest doesn't match it, Claude Code refuses the install."* A
   mismatched artefact cannot be installed. **L1.**
2. **Community commit pin.** *"Where the `claude-community` catalog pins a plugin to a commit
   SHA, which it does for nearly every entry, Claude Code refuses to install a different
   commit."* **L1 — but only for that one catalog**, and the page attributes it to the
   catalog's content, not to a general facility.

**The four-step review checklist is L3 and says so by its own admission.** Run
`claude plugin marketplace list` for each marketplace's source; read the **Will install** pane;
read `hooks/hooks.json`, `.mcp.json` and every file in `bin/`; then
`claude --plugin-dir <dir> plugin details <name>` for a `Component inventory`. The reason it
cannot be more than L3 is stated on the page: *"The **Will install** section shows that a hook
exists but not what it runs."* **A control that shows you a hook exists without showing you its
command is an inventory, not a review** — and this repository has a name for that shape.

**Uninstall is not deletion.** *"the plugin's files stay on disk under `~/.claude/plugins/cache/`
for 14 days before a background sweep removes them."* Cache layout:
`~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`.

**Telemetry redacts exactly the plugins you would want named.** *"For the community and
third-party tiers, `plugin.name` and `marketplace.name` are the literal string `third-party`
unless you set `OTEL_LOG_TOOL_DETAILS=1`."* An observatory that exports OTel and does not set
that variable **cannot attribute a behaviour change to a third-party plugin at all** — which is
a direct, unmeasured threat to any future B step that delivers its overlay as one.

## Extract — what managed settings actually enforce, and what the page says they cannot

Read 2026-09-27 from
[Manage plugins for your organization](https://code.claude.com/docs/en/plugins/org). **This is
the L2 layer of the phase**, and it is unusually honest: the control matrix ships a *"What it
can't do"* column, and the page ends with a section titled **"Plan for what managed settings
can't enforce"**.

**The two sentences that make it L2 rather than L3:** *"Managed settings let you decide which
plugins Claude Code installs and allows on every machine in your organization. Users can't
override them."* And *"Most controls on this page take effect only from managed settings"* — so
the same key in a user or project file is not the control.

**Enforcement timing is stated, and it is twice:** *"Both lists apply before anything downloads
and again at session start"* — *"so an installed plugin whose marketplace source no longer
matches doesn't load."* A policy change therefore reaches already-installed plugins, which is
the property an allowlist needs to be worth anything.

**The keys, with the limit the page itself attaches to each:**

| Key | What it enforces (quoted) | What the page says it can't do (quoted) |
|---|---|---|
| `strictKnownMarketplaces` (alias `allowedMarketplaces`) | *"Allowlist of marketplace sources. `[]` blocks every source, including the official marketplace."* | *"Doesn't register a marketplace, restrict entries inside an allowed marketplace, or block `--plugin-dir`"* |
| `blockedMarketplaces` | *"Blocklist of marketplace sources, checked before the allowlist"* | *"Doesn't block a marketplace already registered from a source it doesn't match"* |
| `enabledPlugins` | *"`true` force-enables, `false` blocks at every scope and hides the plugin"* | *"Doesn't install a plugin whose marketplace isn't registered or allowed"* |
| `disableSideloadFlags` | *"Rejects `--plugin-dir`, `--plugin-url`, `--agents`, the Agent SDK `plugins` option, and non-SDK `--mcp-config` at startup"*, and rejects `CLAUDE_CODE_PLUGIN_DIRS` folders the same way | *"Doesn't restrict `.mcp.json`, `claude mcp add`, or SDK-provided servers"* |
| `strictPluginOnlyCustomization` | *"Blocks skills, agents, hooks, and MCP servers that don't come from a plugin, managed settings, or Claude Code's built-ins"* | *"Doesn't restrict which plugins users install"* |
| `allowManagedHooksOnly` | *"Restricts which hooks run"* | *"Doesn't trust hooks from plugins users enable themselves"* |
| `disableCommandPluginSources` | *"Blocks plugins with a `command` source from installing, updating, or loading"* | *"Doesn't affect other source types"* |
| `syncClaudeAiPlugins` | *"Set `false` to stop Claude Code downloading and loading the plugins synced from claude.ai"* | *"Doesn't turn off one synced plugin"* |
| `pluginTrustMessage` | *"Appends your text to the trust warning"* | *"Doesn't change the warning's own text"* — **L3 by construction: it edits a sentence** |

**`disableSideloadFlags` is the row this project would care about most, and it cuts both ways.**
`--plugin-dir` is exactly how a plugin author loads a candidate overlay for one session without
installing it; the doc recommends it for that (*"If you're a plugin author testing a copy of
your plugin on disk, start Claude Code from your shell with `--plugin-dir`"*). So the same key
that stops a developer sideloading an unreviewed bundle would stop this repository's own
delivery route. **It is a knob with a measurable cost to the harness, and that cost is not
hypothetical: the observatory's runner installs overlays by path.**

**Five limits that are the honest reasons this is not L1:**

1. **The allowlist is a source list, not a content list.** *"Both lists match the source of the
   marketplace a plugin comes from, not the plugin's own entry inside that marketplace."*
2. **Allowlist matching is brittle where blocklist matching is not.** For the allowlist, *"A
   trailing slash, a `.git` suffix, or `ssh://` in place of `https://` is a different value"*,
   and the page's own advice is *"When a marketplace can be cloned by more than one URL, prefer
   a `hostPattern` entry."* The blocklist, by contrast, canonicalizes: *"Git URLs are
   canonicalized, so the `git@` and `https://` forms, `.git` suffixes, and trailing slashes of
   one `github.com` repository all match the same entry."* **A deny-list that normalizes and an
   allow-list that does not is a control whose failure direction is permissive.**
3. **A lockdown has an uncovered channel.** *"An empty allowlist, `[]`, locks every marketplace
   source out"* — and immediately: *"This lockdown doesn't cover the plugins synced from
   claude.ai, which Claude Code downloads from each user's account rather than from a
   marketplace."*
4. **Collateral damage that looks like a bug.** *"If you set any allowlist without a
   `{ "source": "skills-dir" }` entry, they stop loading"* — *they* being every plugin a user
   keeps under `~/.claude/skills/` with a `.claude-plugin/plugin.json`. Plain skills keep
   loading. So the same key silently reclassifies part of a user's `skills/` directory.
5. **Client version floors on five separate behaviours**: the key aliases need *"Claude Code
   v2.1.232 or later, and older clients ignore them"*; `github` owner wildcards v2.1.223+;
   `syncClaudeAiPlugins` and claude.ai host matching v2.1.273+; `blockedMarketplaces` URL
   entries v2.1.232+. **"Older clients ignore them" is the sentence that decides the layer**:
   a policy silently ignored by an out-of-date client is L3 on that machine, and nothing in the
   policy tells you which machines those are. This is the same shape as stop 18's MCP
   private-registry finding, recorded in [`SOURCES.md`](../../SOURCES.md) line 123 — *"can be
   bypassed by editing configuration files"* — and it is now the second vendor control in this
   curriculum whose enforcement is conditional on a client version nobody audits.

**And the page's own list of what it cannot do at all**, from *"Plan for what managed settings
can't enforce"*: per-user or per-group targeting (*"every plugin key applies to every user who
receives the settings"*); restricting entries inside an allowed marketplace; **hiding `/plugin`
— *"no key disables the command"***; gating `--plugin-dir` through the allowlist.

**One sentence on that page is an instrument this project already owns.** For CI, *"run
`claude -p` with `--output-format stream-json --verbose`. The `init` event lists the loaded
plugins under `plugins`."* **The `init` read-back is exactly the probe author decision 8 made
mandatory** before any B step registers an allowlist, and E-005 is the reason: the runtime
rewrote a `tools:` list before the model saw it, so a file is not the treatment until the `init`
record says so. **Plugin delivery is therefore observable per-run by the mechanism this
repository is already using**, which is the single most useful thing in the extract for any
later step.

> **And the invocation matches exactly, which is checkable without spending anything.**
> `agent-observatory/runner/run-agent.sh:883-885` runs
> `claude "${CLAUDE_ARGS[@]}" --output-format stream-json --verbose -p "$(cat "$BENCH_DIR/task.md")"`.
> That is the same `claude -p --output-format stream-json --verbose` form the org page names, so
> the `init` record every run already emits is the record that would carry `plugins`. **What is
> checked here is the invocation, not the field**: nobody has loaded a plugin under this harness,
> so whether `plugins` is present, populated and granular enough to serve as a delivery proof is
> **unmeasured**. Lab 7.1 owns that probe, it costs one run with `--plugin-dir` and no benchmark,
> and §6 forbids building it at this stop. Naming an observable is not measuring it.

## Extract — versioning and rollback, and the gap

Read 2026-09-27 from [Install and manage plugins](https://code.claude.com/docs/en/plugins/install).

**There is no plugin-version selector and no rollback command.** Stated as what the page
contains: install is `claude plugin install <name>@<marketplace>` with `--scope`, `--yes` and
`--marketplace`; update is `claude plugin update <plugin>@<marketplace>`; there is no
`@version` suffix, no `--version` flag, and no downgrade or rollback verb anywhere on the page.
`version` exists in the manifest and in `claude plugin list`'s `Version` line — **it is
reported, not selected.**

**What can be pinned is the catalog, one level up.** *"Add `#ref` to pin a branch or tag"* on a
GitHub or git marketplace source — e.g. `/plugin marketplace add your-org/plugins#v1.2.0`. So
**the unit of version control is the marketplace, not the plugin**, and pinning it pins every
plugin in it together. The org page turns that into the release-channel pattern: *"host two
marketplaces that point at different refs of the same plugins"* and give each group one.

**Rollback is therefore a reconstruction, not an operation:** re-add the marketplace at an
older `#ref` and reinstall, or uninstall within the 14-day window while
`~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` still holds the previous tree. The
loading reference calls that window *cleanup of previous versions*; the page gives no command
that selects from it.

**Auto-update defaults matter because of the direction of the failure.** *"On by default:
`claude-plugins-official` and the other official marketplace names except
`knowledge-work-plugins` and `first-party-plugins`, plus marketplaces added from claude.ai."*
*"Off by default: every other marketplace"* — including community, third-party and local
development marketplaces. So **the plugins that update themselves without asking are the
first-party ones**, and a security review that assumes the opposite has it backwards.

**The in-session guarantee is real and narrow:** *"The running session keeps the versions it
already loaded."* An update mid-session does not change the running agent; it changes the next
one. For a benchmark harness that is the property you want — **and it is also the property that
makes a per-run content hash mandatory**, because two runs of one batch can straddle an update
and nothing in the run record would say so unless the hash is taken.

Fleet-wide off switches, for completeness: `"autoUpdate": false` on a managed
`extraKnownMarketplaces` entry (*"Claude Code refuses the user's `/plugin` toggle"* when the
managed entry sets it), `DISABLE_AUTOUPDATER` in the managed `env` block — which *"doesn't
cover plugins with a `command` source"* — and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`.

## Extract — Codex plugins: the second runtime, and what does not port

Read 2026-09-27 from [Codex — Plugins](https://learn.chatgpt.com/docs/plugins),
[Build skills](https://learn.chatgpt.com/docs/build-skills) and
[Plugin management](https://learn.chatgpt.com/docs/enterprise/plugin-management).

**Codex has plugins. The scaffold's open question is answered, and answered against its
assumption.** *"Plugins bundle capabilities into reusable workflows in ChatGPT and Codex. They
can include skills and MCP servers."* Fuller, from the skills page: *"Plugins can include one
or more skills. They can also optionally bundle registered MCP server connections, bundled MCP
server configuration, and presentation assets in a single package."* The plugins page adds
browser extensions and hooks to that list.

**Subagents are not a plugin component, and that is the finding with teeth.**
[`SOURCES.md`](../../SOURCES.md) line 108 records what stop 21 was built on: codex subagents
are TOML under `.codex/agents/`, with *"no `tools` field at all"*. The plugins page's component
list does not include them. **So on codex a plugin can carry the skill layer and the MCP layer
of an overlay but not the agent layer** — which is exactly the layer B4, 4B and B8a are about.
A codex plugin is a partial delivery mechanism for this project's overlay, and any step that
used one would have to prove the agent files arrived by some other means.

**Skill discovery paths:** `$CWD/.agents/skills`, `$REPO_ROOT/.agents/skills`,
`$HOME/.agents/skills`, and `/etc/codex/skills` as admin-scoped defaults. **Disabling is a
config entry, not a policy:** `[[skills.config]]` in `~/.codex/config.toml` with
`enabled = false` — *"disable a skill without deleting it"*. A user-writable file that disables
a skill is **L3 against a user and L2 only against the model**.

**Enterprise control is a console policy, and it is thinner than Claude Code's.** Admin >
Plugins carries an **Installation policy** per plugin with values `Available` or `Installed`,
for eligible roles. A marketplace is *"a JSON catalog that lists the plugins to import"* from
GitHub, which *"Workspace admins can import … and keep its plugins up to date from the
repository"*. **No allowlist or blocklist of sources is described on the page, and no sentence
says a user cannot override the policy.** Both of those are absences, and an absence is not a
measurement — but the asymmetry against Claude Code's nine keys with an explicit
non-overridability sentence is large enough to record.

**Pinning is better specified than Claude Code's, at the same level.** An admin may
*"optionally enter a **Branch, tag, or commit**"*, and the semantics are stated: *"use a branch
to receive future commits; a fixed commit stays at that revision."* Sync is *"New marketplaces
check for updates daily"*, and there is one graceful-degradation clause — if a synced entry is
invalid, *"its last working version is retained"*. **Still no rollback verb.**

**One hard portability limit:** *"Any imported plugin that declares MCP servers … is marked
**Desktop only** and works only in the ChatGPT desktop app."* The codex arm of this project is
a CLI (`codex-cli 0.154.0`, [`SOURCES.md`](../../SOURCES.md) line 125). **An MCP-carrying codex
plugin therefore cannot reach the runtime this project measures.** That is the single most
consequential line in the codex reading and it is a refusal, not a warning.

**And the trust posture is one sentence of guidance:** *"Review and trust plugin hooks before
they run."* **L3.**

## Extract — Copilot plugin standards, and the shared key names

Read 2026-09-27. Recorded for the curriculum, **not** as a claim about a Copilot-run agent:
Decision G removed that arm and §6 of the run prompt forbids any claim about it. Nothing here
is about behaviour; it is about what three pages define.

**The object:** *"A distributable package that extends Copilot's functionality. A bundle of
components in a single installable unit."* Components: *"Custom agents"*, *"Skills"*,
*"Hooks"*, *"MCP server configurations"*, *"LSP server configurations"*. Manifest: `plugin.json`
— **flat, where Claude Code's is `.claude-plugin/plugin.json`.** The scaffold's line *"A Copilot
plugin bundles agents, skills, hooks, MCP config and LSP config, with `plugin.json` as
manifest"* is confirmed verbatim and is the one thing in the scaffold that has not drifted.

**Install:** *"In Copilot CLI, you can install plugins imperatively using the `copilot plugin
install` command or declaratively by adding the plugin to the `enabledPlugins` field."* Sources:
*"A marketplace, A repository, A local path."* Versioning: *"Because plugins in a marketplace
are versioned, marketplaces make it easy to discover, install, and update plugins"* — and no
pinning, auto-update or rollback mechanism is stated on the page.

**The finding worth carrying is that the enterprise keys have the same names as Claude Code's.**
The managed-settings reference defines `enabledPlugins` (*"Enables or disables specific plugins
by key"*), `extraKnownMarketplaces` (*"Adds plugin marketplaces that users can access"*) and
`strictKnownMarketplaces` (*"Restricts plugin installation to explicitly listed marketplaces"*),
all three delivered through a `managed-settings.json`. **Three key names, one file name, two
vendors.** Two readings, and this stop cannot choose between them: either the shape is
converging on a de facto standard, or one vendor's schema was adopted by the other. Either way,
**a reader who learns one has learned most of the other, and a reader who assumes the semantics
are identical has not been told they are.**

**The one place they demonstrably differ is override, and it took a hand re-derivation to get
right.** Claude Code: *"Users can't override them."* Copilot: *"This key is overridable for
enterprise teams. Wrap the complete allowlist in `overridable` at the enterprise level"*, and
*"Use a regular array in the team file to replace the default allowlist. Omitting the key
retains the enterprise default."*

> **This is an L2 delegation primitive, not a bypass, and the first reading of it was wrong.**
> A subagent sent to read the page returned *"both … are described as 'overridable for
> enterprise teams', indicating teams can customize at their scope level"* — which reads as a
> weakness in the control. Re-derived by hand from the page, the `overridable` wrapper is
> something **the enterprise must opt into per key**; unwrapped, the enterprise value stands and
> a team file cannot replace it. **The difference between "teams can override this" and "the
> enterprise may choose to let a team override this" is the whole layer label**, and §4b of the
> run prompt is why it was checked: re-derive any value that decides a gate.

## Extract — three vendors, one table

Same-day reading, 2026-09-27. Blank means *not stated on the pages read*, which is not the same
as absent.

| | Claude Code | Codex | Copilot |
|---|---|---|---|
| Manifest | `.claude-plugin/plugin.json`, *"usually"* | not stated | `plugin.json` |
| Skills in a plugin | yes | yes | yes |
| Agents/subagents in a plugin | yes | **not listed** | yes (*"Custom agents"*) |
| Hooks in a plugin | yes | yes | yes |
| MCP in a plugin | yes | yes, **but marked *Desktop only*** | yes |
| LSP in a plugin | yes (*"MCP and LSP servers"*) | not stated | yes |
| Marketplace | `.claude-plugin/marketplace.json`, *"a catalog, not a hosted store"* | *"a JSON catalog"* imported from GitHub by an admin | marketplace, repository, or local path |
| Pin a **plugin** version | **no selector on the page** | **no** | not stated |
| Pin the **catalog** | `#ref` branch/tag | *"Branch, tag, or commit"* | not stated |
| Rollback verb | **none** | **none**; *"its last working version is retained"* on a bad sync | not stated |
| Auto-update default | **on** for official names (two exceptions), off elsewhere | *"check for updates daily"* | not stated |
| Integrity refusal | **`sha256` archive pin; community commit-SHA pin** | not stated | not stated |
| Source allowlist | `strictKnownMarketplaces`, before download **and** at session start | **not described** | `strictKnownMarketplaces` |
| Non-overridable by user | *"Users can't override them."* | **not stated** | only when **not** wrapped in `overridable` |
| Sideload block | `disableSideloadFlags` | not stated | not stated |
| Stated trust posture | a warning naming what the vendor *"cannot verify"* | *"Review and trust plugin hooks before they run."* | not stated |

## Lab 7.1 — Package existing tested components · **DEFERRED**

Package the reviewer agent, the testing skill, the audit hook. **Nothing new during
packaging.** Otherwise a failure is unattributable:

```
feature bug?   plugin packaging bug?   installation bug?   policy bug?
```

**What it owes before it may run.** A registered prediction, an arm, and — new from this
extract — **a per-run delivery proof for a plugin**, which this repository does not have.
`customization.agentHash` hashes one agent file and `skills_hash` hashes the set of `SKILL.md`s
(author decision 11 item 9, and obs#88's `agentsHash` instrument merged at stop 17a). **None of
them hashes a plugin**, so a plugin-delivered overlay would be delivered by a route no hash
sees — the precise defect decision 11 item 9 was written to avoid. The candidate observable is
the `init` event's `plugins` list, named above. **Naming it is not measuring it**, and nothing
at this stop tried.

## Lab 7.2 — Clean-machine reproducibility · **DEFERRED**

On a disposable environment: clone the sample repo, install the approved plugin, verify
versions, run the benchmark, compare with the manually installed configuration.

> Distribution must not change measured behavior beyond known packaging differences.

**What it owes.** Benchmark runs in both configurations, therefore a prediction and a budget.
**And this extract adds a confound it must design around:** *"the files you reviewed can change
on disk"* under auto-update, which is **on by default for the official marketplace**. A
clean-machine comparison whose treated arm auto-updates mid-batch has moved a registered
variable without recording it. The mitigations exist and are named — `"autoUpdate": false`,
`DISABLE_AUTOUPDATER`, a `#ref`-pinned marketplace, a per-run content hash — and **none of them
is in this repository's runner today.**

## Lab 7.3 — Upgrade test · **DEFERRED**

Plugin v1 → v2, changing one skill behavior. Verify install, version visibility, rollback,
compatibility, eval result.

**What it owes, and one clause it cannot satisfy as written.** *Verify … rollback* assumes a
rollback operation. On the pages read, **there is none on any of the three runtimes.** So the
lab must either re-scope to *reconstruct the previous version from a pinned catalog ref* — which
is testable — or record that the clause is unsatisfiable and say why. Rewriting the clause
quietly would be the failure this project names as the house one: a control reporting success
over a scope smaller than it claims.

## Bank controls

Internal approved marketplace · CODEOWNERS · signed/reviewed releases where feasible ·
pinned versions · provenance · dependency scanning · **no silent auto-update into
production teams without promotion checks**.

**Layer-labelled against the reading, applying the workspace rule in order and stopping at the
first yes.** The list was written before any of these pages; five of its seven items turn out
to be L3 on the evidence, and saying so is the point of labelling it.

| Bank control | Layer, on the pages read 2026-09-27 | Why |
|---|---|---|
| Internal approved marketplace | **L2** | `strictKnownMarketplaces` executes before download and at session start, and *"Users can't override them"* — but it is a source list, and older clients *"ignore"* the aliases |
| CODEOWNERS | **L2**, and **outside every runtime** | A GitHub branch-protection control on the marketplace repository. It governs the catalog, not the install; none of the three runtimes reads it |
| Signed / reviewed releases | **L1 in exactly one case, otherwise L3** | L1 where an `archive` source carries a `sha256` the download must match, and for the `claude-community` commit pin. Everywhere else, *"Anthropic … cannot verify"* — and *reviewed* is the four-step checklist, which cannot show what a hook runs |
| Pinned versions | **L3 at the plugin level, L2 at the catalog level** | No plugin-version selector exists. `#ref` on a marketplace executes; a plugin version is reported and not chosen |
| Provenance | **L3** | Tier naming *"tells you who publishes the catalog, not what each plugin in it does"*. And the telemetry that would carry provenance redacts third-party names to the literal string `third-party` without `OTEL_LOG_TOOL_DETAILS=1` |
| Dependency scanning | **L3 — no instrument exists in any of these repos** | Nothing in this project scans a plugin tree. A dependency *resolver* exists (`claude plugin prune`, declared dependencies) — resolving is not scanning, and conflating them would be an L2 label on an L3 object |
| No silent auto-update into production | **L2 and available, but off by default in the wrong direction** | `"autoUpdate": false` in managed settings executes and *"Claude Code refuses the user's `/plugin` toggle"*. Until it is set, auto-update is **on** for the official marketplace names |

## Exit gate

All four answered from the ten readings above, 2026-09-27. **No run was needed for any of
them**; each is a question about what these objects are and what the vendors say they enforce.
Nothing below is stated as a property of the agent under test.

- [x] **Plugin vs skill.** A plugin is not a bigger skill; it is a *unit of installation and
  lifecycle*. The vendor states the components need no plugin at all: *"Skills, subagents,
  hooks, and MCP servers all work on their own, without a plugin."* The reason to bundle is
  given as three practical ones — *"Use a plugin when you want several skills, subagents,
  hooks, or MCP servers packaged as one unit"*, to *"get a setup someone else built, with one
  command and updates from its marketplace"*, and to *"publish versioned releases"*. **So the
  axis is distribution and update, not capability.** Three consequences follow, and they are
  what makes the distinction load-bearing rather than definitional:
  1. **A skill's blast radius is context; a plugin's is your machine.** A `SKILL.md` *"enters
     Claude's context as instructions"*. A plugin can also carry a hook that *"execute[s] shell
     commands with your full user permissions"*, outside the sandbox, and a `bin/` directory
     added to the Bash tool's `PATH`. **Installing a skill and installing a plugin are not the
     same class of act**, and this is the single most important sentence in the phase.
  2. **A plugin has an owner who can change it after you agreed to it.** Auto-update means
     *"the files you reviewed can change on disk"*. A skill you wrote does not change unless you
     change it.
  3. **The cost is paid the same way but N times.** Stop 7 established that the *listing* is
     always-on while the body is lazy; a plugin pays that per component, on every turn, in
     every session, whether or not anything fires.
  **For this project specifically:** a skill is what B6 measured and it is what the overlay is
  made of. A plugin would be a *fourth* delivery mechanism beside `CLAUDE.md`, `.claude/agents/`
  and `SKILL.md` — and it is the only one of the four with no content hash in the run record.
- [x] **Why installation is a supply-chain event.** Because the vendor says the install grants
  arbitrary local code execution, and says it cannot verify what it grants it to:
  *"A Claude Code plugin you install can execute arbitrary code on your machine with your user
  privileges"*, and *"Anthropic does not control what MCP servers, files, or other software are
  included in plugins and cannot verify that they will work as intended or that they won't
  change."* Four properties of a supply chain are each present and each quoted above: **code
  execution** outside the sandbox (hooks, stdio MCP, LSP, `bin/` on `PATH`); **a third-party
  author**; **mutation after review**, by background auto-update that is *on by default for
  first-party marketplaces*; and **weak provenance**, since tier naming describes the catalog's
  publisher and not the plugin's contents. The right comparison is not "installing a config
  file" but "adding a dependency" — with one difference that makes it worse: *a dependency you
  add is pinned by a lockfile, and a plugin has no version selector to pin.* The two L1
  refusals — `sha256` archive digest, community commit SHA — are the only mechanisms on these
  pages that behave like a lockfile, and neither is general.
- [x] **Versioning and rollback.** **Versioning is real at the catalog level and reporting-only
  at the plugin level; rollback does not exist as an operation on any of the three runtimes.**
  A plugin's `version` lives in `.claude-plugin/plugin.json`, appears in `claude plugin list`
  and keys the cache directory — and nothing selects it. There is no `plugin@version`, no
  `--version`, no downgrade verb. What *is* pinnable is the marketplace, with `#ref` to a branch
  or tag; codex pins the same layer and states the semantics more sharply (*"use a branch to
  receive future commits; a fixed commit stays at that revision"*). The supported way to run two
  versions is therefore **two catalogs**: *"host two marketplaces that point at different refs
  of the same plugins."* Rollback is reconstructed, not commanded — re-point the catalog and
  reinstall, or reach into `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` inside
  the 14-day sweep window. **Teach this as the asymmetry it is:** rolling *forward* is one
  command and happens by itself; rolling *back* is a manual reconstruction with a two-week
  expiry. A promotion gate that assumes a rollback button — and B13 clause 7 is *"rollback is
  defined"* — must define it as the reconstruction, or it is checking a box against a mechanism
  that is not there.
- [x] **Centralized enterprise restrictions.** They exist, they execute, and the vendor
  documents their limits better than this curriculum usually gets. Claude Code: nine managed
  keys, delivered by server-managed settings, MDM, or `managed-settings.json`; *"Users can't
  override them"*; the allowlist and blocklist apply *"before anything downloads and again at
  session start"*; `[]` is total lockdown; `disableSideloadFlags` rejects `--plugin-dir`,
  `--plugin-url`, `--agents` and `CLAUDE_CODE_PLUGIN_DIRS` at startup;
  `strictPluginOnlyCustomization` blocks non-plugin skills, agents, hooks and MCP servers.
  **That is L2, and it is the strongest L2 in the curriculum so far.** What keeps it off L1 is
  five things, all stated by the vendor: the allowlist matches *sources* and not entries;
  allowlist matching does not canonicalize URLs where the blocklist does, so it fails
  *permissively*; an `[]` lockdown *"doesn't cover the plugins synced from claude.ai"*; five
  behaviours carry client version floors and *"older clients ignore them"*; and there is no key
  that hides `/plugin` — *"no key disables the command."* Copilot names the same three keys in
  the same `managed-settings.json`, adding an explicit `overridable` wrapper the enterprise must
  opt into per key. Codex is the outlier and the one this project actually runs: **a per-plugin
  `Available`/`Installed` console policy, an admin-imported GitHub catalog, no source allowlist
  described, and no sentence saying a user cannot override it.** The teaching point is the
  ordering: **the runtime this project added at stop 21 has the weakest documented distribution
  control of the three**, and a curriculum that taught "enterprise restrictions exist" from the
  Claude Code page alone would have taught something false about the other runtime in the same
  experiment.
- [x] **And the gate's own question — was this the agent, or the harness?** **Neither, and that
  is the honest answer for a ◇ stop.** `n = 0` runs, no arm, no overlay, no scoring. Every
  claim here is about documentation. The one thing this stop measured is a property of *the
  reading apparatus*, not of the agent or the harness: `WebFetch` follows redirects silently, so
  a fetched page can be reported as resolving at a URL that no longer serves it, and only
  `check-links.sh` sees the hop.

## Learning

```yaml
learning:
  what_was_added: >
    No artifact that runs. Stop 22 is a ◇ Track A reading stop: an extract of ten
    documentation pages (the scaffold named five; three had split into families), the four
    exit-gate answers, a three-vendor comparison table, a layer label on each of the seven
    Bank controls, deferral markers on the three labs with what each still owes, seven new
    SOURCES.md rows, and one ✅ re-status'd to ↪️ by the link checker.
  why_it_exists: >
    To answer, before anything is built, whether a plugin is a delivery mechanism this
    project could use. Stop 21 left the overlay existing in two runtime-specific forms and
    no way to ship either; Phase 7 is the stop that asks how they would reach a second
    machine. The answer is a qualified yes on claude and a no on codex, and the reason is
    quoted rather than reasoned.
  observed_effect: >
    n = 0 runs, so no effect on the agent under test and no number. The effect on the plan
    is three corrected premises. (1) Codex has plugins — the scaffold's open question is
    answered against its own assumption — but subagents are not a plugin component and an
    MCP-carrying codex plugin is marked Desktop only, so it cannot reach the CLI this
    project measures. (2) There is no plugin-version selector and no rollback verb on any of
    the three runtimes, which makes B13 clause 7 ("rollback is defined") a clause that must
    define a reconstruction rather than tick a box. (3) A plugin-delivered overlay would be
    delivered by a route no hash in the run record sees, which is the exact defect author
    decision 11 item 9 was written to prevent — and the candidate observable is the init
    event's plugins list, the same probe author decision 8 already mandates.
  unexpected_effect: >
    WebFetch follows a redirect silently and hands back the content as though the URL
    resolved. A subagent reported Copilot's enterprise-plugin-standards page as resolving
    directly; check-links.sh, which uses curl and reports the hop, reported MOVED — the page
    left concepts/agents/ for concepts/enterprise/, a scope rename. So a ✅ produced by a
    fetch is not a ✅, and this project's reading list has been partly maintained by the
    weaker of the two instruments it owns. Fixed at L3 only for now: the row is re-status'd
    and the reason is written into it. The L2 version — a check that refuses a ✅ in
    SOURCES.md whose URL check-links.sh reports as MOVED — is not built, because §6 forbids
    a future step's artifacts and this is not stop 22's deliverable. It is on record.
    Second, smaller: the subagent's reading of Copilot's `overridable` wrapper inverted its
    meaning, from "the enterprise may delegate this key" to "teams can override it". That
    one decided a layer label, §4b says re-derive anything that decides a gate, and the
    hand re-derivation changed the answer.
  keep_or_remove: >
    Keep the extract. Keep the three deferral markers with their debts written down rather
    than deleting the labs — a deferred lab with its debts recorded is evidence, a deleted
    one is a gap that looks like a decision. Nothing is removed, because stop 22 built
    nothing that could have had no effect. The scaffold's Bank-controls list is kept
    verbatim and annotated rather than rewritten: five of its seven items are L3 on this
    evidence, and the annotation is the finding.
  next_question: >
    Does the init event's `plugins` list actually appear under this harness, and does it name
    a plugin's components well enough to serve as a per-run delivery proof? That is a free
    check — one `claude -p --output-format stream-json --verbose` run with one trivial
    plugin loaded by --plugin-dir — and it is the question that decides whether a plugin can
    ever be a treatment here. It needs no benchmark run, no rubric and no prediction about
    quality, so it is the cheapest useful thing in this phase and it is deliberately not
    done at stop 22: a probe is a lab, Lab 7.1 owns it, and §6 forbids building it early.
```

## Commit

**Not produced at stop 22.** Both artifacts belong to the deferred labs:

```
distribution/ · distribution/plugin-release-process.md   # Labs 7.1–7.3, deferred
experiments/B7-distribution.md                           # needs a registered arm; the author's call
```

Per §6 of the run prompt — never create a future step's artifacts early — neither is written.
Note also that the scaffold's `experiments/B7-distribution.md` filename collides with the
spine's **B7 — verification + policies**, which closed at stop 15 as
[`E-016`](../../experiments/); if the lab ever runs, it needs a key that does not read as a B
step it is not.

## Validation

Stop 22 registers no gate of its own; the spine's closing condition for stops 22–23 is
*"extracts written"*. The clauses below are that condition plus this workbook's own exit gate.

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| "Phases 7 and 8 (◇): extract only, as stop 7" — required reading | Ten rows in [`SOURCES.md`](../../SOURCES.md) under *Plugins & distribution*, seven of them added at this stop. `./tools/check-links.sh` run 2026-09-27T18:0xZ: **`ok=71 moved=11 blocked=2 unverified=0 broken=0`, exit 0** | **L2 for "the URLs resolve"; L3 for "they were read."** `check-links.sh` executes, fails closed on a dead link, and is the CI job *verified reading is still verified*. **Nothing executes that checks anyone opened a page**, so the ticked boxes are guidance. The checker did do one thing a reader could not: it re-status'd a ✅ to ↪️ | `cd agent-learning-lab && ./tools/check-links.sh`, read the four counts, then find `about-enterprise-plugin-standards` among the MOVED lines. For the reading half there is no command — check the quotes against the pages by hand |
| …and extract only | Seven `## Extract` sections in this file, one per source family, each dated 2026-09-27 and quoting verbatim | **L3** — nothing executes a check that an extract matches its source. The proof it was *read* is L2 above; the proof it was read *correctly* is that every claim is a quoted sentence, checkable by hand | `grep -c '^## Extract' phases/07-plugins/README.md` returns **7**. Then open each URL and search for the quoted sentence |
| "Mark 'extract only, labs deferred by the autonomous run'" (§3 stop 7's wording, carried) | The status line at the top of this file, and `DEFERRED` on Labs 7.1, 7.2 and 7.3 | **L3** — a marker is words a reader chooses to honour | `grep -c '^## .*DEFERRED' phases/07-plugins/README.md` returns **3**, the three deferred lab headings, and the status line carries the fourth marker. *Anchored to headings on purpose: stop 7's table cited a bare `grep -c DEFERRED` and the §9 validator got a different number, because prose about the marker is itself a match* |
| Exit gate: "Plugin vs skill" | Answered above from *"Skills, subagents, hooks, and MCP servers all work on their own, without a plugin"*, *"Use a plugin when you want several … packaged as one unit"*, and the `bin/`-on-`PATH` and hook-execution sentences of the security page | **L3** — a written answer from documentation | Compare the answer against those sentences on the overview and security pages |
| Exit gate: "Why installation is a supply-chain event" | Answered above from *"can execute arbitrary code on your machine with your user privileges"*, *"cannot verify that they will work as intended or that they won't change"*, and *"Claude Code runs hooks and MCP servers outside the sandbox"* | **L3 for the claim.** The two *mechanisms* cited as L1 — the `sha256` archive-digest refusal and the `claude-community` commit-SHA refusal — are **L1 as the vendor describes them and untested here**: this repository has installed no plugin and observed neither refusal, so their layer is a documented claim, not an observation | Open the security page; find the two refusal bullets under *Untrusted marketplace sources and failed integrity checks* and the trust-warning code block |
| Exit gate: "Versioning and rollback" | Answered above. The negative half — no `@version`, no `--version`, no downgrade verb — is a statement about the **whole** install page and the codex and Copilot pages, which is the weakest kind of evidence in this file and is labelled as such | **L3, and an argument from absence.** Nothing executes; and "the page does not describe X" is refutable by one sentence anyone finds. It is stated as *what these pages contain on 2026-09-27*, never as a property of the tools | Read [Install and manage plugins](https://code.claude.com/docs/en/plugins/install) end to end and search it for `version`. Every hit is either the manifest field, the `Version` line of `claude plugin list`, or the cache path — none is a selector. Then `claude plugin install --help` on an installed CLI, which this stop did **not** run |
| Exit gate: "Centralized enterprise restrictions" | Answered above from the nine-key control matrix with its *"What it can't do"* column, *"Users can't override them"*, *"before anything downloads and again at session start"*, the five client version floors, and *"Plan for what managed settings can't enforce"* | **L3 for the answer; L2 is what the answer *describes*** — and the distinction is the row's point. The keys execute on a machine that receives them. **No machine in this project receives them**: nothing in these three repositories sets a managed setting, so the L2 is the vendor's, observed by nobody here | Open the org page's control matrix and read both columns. To check the L2 claim you would need a managed-settings file on a machine and a blocked install — **not done at this stop** |
| Hand check — one claim re-derived independently of the fetch that produced it | The Copilot `overridable` semantics. A subagent returned *"described as 'overridable for enterprise teams', indicating teams can customize at their scope level"*; re-fetched and re-read by hand, the page says *"This key is overridable for enterprise teams. Wrap the complete allowlist in `overridable` at the enterprise level"* and *"Omitting the key retains the enterprise default"* — an enterprise opt-in, not a team bypass. **The subagent's reading and the hand reading disagree in the direction that would have flattered the control's weakness, and the hand reading is the one recorded** | **L3** for the doc claim. The *process* is the §4b control and it executed: a value that decided a layer label was re-derived before it was written down | Open the managed-settings reference, find the `strictKnownMarketplaces` entry, and read the override sentence and the one after it |

**Independence check.** Nothing changed between arms, because there are no arms. Stop 22
launched no benchmark run, wrote no customization overlay, installed no plugin, and touched no
rubric, evaluator, fixture, policy file or model id. The registered variables are byte-identical
to the ones stop 21 closed under. The branch's `git diff --stat` against `main` touches only
`phases/07-plugins/README.md`, `SOURCES.md`, `TRACK-B-STATE.md`, `HANDOFF.md`, and this stop's
review file — no file under `build/customizations/`, `benchmark/rubrics/` or `evidence/`.

**`n` for every number in this file: `n = 0` runs.** The only counts stated are counts of
documentation pages, SOURCES.md rows, and `check-links.sh` URLs. Nothing above is a property of
the agent under test, and the four measured results quoted from other stops — E-003's `REJECT`,
stop 7's `allowed-tools` reversal, E-005's rewritten `tools:` list, B7's 17-of-17 gate
executions — each carry their own `n` at the experiment that produced them.
