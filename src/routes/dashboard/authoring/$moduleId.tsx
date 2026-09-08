import { createFileRoute, Link, useParams } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";
import {
  useAuthoring,
  fetchModuleForAuthoring,
  type ModuleRow,
  type LessonRow,
  type QuizRow,
  type QuizQuestionRow,
  type QuizOptionRow,
} from "@/hooks/use-authoring";

export const Route = createFileRoute("/dashboard/authoring/$moduleId")({
  head: () => ({
    meta: [{ title: "Edit Module — Finix Academy" }],
  }),
  component: () => (
    <Protected staffOnly>
      <ModuleEditorPage />
    </Protected>
  ),
});

const TIERS: Array<"bronze" | "silver" | "gold"> = ["bronze", "silver", "gold"];

function ModuleEditorPage() {
  const { moduleId } = useParams({ from: "/dashboard/authoring/$moduleId" });
  const { t } = useLang();
  const authoring = useAuthoring();

  const [mod, setMod] = useState<ModuleRow | null>(null);
  const [lessons, setLessons] = useState<LessonRow[]>([]);
  const [quizzes, setQuizzes] = useState<QuizRow[]>([]);
  const [questions, setQuestions] = useState<QuizQuestionRow[]>([]);
  const [options, setOptions] = useState<QuizOptionRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTier, setActiveTier] = useState<"bronze" | "silver" | "gold">("bronze");
  const [newLesson, setNewLesson] = useState({ title: "", title_ar: "", content: "", content_ar: "", video_url: "" });

  async function load() {
    setLoading(true);
    const data = await fetchModuleForAuthoring(moduleId);
    setMod(data.module);
    setLessons(data.lessons);
    setQuizzes(data.quizzes);
    setQuestions(data.questions);
    setOptions(data.options);
    setLoading(false);
  }

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [moduleId]);

  async function handleAddLesson() {
    if (!newLesson.title) return;
    await authoring.createLesson({
      module_id: moduleId,
      title: newLesson.title,
      title_ar: newLesson.title_ar || newLesson.title,
      content: newLesson.content || null,
      content_ar: newLesson.content_ar || null,
      video_url: newLesson.video_url || null,
      position: lessons.length + 1,
    });
    setNewLesson({ title: "", title_ar: "", content: "", content_ar: "", video_url: "" });
    await load();
  }

  async function handleDeleteLesson(id: string) {
    await authoring.deleteLesson(id);
    await load();
  }

  async function handleSaveModuleField(field: "title" | "title_ar" | "summary" | "summary_ar", value: string) {
    if (!mod) return;
    await authoring.updateModule(mod.id, { [field]: value });
  }

  const currentQuiz = quizzes.find((q) => q.tier === activeTier);

  async function handleEnsureQuiz() {
    if (!mod) return;
    const result = await authoring.upsertQuiz({
      module_id: mod.id,
      tier: activeTier,
      title: `${mod.title} — ${activeTier[0].toUpperCase()}${activeTier.slice(1)} Quiz`,
      title_ar: mod.title_ar,
      pass_percent: 80,
    });
    if (result) await load();
  }

  async function handleAddQuestion() {
    if (!currentQuiz) return;
    const q = await authoring.createQuestion({
      quiz_id: currentQuiz.id,
      question: "New question — edit me",
      question_ar: "سؤال جديد — عدّله",
      position: questions.filter((x) => x.quiz_id === currentQuiz.id).length + 1,
    });
    if (q) {
      await authoring.createOption({ question_id: q.id, option_text: "Option A", option_text_ar: "خيار أ", is_correct: true, position: 1 });
      await authoring.createOption({ question_id: q.id, option_text: "Option B", option_text_ar: "خيار ب", is_correct: false, position: 2 });
      await authoring.createOption({ question_id: q.id, option_text: "Option C", option_text_ar: "خيار ج", is_correct: false, position: 3 });
      await load();
    }
  }

  async function handleUpdateQuestion(id: string, question: string, question_ar: string) {
    await authoring.updateQuestion(id, { question, question_ar });
  }

  async function handleUpdateOption(id: string, patch: Partial<QuizOptionRow>) {
    await authoring.updateOption(id, patch);
  }

  async function handleSetCorrect(questionId: string, optionId: string) {
    const questionOptions = options.filter((o) => o.question_id === questionId);
    await Promise.all(
      questionOptions.map((o) => authoring.updateOption(o.id, { is_correct: o.id === optionId })),
    );
    await load();
  }

  async function handleDeleteQuestion(id: string) {
    await authoring.deleteQuestion(id);
    await load();
  }

  if (loading) {
    return <div className="p-6 text-sm text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</div>;
  }

  if (!mod) {
    return <div className="p-6 text-sm text-destructive">{t("Module not found.", "الوحدة غير موجودة.")}</div>;
  }

  const questionsForQuiz = currentQuiz ? questions.filter((q) => q.quiz_id === currentQuiz.id) : [];

  return (
    <div className="p-6">
      <Link to="/dashboard/authoring" className="mb-4 inline-block text-sm text-primary hover:underline">
        ← {t("Back to Courses", "العودة إلى الدورات")}
      </Link>

      {authoring.error && (
        <div className="mb-4 rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm text-destructive">
          {authoring.error}
        </div>
      )}

      {/* Module details */}
      <div className="mb-8 rounded-xl border border-border bg-card p-6">
        <h1 className="mb-4 text-xl font-bold text-foreground">
          {mod.code} — {t("Module Details", "تفاصيل الوحدة")}
        </h1>
        <div className="grid gap-4 sm:grid-cols-2">
          <label className="flex flex-col gap-1 text-sm">
            <span className="text-muted-foreground">{t("Title (English)", "العنوان (إنجليزي)")}</span>
            <input
              defaultValue={mod.title}
              onBlur={(e) => handleSaveModuleField("title", e.target.value)}
              className="rounded-lg border border-border bg-background px-3 py-2"
            />
          </label>
          <label className="flex flex-col gap-1 text-sm">
            <span className="text-muted-foreground">{t("Title (Arabic)", "العنوان (عربي)")}</span>
            <input
              dir="rtl"
              defaultValue={mod.title_ar}
              onBlur={(e) => handleSaveModuleField("title_ar", e.target.value)}
              className="rounded-lg border border-border bg-background px-3 py-2"
            />
          </label>
          <label className="flex flex-col gap-1 text-sm sm:col-span-2">
            <span className="text-muted-foreground">{t("Summary (English)", "الملخص (إنجليزي)")}</span>
            <textarea
              defaultValue={mod.summary}
              onBlur={(e) => handleSaveModuleField("summary", e.target.value)}
              rows={2}
              className="rounded-lg border border-border bg-background px-3 py-2"
            />
          </label>
          <label className="flex flex-col gap-1 text-sm sm:col-span-2">
            <span className="text-muted-foreground">{t("Summary (Arabic)", "الملخص (عربي)")}</span>
            <textarea
              dir="rtl"
              defaultValue={mod.summary_ar}
              onBlur={(e) => handleSaveModuleField("summary_ar", e.target.value)}
              rows={2}
              className="rounded-lg border border-border bg-background px-3 py-2"
            />
          </label>
        </div>
        <p className="mt-2 text-xs text-muted-foreground">
          {t("Fields save automatically when you click away.", "تُحفظ الحقول تلقائيًا عند النقر خارجها.")}
        </p>
      </div>

      {/* Lessons */}
      <div className="mb-8 rounded-xl border border-border bg-card p-6">
        <h2 className="mb-4 text-lg font-semibold text-foreground">{t("Lessons", "الدروس")}</h2>
        <div className="mb-4 divide-y divide-border">
          {lessons.map((l) => (
            <div key={l.id} className="flex items-center justify-between gap-4 py-3">
              <div>
                <p className="text-sm font-medium text-foreground">{l.title}</p>
                <p className="text-xs text-muted-foreground" dir="rtl">
                  {l.title_ar}
                </p>
              </div>
              <button
                onClick={() => handleDeleteLesson(l.id)}
                className="text-xs text-destructive hover:underline"
              >
                {t("Delete", "حذف")}
              </button>
            </div>
          ))}
          {lessons.length === 0 && (
            <p className="py-3 text-sm text-muted-foreground">{t("No lessons yet.", "لا توجد دروس بعد.")}</p>
          )}
        </div>

        <div className="rounded-lg border border-dashed border-border p-4">
          <p className="mb-3 text-sm font-medium text-foreground">{t("+ Add Lesson", "+ إضافة درس")}</p>
          <div className="grid gap-3 sm:grid-cols-2">
            <input
              placeholder={t("Lesson title (English)", "عنوان الدرس (إنجليزي)")}
              value={newLesson.title}
              onChange={(e) => setNewLesson((f) => ({ ...f, title: e.target.value }))}
              className="rounded-lg border border-border bg-background px-3 py-2 text-sm"
            />
            <input
              dir="rtl"
              placeholder={t("Lesson title (Arabic)", "عنوان الدرس (عربي)")}
              value={newLesson.title_ar}
              onChange={(e) => setNewLesson((f) => ({ ...f, title_ar: e.target.value }))}
              className="rounded-lg border border-border bg-background px-3 py-2 text-sm"
            />
            <input
              placeholder={t("Video URL (optional)", "رابط الفيديو (اختياري)")}
              value={newLesson.video_url}
              onChange={(e) => setNewLesson((f) => ({ ...f, video_url: e.target.value }))}
              className="rounded-lg border border-border bg-background px-3 py-2 text-sm sm:col-span-2"
            />
            <textarea
              placeholder={t("Content (English, optional)", "المحتوى (إنجليزي، اختياري)")}
              value={newLesson.content}
              onChange={(e) => setNewLesson((f) => ({ ...f, content: e.target.value }))}
              rows={2}
              className="rounded-lg border border-border bg-background px-3 py-2 text-sm sm:col-span-2"
            />
            <textarea
              dir="rtl"
              placeholder={t("Content (Arabic, optional)", "المحتوى (عربي، اختياري)")}
              value={newLesson.content_ar}
              onChange={(e) => setNewLesson((f) => ({ ...f, content_ar: e.target.value }))}
              rows={2}
              className="rounded-lg border border-border bg-background px-3 py-2 text-sm sm:col-span-2"
            />
          </div>
          <button
            onClick={handleAddLesson}
            disabled={authoring.saving || !newLesson.title}
            className="mt-3 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:opacity-90 disabled:opacity-50"
          >
            {t("Add Lesson", "إضافة الدرس")}
          </button>
        </div>
      </div>

      {/* Quizzes */}
      <div className="rounded-xl border border-border bg-card p-6">
        <h2 className="mb-4 text-lg font-semibold text-foreground">{t("Quiz Questions", "أسئلة الاختبار")}</h2>
        <div className="mb-4 flex gap-2">
          {TIERS.map((tier) => (
            <button
              key={tier}
              onClick={() => setActiveTier(tier)}
              className={`rounded-full px-3 py-1.5 text-xs font-medium capitalize ${
                activeTier === tier ? "bg-primary text-primary-foreground" : "bg-secondary text-muted-foreground"
              }`}
            >
              {tier}
            </button>
          ))}
        </div>

        {!currentQuiz ? (
          <div className="rounded-lg border border-dashed border-border p-6 text-center">
            <p className="mb-3 text-sm text-muted-foreground">
              {t(`No ${activeTier} quiz exists yet for this module.`, `لا يوجد اختبار ${activeTier} لهذه الوحدة بعد.`)}
            </p>
            <button
              onClick={handleEnsureQuiz}
              disabled={authoring.saving}
              className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:opacity-90"
            >
              {t("Create Quiz", "إنشاء اختبار")}
            </button>
          </div>
        ) : (
          <div className="space-y-4">
            {questionsForQuiz.map((q, idx) => {
              const qOptions = options.filter((o) => o.question_id === q.id);
              return (
                <div key={q.id} className="rounded-lg border border-border p-4">
                  <div className="mb-2 flex items-center justify-between">
                    <span className="text-xs font-medium text-muted-foreground">
                      {t("Question", "سؤال")} {idx + 1}
                    </span>
                    <button
                      onClick={() => handleDeleteQuestion(q.id)}
                      className="text-xs text-destructive hover:underline"
                    >
                      {t("Delete", "حذف")}
                    </button>
                  </div>
                  <div className="mb-3 grid gap-2 sm:grid-cols-2">
                    <input
                      defaultValue={q.question}
                      onBlur={(e) => handleUpdateQuestion(q.id, e.target.value, q.question_ar)}
                      className="rounded-lg border border-border bg-background px-3 py-2 text-sm"
                    />
                    <input
                      dir="rtl"
                      defaultValue={q.question_ar}
                      onBlur={(e) => handleUpdateQuestion(q.id, q.question, e.target.value)}
                      className="rounded-lg border border-border bg-background px-3 py-2 text-sm"
                    />
                  </div>
                  <div className="space-y-2">
                    {qOptions.map((o) => (
                      <div key={o.id} className="flex items-center gap-2">
                        <input
                          type="radio"
                          name={`correct-${q.id}`}
                          checked={o.is_correct}
                          onChange={() => handleSetCorrect(q.id, o.id)}
                        />
                        <input
                          defaultValue={o.option_text}
                          onBlur={(e) => handleUpdateOption(o.id, { option_text: e.target.value })}
                          className="flex-1 rounded-lg border border-border bg-background px-2 py-1.5 text-sm"
                        />
                        <input
                          dir="rtl"
                          defaultValue={o.option_text_ar}
                          onBlur={(e) => handleUpdateOption(o.id, { option_text_ar: e.target.value })}
                          className="flex-1 rounded-lg border border-border bg-background px-2 py-1.5 text-sm"
                        />
                      </div>
                    ))}
                  </div>
                  <p className="mt-2 text-[11px] text-muted-foreground">
                    {t("Select the radio button next to the correct answer.", "اختر الزر بجانب الإجابة الصحيحة.")}
                  </p>
                </div>
              );
            })}
            <button
              onClick={handleAddQuestion}
              disabled={authoring.saving}
              className="rounded-lg border border-dashed border-border px-4 py-2 text-sm font-medium text-foreground hover:bg-secondary"
            >
              {t("+ Add Question", "+ إضافة سؤال")}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
