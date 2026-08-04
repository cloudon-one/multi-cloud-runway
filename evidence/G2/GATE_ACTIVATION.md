# G2 Gate Activation Record (G2-9)

Mode: **local enforcement** — the `cloudon-one` org's GitHub Actions billing
lock (G0 KNOWN_FAILURES #10) prevents any CI job from starting, so gates are
enforced via `make preprod-gates-local` (same scripts, same thresholds file)
until CI is unlocked. User accepted local-test enforcement on 2026-08-04.

## Job blocking matrix (as authored in `.github/workflows/preprod-gates.yml`)

| Job | State | Blocking condition |
|---|---|---|
| architecture-score | **blocking** (threshold 20 = G1 baseline warn-level; ratchet up) | active now, locally |
| placeholder-gate | **blocking** | active now, locally |
| doc-freshness | **blocking** | active now, locally |
| security-scan | **blocking** (thresholds = measured baseline; ratchet down) | active now, locally |
| input-assertions | advisory (`continue-on-error`) | flips blocking in G5 (plan G5-7) |
| terragrunt-validate-stg | advisory (`continue-on-error`) | flip when OIDC roles exist (docs/preprod/CI_IDENTITY.md) |
| terragrunt-plan-stg | advisory (`continue-on-error`) | flip with validate-stg |
| policy-as-code | advisory placeholder | flips blocking in G3 (plan G3-15) |
| evidence-bundle | always runs | n/a |

## Exit-criterion evidence (local equivalent of the broken-PR test)

CI cannot reject a PR while billing-locked, so the deliberately-broken state
was injected locally and each gate had to reject it —
`evidence/G2/gates-local-broken-test.log` (2026-08-04T05:07:41Z):

| Injected breakage | Gate | Result |
|---|---|---|
| `PLACEHOLDER_ACCOUNT_ID_BROKEN_TEST` token in a yaml | placeholder-gate | **rejected** (exit 1) |
| Wildcard `Allow Action:*` policy json in the AWS tree | architecture-score | **rejected** (score 23.5 → 15.5 < 20, exit 1) |
| Hand-edit to generated `NETWORK_TOPOLOGY.md` | doc-freshness | **rejected** (exit 1) |
| (revert) | all three | pass again (exit 0) |

## Pending flips (record commit SHAs here when done)

1. Org billing unlocked → verify `Pre-Production Gates` workflow runs green on
   a no-op PR, then repeat the broken-PR test **in CI** and archive the run URL.
2. OIDC roles created (CI_IDENTITY.md) → flip `terragrunt-validate-stg` /
   `terragrunt-plan-stg` `continue-on-error` to `false`.
3. Branch protection enabled per docs/preprod/BRANCH_PROTECTION.md.
