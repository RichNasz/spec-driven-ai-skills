#!/usr/bin/env bash
# Verify P3 Step 2 — after /spec-coach with non-default article tab
# Checks: "Spec Coach" tab exists; report has substantive content (not empty).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

assert_tab_exists    "$ARTICLE_DOC" "Spec Coach"                     || failed=$((failed + 1))
assert_tab_exists    "$ARTICLE_DOC" "Custom Article Tab"             || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "PART 1"           || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "PART 2"           || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "COMPOSITE SCORE"  || failed=$((failed + 1))

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED — P3 complete."
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
