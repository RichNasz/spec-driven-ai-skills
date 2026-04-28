#!/usr/bin/env bash
# Verify A8 — NEEDS_RESEARCH Without Reference Docs
# Checks: spec tab structure intact; article doc unchanged.
# Manual check required: RECOMMENDATIONS NOT APPLIED must list the NEEDS_RESEARCH item.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

assert_tab_exists  "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists  "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists  "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists  "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists  "$SPEC_DOC" "Quality"    || failed=$((failed + 1))

assert_tab_exists "$ARTICLE_DOC" "Spec Coach" || failed=$((failed + 1))

echo ""
echo "Manual check: Read RECOMMENDATIONS NOT APPLIED in conversation output."
echo "Confirm the NEEDS_RESEARCH item is listed with reason about no reference doc."
echo "Open the spec tab that would have been affected — confirm it is unchanged."

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
