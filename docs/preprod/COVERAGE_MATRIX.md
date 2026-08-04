# Coverage Matrix (G0-3)

Control-family x environment coverage, derived mechanically from stack
presence and `vars.yaml` keys by `scripts/coverage-matrix.py`. **This is
the plan's source of truth for what is missing.** Regenerate with
`python3 scripts/coverage-matrix.py`; do not hand-edit.

Legend: PRESENT = control deployed and env-scoped; PARTIAL = something
exists but is incomplete or unverified at content level; ABSENT = no
implementing artifact in the repo.

| Control family | aws/us/dev | aws/us/stg | aws/eu/stg | gcp/stg/eu | gcp/stg/us |
|---|---|---|---|---|---|
| network isolation | PRESENT | PRESENT | PRESENT | PRESENT | ABSENT |
| egress inspection | ABSENT | ABSENT | ABSENT | ABSENT | ABSENT |
| encryption/CMEK | PARTIAL | PARTIAL | PARTIAL | PARTIAL | ABSENT |
| org guardrails | PARTIAL | PARTIAL | PARTIAL | ABSENT | ABSENT |
| audit logging | PARTIAL | PARTIAL | PARTIAL | PRESENT | ABSENT |
| backup | ABSENT | ABSENT | ABSENT | PARTIAL | ABSENT |
| cost | ABSENT | ABSENT | ABSENT | ABSENT | ABSENT |
| data perimeter | ABSENT | ABSENT | ABSENT | ABSENT | ABSENT |
| identity | PARTIAL | PARTIAL | PARTIAL | PARTIAL | ABSENT |

## Evidence per cell

### aws/us/dev

| Control family | Status | Evidence |
|---|---|---|
| network isolation | PRESENT | aws-terragrunt-configuration/aws/vpc/us/dev (vpc=yes), aws-terragrunt-configuration/aws/network/tgw (tgw=yes); no dedicated route-domain segregation stack |
| egress inspection | ABSENT | no aws-terragrunt-configuration/aws/network/inspection or /firewall stack; spokes egress via local NAT/IGW |
| encryption/CMEK | PARTIAL | aws vars.yaml Environments.us-dev: encrypted=['rds'] unencrypted=['aurora'] undeclared=['dynamodb', 'redis', 's3'] |
| org guardrails | PARTIAL | aws-terragrunt-configuration/aws/security/scp exists (org-scope, small policy set); no tag policy, no IMDSv2/region guardrails |
| audit logging | PARTIAL | aws-terragrunt-configuration/aws/cloudtrail exists (org trail); no Config/GuardDuty/SecurityHub stacks despite README claims |
| backup | ABSENT | no aws-terragrunt-configuration/aws/backup stack; no org backup policy |
| cost | ABSENT | no aws-terragrunt-configuration/aws/budgets stack; no budget keys in vars.yaml |
| data perimeter | ABSENT | no resource-policy perimeter (no S3/VPC endpoint policy stacks, no access-analyzer) |
| identity | PARTIAL | aws-terragrunt-configuration/aws/iam/* stacks exist (org-scope); wildcard/action hygiene unverified until G1 scoring |

### aws/us/stg

| Control family | Status | Evidence |
|---|---|---|
| network isolation | PRESENT | aws-terragrunt-configuration/aws/vpc/us/stg (vpc=yes), aws-terragrunt-configuration/aws/network/tgw (tgw=yes); no dedicated route-domain segregation stack |
| egress inspection | ABSENT | no aws-terragrunt-configuration/aws/network/inspection or /firewall stack; spokes egress via local NAT/IGW |
| encryption/CMEK | PARTIAL | aws vars.yaml Environments.us-stg: encrypted=['rds'] unencrypted=['aurora'] undeclared=['dynamodb', 'redis', 's3'] |
| org guardrails | PARTIAL | aws-terragrunt-configuration/aws/security/scp exists (org-scope, small policy set); no tag policy, no IMDSv2/region guardrails |
| audit logging | PARTIAL | aws-terragrunt-configuration/aws/cloudtrail exists (org trail); no Config/GuardDuty/SecurityHub stacks despite README claims |
| backup | ABSENT | no aws-terragrunt-configuration/aws/backup stack; no org backup policy |
| cost | ABSENT | no aws-terragrunt-configuration/aws/budgets stack; no budget keys in vars.yaml |
| data perimeter | ABSENT | no resource-policy perimeter (no S3/VPC endpoint policy stacks, no access-analyzer) |
| identity | PARTIAL | aws-terragrunt-configuration/aws/iam/* stacks exist (org-scope); wildcard/action hygiene unverified until G1 scoring |

### aws/eu/stg

| Control family | Status | Evidence |
|---|---|---|
| network isolation | PRESENT | aws-terragrunt-configuration/aws/vpc/eu/stg (vpc=yes), aws-terragrunt-configuration/aws/network/tgw (tgw=yes); no dedicated route-domain segregation stack |
| egress inspection | ABSENT | no aws-terragrunt-configuration/aws/network/inspection or /firewall stack; spokes egress via local NAT/IGW |
| encryption/CMEK | PARTIAL | aws vars.yaml Environments.eu-stg: encrypted=['rds'] unencrypted=['aurora'] undeclared=['dynamodb', 'redis', 's3'] |
| org guardrails | PARTIAL | aws-terragrunt-configuration/aws/security/scp exists (org-scope, small policy set); no tag policy, no IMDSv2/region guardrails |
| audit logging | PARTIAL | aws-terragrunt-configuration/aws/cloudtrail exists (org trail); no Config/GuardDuty/SecurityHub stacks despite README claims |
| backup | ABSENT | no aws-terragrunt-configuration/aws/backup stack; no org backup policy |
| cost | ABSENT | no aws-terragrunt-configuration/aws/budgets stack; no budget keys in vars.yaml |
| data perimeter | ABSENT | no resource-policy perimeter (no S3/VPC endpoint policy stacks, no access-analyzer) |
| identity | PARTIAL | aws-terragrunt-configuration/aws/iam/* stacks exist (org-scope); wildcard/action hygiene unverified until G1 scoring |

### gcp/stg/eu

| Control family | Status | Evidence |
|---|---|---|
| network isolation | PRESENT | gcp-terragrunt-configuration/terragrunt/envs/stg/eu/net-vpc (=yes), gcp-terragrunt-configuration/terragrunt/envs/stg/eu/net-firewalls (=yes) |
| egress inspection | ABSENT | gcp-terragrunt-configuration/terragrunt/envs/stg/eu/net-firewalls provides distributed rules only; no centralized inspection/NGFW path |
| encryption/CMEK | PARTIAL | vars.yaml envs.stg.eu: database_encryption=True, kms refs=False; no repo-wide KMS stack, no service_encryption_key_ids wiring |
| org guardrails | ABSENT | no gcp-terragrunt-configuration/terragrunt/envs/global/org-policies stack; no org policy constraints declared anywhere |
| audit logging | PRESENT | gcp-terragrunt-configuration/terragrunt/envs/global/audit exists (org-level sink) |
| backup | PARTIAL | vars.yaml envs.stg.eu: SQL backup/retention keys=yes; no GKE/GCS backup, no backup plans |
| cost | ABSENT | vars.yaml envs.stg.eu: budget keys=no; no billing budget stack |
| data perimeter | ABSENT | no gcp-terragrunt-configuration/terragrunt/envs/global/vpcsc stack; no service perimeter (even dry-run) |
| identity | PARTIAL | gcp-terragrunt-configuration/terragrunt/envs/global/iam exists; workload_identity_iam in env vars=yes; no SA-key-creation guardrail (needs org policy) |

### gcp/stg/us

| Control family | Status | Evidence |
|---|---|---|
| network isolation | ABSENT | envs/stg/us does not exist in the repo |
| egress inspection | ABSENT | envs/stg/us does not exist in the repo |
| encryption/CMEK | ABSENT | envs/stg/us does not exist in the repo |
| org guardrails | ABSENT | envs/stg/us does not exist in the repo |
| audit logging | ABSENT | envs/stg/us does not exist in the repo |
| backup | ABSENT | envs/stg/us does not exist in the repo |
| cost | ABSENT | envs/stg/us does not exist in the repo |
| data perimeter | ABSENT | envs/stg/us does not exist in the repo |
| identity | ABSENT | envs/stg/us does not exist in the repo |

## Notes

- `gcp/stg/us` is entirely absent: the repo has no `envs/stg/us` tree
  (GCP stg exists only as `envs/stg/eu`). The plan's G4 scope must either
  create it or formally descope it.
- AWS org-scope stacks (scp, cloudtrail, iam) cover every column but are
  not env-scoped; they are scored PARTIAL pending content checks in G1.
- README claims GuardDuty; no GuardDuty stack exists (G3-7 closes this).

