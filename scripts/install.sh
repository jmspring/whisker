#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================"
echo "Installing Whisker"
echo "========================================${NC}"
echo ""

# Installation directory
INSTALL_DIR="${HOME}/.local/share/whisker"
BIN_DIR="${HOME}/.local/bin"

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# Check if we're in a release directory or source directory
if [ -f "install.sh" ] && [ -d "core" ]; then
    # Release installation
    echo "Installing from release package..."
    
    # Extract core
    if [ -f "core/whisker-core.tar.gz" ]; then
        echo "Installing core..."
        tar -xzf core/whisker-core.tar.gz -C "$INSTALL_DIR"
    fi
    
    # Install web editor
    if [ -f "web-editor/whisker-web-editor.tar.gz" ]; then
        echo "Installing web editor..."
        mkdir -p "$INSTALL_DIR/web-editor"
        tar -xzf web-editor/whisker-web-editor.tar.gz -C "$INSTALL_DIR/web-editor"
    fi
    
    # Install runtime
    if [ -f "runtime/whisker-runtime-full.tar.gz" ]; then
        echo "Installing runtime..."
        mkdir -p "$INSTALL_DIR/runtime"
        tar -xzf runtime/whisker-runtime-full.tar.gz -C "$INSTALL_DIR/runtime"
    fi
    
    # Copy examples
    if [ -d "examples" ]; then
        echo "Installing examples..."
        cp -r examples "$INSTALL_DIR/"
    fi
    
    # Copy docs
    if [ -d "docs" ]; then
        echo "Installing documentation..."
        cp -r docs "$INSTALL_DIR/"
    fi
else
    # Source installation
    echo "Installing from source..."
    
    # Build first
    if [ -f "build/scripts/build-all.sh" ]; then
        echo "Building project..."
        ./build/scripts/build-all.sh
    fi
    
    # Copy built files
    if [ -d "dist" ]; then
        echo "Copying built files..."
        cp -r dist/* "$INSTALL_DIR/"
    fi
fi

# Create command-line tools
echo "Creating command-line tools..."

# Whisker CLI
cat > "$BIN_DIR/whisker" << 'EOF'
#!/bin/bash
WHISKER_HOME="${HOME}/.local/share/whisker"
lua "${WHISKER_HOME}/whisker/bin/whisker.lua" "$@"
EOF
chmod +x "$BIN_DIR/whisker"

# Whisker editor launcher
cat > "$BIN_DIR/whisker-editor" << 'EOF'
#!/bin/bash
WHISKER_HOME="${HOME}/.local/share/whisker"

if command -v love >/dev/null 2>&1; then
    # Launch desktop editor if LÖVE is available
    if [ -f "${WHISKER_HOME}/whisker-editor.love" ]; then
        love "${WHISKER_HOME}/whisker-editor.love"
    else
        echo "Desktop editor not found"
        exit 1
    fi
else
    # Launch web editor
    if [ -d "${WHISKER_HOME}/web-editor" ]; then
        echo "Opening web editor at http://localhost:3000"
        cd "${WHISKER_HOME}/web-editor"
        npm start
    else
        echo "Editor not found"
        exit 1
    fi
fi
EOF
chmod +x "$BIN_DIR/whisker-editor"

echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo "Whisker installed to: $INSTALL_DIR"
echo "Command-line tools installed to: $BIN_DIR"
echo ""
echo "Add to your PATH by adding this line to ~/.bashrc or ~/.zshrc:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Usage:"
echo "  whisker --help           # Show help"
echo "  whisker-editor           # Launch editor"
echo ""