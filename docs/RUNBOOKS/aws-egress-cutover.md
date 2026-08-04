# Runbook: AWS stg Egress Cutover (G3-6)

Move stg spoke egress from per-VPC NAT/IGW to centralized inspection
(inspection VPC + AWS Network Firewall via TGW). **Highest-risk change in the
pre-prod plan** — see `docs/preprod/CUTOVER_RISKS.md` #1.

Controls: PCI-DSS 1.2.1/1.3 (restrict outbound), CIS 3.8, SOC2 CC6.6.

## When to use

Only after MODULE_GAPS #1–#4 are closed, the inspection/firewall/tgw-routing
stacks have clean plans, `PLACEHOLDER_CIDR_INSPECTION_*` are resolved, and a
change window is approved. One region at a time; us-stg first.

## Prerequisites

- [ ] `make placeholder-gate` exits 0 (no unresolved tokens)
- [ ] Inspection VPC plan shows per-AZ: TGW subnet → firewall-endpoint subnet
      → NAT subnet → IGW; **appliance mode enabled** on the TGW attachment
- [ ] Firewall policy: `STRICT_ORDER`, default actions
      `aws:drop_established` + `aws:alert_established`, managed rule groups
      subscribed; flow + alert logs to CloudWatch
- [ ] TGW route domains: `inspection`, `spokes`, `regulated`; spokes propagate
      into inspection; `regulated` shares no route table with `spokes`
- [ ] Bastion or SSM session available inside the stg VPC for verification
- [ ] Rollback plan reviewed (below); on-call network engineer in the change

## Procedure (order is load-bearing)

1. **Apply inspection VPC** (`network/inspection/<region>/stg`). Verify NAT
   gateways healthy in every AZ.
2. **Apply firewall** (`network/firewall/<region>/stg`). Verify endpoint
   status `READY` per AZ:
   `aws network-firewall describe-firewall --firewall-name <name>`
3. **Apply TGW route domains** (`network/tgw-routing/<region>/stg`). Verify:
   spoke attachments associated with `spokes` table; `0.0.0.0/0` static route
   → inspection attachment; inspection table has routes back to spoke CIDRs.
4. **Cut one spoke** (`vpc/<region>/stg` with TGW default route enabled):
   remove local NAT default route, add `0.0.0.0/0` → TGW.
5. **Verify** (from a host in the spoke):
   - `curl -sS https://checkip.amazonaws.com` → returns an inspection-VPC NAT
     EIP (not the old spoke NAT EIP)
   - `aws ec2 describe-route-tables --filters Name=vpc-id,Values=<spoke-vpc>`
     → no route to a local NAT for `0.0.0.0/0`
   - Firewall flow logs show the test connection; alert log on a known-bad
     test domain (e.g. a rule-group canary)
   - Application smoke tests green
6. Repeat 4–5 for the remaining stg spokes, then the second region.

## Rollback

Single spoke: re-apply the previous vpc stack version (restore local NAT
default route; remove TGW default route). State is additive — no destroy of
the inspection path needed. Full rollback: revert the tgw-routing apply after
all spokes are restored.

## Escalation

Network on-call → platform lead. If egress is black-holed and rollback apply
fails, manual route fix via console/CLI:
`aws ec2 replace-route --route-table-id <rt> --destination-cidr-block 0.0.0.0/0 --nat-gateway-id <nat>`
(document any manual change for drift reconciliation the same day).
