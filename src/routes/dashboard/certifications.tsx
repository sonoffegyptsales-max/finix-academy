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
  track_id: string | null;
  certificate_number: string;
  issued_at: string;
}

function CertificationsPage() {
  const { t } = useLang();
  const { user } = useAuth();
  const { tracks, modules } = useCurriculum();
  const [passed, setPassed] = useState<Set<string>>(new Set());
  const moduleIdBySlug = Object.fromEntries(modules.map((m) => [m.slug, m.id]));
  const { completed } = useEnrollments(moduleIdBySlug);
  const [certificates, setCertificates] = useState<CertRow[]>([]);

  useEffect(() => {
    if (!user) return;
    void supabase
      .from("certificates")
      .select("tier, track_id, certificate_number, issued_at")
      .eq("user_id", user.id)
      .then(({ data }) => setCertificates((data ?? []) as unknown as CertRow[]));
    // Which (module, tier) quizzes this student has passed -> per-track progress.
    void (supabase as any)
      .from("quiz_attempts")
      .select("quizzes!inner(module_id, tier)")
      .eq("user_id", user.id)
      .eq("passed", true)
      .then(({ data }: { data: { quizzes: { module_id: string; tier: string } }[] | null }) =>
        setPassed(new Set((data ?? []).map((r) => `${r.quizzes.module_id}:${r.quizzes.tier}`))),
      );
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
                `Every module ends with Bronze, Silver, and Gold quizzes. Pass a tier quiz in every module of a track with ${FINIX_QUIZ_PASS_PERCENT}% or above to earn that track's certification at that level — issued automatically.`,
                `تنتهي كل وحدة باختبارات برونزي وفضي وذهبي. اجتز اختبار المستوى في كل وحدات المسار بنسبة ${FINIX_QUIZ_PASS_PERCENT}% أو أعلى لنيل اعتماد المسار بالمستوى ده — يصدر تلقائيًا.`,
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

      <div className="space-y-8">
        {tracks.map((track) => {
          const mods = modules.filter((m) => m.track_id === track.id);
          if (mods.length === 0) return null;
          return (
            <section key={track.id}>
              <h2 className="mb-3 text-lg font-semibold text-foreground">{t(track.name, track.name_ar)}</h2>
              <div className="grid gap-4 md:grid-cols-3">
                {tierConfig.map((tier) => {
                  const cert = certificates.find((c) => c.tier === tier.id && c.track_id === track.id);
                  const done = mods.filter((m) => passed.has(`${m.id}:${tier.id}`)).length;
                  return (
                    <div
                      key={tier.id}
                      data-cert={`${track.id}:${tier.id}`}
                      className={`overflow-hidden rounded-xl border p-5 shadow-sm ${
                        cert ? "border-green-300 bg-green-50/30" : "border-border bg-card"
                      }`}
                    >
                      <div className="flex items-center justify-between gap-2">
                        <span className={`rounded-full px-3 py-1 text-xs font-semibold ${tier.color}`}>
                          {t(tier.label, tier.labelAr)}
                        </span>
                        {cert ? (
                          <span className="rounded-full bg-green-500/10 px-2.5 py-0.5 text-xs font-medium text-green-700">
                            ✓ {t("Issued", "صادر")}
                          </span>
                        ) : (
                          <span className="text-xs text-muted-foreground">
                            {done} / {mods.length} {t("modules", "وحدات")}
                          </span>
                        )}
                      </div>
                      {cert ? (
                        <p className="mt-3 text-xs text-muted-foreground">
                          <span className="font-mono">{cert.certificate_number}</span>
                          <br />
                          {new Date(cert.issued_at).toLocaleDateString()}
                        </p>
                      ) : (
                        <>
                          <div className="mt-3 h-1.5 overflow-hidden rounded-full bg-secondary">
                            <div className="h-full bg-primary" style={{ width: `${(done / mods.length) * 100}%` }} />
                          </div>
                          <p className="mt-2 text-xs text-muted-foreground">
                            {t(
                              `Pass the ${tier.label} quiz in every module of this track (${FINIX_QUIZ_PASS_PERCENT}%+).`,
                              `اجتز اختبار ${tier.labelAr} في كل وحدات المسار ده (${FINIX_QUIZ_PASS_PERCENT}٪+).`,
                            )}
                          </p>
                        </>
                      )}
                    </div>
                  );
                })}
              </div>
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
