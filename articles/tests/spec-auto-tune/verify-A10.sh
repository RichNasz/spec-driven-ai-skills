#!/usr/bin/env bash
# Verify A10 — PRESERVE Marker Blocks TAB_REMOVAL
# Checks: article doc unchanged; spec doc tabs still exist.
# Note: The key check — that a TAB_REMOVAL was blocked by a PRESERVE marker — must
# be verified manually in the Claude conversation output (RECOMMENDATIONS NOT APPLIED).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

# Spec doc tabs still exist (none deleted)
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"    || failed=$((failed + 1))

# Article doc unchanged (including Author Feedback tab)
assert_tab_exists "$ARTICLE_DOC" "Generated Article" || failed=$((failed + 1))
assert_tab_exists "$ARTICLE_DOC" "Spec Coach"        || failed=$((failed + 1))
assert_tab_exists "$ARTICLE_DOC" "Author Feedback"   || failed=$((failed + 1))

echo ""
echo "MANUAL CHECK: Review the auto-tune report in the Claude conversation output."
echo "  - RECOMMENDATIONS NOT APPLIED should list at least one TAB_REMOVAL blocked by PRESERVE"
echo "  - The entry should include 'author feedback' or 'PRESERVE' in the reason"
echo "  - The entry should include the author's quoted feedback"

if [[ "$failed" -eq 0 ]]; then
    echo ""
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo ""
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
