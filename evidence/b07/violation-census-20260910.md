# B7 — the violation census: does the enforcement requirement §10.10 asks for exist?

Queried `GET /api/runs?limit=1000` on the observatory API through this machine's SSH tunnel
(`127.0.0.1:18081`) at **2026-09-10T09:38:09Z**. Every stored run the observatory holds, no filter.

**499 runs.** Evaluator `evaluation.exitCode`, whose meanings are fixed by
`agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/evaluator.sh:26-35` and are the same
contract on BE-004.

| exit | meaning | all stored runs | Track B corpus only |
|---:|---|---:|---:|
| **0** | all acceptance criteria passed | 438 | 305 |
| **10** | build failure (F04) | 0 | 0 |
| **11** | existing tests failed (F05) | 9 | 0 |
| **12** | functional acceptance failed (F03) | 49 | 20 |
| **13** | error contract violated (F02) | 0 | 0 |
| **20** | new dependency introduced (F07) | 0 | 0 |
| **21** | unrelated production files changed (F07) | 3 | 0 |
| **30** | evaluator/infrastructure failure (F15) | 0 | 0 |
| | **total** | **499** | **325** |

"Track B corpus" is every run whose `experimentKey` starts with `EXP-B2-`, `EXP-B3-`, `EXP-B4-`,
`EXP-B5-`, `EXP-B6-`, `EXP-4B-`, `EXP-P12-`, `EXP-P3-`, `EXP-P4B-`, `EXP-PREFLIGHT-B3` or
`EXP-PARITY-PROBE` — the runs that share this step's model (`claude-haiku-4-5-20251001`), its two
tasks and its harness. The rest are BE-001/BE-002 and smoke work from before Track B.

## Every non-zero, non-12 verdict in the whole store, listed

| experimentKey | task | runId | exit | in Track B? |
|---|---|---|---:|---|
| `EXP-BE002-AGENTSMD-V3` | BE-002 | `54329a06` | 21 | no |
| `EXP-BE002-AGENTSMD-V3` | BE-002 | `fe51824a` | 21 | no |
| `EXP-BE002-B0` | BE-002 | `d11521bc` | 21 | no |
| `EXP-BE002-MODEL-TIER` | BE-002 | `1a0b375e` | 11 | no |
| `EXP-BE002-MODEL-TIER` | BE-002 | `344274bf` | 11 | no |
| `EXP-BE002-MODEL-TIER` | BE-002 | `4d0246d7` | 11 | no |
| `EXP-BE002-MODEL-TIER` | BE-002 | `5b576f59` | 11 | no |
| `EXP-BE002-MODEL-TIER` | BE-002 | `6b19bafb` | 11 | no |
| `EXP-BE002-MODEL-TIER` | BE-002 | `b32a4396` | 11 | no |
| `EXP-BE002-MODEL-TIER` | BE-002 | `ca952174` | 11 | no |
| `EXP-SMOKE-GITLEAK` | BE-002 | `af4a7e30` | 11 | no |
| `EXP-SMOKE-SONNET` | BE-002 | `4e26debe` | 11 | no |

