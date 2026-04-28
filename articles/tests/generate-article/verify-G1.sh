#!/usr/bin/env bash
# Verify G1 — Same-Doc Guard
# Confirms no tab was created or modified in the spec doc after the skill
# rejected the same-doc config.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
failed=0

# Skill must not have created a "Generated Article" tab
assert_tab_absent "$SPEC_DOC" "Generated Article" || failed=$((failed + 1))

# Spec doc tab count unchanged — exactly 5 canonical tabs
assert_tab_count "$SPEC_DOC" 5 || failed=$((failed + 1))

echo ""
echo "Manual check: confirm Claude emitted exactly:"
echo '  "Source and destination cannot be the same document."'

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
