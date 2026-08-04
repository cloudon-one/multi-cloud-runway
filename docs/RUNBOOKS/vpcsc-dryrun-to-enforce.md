# Runbook: VPC-SC Dry-Run → Enforcement (G4-7)

The stg perimeter (`envs/global/vpcsc`) is created with
`use_explicit_dry_run_spec = true` — violations are logged, never blocked.
**Enforcement is explicitly out of scope for the pre-prod plan**; this runbook
is the only sanctioned path to it.

Controls: PCI-DSS 1.3, SOC2 CC6.6, HIPAA 164.312(e)(1).

## When to use

After the perimeter has been applied in dry-run and the placeholders
(`PLACEHOLDER_PROJECT_NUMBER_STG_*`, `PLACEHOLDER_CORP_EGRESS_CIDR`,
identity placeholders) are resolved.

## Observation window: 2–4 weeks

Query dry-run violations in Cloud Logging (org-level Logs Explorer):

```
protoPayload.metadata.dryRun="true"
protoPayload.metadata.violationReason!=""
```

Useful groupings: by `protoPayload.authenticationInfo.principalEmail` (who),
`protoPayload.serviceName` (which API), `protoPayload.methodName` (what).
Export the query results weekly to the evidence dir (`evidence/G4/vpcsc-dryrun/`).

## Promotion criteria (all must hold)

1. ≥ 14 consecutive days of logs with **zero unexplained violations** —
   every remaining violation is either (a) a known-bad access you *want*
   blocked, or (b) fixed by an added ingress/egress rule or access level.
2. Every legitimate access path (CI, admin console, GKE control plane,
   artifact pulls, log export) appears in the logs as allowed or is covered
   by an explicit rule — absence of evidence is not evidence of coverage.
3. Change approved by security + platform owners; rollback rehearsed.

## Migration: spec → status

In `tf-modules/terraform-google-vpcsc`, the enforced configuration is the
`status` block of `google_access_context_manager_service_perimeter`. The
promotion change (its own PR, security-reviewed via CODEOWNERS):

1. Copy the (by-now stable) `spec { ... }` contents into a `status { ... }`
   block, set `use_explicit_dry_run_spec = false`, and remove the
   `lifecycle.ignore_changes = [status]` guard.
2. Plan must show **update in place** on the perimeter only — any
   create/destroy is a stop condition.
3. Apply in a change window with the rollback below ready.

## Rollback

Revert the promotion commit and re-apply: the perimeter returns to dry-run
(spec-only). API-level emergency rollback:
`gcloud access-context-manager perimeters update <perimeter> --clear-status`
(record any manual action for same-day drift reconciliation).

## Escalation

Security on-call → platform lead → org admin (Access Context Manager editor
role required).
