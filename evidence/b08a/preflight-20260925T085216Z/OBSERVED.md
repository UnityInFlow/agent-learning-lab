# B8a preflight pair — observed, 20260925T085216Z

Probe key `EXP-B8A-PREFLIGHT` — NOT the batch key. Model `claude-haiku-4-5-20251001`. Task `BE-005`.
API `http://127.0.0.1:8081`, OTLP `http://localhost:4318` / `http://localhost:4317`.
`events.jsonl` **17574371 bytes** before the pair.

## arm `control` — run `8d8505d7-aa82-41cf-9776-9e8d6d6c4335`

| | |
|---|---|
| runner exit | `12` |
| evaluator exitCode | `12` |
| runtime.model | `claude-haiku-4-5-20251001` |
| runtime.version | `2.1.282 (Claude Code)` |
| agentHash | `null` |
| instructionsHash | `null` |
| skillsHash | `null` |
| hookExecutions in record | `0` |
| modelCalls / toolCalls | `47` / `44` |
| estimatedCost / durationMs | `0.414733` / `235000` |
| changedFiles | `11` |
| delegations, agent stream | `0` |
| delegations, telemetry | `0` |
| kept worktree | `/var/folders/jr/lwzz65cx5pndqqdgzhnym1pc0000gn/T//observatory-run-8d8505d7-aa82-41cf-9776-9e8d6d6c4335` |

## arm `treated` — run `a390a301-eb67-45a5-b22d-d6e43a922e85`

| | |
|---|---|
| runner exit | `0` |
| evaluator exitCode | `0` |
| runtime.model | `claude-haiku-4-5-20251001` |
| runtime.version | `2.1.282 (Claude Code)` |
| agentHash | `sha256:1f27323694e579ec11dbca026bfbb326` |
| instructionsHash | `null` |
| skillsHash | `null` |
| hookExecutions in record | `0` |
| modelCalls / toolCalls | `102` / `124` |
| estimatedCost / durationMs | `0.807472` / `643000` |
| changedFiles | `11` |
| delegations, agent stream | `19` |
| delegations, telemetry | `0` |
| kept worktree | `/var/folders/jr/lwzz65cx5pndqqdgzhnym1pc0000gn/T//observatory-run-a390a301-eb67-45a5-b22d-d6e43a922e85` |

### The four delivery conditions (decision 11 item 9)

```
(a) git ls-files --error-unmatch, inside the kept worktree:
    TRACKED   .claude/agents/orchestrator.md
    TRACKED   .claude/agents/planner.md
    TRACKED   .claude/agents/implementer.md
    TRACKED   .claude/agents/verifier.md
(b) agentHash sha256:1f27323694e579ec11dbca026bfbb326  vs registered sha256:1f27323694e579ec11dbca026bfbb326
(c) init read-back file: init-schema-a390a301-eb67-45a5-b22d-d6e43a922e85.txt
    init-schema: delivered n=4 ["Read","Task","Grep","Glob"]
    init-schema: declared  n=4 ["Read","Grep","Glob","Task"]
    init-schema: SAME SET, DIFFERENT ORDER — reported, not passed
    init-schema: verdict=order-differs
(d) specialists named, telemetry then stream:
    planner  telemetry=0  stream=1
    implementer  telemetry=0  stream=1
    verifier  telemetry=0  stream=1
```

### Every init read-back this run wrote (author decision 8, all three specialists)

```
--- init-schema-8d8505d7-aa82-41cf-9776-9e8d6d6c4335.txt
    init-schema: delivered n=28 ["Task","Bash","CronCreate","CronDelete","CronList","DesignSync","Edit","EnterWorktree","ExitWorktree","ListAgents","Monitor","NotebookEdit","PushNotification","Read","RemoteTrigger","ReportFindings","ScheduleWakeup","SendMessage","TaskCreate","TaskGet","TaskList","TaskStop","TaskUpdate","ToolSearch","WebFetch","WebSearch","Workflow","Write"]
    init-schema: no overlay given — NOTHING ASSERTED, delivered set recorded only
    init-schema: verdict=recorded-only
--- init-schema-a390a301-eb67-45a5-b22d-d6e43a922e85.txt
    init-schema: delivered n=4 ["Read","Task","Grep","Glob"]
    init-schema: declared  n=4 ["Read","Grep","Glob","Task"]
    init-schema: SAME SET, DIFFERENT ORDER — reported, not passed
    init-schema: verdict=order-differs
```

## events.jsonl

| | bytes |
|---|---|
| before the pair | `17574371` |
| after the pair | `18381324` |

An open OTLP port is not proof an export lands (stop 11). If these two numbers are equal,
delivery condition (d) has no telemetry source and is answered from the agent stream with
that substitution named in the workbook.
