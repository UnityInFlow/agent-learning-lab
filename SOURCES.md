# Verified sources

Every URL the curriculum cites, checked with `curl -sSL` on **2026-08-09**. Re-run
[`tools/check-links.sh`](tools/check-links.sh) before each cohort — this list drifts.

**Status legend:** ✅ resolves as written · ↪️ resolves but **redirects** (the URL in
`CURRICULUM.md` is stale) · 🔒 live in a browser, blocks `curl` (403 to bots)

## What the check found

Seven of the 43 links have moved. Two are worth knowing about because the *content* moved,
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
| ✅ | [Copilot — Custom agents configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration) | **If `tools` is omitted, the agent gets all tools.** `mcp-servers` is not used by IDE agents |
| ✅ | [Claude Code — Subagents](https://code.claude.com/docs/en/sub-agents) | Separate context, own system prompt, tool config, model selection, independent permissions |
| ↪️ | [Codex — Subagents](https://developers.openai.com/codex/agent-configuration/subagents) → `learn.chatgpt.com/docs/agent-configuration/subagents` | Codex **does** have subagents now. Do not teach the old "Codex has no subagents" |

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
| ↪️ | [Copilot — MCP allowlist enforcement](https://docs.github.com/en/copilot/reference/mcp-allowlist-enforcement) → `…/enterprise-administrators/mcp-private-registry-enforcement` | **Renamed.** Read fresh; the enforcement model is the point of Phase 6's exit gate |
| ✅ | [Claude Code — MCP](https://code.claude.com/docs/en/mcp) | |
| ↪️ | [Codex — MCP](https://developers.openai.com/codex/mcp) → `learn.chatgpt.com/docs/extend/mcp?surface=cli` | Note the `?surface=` param — the docs are now surface-scoped |

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
| ↪️ | [MCP private registry enforcement](https://docs.github.com/en/copilot/reference/mcp-allowlist-enforcement) | |
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

Added from labs and extracts. None of these are in `CURRICULUM.md`. All verified 2026-08-09.

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
| ✅ | [Claude Code — Model configuration](https://code.claude.com/docs/en/model-config) | Aliases vs exact model IDs. An alias silently re-pointing is an uncontrolled variable |
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
| [8](phases/08-agentic-workflows/#extract) | gh-aw safe outputs |
| [9](phases/09-memory/#extract) | Claude Code memory |
| [10](phases/10-production-observability/#extract) | Claude Code monitoring usage |

**Still without an extract:** 5B, 6A, 6B, 7 — tracked in issue #17.
