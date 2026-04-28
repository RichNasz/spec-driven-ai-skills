#!/usr/bin/env bash
# Verify C6 — Empty reference_docs List
# Checks: three-part report (no PART 4); skip notice present.
# Identical behavior to C2 despite explicit empty reference_docs list.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

assert_tab_exists        "$ARTICLE_DOC" "Spec Coach"   || failed=$((failed + 1))
assert_tab_contains      "$ARTICLE_DOC" "Spec Coach" "PART 1" || failed=$((failed + 1))
assert_tab_contains      "$ARTICLE_DOC" "Spec Coach" "PART 2" || failed=$((failed + 1))
assert_tab_contains      "$ARTICLE_DOC" "Spec Coach" "PART 3" || failed=$((failed + 1))
assert_tab_not_contains  "$ARTICLE_DOC" "Spec Coach" "PART 4" || failed=$((failed + 1))
assert_tab_contains      "$ARTICLE_DOC" "Spec Coach" "skipped" || failed=$((failed + 1))

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
