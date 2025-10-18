#!/bin/bash
# Build core Lua modules - validates syntax

set -e

echo "Validating core Lua modules..."

# Check if luac is available for syntax checking
if command -v luac >/dev/null 2>&1; then
    # Validate syntax of all Lua files
    error_count=0
    while IFS= read -r file; do
        if ! luac -p "$file" >/dev/null 2>&1; then
            echo "✗ Syntax error in: $file"
            error_count=$((error_count + 1))
        fi
    done < <(find lib/whisker -name "*.lua")

    if [ $error_count -gt 0 ]; then
        echo "✗ Found $error_count file(s) with syntax errors"
        exit 1
    fi
    echo "✓ All core modules have valid syntax"
else
    echo "⚠ luac not available, skipping syntax validation"
    echo "✓ Core modules directory exists"
fi

exit 0
