#!/usr/bin/env bash
# Verify P2 Step 2 — after second /spec-coach
# Checks: "Spec Coach" tab overwritten; seeded inaccuracy NOT in PART 4 (was corrected in P1).
# Saturation verdict stability is a manual check — compare to P1 Step 2 verdict.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

assert_tab_exists    "$ARTICLE_DOC" "Spec Coach"              || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "PART 1"    || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "PART 2"    || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "PART 3"    || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "PART 4"    || failed=$((failed + 1))
assert_tab_contains  "$ARTICLE_DOC" "Spec Coach" "SATURATION VERDICT" || failed=$((failed + 1))

echo ""
echo "Manual check: Read PART 4 of the new Spec Coach report."
echo "Confirm the seeded inaccuracy is NOT listed (it was corrected in P1 Step 3)."
echo "Compare SATURATION VERDICT to P1 Step 2 — it must not be worse."

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
