# Batch 20260910T132311Z — STOPPED, and every run in it is excluded by name

**Stopped by hand at 2026-09-10T14:5xZ, after 5 of 40 runs, because the machine stopped being a
measurement environment.** Nothing here is scored, nothing enters an `n`, and every folder is kept.

## What happened

Runs 01 and 02 of both arms completed normally in ~2.5 minutes each, evaluator exit 0, delivery
separating exactly as the preflight predicted. **Run `BE-003 03 treated` then took 71 minutes and was
still going.** It was not stuck: its log was being written seconds before it was inspected, and the
agent was making progress — through **13 Bash calls fighting `./mvnw test`**, trying `timeout 60`
(which does not exist on macOS), then backgrounding with `sleep 30; pkill`, then
`clean test -DforkMode=never`, then piping to `grep`. A normal run of this arm makes 3–4.

**It was not the treatment.** That run's policy log holds **2 decisions, both `allow`, zero denials**.
The gate did nothing to it.

## The cause: `load average 201.97`

| process | %CPU | age |
|---|---:|---|
| `memcore-server` (memtrace) | **189.7** | 3 days |
| `memtrace` | **106.9** | 3 days |
| `qemu-system-aarch64` (colima — this is ours, the observatory runs in it) | 39.1 | 16 days |
| `opencode run --dir …/books --pure` — a **different project**, started during this batch | 19.9 | seconds |
| `cmux` ×2, `WindowServer` | ~29 | days |

34 `claude` processes were alive, many of them days old (the oldest 12 days). Sum of `%cpu` across all
processes: **569**. Load fell 202 → 85 within minutes of the batch being stopped and its Maven
children dying.

**So the machine has other tenants and the batch cannot be isolated from them.** An agent that cannot
get CPU for Maven burns tool calls working around it — which moves `toolCalls`, `modelCalls` and
`estimatedCost`, three of this experiment's registered secondary outcomes, and could eventually flip
an evaluator verdict if the agent gives up. §6 says to exclude a contaminated *duration* and keep the
run; this is past that, because it is not only duration that moved.

## Excluded by name, all folders kept, none re-used

| run id | task | arm | why |
|---|---|---|---|
| `11dd0c8d-a569-4eb6-83b8-3a83bc548ac5` | BE-003 | treated | in a batch stopped for environment contamination |
| `1cd13b2a-3d01-41b8-aab8-9e7e01d590b5` | BE-003 | control | same |
| `8c17e8ac-b9b2-47ac-ad7b-f577f8ba46ef` | BE-003 | treated | same |
| `5b1df59d-8075-47fe-8d86-a615ae9a6c0c` | BE-003 | control | same |
| `f381a596-7181-494d-b615-57ab647a6831` | BE-003 | treated | **the 71-minute run itself** |
| `0c93f9e0-ff9a-4511-9a68-cac151209bc0` | BE-003 | control | **killed mid-run** when the harness was stopped; never reached the manifest, recorded here by hand |

All six are registered with the observatory under `EXP-B7-POLICY-BE003` and **must be filtered out by
id** when that key is analysed. They are not deleted: §6 forbids removing evidence, and a batch that
was stopped for a good reason is itself evidence.

## What this says about stops that are already closed

`memcore-server` has been running for **three days**. Stop 13's batches (2026-09-09) and stop 14's
25 runs (2026-09-10) were both executed under it. **This is a co-variate nobody registered**, and it
is recorded here rather than in those stops' files because nothing here re-derives their numbers —
it is a flag for a validator, not a correction.

*Recorded by Opus 5 (claude-opus-5), autonomous, 2026-09-10.*
