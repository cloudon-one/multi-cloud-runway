#!/usr/bin/env python3
"""G4-15: plan guard — forbid destroys of foundational resources.

Scans plan JSON files (default: plans/*.json, as produced by
`make preprod-plan`) and fails if any resource of a protected kind carries a
"delete" action. A plan that destroys a project, folder, keyring, VPC, or TGW
is an automatic gate failure (plan failure-handling table).

Usage:
  python3 scripts/plan-guard.py [--plans-dir plans] [--no-destroy-kinds]

Controls: SOC2 CC8.1 (change control), PCI-DSS 6.5.x.
"""

import argparse
import json
import sys
from pathlib import Path

PROTECTED_KINDS = [
    "google_project",
    "google_folder",
    "google_kms_key_ring",
    "google_kms_crypto_key",
    "aws_vpc",
    "aws_ec2_transit_gateway",
    "aws_organizations_organizational_unit",
]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--plans-dir", default="plans")
    ap.add_argument("--no-destroy-kinds", action="store_true",
                    help="(default behavior; flag kept for the plan's canonical invocation)")
    args = ap.parse_args()

    plans_dir = Path(args.plans_dir)
    plan_files = sorted(plans_dir.glob("*.json")) if plans_dir.is_dir() else []
    if not plan_files:
        print(f"plan-guard: no plan JSON found under {plans_dir}/ — nothing to check "
              "(run make preprod-plan first)")
        return 0

    violations = []
    for pf in plan_files:
        try:
            plan = json.loads(pf.read_text(encoding="utf-8"))
        except ValueError as e:
            violations.append(f"{pf.name}: unreadable plan JSON ({e})")
            continue
        for rc in plan.get("resource_changes", []) or []:
            actions = (rc.get("change") or {}).get("actions") or []
            if "delete" in actions and rc.get("type") in PROTECTED_KINDS:
                violations.append(
                    f"{pf.name}: {rc['type']}.{rc.get('name')} ({rc.get('address')}) "
                    f"actions={actions}")

    if violations:
        print(f"plan-guard: {len(violations)} protected-resource deletions:",
              file=sys.stderr)
        for v in violations:
            print(f"  FAIL: {v}", file=sys.stderr)
        return 1
    print(f"plan-guard: OK — {len(plan_files)} plans, no protected-kind deletions")
    return 0


if __name__ == "__main__":
    sys.exit(main())
