/**
 * Lesson bodies for ONE module.
 *
 * useCurriculum() intentionally omits lesson content: it feeds seven pages and
 * only this one renders prose, so selecting it everywhere meant shipping every
 * body of all 22 modules (~550 KB) on each dashboard load. That was the main
 * reason lectures felt slow to open.
 *
 * This hook fetches bodies for a single module -- typically a few lessons,
 * a few KB -- and merges them into the list the curriculum already provides.
 */

import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";

export type LessonBody = {
  id: string;
  content: string | null;
  content_ar: string | null;
};

export function useModuleLessonBodies(moduleId: string | undefined) {
  const [bodies, setBodies] = useState<Map<string, LessonBody>>(new Map());
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!moduleId) {
      setBodies(new Map());
      return;
    }

    let active = true;
    setLoading(true);

    (async () => {
      const { data, error } = await supabase
        .from("lessons")
        .select("id,content,content_ar")
        .eq("module_id", moduleId)
        .order("position");

      if (!active) return;

      if (error || !data) {
        // Non-fatal: titles still render, bodies just stay empty.
        setBodies(new Map());
        setLoading(false);
        return;
      }

      const map = new Map<string, LessonBody>();
      for (const row of data as LessonBody[]) map.set(row.id, row);
      setBodies(map);
      setLoading(false);
    })();

    return () => {
      active = false;
    };
  }, [moduleId]);

  return { bodies, loading };
}
