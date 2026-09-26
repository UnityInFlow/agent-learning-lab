# Verified sources

Every URL the curriculum cites, checked with `curl -sSL` on **2026-08-28**. Re-run
[`tools/check-links.sh`](tools/check-links.sh) before each cohort — this list drifts.

**Status legend:** ✅ resolves as written · ↪️ resolves but **redirects** (the URL in
`CURRICULUM.md` is stale) · 🔒 live in a browser, blocks `curl` (403 to bots) ·
🔑 one of the lab's own repos · ⚠️ no HTTP response at all — **not** a 404, and not a pass

## What the check found

**2026-08-28 re-check: the same 76 URLs. `ok=64 moved=8 blocked=2 unverified=0 broken=0`.
The same eight redirects, still the same eight, none of them new — eighteen days and this
file did not drift.** Nothing here needs a new entry.

**What did move is the checker, and it had been wrong in both directions at once.** Neither
error was visible in its output; both were found by re-verifying its verdicts by hand.

- **Two live pages were reported broken.** It sent `-A 'Mozilla/5.0'` — not a browser
  string — and `anthropic.com` and `code.claude.com` answered by dropping the connection
  instead of replying. curl reports `000` for that, `000` fell into the catch-all, and both
  were printed ❌ and counted broken, so the script exited 1. Both return 200 to a real
  browser UA. **If a pre-cohort check ever fails on `anthropic.com`, re-verify by hand
  before believing it.** `000` now retries once and then lands in ⚠️ `unverified`: not ok,
  not broken, non-fatal, and yours to resolve — it is a transport failure, which is not
  evidence that a page is gone.
- **Two URLs were never checked at all.** Every `github.com/UnityInFlow/*` link was skipped
  before it was fetched, because those repos used to be private and a private repo 404s to
  an unauthenticated curl. All three went public; the skip stayed. So they printed 🔑 and
  counted as neither ok nor broken while both answered 200 — a check that never ran, shown
  as though it had. They are fetched like anything else now, and a 404 is what reports 🔑.
  That is where `ok` 62 → 64 comes from; the URL set did not change.

*2026-08-10 re-check: 76 URLs across `SOURCES.md`, `CURRICULUM.md`, `LEARNING-PATH.md`,
`GUARDRAILS.md`, `build/README.md` and all phase READMEs — nothing broken, nothing newly
moved, all eight redirects already marked ↪️. The first pass checked only the first two
files, hence 43 URLs then and 76 since.*

Eight of the 76 links redirect. Two are worth knowing about because the *content* moved,
not just the path:

1. **The Codex docs left `developers.openai.com` entirely.** Everything under
   `/codex/*` now redirects to `learn.chatgpt.com/docs/*`. Any bookmark, AGENTS.md
   reference, or slide deck pointing at the old host is one deprecation away from breaking.
2. **Copilot's "MCP allowlist enforcement" was renamed to "MCP private registry
   enforcement"** and moved under `/reference/enterprise-administrators/`. A rename like
   that usually means the underlying model changed — read it fresh rather than trusting a
   summary written against the old page. This matters directly for Phase 6.

Nothing 404s. The two 🔒 entries are OpenAI engineering articles; `openai.com` returns 403
to non-browser user agents. They load normally in a browser.

---

## Agent loop / mental model

| | Source | What to take from it |
|---|---|---|
| 🔒 | [OpenAI — Unrolling the Codex agent loop](https://openai.com/index/unrolling-the-codex-agent-loop/) | Harness vs model; context assembly; conversation growth; compaction; why tools and permissions are part of the runtime |
| ✅ | [Anthropic — How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works) | gather context → take action → verify; how tools participate in the loop |
| ✅ | [GitHub — Copilot feature matrix](https://docs.github.com/en/copilot/reference/copilot-feature-matrix) | Which surface supports which primitive. **Check this before every lab** — it is the single most common source of "why didn't my file load" |

## Observability

| | Source | What to take from it |
|---|---|---|
| ✅ | [Copilot CLI reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference) | Search the page for **OpenTelemetry monitoring**. `invoke_agent` / `chat` / `execute_tool` spans, token fields, hook lifecycle, compaction events |
| ✅ | [OpenTelemetry — Signals](https://opentelemetry.io/docs/concepts/signals/) | Traces vs metrics vs logs. Do not collapse them |
| ✅ | [OpenTelemetry — Collector](https://opentelemetry.io/docs/collector/) | receiver → processor → exporter |
| ✅ | [OpenTelemetry — GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/) | The vocabulary your normalization layer should target instead of vendor span names |
| ✅ | [Grafana Tempo](https://grafana.com/docs/tempo/latest/) | Trace storage |
| ✅ | [Grafana — Visualize traces](https://grafana.com/docs/tempo/latest/visualize-traces/) | Reading a trace waterfall |
| 🔒 | [OpenAI — Running Codex safely](https://openai.com/index/running-codex-safely/) | Sandboxing, approvals, telemetry posture |

## Instructions

| | Source | What to take from it |
|---|---|---|
| ✅ | [Copilot — Custom instructions support matrix](https://docs.github.com/en/copilot/reference/custom-instructions-support) | **Which file works on which surface.** The authority for Phase 1 |
| ✅ | [Copilot — Customization cheat sheet](https://docs.github.com/en/copilot/reference/customization-cheat-sheet) | One-page map of every customization file |
| ✅ | [Copilot CLI — Add custom instructions](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions) | CLI-specific loading |
| ↪️ | [Codex — AGENTS.md](https://developers.openai.com/codex/agent-configuration/agents-md) → `learn.chatgpt.com/docs/agent-configuration/agents-md` | Hierarchical discovery and precedence — **verify precedence from the live page**, it has changed before |
| ✅ | [Claude Code — Memory & instructions](https://code.claude.com/docs/en/memory) | `CLAUDE.md`, `@AGENTS.md` import, `.claude/rules/`, `paths` frontmatter. **Read the `#agentsmd` anchor** — it is the fact that invalidated our first experiment |

## Prompt files / reusable workflows

| | Source | What to take from it |
|---|---|---|
| ✅ | [VS Code — Prompt files](https://code.visualstudio.com/docs/agent-customization/prompt-files) | Current frontmatter. The old `mode:` field is **not** current |
| ✅ | [Copilot — Response customization](https://docs.github.com/en/copilot/concepts/prompting/response-customization) | How the pieces relate |
| ✅ | [Claude Code — Skills](https://code.claude.com/docs/en/skills) | Custom commands merged into Skills; `.claude/commands/` is legacy-but-working |

## Skills

| | Source | What to take from it |
|---|---|---|
| ✅ | [Copilot — About Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) | Progressive disclosure; `.github/skills/`, `.claude/skills/`, `.agents/skills/`. Note the explicit prompt-injection warning |
| ✅ | [Copilot — Add skills to the cloud agent](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills) | Installation path |
| ✅ | [Claude Code — Skills](https://code.claude.com/docs/en/skills) | Auto-load from description, explicit invocation, supporting files, executable behavior |
| ↪️ | [Codex — Skills](https://developers.openai.com/codex/skills) → `learn.chatgpt.com/docs/build-skills` | Note the page is now "Build skills" — authoring-oriented |

## Agents & permissions

| | Source | What to take from it |
|---|---|---|
| ✅ | [Copilot — Custom agents configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration) | **If `tools` is omitted, the agent gets all tools.** `mcp-servers` is not used by IDE agents. **Extracted 2026-09-04:** `tools` *filters* — allowlist only, no denylist field; `tools: []` disables all, `tools: ["*"]` enables all; `infer` is **retired** for `disable-model-invocation` + `user-invocable` |
| ✅ | [Claude Code — Subagents](https://code.claude.com/docs/en/sub-agents) | Separate context, own system prompt, tool config, model selection, independent permissions. **Re-read 2026-09-04 and the page has MOVED: 4 documented frontmatter fields → 17.** `tools` is an **allowlist that narrows** and `disallowedTools` a denylist — *not* the pre-approving `allowed-tools` of a skill, and camel-cased where the skill field is hyphenated. `hooks`, `mcpServers` and `skills` are per-subagent and are contamination channels. Omitting `model` does **not** inherit the parent's |
| ↪️ | [Codex — Subagents](https://developers.openai.com/codex/agent-configuration/subagents) → `learn.chatgpt.com/docs/agent-configuration/subagents` | Codex **does** have subagents now. Do not teach the old "Codex has no subagents". **Extracted 2026-09-04:** TOML under `.codex/agents/`, required `name` / `description` / `developer_instructions`, and **no `tools` field at all** — capability is restricted by `sandbox_mode`, not by tool name. A `tools:` boundary is therefore **unportable to codex**, which constrains B10 at stop 21 |

## Hooks

| | Source | What to take from it |
|---|---|---|
| ✅ | [Copilot — Hooks reference](https://docs.github.com/en/copilot/reference/hooks-reference) | `.github/hooks/*.json`; `preToolUse` allow/deny; **timeouts fail open**, including policy hooks |
| ✅ | [Claude Code — Hooks](https://code.claude.com/docs/en/hooks) | Broad lifecycle, matching, control behavior |

## Code intelligence — LSP & MCP

| | Source | What to take from it |
|---|---|---|
| ✅ | [Copilot — LSP servers](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/lsp-servers) | Definition/references/implementations/symbols/hover — symbol-aware, not text |
| ✅ | [Copilot — Add LSP servers](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/add-lsp-servers) | `.github/lsp.json` |
| ✅ | [Copilot — MCP private registry enforcement](https://docs.github.com/en/copilot/reference/enterprise-administrators/mcp-private-registry-enforcement) | **Read fresh at stop 18, 2026-09-25, and the rename did change the model.** *"Enforcement is based only on server name/ID matching, which can be bypassed by editing configuration files"* and *"Strict enforcement that prevents installation of non-registry servers is not yet available."* Applies to local **and** remote servers under "Registry only"; the Copilot **cloud agent has no enforcement at all**; every other surface carries a client version floor. **This is L3, not a boundary** |
| ✅ | [Claude Code — MCP](https://code.claude.com/docs/en/mcp) | **Extracted 2026-09-25 (stop 18).** Three scopes: local `~/.claude.json`, project `.mcp.json`, user `~/.claude.json`. The approval prompt for a project-scoped server fires **only in interactive sessions** — *"In `claude -p` runs, Agent SDK sessions, and cloud sessions, Claude Code can't show that prompt: it loads project-scoped servers without asking"*, and **every run this project makes is `claude -p`**. What does execute: `--strict-mcp-config`, `managedMcpServers`, `disabledMcpjsonServers`, `allowedMcpServers`/`deniedMcpServers`, `managed-mcp.json` |
| ✅ | [Codex — MCP](https://learn.chatgpt.com/docs/extend/mcp?surface=cli) | Note the `?surface=` param — the docs are surface-scoped. **Extracted 2026-09-25 (stop 18):** `[mcp_servers.<name>]` in `~/.codex/config.toml`; stdio `command`/`args`/`env`/`cwd`/`startup_timeout_sec`/`tool_timeout_sec`, HTTP `url`/`bearer_token_env_var`/`http_headers`/`auth`. **Checked on the installed `codex-cli 0.154.0`: there is no analogue of `--strict-mcp-config`** — `--strict-config` only rejects unrecognised config keys — so the codex arm's only MCP isolation is a clean `CODEX_HOME` |
| ✅ | [MCP specification — overview, `2026-07-28`](https://modelcontextprotocol.io/specification/2026-07-28) | Cited dated, not as `latest`, per this file's own Protocol row. **`latest` resolved to `2026-07-28` on 2026-09-25** — `check-links.sh` reports the redirect, so the revision is mechanically confirmed and not just read. Read at stop 18. The sentence the phase turns on: *"While MCP itself cannot enforce these security principles at the protocol level, implementors **SHOULD**…"* — the spec's security section is **L3 by its own admission**. Adds `Elicitation` (server-initiated requests for user input) to the surface Lab 6.3 was written against |
| ✅ | [MCP specification — Tools, `2026-07-28`](https://modelcontextprotocol.io/specification/2026-07-28/server/tools) | *"For trust & safety and security, clients **MUST** consider tool annotations to be untrusted unless they come from trusted servers"* — checked against the [2025-06-18 page](https://modelcontextprotocol.io/specification/2025-06-18/server/tools) to see whether the MUST had weakened; **it had not** (the `latest` overview's lowercase "should" is a summary, non-normative under the spec's own BCP-14 sentence). Server-side bullets are **MUST**, every client-side bullet is **SHOULD**, human-in-the-loop included. `x-mcp-header` mirrors tool parameters into `Mcp-Param-*` headers *"visible to network intermediaries"*, protected only by a **SHOULD NOT** — Lab 6.4's secrets row with a field name |

## Plugins & distribution

| | Source | What to take from it |
|---|---|---|
| ✅ | [Copilot — About plugins](https://docs.github.com/en/copilot/concepts/agents/about-plugins) | `plugin.json` can bundle agents, skills, hooks, MCP and LSP config |
| ✅ | [Copilot — Enterprise plugin standards](https://docs.github.com/en/copilot/concepts/agents/about-enterprise-plugin-standards) | |
| ✅ | [Claude Code — Plugins](https://code.claude.com/docs/en/plugins) | |

## Agentic workflows (gh-aw)

| | Source | What to take from it |
|---|---|---|
| ✅ | [gh-aw home](https://github.github.com/gh-aw/) | **Public Preview.** Pin versions, revalidate every cohort |
| ✅ | [Creating workflows](https://github.github.com/gh-aw/setup/creating-workflows/) | |
| ✅ | [Safe outputs](https://github.github.com/gh-aw/reference/safe-outputs/) | Read-only agent job → structured output → validation → separate scoped write job |
| ✅ | [Permissions](https://github.github.com/gh-aw/reference/permissions/) | |
| ✅ | [A/B experiments](https://github.github.com/gh-aw/experimental/experiments/) | |

## Memory

| | Source | What to take from it |
|---|---|---|
| ✅ | [Copilot Memory](https://docs.github.com/en/copilot/concepts/agents/copilot-memory) | Repo facts + user preferences; enabled **per user**, not per repository; entries expire |
| ✅ | [Claude Code — Memory](https://code.claude.com/docs/en/memory) | Human-authored `CLAUDE.md` vs Claude-written auto memory — **different trust levels** |
| ↪️ | [VS Code — Memory](https://code.visualstudio.com/docs/agents/memory) → `…/docs/agents/run/memory` | Distinct from GitHub-hosted Copilot Memory |

## Governance

| | Source | What to take from it |
|---|---|---|
| ↪️ | [Enterprise managed settings](https://docs.github.com/en/copilot/reference/enterprise-managed-settings-reference) → `…/enterprise-administrators/enterprise-managed-settings` | |
| ✅ | [Content exclusion](https://docs.github.com/en/copilot/concepts/context/content-exclusion) | **Not a universal Agent-mode security boundary.** Know the limits before quoting it to a risk officer |
| ✅ | [MCP private registry enforcement](https://docs.github.com/en/copilot/reference/enterprise-administrators/mcp-private-registry-enforcement) | Same page as the row under *Code intelligence*, cross-listed; URL de-staled and the page **read fresh at stop 18, 2026-09-25**. Renamed from "allowlist enforcement", and the model changed with the name: name/ID matching only, bypassable by editing a config file, strict enforcement *"not yet available"* |
| 🔒 | [OpenAI — Running Codex safely](https://openai.com/index/running-codex-safely/) | |

---

## ⚠️ One source is a tombstone that returns 200

`https://opentelemetry.io/docs/specs/semconv/gen-ai/` responds **HTTP 200**, renders a page,
and does not redirect — so `check-links.sh` marks it ✅. Reading it says:

> "This page **has moved and is no longer maintained** in this repository."

Content moved to
**[github.com/open-telemetry/semantic-conventions-genai](https://github.com/open-telemetry/semantic-conventions-genai)** (✅ verified).
The sub-pages still resolve: [spans](https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-spans/) ✅ ·
[metrics](https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-metrics/) ✅

**A 200 means the server answered. It does not mean the page still says what you cited it
for.** No link checker catches this — only reading does. It is the reason every source here
carries *the question to bring to it* rather than just a URL.

---

## Sources the curriculum does not cite but you will need

Added from labs and extracts. None of these are in `CURRICULUM.md`. All verified 2026-08-28.

### Agent design and orchestration

| | Source | Why it earned a place |
|---|---|---|
| ✅ | [Anthropic — Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) | **Workflow vs agent**, five patterns, and *"add complexity only when it demonstrably improves outcomes."* Extracted in [0A](phases/00a-agent-mechanics/) |
| ✅ | [Anthropic — Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) | 15× tokens, +90.2% — **and *"most coding tasks involve fewer truly parallelizable tasks than research."*** Extracted in [4B](phases/04b-orchestration/) |
| ✅ | [Claude Code — Agent teams](https://code.claude.com/docs/en/agent-teams) | Lead coordinates, assigns, merges |
| ✅ | [Claude Code — Dynamic workflows](https://code.claude.com/docs/en/workflows) | When orchestration should be deterministic code, not a model decision |
| ✅ | [A harness for every task](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code) | How the Claude Code team actually does it |

### Context and knowledge

| | Source | Why |
|---|---|---|
| ✅ | [Anthropic — Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) | **Context rot**, and the four strategies. The theory Phase 1 tests. Extracted in [0A](phases/00a-agent-mechanics/) |
| ↪️ | [Model Context Protocol spec](https://modelcontextprotocol.io/specification/latest) → `/specification/2026-07-28` | The protocol itself, not a vendor's wrapper. **`latest` is a moving target** — cite the dated revision in anything you intend to reproduce |
| ✅ | [MCP spec — Resources, `2026-07-28`](https://modelcontextprotocol.io/specification/2026-07-28/server/resources) | MCP's **read path** — `resources/list`, `resources/read`, `annotations.priority`. **Its five Security Considerations are all server-side and none is about the content.** Extracted in [6B](phases/06b-knowledge-retrieval/#extract) |
| ✅ | [LSP 3.17 specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/) | Why symbol intelligence differs from text search, at the wire level |

### Security and trust

| | Source | Why |
|---|---|---|
| ✅ | [Simon Willison — The lethal trifecta](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/) | Private data + untrusted content + external communication. **95% detection is "a failing grade."** Extracted in [0A](phases/00a-agent-mechanics/) |
| ✅ | [OWASP — Top 10 for LLM Applications](https://genai.owasp.org/llm-top-10/) | Which of the ten your L1/L2 controls can actually stop |
| ✅ | [Claude Code — Security](https://code.claude.com/docs/en/security) | Read the limits harder than the guarantees |
| ✅ | [Claude Code — Sandboxing](https://code.claude.com/docs/en/sandboxing) | What a real Layer 1 boundary looks like |
| ✅ | [Claude Code — IAM](https://code.claude.com/docs/en/iam) | Layer 2 in detail, and precedence |
| ✅ | [Claude Code — Dev containers](https://code.claude.com/docs/en/devcontainer) | When Layer 2 is not enough |

### Flags, telemetry and the things that bit us

| | Source | Why it earned a place |
|---|---|---|
| ✅ | [Claude Code — CLI reference](https://code.claude.com/docs/en/cli-reference) | `--bare`, `-p`, `--permission-mode`, `--append-system-prompt-file`. **Four of seven harness bugs live in these flags** |
| ✅ | [Claude Code — Model configuration](https://code.claude.com/docs/en/model-config) | Aliases vs exact model IDs. An alias silently re-pointing is an uncontrolled variable — the page now gives a **worked example** of it happening (*"Before v2.1.219, `opus` resolved to Opus 4.8… from v2.1.154"*). **Extracted 2026-09-04:** a subagent is a SECOND place the model is chosen, above which sits `CLAUDE_CODE_SUBAGENT_MODEL` |
| ✅ | [Claude Code — Monitoring usage](https://code.claude.com/docs/en/monitoring-usage) | **`claude_code.tool.blocked_on_user`** — the detector for harness bug #7. Every content-capture default. `user.email` when authenticated. Extracted in [10](phases/10-production-observability/) |
| ✅ | [Claude Code — Settings](https://code.claude.com/docs/en/settings) | Which of user/project/local won on a given run |
| ✅ | [Claude Code — Memory](https://code.claude.com/docs/en/memory) | *"Claude Code reads `CLAUDE.md`, not `AGENTS.md`."* The sentence that voided Phase 1. Extracted in [9](phases/09-memory/) |
| ✅ | [Claude Code — Hooks](https://code.claude.com/docs/en/hooks) | Exit codes, fail-open behaviour, and **`InstructionsLoaded`** — the preflight assertion #36 needs. Extracted in [5A](phases/05a-guardrails/) |

## Where each extract lives

| Phase | Extract built from |
|---|---|
| [0A](phases/00a-agent-mechanics/#extract) | Building effective agents · context engineering · lethal trifecta |
| [0B](phases/00b-observatory/#extract) | The GenAI semconv tombstone |
| [1](phases/01-instructions/#extract) | Copilot custom-instructions support matrix |
| [2](phases/02-prompt-files/#extract) | VS Code prompt files |
| [3](phases/03-skills/#extract) | Claude Code Skills |
| [4A](phases/04a-agents-permissions/#extract) | Claude Code subagents |
| [4B](phases/04b-orchestration/#extract) | Multi-agent research system |
| [5A](phases/05a-guardrails/#extract) | Claude Code hooks |
| [5B](phases/05b-verification-selfhealing/#extract) | `permissions.deny` and where BLOCKED is recorded |
| [6A](phases/06a-code-intelligence/#extract) | LSP 3.17 · Claude Code MCP · the MCP spec's enforcement clauses |
| [6B](phases/06b-knowledge-retrieval/#extract) | Context engineering · the lethal trifecta · the MCP spec's resources page |
| [8](phases/08-agentic-workflows/#extract) | gh-aw safe outputs |
| [9](phases/09-memory/#extract) | Claude Code memory |
| [10](phases/10-production-observability/#extract) | Claude Code monitoring usage |

**Still without an extract:** 7 — tracked in issue #17.

*(Corrected 2026-09-25 by Opus 5 (claude-opus-5), autonomously, at spine stop 19. This line read
**"5B, 6A, 6B, 7"** and three of those four had extracts: 5B was written at stop 16, 6A at stop 18,
6B at this stop. The three missing rows are added to the table above. Nothing executes to catch a
stale line here — `check-links.sh` verifies URLs, not claims about this repository — so this is
**L3**, and it went stale for the same reason the workspace `CLAUDE.md` position line has gone
stale three times: a hand-maintained summary of state that lives somewhere other than the state.)*
