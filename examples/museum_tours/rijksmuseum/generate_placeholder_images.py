#!/usr/bin/env python3
"""
Generate placeholder images for Rijksmuseum tour
These are temporary placeholders - replace with actual Rijksmuseum collection images
"""

from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

# Images needed
IMAGES = {
    'gallery_of_honour.jpg': 'Gallery of Honour\nRijksmuseum',
    'night_watch.jpg': 'The Night Watch\nRembrandt van Rijn\n1642',
    'milkmaid.jpg': 'The Milkmaid\nJohannes Vermeer\nc. 1660',
    'merry_drinker.jpg': 'The Merry Drinker\nFrans Hals\nc. 1628',
    'self_portrait_paul.jpg': 'Self-Portrait as Paul\nRembrandt van Rijn\n1661',
    'jewish_bride.jpg': 'The Jewish Bride\nRembrandt van Rijn\nc. 1665',
    'still_life.jpg': 'Still Life with Flowers\nJan van Huysum\nc. 1715',
    'threatened_swan.jpg': 'The Threatened Swan\nJan Asselijn\nc. 1650',
    'winter_landscape.jpg': 'Winter Landscape\nHendrick Avercamp\nc. 1608',
    'delftware.jpg': 'Delftware Collection\n17th-18th Century',
    'battle_waterloo.jpg': 'Battle of Waterloo\nJan Willem Pieneman\n1824',
    'warship_model.jpg': 'Warship Amsterdam\nModel c. 1750',
    'dutch_dollhouse.jpg': 'Dutch Dollhouse\nPetronella Oortman\nc. 1686-1710',
}

def create_placeholder_image(filename, text, size=(1920, 1080)):
    """Create a placeholder image with text."""

    # Create image with museum-like color scheme
    img = Image.new('RGB', size, color='#2c3e50')  # Dark blue-grey
    draw = ImageDraw.Draw(img)

    # Try to use a nice font, fallback to default
    try:
        font_title = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 80)
        font_subtitle = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 50)
    except:
        font_title = ImageFont.load_default()
        font_subtitle = ImageFont.load_default()

    # Add decorative border
    border_color = '#d4af37'  # Gold
    border_width = 20
    draw.rectangle(
        [(border_width, border_width),
         (size[0]-border_width, size[1]-border_width)],
        outline=border_color,
        width=border_width
    )

    # Add "PLACEHOLDER" watermark
    watermark_font = font_subtitle
    watermark = "PLACEHOLDER - Replace with Rijksmuseum Image"

    # Center the text
    lines = text.split('\n')
    y_offset = size[1] // 2 - (len(lines) * 60)

    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font_title)
        text_width = bbox[2] - bbox[0]
        x = (size[0] - text_width) // 2

        # Draw text with shadow
        draw.text((x+3, y_offset+3), line, fill='#000000', font=font_title)
        draw.text((x, y_offset), line, fill='#ecf0f1', font=font_title)
        y_offset += 80

    # Add watermark at bottom
    bbox = draw.textbbox((0, 0), watermark, font=watermark_font)
    watermark_width = bbox[2] - bbox[0]
    watermark_x = (size[0] - watermark_width) // 2
    watermark_y = size[1] - 100
    draw.text((watermark_x, watermark_y), watermark, fill='#e74c3c', font=watermark_font)

    return img

def generate_placeholder_images(output_dir='assets/images'):
    """Generate all placeholder images."""

    # Create output directory
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    print("🖼️  Generating Placeholder Images for Rijksmuseum Tour")
    print("=" * 70)
    print("⚠️  Note: These are PLACEHOLDERS - Replace with actual Rijksmuseum images")
    print("=" * 70)

    for filename, text in IMAGES.items():
        # Create placeholder
        img = create_placeholder_image(filename, text)

        # Save as JPEG with high quality
        filepath = f"{output_dir}/{filename}"
        img.save(filepath, 'JPEG', quality=85, optimize=True)

        print(f"✅ Generated: {filename}")

    print("=" * 70)
    print(f"✅ All {len(IMAGES)} placeholder images generated!")
    print(f"📁 Location: {output_dir}/")
    print()
    print("⚠️  IMPORTANT: These are placeholders!")
    print()
    print("To get actual Rijksmuseum images:")
    print("1. Visit: https://www.rijksmuseum.nl/en/rijksstudio")
    print("2. Search for each artwork by name")
    print("3. Download high-resolution images (free for most)")
    print("4. Replace placeholder files with actual images")
    print("5. Optimize: JPEG, 1920x1080, 85% quality, progressive")

if __name__ == '__main__':
    try:
        generate_placeholder_images()
    except Exception as e:
        print(f"❌ Error: {e}")
        print()
        print("Manual creation instructions:")
        print("Create 1920x1080 JPEG images for:")
        for filename in IMAGES.keys():
            print(f"  - {filename}")
