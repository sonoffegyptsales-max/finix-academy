import { createFileRoute, Link, useParams } from "@tanstack/react-router";
import { useState } from "react";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { useCurriculum } from "@/hooks/use-curriculum";
import { useQuiz, useSubmitQuiz, type QuizResult } from "@/hooks/use-quiz";
import { ProtectedContent } from "@/components/ProtectedContent";

export const Route = createFileRoute("/dashboard/quiz/$slug/$tier")({
  head: () => ({
    meta: [{ title: "Quiz — Finix Academy" }],
  }),
  component: () => (
    <Protected>
      <QuizPage />
    </Protected>
  ),
});

function QuizPage() {
  const { slug, tier } = useParams({ from: "/dashboard/quiz/$slug/$tier" });
  const { t, isRTL } = useLang();
  const { modules, loading: curriculumLoading } = useCurriculum();
  const mod = modules.find((m) => m.slug === slug);
  const { quiz, questions, loading, error } = useQuiz(
    mod?.id,
    tier as "bronze" | "silver" | "gold",
  );
  const { submit, submitting } = useSubmitQuiz();

  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [result, setResult] = useState<QuizResult | null>(null);

  if (curriculumLoading || loading) {
    return (
      <div className="mx-auto max-w-2xl px-6 py-20 text-center text-sm text-muted-foreground">
        {t("Loading quiz…", "جارٍ تحميل الاختبار…")}
      </div>
    );
  }

  if (!mod || error || !quiz) {
    return (
      <div className="mx-auto max-w-md px-6 py-20 text-center">
        <h1 className="text-xl font-bold text-foreground">
          {t("Quiz not available", "الاختبار غير متاح")}
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          {t(
            "This quiz hasn't been set up yet, or the backend isn't connected.",
            "لم يتم إعداد هذا الاختبار بعد، أو الخادم غير متصل.",
          )}
        </p>
        <Link
          to="/dashboard/my-courses"
          className="mt-6 inline-block text-sm font-medium text-primary hover:underline"
        >
          {t("← Back to My Courses", "← العودة إلى دوراتي")}
        </Link>
      </div>
    );
  }

  const allAnswered = questions.length > 0 && questions.every((q) => answers[q.id]);
  const tierLabel = { bronze: "Bronze", silver: "Silver", gold: "Gold" }[tier] ?? tier;
  const tierLabelAr = { bronze: "برونزي", silver: "فضي", gold: "ذهبي" }[tier] ?? tier;

  const handleSubmit = async () => {
    const payload = questions.map((q) => ({
      question_id: q.id,
      selected_option_id: answers[q.id],
    }));
    const res = await submit(quiz.id, payload);
    if (res) setResult(res);
  };

  if (result) {
    return (
      <div className="mx-auto max-w-2xl px-6 py-16 text-center">
        <div
          className={`mx-auto flex h-20 w-20 items-center justify-center rounded-full ${
            result.passed ? "bg-green-500/10 text-green-600" : "bg-destructive/10 text-destructive"
          }`}
        >
          <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            {result.passed ? <path d="M20 6 9 17l-5-5" /> : <path d="M18 6 6 18M6 6l12 12" />}
          </svg>
        </div>
        <h1 className="mt-6 text-3xl font-bold text-foreground">
          {result.passed ? t("Quiz Passed!", "نجحت في الاختبار!") : t("Not Passed", "لم تنجح")}
        </h1>
        <p className="mt-3 text-lg text-muted-foreground">
          {t(
            `You scored ${result.score} / ${result.total} (${result.percent}%)`,
            `درجتك ${result.score} / ${result.total} (${result.percent}٪)`,
          )}
        </p>
        <p className="mt-1 text-sm text-muted-foreground">
          {t(
            `Passing mark: ${quiz.pass_percent}%`,
            `درجة النجاح: ${quiz.pass_percent}٪`,
          )}
        </p>
        {result.passed && (
          <p className="mt-4 rounded-lg bg-primary/5 border border-primary/20 px-4 py-3 text-sm text-primary">
            {t(
              "This module is now marked complete. Pass this tier's quiz in every module to earn the certification.",
              "تم تحديد هذه الوحدة كمكتملة. اجتز اختبار هذا المستوى في كل الوحدات لنيل الاعتماد.",
            )}
          </p>
        )}
        <div className="mt-8 flex flex-wrap justify-center gap-3">
          <Link
            to="/dashboard/my-courses"
            className="rounded-lg bg-primary px-6 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            {t("Back to My Courses", "العودة إلى دوراتي")}
          </Link>
          <Link
            to="/dashboard/certifications"
            className="rounded-lg border border-border px-6 py-2.5 text-sm font-medium text-foreground hover:bg-secondary"
          >
            {t("View Certifications", "عرض الاعتمادات")}
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl px-6 py-14">
      <Link to="/dashboard/my-courses" className="text-sm text-muted-foreground hover:text-primary">
        {t("← My Courses", "← دوراتي")}
      </Link>

      <div className="mt-4 flex items-center gap-2">
        <span className="font-mono text-xs text-muted-foreground">{mod.code}</span>
        <span className="rounded-full border border-primary/20 bg-primary/10 px-2.5 py-0.5 text-[11px] font-medium text-primary">
          {t(tierLabel, tierLabelAr)} {t("Quiz", "اختبار")}
        </span>
      </div>

      <h1 className="mt-3 text-3xl font-bold tracking-tight text-foreground">
        {t(quiz.title, quiz.title_ar)}
      </h1>
      <p className="mt-2 text-sm text-muted-foreground">
        {t(
          `${questions.length} questions · ${quiz.pass_percent}% to pass`,
          `${questions.length} أسئلة · ${quiz.pass_percent}٪ للنجاح`,
        )}
      </p>

      <ProtectedContent>
        <div className="mt-8 space-y-6">
          {questions.map((q, i) => (
            <div key={q.id} className="overflow-hidden rounded-xl border border-border bg-card p-5">
              <p className="font-medium text-foreground">
                <span className="me-2 font-mono text-xs text-muted-foreground">
                  {String(i + 1).padStart(2, "0")}
                </span>
                {t(q.question, q.question_ar)}
              </p>
              <div className="mt-4 space-y-2">
                {q.options.map((opt) => {
                  const selected = answers[q.id] === opt.id;
                  return (
                    <button
                      key={opt.id}
                      onClick={() => setAnswers((prev) => ({ ...prev, [q.id]: opt.id }))}
                      className={`flex w-full items-center gap-3 rounded-lg border px-4 py-2.5 text-start text-sm transition-colors ${
                        selected
                          ? "border-primary bg-primary/5 text-foreground"
                          : "border-border text-muted-foreground hover:border-primary/50"
                      }`}
                    >
                      <span
                        className={`flex h-4 w-4 flex-shrink-0 items-center justify-center rounded-full border-2 ${
                          selected ? "border-primary bg-primary" : "border-input"
                        }`}
                      >
                        {selected && <span className="h-1.5 w-1.5 rounded-full bg-primary-foreground" />}
                      </span>
                      {t(opt.option_text, opt.option_text_ar)}
                    </button>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      </ProtectedContent>

      <div className="mt-8 flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          {Object.keys(answers).length} / {questions.length} {t("answered", "تمت الإجابة")}
        </p>
        <button
          onClick={handleSubmit}
          disabled={!allAnswered || submitting}
          className="rounded-lg bg-primary px-6 py-2.5 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
        >
          {submitting ? t("Submitting…", "جارٍ الإرسال…") : t("Submit Quiz", "إرسال الاختبار")}
        </button>
      </div>
    </div>
  );
}
