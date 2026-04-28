#!/usr/bin/env bash
# Verify A7 — Idempotence
# Checks: Standard Spec Doc tab structure intact (no duplicated content added).
# Manual check required: compare spec content before vs after second run.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
failed=0

assert_tab_exists  "$SPEC_DOC" "Context"    || failed=$((failed + 1))
assert_tab_exists  "$SPEC_DOC" "Parameters" || failed=$((failed + 1))
assert_tab_exists  "$SPEC_DOC" "Content"    || failed=$((failed + 1))
assert_tab_exists  "$SPEC_DOC" "Style"      || failed=$((failed + 1))
assert_tab_exists  "$SPEC_DOC" "Quality"    || failed=$((failed + 1))
assert_tab_count   "$SPEC_DOC" 5            || failed=$((failed + 1))

# No tab content should have changed on the second run.
# Requires setup-A7.sh to have been run (creates /tmp/spec-snap-before-A7.txt).
if [[ ! -f /tmp/spec-snap-before-A7.txt ]]; then
    echo "WARN: /tmp/spec-snap-before-A7.txt not found — run setup-A7.sh before verify-A7.sh"
    failed=$((failed + 1))
else
    snapshot_tab_hashes "$SPEC_DOC" /tmp/spec-snap-after-A7.txt
    assert_no_tab_changed /tmp/spec-snap-before-A7.txt /tmp/spec-snap-after-A7.txt \
        || failed=$((failed + 1))
fi

echo ""
echo "Manual check: confirm the conversation report notes previously applied changes"
echo "as 'already present' rather than re-applying them."

if [[ "$failed" -eq 0 ]]; then
    echo "ALL AUTOMATED CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
