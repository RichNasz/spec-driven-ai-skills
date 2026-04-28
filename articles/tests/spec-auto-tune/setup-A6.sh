#!/usr/bin/env bash
# Setup for A6 — Tab Reorder Becomes Manual Instruction
# Prerequisites: Standard Spec Doc in canonical state; Standard Article Doc has
# a "Spec Coach" tab whose PART 3 recommends moving a tab to a different position.
# If the C2/C3 report does not naturally contain a reorder recommendation,
# manually add one to the "Spec Coach" tab before running.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")

echo "Restoring Standard Spec Doc to canonical state..."
restore_spec_doc "$SPEC_DOC" "$CONTENT_DIR/standard-spec"

require_tab "$ARTICLE_DOC" "Spec Coach" \
    "Ensure a Spec Coach tab exists with a TAB_REORDER recommendation in PART 3."

echo ""
echo "If PART 3 of the Spec Coach report does not contain a reorder recommendation,"
echo "manually edit the 'Spec Coach' tab to add one under PART 3 before running."
echo ""
echo "Invocation:"
echo "  /spec-auto-tune specs/fixtures/config-standard.yaml"
