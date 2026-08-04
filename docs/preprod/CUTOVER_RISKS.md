# Cutover Risks (ordered)

Ordered register of changes that can break running workloads if applied out
of order. G7 promotion consumes this file.

| # | Change | Risk | Mitigation |
|---|---|---|---|
| 1 | **AWS stg egress cutover** (G3-5: spoke VPCs lose local NAT/IGW default route; `0.0.0.0/0` -> TGW -> inspection) | **Black-holes all stg egress** if applied before the inspection VPC, firewall, and TGW route domains are live and verified. Note the TGW vars already declare `0.0.0.0/0 blackhole: true` per attachment — removing the local default route with only that in place kills egress by design. | Strict ordering per `docs/RUNBOOKS/aws-egress-cutover.md`; one region at a time (us-stg first); rollback = restore per-VPC NAT route. Blocked today by MODULE_GAPS #1–#4. |
| 2 | SCP attachment of the new guardrail library to the stg OU (G3-16) | `region-restriction` or `require-imdsv2` can break existing automation that launches IMDSv1 instances or works in unlisted regions | Fixture cases prove intended semantics pre-apply; attach one policy at a time; quarantine stays unattached; `deny-root` is safe-by-construction. Resolve `PLACEHOLDER_OU_ID_STG` first (`make placeholder-gate` blocks apply). |
| 3 | GCP org-policy enforcement at stg folder (G4) | `iam.disableServiceAccountKeyCreation` / `vmExternalIpAccess` can break CI or workloads relying on SA keys / external IPs | Land dry-run first at org scope, enforce at stg folder only after violation logs are quiet (G4-3). |
| 4 | VPC-SC perimeter (G4) | Perimeter misconfig can cut GitHub CI, operators, and cross-project data flows | Dry-run spec only in this plan; promotion criteria in `docs/RUNBOOKS/vpcsc-dryrun-to-enforce.md`; enforcement out of scope. |
