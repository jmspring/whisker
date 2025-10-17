#!/usr/bin/env python3
"""
Generate QR codes for Rijksmuseum tour
Requires: pip install qrcode[pil]
"""

import qrcode
import os
from pathlib import Path

# QR codes to generate
QR_CODES = {
    'RIJKS-WELCOME': 'Welcome to Rijksmuseum',
    'RIJKS-NIGHTWATCH-001': 'The Night Watch',
    'RIJKS-MILKMAID-002': 'The Milkmaid',
    'RIJKS-DRINKER-003': 'The Merry Drinker',
    'RIJKS-REMBRANDT-SELF-004': 'Self-Portrait as Paul',
    'RIJKS-BRIDE-005': 'The Jewish Bride',
    'RIJKS-STILLLIFE-006': 'Still Life with Flowers',
    'RIJKS-SWAN-007': 'The Threatened Swan',
    'RIJKS-WINTER-008': 'Winter Landscape',
    'RIJKS-DELFTWARE-009': 'Delftware Collection',
    'RIJKS-WATERLOO-010': 'Battle of Waterloo',
    'RIJKS-WARSHIP-011': 'Warship Amsterdam Model',
    'RIJKS-DOLLHOUSE-012': 'Dutch Dollhouse',
}

def generate_qr_codes(output_dir='assets/qr_codes'):
    """Generate all QR codes for the tour."""

    # Create output directory
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    print("🔲 Generating QR Codes for Rijksmuseum Tour")
    print("=" * 60)

    for code, description in QR_CODES.items():
        # Create QR code instance
        qr = qrcode.QRCode(
            version=1,  # Controls size (1-40)
            error_correction=qrcode.constants.ERROR_CORRECT_H,  # High error correction
            box_size=10,  # Size of each box in pixels
            border=4,  # Border size in boxes
        )

        # Add data
        qr.add_data(code)
        qr.make(fit=True)

        # Create image
        img = qr.make_image(fill_color="black", back_color="white")

        # Save image
        filename = f"{output_dir}/{code}.png"
        img.save(filename)

        print(f"✅ Generated: {code}.png ({description})")

    print("=" * 60)
    print(f"✅ All {len(QR_CODES)} QR codes generated successfully!")
    print(f"📁 Location: {output_dir}/")
    print()
    print("Next steps:")
    print("1. Print QR codes at 5cm × 5cm for artwork labels")
    print("2. Print RIJKS-WELCOME at 10cm × 10cm for entrance")
    print("3. Mount on museum-quality materials")
    print("4. Place at artwork locations")

if __name__ == '__main__':
    try:
        generate_qr_codes()
    except ImportError:
        print("❌ Error: qrcode library not installed")
        print("Install with: pip install qrcode[pil]")
        print()
        print("Or use online generator:")
        print("https://www.qr-code-generator.com/")
        print()
        print("Codes to generate:")
        for code, description in QR_CODES.items():
            print(f"  {code} ({description})")
