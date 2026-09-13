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
