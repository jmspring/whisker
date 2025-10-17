#!/usr/bin/env python3
"""
Generate PWA icons for Rijksmuseum tour
Creates placeholder icons in all required sizes
"""

from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

# Icon sizes needed for PWA
ICON_SIZES = [72, 96, 128, 144, 152, 192, 384, 512]

def create_rijksmuseum_icon(size):
    """Create a Rijksmuseum-themed icon."""

    # Create image with Rijksmuseum blue background
    img = Image.new('RGB', (size, size), color='#00438D')  # Rijksmuseum blue
    draw = ImageDraw.Draw(img)

    # Add gold border (museum gold)
    border_width = max(2, size // 40)
    draw.rectangle(
        [(border_width, border_width),
         (size-border_width, size-border_width)],
        outline='#d4af37',
        width=border_width
    )

    # Draw a simplified museum building shape
    building_color = '#ffffff'
    building_width = size * 0.7
    building_height = size * 0.5
    building_x = (size - building_width) // 2
    building_y = size * 0.35

    # Main building rectangle
    draw.rectangle(
        [(building_x, building_y),
         (building_x + building_width, building_y + building_height)],
        fill=building_color,
        outline='#d4af37',
        width=max(1, size // 100)
    )

    # Triangular roof
    roof_height = size * 0.15
    draw.polygon([
        (building_x - roof_height//2, building_y),
        (building_x + building_width + roof_height//2, building_y),
        (building_x + building_width//2, building_y - roof_height)
    ], fill='#d4af37')

    # Add columns (simplified)
    num_columns = 3
    column_width = building_width / (num_columns * 2)
    column_spacing = building_width / (num_columns + 1)

    for i in range(num_columns):
        column_x = building_x + column_spacing * (i + 1) - column_width // 2
        column_y = building_y + building_height * 0.2
        column_height = building_height * 0.6

        draw.rectangle(
            [(column_x, column_y),
             (column_x + column_width, column_y + column_height)],
            fill='#00438D'
        )

    # Add text if size is large enough
    if size >= 192:
        try:
            font_size = size // 10
            font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', font_size)
        except:
            font = ImageFont.load_default()

        text = "RM"  # Rijksmuseum
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_x = (size - text_width) // 2
        text_y = building_y + building_height + size * 0.05

        draw.text((text_x, text_y), text, fill='#d4af37', font=font)

    return img

def generate_pwa_icons(output_dir='../../web_runtime/icons'):
    """Generate all PWA icon sizes."""

    # Create output directory
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    print("🎨 Generating PWA Icons for Rijksmuseum Tour")
    print("=" * 70)
    print("⚠️  Note: These are PLACEHOLDERS - Replace with official museum logo")
    print("=" * 70)

    for size in ICON_SIZES:
        # Create icon
        icon = create_rijksmuseum_icon(size)

        # Save as PNG
        filename = f"{output_dir}/icon-{size}.png"
        icon.save(filename, 'PNG', optimize=True)

        print(f"✅ Generated: icon-{size}.png ({size}×{size}px)")

    print("=" * 70)
    print(f"✅ All {len(ICON_SIZES)} PWA icons generated!")
    print(f"📁 Location: {output_dir}/")
    print()
    print("⚠️  IMPORTANT: These are placeholders!")
    print()
    print("To create production icons:")
    print("1. Obtain official Rijksmuseum logo (SVG or high-res PNG)")
    print("2. Use online generator:")
    print("   - PWA Builder: https://www.pwabuilder.com/imageGenerator")
    print("   - Real Favicon Generator: https://realfavicongenerator.net/")
    print("3. Or use ImageMagick/similar tools")
    print("4. Replace placeholder icons with branded versions")
    print()
    print("Icon specifications:")
    print("  - Format: PNG with transparency")
    print("  - Color space: sRGB")
    print("  - Sizes: 72, 96, 128, 144, 152, 192, 384, 512 px")
    print("  - Design: Museum logo, bold colors, high contrast")

if __name__ == '__main__':
    try:
        generate_pwa_icons()
    except Exception as e:
        print(f"❌ Error: {e}")
        print()
        print("Manual creation instructions:")
        print("Create PNG icons in these sizes:")
        for size in ICON_SIZES:
            print(f"  - icon-{size}.png ({size}×{size}px)")
