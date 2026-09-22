import { createFileRoute } from "@tanstack/react-router";
import { useLang } from "@/lib/language";
import { useAuth } from "@/lib/auth";
import { useCurriculum } from "@/hooks/use-curriculum";
import { useEnrollments } from "@/hooks/use-enrollments";
import { usePushNotifications } from "@/hooks/use-push-notifications";

export const Route = createFileRoute("/dashboard/")({
  component: DashboardPage,
});

function NotificationBanner() {
  const { t } = useLang();
  const { status, busy, error, supported, subscribe, unsubscribe } = usePushNotifications();

  if (!supported) return null;

  if (status === "subscribed") {
    return (
      <div className="mb-6 flex items-center justify-between gap-4 rounded-xl border border-green-500/30 bg-green-500/5 px-5 py-3">
        <div className="flex items-center gap-3">
          <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-green-500/10 text-green-600">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>
          </span>
          <p className="text-sm font-medium text-foreground">
            {t("Notifications are on", "الإشعارات مفعّلة")}
          </p>
        </div>
        <button
          onClick={() => void unsubscribe()}
          disabled={busy}
          className="rounded-lg border border-border px-3 py-1 text-xs font-medium text-muted-foreground hover:bg-secondary disabled:opacity-60"
        >
          {t("Turn off", "إيقاف")}
        </button>
      </div>
    );
  }

  return (
    <div className="mb-6 flex items-center justify-between gap-4 rounded-xl border border-primary/30 bg-primary/5 px-5 py-3">
      <div className="flex items-center gap-3">
        <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>
        </span>
        <div>
          <p className="text-sm font-medium text-foreground">
            {t("Enable notifications", "فعّل الإشعارات")}
          </p>
          <p className="text-xs text-muted-foreground">
            {status === "denied"
              ? t(
                  "Notifications are blocked in your browser settings.",
                  "الإشعارات محظورة في إعدادات متصفحك.",
                )
              : t(
                  "Get notified about new lessons and announcements.",
                  "احصل على إشعارات بالدروس الجديدة والإعلانات.",
                )}
          </p>
          {error && <p className="text-xs text-destructive">{error}</p>}
        </div>
      </div>
      {status !== "denied" && (
        <button
          onClick={() => void subscribe()}
          disabled={busy}
          className="rounded-lg bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-60"
        >
          {busy ? t("Enabling…", "جارٍ التفعيل…") : t("Enable", "تفعيل")}
        </button>
      )}
    </div>
  );
}

function StatIcon({ name, className }: { name: string; className?: string }) {
  const base = { width: 20, height: 20, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth: 2, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
  switch (name) {
    case "users":
      return <svg {...base} className={className}><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>;
    case "chart":
      return <svg {...base} className={className}><path d="M18 20V10"/><path d="M12 20V4"/><path d="M6 20v-6"/></svg>;
    case "clipboard":
      return <svg {...base} className={className}><rect width="18" height="12" x="3" y="3" rx="2"/><path d="M8 13l-2 7"/><path d="M16 13l2 7"/><path d="m9 21 1-4h4l1 4"/></svg>;
    case "award":
      return <svg {...base} className={className}><circle cx="12" cy="8" r="7"/><path d="M18 20a3 3 0 0 0-3-3M6 20a3 3 0 0 1 3-3"/><path d="M12 13v4l1 2"/></svg>;
    case "book":
      return <svg {...base} className={className}><path d="M2 3h20v18H2z"/><path d="M7 8h10"/><path d="M7 12h10"/><path d="M7 16h6"/></svg>;
    default:
      return null;
  }
}

function DashboardPage() {
  const { t } = useLang();
  const { user, isAdmin, isTrainer, isStaff } = useAuth();
  const { tracks, modules, loading } = useCurriculum();
  const moduleIdBySlug = Object.fromEntries(modules.map((m) => [m.slug, m.id]));
  const { completed } = useEnrollments(moduleIdBySlug);

  const percent = modules.length > 0 ? Math.round((completed.length / modules.length) * 100) : 0;
  const greetName = user?.email?.split("@")[0] || "there";

  const trackColors: Record<string, string> = {
    "hardware-foundations": "bg-sky-500/10 text-sky-600",
    "networking-protocols": "bg-green-500/10 text-green-600",
    "team-project-management": "bg-amber-500/10 text-amber-600",
    "survey-terminology-tools": "bg-purple-500/10 text-purple-600",
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-foreground">
          {t(`Welcome back, ${greetName}`, `مرحبًا بعودتك، ${greetName}`)}
        </h1>
        <p className="mt-1 text-sm text-muted-foreground">
          {isAdmin
            ? t("Administrator", "مسؤول النظام")
            : isTrainer
              ? t("Trainer", "مدرب")
              : t("Trainee", "متدرب")}
        </p>
      </div>

      <NotificationBanner />

      {/* Progress */}
      <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <div className="overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-sky-50 text-sky-600">
            <StatIcon name="book" className="h-5 w-5" />
          </div>
          <p className="mt-3 text-2xl font-bold text-foreground">
            {loading ? "…" : `${completed.length}/${modules.length}`}
          </p>
          <p className="text-sm text-muted-foreground">
            {t("Modules Completed", "الوحدات المكتملة")}
          </p>
        </div>
        <div className="overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-green-50 text-green-600">
            <StatIcon name="chart" className="h-5 w-5" />
          </div>
          <p className="mt-3 text-2xl font-bold text-foreground">{loading ? "…" : `${percent}%`}</p>
          <p className="text-sm text-muted-foreground">{t("Overall Progress", "التقدم الإجمالي")}</p>
        </div>
        <div className="overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-amber-50 text-amber-600">
            <StatIcon name="clipboard" className="h-5 w-5" />
          </div>
          <p className="mt-3 text-2xl font-bold text-foreground">{tracks.length}</p>
          <p className="text-sm text-muted-foreground">{t("Tracks", "المسارات")}</p>
        </div>
        <div className="overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-yellow-50 text-yellow-600">
            <StatIcon name="award" className="h-5 w-5" />
          </div>
          <p className="mt-3 text-2xl font-bold text-foreground">3</p>
          <p className="text-sm text-muted-foreground">{t("Cert Tiers", "مستويات الاعتماد")}</p>
        </div>
      </div>

      {/* Quick actions */}
      <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <a
          href="/dashboard/my-courses"
          className="flex items-start gap-3 overflow-hidden rounded-xl border border-border bg-card p-5 text-start transition-colors hover:border-primary hover:bg-primary/5"
        >
          <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <StatIcon name="book" className="h-5 w-5" />
          </div>
          <div>
            <p className="text-sm font-semibold text-foreground">{t("My Courses", "دوراتي")}</p>
            <p className="text-xs text-muted-foreground">
              {modules.length} {t("modules available", "وحدة متاحة")}
            </p>
          </div>
        </a>
        <a
          href="/dashboard/certifications"
          className="flex items-start gap-3 overflow-hidden rounded-xl border border-border bg-card p-5 text-start transition-colors hover:border-primary hover:bg-primary/5"
        >
          <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-yellow-500/10 text-yellow-600">
            <StatIcon name="award" className="h-5 w-5" />
          </div>
          <div>
            <p className="text-sm font-semibold text-foreground">{t("Certifications", "الاعتمادات")}</p>
            <p className="text-xs text-muted-foreground">Bronze · Silver · Gold</p>
          </div>
        </a>
        {isStaff && (
          <a
            href="/dashboard/kpi-evaluator"
            className="flex items-start gap-3 overflow-hidden rounded-xl border border-border bg-card p-5 text-start transition-colors hover:border-primary hover:bg-primary/5"
          >
            <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-green-500/10 text-green-600">
              <StatIcon name="chart" className="h-5 w-5" />
            </div>
            <div>
              <p className="text-sm font-semibold text-foreground">{t("KPI Evaluator", "تقييم الأداء")}</p>
              <p className="text-xs text-muted-foreground">
                {t("Evaluate technician performance", "تقييم أداء الفنيين")}
              </p>
            </div>
          </a>
        )}
        <a
          href="/dashboard/field-survey"
          className="flex items-start gap-3 overflow-hidden rounded-xl border border-border bg-card p-5 text-start transition-colors hover:border-primary hover:bg-primary/5"
        >
          <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-amber-500/10 text-amber-600">
            <StatIcon name="clipboard" className="h-5 w-5" />
          </div>
          <div>
            <p className="text-sm font-semibold text-foreground">{t("Field Survey", "مسح الموقع")}</p>
            <p className="text-xs text-muted-foreground">
              {t("Site survey & audit tool", "أداة مسح الموقع")}
            </p>
          </div>
        </a>
      </div>

      {/* Curriculum overview */}
      <div>
        <h2 className="mb-4 text-lg font-semibold text-foreground">
          {t("Curriculum Overview", "نظرة عامة على المنهج")}
        </h2>
        <div className="overflow-hidden rounded-xl border border-border bg-card">
          <div className="divide-y divide-border">
            {tracks.map((track) => {
              const count = modules.filter((m) => m.track_id === track.id).length;
              return (
                <div key={track.id} className="flex items-center justify-between gap-4 p-4">
                  <span
                    className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${
                      trackColors[track.id] ?? "bg-gray-500/10 text-gray-600"
                    }`}
                  >
                    {t(track.name, track.name_ar)}
                  </span>
                  <span className="text-xs text-muted-foreground">
                    {count} {t("modules", "وحدات")}
                  </span>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}
