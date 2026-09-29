// Push reminders + a small offline layer. Progress is never cached: /api and /content always hit the server.
const CACHE = "rcx-v4";
const PRECACHE = [
  "/offline.html",
  "/icon-96.png",
  "/icon-192.png",
  "/avatar.svg",
  "/manifest.webmanifest",
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(PRECACHE)));
  self.skipWaiting();
});

self.addEventListener("activate", (e) =>
  e.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)),
        ),
      )
      .then(() => self.clients.claim()),
  ),
);

self.addEventListener("fetch", (e) => {
  const req = e.request;
  const url = new URL(req.url);
  if (req.method !== "GET" || url.origin !== self.location.origin) return;
  if (url.pathname.startsWith("/api/") || url.pathname.startsWith("/content/"))
    return;

  // pages: always fresh from the server; if it isn't running, explain instead of a browser error
  if (req.mode === "navigate") {
    e.respondWith(fetch(req).catch(() => caches.match("/offline.html")));
    return;
  }
  // hashed build assets never change: cache-first, filled as they're used
  if (url.pathname.startsWith("/assets/")) {
    e.respondWith(
      caches.match(req).then(
        (hit) =>
          hit ||
          fetch(req).then((res) => {
            if (res.ok) {
              const copy = res.clone();
              caches.open(CACHE).then((c) => c.put(req, copy));
            }
            return res;
          }),
      ),
    );
    return;
  }
  // everything else (icons, manifest): network, falling back to the precache
  e.respondWith(fetch(req).catch(() => caches.match(req)));
});

self.addEventListener("push", (e) => {
  const msg = e.data ? e.data.json() : {};
  e.waitUntil(
    self.registration.showNotification(msg.title || "Recurse", {
      body: msg.body || "",
      icon: "/icon-192.png",
      badge: "/icon-96.png",
      tag: "reminder", // a new nudge replaces the old one instead of stacking
      data: { url: msg.url || "/" },
      actions: [
        { action: "start", title: "Start now" },
        { action: "snooze", title: "Snooze 1 hr" },
      ],
    }),
  );
});

self.addEventListener("notificationclick", (e) => {
  e.notification.close();
  if (e.action === "snooze") {
    e.waitUntil(fetch("/api/notify/snooze", { method: "POST" }));
    return;
  }
  const url = e.notification.data?.url || "/";
  e.waitUntil(
    self.clients.matchAll({ type: "window" }).then((wins) => {
      const w = wins[0];
      return w
        ? w.navigate(url).then((c) => c && c.focus())
        : self.clients.openWindow(url);
    }),
  );
});
