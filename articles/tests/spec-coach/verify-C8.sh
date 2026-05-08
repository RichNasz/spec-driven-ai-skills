#!/usr/bin/env bash
# Verify C8 — Happy Path with Author Feedback (No Reference Docs)
# Checks: "Spec Coach" tab exists; Parts 1-3 and 5 present; Part 4 absent;
# Part 5 has FEEDBACK SOURCE, POSITIVE OBSERVATIONS, SPEC CHANGE RECOMMENDATIONS;
# Author Feedback tab unchanged; Spec Doc unchanged.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
SPEC_DOC=$(get_doc_id "standard_spec_doc")
failed=0

assert_tab_exists "$ARTICLE_DOC" "Spec Coach" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "PART 1" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "PART 2" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "PART 3" || failed=$((failed + 1))
assert_tab_not_contains "$ARTICLE_DOC" "Spec Coach" "PART 4" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "PART 5" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "AUTHOR FEEDBACK ANALYSIS" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "FEEDBACK SOURCE" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "POSITIVE OBSERVATIONS" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "SPEC CHANGE RECOMMENDATIONS" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "PRESERVE" || failed=$((failed + 1))

# Author Feedback tab must still exist with original content
assert_tab_exists "$ARTICLE_DOC" "Author Feedback" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Author Feedback" "conversational tone" || failed=$((failed + 1))

# Spec doc unchanged
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"    || failed=$((failed + 1))

echo ""
echo "MANUAL CHECK: Review the Spec Coach tab in the article doc."
echo "  - EXECUTIVE SUMMARY should include an 'Author Feedback:' line with item counts"
echo "  - Factual accuracy audit line should say 'skipped'"
echo "  - POSITIVE OBSERVATIONS entries should reference specific spec tabs"
echo "  - SPEC CHANGE RECOMMENDATIONS entries should include Category, Target, Change, Rationale"

if [[ "$failed" -eq 0 ]]; then
    echo ""
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo ""
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
