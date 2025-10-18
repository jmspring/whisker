#!/bin/bash
# Build web editor

set -e

echo "Checking web editor..."

if [ -d "editor/web" ]; then
    cd editor/web

    if [ -f "package.json" ]; then
        echo "Installing npm dependencies..."
        npm install --silent

        # If there's a build script, run it
        if npm run | grep -q "build"; then
            echo "Building web editor..."
            npm run build
        fi
    fi

    echo "✓ Web editor ready"
else
    echo "⚠ editor/web directory not found, skipping"
fi

exit 0
