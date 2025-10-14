/**
 * Museum Client - Web Runtime
 * Browser-based museum tour player with offline support
 * Mobile-optimized with audio, QR scanning, and analytics
 */

class MuseumClient {
    constructor() {
        this.story = null;
        this.currentPassage = null;
        this.visited = {};
        this.variables = {};
        this.sessionStart = Date.now();
        this.audioPlayedCount = 0;
        this.language = 'en';

        // Audio player state
        this.audioElement = null;
        this.audioPlaying = false;

        // Initialize after DOM is ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.initialize());
        } else {
            this.initialize();
        }
    }

    initialize() {
        // Get audio element
        this.audioElement = document.getElementById('audio-element');

        // Set up event listeners
        this.setupEventListeners();
        this.setupAudioListeners();

        console.log('✅ Museum Client initialized');
    }

    /* ==========================================
       STORY MANAGEMENT
       ========================================== */

    loadStory(story) {
        this.story = story;

        // Initialize variables
        if (story.variables) {
            story.variables.forEach(variable => {
                this.variables[variable.name] = variable.initial;
            });
        }

        // Set UI metadata
        const metadata = story.metadata || {};
        document.getElementById('tour-title').textContent = metadata.title || 'Museum Tour';
        document.getElementById('tour-subtitle').textContent = metadata.museum || '';

        console.log('✅ Story loaded:', metadata.title);
    }

    start() {
        if (!this.story) {
            console.error('No story loaded');
            return;
        }

        // Find start passage
        const startId = this.story.settings?.startPassage || this.story.passages[0]?.id || 'welcome';
        this.gotoPassage(startId);
    }

    findPassage(identifier) {
        if (!this.story) return null;

        return this.story.passages.find(p =>
            p.id === identifier || p.name === identifier
        );
    }

    /* ==========================================
       NAVIGATION
       ========================================== */

    gotoPassage(identifier) {
        const passage = this.findPassage(identifier);

        if (!passage) {
            console.error('Passage not found:', identifier);
            return false;
        }

        this.currentPassage = passage;

        // Track visit
        if (!this.visited[passage.id]) {
            this.visited[passage.id] = {
                firstVisit: Date.now(),
                visitCount: 0
            };
        }

        this.visited[passage.id].visitCount++;
        this.visited[passage.id].lastVisit = Date.now();

        // Update variables
        if (this.variables.visited_count !== undefined) {
            this.variables.visited_count = this.getVisitedCount();
        }

        // Render passage
        this.render();
        this.updateProgress();

        // Scroll to top
        document.querySelector('.museum-main').scrollTo(0, 0);

        return true;
    }

    scanQR(qrCode) {
        // Find passage with matching QR code
        const passage = this.story.passages.find(p =>
            p.metadata && p.metadata.qrCode === qrCode
        );

        if (passage) {
            this.gotoPassage(passage.id);
            this.closeModal('qr-modal');
            return true;
        }

        alert('No exhibit found for QR code: ' + qrCode);
        return false;
    }

    /* ==========================================
       RENDERING
       ========================================== */

    render() {
        if (!this.currentPassage) return;

        const passage = this.currentPassage;

        // Title
        document.getElementById('passage-title').textContent = passage.name || passage.id;

        // Metadata
        this.renderMetadata(passage.metadata);

        // Content
        document.getElementById('passage-content').innerHTML = this.processContent(passage.text);

        // Choices
        this.renderChoices(passage.choices || []);
    }

    renderMetadata(metadata) {
        const container = document.getElementById('passage-metadata');
        container.innerHTML = '';

        if (!metadata) return;

        const badges = [];

        if (metadata.floor) {
            badges.push({ icon: '📍', text: `Floor ${metadata.floor}` });
        }

        if (metadata.hasAudio && metadata.audioLength) {
            badges.push({ icon: '🎧', text: metadata.audioLength });
        }

        if (metadata.qrCode) {
            badges.push({ icon: '🔲', text: metadata.qrCode });
        }

        if (metadata.popularity) {
            const stars = '⭐'.repeat(metadata.popularity);
            badges.push({ icon: '', text: stars });
        }

        badges.forEach(badge => {
            const el = document.createElement('div');
            el.className = 'metadata-badge';
            el.innerHTML = `
                ${badge.icon ? `<span class="icon">${badge.icon}</span>` : ''}
                <span>${badge.text}</span>
            `;
            container.appendChild(el);
        });
    }

    processContent(text) {
        if (!text) return '';

        // Process variables {{variable}}
        text = text.replace(/\{\{([a-zA-Z_][a-zA-Z0-9_]*)\}\}/g, (match, varName) => {
            if (this.variables.hasOwnProperty(varName)) {
                return String(this.variables[varName]);
            }
            return match;
        });

        // Process markdown
        // Headers
        text = text.replace(/^# (.+)$/gm, '<h2>$1</h2>');
        text = text.replace(/^## (.+)$/gm, '<h3>$1</h3>');
        text = text.replace(/^### (.+)$/gm, '<h4>$1</h4>');

        // Bold and italic
        text = text.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
        text = text.replace(/\*(.+?)\*/g, '<em>$1</em>');

        // Audio/image references
        text = text.replace(/\[audio\]\(([^)]+)\)/g, (match, path) => {
            return `<button class="inline-audio-btn" onclick="museumClient.playAudioFromPath('${path}')" aria-label="Play audio">🎧 Play Audio Guide</button>`;
        });

        text = text.replace(/\[image\]\(([^)]+)\)/g, (match, path) => {
            return `<img src="${path}" alt="Exhibit image" loading="lazy">`;
        });

        // Lists (simple implementation)
        text = text.replace(/^- (.+)$/gm, '<li>$1</li>');
        text = text.replace(/(<li>.*<\/li>\n?)+/g, '<ul>$&</ul>');

        // Paragraphs
        const paragraphs = text.split(/\n\n+/).filter(p => p.trim());
        text = paragraphs.map(p => {
            // Don't wrap if already has block-level tags
            if (p.match(/^<(h[1-6]|ul|ol|div|button)/)) {
                return p;
            }
            return `<p>${p.trim()}</p>`;
        }).join('');

        return text;
    }

    renderChoices(choices) {
        const container = document.getElementById('passage-choices');
        container.innerHTML = '';

        choices.forEach((choice, index) => {
            const btn = document.createElement('button');
            btn.className = 'choice-btn';
            btn.textContent = choice.text;
            btn.setAttribute('aria-label', `Choice: ${choice.text}`);

            btn.addEventListener('click', () => {
                this.gotoPassage(choice.target);
            });

            container.appendChild(btn);
        });
    }

    /* ==========================================
       PROGRESS TRACKING
       ========================================== */

    updateProgress() {
        const visitedCount = this.getVisitedCount();
        const totalCount = this.story.passages.length;
        const percentage = Math.floor((visitedCount / totalCount) * 100);

        document.getElementById('progress-bar').style.width = percentage + '%';
        document.getElementById('progress-text').textContent = `${visitedCount}/${totalCount} exhibits`;
    }

    getVisitedCount() {
        return Object.keys(this.visited).length;
    }

    /* ==========================================
       AUDIO PLAYER
       ========================================== */

    playAudioFromPath(audioPath) {
        const fullPath = '../museum_tours/natural_history/' + audioPath;
        this.playAudio(fullPath, 'Audio Guide');
    }

    playAudio(audioPath, title = 'Audio Guide') {
        if (!this.audioElement) return;

        this.audioElement.src = audioPath;
        this.audioElement.load();
        this.audioElement.play();

        // Show audio player
        const player = document.getElementById('audio-player');
        player.style.display = 'block';
        setTimeout(() => player.classList.add('visible'), 10);

        // Set title
        document.getElementById('audio-title').textContent = title;

        // Track play count
        this.audioPlayedCount++;

        if (this.variables.audio_count !== undefined) {
            this.variables.audio_count = this.audioPlayedCount;
        }
    }

    toggleAudioPlayPause() {
        if (!this.audioElement) return;

        if (this.audioElement.paused) {
            this.audioElement.play();
        } else {
            this.audioElement.pause();
        }
    }

    seekAudio(delta) {
        if (!this.audioElement) return;
        this.audioElement.currentTime = Math.max(0, this.audioElement.currentTime + delta);
    }

    closeAudioPlayer() {
        const player = document.getElementById('audio-player');
        player.classList.remove('visible');
        setTimeout(() => {
            player.style.display = 'none';
            if (this.audioElement) {
                this.audioElement.pause();
                this.audioElement.src = '';
            }
        }, 300);
    }

    setupAudioListeners() {
        if (!this.audioElement) return;

        // Play/pause button
        const playIcon = document.getElementById('audio-play-icon');

        this.audioElement.addEventListener('play', () => {
            playIcon.textContent = '⏸️';
        });

        this.audioElement.addEventListener('pause', () => {
            playIcon.textContent = '▶️';
        });

        // Update duration and seek bar
        this.audioElement.addEventListener('loadedmetadata', () => {
            this.updateAudioDuration();
        });

        this.audioElement.addEventListener('timeupdate', () => {
            this.updateAudioDuration();
            this.updateAudioSeekBar();
        });

        // Seek bar input
        const seekBar = document.getElementById('audio-seek-bar');
        seekBar.addEventListener('input', (e) => {
            const time = (e.target.value / 100) * this.audioElement.duration;
            this.audioElement.currentTime = time;
        });

        // Control buttons
        document.getElementById('audio-play-pause').addEventListener('click', () => {
            this.toggleAudioPlayPause();
        });

        document.getElementById('audio-rewind').addEventListener('click', () => {
            this.seekAudio(-15);
        });

        document.getElementById('audio-forward').addEventListener('click', () => {
            this.seekAudio(15);
        });

        document.getElementById('audio-close').addEventListener('click', () => {
            this.closeAudioPlayer();
        });
    }

    updateAudioDuration() {
        if (!this.audioElement) return;

        const current = this.formatTime(this.audioElement.currentTime);
        const duration = this.formatTime(this.audioElement.duration);

        document.getElementById('audio-duration').textContent = `${current} / ${duration}`;
    }

    updateAudioSeekBar() {
        if (!this.audioElement) return;

        const percentage = (this.audioElement.currentTime / this.audioElement.duration) * 100;
        document.getElementById('audio-seek-bar').value = percentage || 0;
    }

    formatTime(seconds) {
        if (isNaN(seconds)) return '0:00';

        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    }

    /* ==========================================
       MAP
       ========================================== */

    showMap() {
        const container = document.getElementById('map-container');
        container.innerHTML = '';

        // Create exhibit list
        const listEl = document.createElement('div');
        listEl.className = 'map-exhibit-list';

        // Get exhibits (passages with exhibitId metadata)
        const exhibits = this.story.passages.filter(p => p.metadata && p.metadata.exhibitId);

        // Sort by floor
        exhibits.sort((a, b) => {
            const floorA = a.metadata.floor || 0;
            const floorB = b.metadata.floor || 0;
            return floorA - floorB;
        });

        exhibits.forEach(exhibit => {
            const visited = this.visited[exhibit.id];
            const exhibitEl = document.createElement('div');
            exhibitEl.className = 'map-exhibit' + (visited ? ' visited' : '');

            exhibitEl.innerHTML = `
                <span class="exhibit-status">${visited ? '✓' : '◯'}</span>
                <div class="exhibit-info">
                    <div class="exhibit-name">${exhibit.name}</div>
                    <div class="exhibit-details">
                        Floor ${exhibit.metadata.floor || '?'} •
                        ${exhibit.metadata.hasAudio ? '🎧 Audio' : 'No audio'} •
                        QR: ${exhibit.metadata.qrCode || 'N/A'}
                    </div>
                </div>
            `;

            exhibitEl.addEventListener('click', () => {
                this.gotoPassage(exhibit.id);
                this.closeModal('map-modal');
            });

            listEl.appendChild(exhibitEl);
        });

        container.appendChild(listEl);
        this.showModal('map-modal');
    }

    /* ==========================================
       STATISTICS
       ========================================== */

    showStats() {
        const container = document.getElementById('stats-container');
        container.innerHTML = '';

        // Calculate stats
        const visitedCount = this.getVisitedCount();
        const totalCount = this.story.passages.length;
        const percentage = Math.floor((visitedCount / totalCount) * 100);
        const duration = Math.floor((Date.now() - this.sessionStart) / 60000);

        // Create stats grid
        const gridEl = document.createElement('div');
        gridEl.className = 'stats-grid';

        const stats = [
            { value: visitedCount, label: 'Exhibits Visited' },
            { value: `${percentage}%`, label: 'Completion' },
            { value: `${duration} min`, label: 'Tour Duration' },
            { value: this.audioPlayedCount, label: 'Audio Guides' }
        ];

        stats.forEach(stat => {
            const cardEl = document.createElement('div');
            cardEl.className = 'stat-card';
            cardEl.innerHTML = `
                <div class="stat-value">${stat.value}</div>
                <div class="stat-label">${stat.label}</div>
            `;
            gridEl.appendChild(cardEl);
        });

        container.appendChild(gridEl);

        // Most visited exhibit
        if (visitedCount > 0) {
            let mostVisited = null;
            let maxVisits = 0;

            for (const [passageId, info] of Object.entries(this.visited)) {
                if (info.visitCount > maxVisits) {
                    maxVisits = info.visitCount;
                    mostVisited = this.findPassage(passageId);
                }
            }

            if (mostVisited) {
                const detailEl = document.createElement('div');
                detailEl.className = 'help-section';
                detailEl.innerHTML = `
                    <h3>⭐ Most Revisited</h3>
                    <p><strong>${mostVisited.name}</strong> (${maxVisits} times)</p>
                `;
                container.appendChild(detailEl);
            }
        }

        this.showModal('stats-modal');
    }

    /* ==========================================
       SESSION EXPORT
       ========================================== */

    exportSession() {
        const sessionData = {
            storyIfid: this.story.metadata?.ifid,
            sessionStart: this.sessionStart,
            durationSeconds: Math.floor((Date.now() - this.sessionStart) / 1000),
            visited: this.visited,
            variables: this.variables,
            audioPlayedCount: this.audioPlayedCount,
            language: this.language
        };

        // Download as JSON
        const blob = new Blob([JSON.stringify(sessionData, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `museum-visit-${Date.now()}.json`;
        a.click();
        URL.revokeObjectURL(url);

        alert('Visit data exported! Check your downloads.');
    }

    /* ==========================================
       MODALS
       ========================================== */

    showModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.add('visible');

            // Close on overlay click
            const overlay = modal.querySelector('.modal-overlay');
            overlay.addEventListener('click', () => this.closeModal(modalId));
        }
    }

    closeModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.remove('visible');
        }
    }

    /* ==========================================
       EVENT LISTENERS
       ========================================== */

    setupEventListeners() {
        // Navigation buttons
        document.getElementById('btn-menu').addEventListener('click', () => this.showModal('menu-modal'));
        document.getElementById('btn-map').addEventListener('click', () => this.showMap());
        document.getElementById('btn-qr').addEventListener('click', () => this.showModal('qr-modal'));
        document.getElementById('btn-audio').addEventListener('click', () => {
            if (this.currentPassage?.metadata?.hasAudio) {
                // Play current passage audio if available
                alert('Audio feature coming soon!');
            } else {
                alert('No audio available for this exhibit');
            }
        });
        document.getElementById('btn-stats').addEventListener('click', () => this.showStats());
        document.getElementById('btn-help').addEventListener('click', () => this.showModal('help-modal'));

        // Modal close buttons
        document.getElementById('map-modal-close').addEventListener('click', () => this.closeModal('map-modal'));
        document.getElementById('qr-modal-close').addEventListener('click', () => this.closeModal('qr-modal'));
        document.getElementById('stats-modal-close').addEventListener('click', () => this.closeModal('stats-modal'));
        document.getElementById('help-modal-close').addEventListener('click', () => this.closeModal('help-modal'));
        document.getElementById('menu-modal-close').addEventListener('click', () => this.closeModal('menu-modal'));

        // QR Scanner
        document.getElementById('qr-submit').addEventListener('click', () => {
            const qrCode = document.getElementById('qr-input').value.trim();
            if (qrCode) {
                this.scanQR(qrCode);
            }
        });

        document.getElementById('qr-input').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                document.getElementById('qr-submit').click();
            }
        });

        // Menu options
        document.getElementById('menu-restart').addEventListener('click', () => {
            if (confirm('Are you sure you want to restart the tour?')) {
                this.visited = {};
                this.variables = {};
                this.sessionStart = Date.now();
                this.audioPlayedCount = 0;
                this.start();
                this.closeModal('menu-modal');
            }
        });

        document.getElementById('menu-export').addEventListener('click', () => {
            this.exportSession();
            this.closeModal('menu-modal');
        });

        document.getElementById('menu-about').addEventListener('click', () => {
            alert('Museum Tour powered by Whisker\nVersion 1.0.0\n\nCreated with Claude Code');
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                // Close any open modals
                document.querySelectorAll('.museum-modal.visible').forEach(modal => {
                    modal.classList.remove('visible');
                });

                // Close audio player
                if (document.getElementById('audio-player').classList.contains('visible')) {
                    this.closeAudioPlayer();
                }
            }
        });
    }
}

// Global instance
const museumClient = new MuseumClient();
