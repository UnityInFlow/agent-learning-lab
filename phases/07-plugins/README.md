# Phase 7 — Plugins + controlled distribution

**Status:** ⬜ Not started · **Depends on:** Phases 3, 4, 5

## Goal

Package only primitives the team already understands.

> **Do not use plugins to hide complexity from beginners.** A plugin that installs an
> abstraction nobody on the team can debug has moved the problem, not solved it.

## Verified reading

- [ ] ✅ [Copilot — About plugins](https://docs.github.com/en/copilot/concepts/agents/about-plugins)
- [ ] ✅ [Copilot — Enterprise plugin standards](https://docs.github.com/en/copilot/concepts/agents/about-enterprise-plugin-standards)
- [ ] ↪️ [Enterprise managed settings](https://docs.github.com/en/copilot/reference/enterprise-administrators/enterprise-managed-settings)
- [ ] ✅ [Claude Code — Plugins](https://code.claude.com/docs/en/plugins)
- [ ] Codex plugin capabilities — current Codex docs. **Do not assume a Copilot plugin
      manifest is portable**

A Copilot plugin bundles agents, skills, hooks, MCP config and LSP config, with
`plugin.json` as manifest.

## Lab 7.1 — Package existing tested components

Package the reviewer agent, the testing skill, the audit hook. **Nothing new during
packaging.** Otherwise a failure is unattributable:

```
feature bug?   plugin packaging bug?   installation bug?   policy bug?
```

## Lab 7.2 — Clean-machine reproducibility

On a disposable environment: clone the sample repo, install the approved plugin, verify
versions, run the benchmark, compare with the manually installed configuration.

> Distribution must not change measured behavior beyond known packaging differences.

## Lab 7.3 — Upgrade test

Plugin v1 → v2, changing one skill behavior. Verify install, version visibility, rollback,
compatibility, eval result.

## Bank controls

Internal approved marketplace · CODEOWNERS · signed/reviewed releases where feasible ·
pinned versions · provenance · dependency scanning · **no silent auto-update into
production teams without promotion checks**.

## Exit gate

- [ ] Plugin vs skill
- [ ] Why installation is a supply-chain event
- [ ] Versioning and rollback
- [ ] Centralized enterprise restrictions

## Commit

```
distribution/ · distribution/plugin-release-process.md
experiments/B7-distribution.md
```
