#!/bin/bash
# Package release for distribution

set -e

VERSION="${1:-$(cat VERSION 2>/dev/null || echo 'dev')}"
RELEASE_NAME="whisker-${VERSION}"
RELEASE_DIR="dist/releases"
PACKAGE_DIR="${RELEASE_DIR}/${RELEASE_NAME}"

echo "Creating release package: ${RELEASE_NAME}"

# Create release directory
mkdir -p "${PACKAGE_DIR}"

# Copy core files
echo "Copying core library..."
cp -r lib "${PACKAGE_DIR}/"

echo "Copying binaries..."
mkdir -p "${PACKAGE_DIR}/bin"
cp bin/whisker "${PACKAGE_DIR}/bin/"

echo "Copying publisher..."
cp -r publisher "${PACKAGE_DIR}/"

echo "Copying example stories..."
cp -r stories "${PACKAGE_DIR}/"

echo "Copying configuration..."
cp -r config "${PACKAGE_DIR}/"

echo "Copying documentation..."
cp README.md "${PACKAGE_DIR}/"
cp AUTHORING.md "${PACKAGE_DIR}/" 2>/dev/null || true
cp LICENSE "${PACKAGE_DIR}/" 2>/dev/null || true
[ -d docs ] && cp -r docs "${PACKAGE_DIR}/" || true

echo "Copying rockspec..."
mkdir -p "${PACKAGE_DIR}/rockspec"
cp rockspec/*.rockspec "${PACKAGE_DIR}/rockspec/" 2>/dev/null || true

# Create archive
echo "Creating archive..."
cd "${RELEASE_DIR}"
tar czf "${RELEASE_NAME}.tar.gz" "${RELEASE_NAME}"
zip -r -q "${RELEASE_NAME}.zip" "${RELEASE_NAME}"

echo "✓ Release package created:"
echo "  - ${RELEASE_DIR}/${RELEASE_NAME}.tar.gz"
echo "  - ${RELEASE_DIR}/${RELEASE_NAME}.zip"
echo "  - ${PACKAGE_DIR}/ (uncompressed)"

exit 0
