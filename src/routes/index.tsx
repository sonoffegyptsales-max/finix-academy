import { createFileRoute, Link } from "@tanstack/react-router";
import { finixCertTiers } from "@/content/finix";
import { useAuth } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { useCatalogStats } from "@/hooks/use-catalog-stats";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Finix Academy — Smart Home & Industrial Automation Training" },
      {
        name: "description",
        content:
          "Bilingual professional training for smart home installers and industrial control technicians: 22 modules across 3 tracks, Bronze/Silver/Gold certification, hands-on training on the Finix Alpha Control platform.",
      },
      { property: "og:title", content: "Finix Academy — Smart Home & Industrial Automation Training" },
      { property: "og:type", content: "website" },
    ],
  }),
  component: Landing,
});

function Landing() {
  const { t } = useLang();
  const { user } = useAuth();
  const live = useCatalogStats();

  // Live counts from the database. The old static source said 10 modules /
  // 4 tracks -- the real curriculum is 22 / 3. Render nothing until real
  // numbers arrive instead of flashing a wrong figure.
  const stats = live
    ? [
        { value: `${live.tracks}`, label: t("Tracks", "مسارات") },
        { value: `${live.modules}`, label: t("Modules", "وحدة تدريبية") },
        { value: `${live.lessons}`, label: t("Lessons", "درس") },
        { value: `${live.questions}`, label: t("Quiz questions", "سؤال تقييم") },
      ]
    : [];

  return (
    <div>
      {/* Hero — light background, matches target public page */}
      <section className="relative border-b border-border bg-background">
        <div className="mx-auto max-w-5xl px-6 py-24 md:py-32">
          <p className="font-mono text-xs uppercase tracking-[0.3em] text-muted-foreground">
            {t("Smart Home & Industrial Automation", "المنازل الذكية والأتمتة الصناعية")}
          </p>
          <h1 className="mt-5 text-5xl font-bold leading-tight tracking-tight text-foreground md:text-6xl">
            {t("Finix Academy", "أكاديمية فينيكس")}
          </h1>
          <p className="mt-8 max-w-2xl text-lg leading-relaxed text-muted-foreground">
            {t(
              "Professional training for smart home installers and automation engineers — structured curriculum, tiered certifications, and the field tools you use on real jobs.",
              "تدريب احترافي لمركّبي المنازل الذكية ومهندسي الأتمتة — منهج منظم واعتمادات متدرجة وأدوات ميدانية مستخدمة في الأعمال الحقيقية.",
            )}
          </p>
          <div className="mt-10 flex flex-wrap gap-3">
            {user ? (
              <Link
                to="/dashboard"
                className="rounded-lg bg-primary px-8 py-3 font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
              >
                {t("Start Learning", "ابدأ التعلم")}
              </Link>
            ) : (
              <Link
                to="/auth"
                className="rounded-lg bg-primary px-8 py-3 font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
              >
                {t("Start Learning", "ابدأ التعلم")}
              </Link>
            )}
          </div>
        </div>
      </section>

      {/* Stats bar */}
      <section className="border-b border-border bg-background">
        <div className="mx-auto max-w-5xl px-6 py-12">
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
            {stats.map((s) => (
              <div
                key={s.label}
                className="rounded-xl border border-border bg-card p-6 text-center shadow-sm"
              >
                <p className="text-3xl font-bold text-primary">{s.value}</p>
                <p className="mt-1 text-sm text-muted-foreground">{s.label}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Feature cards — dark slate section matching target */}
      <section className="relative bg-[slate-900] bg-[length:100%_100%]">
        <div className="mx-auto max-w-5xl px-6 py-20">
          <div className="grid gap-6 md:grid-cols-3">
            <div className="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"/>
                  </svg>
                </div>
                <h3 className="text-xl font-semibold text-foreground">
                  {t("Alpha Control Hands-On", "تدريب عملي على Alpha Control")}
                </h3>
              </div>
              <p className="mt-4 text-sm leading-relaxed text-muted-foreground">
                {t(
                  "Train on Finix Systems' own stackable controller — 16 inputs, 16 relay outputs, High-Current, Sound and Interlock modules",
                  "اتدرّب على كنترولر Finix Systems نفسه — 16 دخل و16 خرج ريليه، ووحدات التيار العالي والصوت والقفل التبادلي",
                )}
              </p>
            </div>

            <div className="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-accent/10 text-accent">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <circle cx="12" cy="8" r="7"/>
                    <path d="M18 20a3 3 0 0 0-3-3M6 20a3 3 0 0 1 3-3"/>
                    <path d="M12 13v4l1 2"/>
                  </svg>
                </div>
                <h3 className="text-xl font-semibold text-foreground">
                  {t(`${finixCertTiers.length}-Tier Certification`, "شهادة بثلاث مستويات")}
                </h3>
              </div>
              <p className="mt-4 text-sm leading-relaxed text-muted-foreground">
                {t("Bronze, Silver & Gold on every module", "برونزي وفضي وذهبي في كل وحدة")}
              </p>
            </div>

            <div className="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-green-500/10 text-green-400">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    <path d="m9 12 2 2 4-4"/>
                  </svg>
                </div>
                <h3 className="text-xl font-semibold text-foreground">
                  {t("Field Ready", "جاهزية ميدانية")}
                </h3>
              </div>
              <p className="mt-4 text-sm leading-relaxed text-muted-foreground">
                {t("KPI evaluations & site survey tools", "تقييمات أداء وأدوات مسح الموقع")}
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
