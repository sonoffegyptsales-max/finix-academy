import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { finixSurveyStages } from "@/content/finix";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";

export const Route = createFileRoute("/finix/survey")({
  head: () => ({
    meta: [
      { title: "Site Survey & Engineering Audit — Finix Academy" },
      {
        name: "description",
        content:
          "Five-stage site survey and engineering audit form for smart home and automation projects.",
      },
    ],
  }),
  component: () => (
    <Protected>
      <FinixSurveyTool />
    </Protected>
  ),
});

interface SurveyEntry {
  id: string;
  projectName: string;
  clientName: string;
  date: string;
  stages: Record<string, string>;
}

const ENTRIES_KEY = "finix-survey-entries";

function readEntries(): SurveyEntry[] {
  try {
    const parsed: unknown = JSON.parse(localStorage.getItem(ENTRIES_KEY) ?? "[]");
    return Array.isArray(parsed) ? (parsed as SurveyEntry[]) : [];
  } catch {
    return [];
  }
}

function FinixSurveyTool() {
  const { t } = useLang();
  const [projectName, setProjectName] = useState("");
  const [clientName, setClientName] = useState("");
  const [stages, setStages] = useState<Record<string, string>>({});
  const [entries, setEntries] = useState<SurveyEntry[]>([]);

  useEffect(() => {
    setEntries(readEntries());
  }, []);

  const filledCount = finixSurveyStages.filter((s) => (stages[s.id] ?? "").trim()).length;

  const save = () => {
    const entry: SurveyEntry = {
      id: `${Date.now()}`,
      projectName:
        projectName.trim() || t("Unnamed project", "مشروع بدون اسم"),
      clientName: clientName.trim(),
      date: new Date().toISOString(),
      stages,
    };
    const next = [entry, ...entries];
    localStorage.setItem(ENTRIES_KEY, JSON.stringify(next));
    setEntries(next);
    setProjectName("");
    setClientName("");
    setStages({});
  };

  const remove = (id: string) => {
    const next = entries.filter((e) => e.id !== id);
    localStorage.setItem(ENTRIES_KEY, JSON.stringify(next));
    setEntries(next);
  };

  const inputClass =
    "w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground";

  return (
    <div className="mx-auto max-w-3xl px-6 py-14">
      <Link to="/finix" className="text-sm text-muted-foreground hover:text-accent">
        {t("← Finix Academy", "← أكاديمية فينيكس")}
      </Link>
      <h1 className="mt-6 text-4xl font-bold tracking-tight text-foreground">
        {t("Site Survey & Engineering Audit", "مسح الموقع والتدقيق الهندسي")}
      </h1>
      <p className="mt-3 text-lg text-muted-foreground">
        {t(
          "Five-stage site survey and engineering audit form — fill each stage during the visit, then save the report for handover.",
          "استمارة مسح موقع وتدقيق هندسي من خمس مراحل — املأ كل مرحلة أثناء الزيارة ثم احفظ التقرير للتسليم.",
        )}
      </p>

      <div className="mt-8 grid gap-4 sm:grid-cols-2">
        <div>
          <label className="mb-1.5 block text-sm font-medium text-foreground">
            {t("Project Name *", "اسم المشروع *")}
          </label>
          <input
            value={projectName}
            onChange={(e) => setProjectName(e.target.value)}
            placeholder={t("Villa 12, Al Olaya, Riyadh", "فيلا ١٢، العليا، الرياض")}
            className={inputClass}
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
            className={inputClass}
          />
        </div>
      </div>

      <div className="mt-8 space-y-4">
        {finixSurveyStages.map((stage, i) => (
          <section key={stage.id} className="rounded-2xl border border-border bg-card p-6">
            <h2 className="font-semibold text-foreground">
              <span className="mr-2 font-mono text-xs text-accent">
                {t("Stage", "المرحلة")} {i + 1}
              </span>
              {t(stage.name, stage.nameAr)}
            </h2>
            <textarea
              value={stages[stage.id] ?? ""}
              onChange={(e) =>
                setStages((prev) => ({ ...prev, [stage.id]: e.target.value }))
              }
              rows={3}
              placeholder={t(stage.hint, stage.hintAr)}
              className="mt-3 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground"
            />
          </section>
        ))}
      </div>

      <div className="mt-6 flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm text-muted-foreground">
          {filledCount} / {finixSurveyStages.length} {t("stages filled", "مراحل مكتملة")}
        </p>
        <div className="flex gap-3">
          <button
            onClick={() => setStages({})}
            className="rounded-lg border border-border px-4 py-2 text-sm font-medium text-foreground hover:bg-secondary"
          >
            {t("Clear stages", "تفريغ المراحل")}
          </button>
          <button
            onClick={save}
            disabled={filledCount === 0}
            className="rounded-lg bg-primary px-5 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
          >
            {t("Submit Report", "إرسال التقرير")}
          </button>
        </div>
      </div>

      {entries.length > 0 && (
        <section className="mt-10">
          <h2 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
            {t("Saved reports", "التقارير المحفوظة")}
          </h2>
          <ul className="mt-3 space-y-3">
            {entries.map((e) => (
              <li key={e.id} className="rounded-xl border border-border bg-card p-4">
                <div className="flex items-center justify-between gap-4">
                  <p className="text-sm font-medium text-foreground">
                    {e.projectName}
                    {e.clientName ? (
                      <span className="text-muted-foreground"> · {e.clientName}</span>
                    ) : null}
                    <span className="ml-2 text-xs font-normal text-muted-foreground">
                      {new Date(e.date).toLocaleDateString()}
                    </span>
                  </p>
                  <button
                    onClick={() => remove(e.id)}
                    className="text-xs text-muted-foreground hover:text-red-500"
                  >
                    {t("Delete", "حذف")}
                  </button>
                </div>
                <dl className="mt-2 space-y-1">
                  {finixSurveyStages.map((s, i) =>
                    e.stages[s.id]?.trim() ? (
                      <div key={s.id} className="text-xs leading-relaxed text-muted-foreground">
                        <dt className="inline font-medium text-foreground">
                          {t("Stage", "المرحلة")} {i + 1} ({t(s.name, s.nameAr)}):{" "}
                        </dt>
                        <dd className="inline">{e.stages[s.id]}</dd>
                      </div>
                    ) : null,
                  )}
                </dl>
              </li>
            ))}
          </ul>
        </section>
      )}
    </div>
  );
}
