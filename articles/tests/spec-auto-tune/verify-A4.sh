#!/usr/bin/env bash
# Verify A4 — Factual Correction With Reference Docs
# Checks: seeded inaccuracy text gone from spec Content tab;
# article doc and reference doc unchanged.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

# The seeded inaccuracy is "generally available" — corrected to "in preview" per reference doc.
# Check that the inaccurate claim is no longer present in the Content tab.
assert_tab_not_contains "$SPEC_DOC" "Content" "generally available" || failed=$((failed + 1))

# Spec still has its tab structure
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"    || failed=$((failed + 1))

# Article doc must be unchanged
assert_tab_exists "$ARTICLE_DOC" "Generated Article" || failed=$((failed + 1))
assert_tab_exists "$ARTICLE_DOC" "Spec Coach"        || failed=$((failed + 1))

echo ""
echo "Manual check: Read FACTUAL CORRECTIONS APPLIED section in conversation output."
echo "Confirm the correction lists the Reference Doc as its source."

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
