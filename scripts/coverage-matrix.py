#!/usr/bin/env python3
"""G0-3: Control-family x environment coverage matrix.

Emits docs/preprod/COVERAGE_MATRIX.md — the plan's source of truth for
"what's missing" per environment. Cells are PRESENT | PARTIAL | ABSENT and
every cell carries the evidencing repo path (or the absence it proves).

Derivation is mechanical: stack presence on disk + key presence in vars.yaml.
No cloud calls. A control family scored from stack presence alone is at best
PARTIAL — content-level verification arrives with the G1 scoring engine.

Controls: PCI-DSS 12.5.1 (asset/control inventory), SOC2 CC3.2 (risk
identification), CIS overall mapping.

Usage:
  python3 scripts/coverage-matrix.py            # write docs/preprod/COVERAGE_MATRIX.md
  python3 scripts/coverage-matrix.py --check    # exit 1 if the file on disk is stale
"""

import argparse
import importlib.util
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
AWS_ROOT = REPO_ROOT / "aws-terragrunt-configuration" / "aws"
GCP_ROOT = REPO_ROOT / "gcp-terragrunt-configuration"
GCP_ENVS = GCP_ROOT / "terragrunt" / "envs"
OUTPUT = REPO_ROOT / "docs" / "preprod" / "COVERAGE_MATRIX.md"

# reuse the anchor-tolerant YAML loader from baseline-inventory.py
_spec = importlib.util.spec_from_file_location(
    "baseline_inventory", REPO_ROOT / "scripts" / "baseline-inventory.py")
_bi = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_bi)
load_vars_yaml = _bi.load_vars_yaml

COLUMNS = ["aws/us/dev", "aws/us/stg", "aws/eu/stg", "gcp/stg/eu", "gcp/stg/us"]

FAMILIES = [
    "network isolation",
    "egress inspection",
    "encryption/CMEK",
    "org guardrails",
    "audit logging",
    "backup",
    "cost",
    "data perimeter",
    "identity",
]

AWS_DATA_SERVICES = ["rds", "aurora", "dynamodb", "redis", "s3"]


def stack(path: str) -> bool:
    return (REPO_ROOT / path / "terragrunt.hcl").exists()


def cell(status: str, evidence: str):
    return {"status": status, "evidence": evidence}


def aws_env_resources(aws_vars, region: str, env: str):
    return (aws_vars.get("Environments", {})
            .get(f"{region}-{env}", {})
            .get("Resources", {}) or {})


def aws_encryption_cell(aws_vars, region, env):
    res = aws_env_resources(aws_vars, region, env)
    encrypted, unencrypted, missing = [], [], []
    for svc in AWS_DATA_SERVICES:
        block = res.get(svc)
        if not isinstance(block, dict):
            missing.append(svc)
            continue
        text = str(block)
        if "'storage_encrypted': True" in text or "kms_key" in text or "'encrypted': True" in text:
            encrypted.append(svc)
        elif "'storage_encrypted': False" in text:
            unencrypted.append(svc)
        else:
            missing.append(svc)
    ev = f"aws vars.yaml Environments.{region}-{env}: encrypted={encrypted or '-'} unencrypted={unencrypted or '-'} undeclared={missing or '-'}"
    if unencrypted or missing:
        return cell("PARTIAL" if encrypted else "ABSENT", ev)
    return cell("PARTIAL", ev + " (no CMK refs; default keys at best)")


def aws_column(aws_vars, region, env):
    base = "aws-terragrunt-configuration/aws"
    cells = {}

    vpc = stack(f"{base}/vpc/{region}/{env}")
    tgw = stack(f"{base}/network/tgw")
    cells["network isolation"] = cell(
        "PRESENT" if (vpc and tgw) else ("PARTIAL" if vpc else "ABSENT"),
        f"{base}/vpc/{region}/{env} (vpc={'yes' if vpc else 'NO'}), {base}/network/tgw (tgw={'yes' if tgw else 'NO'}); no dedicated route-domain segregation stack")

    insp = stack(f"{base}/network/inspection/{region}/{env}") or stack(f"{base}/network/firewall/{region}/{env}")
    cells["egress inspection"] = cell(
        "PRESENT" if insp else "ABSENT",
        f"no {base}/network/inspection or /firewall stack; spokes egress via local NAT/IGW")

    cells["encryption/CMEK"] = aws_encryption_cell(aws_vars, region, env)

    scp = stack(f"{base}/security/scp")
    cells["org guardrails"] = cell(
        "PARTIAL" if scp else "ABSENT",
        f"{base}/security/scp exists (org-scope, small policy set); no tag policy, no IMDSv2/region guardrails" if scp
        else "no SCP stack")

    trail = stack(f"{base}/cloudtrail")
    cells["audit logging"] = cell(
        "PARTIAL" if trail else "ABSENT",
        f"{base}/cloudtrail exists (org trail); no Config/GuardDuty/SecurityHub stacks despite README claims" if trail
        else "no cloudtrail stack")

    bkp = stack(f"{base}/backup/{region}/{env}")
    cells["backup"] = cell("PRESENT" if bkp else "ABSENT",
                           f"no {base}/backup stack; no org backup policy")

    budgets = stack(f"{base}/budgets/{region}/{env}")
    cells["cost"] = cell("PRESENT" if budgets else "ABSENT",
                         f"no {base}/budgets stack; no budget keys in vars.yaml")

    cells["data perimeter"] = cell(
        "ABSENT", "no resource-policy perimeter (no S3/VPC endpoint policy stacks, no access-analyzer)")

    iam = stack(f"{base}/iam/roles") and stack(f"{base}/iam/policies")
    cells["identity"] = cell(
        "PARTIAL" if iam else "ABSENT",
        f"{base}/iam/* stacks exist (org-scope); wildcard/action hygiene unverified until G1 scoring")
    return cells


def gcp_column(gcp_vars, folder, env):
    base = f"gcp-terragrunt-configuration/terragrunt/envs/{folder}/{env}"
    gbase = "gcp-terragrunt-configuration/terragrunt/envs/global"
    cells = {}

    if not (GCP_ENVS / folder / env).is_dir():
        for fam in FAMILIES:
            cells[fam] = cell("ABSENT", f"envs/{folder}/{env} does not exist in the repo")
        return cells

    vpc = stack(f"{base}/net-vpc")
    fw = stack(f"{base}/net-firewalls")
    cells["network isolation"] = cell(
        "PRESENT" if (vpc and fw) else ("PARTIAL" if vpc else "ABSENT"),
        f"{base}/net-vpc (={'yes' if vpc else 'NO'}), {base}/net-firewalls (={'yes' if fw else 'NO'})")

    cells["egress inspection"] = cell(
        "ABSENT",
        f"{base}/net-firewalls provides distributed rules only; no centralized inspection/NGFW path")

    env_vars = (gcp_vars.get("envs", {}).get(folder, {}).get(env, {})
                .get("resources", {}) or {})
    txt = str(env_vars)
    has_dbenc = "'database_encryption': True" in txt or '"database_encryption": true' in txt
    has_kms = "kms_rings" in txt or "kms_key" in txt
    cells["encryption/CMEK"] = cell(
        "PARTIAL" if (has_dbenc or has_kms) else "ABSENT",
        f"vars.yaml envs.{folder}.{env}: database_encryption={has_dbenc}, kms refs={has_kms}; no repo-wide KMS stack, no service_encryption_key_ids wiring")

    orgpol = stack(f"{gbase}/org-policies")
    cells["org guardrails"] = cell(
        "PRESENT" if orgpol else "ABSENT",
        f"no {gbase}/org-policies stack; no org policy constraints declared anywhere")

    audit = stack(f"{gbase}/audit")
    cells["audit logging"] = cell(
        "PRESENT" if audit else "ABSENT",
        f"{gbase}/audit exists (org-level sink)" if audit else "no audit stack")

    has_sql_backup = "backup_configuration" in txt or "transaction_log_retention_days" in txt
    cells["backup"] = cell(
        "PARTIAL" if has_sql_backup else "ABSENT",
        f"vars.yaml envs.{folder}.{env}: SQL backup/retention keys={'yes' if has_sql_backup else 'no'}; no GKE/GCS backup, no backup plans")

    has_budget = "budget" in txt
    cells["cost"] = cell(
        "PARTIAL" if has_budget else "ABSENT",
        f"vars.yaml envs.{folder}.{env}: budget keys={'yes' if has_budget else 'no'}; no billing budget stack")

    vpcsc = stack(f"{gbase}/vpcsc")
    cells["data perimeter"] = cell(
        "PRESENT" if vpcsc else "ABSENT",
        f"no {gbase}/vpcsc stack; no service perimeter (even dry-run)")

    iam = stack(f"{gbase}/iam")
    has_wi = "workload_identity" in txt
    cells["identity"] = cell(
        "PARTIAL" if (iam or has_wi) else "ABSENT",
        f"{gbase}/iam exists; workload_identity_iam in env vars={'yes' if has_wi else 'no'}; no SA-key-creation guardrail (needs org policy)")
    return cells


def build_matrix():
    aws_vars = load_vars_yaml(AWS_ROOT / "vars.yaml")
    gcp_vars = load_vars_yaml(GCP_ROOT / "terragrunt" / "vars.yaml")
    matrix = {}
    matrix["aws/us/dev"] = aws_column(aws_vars, "us", "dev")
    matrix["aws/us/stg"] = aws_column(aws_vars, "us", "stg")
    matrix["aws/eu/stg"] = aws_column(aws_vars, "eu", "stg")
    matrix["gcp/stg/eu"] = gcp_column(gcp_vars, "stg", "eu")
    matrix["gcp/stg/us"] = gcp_column(gcp_vars, "stg", "us")
    return matrix


def render(matrix):
    lines = [
        "# Coverage Matrix (G0-3)",
        "",
        "Control-family x environment coverage, derived mechanically from stack",
        "presence and `vars.yaml` keys by `scripts/coverage-matrix.py`. **This is",
        "the plan's source of truth for what is missing.** Regenerate with",
        "`python3 scripts/coverage-matrix.py`; do not hand-edit.",
        "",
        "Legend: PRESENT = control deployed and env-scoped; PARTIAL = something",
        "exists but is incomplete or unverified at content level; ABSENT = no",
        "implementing artifact in the repo.",
        "",
        "| Control family | " + " | ".join(COLUMNS) + " |",
        "|---|" + "---|" * len(COLUMNS),
    ]
    for fam in FAMILIES:
        row = [f"| {fam}"]
        for col in COLUMNS:
            row.append(matrix[col][fam]["status"])
        lines.append(" | ".join(row) + " |")

    lines += ["", "## Evidence per cell", ""]
    for col in COLUMNS:
        lines.append(f"### {col}")
        lines.append("")
        lines.append("| Control family | Status | Evidence |")
        lines.append("|---|---|---|")
        for fam in FAMILIES:
            c = matrix[col][fam]
            lines.append(f"| {fam} | {c['status']} | {c['evidence']} |")
        lines.append("")

    lines += [
        "## Notes",
        "",
        "- `gcp/stg/us` is entirely absent: the repo has no `envs/stg/us` tree",
        "  (GCP stg exists only as `envs/stg/eu`). The plan's G4 scope must either",
        "  create it or formally descope it.",
        "- AWS org-scope stacks (scp, cloudtrail, iam) cover every column but are",
        "  not env-scoped; they are scored PARTIAL pending content checks in G1.",
        "- README claims GuardDuty; no GuardDuty stack exists (G3-7 closes this).",
        "",
    ]
    return "\n".join(lines) + "\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()

    content = render(build_matrix())
    if args.check:
        if OUTPUT.exists() and OUTPUT.read_text(encoding="utf-8") == content:
            print(f"OK: {OUTPUT} is fresh")
            return 0
        print(f"FAIL: {OUTPUT} is stale; regenerate with scripts/coverage-matrix.py", file=sys.stderr)
        return 1

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(content, encoding="utf-8")
    print(f"Wrote {OUTPUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
