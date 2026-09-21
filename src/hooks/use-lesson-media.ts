import { useCallback, useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";

export type MediaKind = "image" | "video" | "audio";

export interface LessonMediaRow {
  id: string;
  lesson_id: string;
  kind: MediaKind;
  storage_path: string;
  caption: string | null;
  caption_ar: string | null;
  position: number;
}

const BUCKET = "lesson-media";

/** Signed URLs are short-lived on purpose: a copied link stops working. */
const SIGNED_URL_TTL_SECONDS = 60 * 30;

export function kindForFile(file: File): MediaKind | null {
  if (file.type.startsWith("image/")) return "image";
  if (file.type.startsWith("video/")) return "video";
  if (file.type.startsWith("audio/")) return "audio";
  return null;
}

function safeName(name: string) {
  const dot = name.lastIndexOf(".");
  const ext = dot > -1 ? name.slice(dot).toLowerCase() : "";
  const base = (dot > -1 ? name.slice(0, dot) : name)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "")
    .slice(0, 60);
  return `${base || "file"}-${Date.now()}${ext}`;
}

/** Staff-side CRUD for lesson media (upload, list, delete). */
export function useLessonMedia() {
  const [uploading, setUploading] = useState(false);
  const [progressLabel, setProgressLabel] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const listForLessons = useCallback(async (lessonIds: string[]) => {
    if (lessonIds.length === 0) return [] as LessonMediaRow[];
    const { data, error } = await supabase
      .from("lesson_media")
      .select("*")
      .in("lesson_id", lessonIds)
      .order("position");
    if (error) throw error;
    return (data ?? []) as LessonMediaRow[];
  }, []);

  const upload = useCallback(
    async (lessonId: string, file: File, caption: string, captionAr: string, position: number) => {
      const kind = kindForFile(file);
      if (!kind) {
        setError("Unsupported file type — use an image, video or audio file.");
        return null;
      }
      setUploading(true);
      setError(null);
      setProgressLabel(`Uploading ${file.name}…`);
      try {
        const path = `${lessonId}/${safeName(file.name)}`;
        const { error: upErr } = await supabase.storage
          .from(BUCKET)
          .upload(path, file, { cacheControl: "3600", upsert: false });
        if (upErr) throw upErr;

        const { data, error: rowErr } = await supabase
          .from("lesson_media")
          .insert({
            lesson_id: lessonId,
            kind,
            storage_path: path,
            caption: caption || null,
            caption_ar: captionAr || null,
            position,
          })
          .select()
          .single();
        if (rowErr) {
          // Roll back the orphaned object so storage doesn't drift.
          await supabase.storage.from(BUCKET).remove([path]);
          throw rowErr;
        }
        return data as LessonMediaRow;
      } catch (e) {
        setError(e instanceof Error ? e.message : "Upload failed");
        return null;
      } finally {
        setUploading(false);
        setProgressLabel(null);
      }
    },
    [],
  );

  const remove = useCallback(async (row: LessonMediaRow) => {
    setError(null);
    try {
      await supabase.storage.from(BUCKET).remove([row.storage_path]);
      const { error } = await supabase.from("lesson_media").delete().eq("id", row.id);
      if (error) throw error;
      return true;
    } catch (e) {
      setError(e instanceof Error ? e.message : "Delete failed");
      return false;
    }
  }, []);

  const updateCaption = useCallback(
    async (id: string, caption: string, captionAr: string) => {
      const { error } = await supabase
        .from("lesson_media")
        .update({ caption: caption || null, caption_ar: captionAr || null })
        .eq("id", id);
      if (error) setError(error.message);
    },
    [],
  );

  return { uploading, progressLabel, error, listForLessons, upload, remove, updateCaption };
}

/**
 * Resolves media rows to short-lived signed URLs for playback/display.
 * Re-signs automatically before expiry so long lessons keep working.
 */
export function useSignedMedia(rows: LessonMediaRow[]) {
  const [urls, setUrls] = useState<Record<string, string>>({});

  const key = rows.map((r) => r.id).join(",");

  useEffect(() => {
    let active = true;

    async function sign() {
      if (rows.length === 0) {
        if (active) setUrls({});
        return;
      }
      const paths = rows.map((r) => r.storage_path);
      const { data, error } = await supabase.storage
        .from(BUCKET)
        .createSignedUrls(paths, SIGNED_URL_TTL_SECONDS);
      if (error || !data || !active) return;

      const next: Record<string, string> = {};
      data.forEach((entry, i) => {
        if (entry.signedUrl) next[rows[i].id] = entry.signedUrl;
      });
      setUrls(next);
    }

    void sign();
    // Re-sign a little before the URLs expire.
    const timer = setInterval(sign, (SIGNED_URL_TTL_SECONDS - 120) * 1000);
    return () => {
      active = false;
      clearInterval(timer);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [key]);

  return urls;
}
