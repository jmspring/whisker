#!/usr/bin/env python3
"""
Generate placeholder audio files for Rijksmuseum tour
Creates silent MP3 files with correct durations
Requires: pip install pydub
"""

import os
from pathlib import Path

try:
    from pydub import AudioSegment
    from pydub.generators import Sine
    PYDUB_AVAILABLE = True
except ImportError:
    PYDUB_AVAILABLE = False

# Audio files needed (filename: duration in seconds)
AUDIO_FILES = {
    'night_watch.mp3': 240,          # 4:00
    'milkmaid.mp3': 180,             # 3:00
    'merry_drinker.mp3': 150,        # 2:30
    'self_portrait_paul.mp3': 180,   # 3:00
    'jewish_bride.mp3': 180,         # 3:00
    'still_life.mp3': 150,           # 2:30
    'threatened_swan.mp3': 150,      # 2:30
    'winter_landscape.mp3': 180,     # 3:00
    'delftware.mp3': 150,            # 2:30
    'battle_waterloo.mp3': 180,      # 3:00
    'warship_model.mp3': 150,        # 2:30
    'dutch_dollhouse.mp3': 180,      # 3:00
}

def format_duration(seconds):
    """Format seconds as M:SS"""
    minutes = seconds // 60
    secs = seconds % 60
    return f"{minutes}:{secs:02d}"

def create_silent_audio(duration_seconds, output_path):
    """Create a silent audio file."""
    # Create silent audio segment
    silent = AudioSegment.silent(duration=duration_seconds * 1000)  # milliseconds

    # Export as MP3
    silent.export(
        output_path,
        format="mp3",
        bitrate="128k",
        parameters=["-ar", "44100", "-ac", "1"]  # 44.1kHz, mono
    )

def generate_audio_placeholders():
    """Generate all placeholder audio files."""

    print("🎧 Generating Placeholder Audio Files for Rijksmuseum Tour")
    print("=" * 70)

    if not PYDUB_AVAILABLE:
        print("⚠️  pydub not available - creating text marker files")
        print()
        create_marker_files()
        return

    print("✅ pydub available - generating silent MP3 files")
    print()

    # Create directories
    Path('assets/audio/en').mkdir(parents=True, exist_ok=True)
    Path('assets/audio/nl').mkdir(parents=True, exist_ok=True)

    total_duration = 0

    for filename, duration in AUDIO_FILES.items():
        # Generate English version
        en_path = f"assets/audio/en/{filename}"
        create_silent_audio(duration, en_path)
        print(f"✅ Generated: en/{filename} ({format_duration(duration)} silent)")

        # Generate Dutch version
        nl_path = f"assets/audio/nl/{filename}"
        create_silent_audio(duration, nl_path)
        print(f"✅ Generated: nl/{filename} ({format_duration(duration)} silent)")

        total_duration += duration

    print()
    print("=" * 70)
    print(f"✅ All 24 placeholder audio files generated! (12 en + 12 nl)")
    print(f"📁 Location: assets/audio/en/ and assets/audio/nl/")
    print(f"⏱️  Total audio time: {format_duration(total_duration)} per language")
    print()
    print_replacement_instructions()

def create_marker_files():
    """Create text marker files when audio generation isn't possible."""

    # Create directories
    Path('assets/audio/en').mkdir(parents=True, exist_ok=True)
    Path('assets/audio/nl').mkdir(parents=True, exist_ok=True)

    for filename, duration in AUDIO_FILES.items():
        duration_str = format_duration(duration)

        # English marker
        en_marker = f"assets/audio/en/{filename}.txt"
        with open(en_marker, 'w') as f:
            f.write(f"PLACEHOLDER: Replace with actual {duration_str} English narration\n")
            f.write(f"Duration: {duration} seconds\n")
            f.write(f"Format: MP3, 128kbps, mono, 44.1kHz\n")
        print(f"✅ Created marker: en/{filename}.txt")

        # Dutch marker
        nl_marker = f"assets/audio/nl/{filename}.txt"
        with open(nl_marker, 'w') as f:
            f.write(f"PLACEHOLDER: Replace with actual {duration_str} Dutch narration\n")
            f.write(f"Duration: {duration} seconds\n")
            f.write(f"Format: MP3, 128kbps, mono, 44.1kHz\n")
        print(f"✅ Created marker: nl/{filename}.txt")

    print()
    print("=" * 70)
    print("⚠️  Created 24 marker files (pydub not available for actual MP3s)")
    print("📁 Location: assets/audio/en/ and assets/audio/nl/")
    print()
    print("To generate actual silent MP3s:")
    print("  pip install pydub")
    print("  python3 generate_audio_placeholders.py")
    print()
    print_replacement_instructions()

def print_replacement_instructions():
    """Print instructions for replacing placeholders."""
    print("=" * 70)
    print("⚠️  IMPORTANT: These are placeholders!")
    print()
    print("To create actual audio guides:")
    print("1. Extract scripts from rijksmuseum_tour.whisker passages")
    print("2. Record professional narration (or use TTS):")
    print("   - Option A: Professional narrator + studio (€6,000)")
    print("   - Option B: High-quality TTS like Azure/Google (€300)")
    print("3. Format: MP3, 128kbps, mono, 44.1kHz")
    print("4. Duration: As specified per file (2:30 - 4:00)")
    print("5. Replace placeholder files with actual recordings")
    print()
    print("Audio specifications:")
    print("  - Format: MP3")
    print("  - Bitrate: 128 kbps")
    print("  - Sample rate: 44.1 kHz")
    print("  - Channels: Mono (saves space)")
    print("  - Total size: ~40-50 MB for all 24 files")
    print("=" * 70)

if __name__ == '__main__':
    generate_audio_placeholders()
