import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/lib/auth";

/**
 * Which modules the signed-in user may open.
 *
 * This is for DISPLAY only (lock badges, "request access" buttons). The real
 * enforcement is row-level security: a locked trainee gets zero lesson rows,
 * zero media, zero quiz questions, and the grader refuses the quiz.
 */
export function useModuleAccess() {
  const { user, isStaff, loading: authLoading } = useAuth();
  const [unlocked, setUnlocked] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;
    if (authLoading) return;
    if (!user || isStaff) {
      setLoading(false);
      return;
    }
    setLoading(true);
    void (supabase as any)
      .from("module_access")
      .select("module_id")
      .eq("user_id", user.id)
      .is("revoked_at", null)
      .then(({ data }: { data: { module_id: string }[] | null }) => {
        if (!active) return;
        setUnlocked(new Set((data ?? []).map((r) => r.module_id)));
        setLoading(false);
      });
    return () => {
      active = false;
    };
  }, [user?.id, isStaff, authLoading]);

  const canOpen = (moduleId: string | undefined) => !!moduleId && (isStaff || unlocked.has(moduleId));
  return { canOpen, unlockedCount: isStaff ? Infinity : unlocked.size, loading: loading || authLoading };
}

/** Lesson counts per module, readable even for locked modules. */
export function useLessonCounts() {
  const [counts, setCounts] = useState<Map<string, number>>(new Map());
  useEffect(() => {
    void (supabase as any).rpc("module_lesson_counts").then(({ data }: { data: { module_id: string; lessons: number }[] | null }) => {
      setCounts(new Map((data ?? []).map((r) => [r.module_id, r.lessons])));
    });
  }, []);
  return counts;
}
