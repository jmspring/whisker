#!/bin/bash
# Generate placeholder audio files for Rijksmuseum tour
# These are silent MP3 placeholders - replace with actual narration

echo "🎧 Generating Placeholder Audio Files for Rijksmuseum Tour"
echo "========================================================================"
echo "⚠️  Note: These are SILENT PLACEHOLDERS - Replace with actual audio"
echo "========================================================================"

# Audio files needed (English and Dutch)
declare -A AUDIO_FILES=(
    ["night_watch.mp3"]="240"      # 4:00
    ["milkmaid.mp3"]="180"          # 3:00
    ["merry_drinker.mp3"]="150"     # 2:30
    ["self_portrait_paul.mp3"]="180" # 3:00
    ["jewish_bride.mp3"]="180"      # 3:00
    ["still_life.mp3"]="150"        # 2:30
    ["threatened_swan.mp3"]="150"   # 2:30
    ["winter_landscape.mp3"]="180"  # 3:00
    ["delftware.mp3"]="150"         # 2:30
    ["battle_waterloo.mp3"]="180"   # 3:00
    ["warship_model.mp3"]="150"     # 2:30
    ["dutch_dollhouse.mp3"]="180"   # 3:00
)

# Function to create silent MP3 using ffmpeg
create_silent_mp3() {
    local filename=$1
    local duration=$2
    local output=$3

    if command -v ffmpeg &> /dev/null; then
        # Create silent audio with ffmpeg
        ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t $duration -q:a 9 -acodec libmp3lame "$output" -y 2>/dev/null
        return 0
    else
        return 1
    fi
}

# Try to create actual silent MP3 files
if command -v ffmpeg &> /dev/null; then
    echo "✅ ffmpeg found - generating actual silent MP3 files"
    echo ""

    # Generate English audio files
    mkdir -p assets/audio/en
    for filename in "${!AUDIO_FILES[@]}"; do
        duration="${AUDIO_FILES[$filename]}"
        output="assets/audio/en/$filename"
        create_silent_mp3 "$filename" "$duration" "$output"
        minutes=$((duration / 60))
        seconds=$((duration % 60))
        echo "✅ Generated: en/$filename (${minutes}:$(printf '%02d' $seconds) silent)"
    done

    echo ""

    # Generate Dutch audio files
    mkdir -p assets/audio/nl
    for filename in "${!AUDIO_FILES[@]}"; do
        duration="${AUDIO_FILES[$filename]}"
        output="assets/audio/nl/$filename"
        create_silent_mp3 "$filename" "$duration" "$output"
        minutes=$((duration / 60))
        seconds=$((duration % 60))
        echo "✅ Generated: nl/$filename (${minutes}:$(printf '%02d' $seconds) silent)"
    done

    echo ""
    echo "========================================================================"
    echo "✅ All 24 placeholder audio files generated! (12 en + 12 nl)"
    echo "📁 Location: assets/audio/en/ and assets/audio/nl/"

else
    echo "⚠️  ffmpeg not available - creating placeholder marker files"
    echo ""

    # Create marker files instead
    mkdir -p assets/audio/en assets/audio/nl

    for filename in "${!AUDIO_FILES[@]}"; do
        duration="${AUDIO_FILES[$filename]}"
        minutes=$((duration / 60))
        seconds=$((duration % 60))

        # English placeholder
        echo "PLACEHOLDER: Replace with actual ${minutes}:$(printf '%02d' $seconds) English narration" > "assets/audio/en/$filename.txt"
        echo "✅ Created marker: en/$filename.txt"

        # Dutch placeholder
        echo "PLACEHOLDER: Replace with actual ${minutes}:$(printf '%02d' $seconds) Dutch narration" > "assets/audio/nl/$filename.txt"
        echo "✅ Created marker: nl/$filename.txt"
    done

    echo ""
    echo "========================================================================"
    echo "⚠️  Created marker files (ffmpeg not available for actual MP3s)"
    echo "📁 Location: assets/audio/en/ and assets/audio/nl/"
fi

echo ""
echo "========================================================================"
echo "⚠️  IMPORTANT: These are placeholders!"
echo ""
echo "To create actual audio guides:"
echo "1. Extract scripts from rijksmuseum_tour.whisker passages"
echo "2. Record professional narration (or use TTS):"
echo "   - Option A: Professional narrator + studio (€6,000)"
echo "   - Option B: High-quality TTS like Azure/Google (€300)"
echo "3. Format: MP3, 128kbps, mono, 44.1kHz"
echo "4. Duration: As specified per file (2:30 - 4:00)"
echo "5. Replace placeholder files with actual recordings"
echo ""
echo "Audio specifications:"
echo "  - Format: MP3"
echo "  - Bitrate: 128 kbps"
echo "  - Sample rate: 44.1 kHz"
echo "  - Channels: Mono (saves space)"
echo "  - Total size: ~40-50 MB for all 24 files"
echo "========================================================================"
