"""Loaders for gate scripts: YAML (anchor-redefinition tolerant), repo paths,
terragrunt stack discovery.

Both vars.yaml files legitimately redefine YAML anchors (legal in YAML 1.2 and
accepted by Terragrunt's yamldecode); PyYAML >= 6.0.3 rejects that, so all gate
scripts must load vars through load_vars_yaml() below — never yaml.safe_load.

Controls: SOC2 CC8.1 (consistent change tooling).
"""

import re
from pathlib import Path

import yaml
import yaml.composer

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
AWS_ROOT = REPO_ROOT / "aws-terragrunt-configuration" / "aws"
GCP_ROOT = REPO_ROOT / "gcp-terragrunt-configuration"
GCP_TG_ROOT = GCP_ROOT / "terragrunt"
GCP_ENVS = GCP_TG_ROOT / "envs"
GCP_MODULES = GCP_ROOT / "tf-modules"
AWS_VARS = AWS_ROOT / "vars.yaml"
GCP_VARS = GCP_TG_ROOT / "vars.yaml"

CACHE_DIRS = {".terragrunt-cache", ".terraform"}
AWS_ENV_NAMES = {"dev", "stg", "prod"}
AWS_REGIONS = {"us", "eu"}

SOURCE_RE = re.compile(r'source\s*=\s*"([^"]+)"')


class _RedefiningComposer(yaml.composer.Composer):
    def compose_node(self, parent, index):
        event = self.peek_event()
        if (not isinstance(event, yaml.events.AliasEvent)
                and getattr(event, "anchor", None) is not None
                and event.anchor in self.anchors):
            del self.anchors[event.anchor]
        return super().compose_node(parent, index)


class TerragruntSafeLoader(
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
    return yaml.load(Path(path).read_text(encoding="utf-8"), Loader=TerragruntSafeLoader)


def load_aws_vars():
    return load_vars_yaml(AWS_VARS)


def load_gcp_vars():
    return load_vars_yaml(GCP_VARS)


def find_stacks(root: Path):
    """All terragrunt.hcl files under root, skipping caches."""
    return sorted(p for p in root.rglob("terragrunt.hcl")
                  if not CACHE_DIRS.intersection(p.relative_to(root).parts))


def aws_env_stacks():
    """AWS stacks that follow the {service}/{region}/{env} convention.
    Returns list of dicts {service, region, env, path}."""
    out = []
    for hcl in find_stacks(AWS_ROOT):
        parts = hcl.relative_to(AWS_ROOT).parts[:-1]
        if len(parts) >= 3 and parts[-2] in AWS_REGIONS and parts[-1] in AWS_ENV_NAMES:
            out.append({"service": "/".join(parts[:-2]), "region": parts[-2],
                        "env": parts[-1], "path": hcl})
    return out


def gcp_env_stacks():
    """GCP stacks under envs/{folder}/{env}/{resource} (excludes global root)."""
    out = []
    for hcl in find_stacks(GCP_ENVS):
        parts = hcl.relative_to(GCP_ENVS).parts[:-1]
        if len(parts) == 3:
            out.append({"folder": parts[0], "env": parts[1],
                        "resource": parts[2], "path": hcl})
        elif len(parts) == 2 and parts[0] == "global":
            out.append({"folder": "global", "env": "global",
                        "resource": parts[1], "path": hcl})
    return out


def leaf_key_paths(data, prefix=""):
    """Yield (dotted_path, value) for every leaf (non-dict) in a nested mapping."""
    if isinstance(data, dict):
        if not data:
            yield (prefix, data)
        for k, v in data.items():
            p = f"{prefix}.{k}" if prefix else str(k)
            if isinstance(v, dict) and v:
                yield from leaf_key_paths(v, p)
            else:
                yield (p, v)


def find_key_line(path: Path, dotted: str):
    """Best-effort line number of a dotted key path in a YAML file.

    Walks the file tracking indentation so the innermost matching key in the
    right nesting context is found; falls back to the first bare occurrence.
    """
    parts = dotted.split(".")
    text = Path(path).read_text(encoding="utf-8").splitlines()
    depth = 0
    stack = []  # (indent, key)
    for lineno, line in enumerate(text, 1):
        m = re.match(r"^(\s*)([A-Za-z0-9_\-\.\*&' \"]+?):", line)
        if not m:
            continue
        indent = len(m.group(1))
        key = m.group(2).strip().strip("'\"").lstrip("&").split()[0] if m.group(2).strip() else ""
        while stack and stack[-1][0] >= indent:
            stack.pop()
        stack.append((indent, key))
        keys = [k for _, k in stack]
        if keys == parts[:len(keys)] and len(keys) == len(parts):
            return lineno
        depth = indent
    _ = depth
    # fallback: first occurrence of the leaf key name
    leaf = parts[-1]
    for lineno, line in enumerate(text, 1):
        if re.match(rf"^\s*['\"]?{re.escape(leaf)}['\"]?\s*:", line):
            return lineno
    return None


def module_declared_variables(module_dir: Path):
    """Variable names declared by a local terraform module (its *.tf files)."""
    names = set()
    for tf in module_dir.glob("*.tf"):
        for m in re.finditer(r'variable\s+"([^"]+)"', tf.read_text(encoding="utf-8", errors="replace")):
            names.add(m.group(1))
    return names


def read_module_source(hcl_path: Path):
    m = SOURCE_RE.search(Path(hcl_path).read_text(encoding="utf-8", errors="replace"))
    return m.group(1) if m else None
