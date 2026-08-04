#!/usr/bin/env python3
"""G3-15: SCP validation gate.

Simulates every SCP under aws/security/scp/policies/ against fixture cases in
scripts/fixtures/scp-cases.yaml and asserts the expected allow/deny outcome.

Gate rules:
  - unparseable/empty policy file  -> FAIL, unless waived with a reason in
    scripts/config/scp-waivers.yaml (pre-existing 0-byte files; see evidence)
  - parseable policy without >= 3 fixture cases -> FAIL (plan: "SCPs without
    test cases fail the gate")
  - any case whose simulated outcome differs from `expect` -> FAIL

The simulator implements the SCP-relevant subset of IAM policy evaluation:
Deny statements only (SCP FullAWSAccess baseline assumed), Action/NotAction
globs, Resource globs, and the condition operators used by this repo's
policies: StringEquals, StringNotEquals, StringLike, StringNotLike, ArnLike,
ArnNotLike, NumericGreaterThan. AWS missing-key semantics: negated operators
evaluate true when the context key is absent; positive operators evaluate
false.

Controls: PCI-DSS 7.2 (least privilege verification), SOC2 CC6.1/CC8.1.
"""

import fnmatch
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lib import loaders  # noqa: E402

REPO = loaders.REPO_ROOT
POLICY_DIR = REPO / "aws-terragrunt-configuration" / "aws" / "security" / "scp" / "policies"
FIXTURES = REPO / "scripts" / "fixtures" / "scp-cases.yaml"
WAIVERS = REPO / "scripts" / "config" / "scp-waivers.yaml"

NEGATED_OPS = {"StringNotEquals", "StringNotLike", "ArnNotLike"}


def glob_match(pattern, value):
    # IAM wildcards: * and ? (case-sensitive; fnmatchcase avoids [] semantics
    # by escaping brackets first)
    pattern = pattern.replace("[", "[[]")
    return fnmatch.fnmatchcase(value, pattern)


def as_list(x):
    return x if isinstance(x, list) else [x]


def condition_matches(operator, kv, context):
    """One operator block: ALL keys must match (AND)."""
    for key, expected in kv.items():
        expected = [str(e) for e in as_list(expected)]
        actual = context.get(key)
        if actual is None:
            if operator in NEGATED_OPS:
                continue  # absent key satisfies negated operators
            return False
        actual = str(actual)
        if operator == "StringEquals":
            if actual not in expected:
                return False
        elif operator == "StringNotEquals":
            if actual in expected:
                return False
        elif operator in ("StringLike", "ArnLike"):
            if not any(glob_match(p, actual) for p in expected):
                return False
        elif operator in ("StringNotLike", "ArnNotLike"):
            if any(glob_match(p, actual) for p in expected):
                return False
        elif operator == "NumericGreaterThan":
            if not float(actual) > float(expected[0]):
                return False
        else:
            raise ValueError(f"unsupported condition operator: {operator}")
    return True


def statement_denies(stmt, context):
    if stmt.get("Effect") != "Deny":
        return False
    action = context["action"]
    if "Action" in stmt:
        if not any(glob_match(p, action) for p in as_list(stmt["Action"])):
            return False
    elif "NotAction" in stmt:
        if any(glob_match(p, action) for p in as_list(stmt["NotAction"])):
            return False
    resource = context.get("resource", "*")
    resources = as_list(stmt.get("Resource", "*"))
    if not any(glob_match(p, resource) or p == "*" for p in resources):
        return False
    for op, kv in (stmt.get("Condition") or {}).items():
        if not condition_matches(op, kv, context):
            return False
    return True


def evaluate(policy, context):
    """'deny' if any Deny statement matches, else 'allow' (FullAWSAccess baseline)."""
    for stmt in as_list(policy.get("Statement", [])):
        if statement_denies(stmt, context):
            return "deny"
    return "allow"


def main():
    fixtures = (loaders.load_vars_yaml(FIXTURES) or {}).get("policies", {})
    waivers = {}
    if WAIVERS.exists():
        for w in (loaders.load_vars_yaml(WAIVERS) or {}).get("waivers", []) or []:
            if not w.get("reason"):
                print(f"ERROR: waiver for {w.get('file')} has no reason", file=sys.stderr)
                return 2
            waivers[w["file"]] = w["reason"]

    failures, warnings, passed = [], [], 0
    for pf in sorted(POLICY_DIR.glob("*.json")):
        name = pf.name
        text = pf.read_text(encoding="utf-8").strip()
        if not text:
            msg = f"{name}: empty policy file (would fail at apply)"
            if name in waivers:
                warnings.append(f"{msg} — WAIVED: {waivers[name]}")
            else:
                failures.append(msg)
            continue
        try:
            policy = json.loads(text)
        except ValueError as e:
            failures.append(f"{name}: invalid JSON ({e})")
            continue

        cases = (fixtures.get(name) or {}).get("cases", [])
        if len(cases) < 3:
            failures.append(f"{name}: only {len(cases)} fixture cases (>= 3 required)")
            continue
        for case in cases:
            got = evaluate(policy, case["context"])
            if got != case["expect"]:
                failures.append(f"{name} / {case['name']}: expected "
                                f"{case['expect']}, got {got}")
            else:
                passed += 1

    for w in warnings:
        print(f"WARN: {w}")
    print(f"validate-scp: {passed} cases passed, {len(failures)} failures, "
          f"{len(warnings)} waived")
    if failures:
        for f in failures:
            print(f"FAIL: {f}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
