#!/usr/bin/env bash
# Verify A6 — Tab Reorder Becomes Manual Instruction
# Checks: Standard Spec Doc tab order is unchanged (tabs still exist in original order).
# Manual check required for MANUAL STEPS REQUIRED section in conversation output.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
failed=0

# All five canonical tabs still present (order is not verifiable via find_tab, but
# confirms no tab was deleted as part of a reorder attempt)
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"    || failed=$((failed + 1))
assert_tab_count  "$SPEC_DOC" 5            || failed=$((failed + 1))

echo ""
echo "Manual check: Read MANUAL STEPS REQUIRED in conversation output."
echo "Confirm it names the tab, current position, target position, and UI steps."
echo "Confirm no API call attempted to reorder tabs."

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
