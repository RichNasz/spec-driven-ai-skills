#!/usr/bin/env bash
# Verify A9 — Author Feedback Recommendations Applied
# Checks: at least one spec tab changed; article doc unchanged (including Author Feedback tab).
# Note: The AUTHOR FEEDBACK CHANGES APPLIED report section is in the Claude conversation
# output and must be checked manually.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

# Spec doc tabs still exist
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"    || failed=$((failed + 1))

# Article doc unchanged (spec-auto-tune must not modify it)
assert_tab_exists "$ARTICLE_DOC" "Generated Article" || failed=$((failed + 1))
assert_tab_exists "$ARTICLE_DOC" "Spec Coach"        || failed=$((failed + 1))
assert_tab_exists "$ARTICLE_DOC" "Author Feedback"   || failed=$((failed + 1))

# At least one spec tab must have changed
if [[ ! -f /tmp/spec-snap-before-A9.txt ]]; then
    echo "WARN: /tmp/spec-snap-before-A9.txt not found — run setup-A9.sh before verify-A9.sh"
    failed=$((failed + 1))
else
    snapshot_tab_hashes "$SPEC_DOC" /tmp/spec-snap-after-A9.txt
    assert_any_tab_changed /tmp/spec-snap-before-A9.txt /tmp/spec-snap-after-A9.txt \
        || failed=$((failed + 1))
fi

echo ""
echo "MANUAL CHECK: Review the auto-tune report in the Claude conversation output."
echo "  - AUTHOR FEEDBACK CHANGES APPLIED section should list at least one change"
echo "  - Each entry should include the author's quoted feedback and the target tab"

if [[ "$failed" -eq 0 ]]; then
    echo ""
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo ""
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
