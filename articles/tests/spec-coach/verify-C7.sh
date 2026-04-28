#!/usr/bin/env bash
# Verify C7 — Rubric Inference (No Explicit Rubric in Spec)
# Checks: "Spec Coach" tab exists; report notes rubric was inferred; COMPOSITE SCORE present.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

assert_tab_exists "$ARTICLE_DOC" "Spec Coach" || failed=$((failed + 1))
assert_tab_contains "$ARTICLE_DOC" "Spec Coach" "COMPOSITE SCORE" || failed=$((failed + 1))
# Report must note that the rubric was inferred
assert_tab_matches "$ARTICLE_DOC" "Spec Coach" "inferred|no explicit rubric" || failed=$((failed + 1))

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
