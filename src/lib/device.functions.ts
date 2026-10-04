import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";

/** Build an admin (service-role) Supabase client for privileged operations. */
function serviceClient() {
  const url = process.env["SUPABASE_URL"];
  const serviceKey = process.env["SUPABASE_SERVICE_ROLE_KEY"];
  if (!url || !serviceKey) {
    throw new Error("Server misconfigured: Supabase service credentials missing.");
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

async function isStaff(admin: any, userId: string): Promise<boolean> {
  const { data } = await admin
    .from("user_roles")
    .select("role")
    .eq("user_id", userId)
    .in("role", ["admin", "trainer"]);
  return (data ?? []).length > 0;
}

/** How many devices one trainee account may use. Mirrors max_trainee_devices() in SQL. */
export const MAX_DEVICES = 2;

/**
 * Called by the trainee's browser right after sign-in.
 *
 * - Device already registered for this account -> refresh last_seen, { status: "ok" }.
 * - New device and a free slot (fewer than 2)   -> register it, { status: "bound" }.
 * - New device and both slots taken             -> { status: "blocked" } with the
 *   labels of the registered devices so the trainee knows where to sign in.
 *
 * The 2-device limit is ALSO enforced by a database trigger, so two new
 * devices signing in at the same instant cannot both slip through.
 * Staff (admin/trainer) are never device-locked.
 */
export const claimDevice = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        deviceId: z.string().min(8).max(200),
        label: z.string().max(120).optional(),
        userAgent: z.string().max(400).optional(),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const admin = serviceClient();

    if (await isStaff(admin, context.userId)) {
      return { status: "staff" as const };
    }

    const { data: active, error: readErr } = await admin
      .from("trainee_devices")
      .select("id, device_id, device_label, bound_at")
      .eq("user_id", context.userId)
      .is("revoked_at", null)
      .order("bound_at", { ascending: true });
    if (readErr) throw new Error(readErr.message);

    const mine = (active ?? []).find((d) => d.device_id === data.deviceId);
    if (mine) {
      await admin
        .from("trainee_devices")
        .update({ last_seen_at: new Date().toISOString() })
        .eq("id", mine.id);
      return { status: "ok" as const, used: (active ?? []).length, max: MAX_DEVICES };
    }

    const blocked = () => ({
      status: "blocked" as const,
      max: MAX_DEVICES,
      devices: (active ?? []).map((d) => d.device_label ?? "Unknown device"),
      boundLabel: (active ?? []).map((d) => d.device_label ?? "Unknown device").join(" + "),
    });

    if ((active ?? []).length >= MAX_DEVICES) return blocked();

    const { error: insErr } = await admin.from("trainee_devices").insert({
      user_id: context.userId,
      device_id: data.deviceId,
      device_label: data.label ?? null,
      user_agent: data.userAgent ?? null,
    });
    if (insErr) {
      // Lost a race against another new device: the trigger refused us.
      if (insErr.message.includes("device_limit_reached")) return blocked();
      throw new Error(insErr.message);
    }
    return { status: "bound" as const, used: (active ?? []).length + 1, max: MAX_DEVICES };
  });

/**
 * Admin-only: list every trainee's device binding (for the admin panel).
 */
export const listDeviceBindings = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }) => {
    await assertAdmin(context.supabase, context.userId);
    const admin = serviceClient();

    const { data: rows, error } = await admin
      .from("trainee_devices")
      .select("id, user_id, device_label, user_agent, bound_at, last_seen_at")
      .is("revoked_at", null)
      .order("bound_at", { ascending: false });
    if (error) throw new Error(error.message);

    const ids = (rows ?? []).map((r) => r.user_id);
    if (ids.length === 0) return { bindings: [] };

    const { data: profiles } = await admin
      .from("profiles")
      .select("id, email, full_name")
      .in("id", ids);
    const byId = new Map((profiles ?? []).map((p) => [p.id, p]));

    return {
      bindings: (rows ?? []).map((r) => ({
        id: r.id,
        userId: r.user_id,
        email: byId.get(r.user_id)?.email ?? "—",
        fullName: byId.get(r.user_id)?.full_name ?? null,
        label: r.device_label,
        boundAt: r.bound_at,
        lastSeenAt: r.last_seen_at,
      })),
    };
  });

/**
 * Admin-only: release a trainee's device binding so they can register a new
 * machine on their next sign-in (lost/replaced phone, reinstalled browser).
 * The old row is kept as an audit trail.
 */
export const resetDeviceBinding = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({ userId: z.string().uuid(), bindingId: z.string().uuid().optional() })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    await assertAdmin(context.supabase, context.userId);
    const admin = serviceClient();

    // With bindingId: free that one slot. Without: free every device.
    let q = admin
      .from("trainee_devices")
      .update({ revoked_at: new Date().toISOString() })
      .eq("user_id", data.userId)
      .is("revoked_at", null);
    if (data.bindingId) q = q.eq("id", data.bindingId);
    const { error } = await q;
    if (error) throw new Error(error.message);
    return { ok: true };
  });

/**
 * Admin-only: issue a short sign-in code for a trainee.
 *
 * The code is the ONLY thing the trainee needs to type — no email, no password.
 * Redeeming it returns that account's real credentials server-side and signs
 * them in, then the normal device binding applies.
 */
export const issueAccessCode = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        userId: z.string().uuid(),
        expiresInDays: z.number().int().min(1).max(365).optional(),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    await assertAdmin(context.supabase, context.userId);
    const admin = serviceClient();

    // Retire any previous active codes for this trainee.
    await admin
      .from("access_codes")
      .update({ revoked_at: new Date().toISOString() })
      .eq("user_id", data.userId)
      .is("revoked_at", null);

    // Unambiguous alphabet: no O/0, no I/1.
    const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    const pick = (n: number) =>
      Array.from({ length: n }, () => alphabet[Math.floor(Math.random() * alphabet.length)]).join("");
    const code = `${pick(4)}-${pick(4)}`;

    const expiresAt = data.expiresInDays
      ? new Date(Date.now() + data.expiresInDays * 86400_000).toISOString()
      : null;

    const { error } = await admin.from("access_codes").insert({
      code,
      user_id: data.userId,
      expires_at: expiresAt,
    });
    if (error) throw new Error(error.message);

    return { ok: true, code, expiresAt };
  });

/**
 * PUBLIC (no auth): exchange an access code for a one-time sign-in link.
 *
 * Returns a magic-link token pair the browser can use with
 * supabase.auth.verifyOtp — the trainee never sees an email or password.
 */
export const redeemAccessCode = createServerFn({ method: "POST" })
  .inputValidator((data) =>
    z.object({ code: z.string().min(4).max(20) }).parse(data),
  )
  .handler(async ({ data }) => {
    const admin = serviceClient();
    const code = data.code.trim().toUpperCase();

    const { data: row, error } = await admin
      .from("access_codes")
      .select("code, user_id, expires_at, revoked_at")
      .eq("code", code)
      .maybeSingle();
    if (error) throw new Error(error.message);

    if (!row || row.revoked_at) {
      throw new Error("That code is not valid.");
    }
    if (row.expires_at && new Date(row.expires_at) < new Date()) {
      throw new Error("That code has expired. Ask your administrator for a new one.");
    }

    // Look up the account's email to generate a magic link.
    const { data: profile } = await admin
      .from("profiles")
      .select("email")
      .eq("id", row.user_id)
      .maybeSingle();
    if (!profile?.email) throw new Error("That code is not linked to an active account.");

    const { data: link, error: linkErr } = await admin.auth.admin.generateLink({
      type: "magiclink",
      email: profile.email,
    });
    if (linkErr) throw new Error(linkErr.message);

    const hashedToken = link?.properties?.hashed_token;
    if (!hashedToken) throw new Error("Could not start a session for that code.");

    await admin
      .from("access_codes")
      .update({ last_used_at: new Date().toISOString() })
      .eq("code", code);

    return { ok: true, email: profile.email, tokenHash: hashedToken };
  });
