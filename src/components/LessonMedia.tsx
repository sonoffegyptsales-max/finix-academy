import { useLang } from "@/lib/language";
import { useSignedMedia, type LessonMediaRow } from "@/hooks/use-lesson-media";
import { isExternal } from "@/components/LessonResources";

/**
 * Renders a lesson's images, video and audio inline.
 *
 * Playback happens here, in Finix Academy — there is no external app and no
 * download path. Sources are short-lived signed URLs, downloads are disabled
 * on the players, and the surrounding ProtectedContent wrapper still applies
 * its watermark and copy deterrents.
 */
export function LessonMedia({ media }: { media: LessonMediaRow[] }) {
  const { t } = useLang();
  // External recommendations (kind 'video' whose storage_path is a URL) are
  // rendered by LessonResources as links. They must be excluded here or each
  // would become a <video src="https://youtube.com/watch?v=..."> that can
  // never play, showing a broken player on the lesson.
  const media_ = media.filter((m) => !isExternal(m));
  const urls = useSignedMedia(media_);

  if (media_.length === 0) return null;

  return (
    <div className="mt-3 space-y-4">
      {media_.map((m) => {
        const src = urls[m.id];
        const caption = t(m.caption ?? "", m.caption_ar ?? "");

        return (
          <figure key={m.id} className="overflow-hidden rounded-lg border border-border bg-background">
            {!src ? (
              <div className="flex h-32 items-center justify-center text-xs text-muted-foreground">
                {t("Loading media…", "جارٍ تحميل الوسائط…")}
              </div>
            ) : m.kind === "image" ? (
              <img
                src={src}
                alt={caption || t("Lesson figure", "صورة توضيحية")}
                className="block w-full select-none"
                draggable={false}
                onContextMenu={(e) => e.preventDefault()}
              />
            ) : m.kind === "video" ? (
              <video
                src={src}
                controls
                controlsList="nodownload noplaybackrate"
                disablePictureInPicture
                className="block w-full"
                onContextMenu={(e) => e.preventDefault()}
              />
            ) : (
              <audio
                src={src}
                controls
                controlsList="nodownload"
                className="w-full p-3"
                onContextMenu={(e) => e.preventDefault()}
              />
            )}

            {caption && (
              <figcaption className="border-t border-border px-3 py-2 text-xs text-muted-foreground">
                {caption}
              </figcaption>
            )}
          </figure>
        );
      })}
    </div>
  );
}
