/**
 * Client-side branding helpers.
 *
 * An admin uploads ONE master image; the browser renders every required size
 * from it with a canvas before anything is sent. That keeps the server free of
 * an image-processing dependency and means the admin never has to prepare
 * seven separate files by hand.
 */

import { useEffect, useState } from "react";

export type RenderedAsset = {
  slot: string;
  content: string; // base64, no data: prefix
  contentType: string;
};

/** Read a File into an HTMLImageElement. */
function loadImage(file: File): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const url = URL.createObjectURL(file);
    const img = new Image();
    img.onload = () => {
      URL.revokeObjectURL(url);
      resolve(img);
    };
    img.onerror = () => {
      URL.revokeObjectURL(url);
      reject(new Error("Could not read that image file."));
    };
    img.src = url;
  });
}

/** Trim uniform border padding so a logo on a big white field crops tight. */
function trimCanvas(canvas: HTMLCanvasElement): HTMLCanvasElement {
  const ctx = canvas.getContext("2d");
  if (!ctx) return canvas;
  const { width, height } = canvas;
  const data = ctx.getImageData(0, 0, width, height).data;

  let top = height,
    left = width,
    right = 0,
    bottom = 0;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const i = (y * width + x) * 4;
      const a = data[i + 3];
      const r = data[i],
        g = data[i + 1],
        b = data[i + 2];
      // "ink" = not transparent and not near-white
      const isInk = a > 12 && !(r > 235 && g > 235 && b > 235);
      if (isInk) {
        if (x < left) left = x;
        if (x > right) right = x;
        if (y < top) top = y;
        if (y > bottom) bottom = y;
      }
    }
  }
  if (right <= left || bottom <= top) return canvas;

  const out = document.createElement("canvas");
  out.width = right - left + 1;
  out.height = bottom - top + 1;
  out.getContext("2d")!.drawImage(
    canvas,
    left,
    top,
    out.width,
    out.height,
    0,
    0,
    out.width,
    out.height,
  );
  return out;
}

/** Draw a File to a canvas, optionally making near-white pixels transparent. */
async function toCanvas(file: File, makeTransparent: boolean) {
  const img = await loadImage(file);
  const c = document.createElement("canvas");
  c.width = img.naturalWidth;
  c.height = img.naturalHeight;
  const ctx = c.getContext("2d")!;
  ctx.drawImage(img, 0, 0);

  if (makeTransparent) {
    const id = ctx.getImageData(0, 0, c.width, c.height);
    const d = id.data;
    for (let i = 0; i < d.length; i += 4) {
      if (d[i] > 235 && d[i + 1] > 235 && d[i + 2] > 235) d[i + 3] = 0;
    }
    ctx.putImageData(id, 0, 0);
  }
  return trimCanvas(c);
}

/** Centre a source canvas on a square with proportional padding. */
function square(
  src: HTMLCanvasElement,
  size: number,
  padRatio: number,
  bg?: string,
): HTMLCanvasElement {
  const c = document.createElement("canvas");
  c.width = size;
  c.height = size;
  const ctx = c.getContext("2d")!;
  if (bg) {
    ctx.fillStyle = bg;
    ctx.fillRect(0, 0, size, size);
  }
  const inner = size * (1 - 2 * padRatio);
  const scale = Math.min(inner / src.width, inner / src.height);
  const w = src.width * scale;
  const h = src.height * scale;
  ctx.imageSmoothingQuality = "high";
  ctx.drawImage(src, (size - w) / 2, (size - h) / 2, w, h);
  return c;
}

function canvasToBase64(c: HTMLCanvasElement, type = "image/png"): string {
  const url = c.toDataURL(type);
  return url.slice(url.indexOf(",") + 1);
}

/** White-recoloured copy, for dark backgrounds. */
function recolourWhite(src: HTMLCanvasElement): HTMLCanvasElement {
  const c = document.createElement("canvas");
  c.width = src.width;
  c.height = src.height;
  const ctx = c.getContext("2d")!;
  ctx.drawImage(src, 0, 0);
  const id = ctx.getImageData(0, 0, c.width, c.height);
  const d = id.data;
  for (let i = 0; i < d.length; i += 4) {
    if (d[i + 3] > 0) {
      d[i] = 255;
      d[i + 1] = 255;
      d[i + 2] = 255;
    }
  }
  ctx.putImageData(id, 0, 0);
  return c;
}

/**
 * Build the full logo set from one wide wordmark file.
 * Produces the dark logo and its white variant.
 */
export async function renderLogoSet(file: File): Promise<RenderedAsset[]> {
  const base = await toCanvas(file, true);
  return [
    { slot: "logo", content: canvasToBase64(base), contentType: "image/png" },
    {
      slot: "logoLight",
      content: canvasToBase64(recolourWhite(base)),
      contentType: "image/png",
    },
  ];
}

/**
 * Build favicon + PWA icons from one square-ish file.
 *
 * The maskable and Apple icons get an opaque white plate: Android crops into
 * a maskable icon's safe zone, and iOS ignores transparency entirely (a
 * transparent PNG turns black on the home screen).
 */
export async function renderIconSet(file: File): Promise<RenderedAsset[]> {
  const base = await toCanvas(file, true);
  return [
    {
      slot: "icon192",
      content: canvasToBase64(square(base, 192, 0.1)),
      contentType: "image/png",
    },
    {
      slot: "icon512",
      content: canvasToBase64(square(base, 512, 0.1)),
      contentType: "image/png",
    },
    {
      slot: "iconMaskable",
      content: canvasToBase64(square(base, 512, 0.22, "#ffffff")),
      contentType: "image/png",
    },
    {
      slot: "appleTouch",
      content: canvasToBase64(square(base, 180, 0.12, "#ffffff")),
      contentType: "image/png",
    },
    // Browsers accept a PNG served as the favicon; a 64px PNG is sharper on
    // modern high-DPI tabs than a legacy 16px .ico frame.
    {
      slot: "favicon",
      content: canvasToBase64(square(base, 64, 0.06)),
      contentType: "image/png",
    },
  ];
}

/** Public branding URLs, versioned so a replaced asset appears immediately. */
export type Branding = {
  version: number;
  logo: string;
  logoLight: string;
  favicon: string;
  icon192: string;
  icon512: string;
  iconMaskable: string;
  appleTouch: string;
};

const SUPABASE_URL = import.meta.env["VITE_SUPABASE_URL"] as string | undefined;

function fallbackBranding(version = 0): Branding {
  const q = version ? `?v=${version}` : "";
  const base = SUPABASE_URL
    ? `${SUPABASE_URL}/storage/v1/object/public/branding`
    : "";
  if (!base) {
    // No backend configured — use the files shipped in /public.
    return {
      version: 0,
      logo: "/logo.png",
      logoLight: "/logo-light.png",
      favicon: "/favicon.ico",
      icon192: "/icons/icon-192.png",
      icon512: "/icons/icon-512.png",
      iconMaskable: "/icons/icon-maskable-512.png",
      appleTouch: "/icons/apple-touch-icon.png",
    };
  }
  return {
    version,
    logo: `${base}/logo.png${q}`,
    logoLight: `${base}/logo-light.png${q}`,
    favicon: `${base}/favicon.ico${q}`,
    icon192: `${base}/icon-192.png${q}`,
    icon512: `${base}/icon-512.png${q}`,
    iconMaskable: `${base}/icon-maskable-512.png${q}`,
    appleTouch: `${base}/apple-touch-icon.png${q}`,
  };
}

/**
 * Read current branding. Fetches the version stamp directly from the public
 * bucket rather than going through a server function, so it works on the
 * signed-out landing page with no auth round trip.
 */
export function useBranding(): Branding {
  const [branding, setBranding] = useState<Branding>(() => fallbackBranding());

  useEffect(() => {
    if (!SUPABASE_URL) return;
    let cancelled = false;
    const url = `${SUPABASE_URL}/storage/v1/object/public/branding/settings.json`;
    fetch(url, { cache: "no-cache" })
      .then((r) => (r.ok ? r.json() : null))
      .then((j) => {
        if (cancelled || !j) return;
        const v = Number(j.version) || 0;
        if (v) setBranding(fallbackBranding(v));
      })
      .catch(() => {
        /* keep fallback */
      });
    return () => {
      cancelled = true;
    };
  }, []);

  return branding;
}
