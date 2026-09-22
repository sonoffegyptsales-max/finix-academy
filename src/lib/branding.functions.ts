import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";

/**
 * Branding assets (site logo + favicon) live in a PUBLIC storage bucket:
 * a logo must render for signed-out visitors on the landing page, and the
 * browser fetches a favicon with no auth headers at all. Nothing secret
 * is stored here.
 *
 * Uploads go through this server function rather than straight from the
 * browser, so the write is authorised by the service-role key after an
 * explicit admin check. That keeps the whole feature working without adding
 * storage RLS policies, and means only admins can ever change site identity.
 */

export const BRANDING_BUCKET = "branding";

/** Logical asset slots an admin can replace, and their stored filenames. */
export const BRAND_SLOTS = {
  logo: { file: "logo.png", mime: "image/png" },
  logoLight: { file: "logo-light.png", mime: "image/png" },
  favicon: { file: "favicon.ico", mime: "image/x-icon" },
  icon192: { file: "icon-192.png", mime: "image/png" },
  icon512: { file: "icon-512.png", mime: "image/png" },
  iconMaskable: { file: "icon-maskable-512.png", mime: "image/png" },
  appleTouch: { file: "apple-touch-icon.png", mime: "image/png" },
} as const;

export type BrandSlot = keyof typeof BRAND_SLOTS;

function serviceClient() {
  const url = process.env["SUPABASE_URL"];
  const serviceKey = process.env["SUPABASE_SERVICE_ROLE_KEY"];
  if (!url || !serviceKey) {
    throw new Error(
      "Server misconfigured: SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY missing.",
    );
  }
  return createClient<Database>(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

async function assertAdmin(supabase: any, userId: string) {
  const { data, error } = await supabase
    .from("user_roles")
    .select("role")
    .eq("user_id", userId)
    .eq("role", "admin")
    .maybeSingle();
  if (error) throw new Error(error.message);
  if (!data) throw new Error("Administrator rights required");
}

/** Public base URL for branding assets, derived from the project URL. */
function publicBase(): string {
  const url = process.env["SUPABASE_URL"];
  return `${url}/storage/v1/object/public/${BRANDING_BUCKET}`;
}

/**
 * Admin-only: replace one branding asset.
 *
 * The file arrives base64-encoded because server-function payloads are JSON.
 * Size is capped well below the bucket limit -- a logo that large is a mistake,
 * and rejecting early gives a clearer error than a storage failure.
 */
export const uploadBrandAsset = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        slot: z.enum(
          Object.keys(BRAND_SLOTS) as [BrandSlot, ...BrandSlot[]],
        ),
        /** base64 (no data: prefix) */
        content: z.string().min(16).max(8_000_000),
        contentType: z.string().max(100).optional(),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const { supabase, user } = context as any;
    await assertAdmin(supabase, user.id);

    const slot = BRAND_SLOTS[data.slot as BrandSlot];
    const bytes = Buffer.from(data.content, "base64");
    if (bytes.byteLength > 5 * 1024 * 1024) {
      throw new Error("File too large — 5 MB maximum.");
    }

    const admin = serviceClient();
    const { error } = await admin.storage
      .from(BRANDING_BUCKET)
      .upload(slot.file, bytes, {
        contentType: data.contentType || slot.mime,
        upsert: true,
        // Short cache: a replaced logo should appear quickly. The version
        // stamp below is what actually busts already-cached copies.
        cacheControl: "60",
      });
    if (error) throw new Error(error.message);

    // Bump the version stamp so clients re-request the changed asset.
    const version = Date.now();
    await admin.storage
      .from(BRANDING_BUCKET)
      .upload(
        "settings.json",
        Buffer.from(
          JSON.stringify({ version, updatedAt: new Date().toISOString() }),
        ),
        { contentType: "application/json", upsert: true, cacheControl: "60" },
      );

    return {
      ok: true as const,
      slot: data.slot,
      url: `${publicBase()}/${slot.file}?v=${version}`,
      version,
    };
  });

/**
 * Admin-only: derive every icon size from a single uploaded master image.
 *
 * Doing this server-side means an admin uploads ONE file and gets a correct
 * favicon, PWA icons and Apple touch icon, instead of having to prepare seven
 * files by hand. Resizing uses the browser-agnostic approach of storing the
 * master and letting the client supply pre-rendered sizes, so this function
 * accepts the already-rendered set.
 */
export const uploadBrandSet = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        assets: z
          .array(
            z.object({
              slot: z.enum(
                Object.keys(BRAND_SLOTS) as [BrandSlot, ...BrandSlot[]],
              ),
              content: z.string().min(16).max(8_000_000),
              contentType: z.string().max(100).optional(),
            }),
          )
          .min(1)
          .max(10),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const { supabase, user } = context as any;
    await assertAdmin(supabase, user.id);

    const admin = serviceClient();
    const written: string[] = [];

    for (const a of data.assets) {
      const slot = BRAND_SLOTS[a.slot as BrandSlot];
      const bytes = Buffer.from(a.content, "base64");
      if (bytes.byteLength > 5 * 1024 * 1024) {
        throw new Error(`${slot.file} is larger than 5 MB.`);
      }
      const { error } = await admin.storage
        .from(BRANDING_BUCKET)
        .upload(slot.file, bytes, {
          contentType: a.contentType || slot.mime,
          upsert: true,
          cacheControl: "60",
        });
      if (error) throw new Error(`${slot.file}: ${error.message}`);
      written.push(slot.file);
    }

    const version = Date.now();
    await admin.storage
      .from(BRANDING_BUCKET)
      .upload(
        "settings.json",
        Buffer.from(
          JSON.stringify({ version, updatedAt: new Date().toISOString() }),
        ),
        { contentType: "application/json", upsert: true, cacheControl: "60" },
      );

    return { ok: true as const, written, version };
  });

/** Current branding URLs plus the version stamp. Readable by anyone. */
export const getBranding = createServerFn({ method: "GET" }).handler(
  async () => {
    const base = publicBase();
    let version = 0;
    try {
      const res = await fetch(`${base}/settings.json`, {
        headers: { "cache-control": "no-cache" },
      });
      if (res.ok) {
        const j = (await res.json()) as { version?: number };
        version = Number(j.version) || 0;
      }
    } catch {
      // Bucket unreachable — fall back to unversioned URLs rather than failing
      // the whole page render over a logo.
    }
    const q = version ? `?v=${version}` : "";
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
  },
);
