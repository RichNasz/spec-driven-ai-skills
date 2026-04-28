#!/usr/bin/env bash
# Setup for G2 — Happy Path (YAML form)
# Resets Standard Article Doc to empty state.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
reset_article_doc "$ARTICLE_DOC"

echo ""
echo "Invocation:"
echo "  /generate-article specs/fixtures/config-standard.yaml"
