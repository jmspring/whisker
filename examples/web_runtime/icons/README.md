# PWA Icons (Placeholders)

This directory should contain app icons for the Progressive Web App. Icons enable installation on iOS/Android home screens.

## Required Icons

Generate these sizes from your museum's logo or icon design:

- `icon-72.png` (72x72) - iOS, Android launcher
- `icon-96.png` (96x96) - Android launcher
- `icon-128.png` (128x128) - Desktop PWA
- `icon-144.png` (144x144) - Android launcher
- `icon-152.png` (152x152) - iOS home screen
- `icon-192.png` (192x192) - Android launcher (standard)
- `icon-384.png` (384x384) - Android launcher (high-res)
- `icon-512.png` (512x512) - Android splash screen

## Placeholder Icon

`icon-placeholder.svg` - Generic museum icon for testing

To generate PNGs from the placeholder SVG:

```bash
# Using ImageMagick/rsvg-convert
rsvg-convert -w 72 -h 72 icon-placeholder.svg > icon-72.png
rsvg-convert -w 96 -h 96 icon-placeholder.svg > icon-96.png
rsvg-convert -w 128 -h 128 icon-placeholder.svg > icon-128.png
rsvg-convert -w 144 -h 144 icon-placeholder.svg > icon-144.png
rsvg-convert -w 152 -h 152 icon-placeholder.svg > icon-152.png
rsvg-convert -w 192 -h 192 icon-placeholder.svg > icon-192.png
rsvg-convert -w 384 -h 384 icon-placeholder.svg > icon-384.png
rsvg-convert -w 512 -h 512 icon-placeholder.svg > icon-512.png
```

Or use ImageMagick:
```bash
convert -background none -resize 72x72 icon-placeholder.svg icon-72.png
convert -background none -resize 96x96 icon-placeholder.svg icon-96.png
convert -background none -resize 128x128 icon-placeholder.svg icon-128.png
convert -background none -resize 144x144 icon-placeholder.svg icon-144.png
convert -background none -resize 152x152 icon-placeholder.svg icon-152.png
convert -background none -resize 192x192 icon-placeholder.svg icon-192.png
convert -background none -resize 384x384 icon-placeholder.svg icon-384.png
convert -background none -resize 512x512 icon-placeholder.svg icon-512.png
```

## Icon Design Guidelines

**Design:**
- Simple, recognizable symbol
- Bold colors matching museum brand
- High contrast for visibility
- No text (icons should work at small sizes)
- Square canvas with padding (safe area)

**Technical:**
- PNG format with transparency
- sRGB color space
- No compression artifacts
- Test on light and dark backgrounds

**Tips:**
- Museum building silhouette
- Iconic artifact (dinosaur, sculpture, etc.)
- Museum logo (simplified)
- Geometric shape with museum theme

## Online Icon Generators

**Easy options:**
1. **PWA Builder**: https://www.pwabuilder.com/imageGenerator
   - Upload one image, generates all sizes
   - Handles transparency and padding

2. **Real Favicon Generator**: https://realfavicongenerator.net/
   - Comprehensive icon generation
   - Tests on various platforms

3. **Favicon.io**: https://favicon.io/
   - Simple, free
   - Generates from image or text

## Quick Start

**For testing (use placeholder):**
```bash
# Generate placeholder icons (requires ImageMagick)
./generate-placeholder-icons.sh
```

**For production (use museum logo):**
1. Create or obtain museum logo (SVG or high-res PNG)
2. Use online generator (PWA Builder recommended)
3. Download generated icons
4. Replace files in this directory
5. Update manifest.json if paths change

## Verification

After generating icons, verify:
```bash
# Check all icons exist
ls -lh icon-*.png

# Verify sizes
file icon-*.png

# Should show correct dimensions:
# icon-72.png: PNG image data, 72 x 72
# icon-96.png: PNG image data, 96 x 96
# etc.
```

## Testing PWA Installation

**iOS (Safari):**
1. Open museum.html
2. Tap Share button
3. Scroll to "Add to Home Screen"
4. Should show your icon

**Android (Chrome):**
1. Open museum.html
2. Tap Menu (⋮)
3. Select "Install app"
4. Should show your icon

**Desktop (Chrome):**
1. Open museum.html
2. Click install icon in address bar
3. Should show your icon

## Current Status

⚠️ **Placeholder icons needed** - Generate from museum logo before production deployment.

The placeholder SVG is provided for testing. Replace with actual museum branding for production use.
