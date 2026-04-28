#!/usr/bin/env bash
# Setup for G1 — Same-Doc Guard
# No fixture state to prepare; config-same-doc.yaml is pre-existing.
# This script just confirms the fixture file exists.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

CONFIG="specs/fixtures/config-same-doc.yaml"
if [[ ! -f "$CONFIG" ]]; then
    echo "ERROR: $CONFIG not found"
    exit 1
fi

echo "G1 setup complete. Config file present: $CONFIG"
echo ""
echo "Invocation:"
echo "  /generate-article specs/fixtures/config-same-doc.yaml"
echo ""
echo "Expected: Claude emits exactly: \"Source and destination cannot be the same document.\""
echo "After invocation: ./tests/generate-article/verify-G1.sh"
