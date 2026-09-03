import { createFileRoute, Link } from "@tanstack/react-router";
import {
  FINIX_QUIZ_PASS_PERCENT,
  finixModules,
  finixQuizTierLabels,
  finixQuizTiers,
  finixTracks,
} from "@/content/finix";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { useFinixProgress } from "@/hooks/use-finix-progress";

export const Route = createFileRoute("/finix/$slug")({
  head: () => ({
    meta: [{ title: "Module — Finix Academy" }],
  }),
  component: () => (
    <Protected>
      <FinixModulePage />
    </Protected>
  ),
});

function FinixModulePage() {
  const { t } = useLang();
  const { slug } = Route.useParams();
  const { toggle, isComplete } = useFinixProgress();

  const module = finixModules.find((m) => m.slug === slug);

  if (!module) {
    return (
      <div className="mx-auto max-w-md px-6 py-24 text-center">
        <h1 className="text-2xl font-bold text-foreground">
          {t("Module not found", "الوحدة غير موجودة")}
        </h1>
        <Link to="/finix" className="mt-6 inline-block text-sm font-medium text-accent">
          {t("← Back to Finix Academy", "← العودة إلى أكاديمية فينيكس")}
        </Link>
      </div>
    );
  }

  const index = finixModules.indexOf(module);
  const track = finixTracks.find((tr) => tr.id === module.track);
  const prev = finixModules[index - 1];
  const next = finixModules[index + 1];
  const done = isComplete(module.slug);

  return (
    <div className="mx-auto max-w-3xl px-6 py-14">
      <Link to="/finix" className="text-sm text-muted-foreground hover:text-accent">
        {t("← Finix Academy", "← أكاديمية فينيكس")}
      </Link>

      <div className="mt-6 flex flex-wrap items-center gap-2">
        <span className="font-mono text-xs text-muted-foreground">{module.code}</span>
        {track && (
          <span className="rounded-full border border-border px-2.5 py-0.5 text-[11px] text-muted-foreground">
            {t(track.name, track.nameAr)}
          </span>
        )}
        {done && (
          <span className="rounded-full border border-accent/40 bg-accent/10 px-2.5 py-0.5 text-[11px] text-accent">
            ✓ {t("Complete", "مكتملة")}
          </span>
        )}
      </div>

      <h1 className="mt-3 text-4xl font-bold tracking-tight text-foreground">
        {t(module.title, module.titleAr)}
      </h1>
      <p className="mt-4 text-lg leading-relaxed text-muted-foreground">
        {t(module.summary, module.summaryAr)}
      </p>

      <section className="mt-8">
        <h2 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
          {t("Lessons", "الدروس")}
        </h2>
        <ol className="mt-3 divide-y divide-border rounded-xl border border-border bg-card">
          {module.lessons.map((lesson, i) => (
            <li key={lesson.title} className="flex items-center justify-between gap-4 p-4">
              <span className="flex items-center gap-3 text-sm text-foreground">
                <span className="font-mono text-xs text-muted-foreground">
                  {String(i + 1).padStart(2, "0")}
                </span>
                {t(lesson.title, lesson.titleAr)}
              </span>
            </li>
          ))}
        </ol>
        <a
          href={module.url}
          target="_blank"
          rel="noreferrer"
          className="mt-3 inline-block rounded-lg bg-primary px-5 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90"
        >
          {t("Study this module in Finix Academy ↗", "ادرس هذه الوحدة في أكاديمية فينيكس ↗")}
        </a>
      </section>

      <section className="mt-8">
        <h2 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
          {t(
            `Quizzes — ${FINIX_QUIZ_PASS_PERCENT}% or above earns the tier`,
            `الاختبارات — نسبة ${FINIX_QUIZ_PASS_PERCENT}٪ أو أعلى تمنح الاعتماد`,
          )}
        </h2>
        <div className="mt-3 flex flex-wrap gap-3">
          {finixQuizTiers.map((tier) => (
            <a
              key={tier}
              href={module.url}
              target="_blank"
              rel="noreferrer"
              className="rounded-lg border border-border bg-card px-5 py-2.5 text-sm font-medium text-foreground transition-colors hover:border-accent"
            >
              {t(
                finixQuizTierLabels[tier].en + " quiz ↗",
                "اختبار " + finixQuizTierLabels[tier].ar + " ↗",
              )}
            </a>
          ))}
        </div>
      </section>

      <div className="mt-8 flex flex-wrap items-center gap-3">
        <button
          onClick={() => toggle(module.slug)}
          className={`rounded-lg px-5 py-2.5 font-medium transition-colors ${
            done
              ? "border border-border text-foreground hover:bg-secondary"
              : "bg-accent text-white hover:bg-accent/90"
          }`}
        >
          {done
            ? t("Mark as not complete", "إلغاء وضع مكتملة")
            : t("Mark module complete", "تحديد الوحدة كمكتملة")}
        </button>
        <Link
          to="/finix/certification"
          className="text-sm font-medium text-accent hover:underline"
        >
          {t("Check your certification progress →", "تحقق من تقدم الاعتماد ←")}
        </Link>
      </div>

      <nav className="mt-12 flex justify-between border-t border-border pt-6 text-sm">
        {prev ? (
          <Link to="/finix/$slug" params={{ slug: prev.slug }} className="text-muted-foreground hover:text-accent">
            ← {t(prev.title, prev.titleAr)}
          </Link>
        ) : (
          <span />
        )}
        {next && (
          <Link to="/finix/$slug" params={{ slug: next.slug }} className="text-muted-foreground hover:text-accent">
            {t(next.title, next.titleAr)} →
          </Link>
        )}
      </nav>
    </div>
  );
}
