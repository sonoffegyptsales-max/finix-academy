import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { Protected, useAuth } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { supabase } from "@/integrations/supabase/client";
import { finixKpiGroups, FINIX_KPI_MAX_SCORE, finixKpiBand } from "@/content/finix";

export const Route = createFileRoute("/dashboard/kpi-evaluator")({
  head: () => ({
    meta: [{ title: "KPI Evaluator — Finix Academy" }],
  }),
  component: () => (
    <Protected staffOnly>
      <KpiEvaluatorPage />
    </Protected>
  ),
});

interface KpiEntryRow {
  id: string;
  trainee_name: string;
  project_name: string | null;
  final_percent: number;
  band: string;
  created_at: string;
}

const LOCAL_KEY = "finix-kpi-entries";

function readLocal() {
  if (typeof window === "undefined") return [];
  try {
    const parsed = JSON.parse(localStorage.getItem(LOCAL_KEY) ?? "[]");
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function groupPercent(scores, groupId) {
  const group = finixKpiGroups.find((g) => g.id === groupId);
  if (!group) return 0;
  const total = group.criteria.length * FINIX_KPI_MAX_SCORE;
  const earned = group.criteria.reduce((sum, c) => sum + (scores[c.id] ?? 0), 0);
  return total > 0 ? Math.round((earned / total) * 100) : 0;
}

function finalGrade(scores) {
  return Math.round(
    groupPercent(scores, "technical") * 0.6 + groupPercent(scores, "behavioral") * 0.4,
  );
}

function KpiEvaluatorPage() {
  const { t } = useLang();
  const { user } = useAuth();
  const [trainee, setTrainee] = useState("");
  const [project, setProject] = useState("");
  const [feedback, setFeedback] = useState("");
  const [scores, setScores] = useState({});
  const [entries, setEntries] = useState<KpiEntryRow[]>([]);
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
        .from("kpi_evaluations")
        .select("id, trainee_name, project_name, final_percent, band, created_at")
        .order("created_at", { ascending: false })
        .limit(50);
      if (error) throw error;
      setEntries(data ?? []);
      setUsingFallback(false);
    } catch {
      setEntries(readLocal());
      setUsingFallback(true);
    }
  };

  useState(() => {
    void loadEntries();
  });

  const percent = finalGrade(scores);
  const scoredAll = finixKpiGroups.every((g) => g.criteria.every((c) => scores[c.id] != null));
  const band = finixKpiBand(percent);

  const handleSave = async () => {
    if (!scoredAll) return;
    const traineeName = trainee.trim() || "Unnamed trainee";
    const technicalPercent = groupPercent(scores, "technical");
    const behavioralPercent = groupPercent(scores, "behavioral");

    if (user) {
      try {
        const { error } = await supabase.from("kpi_evaluations").insert({
          evaluator_id: user.id,
          trainee_name: traineeName,
          project_name: project.trim() || null,
          scores,
          technical_percent: technicalPercent,
          behavioral_percent: behavioralPercent,
          final_percent: percent,
          band: band.en,
          feedback: feedback.trim() || null,
        });
        if (error) throw error;
      } catch {
        // fall through to local
      }
    }

    const local = readLocal();
    local.unshift({
      id: new Date().toISOString(),
      trainee_name: traineeName,
      project_name: project.trim() || null,
      final_percent: percent,
      band: band.en,
      created_at: new Date().toISOString(),
    });
    localStorage.setItem(LOCAL_KEY, JSON.stringify(local));

    await loadEntries();
    setScores({});
    setTrainee("");
    setProject("");
    setFeedback("");
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="p-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">
            {t("KPI Evaluator", "تقييم الأداء")}
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {t("Evaluate technician field performance", "تقييم أداء الفنيين في الميدان")}
          </p>
        </div>
        {saved && (
          <span className="rounded-full bg-green-500/10 px-3 py-1 text-xs font-medium text-green-600">
            {t("Saved!", "تم الحفظ!")}
          </span>
        )}
      </div>

      {usingFallback && (
        <div className="mb-6 rounded-lg border border-amber-300 bg-amber-50 px-4 py-3 text-xs text-amber-800">
          {t(
            "Saving locally — backend evaluation table isn't connected yet.",
            "الحفظ محليًا — لم يتم توصيل جدول التقييمات في الخادم بعد.",
          )}
        </div>
      )}

      <div className="overflow-hidden rounded-xl border border-border bg-card p-6 shadow-sm">
        <div className="mb-6 grid gap-4 sm:grid-cols-2">
          <div>
            <label className="mb-1.5 block text-sm font-medium text-foreground">
              {t("Trainee *", "المتدرب *")}
            </label>
            <input
              value={trainee}
              onChange={(e) => setTrainee(e.target.value)}
              placeholder={t("Enter trainee name", "أدخل اسم المتدرب")}
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
            />
          </div>
          <div>
            <label className="mb-1.5 block text-sm font-medium text-foreground">
              {t("Project Name", "اسم المشروع")}
            </label>
            <input
              value={project}
              onChange={(e) => setProject(e.target.value)}
              placeholder={t("e.g. Villa 5, Riyadh", "مثال: فيلا 5، الرياض")}
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
            />
          </div>
        </div>

        {finixKpiGroups.map((group) => (
          <section key={group.id} className="mb-6">
            <div className="flex items-center justify-between">
              <h2 className="text-base font-semibold text-foreground">
                {t(group.title, group.titleAr)}
                <span className="ml-2 text-sm font-normal text-muted-foreground">
                  ({Math.round(group.weight * 100)}%)
                </span>
              </h2>
              <span className="text-sm font-semibold text-primary">
                {groupPercent(scores, group.id)}%
              </span>
            </div>
            <div className="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {group.criteria.map((criterion) => (
                <div
                  key={criterion.id}
                  className="overflow-hidden rounded-lg border border-border bg-background p-4"
                >
                  <div className="flex items-center justify-between gap-2">
                    <p className="text-sm font-medium text-foreground">
                      {t(criterion.label, criterion.labelAr)}
                    </p>
                    <span className="font-mono text-xs text-muted-foreground">
                      {scores[criterion.id] ?? FINIX_KPI_MAX_SCORE} / {FINIX_KPI_MAX_SCORE}
                    </span>
                  </div>
                  <div className="mt-3 flex gap-1.5">
                    {Array.from({ length: FINIX_KPI_MAX_SCORE + 1 }, (_, v) => {
                      const selected = (scores[criterion.id] ?? FINIX_KPI_MAX_SCORE) === v;
                      return (
                        <button
                          key={v}
                          onClick={() =>
                            setScores((prev) => ({ ...prev, [criterion.id]: v }))
                          }
                          className={`flex h-8 w-8 items-center justify-center rounded-lg border text-sm font-medium transition-colors ${
                            selected
                              ? "border-primary bg-primary text-primary-foreground"
                              : "border-input bg-background text-muted-foreground hover:border-primary hover:text-foreground"
                          }`}
                        >
                          {v}
                        </button>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          </section>
        ))}

        <div className="mb-6 overflow-hidden rounded-xl border border-border bg-background p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">{t("Final Grade", "الدرجة النهائية")}</p>
              <p className="mt-1 text-xs text-muted-foreground">
                {t("Technical (60%) + Behavioral (40%)", "فني (٦٠٪) + سلوكي (٤٠٪)")}
              </p>
            </div>
            <div className="text-right">
              <p className="text-3xl font-bold text-foreground">
                {scoredAll ? `${percent}%` : "—"}
              </p>
              {scoredAll && (
                <p className="mt-1 text-sm font-medium text-primary">{t(band.en, band.ar)}</p>
              )}
            </div>
          </div>
        </div>

        <div className="mb-6">
          <label className="mb-1.5 block text-sm font-medium text-foreground">
            {t("Feedback Notes", "ملاحظات توجيهية")}
          </label>
          <textarea
            value={feedback}
            onChange={(e) => setFeedback(e.target.value)}
            rows={3}
            placeholder={t("Additional feedback for the trainee…", "ملاحظات إضافية للمتدرب…")}
            className="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
          />
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={handleSave}
            disabled={!scoredAll}
            className="rounded-lg bg-primary px-6 py-2.5 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
          >
            {t("Submit Evaluation", "إرسال التقييم")}
          </button>
          <button
            onClick={() => {
              setScores({});
              setTrainee("");
              setProject("");
              setFeedback("");
            }}
            className="rounded-lg border border-border bg-card px-4 py-2.5 text-sm font-medium text-foreground hover:bg-secondary transition-colors"
          >
            {t("Clear", "مسح")}
          </button>
        </div>
      </div>

      {entries.length > 0 && (
        <div className="mt-8">
          <h2 className="mb-4 text-lg font-semibold text-foreground">
            {t("Saved Evaluations", "التقييمات المحفوظة")}
          </h2>
          <div className="overflow-hidden rounded-xl border border-border bg-card">
            <div className="divide-y divide-border">
              {entries.map((entry) => (
                <div key={entry.id} className="flex items-center justify-between gap-4 p-4">
                  <div className="flex flex-col">
                    <p className="text-sm font-medium text-foreground">
                      {entry.trainee_name}
                      {entry.project_name ? (
                        <span className="ml-2 text-muted-foreground">· {entry.project_name}</span>
                      ) : null}
                    </p>
                    <p className="mt-1 text-xs text-muted-foreground">
                      {new Date(entry.created_at).toLocaleDateString()} · {entry.final_percent}% · {entry.band}
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
