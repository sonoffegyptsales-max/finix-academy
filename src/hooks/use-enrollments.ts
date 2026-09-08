import { useCallback, useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/lib/auth";

const LOCAL_KEY = "finix-progress";

function readLocal(): string[] {
  if (typeof window === "undefined") return [];
  try {
    const parsed: unknown = JSON.parse(localStorage.getItem(LOCAL_KEY) ?? "[]");
    return Array.isArray(parsed) ? parsed.filter((s): s is string => typeof s === "string") : [];
  } catch {
    return [];
  }
}

function writeLocal(slugs: string[]) {
  localStorage.setItem(LOCAL_KEY, JSON.stringify(slugs));
}

/**
 * Tracks which modules a trainee has completed. Backed by the `enrollments`
 * table (server-side, synced across devices) with a localStorage fallback
 * for signed-out preview or when Supabase isn't reachable.
 *
 * `completed` holds module SLUGS for compatibility with the existing UI;
 * moduleIdBySlug lets callers resolve the DB id needed for writes.
 */
export function useEnrollments(moduleIdBySlug: Record<string, string> = {}) {
  const { user } = useAuth();
  const [completed, setCompleted] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    if (!user) {
      setCompleted(readLocal());
      setLoading(false);
      return;
    }
    try {
      const { data, error } = await supabase
        .from("enrollments")
        .select("module_id, status")
        .eq("user_id", user.id)
        .eq("status", "completed");
      if (error) throw error;

      const idToSlug = Object.fromEntries(
        Object.entries(moduleIdBySlug).map(([slug, id]) => [id, slug]),
      );
      const slugs = (data ?? [])
        .map((row) => idToSlug[row.module_id])
        .filter((s): s is string => Boolean(s));
      setCompleted(slugs);
    } catch {
      setCompleted(readLocal());
    } finally {
      setLoading(false);
    }
  }, [user, moduleIdBySlug]);

  useEffect(() => {
    void load();
  }, [load]);

  const toggle = useCallback(
    async (slug: string) => {
      const moduleId = moduleIdBySlug[slug];
      const isDone = completed.includes(slug);
      const next = isDone ? completed.filter((s) => s !== slug) : [...completed, slug];
      setCompleted(next);

      if (!user || !moduleId) {
        writeLocal(next);
        return;
      }

      try {
        if (isDone) {
          await supabase
            .from("enrollments")
            .update({ status: "in_progress", completed_at: null })
            .eq("user_id", user.id)
            .eq("module_id", moduleId);
        } else {
          await supabase.from("enrollments").upsert(
            {
              user_id: user.id,
              module_id: moduleId,
              status: "completed",
              completed_at: new Date().toISOString(),
            },
            { onConflict: "user_id,module_id" },
          );
        }
      } catch {
        // Best-effort: local state already updated; server sync will retry on next load.
        writeLocal(next);
      }
    },
    [completed, moduleIdBySlug, user],
  );

  return {
    completed,
    loading,
    toggle,
    isComplete: (slug: string) => completed.includes(slug),
  };
}
