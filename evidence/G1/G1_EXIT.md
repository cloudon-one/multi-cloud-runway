# G1 Exit Record — Evidence Spine

Closed: 2026-08-04 (UTC). Branch: `feature/preprod-g1-evidence-spine`.

| Check | Command | Result |
|---|---|---|
| Report schema valid | `python3 scripts/architecture-score.py --validate-schema` | exit 0 — 16 records, schema v1 |
| Score baseline recorded | `make score` | **23.5/100 (grade F)** — PASS 5 · WARN 3 · FAIL 8; snapshot in `ARCHITECTURE_REPORT.baseline.json` |
| Placeholder register complete | `python3 scripts/placeholder-scan.py --check` | exit 0 — 0 tokens in repo |
| Assertions run | `python3 scripts/input-assertions.py --check` | exit 0 — 16 findings, all allowlisted with reasons |
| Generated docs fresh | `python3 scripts/validate-docs.py --check-staleness` | exit 0 — all 3 trailers + 3 generator checks fresh |

## Baseline score context

The F grade is the honest starting point, matching `docs/preprod/COVERAGE_MATRIX.md`:
egress inspection, CMEK/rotation, org guardrails, DR declarations, and budgets
are absent. Later gates are expected to raise this; a score *drop* against
this baseline fails the gate (plan failure-handling table).

## Notable findings produced by the new tooling

1. **Prod bug (deferred, GR-3):** `enable_network_egress_expoert` typo in both
   prod GKE var blocks — input silently dropped, egress export effectively OFF.
   Logged in `docs/preprod/DEFERRED_PROD_CHANGES.md`.
2. Declared-but-undeployed `svc-iam-permissions` / `net-iam-permissions`
   blocks across 7 env scopes; stg `net-glb` declared with no stack.
3. `iam/roles` sources a stub module with no variables ("placeholder" per its
   own hcl comment) — `Environments.master.Resources.iam` partially inert.
4. The README CIDR table had drifted from vars.yaml (claimed /16 VPC CIDRs vs
   actual /20 subnets); topology docs are now generated, drift is CI-checkable.
