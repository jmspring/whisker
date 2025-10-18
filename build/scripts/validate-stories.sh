#!/bin/bash
# Validate example stories

set -e

echo "Validating example stories..."

if [ ! -d "stories/examples" ]; then
    echo "✗ stories/examples directory not found"
    exit 1
fi

# Count story files
story_count=$(find stories/examples -name "*.lua" -o -name "*.whisker" -o -name "*.json" | wc -l)

if [ "$story_count" -eq 0 ]; then
    echo "⚠ No story files found in stories/examples"
    exit 0
fi

echo "Found $story_count story file(s)"

# Validate Lua syntax for .lua stories
lua_errors=0
while IFS= read -r file; do
    if command -v luac >/dev/null 2>&1; then
        if ! luac -p "$file" >/dev/null 2>&1; then
            echo "✗ Syntax error in: $file"
            lua_errors=$((lua_errors + 1))
        fi
    fi
done < <(find stories/examples -name "*.lua")

if [ $lua_errors -gt 0 ]; then
    echo "✗ Found $lua_errors story file(s) with syntax errors"
    exit 1
fi

echo "✓ All example stories validated successfully"
exit 0
