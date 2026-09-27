import { useLang } from "@/lib/language";
import { type LessonMediaRow } from "@/hooks/use-lesson-media";

/** True when this row is an external recommendation rather than a bucket object. */
export function isExternal(m: LessonMediaRow): boolean {
  return /^https?:\/\//i.test(m.storage_path);
}

function hostLabel(url: string): string {
  try {
    const h = new URL(url).hostname.replace(/^www\./, "");
    return h === "youtu.be" ? "youtube.com" : h;
  } catch {
    return "";
  }
}

/**
 * Recommended external video resources for a lesson.
 *
 * These are third-party videos, so they are LINKS, never embeds: re-hosting or
 * embedding someone else's video is a copyright problem, and a link also keeps
 * the no-download policy intact — the trainee leaves to watch and comes back.
 *
 * Every caption says WHY the video is assigned. An unexplained video is
 * homework; one with a stated purpose is training.
 */
export function LessonResources({ media }: { media: LessonMediaRow[] }) {
  const { t } = useLang();
  const items = media.filter(isExternal);
  if (items.length === 0) return null;

  return (
    <section className="mt-4 rounded-lg border border-border bg-secondary/30 p-4">
      <h4 className="flex items-center gap-2 text-sm font-semibold text-foreground">
        <svg viewBox="0 0 24 24" className="h-4 w-4 shrink-0 text-primary" aria-hidden="true">
          <path
            d="M10 8.5v7l6-3.5-6-3.5z"
            fill="currentColor"
          />
          <rect
            x="2.5" y="4.5" width="19" height="15" rx="2.5"
            fill="none" stroke="currentColor" strokeWidth="1.6"
          />
        </svg>
        {t("Recommended videos", "فيديوهات مقترحة")}
        <span className="text-xs font-normal text-muted-foreground">
          ({items.length})
        </span>
      </h4>

      <p className="mt-1 text-xs text-muted-foreground">
        {t(
          "External resources. They open in a new tab — read why each one is assigned before watching.",
          "مصادر خارجية تُفتح في تبويب جديد. اقرأ سبب ترشيح كل فيديو قبل المشاهدة.",
        )}
      </p>

      <ul className="mt-3 space-y-2.5">
        {items.map((m) => {
          const why = t(m.caption ?? "", m.caption_ar ?? "");
          const host = hostLabel(m.storage_path);
          return (
            <li key={m.id}>
              <a
                href={m.storage_path}
                target="_blank"
                rel="noopener noreferrer"
                className="group block rounded-md border border-border bg-background p-3 transition-colors hover:border-primary/60 hover:bg-secondary/50"
              >
                <span className="flex items-center gap-2 text-sm font-medium text-foreground group-hover:text-primary">
                  {t("Watch on", "شاهد على")} {/* host is Latin: pin LTR so
                      bidi does not move the domain's dot in an Arabic line */}
                  <span dir="ltr" className="font-mono text-xs">{host}</span>
                  <svg viewBox="0 0 24 24" className="h-3.5 w-3.5 shrink-0 rtl:-scale-x-100" aria-hidden="true">
                    <path
                      d="M7 17L17 7M17 7H9M17 7v8"
                      fill="none" stroke="currentColor" strokeWidth="2"
                      strokeLinecap="round" strokeLinejoin="round"
                    />
                  </svg>
                </span>
                {why && (
                  <span className="mt-1 block text-xs leading-relaxed text-muted-foreground">
                    {why}
                  </span>
                )}
              </a>
            </li>
          );
        })}
      </ul>
    </section>
  );
}
