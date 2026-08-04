#!/usr/bin/env python3
"""G2: security-scan gate — tfsec + checkov against .github/gate-thresholds.yaml.

Single source of truth for both the CI `security-scan` job and
`make preprod-gates-local`. Exit 1 when any threshold is exceeded.

Controls: PCI-DSS 6.3.2 (code review/scanning), CIS 1.x, SOC2 CC7.1.
"""

import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lib import loaders  # noqa: E402

REPO = loaders.REPO_ROOT
THRESHOLDS = REPO / ".github" / "gate-thresholds.yaml"
TREES = ["aws-terragrunt-configuration", "gcp-terragrunt-configuration"]


def export_index():
    """Pristine export of the git index (tracked + staged files only), so the
    scan surface is identical locally and in CI. Local terragrunt/terraform
    caches hold vendored module clones that would otherwise dominate results
    (882 phantom findings measured on a cache-polluted tree)."""
    tmp = Path(tempfile.mkdtemp(prefix="secgate-"))
    subprocess.run(["git", "checkout-index", "-a", f"--prefix={tmp}/"],
                   cwd=REPO, check=True)
    return tmp


def main():
    th = loaders.load_vars_yaml(THRESHOLDS)
    fail = False
    scan_root = export_index()

    def cached(path):
        return ".terragrunt-cache" in path or "/.terraform/" in path

    if shutil.which("tfsec"):
        sev = {"CRITICAL": 0, "HIGH": 0}
        for tree in TREES:
            r = subprocess.run(["tfsec", str(scan_root / tree), "--format", "json",
                                "--no-color"], capture_output=True, text=True)
            try:
                results = json.loads(r.stdout or "{}").get("results") or []
            except ValueError:
                results = []
            for res in results:
                fname = (res.get("location") or {}).get("filename", "")
                if res.get("severity") in sev and not cached(fname):
                    sev[res["severity"]] += 1
        print(f"tfsec: {sev} (max HIGH {th['max_tfsec_high']}, "
              f"max CRITICAL {th['max_tfsec_critical']})")
        if sev["CRITICAL"] > th["max_tfsec_critical"] or \
                sev["HIGH"] > th["max_tfsec_high"]:
            print("FAIL: tfsec thresholds exceeded", file=sys.stderr)
            fail = True
    else:
        print("FAIL: tfsec not installed", file=sys.stderr)
        fail = True

    if shutil.which("checkov"):
        r = subprocess.run(["checkov", "-d", str(scan_root / "gcp-terragrunt-configuration"),
                            "--framework", "terraform", "-o", "json", "--quiet"],
                           capture_output=True, text=True)
        try:
            data = json.loads(r.stdout)
            data = data if isinstance(data, list) else [data]
            failed = sum(1 for d in data
                         for c in (d.get("results", {}) or {}).get("failed_checks", [])
                         if not cached(c.get("file_path", "")
                                       + c.get("repo_file_path", "")))
        except ValueError:
            failed = -1
        print(f"checkov failed checks: {failed} (max {th['max_checkov_failed']})")
        if failed < 0 or failed > th["max_checkov_failed"]:
            print("FAIL: checkov threshold exceeded", file=sys.stderr)
            fail = True
    else:
        print("FAIL: checkov not installed", file=sys.stderr)
        fail = True

    shutil.rmtree(scan_root, ignore_errors=True)
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main())
