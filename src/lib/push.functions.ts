import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { createClient } from "@supabase/supabase-js";
import webpush from "web-push";
import type { Database } from "@/integrations/supabase/types";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";

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

function configureVapid() {
  const pub = process.env["VAPID_PUBLIC_KEY"];
  const priv = process.env["VAPID_PRIVATE_KEY"];
  const subject = process.env["VAPID_SUBJECT"] || "mailto:admin@finixacademy.local";
  if (!pub || !priv) {
    throw new Error("Server misconfigured: VAPID keys missing.");
  }
  webpush.setVapidDetails(subject, pub, priv);
}

/**
 * Any authenticated user: register a browser push subscription for themselves.
 */
export const savePushSubscription = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        endpoint: z.string().url().max(1000),
        p256dh: z.string().min(1).max(500),
        auth: z.string().min(1).max(500),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const { error } = await context.supabase.from("push_subscriptions").upsert(
      {
        user_id: context.userId,
        endpoint: data.endpoint,
        p256dh: data.p256dh,
        auth_key: data.auth,
      },
      { onConflict: "endpoint" },
    );
    if (error) throw new Error(error.message);
    return { ok: true };
  });

/**
 * Any authenticated user: remove a push subscription (on unsubscribe).
 */
export const removePushSubscription = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) => z.object({ endpoint: z.string().url().max(1000) }).parse(data))
  .handler(async ({ data, context }) => {
    const { error } = await context.supabase
      .from("push_subscriptions")
      .delete()
      .eq("endpoint", data.endpoint)
      .eq("user_id", context.userId);
    if (error) throw new Error(error.message);
    return { ok: true };
  });

/**
 * Admin-only: send a push notification to ALL trainees (users holding the
 * 'trainee' role). Records each in the notifications table and prunes dead
 * subscriptions (410/404). Returns delivery counts.
 */
export const sendPushToTrainees = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        title: z.string().min(1).max(120),
        body: z.string().min(1).max(500),
        url: z.string().max(500).optional(),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    await assertAdmin(context.supabase, context.userId);
    configureVapid();
    const admin = serviceClient();

    // 1. Resolve trainee user ids.
    const { data: roleRows, error: roleErr } = await admin
      .from("user_roles")
      .select("user_id")
      .eq("role", "trainee");
    if (roleErr) throw new Error(roleErr.message);
    const traineeIds = (roleRows ?? []).map((r) => r.user_id);
    if (traineeIds.length === 0) return { ok: true, sent: 0, failed: 0, recipients: 0 };

    // 2. Their push subscriptions.
    const { data: subs, error: subErr } = await admin
      .from("push_subscriptions")
      .select("id, user_id, endpoint, p256dh, auth_key")
      .in("user_id", traineeIds);
    if (subErr) throw new Error(subErr.message);

    // 3. Log an in-app notification row per trainee (so it shows even without push).
    const notifRows = traineeIds.map((uid) => ({
      user_id: uid,
      title: data.title,
      body: data.body,
      url: data.url ?? null,
    }));
    await admin.from("notifications").insert(notifRows);

    // 4. Fan out web-push.
    const payload = JSON.stringify({
      title: data.title,
      body: data.body,
      url: data.url ?? "/dashboard",
    });

    let sent = 0;
    let failed = 0;
    const deadEndpoints: string[] = [];

    await Promise.all(
      (subs ?? []).map(async (s) => {
        try {
          await webpush.sendNotification(
            {
              endpoint: s.endpoint,
              keys: { p256dh: s.p256dh, auth: s.auth_key },
            },
            payload,
          );
          sent += 1;
        } catch (err: any) {
          failed += 1;
          const code = err?.statusCode;
          if (code === 404 || code === 410) deadEndpoints.push(s.endpoint);
        }
      }),
    );

    // 5. Prune dead subscriptions.
    if (deadEndpoints.length > 0) {
      await admin.from("push_subscriptions").delete().in("endpoint", deadEndpoints);
    }

    return {
      ok: true,
      sent,
      failed,
      recipients: traineeIds.length,
      subscriptions: subs?.length ?? 0,
    };
  });
