# Testing Guide - Natural History Museum Tour

Complete testing checklist for the museum tour system.

## Quick Start Testing

### Desktop Testing (5 minutes)

```bash
cd examples/web_runtime
python3 -m http.server 8000
open http://localhost:8000/museum.html
```

**Test:**
- ✅ Story loads (Natural History Museum)
- ✅ Can navigate between passages
- ✅ Choices are clickable
- ✅ Progress bar updates
- ✅ Map shows all exhibits
- ✅ Stats dashboard works
- ✅ QR code manual entry works

### Mobile Testing (15 minutes)

**Setup:**
```bash
# Find your IP
ifconfig | grep "inet " | grep -v 127.0.0.1

# Example output: inet 192.168.1.100
# Open on phone: http://192.168.1.100:8000/museum.html
```

**Test:**
- ✅ Page loads on mobile
- ✅ Touch targets are large enough (56px choices)
- ✅ Bottom navigation is accessible
- ✅ Modals open/close properly
- ✅ Text is readable (no pinch-zoom needed)
- ✅ Portrait and landscape work
- ✅ No horizontal scrolling

## Comprehensive Testing

### 1. CLI Client Testing

Test the reference implementation:

```bash
cd examples/museum_tours
lua museum_client.lua natural_history/story.whisker
```

**Test all features:**
```
Commands to test:
  [1-9]  - Navigate via choices (test all exhibits)
  [m]    - View map (check all 10 exhibits listed)
  [q]    - QR scan (try: MUSEUM-DINO-001)
  [s]    - Stats (verify tracking works)
  [h]    - Help (readable?)
  [x]    - Exit (stats shown?)

Expected behavior:
✅ All 13 passages accessible
✅ Variables update (visited_count)
✅ QR codes work (find passage by code)
✅ Map shows visited status
✅ Stats show visit count, duration
✅ Smooth navigation
```

**Known Placeholders:**
- ⚠️ Audio: References exist but files are placeholders
- ⚠️ Images: References exist but files are placeholders
- ✅ Text content: Complete
- ✅ Navigation: Fully working

### 2. Web Runtime Testing

#### Browser Compatibility

**Desktop Browsers:**
```
Chrome 80+:
  ✅ Story loads
  ✅ Service worker registers
  ✅ Responsive layout
  ✅ All features work

Safari 13+:
  ✅ Story loads
  ✅ Service worker registers
  ✅ All features work
  ⚠️ Check audio player compatibility

Firefox 75+:
  ✅ Story loads
  ✅ Service worker registers
  ✅ All features work

Edge 80+:
  ✅ Story loads
  ✅ Service worker registers
  ✅ All features work
```

**Mobile Browsers:**
```
iOS Safari 13+:
  ✅ Story loads
  ✅ Touch targets adequate
  ✅ Service worker works (HTTPS or localhost only)
  ✅ Can add to home screen
  ⚠️ Check safe area insets (notch)

Chrome Android 80+:
  ✅ Story loads
  ✅ Touch targets adequate
  ✅ Service worker works
  ✅ Install prompt shows
  ✅ Full PWA support
```

#### Core Features

**Story Loading:**
```javascript
// Should load without errors
fetch('../museum_tours/natural_history/story.whisker')
  .then(response => response.json())
  .then(story => {
    ✅ Loads successfully
    ✅ Has 13 passages
    ✅ Has metadata (title, museum, etc.)
    ✅ Has variables
  })
```

**Navigation:**
```
Test sequence:
1. Load story (should show "Welcome" passage)
2. Click "View Museum Map" (should show info passage)
3. Click "Start with Dinosaurs" (should navigate)
4. Use back button (should go to previous)
5. Try QR code "MUSEUM-EGYPT-001" (should jump to Egypt)
6. Complete tour (should reach conclusion)

Expected:
✅ All navigation works
✅ Progress bar updates
✅ Visited count increases
✅ No broken links
```

**Audio Player:**
```
Test with audio placeholder:
1. Click audio link in passage
2. Audio player should appear at bottom
3. Controls:
   ✅ Play button (▶️ → ⏸️)
   ✅ Seek bar (draggable)
   ✅ Rewind 15s (⏪)
   ✅ Forward 15s (⏩)
   ✅ Close button (✕)
   ⚠️ Actual playback requires MP3 files
```

**Museum Map:**
```
Open map modal:
✅ Shows all 10 exhibits
✅ Sorted by floor (1, 1, 1, 2, 2, 2, 3, 3)
✅ Visited indicators (✓/◯)
✅ Audio badges (🎧 where applicable)
✅ QR codes displayed
✅ Click navigates to exhibit
✅ Map closes properly
```

**QR Code Scanning:**
```
Test manual entry:
1. Click QR button
2. Enter: MUSEUM-DINO-001
3. Click "Go to Exhibit"

Expected:
✅ Navigates to Dinosaurs exhibit
✅ Modal closes
✅ Progress updates

Try all QR codes:
- MUSEUM-ENTRANCE (welcome)
- MUSEUM-DINO-001 (dinosaurs)
- MUSEUM-EGYPT-001 (ancient_egypt)
- MUSEUM-OCEAN-001 (ocean_life)
- MUSEUM-GEMS-001 (gems_minerals)
- MUSEUM-MAMMALS-001 (mammals)
- MUSEUM-BIRDS-001 (birds)
- MUSEUM-HUMAN-001 (human_origins)
- MUSEUM-BUTTERFLY-001 (butterflies)
```

**Statistics Dashboard:**
```
After visiting 5 exhibits:
✅ Shows "5" exhibits visited
✅ Shows percentage (e.g., "38%")
✅ Shows tour duration in minutes
✅ Shows audio played count (0 without files)
✅ Shows most revisited exhibit (if any)
```

**Session Export:**
```
Menu → Export Visit Data:
✅ Downloads JSON file
✅ Contains timestamp
✅ Contains visited exhibits
✅ Contains duration
✅ Contains variables
✅ No personal data (privacy-first)
```

#### Offline Testing

**Service Worker:**
```bash
# 1. Open DevTools → Application → Service Workers
# Should show: "Status: activated and is running"

# 2. Check cache:
# Application → Cache Storage → whisker-museum-v1
# Should contain:
#   - museum.html
#   - museum.css
#   - museum-client.js
#   - manifest.json
```

**Offline Functionality:**
```
Test sequence:
1. Load museum.html (while online)
2. Navigate to 2-3 exhibits
3. Open DevTools → Network tab
4. Check "Offline" checkbox
5. Refresh page

Expected:
✅ Page loads from cache
✅ Story still accessible
✅ Navigation still works
✅ Previously visited exhibits work
✅ New exhibits may fail (not cached yet)
```

**Full Offline Test:**
```
1. Visit tour while online
2. Navigate through all exhibits once
3. Turn off WiFi / airplane mode
4. Refresh page

Expected:
✅ Everything works
✅ All passages accessible
✅ Images load (if cached)
✅ Audio references show (files may not play)
```

#### PWA Installation

**iOS:**
```
1. Open museum.html in Safari
2. Tap Share button (square with arrow)
3. Scroll down to "Add to Home Screen"
4. Tap "Add"
5. Return to home screen

Expected:
⚠️ Icon shows (placeholder if not generated)
✅ App name: "Museum Tour"
✅ Tap opens in standalone mode
✅ No browser chrome
✅ Full-screen experience
```

**Android:**
```
1. Open museum.html in Chrome
2. Install prompt should appear (or Menu → Install app)
3. Tap "Install"
4. Confirm

Expected:
⚠️ Icon shows (placeholder if not generated)
✅ App name: "Museum Tour"
✅ App appears in launcher
✅ Opens in standalone mode
✅ Notification with URL
```

### 3. Mobile Optimization Testing

**Touch Targets:**
```
Measure with DevTools (Desktop):
1. Right-click element → Inspect
2. Check computed height

Required minimums:
✅ Choice buttons: 56px (exceeds 44px minimum)
✅ Nav buttons: 56px
✅ Header buttons: 44px
✅ Audio controls: 44-56px
✅ Modal close: 44px
```

**Text Readability:**
```
On phone (no zoom needed):
✅ Passage title: 1.75rem (28px) - readable
✅ Passage text: 1.125rem (18px) - readable
✅ Choice buttons: 1.0625rem (17px) - readable
✅ Metadata: 0.875rem (14px) - readable
✅ No text smaller than 14px
```

**Layout Responsiveness:**
```
Test breakpoints:
320px (small phone):
  ✅ No horizontal scroll
  ✅ Content fits
  ✅ Buttons stack vertically

375px (iPhone SE):
  ✅ Comfortable layout
  ✅ All interactive

414px (iPhone Plus):
  ✅ Spacious
  ✅ All features accessible

768px (tablet portrait):
  ✅ Max-width constraint (800px)
  ✅ Centered content

1024px (tablet landscape / desktop):
  ✅ Navigation may move to top
  ✅ Wider layout
  ✅ Max-width 1200px
```

**Landscape Mode:**
```
Phone in landscape:
✅ Header compact (smaller)
✅ Content scrollable
✅ Bottom nav accessible
✅ No critical UI hidden
```

### 4. Performance Testing

**Load Time:**
```
DevTools → Network tab → Reload:

First load (no cache):
  ✅ HTML: < 100ms
  ✅ CSS: < 200ms
  ✅ JS: < 300ms
  ✅ Story JSON: < 200ms
  ✅ Total: < 1s

Subsequent loads (cached):
  ✅ Everything: < 200ms
  ✅ Instant feel
```

**Runtime Performance:**
```
DevTools → Performance tab → Record:

Navigation between passages:
  ✅ < 100ms response
  ✅ Smooth animation
  ✅ No jank

Scroll performance:
  ✅ 60 FPS
  ✅ No lag
  ✅ Smooth on long content
```

**Memory Usage:**
```
DevTools → Memory tab:

After loading:
  ✅ < 50 MB initial

After visiting all passages:
  ✅ < 100 MB total
  ✅ No memory leaks
  ✅ GC works properly
```

### 5. Accessibility Testing

**Keyboard Navigation:**
```
Test with Tab key:
✅ Can focus all interactive elements
✅ Focus visible (outline)
✅ Logical tab order
✅ Enter activates buttons
✅ Escape closes modals
```

**Screen Reader:**
```
Test with VoiceOver (iOS/Mac) or TalkBack (Android):
✅ All text readable
✅ Buttons announced with purpose
✅ Heading hierarchy correct
✅ Links make sense
✅ ARIA labels where needed
```

**High Contrast:**
```
System settings → High Contrast:
✅ Text visible
✅ Buttons have borders
✅ Focus indicators strong
✅ No color-only information
```

**Reduced Motion:**
```
System settings → Reduce Motion:
✅ Animations disabled/minimized
✅ Transitions instant
✅ No motion sickness triggers
```

## Known Issues / Placeholders

### Assets (Expected)
- ⚠️ **Audio files**: References exist but .mp3 files are placeholders
- ⚠️ **Images**: References exist but .jpg files are placeholders
- ⚠️ **QR code images**: Can be generated from codes
- ⚠️ **PWA icons**: Placeholder SVG provided, needs PNG generation

### Camera QR Scanning (Future)
- ⚠️ Manual entry works
- ⚠️ Camera scanning requires html5-qrcode library (Week 2)

### Audio Playback (Asset-Dependent)
- ⚠️ UI works perfectly
- ⚠️ Playback requires actual MP3 files in assets/audio/

### Language Switching (Future)
- ⚠️ Structure ready
- ⚠️ UI for language selector (Week 2)
- ⚠️ Translations needed per museum

## Bug Reporting

If you find issues, document:
1. **Device/Browser**: iOS Safari 15, etc.
2. **Steps to reproduce**: Specific actions
3. **Expected behavior**: What should happen
4. **Actual behavior**: What happened
5. **Screenshots/Errors**: Console errors, screenshots

## Success Criteria

### Minimum Viable Product ✅
- [x] Story loads on desktop
- [x] Story loads on mobile
- [x] Navigation works
- [x] Touch targets adequate (44px+)
- [x] Offline support (service worker)
- [x] PWA installable
- [x] All core features functional

### Production Ready (After Assets) ⏳
- [ ] Audio files integrated
- [ ] Images integrated
- [ ] QR codes generated and printed
- [ ] PWA icons generated
- [ ] Tested on real devices
- [ ] Camera QR scanning (optional)
- [ ] Multi-language (optional)

## Next Steps

1. **Generate placeholder icons** (5 min)
   ```bash
   cd examples/web_runtime/icons
   # Follow README.md instructions
   ```

2. **Test on real mobile devices** (30 min)
   - Borrow iPhone and Android phone
   - Test all features
   - Note any issues

3. **Create real assets** (varies)
   - Record audio guides
   - Take exhibit photos
   - Generate QR codes
   - Create proper icons

4. **Deploy to production** (15 min)
   - Upload to Vercel/Netlify
   - Test deployed version
   - Print QR codes
   - Train museum staff

---

**Current Status:** ✅ Core system fully functional with placeholders
**Next:** Replace placeholders with actual museum content
