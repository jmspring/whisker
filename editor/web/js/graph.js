/**
 * Whisker Story Editor - Graph View Controller
 * Phase 2 - Visual Node Editor
 */

class GraphView {
    constructor(editor) {
        this.editor = editor;
        this.container = null;
        this.canvas = null;
        this.svg = null;
        
        // Graph state
        this.nodes = new Map(); // passageId -> {x, y, element}
        this.zoom = 1.0;
        this.panX = 0;
        this.panY = 0;
        
        // Interaction state
        this.isPanning = false;
        this.isDragging = false;
        this.isConnecting = false;
        this.selectedNodes = new Set();
        this.draggedNode = null;
        this.connectingFrom = null;
        this.dragStartX = 0;
        this.dragStartY = 0;
        this.lastMouseX = 0;
        this.lastMouseY = 0;
        
        // Context menu
        this.contextMenu = null;
    }

    /**
     * Initialize the graph view
     */
    initialize() {
        this.container = document.getElementById('graphContainer');
        this.canvas = document.getElementById('graphCanvas');
        this.svg = document.getElementById('graphConnections');
        
        if (!this.container || !this.canvas || !this.svg) return;
        
        this.setupEventListeners();
    }

    /**
     * Setup all event listeners for graph interaction
     */
    setupEventListeners() {
        // Mouse events for panning
        this.canvas.addEventListener('mousedown', (e) => this.onMouseDown(e));
        this.canvas.addEventListener('mousemove', (e) => this.onMouseMove(e));
        this.canvas.addEventListener('mouseup', (e) => this.onMouseUp(e));
        this.canvas.addEventListener('mouseleave', (e) => this.onMouseUp(e));
        
        // Wheel for zooming
        this.canvas.addEventListener('wheel', (e) => this.onWheel(e));
        
        // Context menu
        this.canvas.addEventListener('contextmenu', (e) => {
            e.preventDefault();
            this.hideContextMenu();
        });
        
        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => this.onKeyDown(e));
    }

    /**
     * Render the entire graph
     */
    render() {
        if (!this.editor.project) return;
        
        // Clear existing nodes
        this.canvas.innerHTML = '';
        this.nodes.clear();
        
        // Auto-layout if nodes don't have positions
        const needsLayout = this.editor.project.passages.some(p => !p.position);
        if (needsLayout) {
            this.autoLayout();
        }
        
        // Create nodes
        this.editor.project.passages.forEach(passage => {
            this.createNode(passage);
        });
        
        // Draw connections
        this.drawConnections();
    }

    /**
     * Create a node element for a passage
     */
    createNode(passage) {
        const node = document.createElement('div');
        node.className = 'graph-node';
        node.dataset.passageId = passage.id;
        
        if (passage.id === this.editor.project.settings.startPassage) {
            node.classList.add('start-node');
        }
        
        if (passage.id === this.editor.currentPassageId) {
            node.classList.add('selected');
        }
        
        // Position
        const pos = passage.position || { x: 100, y: 100 };
        this.setNodePosition(node, pos.x, pos.y);
        
        // Content
        const preview = passage.content.substring(0, 100);
        const choicesHtml = passage.choices.map(choice => `
            <div class="node-choice">
                <span class="choice-arrow">→</span>
                <span>${choice.text}</span>
            </div>
        `).join('');
        
        node.innerHTML = `
            <div class="node-header">
                <div class="node-title">${passage.title}</div>
                <button class="node-menu" onclick="graph.showNodeMenu(event, '${passage.id}')">⋮</button>
            </div>
            <div class="node-content">${preview || '(empty)'}</div>
            <div class="node-choices">${choicesHtml}</div>
            <div class="node-connector" onclick="graph.startConnection(event, '${passage.id}')"></div>
        `;
        
        // Events
        node.addEventListener('mousedown', (e) => this.onNodeMouseDown(e, passage.id));
        node.addEventListener('click', (e) => this.onNodeClick(e, passage.id));
        node.addEventListener('dblclick', (e) => this.onNodeDoubleClick(e, passage.id));
        
        this.canvas.appendChild(node);
        this.nodes.set(passage.id, { x: pos.x, y: pos.y, element: node });
        
        return node;
    }

    /**
     * Set node position with transform
     */
    setNodePosition(node, x, y) {
        node.style.transform = `translate(${x}px, ${y}px)`;
    }

    /**
     * Get node center position
     */
    getNodeCenter(passageId) {
        const nodeData = this.nodes.get(passageId);
        if (!nodeData) return { x: 0, y: 0 };
        
        const rect = nodeData.element.getBoundingClientRect();
        const canvasRect = this.canvas.getBoundingClientRect();
        
        return {
            x: (nodeData.x + rect.width / 2),
            y: (nodeData.y + rect.height / 2)
        };
    }

    /**
     * Draw all connection lines
     */
    drawConnections() {
        this.svg.innerHTML = '<defs><marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto"><polygon points="0 0, 10 3.5, 0 7" class="connection-arrow" /></marker></defs>';
        
        this.editor.project.passages.forEach(passage => {
            passage.choices.forEach(choice => {
                const target = choice.target;
                if (!this.nodes.has(target)) return;
                
                const start = this.getNodeCenter(passage.id);
                const end = this.getNodeCenter(target);
                
                // Create curved path
                const dx = end.x - start.x;
                const dy = end.y - start.y;
                const curve = Math.min(Math.abs(dx) * 0.5, 100);
                
                const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
                path.setAttribute('d', `M ${start.x} ${start.y} C ${start.x + curve} ${start.y}, ${end.x - curve} ${end.y}, ${end.x} ${end.y}`);
                path.setAttribute('class', 'connection-line');
                path.setAttribute('marker-end', 'url(#arrowhead)');
                
                this.svg.appendChild(path);
            });
        });
    }

    /**
     * Auto-layout algorithm (hierarchical)
     */
    autoLayout() {
        this.showLayoutIndicator();
        
        const passages = this.editor.project.passages;
        const startId = this.editor.project.settings.startPassage;
        
        // Build graph structure
        const graph = new Map();
        passages.forEach(p => {
            graph.set(p.id, {
                passage: p,
                children: p.choices.map(c => c.target),
                level: -1,
                visited: false
            });
        });
        
        // BFS to determine levels
        const queue = [{ id: startId, level: 0 }];
        graph.get(startId).level = 0;
        
        while (queue.length > 0) {
            const { id, level } = queue.shift();
            const node = graph.get(id);
            if (!node) continue;
            
            node.children.forEach(childId => {
                const child = graph.get(childId);
                if (child && child.level === -1) {
                    child.level = level + 1;
                    queue.push({ id: childId, level: level + 1 });
                }
            });
        }
        
        // Group by level
        const levels = new Map();
        graph.forEach((node, id) => {
            const level = node.level === -1 ? 0 : node.level;
            if (!levels.has(level)) {
                levels.set(level, []);
            }
            levels.get(level).push(id);
        });
        
        // Position nodes
        const levelWidth = 300;
        const nodeHeight = 150;
        const startX = 100;
        const startY = 100;
        
        levels.forEach((ids, level) => {
            const totalHeight = ids.length * nodeHeight;
            ids.forEach((id, index) => {
                const passage = passages.find(p => p.id === id);
                if (passage) {
                    passage.position = {
                        x: startX + level * levelWidth,
                        y: startY + (index * nodeHeight) - (totalHeight / 2) + (nodeHeight / 2)
                    };
                }
            });
        });
        
        setTimeout(() => this.hideLayoutIndicator(), 500);
    }

    /**
     * Mouse down handler
     */
    onMouseDown(e) {
        if (e.button === 0 && e.target === this.canvas) {
            this.isPanning = true;
            this.dragStartX = e.clientX - this.panX;
            this.dragStartY = e.clientY - this.panY;
            this.canvas.classList.add('panning');
        }
    }

    /**
     * Mouse move handler
     */
    onMouseMove(e) {
        this.lastMouseX = e.clientX;
        this.lastMouseY = e.clientY;
        
        if (this.isPanning) {
            this.panX = e.clientX - this.dragStartX;
            this.panY = e.clientY - this.dragStartY;
            this.applyTransform();
        } else if (this.isDragging && this.draggedNode) {
            const canvasRect = this.canvas.getBoundingClientRect();
            const x = (e.clientX - canvasRect.left - this.panX) / this.zoom;
            const y = (e.clientY - canvasRect.top - this.panY) / this.zoom;
            
            this.moveNode(this.draggedNode, x, y);
        } else if (this.isConnecting) {
            this.drawTempConnection(e);
        }
    }

    /**
     * Mouse up handler
     */
    onMouseUp(e) {
        if (this.isPanning) {
            this.isPanning = false;
            this.canvas.classList.remove('panning');
        }
        
        if (this.isDragging) {
            this.isDragging = false;
            this.draggedNode = null;
        }
        
        if (this.isConnecting) {
            this.finishConnection(e);
        }
    }

    /**
     * Node mouse down handler
     */
    onNodeMouseDown(e, passageId) {
        if (e.button !== 0) return;
        
        e.stopPropagation();
        
        this.isDragging = true;
        this.draggedNode = passageId;
    }

    /**
     * Node click handler
     */
    onNodeClick(e, passageId) {
        e.stopPropagation();
        
        if (!e.ctrlKey && !e.metaKey) {
            this.selectedNodes.clear();
        }
        
        this.selectedNodes.add(passageId);
        this.updateNodeSelection();
        
        // Update editor
        this.editor.selectPassage(passageId);
    }

    /**
     * Node double click handler - open editor
     */
    onNodeDoubleClick(e, passageId) {
        e.stopPropagation();
        this.editor.selectPassage(passageId);
        this.editor.switchView('list');
    }

    /**
     * Move a node to new position
     */
    moveNode(passageId, x, y) {
        const nodeData = this.nodes.get(passageId);
        if (!nodeData) return;
        
        nodeData.x = x;
        nodeData.y = y;
        this.setNodePosition(nodeData.element, x, y);
        
        // Update passage position
        const passage = this.editor.project.passages.find(p => p.id === passageId);
        if (passage) {
            passage.position = { x, y };
        }
        
        this.drawConnections();
    }

    /**
     * Update node selection visuals
     */
    updateNodeSelection() {
        this.nodes.forEach((nodeData, passageId) => {
            if (this.selectedNodes.has(passageId)) {
                nodeData.element.classList.add('selected');
            } else {
                nodeData.element.classList.remove('selected');
            }
        });
    }

    /**
     * Wheel handler for zooming
     */
    onWheel(e) {
        e.preventDefault();
        
        const delta = e.deltaY > 0 ? 0.9 : 1.1;
        const newZoom = Math.min(Math.max(this.zoom * delta, 0.1), 3.0);
        
        // Zoom towards mouse position
        const rect = this.canvas.getBoundingClientRect();
        const mouseX = e.clientX - rect.left;
        const mouseY = e.clientY - rect.top;
        
        const worldX = (mouseX - this.panX) / this.zoom;
        const worldY = (mouseY - this.panY) / this.zoom;
        
        this.zoom = newZoom;
        
        this.panX = mouseX - worldX * this.zoom;
        this.panY = mouseY - worldY * this.zoom;
        
        this.applyTransform();
        this.updateZoomDisplay();
    }

    /**
     * Apply transform to canvas
     */
    applyTransform() {
        this.canvas.style.transform = `translate(${this.panX}px, ${this.panY}px) scale(${this.zoom})`;
        this.canvas.style.transformOrigin = '0 0';
    }

    /**
     * Zoom controls
     */
    zoomIn() {
        this.zoom = Math.min(this.zoom * 1.2, 3.0);
        this.applyTransform();
        this.updateZoomDisplay();
    }

    zoomOut() {
        this.zoom = Math.max(this.zoom * 0.8, 0.1);
        this.applyTransform();
        this.updateZoomDisplay();
    }

    zoomReset() {
        this.zoom = 1.0;
        this.panX = 0;
        this.panY = 0;
        this.applyTransform();
        this.updateZoomDisplay();
    }

    zoomToFit() {
        if (this.nodes.size === 0) return;
        
        let minX = Infinity, minY = Infinity;
        let maxX = -Infinity, maxY = -Infinity;
        
        this.nodes.forEach(node => {
            minX = Math.min(minX, node.x);
            minY = Math.min(minY, node.y);
            maxX = Math.max(maxX, node.x + 250);
            maxY = Math.max(maxY, node.y + 200);
        });
        
        const width = maxX - minX;
        const height = maxY - minY;
        const rect = this.container.getBoundingClientRect();
        
        const scaleX = rect.width / width;
        const scaleY = rect.height / height;
        this.zoom = Math.min(scaleX, scaleY, 1.0) * 0.9;
        
        this.panX = (rect.width - width * this.zoom) / 2 - minX * this.zoom;
        this.panY = (rect.height - height * this.zoom) / 2 - minY * this.zoom;
        
        this.applyTransform();
        this.updateZoomDisplay();
    }

    /**
     * Update zoom level display
     */
    updateZoomDisplay() {
        const display = document.getElementById('zoomLevel');
        if (display) {
            display.textContent = `${Math.round(this.zoom * 100)}%`;
        }
    }

    /**
     * Start creating a connection
     */
    startConnection(e, passageId) {
        e.stopPropagation();
        this.isConnecting = true;
        this.connectingFrom = passageId;
        this.canvas.classList.add('connecting');
    }

    /**
     * Draw temporary connection line
     */
    drawTempConnection(e) {
        if (!this.connectingFrom) return;
        
        const start = this.getNodeCenter(this.connectingFrom);
        const rect = this.canvas.getBoundingClientRect();
        const endX = (e.clientX - rect.left - this.panX) / this.zoom;
        const endY = (e.clientY - rect.top - this.panY) / this.zoom;
        
        // Remove old temp line
        const oldTemp = this.svg.querySelector('.temp-connection');
        if (oldTemp) oldTemp.remove();
        
        // Draw new temp line
        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', start.x);
        line.setAttribute('y1', start.y);
        line.setAttribute('x2', endX);
        line.setAttribute('y2', endY);
        line.setAttribute('class', 'temp-connection');
        this.svg.appendChild(line);
    }

    /**
     * Finish creating connection
     */
    finishConnection(e) {
        // Remove temp line
        const tempLine = this.svg.querySelector('.temp-connection');
        if (tempLine) tempLine.remove();
        
        // Find target node
        const target = e.target.closest('.graph-node');
        if (target && target.dataset.passageId !== this.connectingFrom) {
            const targetId = target.dataset.passageId;
            
            // Add choice to source passage
            const sourcePassage = this.editor.project.passages.find(p => p.id === this.connectingFrom);
            if (sourcePassage) {
                sourcePassage.choices.push({
                    text: `Go to ${target.querySelector('.node-title').textContent}`,
                    target: targetId
                });
                this.render();
            }
        }
        
        this.isConnecting = false;
        this.connectingFrom = null;
        this.canvas.classList.remove('connecting');
    }

    /**
     * Show node context menu
     */
    showNodeMenu(e, passageId) {
        e.stopPropagation();
        this.hideContextMenu();
        
        const menu = document.createElement('div');
        menu.className = 'context-menu';
        menu.style.left = e.clientX + 'px';
        menu.style.top = e.clientY + 'px';
        
        const isStart = passageId === this.editor.project.settings.startPassage;
        
        menu.innerHTML = `
            <div class="context-menu-item" onclick="graph.editNode('${passageId}')">
                ✏️ Edit Passage
            </div>
            <div class="context-menu-item" onclick="graph.addNodeChoice('${passageId}')">
                ➕ Add Choice
            </div>
            <div class="context-menu-divider"></div>
            ${!isStart ? `
                <div class="context-menu-item danger" onclick="graph.deleteNode('${passageId}')">
                    🗑️ Delete Passage
                </div>
            ` : ''}
        `;
        
        document.body.appendChild(menu);
        this.contextMenu = menu;
        
        // Close on click outside
        setTimeout(() => {
            document.addEventListener('click', () => this.hideContextMenu(), { once: true });
        }, 0);
    }

    /**
     * Hide context menu
     */
    hideContextMenu() {
        if (this.contextMenu) {
            this.contextMenu.remove();
            this.contextMenu = null;
        }
    }

    /**
     * Context menu actions
     */
    editNode(passageId) {
        this.editor.selectPassage(passageId);
        this.editor.switchView('list');
    }

    addNodeChoice(passageId) {
        this.editor.selectPassage(passageId);
        this.editor.addChoice();
        this.render();
    }

    deleteNode(passageId) {
        this.editor.currentPassageId = passageId;
        this.editor.deleteCurrentPassage();
        this.render();
    }

    /**
     * Keyboard shortcuts
     */
    onKeyDown(e) {
        // Delete selected nodes
        if ((e.key === 'Delete' || e.key === 'Backspace') && this.selectedNodes.size > 0) {
            e.preventDefault();
            this.selectedNodes.forEach(id => {
                if (id !== this.editor.project.settings.startPassage) {
                    this.editor.currentPassageId = id;
                    this.editor.deleteCurrentPassage();
                }
            });
            this.selectedNodes.clear();
            this.render();
        }
        
        // Deselect all
        if (e.key === 'Escape') {
            this.selectedNodes.clear();
            this.updateNodeSelection();
        }
    }

    /**
     * Layout indicator
     */
    showLayoutIndicator() {
        const indicator = document.getElementById('layoutIndicator');
        if (indicator) {
            indicator.classList.remove('hidden');
        }
    }

    hideLayoutIndicator() {
        const indicator = document.getElementById('layoutIndicator');
        if (indicator) {
            indicator.classList.add('hidden');
        }
    }
}

// Global graph instance
let graph = null;