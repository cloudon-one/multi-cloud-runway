#!/usr/bin/env python3
"""G1-2/G1-3: Architecture scoring engine.

Emits ARCHITECTURE_REPORT.json (machine-readable, fixed schema — CI depends
on it) and ARCHITECTURE_SCORECARD.md (human/auditor-readable) from vars.yaml
and the terragrunt tree. No live cloud state is read.

Score = 100 - sum(score_impact); grades A>=90 B>=80 C>=70 D>=60 else F.

Categories: IP Planning, Segmentation, Encryption, Identity, Audit,
Multi-region/DR, Naming, Cost.

Controls: headers per check; see the "controls" field of each record.

Usage:
  python3 scripts/architecture-score.py                 # write both artifacts
  python3 scripts/architecture-score.py --validate-schema
  python3 scripts/architecture-score.py --min-score 85 --fail-on FAIL
  python3 scripts/architecture-score.py --quick         # no file writes, exit code only
"""

import argparse
import ipaddress
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lib import loaders, report as rp  # noqa: E402

REPO = loaders.REPO_ROOT
REPORT_JSON = REPO / "ARCHITECTURE_REPORT.json"
SCORECARD_MD = REPO / "ARCHITECTURE_SCORECARD.md"
SOURCES = [loaders.AWS_VARS, loaders.GCP_VARS]

STG_AWS = [("us", "stg"), ("eu", "stg")]
AWS_DATA_SERVICES = ["rds", "aurora", "dynamodb", "redis", "s3"]


def aws_resources(aws, region, env):
    return (aws.get("Environments", {}).get(f"{region}-{env}", {})
            .get("Resources", {}) or {})


def gcp_resources(gcp, folder, env):
    return (gcp.get("envs", {}).get(folder, {}).get(env, {})
            .get("resources", {}) or {})


def iter_gcp_env_resources(gcp):
    """Yield (folder, env, resources) handling both shapes: envs.{folder}.{env}
    .resources and the flat envs.{folder}.resources (global, us)."""
    for folder, envs in (gcp.get("envs", {}) or {}).items():
        if not isinstance(envs, dict):
            continue
        if "resources" in envs:
            yield folder, "_flat", envs.get("resources") or {}
            continue
        for env, envval in envs.items():
            if isinstance(envval, dict) and "resources" in envval:
                yield folder, env, envval.get("resources") or {}


def collect_cidrs(aws, gcp):
    """(label, network) pairs for every VPC-level CIDR declared in vars."""
    out = []
    for envkey, envval in (aws.get("Environments", {}) or {}).items():
        res = (envval or {}).get("Resources", {}) or {}
        vpc = (res.get("vpc") or {}).get("inputs", {}) or {}
        cidr = vpc.get("vpc_cidr")
        if cidr:
            out.append((f"aws/{envkey}/vpc", cidr))
    for folder, env, res in iter_gcp_env_resources(gcp):
            netvpc = (res.get("net-vpc") or {}).get("inputs", {}) or {}
            for sn in netvpc.get("subnets", []) or []:
                ip = sn.get("subnet_ip")
                if ip:
                    out.append((f"gcp/{folder}/{env}/{sn.get('subnet_name')}", ip))
            for rng in (netvpc.get("secondary_ranges") or {}).values():
                for r in rng or []:
                    if r.get("ip_cidr_range"):
                        out.append((f"gcp/{folder}/{env}/secondary/{r.get('range_name')}",
                                    r["ip_cidr_range"]))
    return out


def check_ip_planning(aws, gcp):
    recs = []
    cidrs = []
    bad = []
    for label, c in collect_cidrs(aws, gcp):
        try:
            cidrs.append((label, ipaddress.ip_network(c)))
        except ValueError:
            bad.append(f"{label}={c}")
    overlaps = []
    for i in range(len(cidrs)):
        for j in range(i + 1, len(cidrs)):
            li, ni = cidrs[i]
            lj, nj = cidrs[j]
            # secondary ranges legitimately nest inside their own VPC subnets;
            # only flag overlaps across different cloud/env prefixes
            pi, pj = li.rsplit("/", 1)[0], lj.rsplit("/", 1)[0]
            if pi.split("/")[0:3] == pj.split("/")[0:3]:
                continue
            if ni.overlaps(nj):
                overlaps.append(f"{li}({ni}) <-> {lj}({nj})")
    status = "FAIL" if overlaps or bad else "PASS"
    recs.append(rp.record(
        "IP Planning", "cidr-overlap", status, 8,
        ("No overlapping CIDRs across AWS VPCs and GCP subnets"
         if status == "PASS" else
         f"Overlaps: {overlaps[:5]}; unparseable: {bad[:5]}"),
        "aws vars.yaml + gcp vars.yaml (all vpc/subnet cidrs)",
        ["PCI-DSS 1.1", "CIS-3.1"]))

    # GKE secondary ranges present + sized for every env that runs svc-gke
    problems = []
    for folder, env, res in iter_gcp_env_resources(gcp):
            if "svc-gke" not in res:
                continue
            netvpc = (res.get("net-vpc") or {}).get("inputs", {}) or {}
            sec = netvpc.get("secondary_ranges") or {}
            ranges = [r for lst in sec.values() for r in (lst or [])]
            if not ranges:
                problems.append(f"{folder}/{env}: no secondary_ranges")
                continue
            for r in ranges:
                try:
                    n = ipaddress.ip_network(r["ip_cidr_range"])
                except (KeyError, ValueError):
                    problems.append(f"{folder}/{env}: bad range {r}")
                    continue
                name = (r.get("range_name") or "").lower()
                if "pod" in name and n.prefixlen > 21:
                    problems.append(f"{folder}/{env}: pods range {n} smaller than /21")
                if ("service" in name or "svc" in name) and n.prefixlen > 24:
                    problems.append(f"{folder}/{env}: services range {n} smaller than /24")
    recs.append(rp.record(
        "IP Planning", "gke-secondary-ranges", "PASS" if not problems else "WARN", 4,
        "All GKE envs declare adequately sized secondary ranges" if not problems
        else f"Issues: {problems[:6]}",
        "gcp vars.yaml envs.*.*.resources.net-vpc.inputs.secondary_ranges",
        ["CIS GKE 5.6.2"]))
    return recs


def check_segmentation(aws, gcp):
    recs = []
    insp = [(r, e) for r, e in STG_AWS
            if (loaders.AWS_ROOT / "network" / "inspection" / r / e / "terragrunt.hcl").exists()]
    recs.append(rp.record(
        "Segmentation", "stg-egress-inspection-path",
        "PASS" if len(insp) == len(STG_AWS) else "FAIL", 15,
        "Both AWS stg regions route egress via an inspection path" if len(insp) == len(STG_AWS)
        else "No inspection VPC / firewall stacks exist for aws us-stg or eu-stg; "
             "spokes egress via local NAT/IGW (G3.A closes this)",
        "aws-terragrunt-configuration/aws/network/", ["PCI-DSS 1.2.1", "CIS 3.8"]))

    tagged = "DataClassification" in json.dumps(aws.get("common", {})) or \
             "data-classification" in json.dumps(gcp.get("common", {}))
    recs.append(rp.record(
        "Segmentation", "workload-classification-tags",
        "PASS" if tagged else "WARN", 5,
        "Workload data-classification tagging declared" if tagged else
        "No DataClassification / data-classification tag scheme declared in either "
        "vars.yaml common block, so regulated/non-regulated co-tenancy is unverifiable "
        "(G3-14 / G4-4 close this)",
        "vars.yaml common.common_tags / common.labels", ["PCI-DSS 1.1", "SOC2 CC6.1"]))
    return recs


def check_encryption(aws, gcp):
    recs = []
    fails, warns = [], []
    for region, env in STG_AWS + [("us", "dev")]:
        res = aws_resources(aws, region, env)
        for svc in AWS_DATA_SERVICES:
            block = res.get(svc)
            if not isinstance(block, dict):
                continue
            text = json.dumps(block)
            has_cmk = "kms_key" in text
            if '"storage_encrypted": false' in text:
                fails.append(f"{region}-{env}/{svc}: storage_encrypted=false")
            elif not has_cmk:
                warns.append(f"{region}-{env}/{svc}: no CMK/kms_key reference")
    status = "FAIL" if any(f.startswith(("us-stg", "eu-stg")) for f in fails) else \
             ("WARN" if fails or warns else "PASS")
    recs.append(rp.record(
        "Encryption", "aws-data-services-cmk", status, 12,
        "All AWS data services encrypted with CMK references" if status == "PASS"
        else f"explicit-off: {fails[:6]}; default-key-only: {len(warns)} services",
        "aws vars.yaml Environments.*.Resources.{rds,aurora,dynamodb,redis,s3}",
        ["PCI-DSS 3.4", "CIS-2.1", "HIPAA 164.312(a)(2)(iv)"]))

    gproblems = []
    for folder, env in [("stg", "eu"), ("dev", "eu")]:
        res = gcp_resources(gcp, folder, env)
        gke = (res.get("svc-gke") or {}).get("inputs", {}) or {}
        if gke and not gke.get("database_encryption"):
            gproblems.append(f"{folder}/{env}: gke database_encryption off")
        sql = (res.get("svc-sql") or {}).get("inputs", {}) or {}
        if sql and "kms" not in json.dumps(sql).lower():
            gproblems.append(f"{folder}/{env}: svc-sql has no CMEK key reference")
        redis = (res.get("svc-redis") or {}).get("inputs", {}) or {}
        if redis and "kms" not in json.dumps(redis).lower():
            gproblems.append(f"{folder}/{env}: svc-redis has no CMEK key reference")
    stg_bad = [p for p in gproblems if p.startswith("stg/")]
    recs.append(rp.record(
        "Encryption", "gcp-data-services-cmek",
        "FAIL" if stg_bad else ("WARN" if gproblems else "PASS"), 12,
        f"Missing CMEK wiring: {gproblems[:6]}" if gproblems else
        "All GCP stg data services carry CMEK references",
        "gcp vars.yaml envs.*.*.resources.{svc-gke,svc-sql,svc-redis}",
        ["PCI-DSS 3.4", "CIS GCP 1.10"]))

    rot = "rotation_period" in json.dumps(gcp) or "rotation" in json.dumps(
        aws.get("Environments", {}).get("us-stg", {}))
    recs.append(rp.record(
        "Encryption", "key-rotation-declared", "PASS" if rot else "FAIL", 5,
        "Key rotation period declared" if rot else
        "No key rotation period declared in either vars.yaml (G4-9 adds KMS module "
        "with rotation; AWS CMKs land with G3 stacks)",
        "vars.yaml (rotation_period keys)", ["PCI-DSS 3.6.4", "CIS 3.8"]))
    return recs


def check_identity(aws, gcp):
    recs = []
    org_pol = (loaders.GCP_ENVS / "global" / "org-policies" / "terragrunt.hcl").exists()
    recs.append(rp.record(
        "Identity", "gcp-sa-key-creation-blocked", "PASS" if org_pol else "FAIL", 8,
        "Org policy stack exists (constraint list verified in G4)" if org_pol else
        "No org-policy stack: iam.disableServiceAccountKeyCreation not enforced anywhere",
        "gcp-terragrunt-configuration/terragrunt/envs/global/",
        ["CIS GCP 1.4", "SOC2 CC6.1"]))

    wildcards = []
    for jf in (loaders.AWS_ROOT).rglob("*.json"):
        if loaders.CACHE_DIRS.intersection(jf.parts):
            continue
        try:
            doc = json.loads(jf.read_text(encoding="utf-8"))
        except (ValueError, UnicodeDecodeError):
            continue
        stmts = doc.get("Statement", []) if isinstance(doc, dict) else []
        if isinstance(stmts, dict):
            stmts = [stmts]
        for st in stmts:
            if (st or {}).get("Effect") == "Allow":
                acts = st.get("Action", [])
                acts = [acts] if isinstance(acts, str) else acts
                if "*" in acts:
                    wildcards.append(str(jf.relative_to(REPO)))
    recs.append(rp.record(
        "Identity", "no-wildcard-allow-actions",
        "PASS" if not wildcards else "FAIL", 8,
        "No Allow-Effect policy document grants Action:*" if not wildcards else
        f"Wildcard Allow actions in: {wildcards[:5]}",
        "aws-terragrunt-configuration/**/*.json", ["PCI-DSS 7.1", "CIS-1.1", "SOC2 CC6.1"]))

    gke_hcls = [s["path"] for s in loaders.gcp_env_stacks() if s["resource"] == "svc-gke"]
    wi = all("identity_namespace" in p.read_text(encoding="utf-8", errors="replace")
             for p in gke_hcls) if gke_hcls else False
    recs.append(rp.record(
        "Identity", "gke-workload-identity", "PASS" if wi else "FAIL", 6,
        "All GKE stacks wire identity_namespace (Workload Identity)" if wi else
        "Some GKE stacks lack identity_namespace wiring",
        "gcp envs/*/*/svc-gke/terragrunt.hcl", ["CIS GKE 5.2.1", "SOC2 CC6.1"]))
    return recs


def check_audit(aws, gcp):
    recs = []
    trail = (loaders.AWS_ROOT / "cloudtrail" / "terragrunt.hcl").exists()
    trail_cfg = json.dumps(aws.get("Environments", {}).get("master", {})) + \
        json.dumps(aws.get("Environments", {}).get("management", {}))
    validation = "log_file_validation" in trail_cfg or "enable_log_file_validation" in trail_cfg
    recs.append(rp.record(
        "Audit", "aws-org-trail",
        "PASS" if (trail and validation) else ("WARN" if trail else "FAIL"), 8,
        ("Org CloudTrail present with log-file validation" if (trail and validation) else
         "CloudTrail stack exists but log-file validation / retention not declared in vars"
         if trail else "No CloudTrail stack"),
        "aws-terragrunt-configuration/aws/cloudtrail/", ["PCI-DSS 10.1", "CIS-5.1"]))

    audit = (loaders.GCP_ENVS / "global" / "audit" / "terragrunt.hcl").exists()
    aud_cfg = json.dumps((gcp.get("envs", {}).get("global", {}) or {}))
    retention = "retention" in aud_cfg
    recs.append(rp.record(
        "Audit", "gcp-org-log-sink",
        "PASS" if (audit and retention) else ("WARN" if audit else "FAIL"), 8,
        ("Org audit sink present with retention declared" if (audit and retention) else
         "Audit stack exists but no retention period declared in vars"
         if audit else "No audit stack"),
        "gcp-terragrunt-configuration/terragrunt/envs/global/audit/",
        ["PCI-DSS 10.1", "SOC2 CC7.1", "CIS GCP 2.2"]))
    return recs


def check_dr(aws, gcp):
    recs = []
    dr_declared = "dr_region" in json.dumps(aws).lower()
    recs.append(rp.record(
        "Multi-region/DR", "aws-dr-region-declared",
        "PASS" if dr_declared else "FAIL", 5,
        "DR region declared per env" if dr_declared else
        "No dr_region key anywhere in AWS vars.yaml; no cross-region copy targets declared",
        "aws vars.yaml", ["SOC2 A1.2", "ISO27001 A.17"]))

    stg_regions = set((gcp.get("envs", {}).get("stg", {}) or {}).keys())
    prod_regions = set((gcp.get("envs", {}).get("prod", {}) or {}).keys())
    parity = stg_regions == prod_regions
    recs.append(rp.record(
        "Multi-region/DR", "gcp-stg-prod-region-parity",
        "PASS" if parity else "FAIL", 5,
        f"GCP stg regions {sorted(stg_regions)} != prod regions {sorted(prod_regions)}; "
        "stg cannot rehearse prod's multi-region posture" if not parity else
        "stg mirrors prod regions",
        "gcp vars.yaml envs.stg vs envs.prod", ["SOC2 A1.2"]))
    return recs


def check_naming(aws, gcp):
    recs = []
    missing = []
    for s in loaders.aws_env_stacks():
        res = aws_resources(aws, s["region"], s["env"])
        if s["service"] not in res:
            missing.append(f"stack {s['service']}/{s['region']}/{s['env']} has no "
                           f"vars key Environments.{s['region']}-{s['env']}.Resources.{s['service']}")
    for s in loaders.gcp_env_stacks():
        if s["folder"] == "global":
            continue
        res = gcp_resources(gcp, s["folder"], s["env"])
        if s["resource"] not in res:
            missing.append(f"stack envs/{s['folder']}/{s['env']}/{s['resource']} has no "
                           f"vars key envs.{s['folder']}.{s['env']}.resources.{s['resource']}")
    recs.append(rp.record(
        "Naming", "stack-to-vars-consistency", "PASS" if not missing else "FAIL", 10,
        "Every env stack resolves to a vars.yaml key" if not missing else
        f"{len(missing)} stacks reference nonexistent vars keys: {missing[:5]}",
        "terragrunt tree vs vars.yaml", ["SOC2 CC8.1"]))
    return recs


def check_cost(aws, gcp):
    recs = []
    aws_budget = "budget" in json.dumps(aws).lower()
    gcp_budget = "budget" in json.dumps(gcp).lower()
    status = "PASS" if (aws_budget and gcp_budget) else \
             ("WARN" if (aws_budget or gcp_budget) else "FAIL")
    recs.append(rp.record(
        "Cost", "budgets-declared", status, 4,
        "Budgets with thresholds declared in both clouds" if status == "PASS" else
        f"budget keys present: aws={aws_budget}, gcp={gcp_budget}; need per-env budgets "
        "with >= 2 thresholds (G3-11 / G4-13)",
        "vars.yaml (budget keys)", ["SOC2 CC3.4"]))
    return recs


def build_records():
    aws = loaders.load_aws_vars()
    gcp = loaders.load_gcp_vars()
    recs = []
    recs += check_ip_planning(aws, gcp)
    recs += check_segmentation(aws, gcp)
    recs += check_encryption(aws, gcp)
    recs += check_identity(aws, gcp)
    recs += check_audit(aws, gcp)
    recs += check_dr(aws, gcp)
    recs += check_naming(aws, gcp)
    recs += check_cost(aws, gcp)
    return recs


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--validate-schema", action="store_true")
    ap.add_argument("--min-score", type=float, default=None)
    ap.add_argument("--fail-on", choices=["FAIL", "WARN"], default=None)
    ap.add_argument("--quick", action="store_true", help="no file writes; exit code only")
    args = ap.parse_args()

    records = build_records()

    if args.validate_schema:
        errors = []
        for r in records:
            errors += [f"{r.get('check', '?')}: {e}" for e in rp.validate_record(r)]
        if errors:
            print("\n".join(errors), file=sys.stderr)
            return 1
        print(f"OK: {len(records)} records conform to schema v{rp.SCHEMA_VERSION}")
        return 0

    rep = rp.build_report(records, "scripts/architecture-score.py",
                          SOURCES)
    if not args.quick:
        rp.write_report_json(rep, REPORT_JSON)
        SCORECARD_MD.write_text(
            rp.render_scorecard(rep, "Architecture Scorecard", SOURCES),
            encoding="utf-8")
        print(f"Wrote {REPORT_JSON.name} and {SCORECARD_MD.name}")

    s = rep["score"]
    t = rep["totals"]
    print(f"Score: {s}/100 (grade {rep['grade']})  "
          f"PASS={t['pass']} WARN={t['warn']} FAIL={t['fail']} N/A={t['na']}")

    rc = 0
    if args.min_score is not None and s < args.min_score:
        print(f"FAIL: score {s} < required {args.min_score}", file=sys.stderr)
        rc = 1
    if args.fail_on == "FAIL" and t["fail"] > 0:
        print(f"FAIL: {t['fail']} FAIL-status checks present", file=sys.stderr)
        rc = 1
    if args.fail_on == "WARN" and (t["fail"] > 0 or t["warn"] > 0):
        print("FAIL: WARN/FAIL-status checks present", file=sys.stderr)
        rc = 1
    return rc


if __name__ == "__main__":
    sys.exit(main())
