#!/usr/bin/env python3
"""G1-7/G1-8: Intent -> output assertions.

Walks every declared key in both vars.yaml files and verifies something in the
terragrunt/terraform tree actually consumes it. Unconsumed keys are "declared
but not emitted" findings -> INPUT_ASSERTIONS.md, with file:line of declaration.

Consumption model (static, no cloud access):
  L1 (both clouds)  every env/resource block must have a terragrunt stack
                    directory that resolves to it via the repo's path convention.
  L2 (GCP only)     inputs.* keys of a consumed resource must be declared as
                    variables by the local tf-module the stack sources
                    (AWS modules are external Git sources pinned by ref — key-level
                    verification is out of static reach; reported as UNVERIFIED).

Allowlist: scripts/config/assertion-allowlist.yaml — every entry requires a
`reason:`. Allowlisted findings don't fail the gate.

Usage:
  python3 scripts/input-assertions.py            # write INPUT_ASSERTIONS.md
  python3 scripts/input-assertions.py --check    # exit 1 on non-allowlisted findings
Controls: SOC2 CC8.1 (declared config is deployed config), PCI-DSS 6.4.
"""

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lib import loaders  # noqa: E402

REPO = loaders.REPO_ROOT
OUTPUT = REPO / "INPUT_ASSERTIONS.md"
ALLOWLIST = REPO / "scripts" / "config" / "assertion-allowlist.yaml"


def load_allowlist():
    if not ALLOWLIST.exists():
        return {}
    data = loaders.load_vars_yaml(ALLOWLIST) or {}
    entries = {}
    for e in data.get("allow", []) or []:
        if not e.get("reason"):
            print(f"ERROR: allowlist entry {e.get('key')!r} has no reason", file=sys.stderr)
            sys.exit(2)
        entries[e["key"]] = e["reason"]
    return entries


def aws_findings(aws):
    """L1: every Environments.{key}.Resources.{svc} block must be consumed.

    Consumption paths (matching the repo's two lookup conventions):
      a. path convention — stack aws/{svc}/{region}/{env} exists for a
         region-env key, or
      b. literal lookup — some global stack references Environments["<key>"]
         directly (e.g. cloudtrail uses "log-archive"), and a stack whose
         directory basename equals the resource name exists.
    A region-env miss where a same-named global stack exists is reported as
    L1-INDIRECT (verify the global stack's lookup, or allowlist).
    """
    findings = []
    stacks = {(s["service"], s["region"], s["env"]) for s in loaders.aws_env_stacks()}
    hcl_files = loaders.find_stacks(loaders.AWS_ROOT)
    hcl_texts = {p: p.read_text(encoding="utf-8", errors="replace") for p in hcl_files}
    stack_basenames = {p.parent.name for p in hcl_files}
    # parent-dir convention: aws/{account}/{resource} stacks read
    # Environments[basename(dirname)] via local.account (e.g. security/scp)
    parent_dir_stacks = {(p.parent.parent.name, p.parent.name) for p in hcl_files}

    for envkey, envval in (aws.get("Environments", {}) or {}).items():
        region_env = None
        if "-" in envkey:
            r, e = envkey.split("-", 1)
            if r in loaders.AWS_REGIONS and e in loaders.AWS_ENV_NAMES:
                region_env = (r, e)
        for svc in ((envval or {}).get("Resources", {}) or {}):
            dotted = f"Environments.{envkey}.Resources.{svc}"
            if region_env and (svc, *region_env) in stacks:
                continue
            if (envkey, svc) in parent_dir_stacks:
                continue
            # literal lookup: one hcl file naming both the env key and the
            # resource (e.g. accounts stack reads Environments.master.*)
            svc_pat = re.compile(rf'\["{re.escape(svc)}"\]|Resources\.{re.escape(svc)}\b')
            if any(f'"{envkey}"' in t and svc_pat.search(t)
                   for t in hcl_texts.values()):
                continue
            # interpolated resource lookup: a stack dir named after the
            # resource whose hcl names the env key literally (e.g. cloudtrail
            # reads Environments["log-archive"]...[local.resource])
            if any(p.parent.name == svc and f'"{envkey}"' in t
                   for p, t in hcl_texts.items()):
                continue
            if svc in stack_basenames:
                findings.append({
                    "cloud": "aws", "level": "L1-INDIRECT", "key": dotted,
                    "issue": (f"no per-env stack aws/{svc}/{envkey.replace('-', '/')}; "
                              f"a global stack named '{svc}' exists — verify its lookup "
                              "actually reads this key, or allowlist with reason"),
                    "line": loaders.find_key_line(loaders.AWS_VARS, dotted),
                })
            else:
                findings.append({
                    "cloud": "aws", "level": "L1", "key": dotted,
                    "issue": "declared but no stack consumes it",
                    "line": loaders.find_key_line(loaders.AWS_VARS, dotted),
                })
    return findings


def gcp_module_for_stack(hcl_path):
    src = loaders.read_module_source(hcl_path) or ""
    m = re.search(r"tf-modules//?([\w-]+)", src)
    return loaders.GCP_MODULES / m.group(1) if m else None


def gcp_findings(gcp):
    findings = []
    stacks = {}
    for s in loaders.gcp_env_stacks():
        stacks[(s["folder"], s["env"], s["resource"])] = s["path"]

    for folder, env, res in iter_env_resources(gcp):
        for rname, rblock in (res or {}).items():
            skey = (folder, env, rname)
            dotted_prefix = (f"envs.{folder}.{env}.resources.{rname}"
                             if env != "_flat" else f"envs.{folder}.resources.{rname}")
            if env != "_flat" and skey not in stacks:
                findings.append({
                    "cloud": "gcp", "level": "L1", "key": dotted_prefix,
                    "issue": f"declared but no stack envs/{folder}/{env}/{rname} exists",
                    "line": loaders.find_key_line(loaders.GCP_VARS, dotted_prefix),
                })
                continue
            # L2: inputs.* keys vs local module variables
            hcl = stacks.get(skey)
            if hcl is None:
                continue
            module_dir = gcp_module_for_stack(hcl)
            if module_dir is None or not module_dir.is_dir():
                continue
            declared_vars = loaders.module_declared_variables(module_dir)
            hcl_text = hcl.read_text(encoding="utf-8", errors="replace")
            inputs = (rblock or {}).get("inputs", {}) if isinstance(rblock, dict) else {}
            for key in (inputs or {}):
                if key in declared_vars or f'"{key}"' in hcl_text or key in hcl_text:
                    continue
                findings.append({
                    "cloud": "gcp", "level": "L2",
                    "key": f"{dotted_prefix}.inputs.{key}",
                    "issue": (f"input not declared by module {module_dir.name} "
                              f"and not referenced in {hcl.relative_to(REPO)}"),
                    "line": loaders.find_key_line(loaders.GCP_VARS, key),
                })
    return findings


def iter_env_resources(gcp):
    for folder, envs in (gcp.get("envs", {}) or {}).items():
        if not isinstance(envs, dict):
            continue
        if "resources" in envs:
            yield folder, "_flat", envs.get("resources") or {}
            continue
        for env, envval in envs.items():
            if isinstance(envval, dict) and "resources" in envval:
                yield folder, env, envval.get("resources") or {}


def render(findings, allow):
    active = [f for f in findings if f["key"] not in allow]
    allowed = [f for f in findings if f["key"] in allow]
    lines = [
        "# Input Assertions (G1-7)",
        "",
        "Declared-but-not-emitted findings: keys present in a vars.yaml that no",
        "terragrunt stack or module consumes. Generated by",
        "`scripts/input-assertions.py`; regenerate with `make assertions`.",
        "",
        f"**{len(active)} active findings, {len(allowed)} allowlisted.** "
        "AWS `inputs.*` keys are UNVERIFIED at key level (external Git modules; "
        "L2 applies to GCP local modules only).",
        "",
    ]
    if active:
        lines += ["| Cloud | Level | Key | Declared at | Issue |", "|---|---|---|---|---|"]
        for f in active:
            loc = f"vars.yaml:{f['line']}" if f.get("line") else "vars.yaml"
            lines.append(f"| {f['cloud']} | {f['level']} | `{f['key']}` | {loc} | {f['issue']} |")
        lines.append("")
    if allowed:
        lines += ["## Allowlisted (with reasons)", "",
                  "| Key | Reason |", "|---|---|"]
        for f in allowed:
            lines.append(f"| `{f['key']}` | {allow[f['key']]} |")
        lines.append("")
    return "\n".join(lines) + "\n", active


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true",
                    help="exit 1 if non-allowlisted findings exist")
    args = ap.parse_args()

    allow = load_allowlist()
    findings = aws_findings(loaders.load_aws_vars()) + gcp_findings(loaders.load_gcp_vars())
    content, active = render(findings, allow)

    if args.check:
        if active:
            print(f"FAIL: {len(active)} non-allowlisted declared-but-not-emitted keys "
                  f"(see INPUT_ASSERTIONS.md)", file=sys.stderr)
            for f in active[:10]:
                print(f"  {f['key']}: {f['issue']}", file=sys.stderr)
            return 1
        print("OK: no non-allowlisted findings")
        return 0

    OUTPUT.write_text(content, encoding="utf-8")
    print(f"Wrote {OUTPUT.name}: {len(active)} active, "
          f"{len(findings) - len(active)} allowlisted")
    return 0


if __name__ == "__main__":
    sys.exit(main())
