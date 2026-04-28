#!/usr/bin/env bash
# Setup for G7 — Unknown YAML Keys Ignored
# Resets Standard Article Doc. Uses config-with-refs.yaml (contains reference_docs key).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
reset_article_doc "$ARTICLE_DOC"

echo ""
echo "Invocation:"
echo "  /generate-article specs/fixtures/config-with-refs.yaml"
echo ""
echo "Expected tab name: \"Generated Article\" (from dest_tab_name in config-with-refs.yaml)"
