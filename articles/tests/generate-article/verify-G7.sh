#!/usr/bin/env bash
# Verify G7 — Unknown YAML Keys Ignored
# Checks: tab named per dest_tab_name in config-with-refs.yaml ("Generated Article") exists.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

# dest_tab_name in config-with-refs.yaml is "Generated Article"
assert_tab_exists "$ARTICLE_DOC" "Generated Article" || failed=$((failed + 1))

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
