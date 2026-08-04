# Org Policy Enforcement Scope (G4-3)

Deployed by `envs/global/org-policies` (module
`tf-modules/terraform-google-org-policies`). Pattern: **dry-run at org scope,
enforcing at the stg folder** — org-wide observation without org-wide blast
radius. Prod/other folders inherit nothing enforcing from this plan.

| Constraint | Type | org (dry-run) | stg folder (enforcing) | Notes |
|---|---|---|---|---|
| compute.requireOsLogin | boolean | ✓ | ✓ | |
| compute.requireShieldedVm | boolean | ✓ | ✓ | |
| compute.disableSerialPortAccess | boolean | ✓ | ✓ | |
| compute.disableNestedVirtualization | boolean | ✓ | ✓ | |
| compute.vmExternalIpAccess | list | ✓ | ✓ | deny all |
| compute.skipDefaultNetworkCreation | boolean | ✓ | ✓ | |
| iam.disableServiceAccountKeyCreation | boolean | ✓ | ✓ | breaks SA-key workflows by design — see CUTOVER_RISKS #3 |
| iam.disableServiceAccountKeyUpload | boolean | ✓ | ✓ | |
| iam.allowedPolicyMemberDomains | list | ✓ | ✓ | allowed value = `PLACEHOLDER_GCP_DIRECTORY_CUSTOMER_ID` (directory customer ID, `gcloud organizations describe`) |
| sql.restrictPublicIp | boolean | ✓ | ✓ | |
| storage.publicAccessPrevention | boolean | ✓ | ✓ | |
| storage.uniformBucketLevelAccess | boolean | ✓ | ✓ | |
| gcp.resourceLocations | list | ✓ | ✓ | `in:europe-locations`, `in:us-locations` (repo regions: europe-west1, us-east1) |

Promotion of enforcement to other folders/org: separate change, after the
org-scope dry-run logs are quiet for the same constraint (same discipline as
VPC-SC — observe first, enforce second).
