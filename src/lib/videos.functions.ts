import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
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

export const addSessionVideo = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) =>
    z
      .object({
        sessionId: z.number().int().min(1).max(8),
        title: z.string().min(2).max(160),
        description: z.string().max(500).optional(),
        url: z.string().url().max(500),
        source: z.enum(["official", "custom"]).default("custom"),
        position: z.number().int().min(0).max(999).default(0),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    await assertAdmin(context.supabase, context.userId);
    const { error } = await context.supabase.from("session_videos").insert({
      session_id: data.sessionId,
      title: data.title,
      description: data.description ?? null,
      url: data.url,
      source: data.source,
      position: data.position,
      created_by: context.userId,
    });
    if (error) throw new Error(error.message);
    return { ok: true };
  });

export const deleteSessionVideo = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data) => z.object({ id: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    await assertAdmin(context.supabase, context.userId);
    const { error } = await context.supabase.from("session_videos").delete().eq("id", data.id);
    if (error) throw new Error(error.message);
    return { ok: true };
  });
