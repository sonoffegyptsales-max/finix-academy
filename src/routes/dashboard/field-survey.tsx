import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { useLang } from "@/lib/language";
import { finixSurveyStages } from "@/content/finix";

export const Route = createFileRoute("/dashboard/field-survey")({
  head: () => ({
    meta: [{ title: "Field Survey — Finix Academy" }],
  }),
  component: FieldSurveyPage,
});

const ENTRIES_KEY = "finix-survey-entries";

function readEntries() {
  if (typeof window === "undefined") return [];
  try {
    const parsed = JSON.parse(localStorage.getItem(ENTRIES_KEY) ?? "[]");
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function saveEntries(entries) {
  localStorage.setItem(ENTRIES_KEY, JSON.stringify(entries));
}

function FieldSurveyPage() {
  const [projectName, setProjectName] = useState("");
  const [clientName, setClientName] = useState("");
  const [notes, setNotes] = useState("");
  const [stages, setStages] = useState({});
  const [entries, setEntries] = useState(readEntries());
  const [saved, setSaved] = useState(false);

  const filledCount = finixSurveyStages.filter(
    (s) => (stages[s.id] ?? "").trim(),
  ).length;

  const handleSave = () => {
    if (filledCount === 0) return;
    const entry = {
      id: new Date().toISOString(),
      projectName: projectName.trim() || "Unnamed project",
      clientName: clientName.trim(),
      date: new Date().toISOString(),
      stages,
      stageCount: filledCount,
    };
    const next = [entry, ...entries];
    saveEntries(next);
    setEntries(next);
    setProjectName("");
    setClientName("");
    setNotes("");
    setStages({});
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  const remove = (id) => {
    const next = entries.filter((e) => e.id !== id);
    saveEntries(next);
    setEntries(next);
  };

  return (
    <div className="p-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Field Survey</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Site survey & engineering audit tool
          </p>
        </div>
        {saved && (
          <span className="rounded-full bg-green-500/10 px-3 py-1 text-xs font-medium text-green-600">
            Report saved!
          </span>
        )}
      </div>

      <div className="overflow-hidden rounded-xl border border-border bg-card p-6 shadow-sm">
        <h2 className="mb-4 text-lg font-semibold text-foreground">New Site Survey</h2>

        <div className="mb-6 grid gap-4 sm:grid-cols-2">
          <div>
            <label className="mb-1.5 block text-sm font-medium text-foreground">
              Project Name *
            </label>
            <input
              value={projectName}
              onChange={(e) => setProjectName(e.target.value)}
              placeholder="Villa 12, Al Olaya, Riyadh"
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
            />
          </div>
          <div>
            <label className="mb-1.5 block text-sm font-medium text-foreground">
              Client Name
            </label>
            <input
              value={clientName}
              onChange={(e) => setClientName(e.target.value)}
              placeholder="Ahmed Al-Rashidi"
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
            />
          </div>
        </div>

        <div className="mb-6 space-y-4">
          {finixSurveyStages.map((stage, i) => (
            <div
              key={stage.id}
              className="overflow-hidden rounded-xl border border-border bg-background p-5"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary">
                    Stage {i + 1}
                  </span>
                  <h3 className="text-base font-semibold text-foreground">
                    {stage.name}
                  </h3>
                </div>
              </div>
              <textarea
                value={stages[stage.id] ?? ""}
                onChange={(e) =>
                  setStages((prev) => ({
                    ...prev,
                    [stage.id]: e.target.value,
                  }))
                }
                rows={3}
                placeholder={stage.hint}
                className="mt-3 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
              />
              <p className="mt-1.5 text-xs text-muted-foreground">
                {stages[stage.id]?.trim() ? (
                  <span className="text-green-600">Filled ✓</span>
                ) : (
                  <span className="text-muted-foreground">Not filled</span>
                )}
              </p>
            </div>
          ))}
        </div>

        <div className="mb-6">
          <label className="mb-1.5 block text-sm font-medium text-foreground">
            Additional Notes
          </label>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            rows={2}
            placeholder="General observations…"
            className="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
          />
        </div>

        <div className="flex items-center justify-between gap-4 border-t border-border pt-4">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5">
              <div className="h-2 w-2 rounded-full bg-primary" />
              <span className="text-sm text-muted-foreground">
                {filledCount} / {finixSurveyStages.length} stages filled
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
              Clear
            </button>
            <button
              onClick={handleSave}
              disabled={filledCount === 0}
              className="rounded-lg bg-primary px-6 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
            >
              Submit Report
            </button>
          </div>
        </div>
      </div>

      {entries.length > 0 && (
        <div className="mt-8">
          <h2 className="mb-4 text-lg font-semibold text-foreground">Saved Reports</h2>
          <div className="overflow-hidden rounded-xl border border-border bg-card">
            <div className="divide-y divide-border">
              {entries.map((entry) => (
                <div
                  key={entry.id}
                  className="flex items-start justify-between gap-4 p-4"
                >
                  <div className="flex flex-col">
                    <p className="text-sm font-medium text-foreground">
                      {entry.projectName}
                      {entry.clientName ? (
                        <span className="ml-2 text-muted-foreground">
                          · {entry.clientName}
                        </span>
                      ) : null}
                    </p>
                    <p className="mt-1 text-xs text-muted-foreground">
                      {new Date(entry.date).toLocaleDateString()} · {entry.stageCount} stages
                    </p>
                    <div className="mt-2 space-y-1">
                      {finixSurveyStages.map((s, i) =>
                        entry.stages[s.id]?.trim() ? (
                          <div key={s.id} className="text-xs leading-relaxed text-muted-foreground">
                            <span className="font-medium text-foreground">
                              Stage {i + 1} ({s.name}):
                            </span>{" "}
                            {entry.stages[s.id]}
                          </div>
                        ) : null,
                      )}
                    </div>
                  </div>
                  <button
                    onClick={() => remove(entry.id)}
                    className="text-xs text-muted-foreground hover:text-destructive transition-colors"
                  >
                    Delete
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
