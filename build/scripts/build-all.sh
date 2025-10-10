#!/bin/bash
set -e

echo "========================================"
echo "Building Whisker - All Components"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if required tools are installed
check_requirements() {
    echo "Checking requirements..."
    
    local missing_tools=()
    
    command -v lua >/dev/null 2>&1 || missing_tools+=("lua")
    command -v luarocks >/dev/null 2>&1 || missing_tools+=("luarocks")
    command -v node >/dev/null 2>&1 || missing_tools+=("node")
    command -v npm >/dev/null 2>&1 || missing_tools+=("npm")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}Error: Missing required tools: ${missing_tools[*]}${NC}"
        echo "Please run ./scripts/setup-dev.sh first"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All requirements met${NC}"
    echo ""
}

# Create dist directory
mkdir -p dist

# Check requirements
check_requirements

# Build core Lua modules
echo -e "${YELLOW}[1/4] Building core modules...${NC}"
if ./build/scripts/build-core.sh; then
    echo -e "${GREEN}✓ Core build successful${NC}"
else
    echo -e "${RED}✗ Core build failed${NC}"
    exit 1
fi
echo ""

# Build web editor
echo -e "${YELLOW}[2/4] Building web editor...${NC}"
if ./build/scripts/build-web-editor.sh; then
    echo -e "${GREEN}✓ Web editor build successful${NC}"
else
    echo -e "${RED}✗ Web editor build failed${NC}"
    exit 1
fi
echo ""

# Build web runtime
echo -e "${YELLOW}[3/4] Building web runtime...${NC}"
if ./build/scripts/build-runtime.sh; then
    echo -e "${GREEN}✓ Runtime build successful${NC}"
else
    echo -e "${RED}✗ Runtime build failed${NC}"
    exit 1
fi
echo ""

# Build desktop editor
echo -e "${YELLOW}[4/4] Building desktop editor...${NC}"
if ./build/scripts/build-desktop.sh; then
    echo -e "${GREEN}✓ Desktop build successful${NC}"
else
    echo -e "${RED}✗ Desktop build failed${NC}"
    exit 1
fi
echo ""

echo "========================================"
echo -e "${GREEN}All builds completed successfully!${NC}"
echo "========================================"
echo ""
echo "Build artifacts available in: ./dist/"
ls -lh dist/