import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import type { Tables } from "@/integrations/supabase/types";
import { finixModules, finixTracks } from "@/content/finix";

export type DbTrack = Tables<"tracks">;
export type DbModule = Tables<"modules">;
export type DbLesson = Tables<"lessons">;

export interface CurriculumModule extends DbModule {
  lessons: DbLesson[];
}

interface CurriculumState {
  tracks: DbTrack[];
  modules: CurriculumModule[];
  loading: boolean;
  /** True if the Supabase tables weren't reachable/seeded and we fell back to static content. */
  usingFallback: boolean;
}

/** Static fallback shaped like the DB rows, used when Supabase isn't seeded yet. */
function fallbackCurriculum(): { tracks: DbTrack[]; modules: CurriculumModule[] } {
  const tracks: DbTrack[] = finixTracks.map((t, i) => ({
    id: t.id,
    name: t.name,
    name_ar: t.nameAr,
    tagline: t.tagline,
    tagline_ar: t.taglineAr,
    position: i + 1,
    created_at: new Date().toISOString(),
  }));

  const modules: CurriculumModule[] = finixModules.map((m, i) => ({
    id: m.slug,
    slug: m.slug,
    code: m.code,
    track_id: m.track,
    title: m.title,
    title_ar: m.titleAr,
    summary: m.summary,
    summary_ar: m.summaryAr,
    external_url: m.url,
    position: i + 1,
    published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    lessons: m.lessons.map((l, j) => ({
      id: `${m.slug}-${j}`,
      module_id: m.slug,
      title: l.title,
      title_ar: l.titleAr,
      content: null,
      content_ar: null,
      video_url: null,
      position: j + 1,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })),
  }));

  return { tracks, modules };
}

/**
 * Loads the live curriculum (tracks, modules, lessons) from Supabase.
 * Falls back to the bundled static content if the tables aren't reachable
 * (e.g. migrations not yet applied to this Supabase project).
 */
export function useCurriculum(): CurriculumState {
  const [tracks, setTracks] = useState<DbTrack[]>([]);
  const [modules, setModules] = useState<CurriculumModule[]>([]);
  const [loading, setLoading] = useState(true);
  const [usingFallback, setUsingFallback] = useState(false);

  useEffect(() => {
    let active = true;

    async function load() {
      try {
        const [{ data: trackRows, error: trackErr }, { data: moduleRows, error: moduleErr }] =
          await Promise.all([
            supabase.from("tracks").select("*").order("position"),
            supabase.from("modules").select("*").eq("published", true).order("position"),
          ]);

        if (trackErr || moduleErr || !trackRows || !moduleRows || trackRows.length === 0) {
          throw trackErr || moduleErr || new Error("No curriculum rows found");
        }

        const moduleIds = moduleRows.map((m) => m.id);
        const { data: lessonRows, error: lessonErr } = await supabase
          .from("lessons")
          .select("*")
          .in("module_id", moduleIds)
          .order("position");

        if (lessonErr) throw lessonErr;

        const lessonsByModule = new Map<string, DbLesson[]>();
        for (const lesson of lessonRows ?? []) {
          const list = lessonsByModule.get(lesson.module_id) ?? [];
          list.push(lesson);
          lessonsByModule.set(lesson.module_id, list);
        }

        const withLessons: CurriculumModule[] = moduleRows.map((m) => ({
          ...m,
          lessons: lessonsByModule.get(m.id) ?? [],
        }));

        if (!active) return;
        setTracks(trackRows);
        setModules(withLessons);
        setUsingFallback(false);
      } catch {
        if (!active) return;
        const fallback = fallbackCurriculum();
        setTracks(fallback.tracks);
        setModules(fallback.modules);
        setUsingFallback(true);
      } finally {
        if (active) setLoading(false);
      }
    }

    void load();
    return () => {
      active = false;
    };
  }, []);

  return { tracks, modules, loading, usingFallback };
}
