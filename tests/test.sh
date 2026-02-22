#!/usr/bin/env bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$PROJECT_DIR/data"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

tests_passed=0
tests_failed=0

test_json_exists() {
    if [ -f "$DATA_DIR/emojis.json" ]; then
        echo -e "${GREEN}✓${NC} JSON file exists"
        ((tests_passed++))
    else
        echo -e "${RED}✗${NC} JSON file not found"
        ((tests_failed++))
    fi
}

test_json_valid() {
    if python3 -c "import json; json.load(open('$DATA_DIR/emojis.json'))" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} JSON is valid"
        ((tests_passed++))
    else
        echo -e "${RED}✗${NC} JSON is invalid"
        ((tests_failed++))
    fi
}

test_json_has_categories() {
    local count=$(python3 -c "
import json
with open('$DATA_DIR/emojis.json') as f:
    data = json.load(f)
    print(len(data))
" 2>/dev/null)
    
    if [ -n "$count" ] && [ "$count" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} JSON has $count categories"
        ((tests_passed++))
    else
        echo -e "${RED}✗${NC} JSON has no categories"
        ((tests_failed++))
    fi
}

test_emojis_loaded() {
    local count=$(python3 -c "
import json
with open('$DATA_DIR/emojis.json') as f:
    data = json.load(f)
    total = sum(len(cat.get('emojis', [])) for cat in data.values())
    print(total)
" 2>/dev/null)
    
    if [ -n "$count" ] && [ "$count" -gt 100 ]; then
        echo -e "${GREEN}✓${NC} Loaded $count emojis"
        ((tests_passed++))
    else
        echo -e "${RED}✗${NC} Too few emojis: $count"
        ((tests_failed++))
    fi
}

test_script_syntax() {
    if bash -n "$PROJECT_DIR/emoji-picker.sh" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Script syntax is valid"
        ((tests_passed++))
    else
        echo -e "${RED}✗${NC} Script has syntax errors"
        ((tests_failed++))
    fi
}

test_dependencies() {
    local missing=0
    for cmd in yad xclip notify-send python3; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e "${RED}✗${NC} Missing: $cmd"
            ((missing++))
        fi
    done
    
    if [ "$missing" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} All dependencies available"
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
}

echo "Running tests..."
echo "================"

test_json_exists
test_json_valid
test_json_has_categories
test_emojis_loaded
test_script_syntax
test_dependencies

echo "================"
echo -e "Passed: ${GREEN}$tests_passed${NC}"
echo -e "Failed: ${RED}$tests_failed${NC}"

[ "$tests_failed" -eq 0 ] && exit 0 || exit 1
