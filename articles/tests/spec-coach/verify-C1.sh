#!/usr/bin/env bash
# Verify C1 — Same-Doc Guard
# Confirms no "Spec Coach" tab was created and the doc is untouched.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
failed=0

# Skill must not have created a "Spec Coach" tab
assert_tab_absent "$SPEC_DOC" "Spec Coach" || failed=$((failed + 1))

# Spec doc tab count unchanged — exactly 5 canonical tabs
assert_tab_count "$SPEC_DOC" 5 || failed=$((failed + 1))

echo ""
echo "Manual check: confirm Claude emitted exactly:"
echo '  "Spec and article cannot be the same document."'

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
