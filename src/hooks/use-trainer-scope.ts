import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/lib/auth";

/**
 * For a trainer: the set of lesson ids the admin assigned (what they may
 * see and edit). For an admin: null = everything. Display only -- the
 * database enforces the same rule.
 */
export function useTrainerScope() {
  const { user, isAdmin, isTrainer, loading: authLoading } = useAuth();
  const [lessonIds, setLessonIds] = useState<Set<string> | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (authLoading) return;
    if (!user || isAdmin || !isTrainer) {
      setLessonIds(null);
      setLoading(false);
      return;
    }
    let active = true;
    setLoading(true);
    void (supabase as any)
      .from("trainer_assignments")
      .select("lesson_id")
      .eq("trainer_id", user.id)
      .then(({ data }: { data: { lesson_id: string }[] | null }) => {
        if (!active) return;
        setLessonIds(new Set((data ?? []).map((r) => r.lesson_id)));
        setLoading(false);
      });
    return () => {
      active = false;
    };
  }, [user?.id, isAdmin, isTrainer, authLoading]);

  return {
    /** null = admin, unrestricted */
    lessonIds,
    isScoped: lessonIds !== null,
    loading: loading || authLoading,
  };
}
