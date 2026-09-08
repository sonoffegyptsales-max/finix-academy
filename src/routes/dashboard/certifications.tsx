import { createFileRoute } from "@tanstack/react-router";
import { useLang } from "@/lib/language";
import { finixModules, finixCertTiers, finixQuizTierLabels, FINIX_QUIZ_PASS_PERCENT } from "@/content/finix";

export const Route = createFileRoute("/dashboard/certifications")({
  head: () => ({
    meta: [{ title: "Certifications — Finix Academy" }],
  }),
  component: CertificationsPage,
});

function CertificationsPage() {
  const { t } = useLang();

  const tierConfig = [
    {
      id: "bronze" as const,
      label: "Bronze",
      labelAr: "برونزي",
      color: "text-amber-600 bg-amber-50 border-amber-200",
      bgColor: "bg-amber-50/50",
    },
    {
      id: "silver" as const,
      label: "Silver",
      labelAr: "فضي",
      color: "text-blue-600 bg-blue-50 border-blue-200",
      bgColor: "bg-blue-50/50",
    },
    {
      id: "gold" as const,
      label: "Gold",
      labelAr: "ذهبي",
      color: "text-yellow-600 bg-yellow-50 border-yellow-200",
      bgColor: "bg-yellow-50/50",
    },
  ];

  // Simulated — would come from Supabase
  const completedCount = 0;

  return (
    <div className="p-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Certifications</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Earn certifications by passing tier quizzes
          </p>
        </div>
      </div>

      {/* Info banner */}
      <div className="mb-6 overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm">
        <div className="flex items-start gap-3">
          <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="8" r="7"/>
              <path d="M18 20a3 3 0 0 0-3-3M6 20a3 3 0 0 1 3-3"/>
              <path d="M12 13v4l1 2"/>
            </svg>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-foreground">How certifications work</h3>
            <p className="mt-1 text-sm text-muted-foreground">
              Every module ends with Bronze, Silver, and Gold quizzes. Pass a tier quiz in each module with {FINIX_QUIZ_PASS_PERCENT}% or above to earn that certification.
            </p>
            <p className="mt-2 text-xs text-muted-foreground" dir="rtl">
              تنتهي كل وحدة باختبارات برونزي وفضي وذهبي. اجتز اختبار المستوى في كل وحدة بنسبة {FINIX_QUIZ_PASS_PERCENT}% أو أعلى لنيل ذلك الاعتماد.
            </p>
          </div>
        </div>
      </div>

      {/* Per-tier progress */}
      {tierConfig.map((tier) => (
        <section key={tier.id} className="mb-6">
          <div className="mb-4 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className={`rounded-full px-3 py-1 text-xs font-semibold ${tier.color}`}>
                {tier.label}
              </span>
              <span className="text-xs text-muted-foreground">
                {completedCount} / {finixModules.length} modules completed
              </span>
            </div>
            <a
              href="/finix/certification"
              className="text-xs font-medium text-primary hover:underline"
            >
              View details →
            </a>
          </div>
          <div className="overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm">
            <div className="mb-4 flex items-center gap-4">
              <div className="flex-1 h-2 overflow-hidden rounded-full bg-secondary">
                <div
                  className="h-full rounded-full bg-primary transition-all"
                  style={{ width: `${(completedCount / finixModules.length) * 100}%` }}
                />
              </div>
              <span className="text-sm font-semibold text-foreground">
                {Math.round((completedCount / finixModules.length) * 100)}%
              </span>
            </div>
            <p className="text-xs text-muted-foreground mb-4">
              {completedCount} of {finixModules.length} modules passed the {tier.label} quiz
            </p>
            <div className="overflow-hidden rounded-lg border border-border bg-background">
              <div className="divide-y divide-border">
                {finixModules.slice(0, 5).map((mod) => (
                  <div
                    key={mod.slug}
                    className={`flex items-center gap-3 px-4 py-3 text-sm ${tier.bgColor}`}
                  >
                    <span className="font-mono text-muted-foreground">{mod.code}</span>
                    <span className="flex-1 truncate text-foreground">{mod.title}</span>
                    <span className="rounded-full bg-secondary px-2 py-0.5 text-[11px] text-muted-foreground">
                      Not attempted
                    </span>
                  </div>
                ))}
              </div>
            </div>
            </div>
          </section>
        ))}

      {/* CTA */}
      <div className="mt-8 rounded-xl border border-primary/20 bg-primary/5 p-6 text-center">
        <h3 className="text-lg font-semibold text-foreground">Start earning certifications</h3>
        <p className="mt-2 text-sm text-muted-foreground">
          Study the modules and pass the quizzes to earn your Bronze, Silver, and Gold certifications.
        </p>
        <div className="mt-4 flex flex-wrap gap-3 justify-center">
          <a
            href="/dashboard/my-courses"
            className="rounded-lg bg-primary px-6 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
          >
            Browse Courses
          </a>
          <a
            href="/finix/certification"
            className="rounded-lg border border-border bg-card px-6 py-2.5 text-sm font-medium text-foreground hover:bg-secondary transition-colors"
          >
            Certification Path
          </a>
        </div>
      </div>
    </div>
  );
}
