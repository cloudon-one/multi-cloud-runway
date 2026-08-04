# G4 Exit Record — GCP Pre-Prod Controls (PARTIAL)

Branch: `feature/preprod-g4-gcp-controls` (2026-08-04 UTC).
G4.A/B/C delivered as code (all four new local modules pass `tofu validate`
offline); G4.D (project factory) deferred; terragrunt-level validate/plan
criteria deferred on credentials.

## Exit criteria status

| Check | Status | Evidence |
|---|---|---|
| Perimeter is dry-run, never enforcing | ✅ `use_explicit_dry_run_spec = true`, no `status` block, `ignore_changes = [status]` guard; scorecard `vpcsc-perimeter-coverage` PASS | `tf-modules/terraform-google-vpcsc/main.tf` |
| `CMEK_WIRING.md` generated, non-empty, per-project sections | ✅ host + service project sections, 12 bindings | `make cmek-wiring` |
| Org policies enforcing at stg folder, dry-run at org | ✅ (as authored) | `docs/preprod/ORG_POLICY_SCOPE.md` |
| Zero destroys of projects/folders/keyrings in plan | ✅ tooling ready (`scripts/plan-guard.py`), ⏸ no plans to check yet (credentials) | — |
| `run --all validate` clean on `envs/stg/**` + `envs/global/**` | ⏸ deferred — GCS backend needs refreshed ADC; **all 4 new modules pass `tofu validate` standalone** | module validate logs |

## Delivered

- **G4.A**: `terraform-google-org-policies` module (Org Policy v2, per-constraint
  dry-run) + `envs/global/org-policies` stack + 13-constraint seed set in vars
  (enforcing at stg folder via admin-stack folder output, dry-run at org).
  `terraform-google-org-tags` + `envs/global/tags` (environment /
  data-classification / compliance-scope; stg folder bound).
- **G4.B**: `terraform-google-vpcsc` module + `envs/global/vpcsc` stack.
  Restricted services **derived** in the stack hcl from the union of declared
  stg APIs ∩ VPC-SC-supported list. Access levels (corp-network,
  admin-identity, ci-automation), ingress (console/CI/GKE), egress (artifact
  pulls, log export). Dry-run only; promotion runbook
  `docs/RUNBOOKS/vpcsc-dryrun-to-enforce.md`.
- **G4.C**: `terraform-google-kms` module + `envs/stg/eu/kms` stack (6 service
  keys, 90-day rotation) + **svc-sql wired to the sql CMEK via dependency**
  (closes part of the G1 encryption finding). `scripts/render-cmek-wiring.py`
  → `CMEK_WIRING.md` (post-apply service-agent grants; project numbers can't
  exist at plan time). Scorecard checks added: `vpcsc-perimeter-coverage`
  (G4-8), `gcp-kms-key-resolution` (G4-12).
- `scripts/plan-guard.py` (G4-15) wired for `plans/*.json`.
- **Score: 23.5 → 36.5** (sa-key-creation guardrail, perimeter coverage, KMS
  resolution now PASS; no check regressed).

## Deferred (with reasons)

1. **G4.D project factory + import-only migration** — requires live project
   inventory and `terraform import` verification against real state; blocked
   on credentials, and per user instruction client project data must come
   from live sources, never invented. Resumes as its own branch.
2. **`envs/stg/us`** — still a scope decision (G0 finding #5): create for
   region parity or descope in `ACCEPTED_GAPS.md` (G5).
3. **svc-redis CMEK** — the local memorystore module exposes no
   customer-managed-key input (upstream `terraform-google-modules/memorystore`
   10.0). Recorded as MODULE_GAPS-style gap; scorecard keeps it visible.
4. Terragrunt validate/plan of the new stacks — expired ADC.

## New placeholders (all in gate-thresholds allowlist, must be empty for promotion)

`PLACEHOLDER_GCP_DIRECTORY_CUSTOMER_ID`, `PLACEHOLDER_PROJECT_NUMBER_STG_HOST`,
`PLACEHOLDER_PROJECT_NUMBER_STG_SERVICE`, `PLACEHOLDER_CORP_EGRESS_CIDR`,
`PLACEHOLDER_ADMIN_GROUP_EMAIL`, `PLACEHOLDER_CI_SA_EMAIL` (9 total in repo).
