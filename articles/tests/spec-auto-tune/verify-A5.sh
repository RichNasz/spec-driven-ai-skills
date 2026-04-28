#!/usr/bin/env bash
# Verify A5 — Over-Determined Spec Blocks Additions
# Checks: Over-Determined Spec Doc tab structure intact; article doc unchanged.
# Manual check required for RECOMMENDATIONS NOT APPLIED section in conversation.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

OVER_DET_DOC=$(get_doc_id "over_determined_spec")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

# Over-Determined Spec Doc still has its tabs
assert_tab_exists "$OVER_DET_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$OVER_DET_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$OVER_DET_DOC" "Content"    || failed=$((failed + 1))

# Article doc unchanged
assert_tab_exists "$ARTICLE_DOC" "Spec Coach" || failed=$((failed + 1))

echo ""
echo "Manual check: Read RECOMMENDATIONS NOT APPLIED in conversation output."
echo "Confirm at least one entry cites OVER-DETERMINED as the reason for skipping."
echo "Confirm CONSTRAINT CHANGES APPLIED shows at least one removal."

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
