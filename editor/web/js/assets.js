/**
 * Whisker Story Editor - Asset Manager
 * Phase 4 - Polish & Export
 */

class AssetManager {
    constructor(editor) {
        this.editor = editor;
        this.assets = new Map(); // filename -> { data, type, size }
    }

    /**
     * Initialize asset manager
     */
    initialize() {
        if (this.editor.project && this.editor.project.assets) {
            this.assets = new Map(Object.entries(this.editor.project.assets));
        }
    }

    /**
     * Upload asset
     */
    uploadAsset() {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = 'image/*,audio/*';
        input.multiple = true;

        input.onchange = async (e) => {
            const files = Array.from(e.target.files);
            
            for (const file of files) {
                await this.addAsset(file);
            }

            this.render();
            this.editor.updateStatus(`Added ${files.length} asset(s)`);
        };

        input.click();
    }

    /**
     * Add asset from file
     */
    async addAsset(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();

            reader.onload = (e) => {
                const asset = {
                    name: file.name,
                    type: file.type,
                    size: file.size,
                    data: e.target.result,
                    timestamp: Date.now()
                };

                this.assets.set(file.name, asset);

                // Add to project
                if (!this.editor.project.assets) {
                    this.editor.project.assets = {};
                }
                this.editor.project.assets[file.name] = asset;

                resolve(asset);
            };

            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }

    /**
     * Delete asset
     */
    deleteAsset(filename) {
        if (!confirm(`Delete asset "${filename}"?`)) return;

        this.assets.delete(filename);

        if (this.editor.project.assets) {
            delete this.editor.project.assets[filename];
        }

        this.render();
        this.editor.updateStatus(`Deleted asset: ${filename}`);
    }

    /**
     * Insert asset reference into content
     */
    insertAsset(filename) {
        const asset = this.assets.get(filename);
        if (!asset) return;

        const textarea = document.getElementById('passageContent');
        if (!textarea) return;

        let syntax = '';
        if (asset.type.startsWith('image/')) {
            syntax = `![${filename}](${filename})`;
        } else if (asset.type.startsWith('audio/')) {
            syntax = `[🔊 ${filename}](${filename})`;
        } else {
            syntax = `[${filename}](${filename})`;
        }

        const start = textarea.selectionStart;
        const end = textarea.selectionEnd;
        const text = textarea.value;

        textarea.value = text.substring(0, start) + syntax + text.substring(end);
        textarea.selectionStart = textarea.selectionEnd = start + syntax.length;
        textarea.focus();

        this.editor.updateCurrentPassage();
        this.hidePanel();
    }

    /**
     * Render assets panel
     */
    render() {
        const container = document.getElementById('assetsGrid');
        if (!container) return;

        if (this.assets.size === 0) {
            container.innerHTML = '<p style="grid-column: 1/-1; text-align: center; color: #888; padding: 40px;">No assets uploaded</p>';
            return;
        }

        container.innerHTML = Array.from(this.assets.entries()).map(([filename, asset]) => {
            const icon = this.getAssetIcon(asset.type);
            const size = this.formatSize(asset.size);

            return `
                <div class="asset-item" onclick="assetManager.selectAsset('${filename}')">
                    <div class="asset-thumbnail">
                        ${asset.type.startsWith('image/') ? 
                            `<img src="${asset.data}" style="max-width: 100%; max-height: 100%; object-fit: contain;">` :
                            icon
                        }
                    </div>
                    <div class="asset-name" title="${filename}">${filename}</div>
                    <div class="asset-size">${size}</div>
                </div>
            `;
        }).join('');
    }

    /**
     * Select asset (show context menu)
     */
    selectAsset(filename) {
        const actions = [
            { label: 'Insert into content', action: () => this.insertAsset(filename) },
            { label: 'Copy filename', action: () => this.copyFilename(filename) },
            { label: 'Delete', action: () => this.deleteAsset(filename), danger: true }
        ];

        // Simple confirm for now - could be enhanced with a proper context menu
        const action = confirm(`Asset: ${filename}\n\nInsert into content?`);
        if (action) {
            this.insertAsset(filename);
        }
    }

    /**
     * Copy filename to clipboard
     */
    copyFilename(filename) {
        navigator.clipboard.writeText(filename).then(() => {
            this.editor.updateStatus('Copied filename to clipboard');
        });
    }

    /**
     * Get icon for asset type
     */
    getAssetIcon(type) {
        if (type.startsWith('image/')) return '🖼️';
        if (type.startsWith('audio/')) return '🔊';
        if (type.startsWith('video/')) return '🎬';
        return '📎';
    }

    /**
     * Format file size
     */
    formatSize(bytes) {
        if (bytes < 1024) return bytes + ' B';
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
        return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
    }

    /**
     * Toggle assets panel
     */
    togglePanel() {
        const panel = document.getElementById('assetsPanel');
        if (!panel) return;

        panel.classList.toggle('hidden');
        
        if (!panel.classList.contains('hidden')) {
            this.render();
        }
    }

    /**
     * Hide assets panel
     */
    hidePanel() {
        const panel = document.getElementById('assetsPanel');
        if (panel) {
            panel.classList.add('hidden');
        }
    }

    /**
     * Get asset count
     */
    getCount() {
        return this.assets.size;
    }

    /**
     * Get total size
     */
    getTotalSize() {
        let total = 0;
        this.assets.forEach(asset => {
            total += asset.size;
        });
        return total;
    }
}

// Global instance
let assetManager = null;