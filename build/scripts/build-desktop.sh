#!/bin/bash
# Build desktop runtime

set -e

echo "Checking desktop publisher..."

if [ -d "publisher/desktop" ]; then
    # For LÖVE2D, just verify the required files exist
    if [ -f "publisher/desktop/main.lua" ] && [ -f "publisher/desktop/conf.lua" ]; then
        echo "✓ Desktop publisher ready"
    else
        echo "✗ Missing required desktop files (main.lua or conf.lua)"
        exit 1
    fi
else
    echo "⚠ publisher/desktop directory not found, skipping"
fi

exit 0
