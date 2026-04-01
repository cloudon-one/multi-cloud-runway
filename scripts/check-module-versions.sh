#!/usr/bin/env bash
# Audit upstream module versions across all GCP terraform modules
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${SCRIPT_DIR}/../gcp-terragrunt-configuration/tf-modules"

echo "GCP Upstream Module Versions"
echo "============================"
echo ""
printf "%-35s %-25s %-55s %s\n" "LOCAL MODULE" "BLOCK NAME" "UPSTREAM SOURCE" "VERSION"
printf "%s\n" "$(printf -- '-%.0s' {1..140})"

for tf_file in $(find "$MODULES_DIR" -maxdepth 3 -name "*.tf" | sort); do
    module_dir=$(basename "$(dirname "$tf_file")")
    awk -v module_dir="$module_dir" '
    # Detect start of a top-level module block (POSIX character classes; BSD awk safe)
    /^[[:space:]]*module[[:space:]]+"[^"]*"[[:space:]]*\{/ {
        in_module = 1
        depth = 1
        label = $0
        sub(/^[^"]*"/, "", label)
        sub(/".*/, "", label)
        block_name = label
        src = ""
        ver = ""
        next
    }
    in_module {
        # Count { and } on this line to track nesting depth
        opn = $0
        gsub(/[^{]/, "", opn)
        cls = $0
        gsub(/[^}]/, "", cls)
        depth += length(opn) - length(cls)

        # Extract source (skip local relative paths starting with ./)
        if (/^[[:space:]]*source[[:space:]]*=[[:space:]]*"/) {
            val = $0
            sub(/^[^"]*"/, "", val)
            sub(/".*/, "", val)
            if (substr(val, 1, 2) != "./") {
                src = val
            }
        } else if (/^[[:space:]]*version[[:space:]]*=[[:space:]]*"/) {
            # Extract version, stripping any leading "= " inside the quoted value
            val = $0
            sub(/^[^"]*"/, "", val)
            sub(/".*/, "", val)
            sub(/^=[[:space:]]*/, "", val)
            ver = val
        }

        # When depth reaches 0 the module block is closed
        if (depth <= 0) {
            if (src != "" && ver != "") {
                printf "%-35s %-25s %-55s %s\n", module_dir, block_name, src, ver
            }
            in_module = 0
            block_name = ""
            src = ""
            ver = ""
        }
    }
    ' "$tf_file"
done
