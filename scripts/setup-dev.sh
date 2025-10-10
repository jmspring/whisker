#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================"
echo "Whisker Development Environment Setup"
echo "========================================${NC}"
echo ""

# Detect OS
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
    Linux*)
        PACKAGE_MANAGER="apt-get"
        if command -v dnf >/dev/null 2>&1; then
            PACKAGE_MANAGER="dnf"
        elif command -v pacman >/dev/null 2>&1; then
            PACKAGE_MANAGER="pacman"
        fi
        ;;
    Darwin*)
        PACKAGE_MANAGER="brew"
        ;;
    *)
        echo -e "${YELLOW}Unknown OS: $OS_TYPE${NC}"
        PACKAGE_MANAGER=""
        ;;
esac

echo -e "${YELLOW}Detected OS: $OS_TYPE${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install package
install_package() {
    local package=$1
    echo -e "${YELLOW}Installing $package...${NC}"
    
    case "$PACKAGE_MANAGER" in
        apt-get)
            sudo apt-get update && sudo apt-get install -y "$package"
            ;;
        dnf)
            sudo dnf install -y "$package"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package"
            ;;
        brew)
            brew install "$package"
            ;;
        *)
            echo -e "${RED}Please install $package manually${NC}"
            return 1
            ;;
    esac
}

# Check and install Lua
echo -e "${BLUE}[1/6] Checking Lua installation...${NC}"
if command_exists lua; then
    LUA_VERSION=$(lua -v 2>&1 | head -n1)
    echo -e "${GREEN}✓ Lua is installed: $LUA_VERSION${NC}"
else
    echo -e "${YELLOW}Lua not found${NC}"
    install_package lua5.4 || install_package lua
fi
echo ""

# Check and install LuaRocks
echo -e "${BLUE}[2/6] Checking LuaRocks installation...${NC}"
if command_exists luarocks; then
    LUAROCKS_VERSION=$(luarocks --version 2>&1 | head -n1)
    echo -e "${GREEN}✓ LuaRocks is installed: $LUAROCKS_VERSION${NC}"
else
    echo -e "${YELLOW}LuaRocks not found${NC}"
    install_package luarocks
fi

# Install Lua dependencies
echo -e "${YELLOW}Installing Lua dependencies...${NC}"
luarocks install --local busted || echo "Warning: Could not install busted"
luarocks install --local luacov || echo "Warning: Could not install luacov"
luarocks install --local luacheck || echo "Warning: Could not install luacheck"
luarocks install --local ldoc || echo "Warning: Could not install ldoc"
luarocks install --local luafilesystem || echo "Warning: Could not install luafilesystem"
luarocks install --local lpeg || echo "Warning: Could not install lpeg"
echo ""

# Check and install Node.js
echo -e "${BLUE}[3/6] Checking Node.js installation...${NC}"
if command_exists node; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓ Node.js is installed: $NODE_VERSION${NC}"
    
    # Check if version is >= 18
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR" -lt 18 ]; then
        echo -e "${YELLOW}Warning: Node.js version 18+ recommended${NC}"
    fi
else
    echo -e "${YELLOW}Node.js not found${NC}"
    echo "Please install Node.js 20+ from https://nodejs.org/"
    exit 1
fi
echo ""

# Check npm
echo -e "${BLUE}[4/6] Checking npm installation...${NC}"
if command_exists npm; then
    NPM_VERSION=$(npm -v)
    echo -e "${GREEN}✓ npm is installed: $NPM_VERSION${NC}"
else
    echo -e "${RED}npm not found${NC}"
    exit 1
fi
echo ""

# Install Node.js dependencies
echo -e "${BLUE}[5/6] Installing Node.js dependencies...${NC}"

if [ -d "editor/web" ]; then
    echo "Installing web editor dependencies..."
    cd editor/web
    npm install
    cd ../..
fi

if [ -d "runtime/web" ]; then
    echo "Installing web runtime dependencies..."
    cd runtime/web
    npm install
    cd ../..
fi

# Install root package dependencies if package.json exists
if [ -f "package.json" ]; then
    echo "Installing root dependencies..."
    npm install
fi

echo -e "${GREEN}✓ Node.js dependencies installed${NC}"
echo ""

# Check optional tools
echo -e "${BLUE}[6/6] Checking optional tools...${NC}"

# Docker
if command_exists docker; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓ Docker is installed: $DOCKER_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ Docker not found (optional for containerized builds)${NC}"
fi

# LÖVE (for desktop editor)
if command_exists love; then
    LOVE_VERSION=$(love --version 2>&1 | head -n1)
    echo -e "${GREEN}✓ LÖVE is installed: $LOVE_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ LÖVE not found (optional for desktop editor)${NC}"
    echo "  Install from: https://love2d.org/"
fi

# Python (for docs)
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ Python is installed: $PYTHON_VERSION${NC}"
    
    # Check for mkdocs
    if command_exists mkdocs; then
        echo -e "${GREEN}✓ MkDocs is installed${NC}"
    else
        echo -e "${YELLOW}⚠ MkDocs not found (optional for documentation)${NC}"
        echo "  Install with: pip3 install mkdocs mkdocs-material"
    fi
else
    echo -e "${YELLOW}⚠ Python not found (optional for documentation)${NC}"
fi

echo ""
echo -e "${BLUE}========================================"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Run tests: make test"
echo "  2. Build project: make build"
echo "  3. Start development: make dev"
echo ""