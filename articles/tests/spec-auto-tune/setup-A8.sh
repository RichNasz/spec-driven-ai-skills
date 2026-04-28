#!/usr/bin/env bash
# Setup for A8 — NEEDS_RESEARCH Without Reference Docs
# Prerequisites: Standard Spec Doc in canonical state; Standard Article Doc has
# a "Spec Coach" tab that includes at least one NEEDS_RESEARCH recommendation.
# If the C2 report doesn't naturally contain one, manually add it to the Spec Coach tab.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")

echo "Restoring Standard Spec Doc to canonical state..."
restore_spec_doc "$SPEC_DOC" "$CONTENT_DIR/standard-spec"

require_tab "$ARTICLE_DOC" "Spec Coach" \
    "Run setup-C2.sh then /spec-coach specs/fixtures/config-standard.yaml first."

echo ""
echo "If the Spec Coach report does not naturally contain a NEEDS_RESEARCH recommendation,"
echo "manually add one to the 'Spec Coach' tab under PART 2's 'BEYOND THE CEILING' section:"
echo "  \"Add concrete examples of [product capability] to Tab 3.\""
echo ""
echo "Invocation:"
echo "  /spec-auto-tune specs/fixtures/config-standard.yaml"
