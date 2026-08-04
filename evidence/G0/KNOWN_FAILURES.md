# Known Failures at G0 Baseline (G0-5)

Honest record of broken state found during Gate G0 (2026-08-04). **Nothing
here was fixed in G0** — per plan, G0 makes zero functional changes. Each item
names the gate expected to address it.

## 1. `make aws-validate` / `make gcp-validate` fail with installed Terragrunt

The Makefile invokes `terragrunt run-all validate --terragrunt-non-interactive`.
Terragrunt v1.1.2 (installed) has removed the `--terragrunt-*` flag spellings:

```
ERROR flag provided but not defined: -terragrunt-non-interactive
make: *** [aws-validate] Error 1
```

Evidence: `evidence/G0/aws-validate.log`, `evidence/G0/gcp-validate.log`
(local-only per evidence retention policy). Affects every `run-all` target in
the Makefile (init/validate/plan/apply/destroy, both clouds). The canonical
modern form is recorded in `docs/preprod/TOOLCHAIN.md`.
**Fix lands in:** G2 (`make preprod-validate`/`preprod-plan` use the modern
syntax; existing targets updated then, not in G0).

## 2. Cloud credentials on this host are invalid — backend init fails

Single-stack probes with the correct modern syntax still fail at `tofu init`
because both remote-state backends require live credentials:

- AWS (`aws/vpc/us/stg`): `STS GetCallerIdentity ... 403 InvalidClientTokenId`
- GCP (`envs/stg/eu/net-vpc`): GCS `auth: "invalid_grant" "Bad Request"`
  (expired application-default credentials)

Consequence: no full `run-all validate`/`plan` baseline could be captured on
this host. Also note Terragrunt v1.1.2 resolves **OpenTofu** (`tofu` 1.12.5),
not `terraform`, as its IaC binary on this host.
**Fix lands in:** G2 (CI OIDC federation, `docs/preprod/CI_IDENTITY.md`); local
credential refresh is an operator action, out of repo scope.

## 3. `make security` is a silent no-op on this host

The target soft-skips when scanners are absent, and both are absent:
`tfsec not installed - skipping`, `checkov not installed - skipping` — so the
"security scan" exits 0 having scanned nothing. `terraform-docs` and
`pre-commit` are also missing (the extensive `.pre-commit-config.yaml` pipeline
is not enforceable locally right now).
**Fix lands in:** G2 (CI runs pinned scanner versions; thresholds in
`.github/gate-thresholds.yaml`), tool installation is an operator action.

## 4. README claims controls that have no implementing stack

`README.md` (architecture diagram and Security table) lists **GuardDuty** as a
deployed security control. No GuardDuty stack exists anywhere under
`aws-terragrunt-configuration/` — nor do AWS Config, Security Hub, Access
Analyzer, AWS Backup, or Budgets stacks.
**Fix lands in:** G3.B (stacks) and G1-9/G1-10 (generated docs replace
hand-maintained claims).

## 5. `gcp/stg/us` does not exist

The plan's coverage matrix includes a `gcp/stg/us` column; the repo has no
`envs/stg/us` tree — GCP staging exists only as `envs/stg/eu` (10 stacks).
Prod, by contrast, has both `prod/eu` and `prod/us`, so stg is **not**
region-equivalent to prod. Either `envs/stg/us` must be created (G4 scope
decision) or formally descoped with rationale in
`docs/preprod/ACCEPTED_GAPS.md` (G5).

## 6. `vars.yaml` files declare unencrypted data services

`aws-terragrunt-configuration/aws/vars.yaml` contains `storage_encrypted: false`
entries in every environment block (lines ~287/510/728/946/1164 at baseline) —
i.e. some RDS/Aurora declarations explicitly opt out of encryption, including
in stg. Scored PARTIAL in `docs/preprod/COVERAGE_MATRIX.md`.
**Fix lands in:** G5 (compliance overlay forces encryption keys); scoring
visibility in G1 (Encryption category).

## 7. Coverage gaps confirmed absent everywhere (both clouds)

From `docs/preprod/COVERAGE_MATRIX.md`: egress inspection, backup stacks,
budgets/cost controls, and data-perimeter controls are ABSENT in every
column; GCP org-policy guardrails are ABSENT entirely.
**Fix lands in:** G3 (AWS), G4 (GCP).

## 8. tflint sweep

`make lint` recurses every `*.tf` directory — including `.terragrunt-cache`
copies, so runtime and findings are inflated by cached module clones (the
baseline sweep took ~5 minutes). The archived tail (`evidence/G0/lint.log`,
local-only) shows only fixable `terraform_unused_declarations` warnings
(e.g. unused `environment`, `routes`, `credentials_path` variables in
`terraform-google-vpn`) and no errors in the captured output. Caveat: the
Makefile loop `(cd "$dir" && tflint);` discards per-directory exit codes, so
the target's exit 0 does **not** prove zero lint errors across the sweep.
**Fix lands in:** G2 (lint scoped to source dirs, cache excluded, exit codes
propagated).

## 9. Upstream GCP module versions captured

`scripts/check-module-versions.sh` ran clean; the full local-module →
upstream-module version table is archived in
`evidence/G0/module-versions.log` (local-only). Notables for later gates:
`kubernetes-engine` 31.1.0, `project-factory` 15.0.1, `kms` 2.3.0 (used only
inside `terraform-google-projects`), `sql-db` 21.0.0.
