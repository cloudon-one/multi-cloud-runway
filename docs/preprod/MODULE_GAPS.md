# Module Gaps (G3/G4 blockers)

AWS stacks source modules exclusively from
`github.com/cloudon-one/aws-terraform-modules` (ref `dev` / `v1.0.0`).
Audited 2026-08-04 via the GitHub API: the repo contains 20 modules
(vpc, tgw, scp, cloudtrail, eks, rds, ...). **None of the modules required by
G3.A/G3.B exist upstream.** Per plan failure-handling: do not fork silently —
gaps are recorded here; stacks land once the module (or an approved
alternative) exists. Upstream issues: to be filed by an operator with write
access (links go in the table when filed).

| # | Needed by | Missing module / feature | Blocks | Upstream issue |
|---|---|---|---|---|
| 1 | G3-2 | `aws-terraform-inspection-vpc` (or vpc-module support for firewall-endpoint subnet tier + TGW attachment with **appliance mode**) | Inspection VPC stacks `network/inspection/{us,eu}/stg` | _to file_ |
| 2 | G3-3 | `aws-terraform-network-firewall` (AWS Network Firewall + policy, STRICT_ORDER, managed rule groups, logging) | Firewall stacks `network/firewall/{us,eu}/stg` | _to file_ |
| 3 | G3-4 | tgw module: multiple route tables / route domains + per-attachment association & propagation control (current module: single implicit table, static `tgw_routes` only, no `appliance_mode_support`) | `network/tgw-routing/{us,eu}/stg` | _to file_ |
| 4 | G3-5 | vpc module: option to drop local NAT/IGW default route and emit `0.0.0.0/0 -> TGW` route (no such inputs; `enable_nat_gateway` exists but no TGW default-route support) | Spoke default-route cutover | _to file_ |
| 5 | G3-7 | `aws-terraform-guardduty` (org detector, delegated admin, data sources) | `security/guardduty` | _to file_ |
| 6 | G3-8 | `aws-terraform-config` (org recorder, delivery channel, conformance packs) | `security/config` | _to file_ |
| 7 | G3-9 | `aws-terraform-securityhub` (delegated admin, standards, cross-region aggregation) | `security/securityhub` | _to file_ |
| 8 | G3-10 | `aws-terraform-backup` (plans, vault lock compliance mode, cross-region copy) + org backup policy support | `backup/{us,eu}/stg` | _to file_ |
| 9 | G3-11 | `aws-terraform-budgets` (budgets with actual/forecast thresholds -> SNS) | `budgets/{us,eu}/stg` | _to file_ |
| 10 | G3-12 | `aws-terraform-access-analyzer` (org external + unused-access analyzers) | `security/access-analyzer` | _to file_ |
| 11 | G3-14 | scp module: `type` is hardcoded `SERVICE_CONTROL_POLICY` — no TAG_POLICY support | `security/tag-policy` | _to file_ |

## What G3 delivered despite the gaps

- G3-1 inspection **schema** in `vars.yaml` (both stg envs, `enabled: false`,
  CIDR placeholders) so stacks can consume it the moment modules exist.
- G3-13/15/16 SCP guardrail library: fully wired (scp module exists), stg OU
  targeting, 30 passing fixture cases, empty-file waivers.
- G3-6 egress cutover runbook + `CUTOVER_RISKS.md` (content is
  module-independent).

## Alternative if upstream stays frozen

Mirror the GCP pattern: a local `aws-tf-modules/` directory in this repo.
That is an architecture decision (breaks the "external modules" convention)
and needs an explicit owner sign-off — do not do it silently.
