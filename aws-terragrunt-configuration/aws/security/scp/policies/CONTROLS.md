# SCP Control Mapping (GR-6 sidecar)

JSON cannot carry header comments, so each policy's control mapping lives here
and in its statement `Sid`s. Every policy MUST have ≥ 3 passing fixture cases
in `scripts/fixtures/scp-cases.yaml` (enforced by `scripts/validate-scp.py`;
SCPs without cases fail the gate — G3-15).

| Policy file | Purpose | Controls | Attached to (G3-16) |
|---|---|---|---|
| `protect-security-services.json` | Deny disabling CloudTrail / Config / GuardDuty / Security Hub / Access Analyzer (break-glass + security-admin exempt) | PCI-DSS 10.1, 11.5; CIS 3.1/3.5/3.14; SOC2 CC7.1 | stg OU (`PLACEHOLDER_OU_ID_STG`) |
| `require-imdsv2.json` | Deny RunInstances without IMDSv2; deny metadata downgrade | CIS 5.2.5; PCI-DSS 7.1 | stg OU |
| `region-restriction.json` | Deny outside us-east-2 / eu-west-2; NotAction for global services | PCI-DSS 12.1; CIS 1.7; SOC2 CC6.6 | stg OU |
| `quarantine.json` | Deny-all except break-glass / security-admin / service-linked roles. **Unattached by default** — attach to a compromised account only | SOC2 CC6.2; PCI-DSS 12.10 (incident response) | none (target_ids: []) |
| `deny-root.json` | Deny all actions by account root principals | CIS 1.1; PCI-DSS 8.1; SOC2 CC6.1 | stg OU |
| `guardrails-sandbox.json` | Non-prod instance-type and volume-size caps | SOC2 CC3.4 (cost guardrail) | stg OU |

Pre-existing policies (`dev.json`, `dev_infra.json`, `global.json`, `prod.json`,
`prod_infra.json`) predate this mapping; they are unchanged by G3 (prod-scoped
entries are read-only per GR-3).

Prod OU attachment of the new library is deliberately deferred —
`docs/preprod/DEFERRED_PROD_CHANGES.md` entry 3.
