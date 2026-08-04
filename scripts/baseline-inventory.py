#!/usr/bin/env python3
"""G0-2: Baseline inventory of the multi-cloud-runway repository.

Emits evidence/G0/BASELINE.json — a machine-readable snapshot of:
  - every terragrunt.hcl path, parsed into {service, region/folder, env}
  - the module source (+ version ref) each stack resolves to
  - every key path present in both vars.yaml files
  - every local module under gcp-terragrunt-configuration/tf-modules/
  - counts: files by extension, stacks by env

Read-only: performs no cloud calls and no terragrunt/terraform execution.

Controls: SOC2 CC8.1 (change baseline), CIS 1.x (inventory of assets),
PCI-DSS 12.5.1 (inventory responsibility).

Usage:
  python3 scripts/baseline-inventory.py            # write BASELINE.json
  python3 scripts/baseline-inventory.py --check    # verify existing file matches repo state (exit 0/1)
  python3 scripts/baseline-inventory.py --output <path>
"""

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path

import yaml
import yaml.composer


class _RedefiningComposer(yaml.composer.Composer):
    """Allow anchor redefinition (YAML 1.2 semantics, matches Terragrunt's yamldecode).

    PyYAML >= 6.0.3 raises ComposerError on duplicate anchors; both vars.yaml
    files legitimately redefine anchors (e.g. &DefReg), so we relax that.
    """

    def compose_node(self, parent, index):
        event = self.peek_event()
        if (not isinstance(event, yaml.events.AliasEvent)
                and getattr(event, "anchor", None) is not None
                and event.anchor in self.anchors):
            del self.anchors[event.anchor]
        return super().compose_node(parent, index)


class _TerragruntSafeLoader(
    yaml.reader.Reader, yaml.scanner.Scanner, yaml.parser.Parser,
    _RedefiningComposer, yaml.constructor.SafeConstructor, yaml.resolver.Resolver,
):
    def __init__(self, stream):
        yaml.reader.Reader.__init__(self, stream)
        yaml.scanner.Scanner.__init__(self)
        yaml.parser.Parser.__init__(self)
        _RedefiningComposer.__init__(self)
        yaml.constructor.SafeConstructor.__init__(self)
        yaml.resolver.Resolver.__init__(self)


def load_vars_yaml(path: Path):
    return yaml.load(path.read_text(encoding="utf-8"), Loader=_TerragruntSafeLoader)


REPO_ROOT = Path(__file__).resolve().parent.parent
AWS_ROOT = REPO_ROOT / "aws-terragrunt-configuration" / "aws"
GCP_ROOT = REPO_ROOT / "gcp-terragrunt-configuration"
GCP_ENVS = GCP_ROOT / "terragrunt" / "envs"
GCP_MODULES = GCP_ROOT / "tf-modules"
DEFAULT_OUTPUT = REPO_ROOT / "evidence" / "G0" / "BASELINE.json"

SOURCE_RE = re.compile(r'source\s*=\s*"([^"]+)"')
REF_RE = re.compile(r"\?ref=([^\"&\s]+)")

AWS_ENVS = {"dev", "stg", "prod"}
AWS_REGIONS = {"us", "eu"}


def read_source(hcl_path: Path):
    """Extract the terraform source string from a terragrunt.hcl, if present."""
    text = hcl_path.read_text(encoding="utf-8", errors="replace")
    m = SOURCE_RE.search(text)
    if not m:
        return None, None
    source = m.group(1)
    ref_m = REF_RE.search(source)
    # refs interpolated from _env.hcl locals (e.g. ${include.env.locals.module_ref})
    ref = ref_m.group(1) if ref_m else None
    return source, ref


def resolve_env_ref(hcl_path: Path, ref: str):
    """If the ref is a terragrunt interpolation, resolve module_ref from the nearest _env.hcl."""
    if ref is None or "${" not in ref:
        return ref
    for parent in hcl_path.parents:
        env_hcl = parent / "_env.hcl"
        if env_hcl.exists():
            m = re.search(r'module_ref\s*=\s*"([^"]+)"', env_hcl.read_text(encoding="utf-8", errors="replace"))
            if m:
                return m.group(1)
        if parent == REPO_ROOT:
            break
    return ref  # unresolved interpolation, keep as-is


CACHE_DIRS = {".terragrunt-cache", ".terraform"}


def find_stacks(root: Path):
    """All terragrunt.hcl files under root, skipping terragrunt/terraform caches."""
    return sorted(p for p in root.rglob("terragrunt.hcl")
                  if not CACHE_DIRS.intersection(p.relative_to(root).parts))


def aws_stacks():
    stacks = []
    for hcl in find_stacks(AWS_ROOT):
        rel = hcl.relative_to(AWS_ROOT)
        parts = rel.parts[:-1]  # drop terragrunt.hcl
        source, ref = read_source(hcl)
        ref = resolve_env_ref(hcl, ref)
        entry = {
            "path": str(hcl.relative_to(REPO_ROOT)),
            "service": None,
            "region": None,
            "env": None,
            "module_source": source,
            "module_ref": ref,
        }
        if len(parts) == 0:
            entry["service"] = "_root"
        elif len(parts) >= 3 and parts[-2] in AWS_REGIONS and parts[-1] in AWS_ENVS:
            entry["service"] = "/".join(parts[:-2])
            entry["region"] = parts[-2]
            entry["env"] = parts[-1]
        else:
            # cross-cutting stacks: cloudtrail, accounts, security/*, iam/*, network/*
            entry["service"] = "/".join(parts)
            entry["env"] = "global"
        stacks.append(entry)
    return stacks


def gcp_stacks():
    stacks = []
    for hcl in find_stacks(GCP_ENVS):
        rel = hcl.relative_to(GCP_ENVS)
        parts = rel.parts[:-1]
        source, ref = read_source(hcl)
        entry = {
            "path": str(hcl.relative_to(REPO_ROOT)),
            "folder": None,
            "env": None,
            "resource": None,
            "module_source": source,
            "module_ref": ref,
        }
        if len(parts) == 0:
            entry["resource"] = "_root"
        elif parts[0] == "global":
            entry["folder"] = "global"
            entry["env"] = "global"
            entry["resource"] = "/".join(parts[1:]) or "_folder_root"
        elif len(parts) == 3:
            # {folder}/{env}/{resource} e.g. shrd/prod/net-vpc  or  stg/eu/svc-gke
            entry["folder"], entry["env"], entry["resource"] = parts[0], parts[1], parts[2]
        else:
            entry["folder"] = parts[0] if parts else None
            entry["resource"] = "/".join(parts[1:]) or "_folder_root"
        stacks.append(entry)
    # root terragrunt.hcl one level above envs/
    root_hcl = GCP_ROOT / "terragrunt" / "terragrunt.hcl"
    if root_hcl.exists():
        stacks.insert(0, {
            "path": str(root_hcl.relative_to(REPO_ROOT)),
            "folder": None, "env": None, "resource": "_root",
            "module_source": None, "module_ref": None,
        })
    return stacks


def yaml_key_paths(data, prefix=""):
    """Flatten every key path in a nested mapping (lists are terminal)."""
    paths = []
    if isinstance(data, dict):
        for k, v in data.items():
            p = f"{prefix}.{k}" if prefix else str(k)
            paths.append(p)
            paths.extend(yaml_key_paths(v, p))
    return paths


def local_modules():
    mods = []
    if GCP_MODULES.is_dir():
        for d in sorted(GCP_MODULES.iterdir()):
            if d.is_dir():
                tf_files = sorted(p.name for p in d.glob("*.tf"))
                mods.append({"name": d.name, "tf_files": tf_files})
    return mods


def file_counts():
    """Counts by extension over git-tracked files only, so local artifacts
    (caches, lock files, __pycache__) cannot perturb the snapshot. evidence/
    is excluded because snapshot outputs must not count themselves."""
    import subprocess
    out = subprocess.run(["git", "ls-files"], cwd=REPO_ROOT,
                         capture_output=True, text=True, check=True).stdout
    counts = Counter()
    for line in out.splitlines():
        parts = Path(line).parts
        if parts and parts[0] == "evidence":
            continue
        counts[Path(line).suffix or "(none)"] += 1
    return dict(sorted(counts.items(), key=lambda kv: -kv[1]))


def stacks_by_env(aws, gcp):
    c = Counter()
    for s in aws:
        c[f"aws/{s['region'] or 'global'}/{s['env']}"] += 1
    for s in gcp:
        c[f"gcp/{s['folder'] or 'root'}/{s['env'] or 'root'}"] += 1
    return dict(sorted(c.items()))


def build():
    aws = aws_stacks()
    gcp = gcp_stacks()
    aws_vars = load_vars_yaml(AWS_ROOT / "vars.yaml")
    gcp_vars = load_vars_yaml(GCP_ROOT / "terragrunt" / "vars.yaml")
    return {
        "schema_version": 1,
        "aws": {
            "stacks": aws,
            "vars_key_paths": yaml_key_paths(aws_vars),
        },
        "gcp": {
            "stacks": gcp,
            "vars_key_paths": yaml_key_paths(gcp_vars),
            "local_modules": local_modules(),
        },
        "counts": {
            "files_by_extension": file_counts(),
            "stacks_by_env": stacks_by_env(aws, gcp),
            "aws_stacks_total": len(aws),
            "gcp_stacks_total": len(gcp),
        },
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true",
                    help="verify the existing BASELINE.json matches current repo state")
    ap.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = ap.parse_args()

    snapshot = build()

    if args.check:
        if not args.output.exists():
            print(f"FAIL: {args.output} does not exist", file=sys.stderr)
            return 1
        existing = json.loads(args.output.read_text(encoding="utf-8"))
        if existing == snapshot:
            print(f"OK: {args.output} matches current repo state")
            return 0
        print(f"FAIL: {args.output} is stale relative to the repo; regenerate it", file=sys.stderr)
        return 1

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(snapshot, indent=2, sort_keys=False) + "\n", encoding="utf-8")
    c = snapshot["counts"]
    print(f"Wrote {args.output}")
    print(f"  AWS stacks: {c['aws_stacks_total']}  GCP stacks: {c['gcp_stacks_total']}")
    print(f"  AWS vars keys: {len(snapshot['aws']['vars_key_paths'])}  "
          f"GCP vars keys: {len(snapshot['gcp']['vars_key_paths'])}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
