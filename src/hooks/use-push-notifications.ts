import { useCallback, useEffect, useState } from "react";
import { savePushSubscription, removePushSubscription } from "@/lib/push.functions";

const VAPID_PUBLIC = import.meta.env["VITE_VAPID_PUBLIC_KEY"] as string | undefined;

function urlBase64ToUint8Array(base64String: string): Uint8Array {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");
  const raw = atob(base64);
  const output = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i += 1) output[i] = raw.charCodeAt(i);
  return output;
}

type PushStatus = "unsupported" | "default" | "granted" | "denied" | "subscribed";

export function usePushNotifications() {
  const [status, setStatus] = useState<PushStatus>("default");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const supported =
    typeof window !== "undefined" &&
    "serviceWorker" in navigator &&
    "PushManager" in window &&
    "Notification" in window;

  useEffect(() => {
    if (!supported) {
      setStatus("unsupported");
      return;
    }
    void (async () => {
      try {
        const reg = await navigator.serviceWorker.getRegistration();
        const sub = await reg?.pushManager.getSubscription();
        if (sub) setStatus("subscribed");
        else setStatus(Notification.permission as PushStatus);
      } catch {
        setStatus(Notification.permission as PushStatus);
      }
    })();
  }, [supported]);

  const subscribe = useCallback(async () => {
    if (!supported) return;
    if (!VAPID_PUBLIC) {
      setError("Push not configured (missing VAPID public key).");
      return;
    }
    setBusy(true);
    setError(null);
    try {
      const permission = await Notification.requestPermission();
      if (permission !== "granted") {
        setStatus(permission as PushStatus);
        return;
      }
      const reg =
        (await navigator.serviceWorker.getRegistration()) ||
        (await navigator.serviceWorker.register("/sw.js"));
      await navigator.serviceWorker.ready;

      const sub = await reg.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC),
      });

      const json = sub.toJSON();
      await savePushSubscription({
        data: {
          endpoint: sub.endpoint,
          p256dh: json.keys?.p256dh ?? "",
          auth: json.keys?.auth ?? "",
        },
      });
      setStatus("subscribed");
    } catch (e: any) {
      setError(e?.message ?? "Failed to enable notifications.");
    } finally {
      setBusy(false);
    }
  }, [supported]);

  const unsubscribe = useCallback(async () => {
    if (!supported) return;
    setBusy(true);
    setError(null);
    try {
      const reg = await navigator.serviceWorker.getRegistration();
      const sub = await reg?.pushManager.getSubscription();
      if (sub) {
        await removePushSubscription({ data: { endpoint: sub.endpoint } });
        await sub.unsubscribe();
      }
      setStatus("granted");
    } catch (e: any) {
      setError(e?.message ?? "Failed to disable notifications.");
    } finally {
      setBusy(false);
    }
  }, [supported]);

  return { status, busy, error, supported, subscribe, unsubscribe };
}
