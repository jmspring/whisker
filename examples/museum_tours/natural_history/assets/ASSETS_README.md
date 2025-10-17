# Museum Tour Assets

This directory contains placeholder assets for the Natural History Museum tour. Replace these with actual museum content.

## Directory Structure

```
assets/
├── audio/          # Audio guide MP3 files
├── images/         # Exhibit photos and diagrams
├── qr_codes/       # QR code images for printing
└── ASSETS_README.md  # This file
```

## Audio Files (Placeholders)

Replace these placeholder references with actual MP3 audio guides:

| File | Exhibit | Duration | Description |
|------|---------|----------|-------------|
| `dinosaurs.mp3` | Hall A: Dinosaurs | 2:45 | Narrated guide about T-Rex and fossils |
| `ancient_egypt.mp3` | Hall B: Ancient Egypt | 3:10 | Mummies and hieroglyphics |
| `ocean_life.mp3` | Hall C: Ocean Life | 2:30 | Whale skeletons and deep sea |
| `gems_minerals.mp3` | Hall D: Gems & Minerals | 2:15 | Crystals and geology |
| `mammals.mp3` | Hall E: Mammals | 2:50 | Taxidermy and habitats |
| `birds.mp3` | Hall F: Birds | 2:20 | Flight and migration |
| `human_origins.mp3` | Hall G: Human Origins | 3:00 | Evolution and anthropology |
| `butterflies.mp3` | Hall H: Butterflies | 2:10 | Metamorphosis and live exhibit |

### Audio Specifications

- **Format**: MP3 (AAC preferred)
- **Bitrate**: 128 kbps (balance quality/size)
- **Sample rate**: 44.1 kHz
- **Channels**: Mono (saves space, adequate for narration)
- **Length**: 2-3 minutes per exhibit
- **Total size**: ~40-50 MB for all files

### Audio Content Guidelines

Each audio guide should include:
1. **Greeting** (5s) - "Welcome to [exhibit name]"
2. **Overview** (30s) - What visitor will see
3. **Key highlights** (90s) - 2-3 main artifacts/facts
4. **Call to action** (15s) - "Look closely at...", "Notice how..."
5. **Transition** (10s) - "When ready, proceed to..."

### Recording Tips

- Use professional narrator or text-to-speech
- Record in quiet space
- Include 2 seconds silence at start/end
- Normalize audio levels
- Test on mobile device speakers
- Provide transcripts for accessibility

## Images (Placeholders)

Replace placeholder image references with actual exhibit photos:

| File | Exhibit | Size | Description |
|------|---------|------|-------------|
| `trex_skeleton.jpg` | Dinosaurs | 1920x1080 | T-Rex skeleton main display |
| `fossil_wall.jpg` | Dinosaurs | 1920x1080 | Wall of fossils |
| `mummy_case.jpg` | Ancient Egypt | 1920x1080 | Decorated mummy sarcophagus |
| `hieroglyphics.jpg` | Ancient Egypt | 1920x1080 | Temple wall hieroglyphics |
| `blue_whale.jpg` | Ocean Life | 1920x1080 | Blue whale skeleton |
| `deep_sea.jpg` | Ocean Life | 1920x1080 | Deep sea creatures |
| `crystal_cave.jpg` | Gems & Minerals | 1920x1080 | Crystal formation |
| `gemstones.jpg` | Gems & Minerals | 1920x1080 | Precious stones display |
| `african_elephant.jpg` | Mammals | 1920x1080 | Elephant diorama |
| `eagle_flight.jpg` | Birds | 1920x1080 | Eagle in flight display |
| `evolution_chart.jpg` | Human Origins | 1920x1080 | Human evolution diagram |
| `butterfly_wings.jpg` | Butterflies | 1920x1080 | Butterfly wing patterns |

### Image Specifications

- **Format**: JPEG (progressive)
- **Resolution**: 1920x1080 (Full HD)
- **Quality**: 85% (good balance)
- **File size**: < 500 KB per image
- **Total size**: ~6-8 MB for all images
- **Orientation**: Landscape preferred

### Photography Guidelines

- Natural lighting preferred
- No flash on artifacts
- Include museum context
- Capture key identifying features
- Get proper permissions
- Credit photographers

## QR Codes (Placeholders)

Generate QR codes for each exhibit that link to the exhibit passage:

| File | QR Code | Exhibit | URL Pattern |
|------|---------|---------|-------------|
| `entrance.png` | `MUSEUM-ENTRANCE` | Welcome | `?exhibit=welcome` |
| `dino-001.png` | `MUSEUM-DINO-001` | Dinosaurs | `?exhibit=dinosaurs` |
| `egypt-001.png` | `MUSEUM-EGYPT-001` | Ancient Egypt | `?exhibit=ancient_egypt` |
| `ocean-001.png` | `MUSEUM-OCEAN-001` | Ocean Life | `?exhibit=ocean_life` |
| `gems-001.png` | `MUSEUM-GEMS-001` | Gems & Minerals | `?exhibit=gems_minerals` |
| `mammals-001.png` | `MUSEUM-MAMMALS-001` | Mammals | `?exhibit=mammals` |
| `birds-001.png` | `MUSEUM-BIRDS-001` | Birds | `?exhibit=birds` |
| `human-001.png` | `MUSEUM-HUMAN-001` | Human Origins | `?exhibit=human_origins` |
| `butterfly-001.png` | `MUSEUM-BUTTERFLY-001` | Butterflies | `?exhibit=butterflies` |

### QR Code Specifications

- **Size**: 512x512 pixels
- **Format**: PNG (transparent background)
- **Error correction**: High (30% redundancy)
- **Quiet zone**: 4 modules minimum
- **Print size**: 2" x 2" minimum

### QR Code Generation

**Option 1: Online Generator**
```
1. Visit: https://www.qr-code-generator.com/
2. Enter exhibit code (e.g., MUSEUM-DINO-001)
3. Download as PNG, 512x512
4. Test with phone camera
```

**Option 2: Command Line (qrencode)**
```bash
# Install qrencode
brew install qrencode  # macOS
apt-get install qrencode  # Linux

# Generate codes
qrencode -o dino-001.png -s 512 "MUSEUM-DINO-001"
qrencode -o egypt-001.png -s 512 "MUSEUM-EGYPT-001"
# ... etc
```

**Option 3: Python Script**
```python
import qrcode

exhibits = [
    ("entrance.png", "MUSEUM-ENTRANCE"),
    ("dino-001.png", "MUSEUM-DINO-001"),
    ("egypt-001.png", "MUSEUM-EGYPT-001"),
    # ... etc
]

for filename, code in exhibits:
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=10,
        border=4,
    )
    qr.add_data(code)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    img.save(f"assets/qr_codes/{filename}")
```

### Physical Labels

Print QR codes on weatherproof labels:
- **Material**: Vinyl or laminated paper
- **Size**: 3" x 3" (QR + text)
- **Mounting**: Adhesive or stand
- **Placement**: Eye level, well-lit, 2-3 feet from artifact
- **Text**: Include exhibit name and "Scan for audio guide"

## PWA Icons (Placeholders)

Generate app icons for Progressive Web App installation:

| File | Size | Purpose |
|------|------|---------|
| `icon-72.png` | 72x72 | iOS, Android launcher |
| `icon-96.png` | 96x96 | Android launcher |
| `icon-128.png` | 128x128 | Desktop PWA |
| `icon-144.png` | 144x144 | Android launcher |
| `icon-152.png` | 152x152 | iOS home screen |
| `icon-192.png` | 192x192 | Android launcher (standard) |
| `icon-384.png` | 384x384 | Android launcher (high-res) |
| `icon-512.png` | 512x512 | Android splash screen |

### Icon Design Guidelines

**Design:**
- Simple, recognizable symbol (🏛️ museum building)
- Bold colors (matches brand)
- High contrast
- No text (too small)
- Square canvas with padding

**Technical:**
- PNG format with transparency
- sRGB color space
- No compression artifacts
- Test on various backgrounds

**Generation:**
```bash
# From SVG using ImageMagick
convert -background none -resize 72x72 icon.svg icon-72.png
convert -background none -resize 96x96 icon.svg icon-96.png
convert -background none -resize 128x128 icon.svg icon-128.png
convert -background none -resize 144x144 icon.svg icon-144.png
convert -background none -resize 152x152 icon.svg icon-152.png
convert -background none -resize 192x192 icon.svg icon-192.png
convert -background none -resize 384x384 icon.svg icon-384.png
convert -background none -resize 512x512 icon.svg icon-512.png
```

**Online Tools:**
- https://realfavicongenerator.net/
- https://www.pwabuilder.com/imageGenerator

## Asset Workflow

### For Museums Creating Tours

1. **Collect Assets**
   - Photograph exhibits (professional or smartphone)
   - Record audio guides (narrator or TTS)
   - Document metadata (titles, descriptions, dates)

2. **Process Assets**
   - Resize images (1920x1080, 85% quality)
   - Compress audio (MP3, 128kbps, mono)
   - Generate QR codes (512x512, high error correction)
   - Create PWA icons (all sizes)

3. **Organize Files**
   - Place in appropriate folders
   - Name consistently
   - Update story.whisker references
   - Test all links

4. **Optimize**
   - Total audio: < 50 MB
   - Total images: < 10 MB
   - Total QR codes: < 2 MB
   - PWA icons: < 1 MB
   - **Total target: < 100 MB for offline support**

5. **Deploy**
   - Upload to web server
   - Update manifest.json paths
   - Test offline functionality
   - Print QR code labels

## Testing Assets

### Audio Testing
```bash
# Test playback
open assets/audio/dinosaurs.mp3

# Check duration
ffprobe -i assets/audio/dinosaurs.mp3 -show_entries format=duration

# Check bitrate
ffprobe -i assets/audio/dinosaurs.mp3 -show_entries format=bit_rate
```

### Image Testing
```bash
# Check dimensions
file assets/images/trex_skeleton.jpg

# Check file size
ls -lh assets/images/

# View
open assets/images/trex_skeleton.jpg
```

### QR Code Testing
```bash
# Test with phone camera
# Should recognize and offer to navigate

# Verify content (if using zbarimg)
zbarimg assets/qr_codes/dino-001.png
```

## Copyright & Licensing

**Important**: Ensure you have rights to use all assets:

- ✅ Own photography
- ✅ Museum-owned content (with permission)
- ✅ Creative Commons (check license)
- ✅ Stock photos (with proper license)
- ❌ Copyrighted images without permission
- ❌ Getty Images watermarked
- ❌ Other museum's photos

**Recommended:**
- Use your museum's own photos
- Hire photographer
- Use Creative Commons (CC-BY or CC0)
- Credit all sources in tour metadata

## Placeholder Assets

For testing, this tour includes placeholder references. Replace with actual content before production deployment.

**Placeholder Strategy:**
- Audio: Silent MP3 files or TTS-generated guides
- Images: Museum logo or exhibit signage photos
- QR codes: Generated from exhibit IDs
- Icons: Simple museum emoji as base

## Budget Estimate

**For 10-exhibit tour:**
- Professional photography: $500-1000
- Audio recording (narrator): $1000-2000
- QR code labels (printed): $50-100
- Icon design: $200-500
- Total: **$1750-3600**

**DIY Option:**
- Smartphone photos: Free
- Text-to-speech audio: Free
- Self-generated QR codes: Free
- Simple icon design: Free
- Total: **$0-50** (printing only)

---

**Ready to create your museum tour?** Start by gathering exhibit photos and recording audio guides, then replace these placeholders with your actual content.
