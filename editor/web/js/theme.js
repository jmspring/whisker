/**
 * Whisker Story Editor - Theme Manager
 * Phase 4 - Polish & Export
 */

class ThemeManager {
    constructor() {
        this.currentTheme = 'dark';
        this.themes = [
            { id: 'dark', name: 'Dark', preview: 'dark' },
            { id: 'light', name: 'Light', preview: 'light' },
            { id: 'high-contrast', name: 'High Contrast', preview: 'high-contrast' },
            { id: 'solarized-dark', name: 'Solarized Dark', preview: 'solarized-dark' },
            { id: 'nord', name: 'Nord', preview: 'nord' }
        ];
    }

    /**
     * Initialize theme manager
     */
    initialize() {
        // Load saved theme
        const saved = localStorage.getItem('whisker_theme');
        if (saved) {
            this.setTheme(saved);
        }
    }

    /**
     * Set theme
     */
    setTheme(themeId) {
        this.currentTheme = themeId;
        
        if (themeId === 'dark') {
            document.documentElement.removeAttribute('data-theme');
        } else {
            document.documentElement.setAttribute('data-theme', themeId);
        }

        // Save to localStorage
        localStorage.setItem('whisker_theme', themeId);

        // Update UI
        this.updateThemeUI();
    }

    /**
     * Get current theme
     */
    getCurrentTheme() {
        return this.currentTheme;
    }

    /**
     * Toggle theme dropdown
     */
    toggleDropdown() {
        const dropdown = document.getElementById('themeDropdown');
        if (!dropdown) return;

        if (dropdown.classList.contains('hidden')) {
            this.renderDropdown();
            dropdown.classList.remove('hidden');

            // Close on click outside
            setTimeout(() => {
                document.addEventListener('click', () => {
                    dropdown.classList.add('hidden');
                }, { once: true });
            }, 0);
        } else {
            dropdown.classList.add('hidden');
        }
    }

    /**
     * Render theme dropdown
     */
    renderDropdown() {
        const dropdown = document.getElementById('themeDropdown');
        if (!dropdown) return;

        dropdown.innerHTML = this.themes.map(theme => `
            <div class="theme-option ${theme.id === this.currentTheme ? 'active' : ''}"
                 onclick="themeManager.setTheme('${theme.id}'); event.stopPropagation();">
                <div class="theme-preview ${theme.preview}"></div>
                <span>${theme.name}</span>
            </div>
        `).join('');
    }

    /**
     * Update theme UI elements
     */
    updateThemeUI() {
        const btn = document.getElementById('themeBtn');
        if (btn) {
            const theme = this.themes.find(t => t.id === this.currentTheme);
            btn.textContent = '🎨 ' + (theme ? theme.name : 'Theme');
        }
    }

    /**
     * Get available themes
     */
    getThemes() {
        return this.themes;
    }
}

// Global instance
let themeManager = null;