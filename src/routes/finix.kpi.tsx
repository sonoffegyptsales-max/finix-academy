import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import {
  FINIX_KPI_MAX_SCORE,
  finixKpiBand,
  finixKpiGroups,
} from "@/content/finix";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";

export const Route = createFileRoute("/finix/kpi")({
  head: () => ({
    meta: [
      { title: "KPI Evaluation — Finix Academy" },
      {
        name: "description",
        content:
          "Evaluate technician field performance across technical (60%) and behavioral (40%) criteria.",
      },
    ],
  }),
  component: () => (
    <Protected>
      <FinixKpiTool />
    </Protected>
  ),
});

interface KpiEntry {
  id: string;
  trainee: string;
  project: string;
  date: string;
  scores: Record<string, number>;
  percent: number;
}

const ENTRIES_KEY = "finix-kpi-entries";

function readEntries(): KpiEntry[] {
  try {
    const parsed: unknown = JSON.parse(localStorage.getItem(ENTRIES_KEY) ?? "[]");
    return Array.isArray(parsed) ? (parsed as KpiEntry[]) : [];
  } catch {
    return [];
  }
}

function groupPercent(scores: Record<string, number>, groupId: "technical" | "behavioral") {
  const group = finixKpiGroups.find((g) => g.id === groupId);
  if (!group) return 0;
  const total = group.criteria.length * FINIX_KPI_MAX_SCORE;
  const earned = group.criteria.reduce((sum, c) => sum + (scores[c.id] ?? 0), 0);
  return total > 0 ? Math.round((earned / total) * 100) : 0;
}

function finalGrade(scores: Record<string, number>) {
  return Math.round(
    groupPercent(scores, "technical") * 0.6 + groupPercent(scores, "behavioral") * 0.4,
  );
}

function FinixKpiTool() {
  const { t } = useLang();
  const [trainee, setTrainee] = useState("");
  const [project, setProject] = useState("");
  const [feedback, setFeedback] = useState("");
  const [scores, setScores] = useState<Record<string, number>>({});
  const [entries, setEntries] = useState<KpiEntry[]>([]);

  useEffect(() => {
    setEntries(readEntries());
  }, []);

  const percent = finalGrade(scores);
  const scoredAll = finixKpiGroups.every((g) =>
    g.criteria.every((c) => scores[c.id] != null),
  );
  const band = finixKpiBand(percent);

  const save = () => {
    const entry: KpiEntry = {
      id: `${Date.now()}`,
      trainee: trainee.trim() || t("Unnamed trainee", "متدرب بدون اسم"),
      project: project.trim(),
      date: new Date().toISOString(),
      scores,
      percent,
    };
    const next = [entry, ...entries];
    localStorage.setItem(ENTRIES_KEY, JSON.stringify(next));
    setEntries(next);
    setScores({});
    setTrainee("");
    setProject("");
    setFeedback("");
  };

  const remove = (id: string) => {
    const next = entries.filter((e) => e.id !== id);
    localStorage.setItem(ENTRIES_KEY, JSON.stringify(next));
    setEntries(next);
  };

  return (
    <div className="mx-auto max-w-3xl px-6 py-14">
      <Link to="/finix" className="text-sm text-muted-foreground hover:text-accent">
        {t("← Finix Academy", "← أكاديمية فينيكس")}
      </Link>
      <h1 className="mt-6 text-4xl font-bold tracking-tight text-foreground">
        {t("Technician Field KPI Evaluation", "تقييم الأداء الميداني للفني")}
      </h1>
      <p className="mt-3 text-lg text-muted-foreground">
        {t(
          "Evaluate technician performance across technical and behavioral criteria. Each criterion is scored 0–10; the final grade is Technical (60%) + Behavioral (40%).",
          "قيّم أداء الفني عبر معايير فنية وسلوكية. كل معيار يُقيّم من ٠ إلى ١٠، والدرجة النهائية = الفني (٦٠٪) + السلوكي (٤٠٪).",
        )}
      </p>

      <div className="mt-8 grid gap-4 sm:grid-cols-2">
        <div>
          <label className="mb-1.5 block text-sm font-medium text-foreground">
            {t("Trainee *", "المتدرب *")}
          </label>
          <input
            value={trainee}
            onChange={(e) => setTrainee(e.target.value)}
            placeholder={t("Select or type trainee name", "اختر أو اكتب اسم المتدرب")}
            className="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground"
          />
        </div>
        <div>
          <label className="mb-1.5 block text-sm font-medium text-foreground">
            {t("Project Name *", "اسم المشروع *")}
          </label>
          <input
            value={project}
            onChange={(e) => setProject(e.target.value)}
            placeholder={t("e.g. Villa 5, Riyadh", "مثال: فيلا ٥، الرياض")}
            className="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground"
          />
        </div>
      </div>

      {finixKpiGroups.map((group) => (
        <section key={group.id} className="mt-10">
          <h2 className="text-xl font-semibold text-foreground">
            {t(group.title, group.titleAr)}{" "}
            <span className="text-sm font-normal text-muted-foreground">
              ({group.weight * 100}%)
            </span>
          </h2>
          <div className="mt-4 space-y-3">
            {group.criteria.map((c) => (
              <div key={c.id} className="rounded-xl border border-border bg-card p-5">
                <div className="flex items-center justify-between gap-4">
                  <p className="font-medium text-foreground">{t(c.label, c.labelAr)}</p>
                  <span className="font-mono text-sm text-muted-foreground">
                    {scores[c.id] ?? 5}/{FINIX_KPI_MAX_SCORE}
                  </span>
                </div>
                <div className="mt-3 flex gap-2">
                  {Array.from({ length: FINIX_KPI_MAX_SCORE + 1 }, (_, v) => {
                    const selected = (scores[c.id] ?? 5) === v;
                    return (
                      <button
                        key={v}
                        onClick={() => setScores((prev) => ({ ...prev, [c.id]: v }))}
                        className={`h-9 w-9 rounded-lg border text-sm font-medium transition-colors ${
                          selected
                            ? "border-accent bg-accent text-white"
                            : "border-border text-muted-foreground hover:border-accent/50"
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
          <p className="mt-3 text-sm text-muted-foreground">
            {t(group.title + " Score", "درجة " + group.titleAr)}:{" "}
            <span className="font-semibold text-foreground">
              {groupPercent(scores, group.id)}%
            </span>
          </p>
        </section>
      ))}

      <div className="mt-10 rounded-2xl border border-border bg-card p-6">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div>
            <p className="text-sm text-muted-foreground">
              {t("Final Grade", "الدرجة النهائية")} — {t("Tech (60%) + Behavioral (40%)", "فني (٦٠٪) + سلوكي (٤٠٪)")}
            </p>
            <p className="text-4xl font-bold text-foreground">
              {scoredAll ? `${percent}%` : "—"}
            </p>
            {scoredAll && (
              <p className="mt-1 text-sm font-medium text-accent">{t(band.en, band.ar)}</p>
            )}
          </div>
        </div>
        <div className="mt-4">
          <label className="mb-1.5 block text-sm font-medium text-foreground">
            {t("Feedback Notes", "ملاحظات وملاحظات توجيهية")}
          </label>
          <textarea
            value={feedback}
            onChange={(e) => setFeedback(e.target.value)}
            rows={3}
            placeholder={t("Additional feedback for the trainee…", "ملاحظات إضافية للمتدرب…")}
            className="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground"
          />
        </div>
        <button
          onClick={save}
          disabled={!scoredAll}
          className="mt-4 rounded-lg bg-primary px-5 py-2.5 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
        >
          {t("Submit Evaluation", "إرسال التقييم")}
        </button>
      </div>

      {entries.length > 0 && (
        <section className="mt-10">
          <h2 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
            {t("Saved evaluations", "التقييمات المحفوظة")}
          </h2>
          <ul className="mt-3 divide-y divide-border rounded-xl border border-border bg-card">
            {entries.map((e) => (
              <li key={e.id} className="flex items-center justify-between gap-4 p-4">
                <div>
                  <p className="text-sm font-medium text-foreground">
                    {e.trainee}
                    {e.project ? <span className="text-muted-foreground"> · {e.project}</span> : null}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {new Date(e.date).toLocaleDateString()} · {e.percent}% ·{" "}
                    {t(finixKpiBand(e.percent).en, finixKpiBand(e.percent).ar)}
                  </p>
                </div>
                <button
                  onClick={() => remove(e.id)}
                  className="text-xs text-muted-foreground hover:text-red-500"
                >
                  {t("Delete", "حذف")}
                </button>
              </li>
            ))}
          </ul>
        </section>
      )}
    </div>
  );
}
