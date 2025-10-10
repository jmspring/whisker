# Whisker Web Runtime Example

Browser-based interactive fiction player with responsive design.

## 🚀 Running the Example

### Quick Start

```bash
# From project root, start a local server
python3 -m http.server 8000

# Then open in browser:
# http://localhost:8000/examples/web_runtime/index.html
```

### Alternative Servers

**Node.js:**
```bash
npx http-server -p 8000
```

**PHP:**
```bash
php -S localhost:8000
```

**Ruby:**
```bash
ruby -run -e httpd . -p 8000
```

## 📋 Requirements

### Browser Support
- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+
- ✅ Opera 76+

### Features Required
- JavaScript enabled
- LocalStorage (for saves)
- CSS3 support
- ES6 support

## 🎮 Controls

### Mouse
- **Click** choices to progress
- **Hover** over choices for visual feedback
- **Scroll** through long passages

### Keyboard Shortcuts
- `Ctrl+S` (or `⌘S` on Mac) - Save game
- `Ctrl+L` (or `⌘L` on Mac) - Load game
- `Ctrl+Z` (or `⌘Z` on Mac) - Undo last choice

### Touch (Mobile)
- **Tap** choices to select
- **Swipe** to scroll passages
- **Pinch zoom** supported

## ✨ Features

### Visual Design
- 🎨 **Modern UI**: Clean, professional interface
- 🌈 **Gradient Header**: Purple gradient design
- ✨ **Smooth Animations**: Fade effects and transitions
- 📱 **Responsive**: Works on desktop, tablet, mobile
- 🎯 **Hover Effects**: Interactive button animations

### Gameplay
- 💾 **LocalStorage Saves**: Auto-save support
- 📜 **History Tracking**: See your journey
- 📊 **Live Stats**: Real-time variable display
- 📈 **Progress Bar**: Visual completion indicator
- ↩️ **Undo System**: Take back choices

### Accessibility
- ♿ **ARIA Labels**: Screen reader friendly
- ⌨️ **Keyboard Navigation**: Full keyboard support
- 🎨 **High Contrast**: Readable color schemes
- 📏 **Scalable Text**: Respects browser zoom

## 📱 Mobile Support

### Responsive Breakpoints
- **Desktop**: 992px+ (full layout with sidebar)
- **Tablet**: 768px-991px (stacked layout)
- **Mobile**: <768px (optimized for small screens)

### Mobile Features
- Touch-optimized buttons
- Collapsible sidebar
- Reduced animations
- Compact controls

## 🎨 Customization

### Changing the Story

Edit the `STORY_DATA` constant in `index.html`:

```javascript
const STORY_DATA = {
    title: "Your Story",
    author: "Your Name",
    variables: {
        health: 100,
        score: 0
    },
    start: "beginning",
    passages: [
        {
            id: "beginning",
            title: "The Start",
            content: "Your adventure begins...",
            choices: [...]
        }
    ]
};
```

### Custom Styling

Add custom CSS after the stylesheet link:

```html
<style>
    .whisker-container {
        max-width: 1200px; /* Wider content */
    }

    .whisker-header {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    }

    .choice-btn {
        background: #ff6b6b;
        border-color: #c92a2a;
    }
</style>
```

### Loading External Stories

To load stories from external JSON files:

```javascript
// Fetch story from file
fetch('story.json')
    .then(response => response.json())
    .then(story => {
        whiskerPlayer.loadStory(story);
        whiskerPlayer.start();
    });
```

## 🐛 Troubleshooting

### Page won't load

**Problem**: Blank page or errors

**Solution**:
1. Use a web server (not `file://` protocol)
2. Check browser console for errors (F12)
3. Verify CSS path is correct

### Styles not applied

**Problem**: No colors or layout issues

**Solution**:
- Check CSS path: `../../src/runtime/web_runtime.css`
- View page source to verify link tag
- Clear browser cache (Ctrl+Shift+R)

### Save not working

**Problem**: Can't save or load games

**Solution**:
- Check browser LocalStorage is enabled
- Check browser privacy settings
- Try different browser
- Clear browser data if corrupted

### Slow performance

**Problem**: Laggy or slow

**Solution**:
1. Close other tabs
2. Update browser to latest version
3. Disable browser extensions
4. Check CPU usage

### Mobile issues

**Problem**: UI doesn't fit or respond

**Solution**:
- Add viewport meta tag (already included)
- Test in mobile device mode (F12 → Device toolbar)
- Check responsive CSS breakpoints

## 💡 Tips & Tricks

### Development
1. **Live Reload**: Use live-server for auto-refresh
2. **Debug**: Open console (F12) for error messages
3. **Responsive Testing**: Use browser dev tools device emulation

### Deployment
1. **Minify**: Compress CSS and JS for production
2. **CDN**: Host assets on CDN for faster loading
3. **Cache**: Set proper cache headers
4. **HTTPS**: Use HTTPS for localStorage security

### Performance
1. **Lazy Load**: Load images on demand
2. **Compress**: Use gzip/brotli compression
3. **Bundle**: Combine CSS/JS files
4. **Optimize**: Remove unused CSS/JS

## 📦 Deployment

### GitHub Pages

1. Push to GitHub repository
2. Enable GitHub Pages in settings
3. Select branch and folder
4. Access at `https://username.github.io/repo/examples/web_runtime/`

### Netlify

1. Drag and drop project folder to Netlify
2. Or connect GitHub repository
3. Automatic deployment on push

### Vercel

1. Install Vercel CLI: `npm i -g vercel`
2. Run: `vercel`
3. Follow prompts

### Static Hosting

Works on any static host:
- **AWS S3**
- **Google Cloud Storage**
- **Azure Static Web Apps**
- **Firebase Hosting**
- **Surge.sh**

## 🔒 Security Considerations

### LocalStorage
- Data stored in browser (not encrypted)
- Limited to ~5-10MB
- Can be cleared by user
- Same-origin policy applies

### Script Execution
- Stories can run JavaScript via `script` field
- Sandbox execution for safety
- Avoid storing sensitive data

### CORS
- May need CORS headers for external resources
- Same-origin policy for fetch requests

## 🎯 Next Steps

### Enhance the Player

Ideas for improvements:
- 🎵 Add background music
- 🔊 Add sound effects
- 🖼️ Add image galleries
- 📊 Add achievement system
- 🗺️ Add story map
- 💬 Add choice timers
- 🎨 Add more themes

### Create Your Story

1. **Plan**: Outline your narrative
2. **Write**: Create passages and choices
3. **Code**: Format as JSON
4. **Test**: Play through all paths
5. **Polish**: Add variables and scripts
6. **Deploy**: Publish online

### Example: Adding Background Music

```javascript
// In your story
passages: [
    {
        id: "intro",
        title: "Welcome",
        content: "Story begins...",
        script: `
            const audio = new Audio('music.mp3');
            audio.loop = true;
            audio.play();
        `,
        choices: [...]
    }
]
```

## 📚 Advanced Features

### Analytics

Track player behavior:

```javascript
// Add after choice made
gtag('event', 'choice_made', {
    'event_category': 'gameplay',
    'event_label': choice.text
});
```

### Achievements

```javascript
// Check for achievements
if (get('discoveries') >= 5) {
    showNotification('Achievement: Master Explorer!', 'success');
}
```

### Multiplayer Sync

Use Firebase or similar for cloud saves:

```javascript
// Save to Firebase
firebase.database().ref('saves/' + userId).set({
    passageId: currentPassageId,
    variables: variables
});
```

## 📖 Learn More

### Documentation
- [Whisker Runtime Docs](../../src/runtime/README.md)
- [Story Format](../../docs/FORMAT_REFERENCE.md)
- [API Reference](../../docs/API_REFERENCE.md)

### Tutorials
- [MDN Web Docs](https://developer.mozilla.org/)
- [JavaScript.info](https://javascript.info/)
- [CSS Tricks](https://css-tricks.com/)

### Inspiration
- [Twine Games](https://twinery.org/)
- [Choice of Games](https://www.choiceofgames.com/)
- [Inkle Studios](https://www.inklestudios.com/)

## 🤝 Contributing

Ideas for contributions:
- Visual theme builder
- Story editor UI
- Better mobile experience
- Internationalization (i18n)
- Accessibility improvements
- Performance optimizations

---

**Start creating web adventures! 🌐✨**