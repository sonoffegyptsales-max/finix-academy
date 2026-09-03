import { createFileRoute, Link } from "@tanstack/react-router";
import {
  FINIX_QUIZ_PASS_PERCENT,
  finixCertTiers,
  finixModules,
  finixQuizTierLabels,
} from "@/content/finix";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { useFinixProgress } from "@/hooks/use-finix-progress";

export const Route = createFileRoute("/finix/certification")({
  head: () => ({
    meta: [
      { title: "Certification Path — Finix Academy" },
      {
        name: "description",
        content:
          "Bronze, Silver and Gold certification requirements in the Finix Academy programme.",
      },
    ],
  }),
  component: () => (
    <Protected>
      <FinixCertification />
    </Protected>
  ),
});

function FinixCertification() {
  const { t } = useLang();
  const { completed } = useFinixProgress();
  const doneCount = finixModules.filter((m) => completed.includes(m.slug)).length;
  const percent = Math.round((doneCount / finixModules.length) * 100);

  return (
    <div className="mx-auto max-w-3xl px-6 py-14">
      <Link to="/finix" className="text-sm text-muted-foreground hover:text-accent">
        {t("← Finix Academy", "← أكاديمية فينيكس")}
      </Link>
      <h1 className="mt-6 text-4xl font-bold tracking-tight text-foreground">
        {t("Certification path", "مسار الاعتماد")}
      </h1>
      <p className="mt-3 text-lg text-muted-foreground">
        {t(
          `Every module ends with Bronze, Silver and Gold quizzes. Pass a tier quiz in each module with ${FINIX_QUIZ_PASS_PERCENT}% or above to earn that certification.`,
          `تنتهي كل وحدة باختبارات برونزي وفضي وذهبي. اجتز اختبار المستوى في كل وحدة بنسبة ${FINIX_QUIZ_PASS_PERCENT}٪ أو أعلى لنيل ذلك الاعتماد.`,
        )}
      </p>

      <section className="mt-8 rounded-2xl border border-border bg-card p-6">
        <div className="flex items-center justify-between text-sm">
          <h2 className="font-semibold text-foreground">
            {t("Study progress", "تقدم الدراسة")}
          </h2>
          <span className="text-muted-foreground">
            {doneCount} / {finixModules.length} {t("modules", "وحدات")} · {percent}%
          </span>
        </div>
        <div className="mt-3 h-2 overflow-hidden rounded-full bg-secondary">
          <div
            className="h-full rounded-full bg-accent transition-all"
            style={{ width: `${percent}%` }}
          />
        </div>
        <p className="mt-3 text-xs text-muted-foreground">
          {t(
            "Marking modules complete tracks your study here; the certifications themselves are earned by the quizzes.",
            "تحديد الوحدات كمكتملة يتابع دراستك هنا؛ أما الاعتمادات فتُمنح باجتياز الاختبارات.",
          )}
        </p>
      </section>

      <div className="mt-8 space-y-6">
        {finixCertTiers.map((tier) => (
          <section
            key={tier.id}
            className="rounded-2xl border border-border bg-card p-6"
          >
            <div className="flex flex-wrap items-center justify-between gap-3">
              <h2 className="text-2xl font-semibold text-foreground">
                {t(tier.name, tier.nameAr)}
              </h2>
              <span className="rounded-full border border-border px-3 py-1 text-xs text-muted-foreground">
                {t(
                  `${finixQuizTierLabels[tier.id].en} quizzes`,
                  `اختبارات ${finixQuizTierLabels[tier.id].ar}`,
                )}
              </span>
            </div>
            <p className="mt-2 text-sm text-muted-foreground">
              {t(tier.description, tier.descriptionAr)}
            </p>
            <a
              href="https://smartacademy.onhercules.app/en/courses"
              target="_blank"
              rel="noreferrer"
              className="mt-4 inline-block rounded-lg border border-border px-4 py-2 text-sm font-medium text-foreground transition-colors hover:border-accent"
            >
              {t("Take the quizzes in Finix Academy ↗", "اجتز الاختبارات في أكاديمية فينيكس ↗")}
            </a>
          </section>
        ))}
      </div>
    </div>
  );
}
