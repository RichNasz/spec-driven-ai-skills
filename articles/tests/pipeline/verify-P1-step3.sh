#!/usr/bin/env bash
# Verify P1 Step 3 — after /spec-auto-tune
# Checks: seeded inaccuracy gone from Spec Content tab; article doc tabs unchanged;
# Spec Doc still has all tabs.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

# Seeded inaccuracy corrected in spec Content tab
assert_tab_not_contains "$SPEC_DOC" "Content" "generally available" || failed=$((failed + 1))

# Spec still has all tabs
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"    || failed=$((failed + 1))

# Article doc tabs must be unchanged by spec-auto-tune
assert_tab_exists "$ARTICLE_DOC" "Generated Article" || failed=$((failed + 1))
assert_tab_exists "$ARTICLE_DOC" "Spec Coach"        || failed=$((failed + 1))

echo ""
echo "Manual check: Read conversation output."
echo "Confirm auto-tune report accounts for every Spec Coach recommendation."
echo "P1 complete. You may now run setup-P2.sh for the second iteration cycle."

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
