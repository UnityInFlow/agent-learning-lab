# Phase 10 — Production observability + engineering impact

**Status:** ⬜ Not started · **Depends on:** Phase 9

## Goal

Move from one-run learning telemetry to chapter-level operating evidence.

## Verified reading

- [ ] ✅ [Copilot CLI OTel reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference)
- [ ] ↪️ [Enterprise managed settings](https://docs.github.com/en/copilot/reference/enterprise-administrators/enterprise-managed-settings)
- [ ] ✅ [Claude Code — Monitoring usage](https://code.claude.com/docs/en/monitoring-usage)
- [ ] ✅ [GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/)

> **Default: full prompt/response/tool content capture stays OFF unless explicitly
> approved.** Copilot OTel exposes useful metadata without it.

## Three layers

| | Examples | Question |
|---|---|---|
| **L1 Adoption** | active users/teams, agent-mode usage, CLI usage | Are people using it? |
| **L2 Agent execution** | success rate, task type, tokens, cost, model/tool calls, retries, duration, hook denials, MCP failures | How do agents behave? |
| **L3 Engineering impact** | PR cycle time, review rework, escaped defects, change failure rate, lead time, incidents, time-to-fix, onboarding independence | Does it improve engineering? |

**Usage is not impact.** A dashboard full of L1 is a dashboard that cannot answer the only
question the business asked.

## Domain model

Do not mirror vendor span names into your database.

```
Experiment · Run · Task · Harness · Model · CustomizationSet
Evaluation · HumanReview · SafetyFinding

Copilot OTel ─┐
Claude OTel ──┼── normalization ──► Observatory domain
Codex OTel ───┘
```

## Dashboards

1. **Run explorer** — task, harness, model, customization version, score, tokens, cost, duration, tool calls, retries
2. **Comparison** — B0 / B1 / B3 / B4 with **median, p25/p75, success rate, sample count.** Never one "average score"
3. **Safety** — denied tools, hook errors, hook timeouts, MCP failures, unexpected network, permission escalations
4. **Model strategy** — quality / cost / latency / failure rate **per task class**

## Experiment policy

Change **one meaningful variable** at a time.

```
Bad:     new model + new skill + new prompt + new permissions   → unattributable
Better:  same task, harness, model, permissions; only AGENTS v2 changed
```

## Promotion gate

A customization moves from pilot to chapter standard only if:

1. deterministic checks do not regress
2. benchmark quality improves or stays within approved tolerance
3. safety guardrails do not regress
4. cost increase is justified
5. enough repetitions exist
6. a human reviews the qualitative diff
7. **rollback is defined**

## Exit gate

- [ ] I can name a metric in each of L1/L2/L3 for my chapter
- [ ] I can explain why usage is not impact to a non-engineer
- [ ] My comparison dashboard shows uncertainty, not just a winner
- [ ] I can state the promotion gate from memory
- [ ] I know what my telemetry captures and what it deliberately does not
