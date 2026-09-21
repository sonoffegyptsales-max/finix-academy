import { createFileRoute, Link, useParams } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { useCurriculum } from "@/hooks/use-curriculum";
import { useEnrollments } from "@/hooks/use-enrollments";
import { ProtectedContent } from "@/components/ProtectedContent";
import { LessonMedia } from "@/components/LessonMedia";
import { useLessonMedia, type LessonMediaRow } from "@/hooks/use-lesson-media";

export const Route = createFileRoute("/dashboard/module/$slug")({
  head: () => ({
    meta: [{ title: "Module — Finix Academy" }],
  }),
  component: () => (
    <Protected>
      <ModulePage />
    </Protected>
  ),
});

function ModulePage() {
  const { slug } = useParams({ from: "/dashboard/module/$slug" });
  const { t } = useLang();
  const { tracks, modules, loading } = useCurriculum();
  const moduleIdBySlug = Object.fromEntries(modules.map((m) => [m.slug, m.id]));
  const { toggle, isComplete } = useEnrollments(moduleIdBySlug);
  const { listForLessons } = useLessonMedia();
  const [media, setMedia] = useState<LessonMediaRow[]>([]);

  const mod = modules.find((m) => m.slug === slug);
  const lessonIdKey = (mod?.lessons ?? []).map((l) => l.id).join(",");

  useEffect(() => {
    let active = true;
    const ids = lessonIdKey ? lessonIdKey.split(",") : [];
    if (ids.length === 0) {
      setMedia([]);
      return;
    }
    void listForLessons(ids)
      .then((rows) => {
        if (active) setMedia(rows);
      })
      .catch(() => {
        if (active) setMedia([]);
      });
    return () => {
      active = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [lessonIdKey]);

  if (loading) {
    return (
      <div className="mx-auto max-w-3xl px-6 py-20 text-center text-sm text-muted-foreground">
        {t("Loading…", "جارٍ التحميل…")}
      </div>
    );
  }

  if (!mod) {
    return (
      <div className="mx-auto max-w-md px-6 py-24 text-center">
        <h1 className="text-2xl font-bold text-foreground">
          {t("Module not found", "الوحدة غير موجودة")}
        </h1>
        <Link to="/dashboard/my-courses" className="mt-6 inline-block text-sm font-medium text-primary">
          {t("← Back to My Courses", "← العودة إلى دوراتي")}
        </Link>
      </div>
    );
  }

  const index = modules.indexOf(mod);
  const track = tracks.find((tr) => tr.id === mod.track_id);
  const prev = modules[index - 1];
  const next = modules[index + 1];
  const done = isComplete(mod.slug);

  return (
    <div className="mx-auto max-w-3xl px-6 py-14">
      <Link to="/dashboard/my-courses" className="text-sm text-muted-foreground hover:text-primary">
        {t("← My Courses", "← دوراتي")}
      </Link>

      <div className="mt-6 flex flex-wrap items-center gap-2">
        <span className="font-mono text-xs text-muted-foreground">{mod.code}</span>
        {track && (
          <span className="rounded-full border border-border px-2.5 py-0.5 text-[11px] text-muted-foreground">
            {t(track.name, track.name_ar)}
          </span>
        )}
        {done && (
          <span className="rounded-full border border-green-300 bg-green-500/10 px-2.5 py-0.5 text-[11px] text-green-700">
            ✓ {t("Complete", "مكتملة")}
          </span>
        )}
      </div>

      <h1 className="mt-3 text-4xl font-bold tracking-tight text-foreground">
        {t(mod.title, mod.title_ar)}
      </h1>
      <p className="mt-4 text-lg leading-relaxed text-muted-foreground">
        {t(mod.summary, mod.summary_ar)}
      </p>

      <section className="mt-8">
        <h2 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
          {t("Lessons", "الدروس")}
        </h2>
        <ProtectedContent>
          <ol className="mt-3 divide-y divide-border rounded-xl border border-border bg-card">
            {mod.lessons.map((lesson, i) => (
              <li key={lesson.id} className="p-4">
                <div className="flex items-center gap-3">
                  <span className="font-mono text-xs text-muted-foreground">
                    {String(i + 1).padStart(2, "0")}
                  </span>
                  <span className="text-sm text-foreground">{t(lesson.title, lesson.title_ar)}</span>
                </div>
                {lesson.content || lesson.content_ar ? (
                  <p className="mt-2 ml-8 whitespace-pre-line text-sm leading-relaxed text-muted-foreground">
                    {t(lesson.content ?? "", lesson.content_ar ?? "")}
                  </p>
                ) : null}
                <LessonMedia media={media.filter((m) => m.lesson_id === lesson.id)} />
              </li>
            ))}
          </ol>
        </ProtectedContent>
      </section>

      <section className="mt-8">
        <h2 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
          {t("Quizzes", "الاختبارات")}
        </h2>
        <div className="mt-3 flex flex-wrap gap-3">
          {(["bronze", "silver", "gold"] as const).map((tier) => (
            <Link
              key={tier}
              to="/dashboard/quiz/$slug/$tier"
              params={{ slug: mod.slug, tier }}
              className="rounded-lg border border-border bg-card px-5 py-2.5 text-sm font-medium text-foreground transition-colors hover:border-primary capitalize"
            >
              {t(tier, { bronze: "برونزي", silver: "فضي", gold: "ذهبي" }[tier])} {t("Quiz", "اختبار")} →
            </Link>
          ))}
        </div>
      </section>

      <p className="mt-6 text-xs text-muted-foreground">
        {t(
          "This material is licensed to your account only. Each page is watermarked with your identity; sharing or redistributing it is traceable.",
          "هذه المادة مرخصة لحسابك فقط. كل صفحة تحمل علامة مائية بهويتك؛ ومشاركتها أو إعادة توزيعها قابل للتتبع.",
        )}
      </p>

      <div className="mt-8 flex flex-wrap items-center gap-3">
        <button
          onClick={() => toggle(mod.slug)}
          className={`rounded-lg px-5 py-2.5 font-medium transition-colors ${
            done
              ? "border border-border text-foreground hover:bg-secondary"
              : "bg-primary text-primary-foreground hover:bg-primary/90"
          }`}
        >
          {done
            ? t("Mark as not complete", "إلغاء وضع مكتملة")
            : t("Mark module complete", "تحديد الوحدة كمكتملة")}
        </button>
        <Link
          to="/dashboard/certifications"
          className="text-sm font-medium text-primary hover:underline"
        >
          {t("Check your certification progress →", "تحقق من تقدم الاعتماد ←")}
        </Link>
      </div>

      <nav className="mt-12 flex justify-between border-t border-border pt-6 text-sm">
        {prev ? (
          <Link
            to="/dashboard/module/$slug"
            params={{ slug: prev.slug }}
            className="text-muted-foreground hover:text-primary"
          >
            ← {t(prev.title, prev.title_ar)}
          </Link>
        ) : (
          <span />
        )}
        {next && (
          <Link
            to="/dashboard/module/$slug"
            params={{ slug: next.slug }}
            className="text-muted-foreground hover:text-primary"
          >
            {t(next.title, next.title_ar)} →
          </Link>
        )}
      </nav>
    </div>
  );
}
