#!/usr/bin/env bash
# Verify A2 — Missing "Spec Coach" Tab
# Confirms spec doc is untouched and article doc has no new "Spec Coach" tab.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

# Article doc: "Generated Article" present, "Spec Coach" must not have been created
assert_tab_exists "$ARTICLE_DOC" "Generated Article" || failed=$((failed + 1))
assert_tab_absent "$ARTICLE_DOC" "Spec Coach"        || failed=$((failed + 1))

# Spec doc: must be completely untouched
assert_tab_count  "$SPEC_DOC" 5     || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"    || failed=$((failed + 1))

echo ""
echo "Manual check: confirm Claude emitted exactly:"
echo "  \"No 'Spec Coach' tab found in the article document. Run /spec-coach first.\""

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
