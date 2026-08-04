# Branch Protection Requirements (G2-7)

Operator checklist for `main` (GitHub → Settings → Branches → Add rule).
**Precondition: the org's Actions billing lock must be resolved first**, or
required status checks will block every merge.

| Setting | Value |
|---|---|
| Require a pull request before merging | on |
| Required approvals | ≥ 1 |
| Require review from Code Owners | on (pairs with `.github/CODEOWNERS`) |
| Dismiss stale approvals on new commits | on |
| Required status checks | `architecture-score`, `placeholder-gate`, `doc-freshness`, `security-scan` (add `terragrunt-validate-stg`, `terragrunt-plan-stg`, `policy-as-code` when flipped per `evidence/G2/GATE_ACTIVATION.md`) |
| Require branches up to date | on |
| Restrict force pushes / deletions | on |

Do **not** mark `input-assertions` required until G5 flips it (plan G5-7).
