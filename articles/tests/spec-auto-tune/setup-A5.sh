#!/usr/bin/env bash
# Setup for A5 — Over-Determined Spec Blocks Additions
# Prerequisites: Over-Determined Spec Doc in canonical state; Standard Article Doc
# has a "Spec Coach" tab produced by running spec-coach against the Over-Determined
# Spec Doc (C5 scenario).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

OVER_DET_DOC=$(get_doc_id "over_determined_spec")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")

echo "Restoring Over-Determined Spec Doc to canonical state..."
restore_spec_doc "$OVER_DET_DOC" "$CONTENT_DIR/over-determined-spec"

require_tab "$ARTICLE_DOC" "Spec Coach" \
    "Run setup-C5.sh then generate-article + /spec-coach against the over-determined spec first."

echo "A5 setup complete."
echo ""
echo "Invocation:"
echo "  /spec-auto-tune specs/fixtures/config-over-determined.yaml"
echo ""
echo "Note: Reset Over-Determined Spec Doc after this test."
