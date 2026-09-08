import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { useCurriculum } from "@/hooks/use-curriculum";
import { useAuthoring } from "@/hooks/use-authoring";

export const Route = createFileRoute("/dashboard/authoring/")({
  head: () => ({
    meta: [{ title: "Course Authoring — Finix Academy" }],
  }),
  component: () => (
    <Protected staffOnly>
      <AuthoringIndexPage />
    </Protected>
  ),
});

function slugify(input: string) {
  return input
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}

function AuthoringIndexPage() {
  const { t } = useLang();
  const { tracks, modules, loading, refresh } = useCurriculum(true);
  const { createModule, togglePublish, saving, error } = useAuthoring();
  const [showNew, setShowNew] = useState(false);
  const [form, setForm] = useState({
    title: "",
    title_ar: "",
    summary: "",
    summary_ar: "",
    track_id: "",
    code: "",
  });

  async function handleCreate() {
    if (!form.title || !form.track_id) return;
    const nextPosition = modules.filter((m) => m.track_id === form.track_id).length + 1;
    const result = await createModule({
      slug: slugify(form.title),
      code: form.code || `M${String(modules.length + 1).padStart(2, "0")}`,
      track_id: form.track_id,
      title: form.title,
      title_ar: form.title_ar || form.title,
      summary: form.summary,
      summary_ar: form.summary_ar || form.summary,
      external_url: null,
      position: nextPosition,
      published: false,
    });
    if (result) {
      setShowNew(false);
      setForm({ title: "", title_ar: "", summary: "", summary_ar: "", track_id: "", code: "" });
      refresh();
    }
  }

  async function handleTogglePublish(id: string, current: boolean) {
    await togglePublish(id, !current);
    refresh();
  }

  return (
    <div className="p-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">
            {t("Course Authoring", "تحرير الدورات")}
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {t(
              "Create and manage modules, lessons, and quiz questions.",
              "أنشئ وأدر الوحدات والدروس وأسئلة الاختبارات.",
            )}
          </p>
        </div>
        <button
          onClick={() => setShowNew((v) => !v)}
          className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:opacity-90"
        >
          {showNew ? t("Cancel", "إلغاء") : t("+ New Module", "+ وحدة جديدة")}
        </button>
      </div>

      {error && (
        <div className="mb-4 rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm text-destructive">
          {error}
        </div>
      )}

      {showNew && (
        <div className="mb-8 rounded-xl border border-border bg-card p-6">
          <h2 className="mb-4 text-lg font-semibold text-foreground">
            {t("New Module", "وحدة جديدة")}
          </h2>
          <div className="grid gap-4 sm:grid-cols-2">
            <label className="flex flex-col gap-1 text-sm">
              <span className="text-muted-foreground">{t("Track", "المسار")}</span>
              <select
                value={form.track_id}
                onChange={(e) => setForm((f) => ({ ...f, track_id: e.target.value }))}
                className="rounded-lg border border-border bg-background px-3 py-2"
              >
                <option value="">{t("Select track…", "اختر مسارًا…")}</option>
                {tracks.map((tr) => (
                  <option key={tr.id} value={tr.id}>
                    {tr.name}
                  </option>
                ))}
              </select>
            </label>
            <label className="flex flex-col gap-1 text-sm">
              <span className="text-muted-foreground">{t("Module Code", "رمز الوحدة")}</span>
              <input
                value={form.code}
                onChange={(e) => setForm((f) => ({ ...f, code: e.target.value }))}
                placeholder="M11"
                className="rounded-lg border border-border bg-background px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-1 text-sm sm:col-span-2">
              <span className="text-muted-foreground">{t("Title (English)", "العنوان (إنجليزي)")}</span>
              <input
                value={form.title}
                onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))}
                className="rounded-lg border border-border bg-background px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-1 text-sm sm:col-span-2">
              <span className="text-muted-foreground">{t("Title (Arabic)", "العنوان (عربي)")}</span>
              <input
                dir="rtl"
                value={form.title_ar}
                onChange={(e) => setForm((f) => ({ ...f, title_ar: e.target.value }))}
                className="rounded-lg border border-border bg-background px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-1 text-sm sm:col-span-2">
              <span className="text-muted-foreground">{t("Summary (English)", "الملخص (إنجليزي)")}</span>
              <textarea
                value={form.summary}
                onChange={(e) => setForm((f) => ({ ...f, summary: e.target.value }))}
                rows={3}
                className="rounded-lg border border-border bg-background px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-1 text-sm sm:col-span-2">
              <span className="text-muted-foreground">{t("Summary (Arabic)", "الملخص (عربي)")}</span>
              <textarea
                dir="rtl"
                value={form.summary_ar}
                onChange={(e) => setForm((f) => ({ ...f, summary_ar: e.target.value }))}
                rows={3}
                className="rounded-lg border border-border bg-background px-3 py-2"
              />
            </label>
          </div>
          <button
            onClick={handleCreate}
            disabled={saving || !form.title || !form.track_id}
            className="mt-4 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:opacity-90 disabled:opacity-50"
          >
            {saving ? t("Saving…", "جارٍ الحفظ…") : t("Create Module", "إنشاء الوحدة")}
          </button>
        </div>
      )}

      <div className="overflow-hidden rounded-xl border border-border bg-card">
        {loading ? (
          <p className="p-6 text-sm text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</p>
        ) : (
          <div className="divide-y divide-border">
            {modules.map((m) => (
              <div key={m.id} className="flex items-center justify-between gap-4 p-4">
                <div className="flex items-center gap-3">
                  <span className="font-mono text-xs text-muted-foreground">{m.code}</span>
                  <div>
                    <p className="text-sm font-medium text-foreground">{m.title}</p>
                    <p className="text-xs text-muted-foreground">
                      {m.lessons.length} {t("lessons", "دروس")}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <span
                    className={`rounded-full px-2.5 py-0.5 text-[11px] font-medium ${
                      m.published ? "bg-green-500/10 text-green-700" : "bg-secondary text-muted-foreground"
                    }`}
                  >
                    {m.published ? t("Published", "منشورة") : t("Draft", "مسودة")}
                  </span>
                  <button
                    onClick={() => handleTogglePublish(m.id, m.published)}
                    disabled={saving}
                    className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-foreground hover:bg-secondary disabled:opacity-50"
                  >
                    {m.published ? t("Unpublish", "إلغاء النشر") : t("Publish", "نشر")}
                  </button>
                  <Link
                    to="/dashboard/authoring/$moduleId"
                    params={{ moduleId: m.id }}
                    className="rounded-lg bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:opacity-90"
                  >
                    {t("Edit", "تحرير")}
                  </Link>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
