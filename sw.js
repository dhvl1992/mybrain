// Service worker: makes the app installable and opens it even with weak network.
// Strategy: network first (so you always get the latest version), cache as backup.
// Only same-origin files are cached. Supabase and Gemini calls are never cached.
const CACHE = "mybrain-v20";
const SHELL = ["./", "./index.html", "./icons/icon-192.png", "./icons/icon-512.png", "./vendor/supabase.js"];
// Shared hub files (top bar, app list, install file). Network first like everything here, so hub changes arrive at once.
const SHARED = ["/topbar.js", "/apps.js", "/manifest.json"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL).then(() => c.addAll(SHARED).catch(() => {}))));
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))));
  self.clients.claim();
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  if (e.request.method !== "GET" || url.origin !== location.origin) return; // let network handle it
  e.respondWith(
    fetch(e.request)
      .then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(e.request, copy));
        return res;
      })
      .catch(() => caches.match(e.request).then((r) => r || caches.match("./index.html")))
  );
});
