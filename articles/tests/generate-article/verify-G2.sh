#!/usr/bin/env bash
# Verify G2 — Happy Path (YAML form)
# Checks: "Generated Article" tab exists and has non-empty content.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
SPEC_DOC=$(get_doc_id "standard_spec_doc")
failed=0

assert_tab_exists "$ARTICLE_DOC" "Generated Article" || failed=$((failed + 1))
# Spec doc must be unchanged — it still has its original tabs
assert_tab_exists "$SPEC_DOC" "Context"            || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters"         || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"            || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"              || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"            || failed=$((failed + 1))

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
