# Museum Web Runtime

A mobile-optimized Progressive Web App for running Whisker museum tours. Works offline, supports audio guides, QR code scanning, and progress tracking.

## Features

✅ **Offline-First**: Service worker caches stories and assets for offline use
✅ **Mobile-Optimized**: 44px minimum touch targets, optimized for phones and tablets
✅ **Audio Player**: Built-in audio player with seek, rewind, and forward controls
✅ **QR Code Support**: Manual QR code entry (camera integration ready)
✅ **Museum Map**: Interactive map showing all exhibits and progress
✅ **Statistics**: Track visited exhibits, audio plays, and tour duration
✅ **PWA**: Installable as a native-like app on iOS and Android
✅ **Responsive**: Works in portrait, landscape, on phones, tablets, and desktop

## Quick Start

### 1. Start a Local Server

```bash
cd examples/web_runtime
python3 -m http.server 8000
```

### 2. Open in Browser

```
http://localhost:8000/museum.html
```

### 3. Test on Mobile

Find your computer's local IP address:
```bash
# macOS/Linux
ifconfig | grep inet

# Windows
ipconfig
```

Open on your phone:
```
http://YOUR_IP:8000/museum.html
```

## What's Included

### Files Created

```
examples/web_runtime/
├── museum.html              # Main HTML entry point
├── museum.css               # Mobile-first responsive styles (44px touch targets)
├── museum-client.js         # Museum tour client (story loading, navigation, audio)
├── sw.js                    # Service worker (offline support)
├── manifest.json            # PWA manifest (installable app)
└── MUSEUM_README.md         # This file
```

### Architecture

**HTML (museum.html)**
- Semantic, accessible markup
- Header with progress bar
- Main passage content area
- Fixed bottom navigation
- Audio player component
- Modals (map, QR, stats, help, menu)

**CSS (museum.css)**
- Mobile-first responsive design
- 44px minimum touch targets (Apple HIG)
- CSS variables for theming
- Smooth animations
- Dark mode support (coming soon)
- Print styles

**JavaScript (museum-client.js)**
- Story loading and parsing
- Passage navigation
- Progress tracking
- Audio playback
- QR code support
- Statistics dashboard
- Session export

**Service Worker (sw.js)**
- Cache-first for app shell (HTML, CSS, JS)
- Network-first for stories (always get latest)
- Cache-first for images
- Network-only for audio (too large)
- Offline fallbacks

## Using with Museum Tours

### Load a Story

The default configuration loads the Natural History Museum example:

```javascript
const storyPath = '../museum_tours/natural_history/story.whisker';

fetch(storyPath)
    .then(response => response.json())
    .then(story => {
        museumClient.loadStory(story);
        museumClient.start();
    });
```

### Custom Story

To load a different story, modify `museum.html`:

```javascript
const storyPath = 'path/to/your/story.whisker';
```

Or use URL parameters:

```javascript
const urlParams = new URLSearchParams(window.location.search);
const storyPath = urlParams.get('story') || '../museum_tours/natural_history/story.whisker';
```

Then access: `museum.html?story=path/to/story.whisker`

## Features in Detail

### Audio Player

The built-in audio player supports:
- ✅ Play/Pause
- ✅ Seek bar with time display
- ✅ Rewind 15 seconds
- ✅ Forward 15 seconds
- ✅ Current time / Total duration
- ✅ Smooth animations
- ⏳ Speed control (coming soon)
- ⏳ Lock screen controls (future)

**Usage in stories:**

```markdown
Listen to the audio guide for this exhibit.

[audio](assets/audio/dinosaurs.mp3)
```

### QR Code Scanning

Currently supports manual QR code entry. Camera scanning can be added with html5-qrcode library.

**To add camera scanning:**

1. Include html5-qrcode:
```html
<script src="https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js"></script>
```

2. Initialize scanner in museum-client.js:
```javascript
const html5QrCode = new Html5Qrcode("qr-reader");
html5QrCode.start(
    { facingMode: "environment" },
    { fps: 10, qrbox: 250 },
    (decodedText) => {
        this.scanQR(decodedText);
    }
);
```

### Museum Map

Interactive map showing:
- All exhibits with floor numbers
- Visited status (✓ or ◯)
- Audio availability
- QR codes
- Tap to navigate

### Statistics Dashboard

Tracks:
- Exhibits visited
- Completion percentage
- Tour duration
- Audio guides played
- Most revisited exhibit

**Export data:**

Visitors can export their session data as JSON:
- Menu → Export Visit Data
- Downloads `museum-visit-[timestamp].json`
- Privacy-first (no personal data)

### Progressive Web App

The tour can be installed as a native-like app:

**iOS (Safari):**
1. Tap Share button
2. Scroll down to "Add to Home Screen"
3. Confirm

**Android (Chrome):**
1. Tap Menu (⋮)
2. Select "Install app" or "Add to Home Screen"
3. Confirm

**Desktop (Chrome):**
1. Click install icon in address bar
2. Or Menu → Install Museum Tour
3. Confirm

### Offline Support

After first load, the app works completely offline:

**What's cached:**
- ✅ HTML, CSS, JavaScript (app shell)
- ✅ Stories (.whisker files)
- ✅ Images
- ⏳ Audio (on-demand only, too large for aggressive caching)

**To preload assets:**

```javascript
// In museum-client.js
if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
    const urls = [
        'assets/audio/dinosaurs.mp3',
        'assets/audio/egypt.mp3',
        // ... more assets
    ];

    navigator.serviceWorker.controller.postMessage({
        type: 'CACHE_URLS',
        urls: urls
    });
}
```

## Mobile Optimization

### Touch Targets

All interactive elements meet or exceed 44px minimum (Apple HIG):
- ✅ Choice buttons: 56px height
- ✅ Navigation buttons: 56px height
- ✅ Header buttons: 44px
- ✅ Audio controls: 44-56px
- ✅ Modal close buttons: 44px

### Responsive Layout

**Phone (Portrait):**
- Single column layout
- Fixed bottom navigation
- Full-width content
- Optimized text size (18px)

**Phone (Landscape):**
- Compact header
- Smaller navigation
- Maintains usability

**Tablet:**
- Wider content (max 800px)
- Larger text
- More breathing room

**Desktop:**
- Centered content
- Navigation at top
- Max width 1200px

### Performance

**Target Metrics:**
- First Paint: < 1s
- Interactive: < 2s
- Smooth scrolling: 60fps
- Memory: < 100MB

**Optimizations:**
- Lazy image loading
- Minimal JavaScript
- CSS animations (GPU-accelerated)
- Service worker caching

## Browser Support

**Fully Supported:**
- ✅ iOS Safari 13+
- ✅ Chrome Android 80+
- ✅ Chrome Desktop 80+
- ✅ Safari Desktop 13+
- ✅ Firefox 75+
- ✅ Edge 80+

**Service Worker Support:**
- ✅ All major browsers
- ⚠️ iOS requires HTTPS or localhost

**PWA Install:**
- ✅ Android Chrome (full support)
- ⚠️ iOS Safari (limited, no push notifications)
- ✅ Desktop Chrome, Edge

## Development

### Testing

**Desktop:**
```bash
python3 -m http.server 8000
open http://localhost:8000/museum.html
```

**Mobile (via USB debugging):**

**iOS:**
1. Enable Web Inspector in Safari settings
2. Connect device via USB
3. Safari → Develop → [Device] → museum.html

**Android:**
1. Enable USB debugging
2. Chrome → chrome://inspect
3. Select device and page

**Mobile (via network):**
```bash
# Find IP: ifconfig (macOS/Linux) or ipconfig (Windows)
# Open on phone: http://YOUR_IP:8000/museum.html
```

### Debugging

**Service Worker:**
- Chrome: DevTools → Application → Service Workers
- Clear cache: Application → Clear Storage

**Console:**
```javascript
// Access client
museumClient.showStats()
museumClient.exportSession()

// Check story
console.log(museumClient.story)
console.log(museumClient.visited)
console.log(museumClient.variables)
```

### Customization

**Colors (CSS variables):**
```css
:root {
    --primary-color: #667eea;
    --primary-dark: #5568d3;
    --secondary-color: #764ba2;
}
```

**Layout:**
- Edit `museum.css` breakpoints
- Modify touch target sizes
- Adjust spacing

**Features:**
- Add custom modals in `museum.html`
- Extend `MuseumClient` class in `museum-client.js`
- Add routes to service worker cache

## Deployment

### Option 1: Static Hosting (Vercel/Netlify)

```bash
# Deploy entire project
cd whisker/
vercel deploy

# Or just examples/web_runtime
cd examples/web_runtime
netlify deploy
```

**Configuration:**
- Set build command: (none needed, static files)
- Set publish directory: `examples/web_runtime`
- Enable HTTPS (required for service worker on iOS)

### Option 2: GitHub Pages

```bash
# Enable GitHub Pages in repo settings
# Set source to main branch, /examples/web_runtime folder
# Access at: https://username.github.io/whisker/examples/web_runtime/museum.html
```

### Option 3: Custom Server

```bash
# Node.js with Express
npm install express
node server.js

# Nginx
sudo cp -r examples/web_runtime /var/www/museum-tour
# Configure nginx site
```

**Requirements:**
- HTTPS required for service worker (except localhost)
- Correct MIME types (.whisker → application/json)
- Enable CORS if loading stories from different domain

## Next Steps

### Week 2 Enhancements

Based on `MUSEUM_RUNTIME.md`:

**QR Camera Scanning:**
- Install html5-qrcode library
- Add camera permissions
- Handle scan success/failure

**Multi-Language:**
- Add language selector
- Support translated passages
- Store preference in localStorage

**Performance:**
- Lazy load images
- Compress assets
- Minimize bundle size

**Analytics:**
- Track navigation patterns
- Measure engagement
- Export aggregate stats (privacy-first)

### Future Features

- 🎨 Theming (dark mode, high contrast)
- 🌐 Multi-language support
- 📍 GPS location awareness (outdoor museums)
- 🗣️ Text-to-speech fallback
- 📊 Museum dashboard (aggregate analytics)
- 🔔 Push notifications (tour reminders)
- 📥 Offline story downloads
- 🎮 Gamification (badges, achievements)

## Troubleshooting

**Service worker not registering:**
- Check HTTPS or localhost
- Clear browser cache
- Check console for errors

**Story not loading:**
- Verify path is correct
- Check JSON is valid
- Look for CORS errors

**Audio not playing:**
- Check file path
- Verify MP3 format
- Test file accessibility

**Offline mode not working:**
- Service worker must be registered first
- Visit page online once
- Check cache in DevTools

**Buttons not tappable:**
- Verify min-height 44px
- Check for overlapping elements
- Test with pointer-events

## Resources

- **Whisker Docs**: `../../docs/`
- **Museum Tours**: `../museum_tours/`
- **CLI Client**: `../museum_tours/museum_client.lua`
- **Story Format**: `../../docs/STORY_FORMAT.md`

## License

Same as Whisker project (see main LICENSE file)

---

Built with ❤️ using Whisker - The Interactive Story Engine
