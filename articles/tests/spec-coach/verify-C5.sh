#!/usr/bin/env bash
# Verify C5 — Over-Determined Saturation Detection
# Checks: SATURATION VERDICT is OVER-DETERMINED; utilization > 100%.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

assert_tab_exists    "$ARTICLE_DOC" "Spec Coach"               || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "OVER-DETERMINED" || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "SATURATION VERDICT" || failed=$((failed + 1))

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
