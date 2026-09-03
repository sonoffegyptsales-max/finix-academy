import { createFileRoute, Link } from "@tanstack/react-router";
import {
  finixCertTiers,
  finixModules,
  finixQuizTierLabels,
  finixTracks,
} from "@/content/finix";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { useFinixProgress } from "@/hooks/use-finix-progress";

export const Route = createFileRoute("/finix/")({
  head: () => ({
    meta: [
      { title: "Finix Academy — Smart Home & Industrial Automation Training" },
      {
        name: "description",
        content:
          "The Finix Academy portal: 10 modules across 4 tracks, Bronze/Silver/Gold certifications, KPI evaluations and site survey tools.",
      },
      {
        property: "og:title",
        content: "Finix Academy — Smart Home & Industrial Automation Training",
      },
    ],
  }),
  component: () => (
    <Protected>
      <FinixPortal />
    </Protected>
  ),
});

function FinixPortal() {
  const { t } = useLang();
  const { completed } = useFinixProgress();

  const stats = [
    { value: `${finixModules.length}`, label: t("Modules", "وحدة تدريبية") },
    { value: `${finixTracks.length}`, label: t("Tracks", "مسارات") },
    {
      value: `${finixCertTiers.length}-${t("Tier", "مستويات")}`,
      label: t("Certifications", "اعتمادات"),
    },
    {
      value: `${finixModules.length * 3}`,
      label: t("Tier quizzes", "اختبارات مصنفة"),
    },
  ];

  return (
    <div>
      <section className="border-b border-border bg-[radial-gradient(ellipse_at_top,var(--color-secondary),transparent_70%)]">
        <div className="mx-auto max-w-5xl px-6 py-16">
          <p className="font-mono text-xs uppercase tracking-[0.3em] text-accent">
            {t("Finix Systems", "فينيكس سيستمز")}
          </p>
          <h1 className="mt-4 text-5xl font-bold tracking-tight text-foreground">
            {t("Finix Academy", "أكاديمية فينيكس")}
          </h1>
          <p className="mt-4 max-w-2xl text-lg leading-relaxed text-muted-foreground">
            {t(
              "Professional training for smart home installers and automation engineers — from electrical foundations to protocols and field tools you use on real jobs.",
              "تدريب احترافي لمركّبي المنازل الذكية ومهندسي الأتمتة — من الأساسيات الكهربائية إلى البروتوكولات والأدوات الميدانية المستخدمة في الأعمال الحقيقية.",
            )}
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link
              to="/finix/certification"
              className="rounded-lg bg-primary px-5 py-2.5 font-medium text-primary-foreground hover:bg-primary/90"
            >
              {t("Certification path", "مسار الاعتماد")}
            </Link>
            <Link
              to="/finix/kpi"
              className="rounded-lg border border-border px-5 py-2.5 font-medium text-foreground hover:bg-secondary"
            >
              {t("KPI evaluation", "تقييم الأداء")}
            </Link>
            <Link
              to="/finix/survey"
              className="rounded-lg border border-border px-5 py-2.5 font-medium text-foreground hover:bg-secondary"
            >
              {t("Site survey tool", "أداة مسح الموقع")}
            </Link>
          </div>
        </div>
      </section>

      <div className="mx-auto max-w-5xl px-6">
        <div className="mt-8 grid grid-cols-2 gap-3 sm:grid-cols-4">
          {stats.map((s) => (
            <div key={s.label} className="rounded-xl border border-border bg-card p-5 text-center">
              <p className="text-3xl font-bold text-accent">{s.value}</p>
              <p className="mt-1 text-sm text-muted-foreground">{s.label}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 flex items-center justify-between text-sm">
          <h2 className="text-2xl font-semibold text-foreground">
            {t("Your progress", "تقدمك")}
          </h2>
          <span className="text-muted-foreground">
            {completed.length} / {finixModules.length}{" "}
            {t("modules complete", "وحدات مكتملة")}
          </span>
        </div>
        <div className="mt-2 h-2 overflow-hidden rounded-full bg-secondary">
          <div
            className="h-full rounded-full bg-accent transition-all"
            style={{ width: `${(completed.length / finixModules.length) * 100}%` }}
          />
        </div>

        {finixTracks.map((track) => {
          const trackModules = finixModules.filter((m) => m.track === track.id);
          return (
            <section key={track.id} className="mt-12">
              <h2 className="text-2xl font-semibold text-foreground">
                {t(track.name, track.nameAr)}
              </h2>
              <p className="mt-1 text-sm text-muted-foreground">
                {t(track.tagline, track.taglineAr)}
              </p>
              <div className="mt-5 grid gap-4 md:grid-cols-2">
                {trackModules.map((m) => {
                  const done = completed.includes(m.slug);
                  return (
                    <Link
                      key={m.slug}
                      to="/finix/$slug"
                      params={{ slug: m.slug }}
                      className={`flex flex-col rounded-xl border bg-card p-6 transition-colors hover:border-accent ${
                        done ? "border-accent/50" : "border-border"
                      }`}
                    >
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-xs text-muted-foreground">{m.code}</span>
                        <span className="rounded-full border border-border px-2.5 py-0.5 text-[11px] text-muted-foreground">
                          {m.lessons.length} {t("lessons", "دروس")}
                        </span>
                        <span className="rounded-full border border-border px-2.5 py-0.5 text-[11px] text-muted-foreground">
                          {t("3 quizzes", "٣ اختبارات")}
                        </span>
                        {done && (
                          <span className="rounded-full border border-accent/40 bg-accent/10 px-2.5 py-0.5 text-[11px] text-accent">
                            ✓ {t("Complete", "مكتملة")}
                          </span>
                        )}
                      </div>
                      <h3 className="mt-3 text-lg font-semibold text-foreground">
                        {t(m.title, m.titleAr)}
                      </h3>
                      <p className="mt-2 line-clamp-2 text-sm leading-relaxed text-muted-foreground">
                        {t(m.summary, m.summaryAr)}
                      </p>
                      <span className="mt-4 text-sm font-medium text-accent">
                        {t("Open module →", "افتح الوحدة ←")}
                      </span>
                    </Link>
                  );
                })}
              </div>
            </section>
          );
        })}
      </div>

      <div className="h-16" />
    </div>
  );
}
