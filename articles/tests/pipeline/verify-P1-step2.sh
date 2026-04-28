#!/usr/bin/env bash
# Verify P1 Step 2 — after /spec-coach
# Checks: "Spec Coach" tab exists with four parts; seeded inaccuracy present in PART 4;
# Spec Doc unchanged; Reference Doc unchanged (has its tab).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

assert_tab_exists    "$ARTICLE_DOC" "Spec Coach"              || failed=$((failed + 1))
assert_tab_exists    "$ARTICLE_DOC" "Generated Article"       || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "PART 4"    || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "INACCURAC"  || failed=$((failed + 1))

# Spec doc must still be in canonical state
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"    || failed=$((failed + 1))

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED — proceed to Step 3: /spec-auto-tune specs/fixtures/config-with-refs.yaml"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
