# CI Identity — OIDC Federation (G2-2)

The `terragrunt-validate-stg` / `terragrunt-plan-stg` jobs authenticate via
**OIDC federation only** — no long-lived cloud credentials are stored in
GitHub. This document specifies what an operator must create; per plan the
agent never creates IAM. Until these exist, both jobs run
`continue-on-error: true` (see `evidence/G2/GATE_ACTIVATION.md`).

Controls: PCI-DSS 8.6 (no shared static secrets), SOC2 CC6.1, CIS 1.x.

## AWS — `github-oidc-preprod-plan` role

Create in the account owning the Terraform state bucket
(`cloudon-aws-admin-tf-state-010`) with this trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "arn:aws:iam::PLACEHOLDER_ACCOUNT_ID_ADMIN:oidc-provider/token.actions.githubusercontent.com" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
      "StringLike": { "token.actions.githubusercontent.com:sub": "repo:cloudon-one/multi-cloud-runway:*" }
    }
  }]
}
```

Permissions: **read-only** — `ReadOnlyAccess` managed policy plus
`s3:GetObject/ListBucket` on the state bucket, `dynamodb:GetItem/PutItem/DeleteItem`
on the lock table (`cloudon-aws-admin-tf-locks`; lock writes are required even
for plan). Explicitly deny everything mutating outside the lock table.

Then set the repo Actions variable `AWS_OIDC_PLAN_ROLE_ARN` to the role ARN.

## GCP — Workload Identity Federation

```
gcloud iam workload-identity-pools create github --location=global --project=PLACEHOLDER_PROJECT_ID_ADMIN
gcloud iam workload-identity-pools providers create-oidc github-actions \
  --location=global --workload-identity-pool=github \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="assertion.repository=='cloudon-one/multi-cloud-runway'" \
  --project=PLACEHOLDER_PROJECT_ID_ADMIN
```

Service account `github-preprod-plan@PLACEHOLDER_PROJECT_ID_ADMIN.iam.gserviceaccount.com`
with `roles/viewer` on the stg folder and `roles/storage.objectViewer` +
`roles/storage.objectCreator` (lock/state prefix only) on the state buckets
(`cloudon-one-admin-tf-state-stg-eu`, ...). Bind the pool principal:

```
gcloud iam service-accounts add-iam-policy-binding github-preprod-plan@PLACEHOLDER_PROJECT_ID_ADMIN.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/PLACEHOLDER_PROJECT_NUMBER_ADMIN/locations/global/workloadIdentityPools/github/attribute.repository/cloudon-one/multi-cloud-runway"
```

Then set repo Actions variables `GCP_WIF_PROVIDER`
(`projects/PLACEHOLDER_PROJECT_NUMBER_ADMIN/locations/global/workloadIdentityPools/github/providers/github-actions`)
and `GCP_WIF_SERVICE_ACCOUNT`.

## Verification (after creation)

1. Re-run the `Pre-Production Gates` workflow (`workflow_dispatch`).
2. `terragrunt-validate-stg` and `terragrunt-plan-stg` must go green.
3. Flip both jobs' `continue-on-error` to `false` and record the commit in
   `evidence/G2/GATE_ACTIVATION.md`.
