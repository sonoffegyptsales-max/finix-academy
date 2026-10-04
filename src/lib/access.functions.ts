import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import { readablePassword } from "@/lib/trainees.functions";

/**
 * Module access + paid enrollment (InstaPay).
 *
 * The curriculum is locked per trainee. Access rows (public.module_access)
 * are written ONLY here, with the service key, so every grant records who
 * made it and a trainee can never grant themselves anything (RLS has no
 * INSERT policy for them -- verified by scripts/verify_module_lock.py).
 *
 * InstaPay has no merchant API, so payment is confirmed by a human: the
 * buyer submits the transfer reference (+ optional screenshot), an admin
 * checks it against the bank app and approves; approval creates the
 * account if needed, unlocks the package's modules and issues a sign-in code.
 */

// The generated types predate these tables; use an untyped client here.
function serviceClient(): any {
  const url = process.env["SUPABASE_URL"];
  const key = process.env["SUPABASE_SERVICE_ROLE_KEY"];
  if (!url || !key) throw new Error("Server misconfigured: Supabase service credentials missing.");
  return createClient<Database>(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
}

async function rolesOf(admin: any, userId: string): Promise<string[]> {
  const { data } = await admin.from("user_roles").select("role").eq("user_id", userId);
  return (data ?? []).map((r: { role: string }) => r.role);
}
async function assertAdmin(admin: any, userId: string) {
  if (!(await rolesOf(admin, userId)).includes("admin")) throw new Error("Administrator rights required");
}
async function assertStaff(admin: any, userId: string) {
  const r = await rolesOf(admin, userId);
  if (!r.includes("admin") && !r.includes("trainer")) throw new Error("Trainer or administrator rights required");
}

const ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
function randomFrom(n: number) {
  const bytes = crypto.getRandomValues(new Uint8Array(n));
  return Array.from(bytes, (b) => ALPHABET[b % ALPHABET.length]).join("");
}

async function modulesForScope(admin: any, scope: "track" | "all", trackId: string | null) {
  let q = admin.from("modules").select("id").eq("published", true);
  if (scope === "track") {
    if (!trackId) throw new Error("This package needs a track.");
    q = q.eq("track_id", trackId);
  }
  const { data, error } = await q;
  if (error) throw new Error(error.message);
  return (data ?? []).map((m: { id: string }) => m.id as string);
}

async function grant(admin: any, userId: string, moduleIds: string[], by: string, source: string, requestId?: string) {
  if (moduleIds.length === 0) return 0;
  const rows = moduleIds.map((module_id) => ({
    user_id: userId,
    module_id,
    source,
    request_id: requestId ?? null,
    granted_by: by,
    granted_at: new Date().toISOString(),
    revoked_at: null,
  }));
  const { error } = await admin.from("module_access").upsert(rows, { onConflict: "user_id,module_id" });
  if (error) throw new Error(error.message);
  return rows.length;
}

async function notify(admin: any, userId: string, title: string, body: string) {
  // Best effort: the in-app notification list. Push delivery is separate.
  await admin.from("notifications").insert({ user_id: userId, title, body, url: "/dashboard/my-courses" });
}

// ============================================================ staff: unlocks

/** Staff: every trainee with the list of module ids they can open. */
export const listTraineeAccess = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }) => {
    const admin = serviceClient();
    await assertStaff(admin, context.userId);

    const { data: roleRows } = await admin.from("user_roles").select("user_id").eq("role", "trainee");
    const ids = [...new Set((roleRows ?? []).map((r: { user_id: string }) => r.user_id))] as string[];
    if (ids.length === 0) return { trainees: [] };

    const [{ data: profiles }, { data: access }] = await Promise.all([
      admin.from("profiles").select("id, email, full_name").in("id", ids),
      admin.from("module_access").select("user_id, module_id").in("user_id", ids).is("revoked_at", null),
    ]);
    const byUser = new Map<string, string[]>();
    for (const a of access ?? []) {
      const list = byUser.get(a.user_id) ?? [];
      list.push(a.module_id);
      byUser.set(a.user_id, list);
    }
    return {
      trainees: (profiles ?? [])
        .map((p: { id: string; email: string | null; full_name: string | null }) => ({
          userId: p.id,
          email: p.email ?? "—",
          fullName: p.full_name,
          moduleIds: byUser.get(p.id) ?? [],
        }))
        .sort((a: { email: string }, b: { email: string }) => a.email.localeCompare(b.email)),
    };
  });

/** Staff: unlock or lock modules for one trainee. */
export const setModuleAccess = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        userId: z.string().uuid(),
        moduleIds: z.array(z.string().uuid()).min(1).max(200),
        unlock: z.boolean(),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const admin = serviceClient();
    await assertStaff(admin, context.userId);
    if (!(await rolesOf(admin, data.userId)).includes("trainee")) throw new Error("That account is not a trainee.");

    if (data.unlock) {
      const n = await grant(admin, data.userId, data.moduleIds, context.userId, "manual");
      const { data: mods } = await admin.from("modules").select("code").in("id", data.moduleIds);
      const codes = (mods ?? []).map((m: { code: string }) => m.code).join(", ");
      await notify(admin, data.userId, "New material unlocked / تم فتح محتوى جديد", codes);
      return { ok: true, changed: n };
    }
    const { error } = await admin
      .from("module_access")
      .update({ revoked_at: new Date().toISOString() })
      .eq("user_id", data.userId)
      .in("module_id", data.moduleIds)
      .is("revoked_at", null);
    if (error) throw new Error(error.message);
    return { ok: true, changed: data.moduleIds.length };
  });

// ============================================================ public: request

const MAX_PROOF_BYTES = 4 * 1024 * 1024;

const proofSchema = z
  .object({
    base64: z.string().max(Math.ceil((MAX_PROOF_BYTES * 4) / 3) + 16),
    type: z.enum(["image/jpeg", "image/png", "image/webp"]),
  })
  .nullable();

const paymentFields = {
  packageId: z.string().uuid(),
  trackId: z.string().max(80).nullable(),
  reference: z.string().trim().min(4).max(80),
  senderName: z.string().trim().max(120).default(""),
  note: z.string().trim().max(500).default(""),
  proof: proofSchema,
};

type RequestInput = {
  userId: string | null;
  fullName: string;
  phone: string;
  email: string;
  packageId: string;
  trackId: string | null;
  reference: string;
  senderName: string;
  note: string;
  proof: { base64: string; type: "image/jpeg" | "image/png" | "image/webp" } | null;
};

/** Validate the package, store the screenshot, insert the request, notify admins. */
async function createRequest(admin: any, r: RequestInput) {
  const email = r.email.toLowerCase();
  const { data: pkg } = await admin
    .from("course_packages")
    .select("id, price_egp, scope, active")
    .eq("id", r.packageId)
    .maybeSingle();
  if (!pkg || !pkg.active) throw new Error("That package is not available.");
  if (pkg.scope === "track") {
    const { data: tr } = await admin.from("tracks").select("id").eq("id", r.trackId ?? "").maybeSingle();
    if (!tr) throw new Error("Choose a track for this package.");
  }

  // Simple flood guard: max 3 open requests per e-mail.
  const { count } = await admin
    .from("access_requests")
    .select("id", { count: "exact", head: true })
    .eq("email", email)
    .eq("status", "pending");
  if ((count ?? 0) >= 3) throw new Error("You already have requests under review. We will contact you shortly.");

  let proofPath: string | null = null;
  if (r.proof) {
    const bytes = Buffer.from(r.proof.base64, "base64");
    if (bytes.length > MAX_PROOF_BYTES) throw new Error("Screenshot is larger than 4 MB.");
    const ext = r.proof.type.split("/")[1];
    proofPath = `${new Date().toISOString().slice(0, 10)}/${crypto.randomUUID()}.${ext}`;
    const { error: upErr } = await admin.storage
      .from("payment-proofs")
      .upload(proofPath, bytes, { contentType: r.proof.type, upsert: false });
    if (upErr) throw new Error("Could not upload the screenshot: " + upErr.message);
  }

  let userId = r.userId;
  if (!userId) {
    const { data: existingProfile } = await admin.from("profiles").select("id").eq("email", email).maybeSingle();
    userId = existingProfile?.id ?? null;
  }

  const { error } = await admin.from("access_requests").insert({
    user_id: userId,
    full_name: r.fullName,
    phone: r.phone.replace(/\s+/g, ""),
    email,
    package_id: pkg.id,
    track_id: pkg.scope === "track" ? r.trackId : null,
    amount_egp: pkg.price_egp,
    instapay_reference: r.reference,
    sender_name: r.senderName,
    customer_note: r.note,
    proof_path: proofPath,
  });
  if (error) {
    if (error.code === "23505") throw new Error("This InstaPay reference was already submitted.");
    throw new Error(error.message);
  }

  const { data: admins } = await admin.from("user_roles").select("user_id").eq("role", "admin");
  for (const a of admins ?? []) {
    await admin.from("notifications").insert({
      user_id: a.user_id,
      title: userId ? "Student upgrade request / طلب اشتراك من طالب" : "New InstaPay request / طلب دفع جديد",
      body: `${r.fullName} — ${pkg.price_egp} EGP — ref ${r.reference}`,
      url: "/dashboard/admin-panel",
    });
  }
  return { ok: true };
}

/**
 * PUBLIC: submit a paid access request after an InstaPay transfer.
 * The price is taken from the package row, never from the browser.
 */
export const submitAccessRequest = createServerFn({ method: "POST" })
  .inputValidator((data) =>
    z
      .object({
        fullName: z.string().trim().min(3).max(120),
        phone: z.string().trim().regex(/^\+?[0-9 ]{10,16}$/, "Invalid phone number"),
        email: z.string().trim().email().max(200),
        ...paymentFields,
      })
      .parse(data),
  )
  .handler(async ({ data }) => {
    return createRequest(serviceClient(), { ...data, userId: null });
  });

/**
 * SIGNED-IN student: buy more courses from inside the dashboard. Name and
 * e-mail come from the account (never the browser), so the request attaches
 * to this exact student and approval unlocks on the account they already use.
 */
export const submitMyAccessRequest = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        phone: z.string().trim().regex(/^\+?[0-9 ]{10,16}$/, "Invalid phone number"),
        ...paymentFields,
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const admin = serviceClient();
    const { data: prof } = await admin.from("profiles").select("email, full_name").eq("id", context.userId).maybeSingle();
    const { data: au } = await admin.auth.admin.getUserById(context.userId);
    const email = prof?.email ?? au?.user?.email;
    if (!email) throw new Error("Your account has no e-mail on file. Contact the academy.");
    return createRequest(admin, {
      ...data,
      userId: context.userId,
      email,
      fullName: prof?.full_name || email,
    });
  });

/** SIGNED-IN student: their own requests (to show "under review" status). */
export const listMyAccessRequests = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }) => {
    const admin = serviceClient();
    const { data, error } = await admin
      .from("access_requests")
      .select("id, created_at, status, amount_egp, instapay_reference, admin_note, track_id, course_packages(name, name_ar, scope)")
      .eq("user_id", context.userId)
      .order("created_at", { ascending: false })
      .limit(20);
    if (error) throw new Error(error.message);
    return { requests: data ?? [] };
  });

// ============================================================ admin: review

export const listAccessRequests = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }) => {
    const admin = serviceClient();
    await assertAdmin(admin, context.userId);
    const { data, error } = await admin
      .from("access_requests")
      .select("*, course_packages(code, name, name_ar, scope), tracks(name, name_ar)")
      .order("created_at", { ascending: false })
      .limit(300);
    if (error) throw new Error(error.message);
    return { requests: data ?? [] };
  });

/** Admin: short-lived link to view a transfer screenshot (private bucket). */
export const getProofUrl = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) => z.object({ requestId: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    const admin = serviceClient();
    await assertAdmin(admin, context.userId);
    const { data: row } = await admin.from("access_requests").select("proof_path").eq("id", data.requestId).maybeSingle();
    if (!row?.proof_path) throw new Error("No screenshot attached.");
    const { data: signed, error } = await admin.storage.from("payment-proofs").createSignedUrl(row.proof_path, 300);
    if (error) throw new Error(error.message);
    return { url: signed.signedUrl as string };
  });

/**
 * Admin: approve a request. Creates the trainee account if the e-mail is new,
 * unlocks the package's modules, and returns a sign-in code to send them.
 */
export const approveAccessRequest = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z.object({ requestId: z.string().uuid(), note: z.string().max(500).default("") }).parse(data),
  )
  .handler(async ({ data, context }) => {
    const admin = serviceClient();
    await assertAdmin(admin, context.userId);

    const { data: req, error: rErr } = await admin
      .from("access_requests")
      .select("*, course_packages(scope)")
      .eq("id", data.requestId)
      .maybeSingle();
    if (rErr) throw new Error(rErr.message);
    if (!req) throw new Error("Request not found.");
    if (req.status !== "pending") throw new Error(`This request is already ${req.status}.`);

    // Claim it first so two admins clicking at once cannot double-process.
    const { data: claimed } = await admin
      .from("access_requests")
      .update({ status: "approved", reviewed_by: context.userId, reviewed_at: new Date().toISOString(), admin_note: data.note })
      .eq("id", req.id)
      .eq("status", "pending")
      .select("id");
    if (!claimed || claimed.length === 0) throw new Error("Another administrator already handled this request.");

    try {
      // 1. Find or create the account.
      let userId: string | null = null;
      let created = false;
      let password: string | null = null;
      const { data: prof } = req.user_id
        ? { data: { id: req.user_id as string } }
        : await admin.from("profiles").select("id").eq("email", req.email).maybeSingle();
      if (prof) {
        userId = prof.id;
      } else {
        const { data: cu, error: cErr } = await admin.auth.admin.createUser({
          email: req.email,
          // Shown once to the admin with the code; can be reset later.
          password: (password = readablePassword()),
          email_confirm: true,
          user_metadata: { full_name: req.full_name, phone: req.phone },
        });
        if (cErr) throw new Error(cErr.message);
        userId = cu.user.id;
        created = true;
        await admin.from("profiles").upsert({ id: userId, email: req.email, full_name: req.full_name }, { onConflict: "id" });
      }
      const roles = await rolesOf(admin, userId!);
      if (!roles.includes("trainee")) {
        const { error: roleErr } = await admin.from("user_roles").insert({ user_id: userId, role: "trainee" });
        if (roleErr) throw new Error(roleErr.message);
      }

      // 2. Unlock what was paid for.
      const moduleIds = await modulesForScope(admin, req.course_packages.scope, req.track_id);
      const unlocked = await grant(admin, userId!, moduleIds, context.userId, "payment", req.id);

      // 3. Sign-in code. An existing student keeps the code they already use
      //    (replacing it would log them out of the course they paid for);
      //    a new account, or one without a valid code, gets a fresh one.
      const { data: current } = await admin
        .from("access_codes")
        .select("code, expires_at")
        .eq("user_id", userId)
        .is("revoked_at", null)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      const stillValid = current && (!current.expires_at || new Date(current.expires_at) > new Date());
      let code: string;
      if (!created && stillValid) {
        code = current.code;
      } else {
        await admin.from("access_codes").update({ revoked_at: new Date().toISOString() }).eq("user_id", userId).is("revoked_at", null);
        code = `${randomFrom(4)}-${randomFrom(4)}`;
        const { error: codeErr } = await admin.from("access_codes").insert({ code, user_id: userId, expires_at: null });
        if (codeErr) throw new Error(codeErr.message);
      }

      await admin.from("access_requests").update({ user_id: userId, granted_user_id: userId }).eq("id", req.id);
      await notify(admin, userId!, "Payment confirmed / تم تأكيد الدفع", `${unlocked} modules unlocked / تم فتح ${unlocked} وحدة`);

      return { ok: true, code, password, created, unlocked, email: req.email, phone: req.phone, fullName: req.full_name };
    } catch (e) {
      // Put the request back so it can be retried.
      await admin.from("access_requests").update({ status: "pending", reviewed_by: null, reviewed_at: null }).eq("id", req.id);
      throw e;
    }
  });

export const rejectAccessRequest = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z.object({ requestId: z.string().uuid(), note: z.string().trim().min(3).max(500) }).parse(data),
  )
  .handler(async ({ data, context }) => {
    const admin = serviceClient();
    await assertAdmin(admin, context.userId);
    const { data: rows, error } = await admin
      .from("access_requests")
      .update({ status: "rejected", admin_note: data.note, reviewed_by: context.userId, reviewed_at: new Date().toISOString() })
      .eq("id", data.requestId)
      .eq("status", "pending")
      .select("id");
    if (error) throw new Error(error.message);
    if (!rows || rows.length === 0) throw new Error("This request was already handled.");
    return { ok: true };
  });
