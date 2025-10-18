#!/bin/bash
# Build web runtime/publisher

set -e

echo "Checking web publisher..."

if [ -d "publisher/web" ]; then
    cd publisher/web

    if [ -f "package.json" ]; then
        echo "Installing npm dependencies..."
        npm install --silent

        # If there's a build script, run it
        if npm run | grep -q "build"; then
            echo "Building web publisher..."
            npm run build
        fi
    fi

    echo "✓ Web publisher ready"
else
    echo "⚠ publisher/web directory not found, skipping"
fi

exit 0
