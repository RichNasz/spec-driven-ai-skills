#!/usr/bin/env bash
# Verify C11 — Author Feedback Conflicts with Part 2 Recommendation
# Checks: Part 5 present; CONFLICTS WITH OTHER PARTS is non-empty;
# PRESERVE markers present; Author Feedback tab unchanged.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
SPEC_DOC=$(get_doc_id "standard_spec_doc")
failed=0

assert_tab_exists "$ARTICLE_DOC" "Spec Coach" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "PART 5" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "AUTHOR FEEDBACK ANALYSIS" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "CONFLICTS WITH OTHER PARTS" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "PRESERVE" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "POSITIVE OBSERVATIONS" || failed=$((failed + 1))

# Author Feedback tab unchanged
assert_tab_exists "$ARTICLE_DOC" "Author Feedback" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Author Feedback" "dedicated paragraph" || failed=$((failed + 1))

# Spec doc unchanged
assert_tab_exists "$SPEC_DOC" "Context" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality" || failed=$((failed + 1))

echo ""
echo "MANUAL CHECK: Review the CONFLICTS WITH OTHER PARTS section in Part 5."
echo "  - At least one entry should reference 'Part 2'"
echo "  - The resolution should state that the author's preference takes precedence"

if [[ "$failed" -eq 0 ]]; then
    echo ""
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo ""
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
