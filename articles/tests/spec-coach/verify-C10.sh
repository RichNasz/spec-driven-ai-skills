#!/usr/bin/env bash
# Verify C10 — Empty Author Feedback Tab
# Checks: Parts 1-3 present; Part 4 and Part 5 absent; skip notices present.
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
assert_tab_not_contains "$ARTICLE_DOC" "Spec Coach" "PART 5" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "Author feedback analysis: skipped" || failed=$((failed + 1))

# Spec doc unchanged
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
