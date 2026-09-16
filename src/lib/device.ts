/**
 * Per-device identity.
 *
 * A random id is generated once per browser profile and kept in localStorage.
 * It is sent on every Supabase request as `x-device-id`, and the database
 * binds a trainee account to the first device id it ever sees.
 *
 * This is a deterrent against casual credential sharing, not a hardware
 * fingerprint: clearing site data or using another browser profile produces a
 * new id, which is exactly why an admin must reset the binding for a genuine
 * device change.
 */

const STORAGE_KEY = "finix.device.id";

function randomId(): string {
  if (typeof crypto !== "undefined" && typeof crypto.randomUUID === "function") {
    return crypto.randomUUID();
  }
  // Fallback for older browsers.
  return `dev-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 12)}`;
}

/**
 * Stable id for this browser. Returns "" during SSR (no localStorage), which
 * is correct: server-rendered requests carry no device claim.
 */
export function getDeviceId(): string {
  if (typeof window === "undefined") return "";
  try {
    let id = window.localStorage.getItem(STORAGE_KEY);
    if (!id) {
      id = randomId();
      window.localStorage.setItem(STORAGE_KEY, id);
    }
    return id;
  } catch {
    // localStorage blocked (private mode / strict settings).
    return "";
  }
}

/** Short human-readable label for the device list in the admin panel. */
export function describeDevice(): string {
  if (typeof navigator === "undefined") return "Unknown device";
  const ua = navigator.userAgent;
  const platform =
    /Android/i.test(ua) ? "Android" :
    /iPhone|iPad|iPod/i.test(ua) ? "iOS" :
    /Windows/i.test(ua) ? "Windows" :
    /Macintosh|Mac OS/i.test(ua) ? "macOS" :
    /Linux/i.test(ua) ? "Linux" : "Unknown";
  const browser =
    /Edg\//i.test(ua) ? "Edge" :
    /OPR\//i.test(ua) ? "Opera" :
    /Chrome\//i.test(ua) ? "Chrome" :
    /Safari\//i.test(ua) ? "Safari" :
    /Firefox\//i.test(ua) ? "Firefox" : "Browser";
  return `${platform} · ${browser}`;
}
