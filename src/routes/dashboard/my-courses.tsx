import { createFileRoute, Link } from "@tanstack/react-router";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { useCurriculum } from "@/hooks/use-curriculum";
import { useEnrollments } from "@/hooks/use-enrollments";

export const Route = createFileRoute("/dashboard/my-courses")({
  head: () => ({
    meta: [{ title: "My Courses — Finix Academy" }],
  }),
  component: () => (
    <Protected>
      <MyCoursesPage />
    </Protected>
  ),
});

const trackColors: Record<string, string> = {
  "hardware-foundations": "bg-sky-500/10 text-sky-600",
  "networking-protocols": "bg-green-500/10 text-green-600",
  "team-project-management": "bg-amber-500/10 text-amber-600",
  "survey-terminology-tools": "bg-purple-500/10 text-purple-600",
};

function MyCoursesPage() {
  const { t } = useLang();
  const { tracks, modules, loading, usingFallback } = useCurriculum();
  const moduleIdBySlug = Object.fromEntries(modules.map((m) => [m.slug, m.id]));
  const { completed, toggle } = useEnrollments(moduleIdBySlug);

  if (loading) {
    return (
      <div className="p-6 text-center text-sm text-muted-foreground">
        {t("Loading courses…", "جارٍ تحميل الدورات…")}
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">{t("My Courses", "دوراتي")}</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {modules.length} {t("modules", "وحدة")} · {tracks.length} {t("tracks", "مسارات")}
          </p>
        </div>
        <span className="rounded-full bg-primary/10 px-3 py-1 text-xs font-medium text-primary">
          {completed.length} / {modules.length} {t("complete", "مكتملة")}
        </span>
      </div>

      {usingFallback && (
        <div className="mb-6 rounded-lg border border-amber-300 bg-amber-50 px-4 py-3 text-xs text-amber-800">
          {t(
            "Showing bundled course data — backend curriculum tables aren't connected yet.",
            "يتم عرض بيانات الدورات المدمجة — لم يتم توصيل جداول المنهج في الخادم بعد.",
          )}
        </div>
      )}

      {tracks.map((track) => {
        const trackModules = modules.filter((m) => m.track_id === track.id);
        if (trackModules.length === 0) return null;

        return (
          <section key={track.id} className="mb-8">
            <div className="mb-4 flex items-center gap-2">
              <span
                className={`rounded-full px-3 py-1 text-xs font-medium ${
                  trackColors[track.id] ?? "bg-gray-500/10 text-gray-600"
                }`}
              >
                {t(track.name, track.name_ar)}
              </span>
              <span className="text-xs text-muted-foreground">
                {trackModules.length} {t("modules", "وحدات")}
              </span>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              {trackModules.map((mod) => {
                const done = completed.includes(mod.slug);
                return (
                  <div
                    key={mod.slug}
                    className={`overflow-hidden rounded-xl border bg-card p-5 shadow-sm transition-colors ${
                      done ? "border-green-300 bg-green-50/30" : "border-border hover:border-primary/50 hover:bg-primary/5"
                    }`}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-xs text-muted-foreground">{mod.code}</span>
                        <span className="rounded-full border border-border bg-secondary px-2 py-0.5 text-[11px] text-muted-foreground">
                          {mod.lessons.length} {t("lessons", "دروس")}
                        </span>
                      </div>
                      {done ? (
                        <span className="rounded-full bg-green-500/10 px-2.5 py-0.5 text-[11px] font-medium text-green-700">
                          ✓ {t("Complete", "مكتملة")}
                        </span>
                      ) : (
                        <span className="rounded-full border border-primary/20 bg-primary/10 px-2.5 py-0.5 text-[11px] font-medium text-primary">
                          {t("Not started", "لم يبدأ")}
                        </span>
                      )}
                    </div>
                    <h3 className="mt-3 text-base font-semibold text-foreground">
                      {t(mod.title, mod.title_ar)}
                    </h3>
                    <p className="mt-2 text-sm leading-relaxed text-muted-foreground line-clamp-2">
                      {t(mod.summary, mod.summary_ar)}
                    </p>

                    <div className="mt-4 flex flex-wrap items-center gap-2">
                      <Link
                        to="/dashboard/module/$slug"
                        params={{ slug: mod.slug }}
                        className="inline-flex items-center gap-1.5 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
                      >
                        {t("Open Module", "افتح الوحدة")}
                      </Link>
                      {["bronze", "silver", "gold"].map((tier) => (
                        <Link
                          key={tier}
                          to="/dashboard/quiz/$slug/$tier"
                          params={{ slug: mod.slug, tier }}
                          className="rounded-full border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:border-primary hover:text-primary transition-colors capitalize"
                        >
                          {tier}
                        </Link>
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
          </section>
        );
      })}
    </div>
  );
}
