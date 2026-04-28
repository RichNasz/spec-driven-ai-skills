#!/usr/bin/env bash
# Setup for C1 — Same-Doc Guard
# No fixture state to prepare; config-same-doc.yaml is pre-existing.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

CONFIG="specs/fixtures/config-same-doc.yaml"
if [[ ! -f "$CONFIG" ]]; then
    echo "ERROR: $CONFIG not found"
    exit 1
fi

echo "C1 setup complete. Config file present: $CONFIG"
echo ""
echo "Invocation:"
echo "  /spec-coach specs/fixtures/config-same-doc.yaml"
echo ""
echo "Expected: Claude emits exactly: \"Spec and article cannot be the same document.\""
echo "After invocation: ./tests/spec-coach/verify-C1.sh"
