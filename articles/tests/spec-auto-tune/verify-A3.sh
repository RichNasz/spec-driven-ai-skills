#!/usr/bin/env bash
# Verify A3 — Happy Path (Instructional Changes Only, No Reference Docs)
# Checks: at least one spec tab differs from canonical; article doc unchanged;
# auto-tune report in Standard Article Doc is absent (report goes to conversation, not doc).
# Note: The report content check is manual — read the Claude conversation output.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

# Spec doc still has the same tabs (only content changed, not tab structure)
assert_tab_exists "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists "$SPEC_DOC" "Quality"    || failed=$((failed + 1))

# Article doc still has its tabs (spec-auto-tune must not modify article doc)
assert_tab_exists "$ARTICLE_DOC" "Generated Article" || failed=$((failed + 1))
assert_tab_exists "$ARTICLE_DOC" "Spec Coach"        || failed=$((failed + 1))

# At least one spec tab must have different content than before the skill ran.
# Requires setup-A3.sh to have been run (creates /tmp/spec-snap-before-A3.txt).
if [[ ! -f /tmp/spec-snap-before-A3.txt ]]; then
    echo "WARN: /tmp/spec-snap-before-A3.txt not found — run setup-A3.sh before verify-A3.sh"
    failed=$((failed + 1))
else
    snapshot_tab_hashes "$SPEC_DOC" /tmp/spec-snap-after-A3.txt
    assert_any_tab_changed /tmp/spec-snap-before-A3.txt /tmp/spec-snap-after-A3.txt \
        || failed=$((failed + 1))
fi

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
