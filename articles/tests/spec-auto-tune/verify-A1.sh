#!/usr/bin/env bash
# Verify A1 — Same-Doc Guard
# Confirms no modifications were made to the spec doc after the skill
# rejected the same-doc config.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
failed=0

# Spec doc tab count unchanged — exactly 5 canonical tabs
assert_tab_count "$SPEC_DOC" 5 || failed=$((failed + 1))

# Skill must not have created any unexpected tabs
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"    || failed=$((failed + 1))

echo ""
echo "Manual check: confirm Claude emitted exactly:"
echo '  "Spec and article cannot be the same document."'

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
