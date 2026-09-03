import { createFileRoute, Link } from "@tanstack/react-router";
import {
  finixCertTiers,
  finixModules,
  finixSurveyStages,
  finixTracks,
} from "@/content/finix";
import { useAuth } from "@/lib/auth";
import { useLang } from "@/lib/language";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Finix Academy — Smart Home & Industrial Automation Training" },
      {
        name: "description",
        content:
          "Professional training for smart home installers and automation engineers: 10 modules across 4 tracks, Bronze/Silver/Gold certifications, KPI evaluations and site survey tools.",
      },
      {
        property: "og:title",
        content: "Finix Academy — Smart Home & Industrial Automation Training",
      },
      { property: "og:type", content: "website" },
    ],
  }),
  component: Landing,
});

function Landing() {
  const { t } = useLang();
  const { user } = useAuth();

  const stats = [
    { value: `${finixModules.length}`, label: t("Modules", "وحدة تدريبية") },
    { value: `${finixTracks.length}`, label: t("Tracks", "مسارات") },
    {
      value: `${finixCertTiers.length}-${t("Tier", "مستويات")}`,
      label: t("Certs", "اعتمادات"),
    },
    {
      value: `${finixSurveyStages.length}`,
      label: t("Survey stages", "مراحل المسح"),
    },
  ];

  return (
    <div>
      <section className="border-b border-border bg-[radial-gradient(ellipse_at_top,var(--color-secondary),transparent_70%)]">
        <div className="mx-auto max-w-5xl px-6 py-24">
          <p className="font-mono text-xs uppercase tracking-[0.3em] text-accent">
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
                to="/finix"
                className="rounded-lg bg-primary px-6 py-3 font-medium text-primary-foreground hover:bg-primary/90"
              >
                {t("Open your portal", "افتح لوحتك")}
              </Link>
            ) : (
              <Link
                to="/auth"
                className="rounded-lg bg-primary px-6 py-3 font-medium text-primary-foreground hover:bg-primary/90"
              >
                {t("Sign in to your account", "تسجيل الدخول")}
              </Link>
            )}
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-5xl px-6 py-16">
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
          {stats.map((s) => (
            <div key={s.label} className="rounded-xl border border-border bg-card p-6 text-center">
              <p className="text-3xl font-bold text-accent">{s.value}</p>
              <p className="mt-1 text-sm text-muted-foreground">{s.label}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-5xl px-6 pb-16">
        <h2 className="text-2xl font-semibold text-foreground">
          {t("Four tracks, one profession", "أربعة مسارات لمهنة واحدة")}
        </h2>
        <div className="mt-6 grid gap-4 md:grid-cols-2">
          {finixTracks.map((track) => (
            <div key={track.id} className="rounded-xl border border-border bg-card p-6">
              <h3 className="font-semibold text-foreground">{t(track.name, track.nameAr)}</h3>
              <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                {t(track.tagline, track.taglineAr)}
              </p>
              <p className="mt-3 font-mono text-xs text-accent">
                {finixModules.filter((m) => m.track === track.id).length}{" "}
                {t("modules", "وحدات")}
              </p>
            </div>
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-5xl px-6 pb-24">
        <h2 className="text-2xl font-semibold text-foreground">
          {t("Field ready", "جاهزية ميدانية")}
        </h2>
        <div className="mt-6 grid gap-4 md:grid-cols-2">
          <Link
            to="/finix/kpi"
            className="rounded-xl border border-border bg-card p-6 transition-colors hover:border-accent"
          >
            <h3 className="font-semibold text-foreground">
              {t("KPI evaluations", "تقييمات الأداء")}
            </h3>
            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
              {t(
                "Score technicians on technical execution (60%) and behavioral criteria (40%), with a final grade and feedback notes.",
                "قيّم الفنيين على الأداء الفني (٦٠٪) والمعايير السلوكية (٤٠٪) بدرجة نهائية وملاحظات توجيهية.",
              )}
            </p>
          </Link>
          <Link
            to="/finix/survey"
            className="rounded-xl border border-border bg-card p-6 transition-colors hover:border-accent"
          >
            <h3 className="font-semibold text-foreground">
              {t("Site survey & engineering audit", "مسح الموقع والتدقيق الهندسي")}
            </h3>
            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
              {t(
                "A five-stage audit form: infrastructure, load mapping, network, scene logic, and as-built documentation.",
                "استمارة تدقيق من خمس مراحل: البنية التحتية والأحمال والشبكة ومنطق المشاهد وتوثيق ما نُفّذ.",
              )}
            </p>
          </Link>
        </div>
      </section>
    </div>
  );
}
