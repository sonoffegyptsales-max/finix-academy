import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { Protected, useAuth } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { supabase } from "@/integrations/supabase/client";
import { finixSurveyStages } from "@/content/finix";

export const Route = createFileRoute("/dashboard/field-survey")({
  head: () => ({
    meta: [{ title: "Field Survey — Finix Academy" }],
  }),
  component: () => (
    <Protected>
      <FieldSurveyPage />
    </Protected>
  ),
});

const LOCAL_KEY = "finix-survey-entries";

function readLocal() {
  if (typeof window === "undefined") return [];
  try {
    const parsed = JSON.parse(localStorage.getItem(LOCAL_KEY) ?? "[]");
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function FieldSurveyPage() {
  const { t } = useLang();
  const { user } = useAuth();
  const [projectName, setProjectName] = useState("");
  const [clientName, setClientName] = useState("");
  const [notes, setNotes] = useState("");
  const [stages, setStages] = useState({});
  const [entries, setEntries] = useState([]);
  const [saved, setSaved] = useState(false);
  const [usingFallback, setUsingFallback] = useState(false);

  const loadEntries = async () => {
    if (!user) {
      setEntries(readLocal());
      setUsingFallback(true);
      return;
    }
    try {
      const { data, error } = await supabase
        .from("survey_reports")
        .select("id, project_name, client_name, stages, created_at")
        .order("created_at", { ascending: false })
        .limit(50);
      if (error) throw error;
      setEntries(
        (data ?? []).map((row) => ({
          id: row.id,
          projectName: row.project_name,
          clientName: row.client_name,
          date: row.created_at,
          stages: row.stages,
          stageCount: Object.values(row.stages ?? {}).filter((v) => String(v).trim()).length,
        })),
      );
      setUsingFallback(false);
    } catch {
      setEntries(readLocal());
      setUsingFallback(true);
    }
  };

  useState(() => {
    void loadEntries();
  });

  const filledCount = finixSurveyStages.filter((s) => (stages[s.id] ?? "").trim()).length;

  const handleSave = async () => {
    if (filledCount === 0) return;
    const name = projectName.trim() || "Unnamed project";

    if (user) {
      try {
        const { error } = await supabase.from("survey_reports").insert({
          created_by: user.id,
          project_name: name,
          client_name: clientName.trim() || null,
          stages,
          notes: notes.trim() || null,
        });
        if (error) throw error;
      } catch {
        // fall through to local
      }
    }

    const local = readLocal();
    local.unshift({
      id: new Date().toISOString(),
      projectName: name,
      clientName: clientName.trim(),
      date: new Date().toISOString(),
      stages,
      stageCount: filledCount,
    });
    localStorage.setItem(LOCAL_KEY, JSON.stringify(local));

    await loadEntries();
    setProjectName("");
    setClientName("");
    setNotes("");
    setStages({});
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="p-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">{t("Field Survey", "مسح الموقع")}</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {t("Site survey & engineering audit tool", "أداة مسح الموقع والتدقيق الهندسي")}
          </p>
        </div>
        {saved && (
          <span className="rounded-full bg-green-500/10 px-3 py-1 text-xs font-medium text-green-600">
            {t("Report saved!", "تم حفظ التقرير!")}
          </span>
        )}
      </div>

      {usingFallback && (
        <div className="mb-6 rounded-lg border border-amber-300 bg-amber-50 px-4 py-3 text-xs text-amber-800">
          {t(
            "Saving locally — backend survey table isn't connected yet.",
            "الحفظ محليًا — لم يتم توصيل جدول التقارير في الخادم بعد.",
          )}
        </div>
      )}

      <div className="overflow-hidden rounded-xl border border-border bg-card p-6 shadow-sm">
        <h2 className="mb-4 text-lg font-semibold text-foreground">
          {t("New Site Survey", "مسح موقع جديد")}
        </h2>

        <div className="mb-6 grid gap-4 sm:grid-cols-2">
          <div>
            <label className="mb-1.5 block text-sm font-medium text-foreground">
              {t("Project Name *", "اسم المشروع *")}
            </label>
            <input
              value={projectName}
              onChange={(e) => setProjectName(e.target.value)}
              placeholder={t("Villa 12, Al Olaya, Riyadh", "فيلا ١٢، العليا، الرياض")}
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
            />
          </div>
          <div>
            <label className="mb-1.5 block text-sm font-medium text-foreground">
              {t("Client Name", "اسم العميل")}
            </label>
            <input
              value={clientName}
              onChange={(e) => setClientName(e.target.value)}
              placeholder={t("Ahmed Al-Rashidi", "أحمد الرشيدي")}
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
            />
          </div>
        </div>

        <div className="mb-6 space-y-4">
          {finixSurveyStages.map((stage, i) => (
            <div key={stage.id} className="overflow-hidden rounded-xl border border-border bg-background p-5">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary">
                    {t("Stage", "المرحلة")} {i + 1}
                  </span>
                  <h3 className="text-base font-semibold text-foreground">
                    {t(stage.name, stage.nameAr)}
                  </h3>
                </div>
              </div>
              <textarea
                value={stages[stage.id] ?? ""}
                onChange={(e) => setStages((prev) => ({ ...prev, [stage.id]: e.target.value }))}
                rows={3}
                placeholder={t(stage.hint, stage.hintAr)}
                className="mt-3 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
              />
              <p className="mt-1.5 text-xs text-muted-foreground">
                {stages[stage.id]?.trim() ? (
                  <span className="text-green-600">{t("Filled ✓", "تم الاستكمال ✓")}</span>
                ) : (
                  <span className="text-muted-foreground">{t("Not filled", "غير مستكمل")}</span>
                )}
              </p>
            </div>
          ))}
        </div>

        <div className="mb-6">
          <label className="mb-1.5 block text-sm font-medium text-foreground">
            {t("Additional Notes", "ملاحظات إضافية")}
          </label>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            rows={2}
            placeholder={t("General observations…", "ملاحظات عامة…")}
            className="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
          />
        </div>

        <div className="flex items-center justify-between gap-4 border-t border-border pt-4">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5">
              <div className="h-2 w-2 rounded-full bg-primary" />
              <span className="text-sm text-muted-foreground">
                {filledCount} / {finixSurveyStages.length} {t("stages filled", "مراحل مستكملة")}
              </span>
            </div>
            <div className="h-2 w-24 overflow-hidden rounded-full bg-secondary">
              <div
                className="h-full rounded-full bg-primary transition-all"
                style={{ width: `${(filledCount / finixSurveyStages.length) * 100}%` }}
              />
            </div>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={() => {
                setStages({});
                setProjectName("");
                setClientName("");
                setNotes("");
              }}
              className="rounded-lg border border-border bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-secondary transition-colors"
            >
              {t("Clear", "مسح")}
            </button>
            <button
              onClick={handleSave}
              disabled={filledCount === 0}
              className="rounded-lg bg-primary px-6 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {t("Submit Report", "إرسال التقرير")}
            </button>
          </div>
        </div>
      </div>

      {entries.length > 0 && (
        <div className="mt-8">
          <h2 className="mb-4 text-lg font-semibold text-foreground">
            {t("Saved Reports", "التقارير المحفوظة")}
          </h2>
          <div className="overflow-hidden rounded-xl border border-border bg-card">
            <div className="divide-y divide-border">
              {entries.map((entry) => (
                <div key={entry.id} className="flex items-start justify-between gap-4 p-4">
                  <div className="flex flex-col">
                    <p className="text-sm font-medium text-foreground">
                      {entry.projectName}
                      {entry.clientName ? (
                        <span className="ml-2 text-muted-foreground">· {entry.clientName}</span>
                      ) : null}
                    </p>
                    <p className="mt-1 text-xs text-muted-foreground">
                      {new Date(entry.date).toLocaleDateString()} · {entry.stageCount} {t("stages", "مراحل")}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
