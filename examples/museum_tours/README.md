# Museum Tours - Interactive Museum Guide System

A complete reference implementation of a self-guided museum tour system using Whisker. This example demonstrates how to create rich, interactive museum experiences that work offline on mobile devices.

## Overview

The museum tour system consists of:

1. **Story Format**: Whisker 2.0 stories with museum-specific metadata
2. **CLI Client**: Cross-platform command-line client for testing and development
3. **Service Architecture**: Foundation for iOS/Android native apps
4. **Example Tour**: Complete Natural History Museum tour with 10 exhibits

## Features

✅ **Offline-capable**: Tours work without internet connection
✅ **Audio guides**: Support for narrated exhibit descriptions
✅ **QR code navigation**: Quick access to specific exhibits
✅ **Progress tracking**: Monitor visitor engagement and completion
✅ **Flexible navigation**: Linear or free-roaming tour modes
✅ **Multi-language ready**: Structure supports translations
✅ **Analytics**: Privacy-first visitor insights
✅ **Cross-platform**: Works on any device with Lua support

## Quick Start (2 Minutes)

### Test CLI Client

```bash
# Install Lua (if needed)
brew install lua              # macOS
# sudo apt-get install lua5.3 # Linux
# download from lua.org       # Windows

# Run the example tour
cd examples/museum_tours
lua museum_client.lua natural_history/story.whisker
```

**Commands:** `[m]ap` | `[q]r` scan | `[s]tats` | `[h]elp` | `[x]` exit

### Test Web Runtime

```bash
cd examples/web_runtime
python3 -m http.server 8000
open http://localhost:8000/museum.html
```

**On mobile:**
```bash
# Find your IP address
ifconfig | grep inet  # macOS/Linux
ipconfig              # Windows

# Open on phone: http://YOUR_IP:8000/museum.html
```

## Example Tour: Natural History Museum

Located in `natural_history/story.whisker`

**Contents:**
- 10 main exhibits (Dinosaurs, Ancient Egypt, Ocean Life, Gems, etc.)
- 45-minute estimated tour time
- Audio guide for each exhibit (2-3 minutes)
- QR codes for direct access
- Progress tracking and analytics
- Multiple navigation paths

**Exhibits:**
1. 🦕 Hall A: Dinosaurs - Age of Reptiles
2. 🏺 Hall B: Ancient Egypt - Mysteries of the Pharaohs
3. 🐋 Hall C: Ocean Life - Beneath the Waves
4. 💎 Hall D: Gems & Minerals - Treasures of the Earth
5. 🦁 Hall E: Mammals - Wild Kingdom
6. 🦅 Hall F: Birds - Masters of Flight
7. 🧬 Hall G: Human Origins - Our Story
8. 🦋 Hall H: Butterflies - Living Jewels

## Story Format

Museum tours use Whisker 2.0 format with enhanced metadata:

```json
{
  "formatVersion": "2.0",
  "metadata": {
    "title": "Natural History Museum Tour",
    "museum": "Smithsonian National Museum",
    "estimatedTime": "45 minutes",
    "exhibitCount": 10,
    "features": {
      "audio": true,
      "qrCodes": true,
      "maps": true,
      "offline": true
    }
  },
  "passages": [
    {
      "id": "dinosaurs",
      "name": "Hall A: Dinosaurs",
      "text": "# Age of Reptiles\n\n[content...]\n\n[audio](assets/audio/dinosaurs.mp3)",
      "choices": [
        {"text": "Next: Ancient Egypt 🏺", "target": "ancient_egypt"}
      ],
      "metadata": {
        "exhibitId": "hall-a-dinosaurs",
        "floor": 1,
        "qrCode": "MUSEUM-DINO-001",
        "hasAudio": true,
        "audioLength": "2:45",
        "hasInteractive": true,
        "popularity": 5
      }
    }
  ],
  "variables": [
    {"name": "visited_count", "type": "number", "initial": 0},
    {"name": "audio_count", "type": "number", "initial": 0}
  ]
}
```

### Passage Metadata Fields

| Field | Type | Description |
|-------|------|-------------|
| `exhibitId` | string | Unique exhibit identifier |
| `floor` | number | Museum floor number |
| `qrCode` | string | QR code for direct access |
| `hasAudio` | boolean | Audio guide available |
| `audioLength` | string | Duration (e.g., "2:45") |
| `hasInteractive` | boolean | Interactive elements |
| `popularity` | number | 1-5 star rating |
| `photoAllowed` | boolean | Photography permitted |

## CLI Client Architecture

The `museum_client.lua` provides a service-oriented architecture that can be adapted for native mobile apps:

### Core Components

```lua
-- Story Loading
client:load_story(filepath)           -- Load tour from file or URL

-- Navigation
client:goto_passage(id)                -- Navigate to exhibit
client:scan_qr(qr_code)                -- QR code navigation
client:choose(choice_index)            -- Select choice

-- Display
client:render()                        -- Render current exhibit
client:show_map()                      -- Museum floor plan
client:show_stats()                    -- Visitor statistics

-- Analytics
client:export_session()                -- Export session data
client:get_visited_count()             -- Count unique visits
```

### Session Data

The client tracks:
- **Visited exhibits**: Which passages viewed
- **Duration**: Time spent in each exhibit
- **Audio plays**: Count of audio guides played
- **Variables**: Custom story state
- **Progress**: Completion percentage

### Mobile App Integration

The CLI client serves as a reference for native implementations:

**iOS (Swift):**
```swift
class MuseumClient {
    func loadStory(filepath: String) -> Result<Story, Error>
    func gotoPassage(id: String) -> Bool
    func scanQR(code: String) -> Bool
    func render() -> PassageView
    func playAudio(path: String)
    func exportSession() -> SessionData
}
```

**Android (Kotlin):**
```kotlin
class MuseumClient {
    fun loadStory(filepath: String): Result<Story>
    fun gotoPassage(id: String): Boolean
    fun scanQR(code: String): Boolean
    fun render(): PassageView
    fun playAudio(path: String)
    fun exportSession(): SessionData
}
```

## Creating Your Own Museum Tour

### Timeline & Budget

**Time Estimate:**
- Content authoring: 2-3 days
- Asset collection: 1-2 days
- Testing & refinement: 1 day
- Deployment: 2-3 hours
- **Total: ~1 week**

**Budget Estimate:**

**Professional Production:**
- Photography: $500-1,000
- Audio recording: $1,000-2,000
- QR code labels: $50-100
- Icon design: $200-500
- **Total: $1,750-3,600**

**DIY Approach:**
- Smartphone photos: Free
- Text-to-speech audio: Free
- Self-generated QR codes: Free
- **Total: $0-50** (printing only)

### Step 1: Plan Your Tour

```
Tour planning checklist:
☐ List all exhibits (8-12 recommended)
☐ Estimate time per exhibit (2-5 minutes)
☐ Determine navigation style (linear/free-roam)
☐ Collect exhibit information
☐ Record audio guides (or write scripts)
☐ Take photos of exhibits
☐ Generate QR codes
☐ Test route through museum
```

### Step 2: Author in Twine

Use [Twine 2](https://twinery.org) for easy visual authoring:

1. Create new story in Twine
2. One passage = one exhibit
3. Add exhibit text and images
4. Link passages for navigation
5. Export as HTML
6. Convert to Whisker format

### Step 3: Add Museum Metadata

Enhance the converted Whisker story with metadata:

```bash
lua tools/add_museum_metadata.lua \
  --input my_tour.whisker \
  --output my_tour_enhanced.whisker \
  --museum "My Museum Name" \
  --floor-plan floor_plan.json
```

### Step 4: Test with CLI Client

```bash
lua museum_client.lua my_tour_enhanced.whisker
```

### Step 5: Deploy

See detailed deployment options below.

## Asset Management

### Directory Structure

```
natural_history/
├── story.whisker           # Main story file
├── assets/
│   ├── audio/
│   │   ├── dinosaurs.mp3   # Audio guides
│   │   ├── egypt.mp3
│   │   └── ...
│   ├── images/
│   │   ├── trex.jpg        # Exhibit photos
│   │   ├── mummy.jpg
│   │   └── ...
│   └── qr_codes/
│       ├── dino-001.png    # QR code images
│       ├── egypt-001.png
│       └── ...
└── README.md               # Tour documentation
```

### Audio Guidelines

- **Format**: MP3 (AAC preferred)
- **Length**: 2-3 minutes per exhibit
- **Bitrate**: 128 kbps (balance quality/size)
- **Sample rate**: 44.1 kHz
- **Channels**: Mono (saves space)
- **Total size**: < 50 MB for offline support

### Image Guidelines

- **Format**: JPEG (progressive)
- **Size**: 1920x1080 max (HD)
- **Compression**: 85% quality
- **Total size**: < 100 MB for offline support

### QR Code Generation

```bash
# Generate QR codes for all exhibits
lua tools/generate_qr_codes.lua \
  --input natural_history/story.whisker \
  --output natural_history/assets/qr_codes/ \
  --size 512x512
```

## Analytics & Privacy

The system tracks visitor engagement without collecting personal data:

### Tracked Metrics
✅ Exhibits visited
✅ Time spent per exhibit
✅ Audio guides played
✅ Navigation paths
✅ Completion rate
✅ Session duration

### NOT Tracked
❌ Visitor identity
❌ Personal information
❌ Location history
❌ Device fingerprinting
❌ Third-party analytics

### Data Export

Visitors can export their session data:

```json
{
  "story_ifid": "MUSEUM-NH-2024",
  "session_start": 1234567890,
  "duration_seconds": 2700,
  "visited": {
    "dinosaurs": {"visit_count": 2, "first_visit": 1234567900},
    "egypt": {"visit_count": 1, "first_visit": 1234569000}
  },
  "audio_played_count": 8,
  "completion_rate": 80
}
```

## Advanced Features

### Multi-Language Support

Structure for supporting multiple languages:

```json
{
  "metadata": {
    "languages": ["en", "es", "fr", "zh"]
  },
  "passages": [
    {
      "id": "dinosaurs",
      "translations": {
        "en": {
          "name": "Dinosaurs",
          "text": "Welcome to the Age of Reptiles..."
        },
        "es": {
          "name": "Dinosaurios",
          "text": "Bienvenidos a la Era de los Reptiles..."
        }
      }
    }
  ]
}
```

### Conditional Content

Show different content based on visitor choices:

```json
{
  "passages": [
    {
      "id": "advanced_topic",
      "text": "{{if visited_basics}}Advanced information...{{else}}Please visit the basics exhibit first.{{endif}}",
      "choices": [
        {
          "text": "Learn more",
          "target": "detailed_view",
          "condition": "visited_basics == true"
        }
      ]
    }
  ]
}
```

### Progressive Disclosure

Unlock exhibits as visitors progress:

```json
{
  "passages": [
    {
      "id": "secret_room",
      "metadata": {
        "requires": ["hall_a", "hall_b", "hall_c"],
        "locked_message": "Visit all three main halls to unlock!"
      }
    }
  ]
}
```

## Deployment Options

### Option 1: Web App (Recommended)

Deploy as Progressive Web App (PWA) for maximum reach:

**Vercel/Netlify (Easiest):**
```bash
cd examples/web_runtime
vercel deploy
# or
netlify deploy
```

**GitHub Pages:**
```bash
# 1. Enable Pages in repo settings
# 2. Point to: /examples/web_runtime/
# 3. Access at: https://username.github.io/whisker/examples/web_runtime/museum.html
```

**Custom Server:**
```bash
# Copy to web server
sudo cp -r examples/web_runtime /var/www/museum-tour

# Configure nginx/apache (HTTPS required for service worker)
sudo systemctl restart nginx
```

**Browser Support:**
- ✅ iOS Safari 13+
- ✅ Chrome Android 80+
- ✅ Chrome Desktop 80+
- ✅ Safari Desktop 13+
- ✅ Firefox 75+
- ✅ Edge 80+

**Pros:**
- No app store approval
- Instant updates
- Cross-platform
- Easy QR code integration
- Installable on iOS/Android home screens

**Cons:**
- Requires initial internet connection for first load
- Limited camera access on some browsers

### Option 2: Native Mobile Apps

Use the CLI client architecture as reference for native implementations:

**iOS (Swift/SwiftUI):**
```swift
import WhiskerRuntime

class MuseumClient {
    func loadStory(filepath: String) -> Result<Story, Error>
    func gotoPassage(id: String) -> Bool
    func scanQR(code: String) -> Bool
    func playAudio(path: String)
    func exportSession() -> SessionData
}
```

**Android (Kotlin/Jetpack Compose):**
```kotlin
class MuseumClient {
    fun loadStory(filepath: String): Result<Story>
    fun gotoPassage(id: String): Boolean
    fun scanQR(code: String): Boolean
    fun playAudio(path: String)
    fun exportSession(): SessionData
}
```

**Pros:**
- Full native features (camera, audio, offline)
- Better performance
- True offline-first
- App Store/Play Store distribution
- Professional appearance

**Cons:**
- Development time (2-4 weeks)
- App store approval process
- Maintenance overhead
- Update cycle slower

### Option 3: Kiosk Mode

Deploy on tablets at museum entrance or information desks:

```bash
# Launch in fullscreen kiosk mode
lua museum_client.lua \
  --kiosk \
  --fullscreen \
  --story natural_history/story.whisker
```

**Hardware Setup:**
- iPads or Android tablets with stands
- Kiosk mode apps (Guided Access on iOS, Kiosk Browser on Android)
- Power adapters and cable management
- Regular cleaning and maintenance schedule

**Pros:**
- Controlled environment
- No visitor setup needed
- Reliable hardware
- Centralized updates
- No internet dependency concerns

**Cons:**
- Hardware cost ($300-500 per tablet)
- Physical maintenance required
- Not portable for visitors
- Need multiple units for large museums

## Testing

### Manual Testing Checklist

```
Before deployment:
☐ Load story successfully
☐ Navigate to all exhibits
☐ Test all choices/links
☐ Verify audio playback
☐ Check image loading
☐ Scan all QR codes
☐ Test offline mode
☐ Check map display
☐ Verify statistics tracking
☐ Test on mobile devices
☐ Check accessibility
☐ Test with slow connection
```

### Automated Testing

```bash
# Run test suite
cd tests
lua test_museum_client.lua

# Performance test
lua benchmark_museum_client.lua natural_history/story.whisker
```

## Performance Guidelines

### Target Metrics

- **Load time**: < 3 seconds
- **Navigation**: < 500ms between exhibits
- **Memory**: < 100 MB
- **Storage**: < 200 MB total
- **Battery**: < 10% per hour

### Optimization Tips

1. **Compress assets**: Use tools like ImageOptim, ffmpeg
2. **Lazy load**: Don't load all assets upfront
3. **Cache aggressively**: Cache everything offline
4. **Minimize JSON**: Use compact Whisker 2.0 format
5. **Preload adjacent**: Preload next likely exhibits

## Troubleshooting

### Story won't load
- Check JSON is valid: `lua validate_story.lua story.whisker`
- Verify file permissions
- Check file path is correct

### Audio doesn't play
- Verify audio file exists
- Check file format (MP3 recommended)
- Test with different audio file

### QR codes not working
- Verify QR code matches `metadata.qrCode` exactly
- Check QR code is scannable (test with phone camera)
- Ensure proper format: "MUSEUM-EXHIBIT-###"

### Progress not saving
- Check write permissions
- Verify session export works: `client:export_session()`
- Test with different save location

## Contributing

Want to improve museum tours? Here's how:

1. **Create example tours**: Share your museum implementations
2. **Add features**: Audio controls, maps, accessibility
3. **Write docs**: Tutorials, guides, case studies
4. **Report bugs**: File issues on GitHub
5. **Test on devices**: Help us support more platforms

## License

This example is released under the same license as Whisker (see main LICENSE file).

## Resources

- **Whisker Documentation**: `../../docs/`
- **Web Runtime**: `../web_runtime/`
- **Twine Export**: `../../src/format/format_converter.lua`
- **Story Format Spec**: `../../docs/STORY_FORMAT.md`

## Contact

Questions about museum tours?

- **Documentation**: See `MUSEUM_RUNTIME.md` in project root
- **Issues**: File on GitHub
- **Examples**: Check `examples/museum_tours/`

---

Built with ❤️ using Whisker - The Interactive Story Engine
