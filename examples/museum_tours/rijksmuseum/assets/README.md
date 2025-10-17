# Rijksmuseum Tour - Assets Directory

This directory contains all media assets for the Rijksmuseum "Masters of Light" tour.

## 📁 Directory Structure

```
assets/
├── README.md           # This file
├── audio/              # Audio guides (24 files)
│   ├── en/            # English narration (12 MP3s)
│   └── nl/            # Dutch narration (12 MP3s)
├── images/            # Artwork images (13 JPEGs)
└── qr_codes/          # QR code images (13 PNGs)
```

## ✅ Assets Generated

### QR Codes (13 files) ✅ COMPLETE

All 13 QR code images have been generated:

```
✅ RIJKS-WELCOME.png              (Welcome / Entrance)
✅ RIJKS-NIGHTWATCH-001.png       (The Night Watch)
✅ RIJKS-MILKMAID-002.png         (The Milkmaid)
✅ RIJKS-DRINKER-003.png          (The Merry Drinker)
✅ RIJKS-REMBRANDT-SELF-004.png   (Self-Portrait as Paul)
✅ RIJKS-BRIDE-005.png            (The Jewish Bride)
✅ RIJKS-STILLLIFE-006.png        (Still Life with Flowers)
✅ RIJKS-SWAN-007.png             (The Threatened Swan)
✅ RIJKS-WINTER-008.png           (Winter Landscape)
✅ RIJKS-DELFTWARE-009.png        (Delftware Collection)
✅ RIJKS-WATERLOO-010.png         (Battle of Waterloo)
✅ RIJKS-WARSHIP-011.png          (Warship Model)
✅ RIJKS-DOLLHOUSE-012.png        (Dutch Dollhouse)
```

**Specifications:**
- Format: PNG
- Size: High resolution (suitable for printing)
- Error correction: High (L level)
- Ready for printing at 5cm × 5cm (artworks) or 10cm × 10cm (entrance)

**Usage:**
1. Print on museum-quality materials
2. Mount at artwork locations (lower right of display labels)
3. Entrance QR code at welcome area
4. Visitors scan with phone camera to access tour

### Images (13 files) ✅ PLACEHOLDERS GENERATED

Placeholder images created for all 13 exhibits:

```
✅ gallery_of_honour.jpg          (Welcome screen)
✅ night_watch.jpg                (Rembrandt)
✅ milkmaid.jpg                   (Vermeer)
✅ merry_drinker.jpg              (Frans Hals)
✅ self_portrait_paul.jpg         (Rembrandt)
✅ jewish_bride.jpg               (Rembrandt)
✅ still_life.jpg                 (Van Huysum)
✅ threatened_swan.jpg            (Asselijn)
✅ winter_landscape.jpg           (Avercamp)
✅ delftware.jpg                  (Collection)
✅ battle_waterloo.jpg            (Pieneman)
✅ warship_model.jpg              (Ship model)
✅ dutch_dollhouse.jpg            (Oortman)
```

**Current Status:** PLACEHOLDERS
- These are temporary placeholder images with artwork titles
- Replace with actual Rijksmuseum collection images

**Specifications (Target):**
- Format: JPEG (progressive)
- Resolution: 1920×1080 pixels
- Quality: 85%
- Color space: sRGB
- File size: < 800 KB each
- Total: ~6-8 MB

**Replacement Instructions:**

1. **Access Rijksmuseum API:**
   ```bash
   # Rijksmuseum provides free API access
   # Most artworks are public domain
   # Visit: https://data.rijksmuseum.nl/object-metadata/api/
   ```

2. **Download Images:**
   - Visit: https://www.rijksmuseum.nl/en/rijksstudio
   - Search for each artwork by name
   - Download highest resolution available
   - Most images are free (CC0 or public domain)

3. **Optimize for Web:**
   ```bash
   # Using ImageMagick
   convert original.jpg -resize 1920x1080 -quality 85 -interlace Plane output.jpg

   # Or use online tools
   # - TinyJPG: https://tinyjpg.com/
   # - Squoosh: https://squoosh.app/
   ```

4. **Replace Files:**
   - Same filenames as placeholders
   - Maintain 1920×1080 resolution
   - Progressive JPEG format
   - 85% quality for balance

### Audio (24 files) ⚠️ MARKERS CREATED

Audio file markers created (text placeholders):

**English (12 files):**
```
⚠️ night_watch.mp3 (4:00)
⚠️ milkmaid.mp3 (3:00)
⚠️ merry_drinker.mp3 (2:30)
⚠️ self_portrait_paul.mp3 (3:00)
⚠️ jewish_bride.mp3 (3:00)
⚠️ still_life.mp3 (2:30)
⚠️ threatened_swan.mp3 (2:30)
⚠️ winter_landscape.mp3 (3:00)
⚠️ delftware.mp3 (2:30)
⚠️ battle_waterloo.mp3 (3:00)
⚠️ warship_model.mp3 (2:30)
⚠️ dutch_dollhouse.mp3 (3:00)
```

**Dutch (12 files):** Same filenames, Dutch narration

**Current Status:** TEXT MARKERS
- Placeholder text files created
- Scripts embedded in tour story (rijksmuseum_tour.whisker)
- Ready for professional recording or TTS generation

**Specifications:**
- Format: MP3
- Bitrate: 128 kbps
- Sample rate: 44.1 kHz
- Channels: Mono (saves space)
- Duration: 2:30 - 4:00 per file
- Total size: ~40-50 MB (all 24 files)

**Creation Options:**

**Option A: Professional Recording (€6,000)**
1. Extract scripts from tour passages
2. Hire professional Dutch + English narrators
3. Studio recording with sound engineer
4. Professional editing and mastering
5. Export as MP3 (128kbps, mono, 44.1kHz)

**Option B: High-Quality TTS (€300)**
1. Extract scripts from tour passages
2. Use Azure Neural TTS or Google Cloud TTS
3. Select natural-sounding voices:
   - English: en-US-JennyNeural (friendly, clear)
   - Dutch: nl-NL-ColetteNeural (professional, warm)
4. Generate with SSML for natural pacing
5. Export as MP3

**Example TTS Generation (Azure):**
```python
import azure.cognitiveservices.speech as speechsdk

speech_config = speechsdk.SpeechConfig(
    subscription="YOUR_KEY",
    region="westeurope"
)

speech_config.speech_synthesis_voice_name = "nl-NL-ColetteNeural"
speech_config.set_speech_synthesis_output_format(
    speechsdk.SpeechSynthesisOutputFormat.Audio16Khz128KBitRateMonoMp3
)

synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config)
result = synthesizer.speak_text_async(script_text).get()

with open("night_watch.mp3", "wb") as audio_file:
    audio_file.write(result.audio_data)
```

**Script Extraction:**

All audio scripts are embedded in `rijksmuseum_tour.whisker` in the passage text. Extract the markdown content between headings for each artwork.

Example script structure:
```markdown
# The Night Watch
## Rembrandt van Rijn, 1642

[Overview section - 30 seconds]
[What you're seeing - 60 seconds]
[Key details - 90 seconds]
[Historical context - 60 seconds]
[Artist biography - 30 seconds]
[Closing - 30 seconds]

Total: ~4:00 minutes
```

## 📊 Asset Status Summary

| Asset Type | Count | Status | Size | Ready |
|------------|-------|--------|------|-------|
| QR Codes | 13 | ✅ Complete | ~50 KB | ✅ Yes |
| Images | 13 | ⚠️ Placeholders | ~6 MB | ⚠️ Replace |
| Audio EN | 12 | ⚠️ Markers | ~20 MB | ⚠️ Record |
| Audio NL | 12 | ⚠️ Markers | ~20 MB | ⚠️ Record |
| **Total** | **50** | **26% Complete** | **~46 MB** | **Partial** |

## 🚀 Production Checklist

### Ready for Production ✅
- [x] QR codes generated (13/13)
- [x] Directory structure created
- [x] Image placeholders generated
- [x] Audio markers created
- [x] Documentation complete

### Needs Replacement ⚠️
- [ ] Replace placeholder images with Rijksmuseum collection images
- [ ] Record or generate English audio narration (12 files)
- [ ] Record or generate Dutch audio narration (12 files)
- [ ] Test audio playback in web runtime
- [ ] Test images display correctly
- [ ] Print and mount QR codes physically

## 🛠️ Asset Generation Scripts

All scripts are in the parent directory:

```bash
# Generate QR codes (✅ Already run)
python3 ../generate_qr_codes.py

# Generate placeholder images (✅ Already run)
python3 ../generate_placeholder_images.py

# Generate audio markers (✅ Already run)
python3 ../generate_audio_placeholders.py

# Generate PWA icons (✅ Already run)
python3 ../generate_pwa_icons.py
```

## 📝 Next Steps

1. **Download Rijksmuseum Images** (1-2 hours)
   - Access Rijksmuseum API or website
   - Download 13 high-resolution images
   - Optimize for web (1920×1080, 85% quality)
   - Replace placeholder files

2. **Record Audio Guides** (1-2 weeks)
   - Extract scripts from tour story
   - Choose Option A (professional) or Option B (TTS)
   - Generate 24 MP3 files (12 artworks × 2 languages)
   - Replace marker files

3. **Print QR Codes** (1 day)
   - Print 13 QR codes on museum-quality materials
   - Size: 5cm × 5cm for artworks, 10cm × 10cm for entrance
   - Mount at artwork locations
   - Test scanning with various phone cameras

4. **Test Everything** (2-3 days)
   - Load tour in web runtime
   - Test image display and zoom
   - Test audio playback (all 24 files)
   - Test QR code scanning
   - Test on multiple devices (iOS, Android)

## 💰 Cost Estimate

| Item | Professional | Cost-Effective |
|------|-------------|----------------|
| Images | €500 (licensing) | €200 (API access) |
| Audio | €6,000 (studio) | €300 (TTS) |
| QR Codes | €400 (professional print) | €50 (DIY print) |
| Icons | €800 (designer) | €0 (generated) |
| **Total** | **€7,700** | **€550** |

## 📞 Support

For questions about:
- **Asset specifications:** See PROPOSAL.md
- **Image sources:** Contact Rijksmuseum
- **Audio recording:** See IMPLEMENTATION_SUMMARY.md
- **Technical issues:** Check parent README.md

---

**Status:** QR codes complete, images and audio need replacement
**Last Updated:** 2024-01-15
**Project:** Rijksmuseum Digital Tour - Masters of Light
