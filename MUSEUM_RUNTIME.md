# Museum Runtime Development Plan

## Project Overview

**Goal**: Create a production-ready browser-based runtime for self-guided museum tours
**Timeline**: 12 weeks (3 months)
**Status**: Development branch created - `feature/museum-runtime`

---

## Core Features

### Phase 1: Enhanced Web Runtime (Weeks 1-4)
- ✅ Core story engine (already exists)
- ⏳ Offline-first architecture (service worker)
- ⏳ Rich media support (audio, video, images)
- ⏳ Mobile-optimized UI
- ⏳ QR code integration
- ⏳ Multi-language support

### Phase 2: Museum Features (Weeks 5-8)
- ⏳ Location awareness (optional GPS)
- ⏳ Map integration
- ⏳ Progressive disclosure
- ⏳ Analytics (privacy-first)
- ⏳ Tour management
- ⏳ Accessibility features

### Phase 3: PWA & Polish (Weeks 9-12)
- ⏳ Progressive Web App
- ⏳ Install prompts
- ⏳ Performance optimization
- ⏳ Museum pilot
- ⏳ Documentation

---

## Week 1 Plan (Current Week)

### Day 1: Assessment ✅ DONE
- [x] PR #13 merged (compact format)
- [x] Main branch updated
- [x] Feature branch created
- [x] Development plan documented

### Day 2: Mobile Testing
**Tasks:**
- [ ] Test current web runtime on iOS (Safari)
- [ ] Test current web runtime on Android (Chrome)
- [ ] Test on tablet (iPad)
- [ ] Document issues and limitations
- [ ] Create mobile testing checklist

**Testing Checklist:**
```
Device Testing:
☐ iPhone Safari - works?
☐ iPad Safari - works?
☐ Android Chrome - works?
☐ Touch interactions - smooth?
☐ Text readable - size OK?
☐ Buttons tappable - targets big enough?
☐ Offline - fails gracefully?
☐ Images load - performance OK?
☐ Audio playback - works?
☐ Portrait mode - layout OK?
☐ Landscape mode - layout OK?
```

### Day 3: Service Worker Implementation
**Goal**: Enable offline functionality

**Files to Create:**
- `examples/web_runtime/sw.js` - Service worker
- `examples/web_runtime/manifest.json` - PWA manifest
- Update `examples/web_runtime/index.html` - Register SW

**Service Worker Features:**
```javascript
// Cache Strategy:
1. App Shell (HTML, CSS, JS) - cache first
2. Story files (.whisker, .json) - network first, cache fallback
3. Images - cache first, network fallback
4. Audio/Video - network only (too large)

// Cache Management:
- Version-based cache invalidation
- Limit cache size (50MB)
- Clear old caches on update
```

### Day 4: Audio Player Component
**Goal**: Rich audio guide support

**Files to Create:**
- `examples/web_runtime/components/audio-player.html` - Audio UI
- `examples/web_runtime/audio-player.css` - Styling
- `examples/web_runtime/audio-player.js` - Controls

**Features:**
```
Player Controls:
☐ Play/Pause button
☐ Seek bar with time display
☐ Volume control
☐ 15s back/forward buttons
☐ Speed control (0.75x, 1x, 1.25x, 1.5x)
☐ Background audio (continues when app backgrounded)
☐ Lock screen controls (iOS/Android)
☐ Autoplay next exhibit (optional)
```

### Day 5: Mobile Layout Improvements
**Goal**: Touch-optimized interface

**Changes to `web_runtime.css`:**
```css
/* Larger touch targets */
.choice-button {
  min-height: 44px;  /* Apple HIG minimum */
  padding: 16px 24px;
  margin: 8px 0;
  font-size: 18px;
}

/* Better spacing */
.passage-text {
  font-size: 18px;
  line-height: 1.6;
  padding: 20px;
}

/* Responsive images */
img {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
}

/* Touch-friendly navigation */
.history-nav {
  position: fixed;
  bottom: 0;
  width: 100%;
  padding: 16px;
  background: var(--bg);
}
```

---

## Week 2 Plan

### QR Code Integration
**Goal**: Scan QR to load tours

**Library**: Use `html5-qrcode` (MIT license)

**Features:**
- Scan QR code to load tour URL
- Scan QR code at exhibits (jump to passage)
- Generate QR codes (admin tool)
- Fallback: manual entry

### Multi-Language Support
**Goal**: Tours in multiple languages

**Approach:**
```javascript
Story Structure:
{
  "defaultLanguage": "en",
  "languages": {
    "en": { "title": "Museum Tour", ... },
    "es": { "title": "Tour del Museo", ... },
    "fr": { "title": "Visite du Musée", ... }
  },
  "passages": {
    "start": {
      "en": { "text": "Welcome...", "choices": [...] },
      "es": { "text": "Bienvenido...", "choices": [...] },
      "fr": { "text": "Bienvenue...", "choices": [...] }
    }
  }
}
```

**UI:**
- Language selector in menu
- Persist selection
- Reload content on change

### Optimize Performance
**Goals:**
- Fast initial load
- Smooth animations
- Efficient memory usage

**Optimizations:**
- Lazy load images
- Compress assets
- Minimize JavaScript
- Use CSS animations (GPU-accelerated)
- Debounce touch events

---

## Week 3 Plan

### Map Integration (Optional)
**Goal**: Visual floor plan

**Approach 1: Simple SVG**
```html
<!-- Floor plan as SVG -->
<svg viewBox="0 0 1000 800">
  <!-- Museum floor plan paths -->
  <circle cx="100" cy="100" r="20" class="exhibit" data-id="exhibit1"/>
  <circle cx="300" cy="200" r="20" class="exhibit" data-id="exhibit2"/>
  <!-- Current location marker -->
  <circle cx="100" cy="100" r="10" class="you-are-here"/>
</svg>
```

**Approach 2: Interactive with Leaflet.js**
- If museum has proper floor plans
- More complex but better UX

### Location Features (Optional GPS)
**Goal**: Location-aware content

**Simple Approach (No GPS):**
```javascript
// Museum staff pre-configures locations
const exhibits = {
  "exhibit1": { passage: "start", qrCode: "..." },
  "exhibit2": { passage: "ancient_egypt", qrCode: "..." },
  // Manual navigation or QR scan
};
```

**Advanced Approach (GPS):**
```javascript
// For outdoor museums or large campuses
navigator.geolocation.watchPosition(position => {
  const { latitude, longitude } = position.coords;

  // Find nearest exhibit
  const nearest = findNearestExhibit(latitude, longitude);

  // Trigger content if within 10 meters
  if (nearest.distance < 10) {
    showExhibit(nearest.id);
  }
});
```

### Analytics (Privacy-First)
**Goal**: Track usage without personal data

**Local Storage Only:**
```javascript
const analytics = {
  tourStarted: Date.now(),
  passagesVisited: [],
  timeSpent: {},
  completionRate: 0,
  // NO: user identity, location history, personal data
};

// Export on tour completion
function exportVisitLog() {
  return JSON.stringify(analytics);
  // User can share or delete
}
```

---

## Week 4 Plan

### Museum Demo Story
**Goal**: Complete museum tour example

**Structure:**
```
Museum Tour: "Natural History Museum"
- 10 exhibits
- Audio guide for each (2-3 minutes)
- Images/diagrams
- Interactive choices
- Multiple languages (EN, ES, FR)
- QR codes for each exhibit
- Estimated time: 45 minutes
```

**Passages:**
1. **Welcome** - Introduction, map overview
2. **Dinosaurs** - T-Rex, fossils
3. **Ancient Egypt** - Mummies, hieroglyphics
4. **Ocean Life** - Whale skeletons, deep sea
5. **Gems & Minerals** - Crystals, geology
6. **Mammals** - Taxidermy, habitats
7. **Birds** - Flight, migration
8. **Human Origins** - Evolution, anthropology
9. **Butterflies** - Live exhibit, metamorphosis
10. **Conclusion** - Summary, gift shop

**Assets Needed:**
- 10 audio files (MP3, 2-3 min each)
- 20-30 images (JPG, compressed)
- QR codes for each exhibit
- Floor plan SVG

### Testing & Refinement
**Tasks:**
- [ ] Load test with 100+ images
- [ ] Test offline scenarios
- [ ] Test on slow connections (3G)
- [ ] Test battery usage
- [ ] Test memory leaks
- [ ] Accessibility audit
- [ ] Get feedback from 5 users

---

## Weeks 5-8: Museum-Specific Features

### Progressive Disclosure
**Concept**: Unlock content as you progress

```javascript
// Example: Can't access ancient Egypt until you visit Dinosaurs
passages: {
  "ancient_egypt": {
    "requires": ["dinosaurs_visited"],
    "locked_message": "Visit the Dinosaurs exhibit first!"
  }
}
```

### Tour Routes
**Multiple paths through museum:**

```javascript
routes: {
  "highlights": {
    name: "Highlights Tour",
    duration: "30 min",
    passages: ["welcome", "dinosaurs", "ocean_life", "gems"]
  },
  "full": {
    name: "Complete Tour",
    duration: "90 min",
    passages: ["all"]
  },
  "kids": {
    name: "Family Tour",
    duration: "45 min",
    passages: ["welcome", "dinosaurs", "butterflies", "conclusion"]
  }
}
```

### Accessibility Features
**WCAG 2.1 AA Compliance:**

- Screen reader support (ARIA labels)
- High contrast mode
- Large text mode
- Keyboard navigation
- Closed captions for audio
- Audio descriptions for images
- Reduce motion option

---

## Weeks 9-12: PWA & Launch

### Progressive Web App Setup
**Files:**
- `manifest.json` - App metadata
- `sw.js` - Service worker (already created)
- Icons (192x192, 512x512)
- Splash screens

**Features:**
- Install prompt
- Offline functionality
- Push notifications (optional)
- Share target (receive tours)

### Museum Pilot
**Partner Museum:**
- 1 museum for pilot test
- 2-week installation
- 50+ visitors
- Gather feedback

**Success Metrics:**
```
☐ 90% uptime
☐ 80% completion rate
☐ < 3 second load time
☐ Works offline
☐ 4+ star rating
☐ No critical bugs
```

### Documentation
**Create:**
- [ ] Museum setup guide
- [ ] Story authoring guide (Twine → Whisker)
- [ ] QR code generation guide
- [ ] Troubleshooting guide
- [ ] Video walkthrough

### Launch Checklist
```
Technical:
☐ All tests passing
☐ Performance optimized
☐ Accessibility audited
☐ Browser compatibility verified
☐ Offline mode tested
☐ Analytics working
☐ Backup system in place

Content:
☐ Demo museum tour complete
☐ Documentation written
☐ Video tutorial recorded
☐ Museum onboarding process defined

Deployment:
☐ Hosting configured (Vercel/Netlify)
☐ Domain configured
☐ SSL enabled
☐ CDN configured
☐ Monitoring set up
☐ Support email set up
```

---

## Technical Architecture

### File Structure
```
whisker/
├── examples/
│   └── web_runtime/
│       ├── index.html              (main entry)
│       ├── manifest.json           (PWA config) ⏳ NEW
│       ├── sw.js                   (service worker) ⏳ NEW
│       ├── components/
│       │   ├── audio-player.html   ⏳ NEW
│       │   ├── qr-scanner.html     ⏳ NEW
│       │   └── map-viewer.html     ⏳ NEW
│       ├── styles/
│       │   ├── web_runtime.css     (existing, enhance)
│       │   ├── mobile.css          ⏳ NEW
│       │   └── print.css           ⏳ NEW
│       └── scripts/
│           ├── museum-runtime.js   ⏳ NEW
│           ├── audio-player.js     ⏳ NEW
│           └── qr-scanner.js       ⏳ NEW
├── examples/
│   └── museum_tours/               ⏳ NEW
│       ├── natural_history/
│       │   ├── story.whisker
│       │   ├── assets/
│       │   │   ├── audio/
│       │   │   ├── images/
│       │   │   └── qr_codes/
│       │   └── README.md
│       └── art_gallery/
│           └── ...
└── docs/
    └── MUSEUM_RUNTIME.md           (this file)
```

### Technology Stack
```
Core:
- Existing Whisker engine (Lua + Fengari)
- Existing web_runtime.lua

Enhancements:
- Service Worker API (offline)
- Web Audio API (audio guides)
- MediaDevices API (QR scanner)
- Geolocation API (optional GPS)
- Cache API (asset storage)
- IndexedDB (story + progress)
- Web Share API (export logs)

Libraries (Minimal):
- html5-qrcode (QR scanning) ~50KB
- Optional: Leaflet.js (maps) ~150KB
```

### Performance Budget
```
Initial Load:
- HTML: < 20KB
- CSS: < 50KB
- JS: < 200KB
- Total: < 300KB (gzipped)

Runtime:
- Memory: < 100MB
- First Paint: < 1s
- Interactive: < 2s
- Smooth: 60fps
```

---

## Development Workflow

### Daily Workflow
```bash
# 1. Start work
git checkout feature/museum-runtime
git pull origin feature/museum-runtime

# 2. Make changes
# ... edit files ...

# 3. Test locally
cd examples/web_runtime
python3 -m http.server 8000
# Test on http://localhost:8000

# 4. Test on mobile
# Connect to http://YOUR_IP:8000 from phone

# 5. Commit changes
git add .
git commit -m "feat: add audio player component"
git push origin feature/museum-runtime

# 6. Update todo list
# Mark tasks complete as you go
```

### Testing Protocol
```bash
# Unit tests (if any)
lua tests/test_museum_runtime.lua

# Integration tests
# Manual testing on:
- iPhone Safari (iOS 16+)
- iPad Safari (iPadOS 16+)
- Android Chrome (Android 10+)
- Desktop Chrome (latest)
- Desktop Safari (latest)

# Performance testing
# Lighthouse audit (target: 90+ score)
# Network throttling (3G)
# CPU throttling (4x slowdown)
```

### Code Review Checklist
```
Before PR:
☐ All tests passing
☐ Code formatted (prettier/eslint)
☐ No console.log() statements
☐ Comments explain "why" not "what"
☐ Mobile tested
☐ Offline tested
☐ Performance acceptable
☐ Accessibility checked
☐ Documentation updated
```

---

## FAQ

**Q: Why browser-first, not native app?**
A: Faster development, cross-platform, no App Store approval, easier updates, lower barrier to entry.

**Q: What about iOS PWA limitations?**
A: Yes, iOS PWAs have limits (storage, notifications). But basic functionality works fine for museum tours.

**Q: Do we need GPS?**
A: No! QR codes are simpler and work better indoors. GPS is optional for outdoor museums.

**Q: How do museums create tours?**
A: Author in Twine 2 (free, mature editor) → Export HTML → Import to Whisker → Deploy. No coding needed.

**Q: What about large asset files?**
A: Service worker caches assets. Large files (video) can stream. Recommend keeping tours < 100MB total.

**Q: How much does it cost to host?**
A: Free tier on Vercel/Netlify handles 100,000+ visitors/month. Paid plans start at $20/month.

**Q: Can we monetize this?**
A: Yes - license to museums ($500-2000 per museum), white-label service, or premium features.

---

## Next Steps

**This Week (Week 1):**
1. ☐ Test web runtime on mobile (Day 2)
2. ☐ Add service worker (Day 3)
3. ☐ Create audio player (Day 4)
4. ☐ Optimize mobile layout (Day 5)

**This Month:**
- Complete Phase 1 (Enhanced Web Runtime)
- Create demo museum tour
- Test with real users

**This Quarter:**
- Complete all 3 phases
- Museum pilot launch
- Documentation & support

**Want to get started?** The next task is testing the current web runtime on mobile devices. See Day 2 tasks above.
