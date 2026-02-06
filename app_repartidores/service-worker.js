/**
 * Cargo-GO - Service Worker para PWA Repartidores
 * Cache offline y network-first strategy.
 */

const CACHE_NAME = 'cgo-repartidores-v1';
const URLS_TO_CACHE = [
    'index.html',
    'manifest.json'
];

// Install
self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME).then(cache => {
            console.log('[CGO-SW] Cacheando archivos');
            return cache.addAll(URLS_TO_CACHE);
        })
    );
    self.skipWaiting();
});

// Activate - limpiar caches anteriores
self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(names =>
            Promise.all(
                names.filter(name => name !== CACHE_NAME)
                     .map(name => caches.delete(name))
            )
        )
    );
    self.clients.claim();
});

// Fetch - Network first, fallback to cache
self.addEventListener('fetch', event => {
    if (event.request.method !== 'GET') return;

    // API calls: network only, offline fallback
    if (event.request.url.includes('/api/')) {
        event.respondWith(
            fetch(event.request).catch(() =>
                new Response(JSON.stringify({
                    ok: false,
                    error: 'Sin conexion',
                    offline: true
                }), {
                    headers: { 'Content-Type': 'application/json' }
                })
            )
        );
        return;
    }

    // Static files: network first, cache fallback
    event.respondWith(
        fetch(event.request)
            .then(response => {
                const clone = response.clone();
                caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
                return response;
            })
            .catch(() => caches.match(event.request))
    );
});
