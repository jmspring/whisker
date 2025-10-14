/**
 * CSS Inliner Utility
 * Reads and minifies CSS for embedding in HTML exports
 */

class CSSInliner {
    /**
     * Get minified CSS for embedding
     * @returns {Promise<string>} Minified CSS
     */
    static async getMinifiedCSS() {
        try {
            const response = await fetch('../../../src/runtime/web_runtime.css');
            if (!response.ok) {
                throw new Error(`Failed to fetch CSS: ${response.statusText}`);
            }

            const css = await response.text();
            return this.minify(css);
        } catch (error) {
            console.error('[CSSInliner] Failed to load CSS:', error);
            // Return fallback minimal CSS
            return this.getFallbackCSS();
        }
    }

    /**
     * Minify CSS
     * @param {string} css - CSS to minify
     * @returns {string} Minified CSS
     */
    static minify(css) {
        return css
            // Remove comments
            .replace(/\/\*[\s\S]*?\*\//g, '')
            // Remove whitespace around special characters
            .replace(/\s*([{}:;,>+~])\s*/g, '$1')
            // Remove multiple spaces
            .replace(/\s+/g, ' ')
            // Remove space after colons in property declarations
            .replace(/:\s/g, ':')
            // Remove trailing semicolons before }
            .replace(/;}/g, '}')
            // Trim
            .trim();
    }

    /**
     * Get fallback CSS if main CSS fails to load
     * @returns {string} Minimal fallback CSS
     */
    static getFallbackCSS() {
        return `
body{margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;line-height:1.6}
.container{max-width:800px;margin:0 auto;padding:20px}
h1{color:#667eea;margin-bottom:20px}
.content{margin-bottom:20px;font-size:16px;line-height:1.8}
.choices{display:flex;flex-direction:column;gap:10px}
.choice-btn{background:#667eea;color:white;padding:12px 20px;border:none;border-radius:6px;cursor:pointer;font-size:15px;text-align:left}
.choice-btn:hover{background:#5568d3}
.stat-item{display:flex;justify-content:space-between;padding:8px;background:#f8f9fa;margin-bottom:4px;border-radius:4px}
.stat-label{font-weight:600}
.stat-value{color:#667eea}
.notification{position:fixed;top:20px;right:20px;background:white;padding:12px 20px;border-radius:8px;box-shadow:0 4px 12px rgba(0,0,0,0.15);animation:slideIn 0.3s ease}
@keyframes slideIn{from{transform:translateX(400px);opacity:0}to{transform:translateX(0);opacity:1}}
        `.trim();
    }

    /**
     * Get cached CSS (for multiple exports)
     */
    static _cssCache = null;

    static async getCachedCSS() {
        if (this._cssCache) {
            return this._cssCache;
        }

        this._cssCache = await this.getMinifiedCSS();
        return this._cssCache;
    }

    /**
     * Clear CSS cache (useful if CSS file changes)
     */
    static clearCache() {
        this._cssCache = null;
    }

    /**
     * Get CSS size info
     * @param {string} css - CSS to analyze
     * @returns {Object} Size information
     */
    static getSizeInfo(css) {
        const bytes = new Blob([css]).size;
        const kb = (bytes / 1024).toFixed(2);

        return {
            bytes: bytes,
            kilobytes: kb,
            formatted: `${kb} KB`
        };
    }

    /**
     * Format CSS (pretty print for debugging)
     * @param {string} css - Minified CSS
     * @returns {string} Formatted CSS
     */
    static format(css) {
        return css
            .replace(/\{/g, ' {\n    ')
            .replace(/\}/g, '\n}\n\n')
            .replace(/;/g, ';\n    ')
            .replace(/,/g, ',\n')
            .trim();
    }
}

// Make available globally
if (typeof window !== 'undefined') {
    window.CSSInliner = CSSInliner;
}
