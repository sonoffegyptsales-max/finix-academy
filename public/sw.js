/* Finix Academy service worker.
 *
 * Handles Web Push notifications and claims clients immediately so an
 * installed PWA updates without needing every tab closed first.
 *
 * Lesson material is deliberately NOT cached: media is served from
 * short-lived signed URLs and the content is licensed per-account, so
 * caching it offline would both break (expired URLs) and undermine the
 * device-lock model.
 */

self.addEventListener("install", () => {
  // Activate the new worker right away instead of waiting for every tab.
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener("push", (event) => {
  let data = {};
  try {
    data = event.data ? event.data.json() : {};
  } catch (_e) {
    data = { title: "Finix Academy", body: event.data ? event.data.text() : "" };
  }

  const title = data.title || "Finix Academy";
  const options = {
    body: data.body || "",
    icon: "/icons/icon-192.png",
    badge: "/icons/icon-192.png",
    dir: "auto",
    data: { url: data.url || "/dashboard" },
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const targetUrl = (event.notification.data && event.notification.data.url) || "/dashboard";

  event.waitUntil(
    self.clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url.includes(targetUrl) && "focus" in client) {
          return client.focus();
        }
      }
      if (self.clients.openWindow) {
        return self.clients.openWindow(targetUrl);
      }
    }),
  );
});
