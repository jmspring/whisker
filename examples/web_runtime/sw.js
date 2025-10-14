/**
 * Service Worker for Museum Tours
 * Provides offline-first functionality for museum tours
 * Caches app shell, stories, and assets for offline access
 */

const CACHE_NAME = 'whisker-museum-v1';
const RUNTIME_CACHE = 'whisker-runtime-v1';

// App shell - core files needed to run the app
const APP_SHELL = [
    '/examples/web_runtime/museum.html',
    '/examples/web_runtime/museum.css',
    '/examples/web_runtime/museum-client.js',
    '/examples/web_runtime/manifest.json'
];

// Install event - cache app shell
self.addEventListener('install', (event) => {
    console.log('[SW] Installing service worker...');

    event.waitUntil(
        caches.open(CACHE_NAME)
            .then((cache) => {
                console.log('[SW] Caching app shell');
                return cache.addAll(APP_SHELL);
            })
            .then(() => {
                console.log('[SW] App shell cached');
                return self.skipWaiting(); // Activate immediately
            })
            .catch((error) => {
                console.error('[SW] Failed to cache app shell:', error);
            })
    );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
    console.log('[SW] Activating service worker...');

    event.waitUntil(
        caches.keys()
            .then((cacheNames) => {
                return Promise.all(
                    cacheNames
                        .filter((cacheName) => {
                            // Delete old caches
                            return cacheName !== CACHE_NAME && cacheName !== RUNTIME_CACHE;
                        })
                        .map((cacheName) => {
                            console.log('[SW] Deleting old cache:', cacheName);
                            return caches.delete(cacheName);
                        })
                );
            })
            .then(() => {
                console.log('[SW] Service worker activated');
                return self.clients.claim(); // Take control immediately
            })
    );
});

// Fetch event - serve from cache, fallback to network
self.addEventListener('fetch', (event) => {
    const url = new URL(event.request.url);

    // Skip cross-origin requests
    if (url.origin !== location.origin) {
        return;
    }

    // Different strategies for different types of requests
    event.respondWith(handleFetch(event.request));
});

async function handleFetch(request) {
    const url = new URL(request.url);
    const pathname = url.pathname;

    // Strategy 1: App Shell (Cache-first)
    // HTML, CSS, JS - always prefer cache for performance
    if (isAppShell(pathname)) {
        return cacheFirst(request);
    }

    // Strategy 2: Stories (.whisker files) - Network-first with cache fallback
    // Always try to get latest story, but work offline
    if (pathname.endsWith('.whisker') || pathname.endsWith('.json')) {
        return networkFirst(request);
    }

    // Strategy 3: Images - Cache-first
    // Images don't change, cache aggressively
    if (isImage(pathname)) {
        return cacheFirst(request);
    }

    // Strategy 4: Audio - Network-only (too large to cache aggressively)
    // Audio files are large, only cache if explicitly requested
    if (isAudio(pathname)) {
        return networkOnly(request);
    }

    // Default: Network-first
    return networkFirst(request);
}

// Cache-first strategy: Serve from cache, fallback to network
async function cacheFirst(request) {
    const cache = await caches.open(CACHE_NAME);
    const cached = await cache.match(request);

    if (cached) {
        console.log('[SW] Serving from cache:', request.url);
        return cached;
    }

    console.log('[SW] Cache miss, fetching:', request.url);

    try {
        const response = await fetch(request);

        // Cache successful responses
        if (response && response.status === 200) {
            cache.put(request, response.clone());
        }

        return response;
    } catch (error) {
        console.error('[SW] Fetch failed:', error);

        // Return offline page if available
        return new Response('Offline - resource not cached', {
            status: 503,
            statusText: 'Service Unavailable',
            headers: new Headers({
                'Content-Type': 'text/plain'
            })
        });
    }
}

// Network-first strategy: Try network, fallback to cache
async function networkFirst(request) {
    const cache = await caches.open(RUNTIME_CACHE);

    try {
        console.log('[SW] Fetching from network:', request.url);
        const response = await fetch(request);

        // Cache successful responses
        if (response && response.status === 200) {
            cache.put(request, response.clone());
        }

        return response;
    } catch (error) {
        console.log('[SW] Network failed, trying cache:', request.url);

        const cached = await cache.match(request);

        if (cached) {
            return cached;
        }

        console.error('[SW] Not in cache either:', error);

        return new Response('Offline - resource not available', {
            status: 503,
            statusText: 'Service Unavailable',
            headers: new Headers({
                'Content-Type': 'text/plain'
            })
        });
    }
}

// Network-only strategy: Always fetch from network
async function networkOnly(request) {
    try {
        return await fetch(request);
    } catch (error) {
        console.error('[SW] Network-only fetch failed:', error);

        return new Response('Offline - network required', {
            status: 503,
            statusText: 'Service Unavailable',
            headers: new Headers({
                'Content-Type': 'text/plain'
            })
        });
    }
}

// Helper: Check if request is part of app shell
function isAppShell(pathname) {
    return APP_SHELL.some(path => pathname.includes(path)) ||
           pathname.endsWith('.html') ||
           pathname.endsWith('.css') ||
           pathname.endsWith('.js');
}

// Helper: Check if request is for an image
function isImage(pathname) {
    return pathname.match(/\.(jpg|jpeg|png|gif|svg|webp)$/i);
}

// Helper: Check if request is for audio
function isAudio(pathname) {
    return pathname.match(/\.(mp3|wav|ogg|m4a|aac)$/i);
}

// Message handler for cache management
self.addEventListener('message', (event) => {
    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }

    if (event.data && event.data.type === 'CACHE_URLS') {
        const urls = event.data.urls;
        caches.open(RUNTIME_CACHE)
            .then(cache => cache.addAll(urls))
            .then(() => {
                event.ports[0].postMessage({ success: true });
            })
            .catch(error => {
                event.ports[0].postMessage({ success: false, error: error.message });
            });
    }

    if (event.data && event.data.type === 'CLEAR_CACHE') {
        caches.keys()
            .then(cacheNames => Promise.all(cacheNames.map(cache => caches.delete(cache))))
            .then(() => {
                event.ports[0].postMessage({ success: true });
            })
            .catch(error => {
                event.ports[0].postMessage({ success: false, error: error.message });
            });
    }
});

// Background sync for analytics (future enhancement)
self.addEventListener('sync', (event) => {
    if (event.tag === 'sync-analytics') {
        console.log('[SW] Background sync: analytics');
        // Would sync analytics data here
    }
});

console.log('[SW] Service worker loaded');
