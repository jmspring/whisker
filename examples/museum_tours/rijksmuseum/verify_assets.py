#!/usr/bin/env python3
"""
Verify all assets for Rijksmuseum tour
Checks that all required files are present
"""

import json
from pathlib import Path
from collections import defaultdict

# Required files
REQUIRED_QR_CODES = [
    'RIJKS-WELCOME.png',
    'RIJKS-NIGHTWATCH-001.png',
    'RIJKS-MILKMAID-002.png',
    'RIJKS-DRINKER-003.png',
    'RIJKS-REMBRANDT-SELF-004.png',
    'RIJKS-BRIDE-005.png',
    'RIJKS-STILLLIFE-006.png',
    'RIJKS-SWAN-007.png',
    'RIJKS-WINTER-008.png',
    'RIJKS-DELFTWARE-009.png',
    'RIJKS-WATERLOO-010.png',
    'RIJKS-WARSHIP-011.png',
    'RIJKS-DOLLHOUSE-012.png',
]

REQUIRED_IMAGES = [
    'gallery_of_honour.jpg',
    'night_watch.jpg',
    'milkmaid.jpg',
    'merry_drinker.jpg',
    'self_portrait_paul.jpg',
    'jewish_bride.jpg',
    'still_life.jpg',
    'threatened_swan.jpg',
    'winter_landscape.jpg',
    'delftware.jpg',
    'battle_waterloo.jpg',
    'warship_model.jpg',
    'dutch_dollhouse.jpg',
]

REQUIRED_AUDIO = [
    'night_watch.mp3',
    'milkmaid.mp3',
    'merry_drinker.mp3',
    'self_portrait_paul.mp3',
    'jewish_bride.mp3',
    'still_life.mp3',
    'threatened_swan.mp3',
    'winter_landscape.mp3',
    'delftware.mp3',
    'battle_waterloo.mp3',
    'warship_model.mp3',
    'dutch_dollhouse.mp3',
]

PWA_ICON_SIZES = [72, 96, 128, 144, 152, 192, 384, 512]

def check_file_exists(filepath):
    """Check if file exists and return size."""
    path = Path(filepath)
    if path.exists():
        size = path.stat().st_size
        return True, size
    return False, 0

def format_size(bytes):
    """Format bytes as human-readable."""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if bytes < 1024.0:
            return f"{bytes:.1f} {unit}"
        bytes /= 1024.0
    return f"{bytes:.1f} TB"

def verify_assets():
    """Verify all required assets."""

    print("=" * 80)
    print("  RIJKSMUSEUM TOUR - ASSET VERIFICATION")
    print("=" * 80)
    print()

    results = defaultdict(lambda: {'found': [], 'missing': [], 'total_size': 0})

    # Check QR codes
    print("📋 QR CODES (13 required)")
    print("-" * 80)
    for qr_code in REQUIRED_QR_CODES:
        filepath = f"assets/qr_codes/{qr_code}"
        exists, size = check_file_exists(filepath)
        if exists:
            results['qr_codes']['found'].append(qr_code)
            results['qr_codes']['total_size'] += size
            print(f"  ✅ {qr_code:<30} ({format_size(size)})")
        else:
            results['qr_codes']['missing'].append(qr_code)
            print(f"  ❌ {qr_code:<30} MISSING")

    print(f"\nFound: {len(results['qr_codes']['found'])}/{len(REQUIRED_QR_CODES)}")
    print(f"Total size: {format_size(results['qr_codes']['total_size'])}")
    print()

    # Check images
    print("🖼️  IMAGES (13 required)")
    print("-" * 80)
    for image in REQUIRED_IMAGES:
        filepath = f"assets/images/{image}"
        exists, size = check_file_exists(filepath)
        status = "PLACEHOLDER" if exists and size < 500000 else "ACTUAL"
        if exists:
            results['images']['found'].append(image)
            results['images']['total_size'] += size
            print(f"  ✅ {image:<30} ({format_size(size)}) [{status}]")
        else:
            results['images']['missing'].append(image)
            print(f"  ❌ {image:<30} MISSING")

    print(f"\nFound: {len(results['images']['found'])}/{len(REQUIRED_IMAGES)}")
    print(f"Total size: {format_size(results['images']['total_size'])}")
    print()

    # Check audio files (English)
    print("🎧 AUDIO - ENGLISH (12 required)")
    print("-" * 80)
    for audio in REQUIRED_AUDIO:
        filepath = f"assets/audio/en/{audio}"
        marker_filepath = f"assets/audio/en/{audio}.txt"
        exists, size = check_file_exists(filepath)
        marker_exists, _ = check_file_exists(marker_filepath)

        if exists:
            results['audio_en']['found'].append(audio)
            results['audio_en']['total_size'] += size
            print(f"  ✅ {audio:<30} ({format_size(size)}) [ACTUAL]")
        elif marker_exists:
            results['audio_en']['found'].append(f"{audio}.txt")
            print(f"  ⚠️  {audio:<30} MARKER FILE ONLY")
        else:
            results['audio_en']['missing'].append(audio)
            print(f"  ❌ {audio:<30} MISSING")

    print(f"\nFound: {len(results['audio_en']['found'])}/{len(REQUIRED_AUDIO)}")
    print(f"Total size: {format_size(results['audio_en']['total_size'])}")
    print()

    # Check audio files (Dutch)
    print("🎧 AUDIO - DUTCH (12 required)")
    print("-" * 80)
    for audio in REQUIRED_AUDIO:
        filepath = f"assets/audio/nl/{audio}"
        marker_filepath = f"assets/audio/nl/{audio}.txt"
        exists, size = check_file_exists(filepath)
        marker_exists, _ = check_file_exists(marker_filepath)

        if exists:
            results['audio_nl']['found'].append(audio)
            results['audio_nl']['total_size'] += size
            print(f"  ✅ {audio:<30} ({format_size(size)}) [ACTUAL]")
        elif marker_exists:
            results['audio_nl']['found'].append(f"{audio}.txt")
            print(f"  ⚠️  {audio:<30} MARKER FILE ONLY")
        else:
            results['audio_nl']['missing'].append(audio)
            print(f"  ❌ {audio:<30} MISSING")

    print(f"\nFound: {len(results['audio_nl']['found'])}/{len(REQUIRED_AUDIO)}")
    print(f"Total size: {format_size(results['audio_nl']['total_size'])}")
    print()

    # Check PWA icons
    print("🎨 PWA ICONS (8 required)")
    print("-" * 80)
    for size in PWA_ICON_SIZES:
        filepath = f"../../web_runtime/icons/icon-{size}.png"
        exists, file_size = check_file_exists(filepath)
        if exists:
            results['pwa_icons']['found'].append(f"icon-{size}.png")
            results['pwa_icons']['total_size'] += file_size
            print(f"  ✅ icon-{size}.png ({size}×{size}px, {format_size(file_size)})")
        else:
            results['pwa_icons']['missing'].append(f"icon-{size}.png")
            print(f"  ❌ icon-{size}.png MISSING")

    print(f"\nFound: {len(results['pwa_icons']['found'])}/{len(PWA_ICON_SIZES)}")
    print(f"Total size: {format_size(results['pwa_icons']['total_size'])}")
    print()

    # Check tour story
    print("📖 TOUR STORY")
    print("-" * 80)
    story_path = "rijksmuseum_tour.whisker"
    exists, size = check_file_exists(story_path)
    if exists:
        print(f"  ✅ rijksmuseum_tour.whisker ({format_size(size)})")

        # Validate JSON
        try:
            with open(story_path, 'r') as f:
                story = json.load(f)
                print(f"  ✅ Valid JSON")
                print(f"  ✅ Format: {story.get('format')} {story.get('formatVersion')}")
                print(f"  ✅ Passages: {len(story.get('passages', []))}")
                print(f"  ✅ Title: {story.get('metadata', {}).get('title')}")
        except Exception as e:
            print(f"  ❌ JSON Error: {e}")
    else:
        print(f"  ❌ rijksmuseum_tour.whisker MISSING")
    print()

    # Summary
    print("=" * 80)
    print("  SUMMARY")
    print("=" * 80)

    total_found = 0
    total_required = 0

    categories = [
        ('QR Codes', len(REQUIRED_QR_CODES), len(results['qr_codes']['found'])),
        ('Images', len(REQUIRED_IMAGES), len(results['images']['found'])),
        ('Audio EN', len(REQUIRED_AUDIO), len(results['audio_en']['found'])),
        ('Audio NL', len(REQUIRED_AUDIO), len(results['audio_nl']['found'])),
        ('PWA Icons', len(PWA_ICON_SIZES), len(results['pwa_icons']['found'])),
    ]

    for category, required, found in categories:
        total_required += required
        total_found += found
        percentage = (found / required * 100) if required > 0 else 0
        status = "✅" if found == required else "⚠️"
        print(f"{status} {category:<12} {found:>2}/{required:<2} ({percentage:>5.1f}%)")

    print("-" * 80)
    total_percentage = (total_found / total_required * 100) if total_required > 0 else 0
    print(f"   {'TOTAL':<12} {total_found:>2}/{total_required:<2} ({total_percentage:>5.1f}%)")
    print()

    # Total size
    total_size = sum(r['total_size'] for r in results.values())
    print(f"Total asset size: {format_size(total_size)}")
    print()

    # Status
    print("=" * 80)
    if total_found == total_required:
        print("  ✅ STATUS: ALL ASSETS COMPLETE")
    else:
        print("  ⚠️  STATUS: PARTIAL - SOME ASSETS NEED REPLACEMENT")
        print()
        print("  Next steps:")
        if len(results['audio_en']['found']) < len(REQUIRED_AUDIO):
            print("  - Record English audio narration (12 files)")
        if len(results['audio_nl']['found']) < len(REQUIRED_AUDIO):
            print("  - Record Dutch audio narration (12 files)")
        if any('PLACEHOLDER' in str(img) for img in results['images']['found']):
            print("  - Replace placeholder images with Rijksmuseum collection images")

    print("=" * 80)

if __name__ == '__main__':
    verify_assets()
