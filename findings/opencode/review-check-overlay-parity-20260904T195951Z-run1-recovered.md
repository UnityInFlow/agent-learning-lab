### tools/check-overlay-parity.sh
**Verdict:** finding
**Failure:** Create two otherwise identical recognized overlays, keep `description: matches the task` in arm A, and delete the entire `description:` line from arm B. Run `--allow-differ description`. The removed line is classified as an allowed difference, `here` contains `description`, and the checker exits 0 even though the declared field is absent from one arm. One reviewer can accept this as a description treatment; another can reject it as a structurally different frontmatter schema.
**Layer of the implied fix:** L2
**Anchor:** if k in allow:
            here.add(k)
            declared_seen.add(k)

### tools/verify-overlay-parity-checker.sh
**Verdict:** finding
**Failure:** Run the verifier on Ubuntu with GNU sed. The first `sed -i '' ...` invocation treats `''` as a filename or invalid suffix and exits non-zero under `set -e`, so the verifier stops before executing its checks. The same artifact completes on macOS/BSD sed, producing platform-dependent verification outcomes.
**Layer of the implied fix:** L2
**Anchor:** sed -i '' '2i\

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates a pass/fail gate because the artifacts define no scoring categories. Reviewers are most likely to diverge on `tools/check-overlay-parity.sh`: for the missing-allowed-key diff above, one can report parity while another rejects the experiment, a full pass-versus-fail divergence (exit 0 versus exit 2 or 3). The artifacts do not specify that every allowed frontmatter key must exist exactly once on both sides, nor the operating systems on which the verifier is required to run.
**Layer of the implied fix:** L3
**Anchor:** SKILL.md frontmatter may differ ONLY in lines whose key is named by --allow-differ

