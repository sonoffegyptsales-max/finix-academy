import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import { readablePassword } from "@/lib/trainees.functions";

/**
 * Trainer accounts and the lessons each trainer is allowed to see and edit.
 * Admin-only. The database enforces the scope (trainer_assignments + RLS);
 * these functions just manage the rows. Verified by scripts/verify_trainer_scope.py.
 */

function serviceClient(): any {
  const url = process.env["SUPABASE_URL"];
  const key = process.env["SUPABASE_SERVICE_ROLE_KEY"];
  if (!url || !key) throw new Error("Server misconfigured: Supabase service credentials missing.");
  return createClient<Database>(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
}

async function assertAdmin(admin: any, userId: string) {
  const { data } = await admin.from("user_roles").select("role").eq("user_id", userId).eq("role", "admin").maybeSingle();
  if (!data) throw new Error("Administrator rights required");
}

/** Admin: create a trainer account. Returns a one-time readable password. */
export const createTrainer = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        email: z.string().trim().email().max(200),
        fullName: z.string().trim().min(2).max(160),
        phone: z.string().trim().max(20).default(""),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const admin = serviceClient();
    await assertAdmin(admin, context.userId);
    const email = data.email.toLowerCase();

    const { data: existing } = await admin.from("profiles").select("id").eq("email", email).maybeSingle();
    if (existing) {
      const { data: roles } = await admin.from("user_roles").select("role").eq("user_id", existing.id);
      const r = (roles ?? []).map((x: { role: string }) => x.role);
      if (r.includes("admin")) throw new Error("That e-mail belongs to an administrator.");
      if (r.includes("trainee")) throw new Error("That e-mail is a student account. Use a different e-mail for the trainer.");
      if (r.includes("trainer")) throw new Error("A trainer with that e-mail already exists.");
    }

    const password = readablePassword();
    const { data: cu, error } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name: data.fullName, phone: data.phone },
    });
    if (error) throw new Error(error.message);
    const uid = cu.user.id;
    await admin.from("profiles").upsert({ id: uid, email, full_name: data.fullName }, { onConflict: "id" });
    const { error: roleErr } = await admin.from("user_roles").insert({ user_id: uid, role: "trainer" });
    if (roleErr) {
      await admin.auth.admin.deleteUser(uid);
      throw new Error(roleErr.message);
    }
    return { ok: true, userId: uid, email, password };
  });

/** Admin: every trainer with their assigned lesson ids. */
export const listTrainers = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }) => {
    const admin = serviceClient();
    await assertAdmin(admin, context.userId);
    const { data: roleRows } = await admin.from("user_roles").select("user_id").eq("role", "trainer");
    const ids: string[] = [...new Set<string>((roleRows ?? []).map((r: { user_id: string }) => r.user_id))];
    if (ids.length === 0) return { trainers: [] };
    const [{ data: profiles }, { data: assigns }] = await Promise.all([
      admin.from("profiles").select("id, email, full_name").in("id", ids),
      admin.from("trainer_assignments").select("trainer_id, lesson_id").in("trainer_id", ids),
    ]);
    const by = new Map<string, string[]>();
    for (const a of assigns ?? []) {
      const l = by.get(a.trainer_id) ?? [];
      l.push(a.lesson_id);
      by.set(a.trainer_id, l);
    }
    const lastSignIn = new Map<string, string | null>();
    for (const id of ids as string[]) {
      const { data } = await admin.auth.admin.getUserById(id);
      lastSignIn.set(id, data?.user?.last_sign_in_at ?? null);
    }
    return {
      trainers: (profiles ?? []).map((p: { id: string; email: string | null; full_name: string | null }) => ({
        userId: p.id,
        email: p.email ?? "—",
        fullName: p.full_name,
        lessonIds: by.get(p.id) ?? [],
        lastSignInAt: lastSignIn.get(p.id) ?? null,
      })),
    };
  });

/** Admin: replace a trainer's lesson list with exactly `lessonIds`. */
export const setTrainerLessons = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z.object({ trainerId: z.string().uuid(), lessonIds: z.array(z.string().uuid()).max(1000) }).parse(data),
  )
  .handler(async ({ data, context }) => {
    const admin = serviceClient();
    await assertAdmin(admin, context.userId);
    const { data: role } = await admin
      .from("user_roles").select("role").eq("user_id", data.trainerId).eq("role", "trainer").maybeSingle();
    if (!role) throw new Error("That account is not a trainer.");

    const want = new Set(data.lessonIds);
    const { data: current } = await admin.from("trainer_assignments").select("lesson_id").eq("trainer_id", data.trainerId);
    const have = new Set((current ?? []).map((r: { lesson_id: string }) => r.lesson_id));
    const toAdd = [...want].filter((id) => !have.has(id));
    const toRemove = [...have].filter((id) => !want.has(id));

    if (toRemove.length) {
      const { error } = await admin.from("trainer_assignments").delete().eq("trainer_id", data.trainerId).in("lesson_id", toRemove);
      if (error) throw new Error(error.message);
    }
    if (toAdd.length) {
      const { error } = await admin.from("trainer_assignments").insert(
        toAdd.map((lesson_id) => ({ trainer_id: data.trainerId, lesson_id, assigned_by: context.userId })),
      );
      if (error) throw new Error(error.message);
      await admin.from("notifications").insert({
        user_id: data.trainerId,
        title: "New lessons assigned / دروس جديدة متاحة ليك",
        body: `${toAdd.length} lesson(s) / درس`,
        url: "/dashboard/authoring",
      });
    }
    return { ok: true, added: toAdd.length, removed: toRemove.length, total: want.size };
  });

/** Admin: remove a trainer account entirely. */
export const deleteTrainer = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) => z.object({ trainerId: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    const admin = serviceClient();
    await assertAdmin(admin, context.userId);
    const { data: roles } = await admin.from("user_roles").select("role").eq("user_id", data.trainerId);
    const r = (roles ?? []).map((x: { role: string }) => x.role);
    if (r.includes("admin")) throw new Error("Cannot delete an administrator here.");
    if (!r.includes("trainer")) throw new Error("That account is not a trainer.");
    const { error } = await admin.auth.admin.deleteUser(data.trainerId);
    if (error) throw new Error(error.message);
    return { ok: true };
  });
