import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Protected, useAuth } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { supabase } from "@/integrations/supabase/client";
import { useCurriculum } from "@/hooks/use-curriculum";
import { useEnrollments } from "@/hooks/use-enrollments";
import { FINIX_QUIZ_PASS_PERCENT } from "@/content/finix";

export const Route = createFileRoute("/dashboard/certifications")({
  head: () => ({
    meta: [{ title: "Certifications — Finix Academy" }],
  }),
  component: () => (
    <Protected>
      <CertificationsPage />
    </Protected>
  ),
});

const tierConfig = [
  { id: "bronze", label: "Bronze", labelAr: "برونزي", color: "text-amber-600 bg-amber-50 border-amber-200" },
  { id: "silver", label: "Silver", labelAr: "فضي", color: "text-blue-600 bg-blue-50 border-blue-200" },
  { id: "gold", label: "Gold", labelAr: "ذهبي", color: "text-yellow-600 bg-yellow-50 border-yellow-200" },
] as const;

interface CertRow {
  tier: string;
  certificate_number: string;
  issued_at: string;
}

function CertificationsPage() {
  const { t } = useLang();
  const { user } = useAuth();
  const { modules } = useCurriculum();
  const moduleIdBySlug = Object.fromEntries(modules.map((m) => [m.slug, m.id]));
  const { completed } = useEnrollments(moduleIdBySlug);
  const [certificates, setCertificates] = useState<CertRow[]>([]);

  useEffect(() => {
    if (!user) return;
    void supabase
      .from("certificates")
      .select("tier, certificate_number, issued_at")
      .eq("user_id", user.id)
      .then(({ data }) => setCertificates(data ?? []));
  }, [user]);

  const percent = modules.length > 0 ? Math.round((completed.length / modules.length) * 100) : 0;

  return (
    <div className="p-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">
            {t("Certifications", "الاعتمادات")}
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {t("Earn certifications by passing tier quizzes", "اكتسب الاعتمادات باجتياز اختبارات المستويات")}
          </p>
        </div>
      </div>

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
            <h3 className="text-sm font-semibold text-foreground">
              {t("How certifications work", "كيف تعمل الاعتمادات")}
            </h3>
            <p className="mt-1 text-sm text-muted-foreground">
              {t(
                `Every module ends with Bronze, Silver, and Gold quizzes. Pass a tier quiz in each module with ${FINIX_QUIZ_PASS_PERCENT}% or above to earn that certification — issued automatically.`,
                `تنتهي كل وحدة باختبارات برونزي وفضي وذهبي. اجتز اختبار المستوى في كل وحدة بنسبة ${FINIX_QUIZ_PASS_PERCENT}% أو أعلى لنيل ذلك الاعتماد — يصدر تلقائيًا.`,
              )}
            </p>
          </div>
        </div>
      </div>

      <div className="mb-8 overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm">
        <div className="flex items-center justify-between text-sm">
          <h2 className="font-semibold text-foreground">{t("Study progress", "تقدم الدراسة")}</h2>
          <span className="text-muted-foreground">
            {completed.length} / {modules.length} {t("modules", "وحدات")} · {percent}%
          </span>
        </div>
        <div className="mt-3 h-2 overflow-hidden rounded-full bg-secondary">
          <div className="h-full rounded-full bg-primary transition-all" style={{ width: `${percent}%` }} />
        </div>
      </div>

      <div className="space-y-4">
        {tierConfig.map((tier) => {
          const cert = certificates.find((c) => c.tier === tier.id);
          return (
            <section
              key={tier.id}
              className={`overflow-hidden rounded-xl border p-6 shadow-sm ${
                cert ? "border-green-300 bg-green-50/30" : "border-border bg-card"
              }`}
            >
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <span className={`rounded-full px-3 py-1 text-xs font-semibold ${tier.color}`}>
                    {t(tier.label, tier.labelAr)}
                  </span>
                  <h2 className="text-xl font-semibold text-foreground">
                    {t(`${tier.label} Certification`, `اعتماد ${tier.labelAr}`)}
                  </h2>
                </div>
                {cert ? (
                  <span className="rounded-full bg-green-500/10 px-3 py-1 text-xs font-medium text-green-700">
                    ✓ {t("Issued", "صادر")}
                  </span>
                ) : (
                  <span className="rounded-full border border-border px-3 py-1 text-xs text-muted-foreground">
                    {t("Not yet earned", "لم يتم الحصول عليه بعد")}
                  </span>
                )}
              </div>
              {cert ? (
                <p className="mt-3 text-sm text-muted-foreground">
                  {t("Certificate #", "رقم الشهادة")}: <span className="font-mono">{cert.certificate_number}</span>
                  {" · "}
                  {t("Issued", "صدرت في")} {new Date(cert.issued_at).toLocaleDateString()}
                </p>
              ) : (
                <p className="mt-3 text-sm text-muted-foreground">
                  {t(
                    `Pass the ${tier.label} quiz of every module with ${FINIX_QUIZ_PASS_PERCENT}% or above.`,
                    `اجتز اختبار ${tier.labelAr} في كل الوحدات بنسبة ${FINIX_QUIZ_PASS_PERCENT}٪ أو أعلى.`,
                  )}
                </p>
              )}
            </section>
          );
        })}
      </div>

      <div className="mt-8 rounded-xl border border-primary/20 bg-primary/5 p-6 text-center">
        <h3 className="text-lg font-semibold text-foreground">
          {t("Start earning certifications", "ابدأ كسب الاعتمادات")}
        </h3>
        <p className="mt-2 text-sm text-muted-foreground">
          {t(
            "Study the modules and pass the quizzes to earn your Bronze, Silver, and Gold certifications.",
            "ادرس الوحدات واجتاز الاختبارات لكسب اعتماداتك.",
          )}
        </p>
        <div className="mt-4 flex flex-wrap gap-3 justify-center">
          <Link
            to="/dashboard/my-courses"
            className="rounded-lg bg-primary px-6 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
          >
            {t("Browse Courses", "تصفح الدورات")}
          </Link>
        </div>
      </div>
    </div>
  );
}
