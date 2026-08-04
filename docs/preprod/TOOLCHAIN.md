# Toolchain Baseline (G0-1)

Resolved tool versions on the execution host at G0 baseline time.
Generated during Gate G0 of the pre-production readiness plan. Re-verify with
`make verify-setup` after any tool upgrade.

Baseline date: 2026-08-04 (UTC)

| Tool | Resolved version | Path | Status |
|---|---|---|---|
| terragrunt | 1.1.2 | `/usr/local/bin/terragrunt` | OK |
| terraform | 1.15.5 | `/usr/local/bin/terraform` | OK |
| opentofu | 1.12.5 | `/usr/local/bin/tofu` | OK (not the active binary; terragrunt resolves `terraform`) |
| aws cli | 2.36.14 | `/usr/local/bin/aws` | OK |
| gcloud SDK | 553.0.0 | `~/google-cloud-sdk/bin/gcloud` | OK |
| tflint | 0.61.0 | `/usr/local/bin/tflint` | OK |
| tfsec | — | — | **NOT INSTALLED** (see KNOWN_FAILURES) |
| checkov | — | — | **NOT INSTALLED** (see KNOWN_FAILURES) |
| infracost | 2.14.1 | `/usr/local/bin/infracost` | OK |
| terraform-docs | — | — | **NOT INSTALLED** (see KNOWN_FAILURES) |
| pre-commit | — | — | **NOT INSTALLED** (see KNOWN_FAILURES) |
| python | 3.13.7 | `/usr/local/bin/python3` | OK (PyYAML 6.0.3 available) |
| git | 2.55.0 | system | OK |

## Terragrunt `run --all` syntax (GR-9 determination)

Installed Terragrunt is **v1.1.2** (≥ 0.78), so the modern explicit form is
supported and is the canonical form for this plan:

```
terragrunt run --all --non-interactive --working-dir <dir> -- plan
```

Notes:

- The legacy `terragrunt run-all plan --terragrunt-non-interactive` form still
  executes on v1.1.2 (the repo `Makefile` currently uses it) but is the
  deprecated spelling. New scripts and CI jobs introduced by this plan use
  `terragrunt run --all` with the renamed flags (`--non-interactive`,
  `--working-dir`).
- Repo commit `77c88c9` already aligned GCP configs with Terragrunt v1.0.0
  semantics.

## Minimum versions declared by the repo

Per `CLAUDE.md` / `Makefile` prerequisites: Terragrunt >= v0.70.0,
Terraform >= v1.5.0. The installed toolchain satisfies both.
