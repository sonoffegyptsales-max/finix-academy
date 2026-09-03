export type VideoRow = {
  id: string;
  session_id: number;
  title: string;
  description: string | null;
  url: string;
  source: string;
  position: number;
};

/** Extract a YouTube video id from watch / youtu.be / shorts / embed URLs. */
export function youTubeId(url: string): string | null {
  try {
    const u = new URL(url.trim());
    const host = u.hostname.replace(/^www\./, "");
    if (host === "youtu.be") return u.pathname.slice(1).split("/")[0] || null;
    if (!host.endsWith("youtube.com") && !host.endsWith("youtube-nocookie.com")) return null;
    const v = u.searchParams.get("v");
    if (v) return v;
    const m = /^\/(embed|shorts|live|v)\/([^/?#]+)/.exec(u.pathname);
    return m ? (m[2] ?? null) : null;
  } catch {
    return null;
  }
}

export function embedUrl(url: string): string | null {
  const id = youTubeId(url);
  return id ? `https://www.youtube-nocookie.com/embed/${id}?rel=0` : null;
}

/**
 * Official SONOFF references per session. These are deep links to SONOFF's own
 * public channels/academy — nothing is re-hosted or copied into this app.
 */
export const officialSonoffLinks: Record<
  number,
  { title: string; description: string; url: string }[]
> = {
  1: [
    {
      title: "SONOFF official YouTube channel",
      description: "Product safety notes, wiring guidance and neutral-wire requirements.",
      url: "https://www.youtube.com/@SONOFFSmartHome",
    },
  ],
  2: [
    {
      title: "SONOFF Wi-Fi setup & pairing playlist",
      description: "2.4 GHz pairing, eWeLink onboarding and connectivity troubleshooting.",
      url: "https://www.youtube.com/@SONOFFSmartHome/search?query=wifi%20pairing",
    },
  ],
  3: [
    {
      title: "SONOFF Zigbee / Matter videos",
      description: "ZBBridge-P, Zigbee routers, Matter and Thread device behaviour.",
      url: "https://www.youtube.com/@SONOFFSmartHome/search?query=zigbee%20matter",
    },
  ],
  4: [
    {
      title: "SONOFF device product videos",
      description: "MINIR4/R4M, Detach Relay Mode, DUALR3 motor mode, 4CH Pro.",
      url: "https://www.youtube.com/@SONOFFSmartHome/search?query=MINIR4%20DUALR3",
    },
  ],
  5: [
    {
      title: "SONOFF DIN-rail & panel devices",
      description: "DIN-rail mounting, POWCT / POW metering and panel integration.",
      url: "https://www.youtube.com/@SONOFFSmartHome/search?query=din%20rail%20panel",
    },
  ],
  6: [
    {
      title: "SONOFF access control & sensors",
      description: "Door locks, NFC tags, contact sensors and door-strike wiring.",
      url: "https://www.youtube.com/@SONOFFSmartHome/search?query=door%20lock%20access",
    },
  ],
  7: [
    {
      title: "SONOFF + Home Assistant integration",
      description: "iHost, LAN mode, MQTT and third-party platform integration.",
      url: "https://www.youtube.com/@SONOFFSmartHome/search?query=home%20assistant",
    },
  ],
  8: [
    {
      title: "SONOFF Academy course catalogue",
      description:
        "Official certification courses — trainees enrol with their own SONOFF Academy account.",
      url: "https://academy.sonoff.tech/courses",
    },
  ],
};
