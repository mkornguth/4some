// service-worker.js at site root
const VERSION = 'v1.0.0';            // bump on deploy
const STATIC_CACHE = `static-${VERSION}`;
const OFFLINE_URL = '/index.cfm';    // your HTML entry

// Precache critical shell assets
self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(STATIC_CACHE);
    await cache.addAll([
      OFFLINE_URL,
      '/assets/css/main.css',
      '/assets/img/brand.png',
    ]);
    // activate immediately on first load
    self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    // Clean up old caches
    const keys = await caches.keys();
    await Promise.all(
      keys
        .filter(k => k.startsWith('static-') && k !== STATIC_CACHE)
        .map(k => caches.delete(k))
    );
    // control client pages without reload
    await self.clients.claim();
  })());
});

// Optional: speed up first byte for navigations on Chrome
self.addEventListener('activate', () => {
  if ('navigationPreload' in self.registration) {
    self.registration.navigationPreload.enable();
  }
});

self.addEventListener('fetch', event => {
  const req = event.request;

  // Only handle GET
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  const isSameOrigin = url.origin === self.location.origin;
  const isHTMLNav = req.mode === 'navigate' || 
                    (req.destination === 'document');

  // Strategy 1: Network-first for HTML navigations (avoid stale app shell)
  if (isHTMLNav && isSameOrigin) {
    event.respondWith((async () => {
      try {
        // Try preload if available, else fetch
        const preload = await event.preloadResponse;
        const netResp = preload || await fetch(req, { cache: 'no-store' });
        // Optionally, update offline fallback if 200
        if (netResp.ok) {
          const cache = await caches.open(STATIC_CACHE);
          cache.put(OFFLINE_URL, netResp.clone());
        }
        return netResp;
      } catch {
        // Offline fallback
        const cache = await caches.open(STATIC_CACHE);
        return (await cache.match(OFFLINE_URL)) || new Response('Offline', { status: 503 });
      }
    })());
    return;
  }

  // Strategy 2: Cache-first for same-origin static assets (css/js/img/fonts)
  if (isSameOrigin && ['style','script','image','font'].includes(req.destination)) {
    event.respondWith((async () => {
      const cache = await caches.open(STATIC_CACHE);
      const cached = await cache.match(req);
      if (cached) return cached;
      try {
        const resp = await fetch(req);
        if (resp.ok) cache.put(req, resp.clone());
        return resp;
      } catch {
        return cached || Response.error();
      }
    })());
    return;
  }

  // Passthrough for everything else (analytics, CORS APIs, etc.)
});
