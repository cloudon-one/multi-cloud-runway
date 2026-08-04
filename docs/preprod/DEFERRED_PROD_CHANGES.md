# Deferred Prod Changes (GR-3)

Changes this plan identified as necessary or advisable in `prod` / `shrd/prod`
trees, which are **read-only for the entire plan**. Each entry needs an owner
and a decision before or during prod promotion (G7 consumes this file).

| # | Found in | Change | Impact of not fixing | Found by |
|---|---|---|---|---|
| 1 | G1 (input assertions) | Fix typo `enable_network_egress_expoert` → `enable_network_egress_export` in `gcp-terragrunt-configuration/terragrunt/vars.yaml` under `envs.prod.us.resources.svc-gke.inputs` and `envs.prod.eu.resources.svc-gke.inputs` | The misspelled input is silently dropped by Terraform, so **GKE network egress export is OFF in both prod regions** while the vars declare intent to enable it | `scripts/input-assertions.py` L2 |
| 2 | G1 (input assertions) | Decide fate of `svc-iam-permissions` blocks declared for `envs.prod.us`, `envs.prod.eu`, `envs.shrd.prod` (and `net-iam-permissions` in `shrd.prod`): deploy the corresponding stacks or delete the blocks | Declared IAM permission sets are not actually applied — prod IAM posture differs from what vars.yaml suggests | `scripts/input-assertions.py` L1 |
| 3 | G0/G3 (planned) | SCP attachment to the prod OU (G3-16 applies SCPs to stg OU only) | Prod OU lacks the new guardrail library until separately attached | plan GR-3 / G3-16 |
| 4 | G3 (SCP audit) | `aws/security/scp/policies/prod_infra.json` is a **0-byte file** attached to the prod-infra OU ("prod-infra-protection") — the declared prod guardrail is hollow and the stack would fail at apply | Prod infra OU has no actual SCP protection despite vars.yaml claiming it | `scripts/validate-scp.py` |
