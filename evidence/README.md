# Evidence

Durable evidence bundles for the pre-production readiness gates (G0–G7).
Each gate writes to `evidence/<gate-id>/`, with timestamped bundles under
`evidence/<gate-id>/<UTC-timestamp>/` for repeated runs.

## Layout

```
evidence/
  G0/                     # baseline & instrumentation
    BASELINE.json         # machine-readable repo snapshot (regenerable)
    KNOWN_FAILURES.md     # honest record of broken state at baseline
    *.log                 # archived validate/lint/security output
  G1/ ... G7/             # one directory per gate
```

## Retention policy

- Keep the **last 10 timestamped bundles per gate**; prune older ones.
- Git-tracked: `*.md` and `*.json` summaries, plus anything referenced from a
  gate's exit-criteria table. Raw logs (`*.log`, `*.txt`) and plan binaries are
  ignored via `.gitignore` in this directory — CI retains plan artifacts for
  30 days and the bundle records their artifact IDs instead.
- Bundles referenced by a closed gate's `GATE_ACTIVATION.md` or
  `PROMOTION_READINESS.md` are never pruned.

## Regeneration

Regenerable artifacts state their generator in their header. Non-regenerable
records (gate activation, promotion readiness, CI run URLs) are permanent.
