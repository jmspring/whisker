#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Cleaning Whisker build artifacts..."

# Remove dist directories
echo "Removing dist directories..."
rm -rf dist/
rm -rf editor/web/dist/
rm -rf editor/desktop/build/
rm -rf runtime/web/dist/

# Remove coverage reports
echo "Removing coverage reports..."
rm -f luacov.*.out
rm -rf coverage/
rm -rf editor/web/coverage/
rm -rf runtime/web/coverage/

# Remove documentation builds
echo "Removing documentation builds..."
rm -rf docs/build/

# Remove node_modules (optional, uncomment if needed)
# echo "Removing node_modules..."
# rm -rf node_modules/
# rm -rf editor/web/node_modules/
# rm -rf runtime/web/node_modules/

# Remove log files
echo "Removing log files..."
find . -name "*.log" -type f -delete

# Remove temporary files
echo "Removing temporary files..."
find . -name "*~" -type f -delete
find . -name "*.swp" -type f -delete
find . -name ".DS_Store" -type f -delete

echo -e "${GREEN}✓ Clean complete!${NC}"