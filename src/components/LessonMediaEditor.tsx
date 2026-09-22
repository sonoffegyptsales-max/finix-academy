import { useRef, useState } from "react";
import { useLang } from "@/lib/language";
import {
  useLessonMedia,
  useSignedMedia,
  kindForFile,
  type LessonMediaRow,
} from "@/hooks/use-lesson-media";

/**
 * Staff-side media manager for a single lesson: upload images, video and
 * audio, caption them bilingually, preview and delete.
 */
export function LessonMediaEditor({
  lessonId,
  media,
  onChanged,
}: {
  lessonId: string;
  media: LessonMediaRow[];
  onChanged: () => void;
}) {
  const { t } = useLang();
  const { upload, remove, updateCaption, uploading, progressLabel, error } = useLessonMedia();
  const urls = useSignedMedia(media);
  const fileRef = useRef<HTMLInputElement>(null);
  const [caption, setCaption] = useState("");
  const [captionAr, setCaptionAr] = useState("");

  async function handleFiles(files: FileList | null) {
    if (!files || files.length === 0) return;
    let position = media.length + 1;
    for (const file of Array.from(files)) {
      if (!kindForFile(file)) continue;
      await upload(lessonId, file, caption, captionAr, position);
      position += 1;
    }
    setCaption("");
    setCaptionAr("");
    if (fileRef.current) fileRef.current.value = "";
    onChanged();
  }

  async function handleRemove(row: LessonMediaRow) {
    const ok = await remove(row);
    if (ok) onChanged();
  }

  return (
    <div className="mt-3 rounded-lg border border-dashed border-border p-3">
      <p className="mb-2 text-xs font-medium text-foreground">
        {t("Media (images · video · audio)", "الوسائط (صور · فيديو · صوت)")}
      </p>

      {error && <p className="mb-2 text-xs text-destructive">{error}</p>}

      {media.length > 0 && (
        <div className="mb-3 space-y-2">
          {media.map((m) => {
            const src = urls[m.id];
            return (
              <div key={m.id} className="flex items-start gap-3 rounded-lg border border-border p-2">
                <div className="w-28 flex-shrink-0">
                  {!src ? (
                    <div className="flex h-16 items-center justify-center rounded bg-secondary text-[10px] text-muted-foreground">
                      …
                    </div>
                  ) : m.kind === "image" ? (
                    <img src={src} alt="" className="h-16 w-full rounded object-cover" />
                  ) : m.kind === "video" ? (
                    <video src={src} className="h-16 w-full rounded object-cover" muted />
                  ) : (
                    <div className="flex h-16 items-center justify-center rounded bg-secondary text-[10px] text-muted-foreground">
                      ♪ {t("audio", "صوت")}
                    </div>
                  )}
                </div>
                <div className="flex-1 space-y-1.5">
                  <input
                    defaultValue={m.caption ?? ""}
                    onBlur={(e) => updateCaption(m.id, e.target.value, m.caption_ar ?? "")}
                    placeholder={t("Caption (English)", "تعليق (إنجليزي)")}
                    className="w-full rounded border border-border bg-background px-2 py-1 text-xs"
                  />
                  <input
                    dir="rtl"
                    defaultValue={m.caption_ar ?? ""}
                    onBlur={(e) => updateCaption(m.id, m.caption ?? "", e.target.value)}
                    placeholder={t("Caption (Arabic)", "تعليق (عربي)")}
                    className="w-full rounded border border-border bg-background px-2 py-1 text-xs"
                  />
                </div>
                <button
                  onClick={() => handleRemove(m)}
                  className="text-xs text-destructive hover:underline"
                >
                  {t("Remove", "إزالة")}
                </button>
              </div>
            );
          })}
        </div>
      )}

      <div className="grid gap-2 sm:grid-cols-2">
        <input
          value={caption}
          onChange={(e) => setCaption(e.target.value)}
          placeholder={t("Caption for next upload (English)", "تعليق للرفع التالي (إنجليزي)")}
          className="rounded border border-border bg-background px-2 py-1.5 text-xs"
        />
        <input
          dir="rtl"
          value={captionAr}
          onChange={(e) => setCaptionAr(e.target.value)}
          placeholder={t("Caption for next upload (Arabic)", "تعليق للرفع التالي (عربي)")}
          className="rounded border border-border bg-background px-2 py-1.5 text-xs"
        />
      </div>

      <input
        ref={fileRef}
        type="file"
        multiple
        accept="image/*,video/*,audio/*"
        onChange={(e) => handleFiles(e.target.files)}
        disabled={uploading}
        className="mt-2 block w-full text-xs file:me-3 file:rounded-lg file:border-0 file:bg-primary file:px-3 file:py-1.5 file:text-xs file:font-medium file:text-primary-foreground hover:file:opacity-90 disabled:opacity-50"
      />

      <p className="mt-1.5 text-[11px] text-muted-foreground">
        {uploading
          ? (progressLabel ?? t("Uploading…", "جارٍ الرفع…"))
          : t(
              "Up to 500 MB per file. Trainees view media inside the app only — no download link is created.",
              "حتى ٥٠٠ ميجابايت للملف. يشاهد المتدربون الوسائط داخل التطبيق فقط — لا يُنشأ رابط تنزيل.",
            )}
      </p>
    </div>
  );
}
