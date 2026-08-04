# G3 Exit Record — AWS Pre-Prod Controls (PARTIAL)

Branch: `feature/preprod-g3-aws-controls` (2026-08-04 UTC).
**G3 closes partially**: the guardrail library (G3.C) is complete and gated;
G3.A (egress inspection) and G3.B (security stacks) are blocked by upstream
module gaps, and the plan-based exit criteria are blocked by expired host
credentials. Nothing was invented to fake completeness.

## Exit criteria status

| Check | Status | Evidence |
|---|---|---|
| Every SCP has ≥ 3 passing test cases | ✅ **30 cases passed, 0 failures** (3 pre-existing empty files waived with reasons) | `python3 scripts/validate-scp.py` exit 0 |
| Architecture score ≥ threshold | ✅ 23.5 ≥ 20, no drop vs G1 baseline | `make preprod-gates-local` |
| `NETWORK_TOPOLOGY.md` regenerated, fresh | ✅ | doc-freshness gate |
| `run --all validate` clean on stg trees | ⏸ **deferred** — host AWS/GCP credentials expired (STS 403 / ADC invalid_grant) | KNOWN_FAILURES #2 |
| `run --all plan` + plan JSON archived | ⏸ deferred — same | — |
| No spoke retains non-TGW default route | ⏸ deferred — cutover impossible until MODULE_GAPS #1–#4 close | `docs/preprod/MODULE_GAPS.md` |

## Delivered

- **G3-13/15/16**: six-policy SCP guardrail library (protect-security-services,
  require-imdsv2, region-restriction, deny-root, guardrails-sandbox,
  quarantine-unattached), control mapping in `policies/CONTROLS.md` + Sids,
  wired in vars.yaml to the **stg OU only** (`PLACEHOLDER_OU_ID_STG`),
  offline SCP simulator + fixtures, `policy-as-code` gate now **blocking**.
- **G3-1**: inspection schema in vars.yaml for both stg envs (`enabled: false`,
  CIDR placeholders registered).
- **G3-6**: `docs/RUNBOOKS/aws-egress-cutover.md` + `CUTOVER_RISKS.md`.
- `docs/preprod/MODULE_GAPS.md`: 11 recorded gaps (audited upstream repo via
  API — none of the G3.A/G3.B modules exist).

## New findings this gate

1. **Three of five pre-existing SCP policy files are 0-byte** (`dev.json`,
   `dev_infra.json`, `prod_infra.json`) — the declared dev/prod-infra OU
   guardrails are hollow and the stack would fail at apply. Waived with
   reasons (`scripts/config/scp-waivers.yaml`); prod file → DEFERRED #4.
2. `prod.json` region policy is a **NotAction** deny: 40 service prefixes
   (incl. acm) are exempt from prod's region restriction — documented in the
   fixture file after the simulator caught a wrong test assumption.
3. TGW vars declare `0.0.0.0/0 blackhole: true` per spoke attachment — the
   egress cutover's black-hole risk is real by construction (CUTOVER_RISKS #1).

## To resume G3 completion

1. Operator refreshes host credentials (or creates the CI OIDC roles) → run
   `make preprod-validate && make preprod-plan`, archive to `evidence/G3/`.
2. Module gaps closed upstream → author `network/inspection|firewall|tgw-routing`
   stacks + G3.B stacks against the already-declared vars schema.
