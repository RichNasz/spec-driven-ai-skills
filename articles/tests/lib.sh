#!/usr/bin/env bash
# Shared test utilities. Source this file from all test scripts.
# Must be sourced from the project root: source tests/lib.sh

SCRIPTS_DIR=".claude/skills/gws-utils/scripts"
FIXTURES_YAML="specs/fixtures/fixtures.yaml"
CONTENT_DIR="specs/fixtures/content"

_check_root() {
    if [[ ! -f "$FIXTURES_YAML" ]]; then
        echo "ERROR: Run test scripts from the project root (articles/)."
        exit 1
    fi
}
_check_root

# Extract Google Doc ID from fixtures.yaml by fixture key name.
get_doc_id() {
    local name="$1"
    grep "^${name}:" "$FIXTURES_YAML" | sed 's|.*document/d/\([^/]*\)/.*|\1|'
}

# Parse read_doc.py stdout into one "index tabId endIndex" record per line.
# Call as: echo "$raw_output" | _parse_tabs
_parse_tabs() {
    python3 -c "
import sys, re
for line in sys.stdin:
    m = re.match(r'^=== TAB (\d+): .* \| ID: (\S+) \| endIndex=(\d+) ===$', line.rstrip())
    if m:
        print(m.group(1), m.group(2), m.group(3))
"
}

# Extract the text content of a named tab from read_doc.py stdout.
# Usage: echo "$raw_output" | _extract_tab "Tab Name"
_extract_tab() {
    TAB_NAME="$1" python3 -c "
import sys, os
tab_name = os.environ['TAB_NAME']
in_tab = False
result = []
for line in sys.stdin.read().split('\n'):
    if '=== TAB' in line and ': ' + tab_name + ' | ' in line:
        in_tab = True
        continue
    if '=== TAB' in line and in_tab:
        break
    if in_tab:
        result.append(line)
print('\n'.join(result))
"
}

# ── Assert helpers ──────────────────────────────────────────────────────────

_pass() { echo "PASS: $*"; }
_fail() { echo "FAIL: $*"; return 1; }

assert_tab_exists() {
    local doc_id="$1" tab_name="$2"
    if python3 "$SCRIPTS_DIR/find_tab.py" "$doc_id" "$tab_name" > /dev/null 2>&1; then
        _pass "tab '$tab_name' exists"
    else
        _fail "tab '$tab_name' not found"
    fi
}

assert_tab_absent() {
    local doc_id="$1" tab_name="$2"
    if python3 "$SCRIPTS_DIR/find_tab.py" "$doc_id" "$tab_name" > /dev/null 2>&1; then
        _fail "tab '$tab_name' exists but should not"
    else
        _pass "tab '$tab_name' correctly absent"
    fi
}

assert_tab_contains() {
    local doc_id="$1" tab_name="$2" search_string="$3"
    local raw tab_content
    raw=$(python3 "$SCRIPTS_DIR/read_doc.py" "$doc_id" 2>/dev/null) || {
        _fail "could not read doc $doc_id"
        return 1
    }
    tab_content=$(echo "$raw" | _extract_tab "$tab_name")
    if echo "$tab_content" | grep -qF "$search_string"; then
        _pass "tab '$tab_name' contains '$search_string'"
    else
        _fail "tab '$tab_name' does not contain '$search_string'"
    fi
}

assert_tab_not_contains() {
    local doc_id="$1" tab_name="$2" search_string="$3"
    local raw tab_content
    raw=$(python3 "$SCRIPTS_DIR/read_doc.py" "$doc_id" 2>/dev/null) || {
        _fail "could not read doc $doc_id"
        return 1
    }
    tab_content=$(echo "$raw" | _extract_tab "$tab_name")
    if echo "$tab_content" | grep -qF "$search_string"; then
        _fail "tab '$tab_name' contains '$search_string' but should not"
    else
        _pass "tab '$tab_name' correctly does not contain '$search_string'"
    fi
}

# Assert tab content contains a string matching a grep-E pattern.
assert_tab_matches() {
    local doc_id="$1" tab_name="$2" pattern="$3"
    local raw tab_content
    raw=$(python3 "$SCRIPTS_DIR/read_doc.py" "$doc_id" 2>/dev/null) || {
        _fail "could not read doc $doc_id"
        return 1
    }
    tab_content=$(echo "$raw" | _extract_tab "$tab_name")
    if echo "$tab_content" | grep -qE "$pattern"; then
        _pass "tab '$tab_name' matches pattern '$pattern'"
    else
        _fail "tab '$tab_name' does not match pattern '$pattern'"
    fi
}

# Count tabs in a doc. Prints count to stdout.
count_tabs() {
    local doc_id="$1"
    python3 "$SCRIPTS_DIR/read_doc.py" "$doc_id" 2>/dev/null | _parse_tabs | wc -l | tr -d ' '
}

assert_tab_count() {
    local doc_id="$1" expected="$2"
    local actual
    actual=$(count_tabs "$doc_id")
    if [[ "$actual" -eq "$expected" ]]; then
        _pass "doc has $expected tab(s)"
    else
        _fail "doc has $actual tab(s), expected $expected"
    fi
}

# Snapshot content hashes of all tabs in a doc to a file.
# Output format: one "<tabId> <md5hash>" line per tab.
# Use with assert_any_tab_changed / assert_no_tab_changed.
snapshot_tab_hashes() {
    local doc_id="$1" outfile="$2"
    local raw
    raw=$(python3 "$SCRIPTS_DIR/read_doc.py" "$doc_id" 2>/dev/null) || {
        echo "ERROR: could not read doc $doc_id"
        return 1
    }
    echo "$raw" | python3 -c "
import sys, hashlib, re
content = sys.stdin.read()
lines = content.split('\n')
current_tab_id = None
current_lines = []
results = []
for line in lines:
    m = re.match(r'^=== TAB \d+: .* \| ID: (\S+) \| endIndex=\d+ ===$', line)
    if m:
        if current_tab_id:
            h = hashlib.md5('\n'.join(current_lines).encode()).hexdigest()
            results.append(current_tab_id + ' ' + h)
        current_tab_id = m.group(1)
        current_lines = []
    elif current_tab_id is not None:
        current_lines.append(line)
if current_tab_id:
    h = hashlib.md5('\n'.join(current_lines).encode()).hexdigest()
    results.append(current_tab_id + ' ' + h)
print('\n'.join(results))
" > "$outfile"
    local count
    count=$(wc -l < "$outfile" | tr -d ' ')
    echo "Snapshotted $count tab(s) to $outfile"
}

# Assert that at least one tab's content hash changed between two snapshots.
assert_any_tab_changed() {
    local before_file="$1" after_file="$2"
    if diff -q "$before_file" "$after_file" > /dev/null 2>&1; then
        _fail "no tab content changed — skill made no modifications to the doc"
    else
        _pass "at least one tab's content changed"
    fi
}

# Assert that no tab's content changed between two snapshots (idempotence check).
assert_no_tab_changed() {
    local before_file="$1" after_file="$2"
    if diff -q "$before_file" "$after_file" > /dev/null 2>&1; then
        _pass "no tab content changed (idempotent as expected)"
    else
        local changed
        changed=$(diff "$before_file" "$after_file" | grep -c '^[<>]')
        _fail "$changed hash line(s) differ — content changed on second run (not idempotent)"
    fi
}

# ── Fixture management ──────────────────────────────────────────────────────

# Reset Standard Article Doc to empty state: delete all tabs except the first,
# then clear the first tab's content.
reset_article_doc() {
    local doc_id="$1"
    local raw tab_data
    raw=$(python3 "$SCRIPTS_DIR/read_doc.py" "$doc_id" 2>/dev/null) || {
        echo "ERROR: could not read article doc $doc_id"
        return 1
    }
    tab_data=$(echo "$raw" | _parse_tabs)

    local first_tab_id="" first_tab_end="" tabs_deleted=0
    while read -r idx tab_id end_idx; do
        if [[ "$idx" == "0" ]]; then
            first_tab_id="$tab_id"
            first_tab_end="$end_idx"
        else
            python3 "$SCRIPTS_DIR/delete_tab.py" "$doc_id" "$tab_id" > /dev/null
            tabs_deleted=$((tabs_deleted + 1))
        fi
    done <<< "$tab_data"

    [[ -n "$first_tab_id" ]] && \
        python3 "$SCRIPTS_DIR/clear_tab.py" "$doc_id" "$first_tab_id" "$first_tab_end" > /dev/null

    echo "Article doc reset. Deleted $tabs_deleted extra tab(s), cleared default tab."
}

# Restore a spec doc to canonical state from content files.
# content_dir must contain files named tab-N-<title>.txt for each tab index N.
restore_spec_doc() {
    local doc_id="$1" content_dir="$2"
    local raw tab_data
    raw=$(python3 "$SCRIPTS_DIR/read_doc.py" "$doc_id" 2>/dev/null) || {
        echo "ERROR: could not read spec doc $doc_id"
        return 1
    }
    tab_data=$(echo "$raw" | _parse_tabs)

    while read -r idx tab_id end_idx; do
        local content_file
        content_file=$(ls "${content_dir}/tab-${idx}-"*.txt 2>/dev/null | head -1)
        if [[ -z "$content_file" ]]; then
            echo "WARNING: no content file for tab index $idx in $content_dir"
            continue
        fi
        python3 "$SCRIPTS_DIR/clear_tab.py" "$doc_id" "$tab_id" "$end_idx" > /dev/null
        python3 "$SCRIPTS_DIR/write_tab.py" "$doc_id" "$tab_id" "$content_file" > /dev/null
        echo "  Restored tab $idx: $(basename "$content_file")"
    done <<< "$tab_data"

    echo "Spec doc restored to canonical state."
}

# Create a tab in a doc and write sentinel text into it (for overwrite tests).
create_sentinel_tab() {
    local doc_id="$1" tab_name="$2" sentinel_text="$3"
    local tab_id
    tab_id=$(python3 "$SCRIPTS_DIR/create_tab.py" "$doc_id" "$tab_name" 2>/dev/null) || {
        echo "ERROR: could not create tab '$tab_name'"
        return 1
    }
    echo "$sentinel_text" > /tmp/test_sentinel.txt
    python3 "$SCRIPTS_DIR/write_tab.py" "$doc_id" "$tab_id" /tmp/test_sentinel.txt > /dev/null
    echo "Created tab '$tab_name' with sentinel content."
}

# Check that a prerequisite tab exists; print a message and exit 1 if absent.
require_tab() {
    local doc_id="$1" tab_name="$2" context="$3"
    if ! python3 "$SCRIPTS_DIR/find_tab.py" "$doc_id" "$tab_name" > /dev/null 2>&1; then
        echo "PREREQUISITE MISSING: '$tab_name' tab not found in doc."
        echo "  $context"
        exit 1
    fi
    echo "Prerequisite OK: '$tab_name' tab present."
}
