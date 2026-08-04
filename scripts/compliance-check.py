#!/usr/bin/env python3
"""
Compliance Check Script for Multi-Cloud Infrastructure (G1-1 refactor).

Performs compliance checks against PCI DSS, CIS Benchmarks, SOC 2 and other
frameworks. Rules live as data in scripts/lib/rules.py (IDs preserved from the
original implementation — do not renumber); loading and reporting are shared
via scripts/lib. The pre-refactor placeholder checks (`return True`) are now
real derivations from vars.yaml and the terragrunt tree.

CLI is unchanged: --root-dir, --framework, --output {text,json}, --fail-on-critical.
Exit codes are unchanged: 1 if any failure (or any critical with --fail-on-critical).
"""

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lib import loaders, rules as rulelib  # noqa: E402


class ComplianceChecker:
    def __init__(self, root_dir: str = "."):
        self.root_dir = Path(root_dir)
        self.findings = []
        self.passed_checks = []
        self.rules = rulelib.RULES

    # -- helpers -----------------------------------------------------------
    def _fail(self, rule_id, finding, remediation):
        r = rulelib.rule(rule_id)
        self.findings.append({
            "rule_id": rule_id, "framework": r["framework"],
            "severity": r["severity"], "category": r["category"],
            "finding": finding, "remediation": remediation,
        })

    def _pass(self, tag):
        self.passed_checks.append(tag)

    # -- checks ------------------------------------------------------------
    def check_all_compliance(self):
        print("🔍 Running compliance checks...", file=sys.stderr)
        aws = loaders.load_aws_vars() if loaders.AWS_VARS.exists() else None
        gcp = loaders.load_gcp_vars() if loaders.GCP_VARS.exists() else None
        if aws:
            self.check_aws(aws)
        if gcp:
            self.check_gcp(gcp)
        self.check_general()

        results = {"frameworks": {}, "summary": {
            "total_rules": len(self.rules), "passed": len(self.passed_checks),
            "failed": len(self.findings),
            "critical_failures": sum(1 for f in self.findings
                                     if f["severity"] == "critical")}}
        for fw in rulelib.FRAMEWORKS.values():
            fw_rules = rulelib.rules_for(fw)
            fw_findings = [f for f in self.findings if f["framework"] == fw]
            results["frameworks"][fw] = {
                "total_rules": len(fw_rules), "findings": len(fw_findings),
                "passed": len(fw_rules) - len({f["rule_id"] for f in fw_findings}),
                "critical_failures": sum(1 for f in fw_findings
                                         if f["severity"] == "critical")}
        return results

    def check_aws(self, aws):
        # PCI-DSS-3.4 encryption at rest: explicit storage_encrypted=false is a fail
        off = []
        for envkey, envval in (aws.get("Environments", {}) or {}).items():
            text = json.dumps((envval or {}).get("Resources", {}) or {})
            if '"storage_encrypted": false' in text:
                off.append(envkey)
        if off:
            self._fail("PCI-DSS-3.4",
                       f"storage_encrypted=false declared in envs: {sorted(off)}",
                       "Enable encryption (with CMKs) for all data services")
        else:
            self._pass("PCI-DSS-3.4")

        # PCI-DSS-1.1 segmentation: every workload (region-env) VPC declares
        # private subnets; hub/transit VPCs (e.g. the network account) exempt
        bad = []
        for envkey, envval in (aws.get("Environments", {}) or {}).items():
            parts = envkey.split("-", 1)
            if len(parts) != 2 or parts[0] not in loaders.AWS_REGIONS \
                    or parts[1] not in loaders.AWS_ENV_NAMES:
                continue
            vpc = (((envval or {}).get("Resources", {}) or {}).get("vpc") or {}) \
                .get("inputs", {}) or {}
            if vpc and not vpc.get("private_subnets"):
                bad.append(envkey)
        if bad:
            self._fail("PCI-DSS-1.1", f"VPCs without private subnets: {bad}",
                       "Declare private subnet tiers for workload isolation")
        else:
            self._pass("PCI-DSS-1.1")

        # PCI-DSS-10.1 audit logging: cloudtrail stack must exist
        if (loaders.AWS_ROOT / "cloudtrail" / "terragrunt.hcl").exists():
            self._pass("PCI-DSS-10.1")
        else:
            self._fail("PCI-DSS-10.1", "No CloudTrail stack",
                       "Add org CloudTrail with log-file validation")

        # CIS-1.1 / PCI-DSS-8.1: wildcard Allow actions in policy documents
        wild = []
        for jf in loaders.AWS_ROOT.rglob("*.json"):
            if loaders.CACHE_DIRS.intersection(jf.parts):
                continue
            try:
                doc = json.loads(jf.read_text(encoding="utf-8"))
            except (ValueError, UnicodeDecodeError):
                continue
            stmts = doc.get("Statement", []) if isinstance(doc, dict) else []
            stmts = [stmts] if isinstance(stmts, dict) else stmts
            for st in stmts:
                acts = (st or {}).get("Action", [])
                acts = [acts] if isinstance(acts, str) else acts
                if (st or {}).get("Effect") == "Allow" and "*" in acts:
                    wild.append(str(jf.relative_to(self.root_dir)))
        if wild:
            self._fail("CIS-1.1", f"Wildcard Allow Action in: {wild[:5]}",
                       "Scope policy actions to least privilege")
        else:
            self._pass("CIS-1.1")

    def check_gcp(self, gcp):
        # PCI-DSS-3.4 (GCP): GKE database encryption + CMEK refs on data services
        missing = []
        for folder, envs in (gcp.get("envs", {}) or {}).items():
            if not isinstance(envs, dict):
                continue
            env_iter = ([("_flat", envs)] if "resources" in envs else envs.items())
            for env, envval in env_iter:
                if not isinstance(envval, dict):
                    continue
                res = envval.get("resources", {}) or {}
                gke = (res.get("svc-gke") or {}).get("inputs", {}) or {}
                if gke and not gke.get("database_encryption"):
                    missing.append(f"{folder}/{env}:gke")
        if missing:
            self._fail("PCI-DSS-3.4", f"GKE etcd encryption off: {missing}",
                       "Enable database_encryption (CMEK) on GKE")
        else:
            self._pass("PCI-DSS-3.4-GCP")

        # PCI-DSS-1.1 (GCP): GKE private nodes
        public = []
        for s in loaders.gcp_env_stacks():
            if s["resource"] != "svc-gke":
                continue
            res = (gcp.get("envs", {}).get(s["folder"], {}) or {}) \
                .get(s["env"], {}) or {}
            gke = ((res.get("resources", {}) or {}).get("svc-gke") or {}) \
                .get("inputs", {}) or {}
            if gke and not gke.get("enable_private_nodes"):
                public.append(f"{s['folder']}/{s['env']}")
        if public:
            self._fail("PCI-DSS-1.1", f"GKE clusters without private nodes: {public}",
                       "Set enable_private_nodes: true")
        else:
            self._pass("PCI-DSS-1.1-GCP")

        # PCI-DSS-10.1 (GCP): audit stack
        if (loaders.GCP_ENVS / "global" / "audit" / "terragrunt.hcl").exists():
            self._pass("PCI-DSS-10.1-GCP")
        else:
            self._fail("PCI-DSS-10.1", "No GCP audit log sink stack",
                       "Add envs/global/audit")

        # SOC2-CC6.1: workload identity on all GKE stacks
        gke_hcls = [s["path"] for s in loaders.gcp_env_stacks()
                    if s["resource"] == "svc-gke"]
        if gke_hcls and all("identity_namespace" in
                            p.read_text(encoding="utf-8", errors="replace")
                            for p in gke_hcls):
            self._pass("SOC2-CC6.1")
        else:
            self._fail("SOC2-CC6.1", "GKE stacks missing Workload Identity wiring",
                       "Wire identity_namespace on every svc-gke stack")

    def check_general(self):
        # CIS-1.1: no secret-material files in repo
        secret_files = [p for pat in ("*.key", "*.pem", ".env")
                        for p in self.root_dir.rglob(pat)
                        if ".git" not in p.parts]
        if secret_files:
            self._fail("CIS-1.1",
                       f"Potential secret files found: {len(secret_files)} files",
                       "Remove secret files; use secure secret management")
        # SOC2-CC7.1: required docs
        missing = [d for d in ("SECURITY.md", "CONTRIBUTING.md")
                   if not (self.root_dir / d).exists()]
        if missing:
            self._fail("SOC2-CC7.1", f"Missing required documentation: {missing}",
                       "Create missing security/compliance docs")
        else:
            self._pass("SOC2-CC7.1")

    # -- output ------------------------------------------------------------
    def print_results(self, results):
        print(f"\n📋 Compliance Check Results\n{'=' * 50}")
        s = results["summary"]
        print(f"Total Rules Checked: {s['total_rules']}")
        print(f"Passed: {s['passed']} ✅\nFailed: {s['failed']} ❌")
        print(f"Critical Failures: {s['critical_failures']} 🚨")
        for fw, st in results["frameworks"].items():
            print(f"\n{fw}:\n  Rules: {st['total_rules']}\n  Passed: {st['passed']} ✅"
                  f"\n  Failed: {st['findings']} ❌\n  Critical: {st['critical_failures']} 🚨")
        if self.findings:
            print(f"\n🔍 Detailed Findings:\n{'=' * 50}")
            for sev, icon in (("critical", "🚨"), ("high", "⚠️"), ("medium", "📋")):
                items = [f for f in self.findings if f["severity"] == sev]
                if items:
                    print(f"\n{icon} {sev.title()} Issues ({len(items)}):")
                    for f in items:
                        print(f"  • [{f['rule_id']}] {f['finding']}")
                        print(f"    Remediation: {f['remediation']}")
        total, passed = s["total_rules"], s["passed"]
        score = (passed / total * 100) if total else 0
        print(f"\n📊 Overall Compliance Score: {score:.1f}%")


def main():
    parser = argparse.ArgumentParser(
        description="Run compliance checks for multi-cloud infrastructure")
    parser.add_argument("--root-dir", default=".",
                        help="Root directory to scan (default: current)")
    parser.add_argument("--framework",
                        choices=list(rulelib.FRAMEWORKS.values()),
                        help="Check specific compliance framework")
    parser.add_argument("--output", choices=["text", "json"], default="text")
    parser.add_argument("--fail-on-critical", action="store_true")
    args = parser.parse_args()

    checker = ComplianceChecker(args.root_dir)
    results = checker.check_all_compliance()

    if args.output == "json":
        print(json.dumps(results, indent=2, default=str))
    else:
        checker.print_results(results)

    if args.fail_on_critical and results["summary"]["critical_failures"] > 0:
        sys.exit(1)
    if results["summary"]["failed"] > 0:
        sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()
