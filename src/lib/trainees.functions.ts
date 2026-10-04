import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";

/** Throw unless the calling user holds the admin role. */
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

/** Build an admin (service-role) Supabase client for privileged operations. */
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

/**
 * Admin-only: create a trainee account (email + password), confirm it, seed a
 * profile row, and grant the 'trainee' role. Returns the new user id.
 */
export const createTrainee = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        email: z.string().email().max(200),
        password: z.string().min(6).max(200),
        fullName: z.string().min(1).max(160),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    await assertAdmin(context.supabase, context.userId);
    const admin = serviceClient();

    // 1. Create the auth user (email pre-confirmed so they can log in immediately).
    const { data: created, error: createErr } = await admin.auth.admin.createUser({
      email: data.email,
      password: data.password,
      email_confirm: true,
      user_metadata: { full_name: data.fullName },
    });
    if (createErr) throw new Error(createErr.message);
    const newUserId = created.user?.id;
    if (!newUserId) throw new Error("User creation returned no id.");

    // 2. Seed the profile row (idempotent).
    const { error: profileErr } = await admin
      .from("profiles")
      .upsert(
        { id: newUserId, email: data.email, full_name: data.fullName },
        { onConflict: "id" },
      );
    if (profileErr) throw new Error(profileErr.message);

    // 3. Grant the trainee role (idempotent).
    const { error: roleErr } = await admin
      .from("user_roles")
      .upsert(
        { user_id: newUserId, role: "trainee" },
        { onConflict: "user_id,role" },
      );
    if (roleErr) throw new Error(roleErr.message);

    return { ok: true, userId: newUserId };
  });

/**
 * Admin-only: list all trainee accounts with basic profile info.
 */
export const listTrainees = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }) => {
    await assertAdmin(context.supabase, context.userId);
    const admin = serviceClient();

    const { data: roleRows, error: roleErr } = await admin
      .from("user_roles")
      .select("user_id")
      .eq("role", "trainee");
    if (roleErr) throw new Error(roleErr.message);

    const ids = (roleRows ?? []).map((r) => r.user_id);
    if (ids.length === 0) return { trainees: [] as Array<{ id: string; email: string; full_name: string | null }> };

    const { data: profiles, error: profErr } = await admin
      .from("profiles")
      .select("id, email, full_name")
      .in("id", ids);
    if (profErr) throw new Error(profErr.message);

    return { trainees: profiles ?? [] };
  });

/**
 * Admin-only: delete a trainee account entirely (auth user + cascading rows).
 */
export const deleteTrainee = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) => z.object({ userId: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    await assertAdmin(context.supabase, context.userId);
    const admin = serviceClient();

    // Guard: never allow deleting an admin through this path.
    const { data: isAdminRow } = await admin
      .from("user_roles")
      .select("role")
      .eq("user_id", data.userId)
      .eq("role", "admin")
      .maybeSingle();
    if (isAdminRow) throw new Error("Cannot delete an administrator account here.");

    const { error } = await admin.auth.admin.deleteUser(data.userId);
    if (error) throw new Error(error.message);
    return { ok: true };
  });


// Readable passwords: no 0/O/1/l/I, grouped so they can be read over the phone.
const PW_ALPHABET = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789";
export function readablePassword(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(12));
  const chars = Array.from(bytes, (b) => PW_ALPHABET[b % PW_ALPHABET.length]).join("");
  return `${chars.slice(0, 4)}-${chars.slice(4, 8)}-${chars.slice(8, 12)}`;
}

/**
 * Admin-only: open a trainee's sign-in details.
 *
 * The access code is stored as-is, so it can always be shown. The password
 * is stored ONLY as a one-way hash by Supabase Auth -- it cannot be shown by
 * anyone. To give a trainee a password, use resetTraineePassword.
 */
export const getTraineeCredentials = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) => z.object({ userId: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    await assertAdmin(context.supabase, context.userId);
    const admin = serviceClient();
    const [{ data: prof }, { data: codeRow }, { data: authUser }] = await Promise.all([
      admin.from("profiles").select("email, full_name").eq("id", data.userId).maybeSingle(),
      (admin as any)
        .from("access_codes")
        .select("code, expires_at, last_used_at, created_at")
        .eq("user_id", data.userId)
        .is("revoked_at", null)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle(),
      admin.auth.admin.getUserById(data.userId),
    ]);
    const u = authUser?.user;
    const expired = codeRow?.expires_at ? new Date(codeRow.expires_at) < new Date() : false;
    return {
      email: prof?.email ?? u?.email ?? "",
      fullName: prof?.full_name ?? null,
      phone: (u?.user_metadata as any)?.phone ?? null,
      code: codeRow && !expired ? (codeRow.code as string) : null,
      codeExpiresAt: codeRow?.expires_at ?? null,
      codeLastUsedAt: codeRow?.last_used_at ?? null,
      lastSignInAt: u?.last_sign_in_at ?? null,
    };
  });

/**
 * Admin-only: set a NEW password for a trainee and return it once so the
 * admin can send it. The previous password stops working immediately.
 */
export const resetTraineePassword = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) => z.object({ userId: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    await assertAdmin(context.supabase, context.userId);
    const admin = serviceClient();
    const { data: isAdminRow } = await admin
      .from("user_roles").select("role").eq("user_id", data.userId).eq("role", "admin").maybeSingle();
    if (isAdminRow) throw new Error("Administrator passwords cannot be reset here.");
    const password = readablePassword();
    const { error } = await admin.auth.admin.updateUserById(data.userId, { password });
    if (error) throw new Error(error.message);
    return { ok: true, password };
  });
