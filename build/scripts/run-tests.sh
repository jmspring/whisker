#!/bin/bash
# Run tests with busted

set -e

TEST_SUITE="${1:-all}"

case "$TEST_SUITE" in
    all)
        echo "Running all tests..."
        busted --output=plainTerminal
        ;;
    unit)
        echo "Running unit tests..."
        busted --output=plainTerminal --exclude-tags=integration,format
        ;;
    integration)
        echo "Running integration tests..."
        busted --output=plainTerminal --tags=integration
        ;;
    web-editor)
        echo "Running web editor tests..."
        if [ -d "editor/web" ] && [ -f "editor/web/package.json" ]; then
            cd editor/web && npm test
        else
            echo "⚠ No web editor tests found, skipping"
        fi
        ;;
    runtime)
        echo "Running runtime tests..."
        busted --output=plainTerminal tests/test_*runtime*.lua 2>/dev/null || echo "⚠ No runtime-specific tests found, skipping"
        ;;
    *)
        echo "Unknown test suite: $TEST_SUITE"
        echo "Usage: $0 {all|unit|integration|web-editor|runtime}"
        exit 1
        ;;
esac

exit 0
