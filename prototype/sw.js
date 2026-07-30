/* Service worker do protótipo.
 *
 * Estratégia: network-first com cache de fallback. O contrário — cache-first —
 * é o que faz um protótipo publicado continuar mostrando a versão de ontem
 * depois de um deploy, e é a queixa mais chata de depurar num Pages.
 */
"use strict";

const CACHE = "vidora-proto-v1";
const ASSETS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./icon-192.png",
  "./icon-512.png",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting()),
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)),
      ))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener("fetch", (event) => {
  const request = event.request;
  // Só GET é cacheável; qualquer outro método passa direto.
  if (request.method !== "GET") return;

  event.respondWith(
    fetch(request)
      .then((response) => {
        // Uma cópia, porque o corpo só pode ser lido uma vez.
        const copy = response.clone();
        caches.open(CACHE).then((c) => c.put(request, copy)).catch(() => {});
        return response;
      })
      .catch(() => caches.match(request).then((hit) => hit
        || caches.match("./index.html"))),
  );
});
